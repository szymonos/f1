#!/usr/bin/env python3
"""
Script synopsis.

# :example
src/live_timing.py

# :save script example
Invoke-ExampleScriptSave src/live_timing.py
# override the existing script example if exists
Invoke-ExampleScriptSave src/live_timing.py -Force
# open the example script in VSCode
code -r (Invoke-ExampleScriptSave src/live_timing.py -WriteOutput)
"""

import os

import fastf1  # type: ignore
from fastf1.livetiming.data import LiveTimingData  # type: ignore

YEAR = 2025
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
