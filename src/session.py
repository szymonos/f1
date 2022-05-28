"""
Display event details
=====================
python -m src.session
"""
# %% Load modules
import os

import fastf1
from scripts import df_info

# %%~Specification
# working folders
YEAR = 2022
SESSION = "R"
CACHE_DIR = "dist"
DF_INFO = False

# create working folders if not exist
if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)
fastf1.Cache.enable_cache(CACHE_DIR)  # replace with your cache directory

schedule = fastf1.get_event_schedule(YEAR)
print(schedule.Location)
location = int(input("Select location: "))
gp = schedule.Location[location]

# %%Load a session and its telemetry data
session = fastf1.get_session(YEAR, gp, SESSION)
session.load()
laps = session.laps

# %% convert laptimes to seconds and save to csv
laps = laps.assign(
    lap_time=laps["LapTime"].dt.total_seconds(),
    sector1_time=laps["Sector1Time"].dt.total_seconds(),
    sector2_time=laps["Sector2Time"].dt.total_seconds(),
    sector3_time=laps["Sector3Time"].dt.total_seconds(),
)

laps.to_csv(f"{CACHE_DIR}/laps.csv")
print(f'Results saved to \033[4m{CACHE_DIR}/laps.csv\033[24m')

# %%
if DF_INFO:
    df_info(laps)

# %%
