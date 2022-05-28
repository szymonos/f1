"""
Display live timing
=====================
python -m live_timing
"""

import fastf1
from fastf1.livetiming.data import LiveTimingData

fastf1.Cache.enable_cache("cache_directory", force_renew=True)

livedata = LiveTimingData("saved_data.txt")
session = fastf1.get_session(2021, "testing", 1)
session.load(livedata=livedata)
