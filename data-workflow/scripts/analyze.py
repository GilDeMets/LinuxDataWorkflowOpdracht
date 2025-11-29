#! /usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np
from datetime import datetime
import sys, traceback

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED = os.path.join(BASE_DIR, "processed", "combined.csv")
PLOT_DIR = os.path.join(BASE_DIR, "analysis-output")

os.makedirs(PLOT_DIR, exist_ok=True)

LOG_FILE = os.path.join(BASE_DIR, "logs", "analysis.log")

sys.stdout = sys.stderr = open(LOG_FILE, "a")

def excepthook(t, v, tb):
	with open(LOG_FILE, "a") as f:
		f.write("".join(traceback.format_exception(t, v, tb)))

sys.excepthook = excepthook

def log(msg: str):
    """Write message to logs/analysis.log with timestamp."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp}] {msg}\n")

# --------------------------------------------------------------------
# Load & clean data
# --------------------------------------------------------------------
log("Loading dataset...")
df = pd.read_csv(PROCESSED)

df["timestamp"] = pd.to_datetime(df["timestamp"])

numeric_cols = ["clouds", "price", "radiation", "solar"]
for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")

df = df.sort_values("timestamp")


# --------------------------------------------------------------------
# Plot helper (saves + overwrites)
# --------------------------------------------------------------------
def save_plot(filename):
    path = os.path.join(PLOT_DIR, filename)
    plt.savefig(path, dpi=150, bbox_inches="tight")
    plt.close()
    log(f"Saved plot: {filename}")


# --------------------------------------------------------------------
# Time-series plots
# --------------------------------------------------------------------
log("Generating time series plots...")

# Clouds
plt.figure(figsize=(12, 4))
plt.plot(df["timestamp"], df["clouds"])
plt.title("Cloud Cover (okta)")
plt.ylabel("okta")
plt.xlabel("Time")
save_plot("clouds_timeseries.png")

# Radiation
plt.figure(figsize=(12, 4))
plt.plot(df["timestamp"], df["radiation"])
plt.title("Solar Radiation (W/m²)")
plt.ylabel("radiation")
plt.xlabel("Time")
save_plot("radiation_timeseries.png")

# Solar Power
plt.figure(figsize=(12, 4))
plt.plot(df["timestamp"], df["solar"])
plt.title("Solar Power Output (W)")
plt.ylabel("power (W)")
plt.xlabel("Time")
save_plot("solar_timeseries.png")

# Price
plt.figure(figsize=(12, 4))
plt.plot(df["timestamp"], df["price"])
plt.title("Energy Price (€/MWh)")
plt.ylabel("€/MWh")
plt.xlabel("Time")
save_plot("price_timeseries.png")


# --------------------------------------------------------------------
# Scatter relationships
# --------------------------------------------------------------------
log("Generating scatter plots...")

# Radiation → Solar
plt.figure(figsize=(6, 5))
plt.scatter(df["radiation"], df["solar"], alpha=0.5)
plt.xlabel("Radiation (W/m²)")
plt.ylabel("Solar Output (W)")
plt.title("Radiation → Solar Output")
save_plot("scatter_radiation_solar.png")

# Clouds → Solar
plt.figure(figsize=(6, 5))
plt.scatter(df["clouds"], df["solar"], alpha=0.5)
plt.xlabel("Cloud Cover (okta)")
plt.ylabel("Solar Output (W)")
plt.title("Clouds → Solar Output")
save_plot("scatter_clouds_solar.png")

# Price → Solar
plt.figure(figsize=(6, 5))
plt.scatter(df["price"], df["solar"], alpha=0.5)
plt.xlabel("Energy Price (€/MWh)")
plt.ylabel("Solar Output (W)")
plt.title("Price → Solar Output")
save_plot("scatter_price_solar.png")


# --------------------------------------------------------------------
# Correlation matrix
# --------------------------------------------------------------------
log("Generating correlation matrix plot...")

corr = df[numeric_cols].corr()

plt.figure(figsize=(6, 4))
plt.imshow(corr, cmap="coolwarm", vmin=-1, vmax=1)
plt.colorbar(label="Correlation")
plt.xticks(range(len(corr.columns)), corr.columns, rotation=45)
plt.yticks(range(len(corr.columns)), corr.columns)
plt.title("Correlation Matrix")
save_plot("correlation_matrix.png")


log("Analysis complete.")
