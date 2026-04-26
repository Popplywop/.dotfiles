#!/usr/bin/env python3
# ~/.config/waybar/scripts/wttr.py
# Weather widget via Open-Meteo — Victoria, Texas
# No API key required. Uses WMO weather codes.

import json
import urllib.request
from datetime import datetime

LAT = 28.8026
LON = -96.9766

WMO_ICONS = {
    0: '', 1: '', 2: '', 3: '',
    45: '', 48: '',
    51: '', 53: '', 55: '',
    61: '', 63: '', 65: '',
    71: '', 73: '', 75: '',
    77: '',
    80: '', 81: '', 82: '',
    85: '', 86: '',
    95: '', 96: '', 99: '',
}

WMO_DESC = {
    0: "Clear sky", 1: "Mostly clear", 2: "Partly cloudy", 3: "Overcast",
    45: "Fog", 48: "Icy fog",
    51: "Light drizzle", 53: "Drizzle", 55: "Heavy drizzle",
    61: "Light rain", 63: "Rain", 65: "Heavy rain",
    71: "Light snow", 73: "Snow", 75: "Heavy snow",
    77: "Snow grains",
    80: "Light showers", 81: "Showers", 82: "Heavy showers",
    85: "Snow showers", 86: "Heavy snow showers",
    95: "Thunderstorm", 96: "Thunderstorm w/ hail", 99: "Heavy thunderstorm",
}

URL = (
    "https://api.open-meteo.com/v1/forecast"
    f"?latitude={LAT}&longitude={LON}"
    "&current=temperature_2m,apparent_temperature,weathercode,"
    "windspeed_10m,relativehumidity_2m"
    "&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,weathercode"
    "&temperature_unit=fahrenheit&windspeed_unit=mph"
    "&timezone=America%2FChicago&forecast_days=3"
)

try:
    with urllib.request.urlopen(URL, timeout=10) as resp:
        d = json.loads(resp.read().decode())

    cur = d["current"]
    code = cur["weathercode"]
    icon = WMO_ICONS.get(code, "?")
    temp = round(cur["temperature_2m"])
    feels = round(cur["apparent_temperature"])
    wind = round(cur["windspeed_10m"])
    humidity = cur["relativehumidity_2m"]
    desc = WMO_DESC.get(code, "Unknown")

    text = f"{icon} {temp}°F"

    tooltip = f"<b>{desc} \u2014 {temp}\u00b0F</b>\n"
    tooltip += f"Feels like: {feels}\u00b0F\n"
    tooltip += f"Wind: {wind} mph\n"
    tooltip += f"Humidity: {humidity}%\n"

    daily = d["daily"]
    for i in range(len(daily["time"])):
        label = "Today" if i == 0 else ("Tomorrow" if i == 1 else daily["time"][i])
        d_icon = WMO_ICONS.get(daily["weathercode"][i], "?")
        d_desc = WMO_DESC.get(daily["weathercode"][i], "")
        hi = round(daily["temperature_2m_max"][i])
        lo = round(daily["temperature_2m_min"][i])
        sunrise = daily["sunrise"][i][11:]
        sunset  = daily["sunset"][i][11:]
        tooltip += f"\n<b>{label}</b>  {d_icon} {d_desc}\n"
        tooltip += f"  {hi}\u00b0F /  {lo}\u00b0F   {sunrise}   {sunset}\n"

    print(json.dumps({"text": text, "tooltip": tooltip}))

except Exception as e:
    print(json.dumps({"text": " ?", "tooltip": str(e)}))
