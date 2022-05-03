# See codestyle conventions at
# https://gist.github.com/ioplker/6bdf0de65514499b8dc9c81cfbbb941e
import std/[os, parseutils, osproc]
import strutils

import nigui


#[ Types ]#
type
  Settings* = object
    shortBreakDuration*: int     # in seconds
    shortBreakInterval*: float   # in minutes
    longBreakDuration*: float    # in minutes
    longBreakInterval*: int      # in short breaks count
    notificationCmd*: string
    screenLockCmd*: string

  Status* = object
    settings*: Settings
    shortBreaksLeft*: int
    restCounter*: int    # how many seconds until current time break ends, `-1` when break is already ended
    workCounter*: int    # how many seconds until next time break starts, `-1` when break is already started

  Face* = ref object
    text*: string
    next*: Face


#[ Constants ]#
const
  DefaultSettings* = Settings(
    shortBreakDuration: 20,
    shortBreakInterval: 15,
    longBreakDuration: 5,
    longBreakInterval: 3,
    notificationCmd: "",
    screenLockCmd: "",
  )


#[ Globals ]#
var status: Status
var window: Window
var faceLabel: Label
var timeLabel: Label
var face: Face
var timer: Timer


#[ Methods ]#
proc main()
proc initSettings()
proc initFaces()
proc initGui()

proc workTimeLoop(event: TimerEvent)
proc restTimeLoop(event: TimerEvent)

proc showTimeBreakNotification()
proc showTimeBreak()
proc hideTimeBreak()

proc quitApp()


proc main() =
  initSettings()
  initFaces()
  initGui()


proc initSettings() =
  var settings: Settings = DefaultSettings

  if fileExists(expandTilde("~" / ".uspokoysarc")):
    echo "Using config: " & expandTilde("~" / ".uspokoysarc")
    const configContents = readFile(expandTilde("~" / ".uspokoysarc"))

    var rawConfigLines = configContents.splitLines()
    var configLines: seq[string]

    # Filtering out comments and empty lines
    for configString in rawConfigLines:
      let handledPair = configString.split("#")[0]
      if handledPair.len > 0:
        configLines.add(handledPair)

    # Parsing strings with `key: value` pattern
    for configString in configLines:
      let pair = configString.split(":")
      let key = pair[0].strip()
      let value = pair[1].strip()

      case key:
        of "shortBreakDuration":
          var parsedValue: int

          if parseInt(value, parsedValue, 0) == 0 or parsedValue == 0:
            raise newException(IOError, "Error! Unexpected config parameter value in string: " & configString)
          else:
            settings.shortBreakDuration = parsedValue

        of "shortBreakInterval":
          let parsedValue = parseFloat(value)

          if parsedValue == 0:
            raise newException(IOError, "Error! Unexpected config parameter value in string: " & configString)
          else:
            settings.shortBreakInterval = parsedValue

        of "longBreakDuration":
          let parsedValue = parseFloat(value)

          if parsedValue == 0:
            raise newException(IOError, "Error! Unexpected config parameter value in string: " & configString)
          else:
            settings.longBreakDuration = parsedValue

        of "longBreakInterval":
          var parsedValue: int

          if parseInt(value, parsedValue, 0) == 0 or parsedValue == 0:
            raise newException(IOError, "Error! Unexpected config parameter value in string: " & configString)
          else:
            settings.longBreakInterval = parsedValue

        of "notificationCmd":
          if value.len == 0:
            raise newException(IOError, "Error! Unexpected config parameter value in string: " & configString)
          else:
            settings.notificationCmd = value

        of "screenLockCmd":
          if value.len == 0:
            raise newException(IOError, "Error! Unexpected config parameter value in string: " & configString)
          else:
            settings.screenLockCmd = value

        else:
          raise newException(IOError, "Error! Unexpected config parameter: " & key)

  status.settings = settings
  status.shortBreaksLeft = settings.longBreakInterval
  status.restCounter = -1
  status.workCounter = int(settings.shortBreakInterval * 60)    # converting minutes to seconds


proc initFaces() =
  let faces = [
    Face(text: "0_0"), Face(text: "-_-"),
    Face(text: "0_0"), Face(text: "-_-"),
    Face(text: "0_0"), Face(text: "^_^"),
    Face(text: "0_0"), Face(text: "v_v"),
    Face(text: "0_0"), Face(text: "<_<"),
    Face(text: "0_0"), Face(text: ">_>"),
    Face(text: "0_0"), Face(text: "=_="),
    Face(text: "=_="), Face(text: "=_="),
  ]

  for index, f in faces:
    if index < faces.len - 1:
      f.next = faces[index + 1]
    else:
      f.next = faces[0]

  face = faces[0]


proc initGui() =
  app.init()

  app.defaultBackgroundColor = rgb(20, 20, 20)
  app.defaultTextColor = rgb(250, 250, 250)

  window = newWindow()
  window.width = 800
  window.height = 500
  window.alwaysOnTop = true

  let container = newLayoutContainer(Layout_Vertical)
  container.widthMode = WidthMode_Expand
  container.heightMode = HeightMode_Expand
  container.xAlign = XAlign_Center
  container.yAlign = YAlign_Center
  container.spacing = 100
  window.add(container)

  faceLabel = newLabel()
  faceLabel.setFontSize(50)
  container.add(faceLabel)

  timeLabel = newLabel("...")
  timeLabel.setFontSize(50)
  container.add(timeLabel)

  timer = startRepeatingTimer(1000, workTimeLoop)

  app.run()


proc workTimeLoop(event: TimerEvent) =
  if status.workCounter == 6:
    showTimeBreakNotification()

  if status.workCounter == 1:
    timer.stop()

    status.workCounter = -1

    if status.shortBreaksLeft == 0:
      status.shortBreaksLeft = status.settings.longBreakInterval
      status.restCounter = int(status.settings.longBreakDuration * 60)
    else:
      status.shortBreaksLeft -= 1
      status.restCounter = status.settings.shortBreakDuration

    timer = startRepeatingTimer(1000, restTimeLoop)
  else:
    status.workCounter -= 1


proc restTimeLoop(event: TimerEvent) =
  showTimeBreak()
  face = face.next
  faceLabel.text = face.text

  if status.restCounter == 1:
    hideTimeBreak()
    timer.stop()

    status.restCounter = -1
    status.workCounter = int(status.settings.shortBreakInterval * 60)

    faceLabel.text = ""
    timeLabel.text = "..."

    timer = startRepeatingTimer(1000, workTimeLoop)
  else:
    status.restCounter -= 1
    timeLabel.text = $status.restCounter


proc showTimeBreakNotification() =
  if status.settings.notificationCmd.len > 0:
    discard execCmd(status.settings.notificationCmd)


proc showTimeBreak() =
  window.show()


proc hideTimeBreak() =
  window.hide()


proc quitApp() =
  app.quit()


#[ Execution ]#
main()
