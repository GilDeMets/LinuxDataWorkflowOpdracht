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
PLOT_DIR_TOTAL = os.path.join(PLOT_DIR, "total")
PLOT_DIR_TODAY = os.path.join(PLOT_DIR, "today")

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
def save_plot_total(filename):
    path = os.path.join(PLOT_DIR_TOTAL, filename)
    plt.savefig(path, dpi=150, bbox_inches="tight")
    plt.close()
    log(f"Saved plot: {filename}")

def save_plot_today(filename):
    path = os.path.join(PLOT_DIR_TODAY, filename)
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
save_plot_total("clouds_timeseries.png")

# Radiation
plt.figure(figsize=(12, 4))
plt.plot(df["timestamp"], df["radiation"])
plt.title("Solar Radiation (W/m²)")
plt.ylabel("radiation")
plt.xlabel("Time")
save_plot_total("radiation_timeseries.png")

# Solar Power
plt.figure(figsize=(12, 4))
plt.plot(df["timestamp"], df["solar"])
plt.title("Solar Power Output (W)")
plt.ylabel("power (W)")
plt.xlabel("Time")
save_plot_total("solar_timeseries.png")

# Price
plt.figure(figsize=(12, 4))
plt.plot(df["timestamp"], df["price"])
plt.title("Energy Price (€/MWh)")
plt.ylabel("€/MWh")
plt.xlabel("Time")
save_plot_total("price_timeseries.png")


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
save_plot_total("scatter_radiation_solar.png")

# Clouds → Solar
plt.figure(figsize=(6, 5))
plt.scatter(df["clouds"], df["solar"], alpha=0.5)
plt.xlabel("Cloud Cover (okta)")
plt.ylabel("Solar Output (W)")
plt.title("Clouds → Solar Output")
save_plot_total("scatter_clouds_solar.png")

# Price → Solar
plt.figure(figsize=(6, 5))
plt.scatter(df["price"], df["solar"], alpha=0.5)
plt.xlabel("Energy Price (€/MWh)")
plt.ylabel("Solar Output (W)")
plt.title("Price → Solar Output")
save_plot_total("scatter_price_solar.png")


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
save_plot_total("correlation_matrix.png")


log("Analysis complete.")

# --------------------------------------------------------------------
# Laatste dag plots
# --------------------------------------------------------------------
log("Generating last-day time series plots...")

# Maak directory voor today-plots
os.makedirs(PLOT_DIR_TODAY, exist_ok=True)

# Bepaal laatste dag met data
last_day = df["timestamp"].dt.date.max()
df_today = df[df["timestamp"].dt.date == last_day]

log(f"Last day detected: {last_day}")

# Clouds
plt.figure(figsize=(12, 4))
plt.plot(df_today["timestamp"], df_today["clouds"])
plt.title(f"Cloud Cover (okta) – {last_day}")
plt.ylabel("okta")
plt.xlabel("Time")
save_plot_today("clouds_today.png")

# Radiation
plt.figure(figsize=(12, 4))
plt.plot(df_today["timestamp"], df_today["radiation"])
plt.title(f"Solar Radiation (W/m²) – {last_day}")
plt.ylabel("radiation")
plt.xlabel("Time")
save_plot_today("radiation_today.png")

# Solar Power
plt.figure(figsize=(12, 4))
plt.plot(df_today["timestamp"], df_today["solar"])
plt.title(f"Solar Power Output (W) – {last_day}")
plt.ylabel("power (W)")
plt.xlabel("Time")
save_plot_today("solar_today.png")

# Price
plt.figure(figsize=(12, 4))
plt.plot(df_today["timestamp"], df_today["price"])
plt.title(f"Energy Price (€/MWh) – {last_day}")
plt.ylabel("€/MWh")
plt.xlabel("Time")
save_plot_today("price_today.png")

# --------------------------------------------------------------------
# Clouds–Radiation dual-axis plot
# --------------------------------------------------------------------
log("Generating clouds-radiation dual-axis plot...")

fig, ax1 = plt.subplots(figsize=(14, 5))

# Clouds (left axis)
color_clouds = "tab:blue"
ax1.plot(df_today["timestamp"], df_today["clouds"], color=color_clouds, label="Clouds (okta)")
ax1.set_ylabel("Clouds (okta)", color=color_clouds)
ax1.tick_params(axis="y", labelcolor=color_clouds)

# Radiation (right axis)
ax2 = ax1.twinx()
color_radiation = "tab:red"
ax2.plot(df_today["timestamp"], df_today["radiation"], color=color_radiation, label="Radiation (W/m²)")
ax2.set_ylabel("Radiation (W/m²)", color=color_radiation)
ax2.tick_params(axis="y", labelcolor=color_radiation)

plt.title(f"Clouds vs Radiation — {last_day}")
fig.tight_layout()

save_plot_today("dualaxis_clouds_radiation.png")

# --------------------------------------------------------------------
# Solar–Price dual-axis plot
# --------------------------------------------------------------------
log("Generating solar-price dual-axis plot...")

fig, ax1 = plt.subplots(figsize=(14, 5))

# Solar (left axis)
color_solar = "tab:green"
ax1.plot(df_today["timestamp"], df_today["solar"], color=color_solar, label="Solar (W)")
ax1.set_ylabel("Solar (W)", color=color_solar)
ax1.tick_params(axis="y", labelcolor=color_solar)

# Price (right axis)
ax2 = ax1.twinx()
color_price = "tab:orange"
ax2.plot(df_today["timestamp"], df_today["price"], color=color_price, label="Price (€/MWh)")
ax2.set_ylabel("Price (€/MWh)", color=color_price)
ax2.tick_params(axis="y", labelcolor=color_price)

plt.title(f"Solar Output vs Energy Price — {last_day}")
fig.tight_layout()

save_plot_today("dualaxis_solar_price.png")
