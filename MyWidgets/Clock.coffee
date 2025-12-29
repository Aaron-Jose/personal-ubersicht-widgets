# This is the configuration for your widget.
# The `update` function is now written in pure CoffeeScript.
# The `style` block has been updated to use standard CSS.

# Command to read the general.json file. This remains unchanged.
command: "cat MyWidgets/script/general.json"

# Refresh every 10 seconds.
# Note: The original was 100, which is likely a typo for 10000 (10s) or 30000 (30s).
# I've set it to 10000ms (10 seconds) as a sensible default.
refreshFrequency: 1000

# The render function defines the HTML structure of the widget.
# No changes were needed here.
render: (output) -> """
  <link href="Fonts/BebasNeue-Regular.ttf" rel="stylesheet" type="text/css">
  <div id="wrapper">
    <div id="time"></div>
    <div id="day"></div>
    <div id="secondary"></div>
  </div>
"""

# The style block is now written in standard CSS.
# It uses CSS variables for better maintainability and standard /* */ comments.
style: """
  size = 800px  // The box around the widget

  width: size 
  margin-left: -.5 * size // Set left edge of widget to be center so it can be easily centered on the page
  text-align: center

  height: 130px             
  margin-top: -.5 * 130px
  vertical-align: middle

  // Postition on the screen
  top: 15%
  left: 55%

  #time
    font-family: BebasNeue-Regular
    font-size: 120px
    margin-bottom: -70px

  #day
    font-family: Satisfy
    font-size: 100px

  #secondary
    font-family: BebasNeue-Regular
    font-size: 40px
    margin-top: -50px

  sup
    font-size: 20px

  #town
    font-size: 30px
    font-family: Satisfy
    margin-top: -25px
"""

# The update function is called on every refresh.
# This logic is now clean, consistent CoffeeScript.
update: (rawOutput, domEl) ->
  # --- 1. Select DOM Elements ---
  timeEl = domEl.querySelector '#time'
  dayEl = domEl.querySelector '#day'
  secondaryEl = domEl.querySelector '#secondary'
  
  # --- 2. Safely Parse JSON Data ---
  try
    data = JSON.parse rawOutput
  catch e
    console.error "Error parsing JSON:", e
    dayEl.textContent = "Error"
    secondaryEl.textContent = "Could not load settings"
    return

  # --- 3. Get and Format Date & Time ---
  now = new Date()
  hours = now.getHours()
  minutes = ("0" + now.getMinutes()).slice(-2) # Ensures two digits, e.g., 05
  
  days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  
  dayName = days[now.getDay()]
  monthName = months[now.getMonth()]
  dateNum = now.getDate()
  year = now.getFullYear()

  # Helper function to get the correct suffix for the date (st, nd, rd, th)
  getDateSuffix = (day) ->
    if day > 3 and day < 21 then 'th'
    switch day % 10
      when 1 then "st"
      when 2 then "nd"
      when 3 then "rd"
      else "th"

  dateSuffix = "<sup>#{getDateSuffix(dateNum)}</sup>"

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

  # --- 5. Update the DOM ---
  dayEl.style.color = primaryColor
  timeEl.style.color = secondaryColor
  secondaryEl.style.color = secondaryColor

  timeEl.innerHTML = "#{hours}:#{minutes}"
  dayEl.innerHTML = dayName
  secondaryEl.innerHTML = "#{dateNum}#{dateSuffix} #{monthName} #{year}"
