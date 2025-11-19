#! /usr/bin/env python3
import os
from pathlib import Path
from datetime import datetime, timezone
from playwright.sync_api import sync_playwright
import time
import sys, traceback

LOG_DIR = Path("/home/hogent/linux-2526-Gil-De-Mets/data-workflow/logs/fetch")
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOG_FILE = LOG_DIR / "solar.log"

sys.stdout = sys.stderr = open(LOG_FILE, "a")

def excepthook(t, v, tb):
        with open(LOG_FILE, "a") as f:
                f.write("".join(traceback.format_exception(t, v, tb)))

sys.excepthook = excepthook

SMA_USER = "meidoornstraat4@gmail.com"
SMA_PASS = os.environ.get("SMA_PASS")
PLANT_ID = "14399320"

if not SMA_PASS:
	ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
	raise SystemExit(f"[{ts}] SMA_PASS niet gezet in environment")

DOWNLOAD_DIR = Path("/home/hogent/linux-2526-Gil-De-Mets/data-workflow/raw/solar")
DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)

def main():
	with sync_playwright() as p:
		browser = p.chromium.launch(headless=True)
		context = browser.new_context(accept_downloads=True)
		page = context.new_page()

		target_url = f"https://ennexos.sunnyportal.com/{PLANT_ID}/monitoring/view-energy-and-power"
		page.goto(target_url, wait_until="domcontentloaded")

		time.sleep(5)

		try:
   			if page.locator("[data-testid='input-login'] button").is_visible():
        			page.click("[data-testid='input-login'] button")
        			page.wait_for_load_state("networkidle")
		except:
    			pass
		
		#login
			
		if "login.sma.energy" in page.url or "login" in page.url:
			username_selector = "input#username[name='username']"
			password_selector = "input#password[name='password']"
			submit_selector = "button[type='submit'], button[name='login']"

			page.wait_for_selector(username_selector, timeout=60000)
			page.fill(username_selector, SMA_USER)
			page.fill(password_selector, SMA_PASS)
			page.click(submit_selector)

			page.wait_for_load_state("networkidle")

		time.sleep(5)
		
		#naar correcte pagina
		if target_url not in page.url:
			page.goto(target_url, wait_until="networkidle")

		#cookies weigeren
		ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
		
		try:
    			reject_btn = page.locator("a:has-text('Reject all')")
    			if reject_btn.count() > 0 and reject_btn.first.is_visible():
        			reject_btn.first.click()
        			page.wait_for_timeout(1000)
		except Exception as e:
    			print(f"[{ts}] Cookiebanner niet gevonden of klik mislukt: {e}")
		
		#expansion openklikken

		page.wait_for_selector("[data-testid='sma-accordion-detail-table']", timeout=60000)
		page.click("[data-testid='sma-accordion-detail-table']")
		page.wait_for_timeout(1000)

		#download
		
		page.wait_for_selector("[data-testid='table-export-button'] button", timeout=61000)

		page.click("[data-testid='table-export-button'] button")

		page.wait_for_selector("[data-testid='dialog-action-download']", timeout=62000)

		with page.expect_download() as download_info:
			page.click("[data-testid='dialog-action-download']")

		download = download_info.value

		ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
		out_path = DOWNLOAD_DIR / f"solardata-{ts}.csv"

		download.save_as(out_path)
		print(f"[{ts}]CSV opgeslagen als: {out_path}")

		browser.close()

if __name__ == "__main__":
	main()
