# calls an AppleScript to update the weather widget
command: "osascript MyWidgets/script/updateWeather.scpt"

# Refresh every 30 seconds
refreshFrequency: 600000


render: (output) -> """ 
"""

update: (output) ->