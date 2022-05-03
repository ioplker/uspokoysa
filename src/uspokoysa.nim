import nigui


var counter = 10


app.init()


var window = newWindow()
window.width = 800
window.height = 500
window.alwaysOnTop = true


var container = newLayoutContainer(Layout_Horizontal)
container.widthMode = WidthMode_Expand
container.heightMode = HeightMode_Expand
container.xAlign = XAlign_Center
container.yAlign = YAlign_Center
window.add(container)

var label = newLabel($counter)
label.setFontSize(50)
container.add(label)


proc decreaseTimer(event: TimerEvent) =
  if counter == 0:
    app.quit()
  else:
    counter -= 1
    label.text = $counter

var timer = startRepeatingTimer(1000, decreaseTimer)


window.show()
app.run()
