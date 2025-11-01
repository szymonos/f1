#!/usr/bin/env python3
"""
Get session information for every driver and save it in a csv file.

# :example
src/session.py -y 2024 -s R
src/session.py -y 2024 -s R -i True

# :save script example
Invoke-ExampleScriptSave src/session.py
# override the existing script example if exists
Invoke-ExampleScriptSave src/session.py -Force
# open the example script in VSCode
code -r (Invoke-ExampleScriptSave src/session.py -WriteOutput)
"""

# %% Load modules
import argparse
import os

import fastf1  # type: ignore

from scripts import df_info

# %% parse input arguments
parser = argparse.ArgumentParser()

parser.add_argument("-y", "--year", type=int, required=True, default=2024)
parser.add_argument(
    "-s",
    "--session",
    choices=["R", "Q", "FP1", "FP2", "FP3"],
    required=True,
    default="R",
)
parser.add_argument("-i", "--df_info", type=bool, choices=[True, False], default=False)
args, unknown = parser.parse_known_args()

print(args.df_info)

# print verbose messages
# if args.verbosity >= 2:
#     print(f"Running '{__file__}'", file=sys.stderr)

# %%~Specification
CACHE_DIR = "dist"

# create working folders if not exist
if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)
fastf1.Cache.enable_cache(CACHE_DIR)  # replace with your cache directory

schedule = fastf1.get_event_schedule(args.year)
print(schedule.Location)
location = int(input("Select location: "))
gp = schedule.Location[location]

# %%Load a session and its telemetry data
session = fastf1.get_session(args.year, gp, args.session)
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
print(f"Results saved to \033[4m{CACHE_DIR}/laps.csv\033[24m")

# %%
if args.df_info:
    print(df_info(laps))
