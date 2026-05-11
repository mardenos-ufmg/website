"""
ana_parana.py — Coleta dados de reservatórios ANA/SAR (Bacia do Paraná)
========================================================================

A tabela fica dentro de um <iframe> em:
  https://www.ana.gov.br/sarportal/sin-modulo-2.html?bacia=88

Dependências:
    pip install selenium beautifulsoup4

Uso:
    # Último dia disponível (padrão)
    python ana_parana.py

    # Desde o início histórico até hoje, semana a semana
    python ana_parana.py --inicio min --fim max --by semana

    # Intervalo mensal
    python ana_parana.py --inicio 01/2023 --fim 12/2023 --by mes

    # Intervalo diário com output customizado
    python ana_parana.py --inicio 01/05/2026 --fim 09/05/2026 --by dia --output saida.csv

    # Browser visível (debug)
    python ana_parana.py --visible

Formatos aceitos para --inicio / --fim:
    DD/MM/AAAA   ->  08/05/2026
    MM/AAAA      ->  05/2026   (dia 1 para --inicio, ultimo dia para --fim)
    AAAA         ->  2026      (jan/1 para --inicio, dez/31 para --fim)
    min          ->  23/08/2010 (dado mais antigo disponivel)
    max          ->  hoje
"""

import csv
import time
import argparse
import calendar
from datetime import date, datetime, timedelta

from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------

PAGE_URL   = "https://www.ana.gov.br/sar/sin/b_parana/"
IFRAME_SRC = "sin-modulo-2.html"
DATE_MIN   = date(2010, 8, 23)   # dado mais antigo disponivel no site
FIELDS     = ["data_referencia", "nome", "afluencia", "defluencia", "nivel", "volume_util"]
BY_OPTIONS = ("dia", "semana", "mes")


# ---------------------------------------------------------------------------
# Geracao de sequencia de datas
# ---------------------------------------------------------------------------

def _dates_by(inicio: date, fim: date, by: str) -> list:
    dates = []

    if by == "dia":
        cur = inicio
        while cur <= fim:
            dates.append(cur)
            cur += timedelta(days=1)

    elif by == "semana":
        cur = inicio
        while cur <= fim:
            dates.append(cur)
            cur += timedelta(weeks=1)

    elif by == "mes":
        cur = inicio
        while cur <= fim:
            dates.append(cur)
            month = cur.month + 1 if cur.month < 12 else 1
            year  = cur.year if cur.month < 12 else cur.year + 1
            day   = min(cur.day, calendar.monthrange(year, month)[1])
            cur   = date(year, month, day)

    else:
        raise ValueError(f"--by deve ser uma de: {BY_OPTIONS}")

    return dates


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def _make_driver(headless: bool = True) -> webdriver.Chrome:
    opts = Options()
    if headless:
        opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-blink-features=AutomationControlled")
    opts.add_experimental_option("excludeSwitches", ["enable-automation"])
    opts.add_experimental_option("useAutomationExtension", False)
    opts.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    )
    driver = webdriver.Chrome(options=opts)
    driver.execute_script(
        "Object.defineProperty(navigator, 'webdriver', {get: () => undefined})"
    )
    return driver


# ---------------------------------------------------------------------------
# Helpers de iframe
# ---------------------------------------------------------------------------

def _switch_to_data_iframe(driver, timeout: int = 30) -> bool:
    driver.switch_to.default_content()
    try:
        WebDriverWait(driver, timeout).until(
            EC.presence_of_element_located((By.TAG_NAME, "iframe"))
        )
    except TimeoutException:
        print("ERRO: nenhum iframe encontrado na pagina.")
        return False

    for frame in driver.find_elements(By.TAG_NAME, "iframe"):
        src  = frame.get_attribute("src")  or ""
        name = frame.get_attribute("name") or ""
        if IFRAME_SRC in src or name == "interno":
            driver.switch_to.frame(frame)
            return True

    try:
        driver.switch_to.frame("interno")
        return True
    except Exception:
        pass

    print("AVISO: iframe de dados nao encontrado.")
    return False


def _wait_table_in_frame(driver, timeout: int = 40) -> bool:
    try:
        WebDriverWait(driver, timeout).until(
            lambda d: len(d.find_elements(By.CSS_SELECTOR, "#tblDadosSIN tbody tr")) > 0
        )
        return True
    except TimeoutException:
        return False


# ---------------------------------------------------------------------------
# Leitura e parse
# ---------------------------------------------------------------------------

def _get_current_date_in_frame(driver) -> str:
    try:
        return (driver.find_element(By.ID, "calendario").get_attribute("value") or "").strip()
    except NoSuchElementException:
        return ""


def _parse_table(html: str, data_ref: str) -> list:
    soup  = BeautifulSoup(html, "html.parser")
    table = soup.find(id="tblDadosSIN")
    if not table:
        return []
    records = []
    for row in table.select("tbody tr"):
        cells = [td.get_text(strip=True) for td in row.find_all("td")]
        if not cells:
            continue
        records.append({
            "data_referencia": data_ref,
            "nome":        cells[0] if len(cells) > 0 else "",
            "afluencia":   cells[1] if len(cells) > 1 else "",
            "defluencia":  cells[2] if len(cells) > 2 else "",
            "nivel":       cells[3] if len(cells) > 3 else "",
            "volume_util": cells[4] if len(cells) > 4 else "",
        })
    return records


def _safe_first_cell_text(driver) -> str:
    """Lê o texto da primeira célula da tabela sem guardar referência ao elemento."""
    try:
        els = driver.find_elements(By.CSS_SELECTOR, "#tblDadosSIN tbody tr:first-child td:first-child")
        return els[0].text.strip() if els else ""
    except Exception:
        return ""


def _load_date_in_frame(driver, dt: date, timeout: int = 25) -> bool:
    date_str = dt.strftime("%d/%m/%Y")

    # Guarda só o texto (string pura), nunca o elemento WebElement
    old_cell = _safe_first_cell_text(driver) or "__NONE__"

    driver.execute_script(
        """
        var cal = document.getElementById('calendario');
        if (cal) {
            cal.value = arguments[0];
            cal.dispatchEvent(new Event('change', {bubbles: true}));
        }
        """,
        date_str,
    )

    def _table_updated(d):
        # Relança o find a cada poll — nunca reutiliza elemento antigo
        try:
            rows = d.find_elements(By.CSS_SELECTOR, "#tblDadosSIN tbody tr")
            if not rows:
                return False
            new_text = _safe_first_cell_text(d)
            return new_text != "" and new_text != old_cell
        except Exception:
            return False

    try:
        WebDriverWait(driver, timeout).until(_table_updated)
        return True
    except TimeoutException:
        # Aceita se a tabela tem linhas, mesmo sem mudança visível (data sem dados novos)
        return len(driver.find_elements(By.CSS_SELECTOR, "#tblDadosSIN tbody tr")) > 0


# ---------------------------------------------------------------------------
# Funcao principal
# ---------------------------------------------------------------------------

def scrape(
    inicio=None,
    fim=None,
    by: str = "dia",
    output=None,
    headless: bool = True,
) -> list:
    driver      = _make_driver(headless=headless)
    all_records = []
    fmt = "%d/%m/%Y"

    try:
        print("Carregando pagina da ANA/SAR...")
        driver.get(PAGE_URL)
        WebDriverWait(driver, 20).until(
            lambda d: d.execute_script("return document.readyState") == "complete"
        )
        time.sleep(2)

        print("Entrando no iframe de dados...")
        if not _switch_to_data_iframe(driver):
            print("ERRO: nao foi possivel acessar o iframe de dados.")
            return []

        print("Aguardando tabela carregar...")
        if not _wait_table_in_frame(driver):
            print("ERRO: tabela nao carregou dentro do iframe.")
            return []

        last_date_str = _get_current_date_in_frame(driver)
        if not last_date_str:
            last_date_str = date.today().strftime(fmt)
        print(f"Ultimo dia disponivel no site: {last_date_str}")

        last_avail = datetime.strptime(last_date_str, fmt).date()

        if inicio is None:
            inicio = last_avail
        if fim is None:
            fim = inicio

        # Garante limites historicos
        inicio = max(inicio, DATE_MIN)
        fim    = min(fim, last_avail)

        if inicio > fim:
            print(f"AVISO: inicio ({inicio.strftime(fmt)}) posterior ao fim ({fim.strftime(fmt)}). Nada a fazer.")
            return []

        dates = _dates_by(inicio, fim, by)
        total = len(dates)
        print(f"Coletando {total} data(s) [{by}]: {inicio.strftime(fmt)} -> {fim.strftime(fmt)}\n")

        for i, dt in enumerate(dates, 1):
            date_str = dt.strftime(fmt)

            if i == 1 and dt == last_avail:
                records = _parse_table(driver.page_source, date_str)
            else:
                print(f"[{i}/{total}] {date_str} carregando...")
                if not _load_date_in_frame(driver, dt):
                    print(f"  -> sem dados ou timeout, pulando.")
                    continue
                records = _parse_table(driver.page_source, date_str)

            if records:
                all_records.extend(records)
                print(f"  -> {len(records)} reservatorios.")
            else:
                print(f"  -> nenhum dado.")

            time.sleep(0.8)

    finally:
        driver.quit()

    if not output:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        output = f"reservatorios_parana_{ts}.csv"

    with open(output, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(all_records)

    print(f"\n=== Total: {len(all_records)} registros -> {output} ===")
    return all_records


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _parse_date_arg(s: str, is_fim: bool = False):
    """Aceita: min, max, DD/MM/AAAA, MM/AAAA, AAAA."""
    s = s.strip().lower()
    if s == "min":
        return "min"
    if s == "max":
        return "max"

    for fmt in ("%d/%m/%Y", "%Y-%m-%d", "%d-%m-%Y"):
        try:
            return datetime.strptime(s, fmt).date()
        except ValueError:
            pass

    # MM/AAAA
    try:
        d = datetime.strptime(s, "%m/%Y")
        if is_fim:
            last_day = calendar.monthrange(d.year, d.month)[1]
            return date(d.year, d.month, last_day)
        return date(d.year, d.month, 1)
    except ValueError:
        pass

    # AAAA
    try:
        d = datetime.strptime(s, "%Y")
        return date(d.year, 12, 31) if is_fim else date(d.year, 1, 1)
    except ValueError:
        pass

    raise argparse.ArgumentTypeError(
        f"Data invalida: '{s}'. Use DD/MM/AAAA, MM/AAAA, AAAA, 'min' ou 'max'."
    )


if __name__ == "__main__":
    TODAY = date.today()

    parser = argparse.ArgumentParser(
        description="Scraper de reservatorios ANA/SAR - Bacia do Parana.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--inicio", default=None, metavar="DATA",
        help="Data inicial. Aceita: DD/MM/AAAA, MM/AAAA, AAAA, 'min' (23/08/2010), 'max' (hoje).",
    )
    parser.add_argument(
        "--fim", default=None, metavar="DATA",
        help="Data final. Mesmos formatos. 'max' = hoje. Padrao: igual ao --inicio.",
    )
    parser.add_argument(
        "--by", choices=BY_OPTIONS, default="dia",
        help="Passo entre coletas: dia, semana ou mes. Padrao: dia.",
    )
    parser.add_argument(
        "--output", metavar="ARQUIVO",
        help="CSV de saida. Padrao: reservatorios_parana_<timestamp>.csv",
    )
    parser.add_argument(
        "--visible", action="store_true",
        help="Abre o Chrome visivel (debug).",
    )
    args = parser.parse_args()

    def resolve(val, is_fim):
        if val is None:
            return None
        parsed = _parse_date_arg(val, is_fim=is_fim)
        if parsed == "min":
            return DATE_MIN
        if parsed == "max":
            return TODAY
        return parsed

    inicio = resolve(args.inicio, is_fim=False)
    fim    = resolve(args.fim,    is_fim=True)

    if fim and not inicio:
        parser.error("--fim requer --inicio.")
    if inicio and fim and fim < inicio:
        parser.error("--fim nao pode ser anterior a --inicio.")

    scrape(
        inicio=inicio,
        fim=fim,
        by=args.by,
        output=args.output,
        headless=not args.visible,
    )
