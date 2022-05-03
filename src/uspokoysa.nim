import nigui


#[ Types ]#
type
  Settings* = object
    shortBreakDuration*: int   # in seconds
    shortBreakInterval*: int   # in minutes
    longBreakDuration*: int    # in minutes
    longBreakInterval*: int    # in short breaks count
    notificationCmd*: string
    screenLockCmd*: string

  Status* = object
    settings*: Settings
    shortBreaksLeft*: int
    restCounter*: int    # how many seconds until current time break ends
    workCounter*: int    # how many seconds until next time break starts

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
var globalStatus: Status
var counter = 4
var faceLabel: Label
var timeLabel: Label
var face: Face
var timer: Timer


#[ Methods ]#
proc main()
proc initFaces()
proc initGui()

proc getDefaultSettings(): Settings
proc getUserSettings(): Settings

proc workTimeLoop(event: TimerEvent)
proc restTimeLoop(event: TimerEvent)

proc showTimeBreakNotification()
proc showTimeBreak()
proc hideTimeBreak()

proc postponeTimeBreak()
proc resetTimeBreaks()
proc lockScreen()
proc quitApp()


proc main() =
  initFaces()
  initGui()


proc initFaces() =
  var faces = [
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

  var window = newWindow()
  window.width = 800
  window.height = 500
  window.alwaysOnTop = true

  var container = newLayoutContainer(Layout_Vertical)
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

  window.show()
  app.run()


proc getDefaultSettings(): Settings =
  DefaultSettings


proc getUserSettings(): Settings =
  discard


proc workTimeLoop(event: TimerEvent) =
  if counter == 1:
    timer.stop()
    counter = 7
    timer = startRepeatingTimer(1000, restTimeLoop)
  else:
    counter -= 1


proc restTimeLoop(event: TimerEvent) =
  face = face.next
  faceLabel.text = face.text

  if counter == 1:
    timer.stop()
    counter = 4
    faceLabel.text = ""
    timeLabel.text = "..."
    timer = startRepeatingTimer(1000, workTimeLoop)
  else:
    counter -= 1
    timeLabel.text = $counter


proc showTimeBreakNotification() =
  discard


proc showTimeBreak() =
  discard


proc hideTimeBreak() =
  discard


proc postponeTimeBreak() =
  discard


proc resetTimeBreaks() =
  discard


proc lockScreen() =
  discard


proc quitApp() =
  app.quit()


#[ Execution ]#
main()
