command: "osascript MyWidgets/script/updateSong.scpt"

# Refresh every second
refreshFrequency: 1000

# Stylesheet
style: """
  // Position the container at the top of the screen
  top: 0%;
  left: 0;
  width: 100%;
  box-sizing: border-box; // Ensures padding doesn't add to the width

  // This is the main container that holds the left and right groups
  #top-bar-container {
    padding: 0px 8px; // Padding on the far edges of the screen
    display: flex;
    align-items: center;
    // Use a gap to create the central space for the notch
    gap: 30px; 
  }
  
  // Container for items on the same side of the notch
  .side-group {
    display: flex;
    align-items: center;
    flex: 1; // Allows each group to grow and fill half the available space
    justify-content: space-between; // Pushes elements inside to their edges
  }

  // Container for the song info specifically
  #musicBar {
    display: inline-flex;
    gap: 12px; // Space between song title, artist, and album
  }
"""

# HTML for widget
render: (output) -> """
  <div id="top-bar-container">
    <!-- Left side of the notch -->
    <div class="side-group">
      <div id="musicBar">
        <div id="trackTitle" class="widget-text songinfo-item"></div>
        <div id="artist" class="widget-text songinfo-item"></div>
        <div id="albumName" class="widget-text songinfo-item"></div>
      </div>

      <div id="temp" class="widget-text" style="padding-right:13% !important"></div>
    </div>

    <!-- Right side of the notch -->
    <div class="side-group">
      <div id="weather" class="widget-text" style="padding-left:13% !important"></div>
      <div id="time-display" class="widget-text"></div>
    </div>
  </div>
"""

# Get variables and update the DOM
update: (output) ->
    date = new Date()
    hours = parseInt(date.getHours())

    # Safely parse JSON
    try
        data = JSON.parse(output)
    catch e
        console.error "Error parsing JSON output:", e
        return # Exit if data is invalid

    # Change colors based on the time of day
    isDarkMode = hours < 5 or hours >= 17
    theme = data.settings.theme

    # Light Mode
    primaryColor = data.settings.lightMode.primaryColour
    secondaryColor = data.settings.lightMode.secondaryColour

    if theme == "1" # Dynamic Mode
      if isDarkMode == true
        primaryColor = data.settings.lightMode.primaryColour
        secondaryColor = data.settings.lightMode.secondaryColour 
      else
        primaryColor = data.settings.darkMode.primaryColour
        secondaryColor = data.settings.darkMode.secondaryColour
        
    if theme == "0" # Dark Mode
      primaryColor = data.settings.darkMode.primaryColour
      secondaryColor = data.settings.darkMode.secondaryColour

    # Apply styles using a shared class for simplicity
    $('.widget-text').css('color', secondaryColor)
    $('#top-bar-container').css('fontFamily', data.settings.fontSettings.fontFamily)
    $('#top-bar-container').css('fontSize', data.settings.fontSettings.fontSize)

    # --- SONG INFO LOGIC ---
    trackTitle = "well this is awkward isn't it"
    artist = ""
    albumName = ""

    if data.song and data.song.track != "null"
        trackTitle = data.song.track.replace(/ *\([^)]*\) */g, "")
        artist = data.song.artist.replace(/ *\([^)]*\) */g, "")
        albumName = data.song.album.replace(/ *\([^)]*\) */g, "")

        # Truncate text if it's too long
        if (trackTitle.length + artist.length + albumName.length) > 70
            albumName = ""
            if (trackTitle.length + artist.length) > 70
                trackTitle = trackTitle.substring(0, 35) + '…'
                if (trackTitle.length + artist.length) > 70
                  artist = artist.substring(0, 25) + '…'

    # --- DATE AND TIME LOGIC ---
    minutes = date.getMinutes()
    minutes = if minutes < 10 then "0" + minutes else minutes
    timeString = date.getHours() + ":" + minutes

    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    
    day = days[date.getDay()]
    month = months[date.getMonth()]
    numDate = date.getDate()
    year = date.getFullYear()
    
    suffix = switch
        when numDate in [1, 21, 31] then 'st'
        when numDate in [2, 22] then 'nd'
        when numDate in [3, 23] then 'rd'
        else 'th'
    
    # --- Final Time String ---
    timeString = hours + ":" + minutes + "&#8199" + day + " " + numDate + "<sup>" + suffix + "</sup>" + "&#8192" + month + " " + year + "&#8199" + " " + data.batteryPercentage + "%"

    
    weatherCondiiton = data.weather.weather[0].main
  
    # Mapping weather conditions to emojis
    weather = {
        'Clear': "\'tis a clear day",
        'Clouds': 'cloudy with no chance of meatballs',
        'Rain': 'better get an umbrella, ella, ella, eh, eh, eh',
        'Drizzle': 'baby rain ig i dont know',
        'Thunderstorm': 'like that one ac/dc song',
        'Snow': 'snow is falling, all around u',
        'Mist': 'ah, is someone running a shower?',
        'Fog': 'wuh oh, cant see no more'
    }

    weatherEmojis = {
        'Clear': '☀️',
        'Clouds': '☁️',
        'Rain': '☂️',
        'Drizzle': '🌦️',
        'Thunderstorm': '🌩️',
        'Snow': '🌨️',
        'Mist': '💨',
        'Fog': '🌫️'
    }
    
    emoji = weatherEmojis[weatherCondiiton] || ''

    weather = weather[weatherCondiiton] || ''

    weatherString = emoji + "&#8192" + weather



    # --- UPDATE WIDGET HTML ---
    # We use .html() to render the <sup> tag correctly
    $('#time-display').html timeString

    # $('#temp').text data.weather.main.temp + "°C"

    # $('#emoji').html emoji
    # $('#weather').html weatherString


    # We use .text() for song info to prevent any potential HTML injection
    $('#trackTitle').text trackTitle.replace( /§/g, ",")
    $('#artist').text artist.replace( /§/g, ",")
    $('#albumName').text albumName.replace( /§/g, ",")

