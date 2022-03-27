"""
Overlaying speed traces of two laps
===================================
Compare two fastest laps by overlaying their speed traces.
python -m plot_speed_traces
"""

# %% Load modules
import os

import fastf1
import fastf1.plotting
import matplotlib
import matplotlib.pyplot as plt

# parameters
matplotlib.rcParams["figure.dpi"] = 200
# FastF1's default color scheme
fastf1.plotting.setup_mpl()

# %%~Specification
YEAR = 2022
GP = "Jeddah"
DRIVER_1 = "PER"
DRIVER_2 = "LEC"
TEAM_1 = "RBR"
TEAM_2 = "FER"
# manually select lap for comparison
D1_PICK_LAP = False
D1_PICKED_LAP = 8
D2_PICK_LAP = False
D2_PICKED_LAP = 8
# working folders
CACHE_DIR = "dist"
IMAGE_DIR = "img"

# create working folders if not exist
if not os.path.exists(IMAGE_DIR):
    os.makedirs(IMAGE_DIR)
if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)
fastf1.Cache.enable_cache(CACHE_DIR)  # replace with your cache directory

# %% Load session details
# enable some matplotlib patches for plotting timedelta values and load
# load a session and its telemetry data
session = fastf1.get_session(YEAR, GP, "Q")
session.load()

# compare laps
if D1_PICK_LAP:
    laps_driver1 = session.laps.pick_driver(DRIVER_1)
    driver1_lap = laps_driver1[laps_driver1["LapNumber"] == D1_PICKED_LAP].iloc[0]
else:
    driver1_lap = session.laps.pick_driver(DRIVER_1).pick_fastest()

if D2_PICK_LAP:
    laps_driver2 = session.laps.pick_driver(DRIVER_2)
    driver2_lap = laps_driver2[laps_driver2["LapNumber"] == D2_PICKED_LAP].iloc[0]
else:
    driver2_lap = session.laps.pick_driver(DRIVER_2).pick_fastest()

##############################################################################
# Next we get the telemetry data for each lap. We also add a 'Distance' column
# to the telemetry dataframe as this makes it easier to compare the laps.
driver1_tel = driver1_lap.get_car_data().add_distance()
driver2_tel = driver2_lap.get_car_data().add_distance()

# %% Plot comparison
# Finally, we create a plot and plot both speed traces.
# We color the individual lines with the driver's team colors.
rbr_color = fastf1.plotting.team_color(TEAM_1)
mer_color = fastf1.plotting.team_color(TEAM_2)

fig, ax = plt.subplots()
ax.plot(driver1_tel["Distance"], driver1_tel["Speed"], color=rbr_color, label=DRIVER_1)
ax.plot(driver2_tel["Distance"], driver2_tel["Speed"], color=mer_color, label=DRIVER_2)

ax.set_xlabel("Distance in m")
ax.set_ylabel("Speed in km/h")

ax.legend()
plt.suptitle(
    f"Fastest Lap Comparison \n "
    f"{session.event['EventName']} {session.event.year} Qualifying"
)

plt.savefig(f"{IMAGE_DIR}/plot_speed_traces.svg")
plt.show()
