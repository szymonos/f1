"""
Display event details
=====================
python -m session
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

# create working folders if not exist
if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)
fastf1.Cache.enable_cache(CACHE_DIR)  # replace with your cache directory

schedule = fastf1.get_event_schedule(YEAR)
print(schedule.Location)
location = int(input("Select location"))
gp = schedule.Location[location]

# %%Load a session and its telemetry data
session = fastf1.get_session(YEAR, gp, SESSION)
session.load()

# %%
for driver_no in session.drivers:
    session.get_driver(driver_no)[["DriverNumber", "Abbreviation"]]

session.drivers
per = session.get_driver("11")
per[["DriverNumber", "Abbreviation"]]
session.get_driver("11")[["DriverNumber", "Abbreviation"]]

print(session.drivers)
print(session.get_driver("11"))
print(session.laps.pick_driver("VER").pick_fastest())

laps = session.laps.pick_driver("VER")
laps.to_csv(f"{CACHE_DIR}/laps.csv")
# %%
df_info(laps)

# %%
session.drivers
session.drivers
dir(session.drivers)
# %%
driver = session.get_driver("1")
driver["Abbreviation"]
dir(driver)

# %%
for driver_no in session.drivers:
    print(session.get_driver(driver_no)[["DriverNumber", "Abbreviation"]])
# %%
session.get_driver("11").name
dir(session.get_driver("11"))
