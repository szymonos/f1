"""
Display live timing
=====================
python -m live_timing
"""

import os

import fastf1
from fastf1.livetiming.data import LiveTimingData

YEAR = 2022
SESSION = "FP3"
CACHE_DIR = "dist"

# create working folders if not exist
if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)

fastf1.Cache.enable_cache(CACHE_DIR)
livedata = LiveTimingData("dist/saved_data.txt")

# get GP
schedule = fastf1.get_event_schedule(YEAR)
print(schedule.Location)
location = int(input("Select location: "))
gp = schedule.Location[location]

session = fastf1.get_session(YEAR, gp, SESSION)

session.load(livedata=livedata)
