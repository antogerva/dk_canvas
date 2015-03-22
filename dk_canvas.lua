package.cpath = ";?51.dll;..package.cpath"

require "cdlua"
require "iuplua"
require "iupluacd"

pos_x=0
pos_y=0
function get_mem()
    --X and Y postion in Donkey Kong(JU) for gameboy
    pos_x = memory.readbyte(0x1)
    pos_y = memory.readbyte(0x0)
    gui.text(10,10,string.format("Xpos: %d",pos_x))
    gui.text(10,20,string.format("Ypos: %d",pos_y))
end
event.onframeend(get_mem)

-- Initialize some IUP component for the UI
label_counter = iup.label{title="1", size="20x20"}
label_x = iup.label{title="0", size="20x20"}
label_y = iup.label{title="0", size="20x20"}
btn_exit = iup.button{ title = "Exit" }
btn_print = iup.button{ title = "Print" }

function close_cb()
  print("halting the timer")
  timer1.run = "NO"
  self:destroy()
  return iup.IGNORE -- because we destroy the dialog
end

timer1 = iup.timer{time=40}
isInit = false
function timer1:action_cb()
  if(isInit==false) then
    isInit=true
    --print("init timer")
    return iup.CLOSE
  end
  print("")
  --print("timer1 called")

  isInit=false;
  if (iup.MainLoopLevel()==0) then
    iup.MainLoop()
  end
  return iup.DEFAULT
end
-- can only be set after the time is created
timer1.run = "YES"

-- callback called when the exit button is activated
function btn_exit:action()
    dlg:hide()
    print("halting the timer")
    timer1.run = "NO"
    self:destroy()
    return iup.IGNORE -- because we destroy the dialog
end

function btn_print:action()
    print("Button press.")
    return iup.DEFAULT
end

canvas = iup.canvas{rastersize="300x300",border="no"}
function canvas:map_cb()
    self.canvas = cd.CreateCanvas(cd.IUP, self)
end

myCanvas = null;
function canvas:action()
    myCanvas=self;
    self.canvas:Activate()
    self.canvas:Clear()
    if self.Draw then
        self:Draw(self.canvas)
    end
end

function canvas:Draw()
    canvas = self.canvas
    canvas:Rect(25,275,25,275)
    canvas:Rect(35+pos_x,40+pos_x,35+pos_y,40+pos_y)
end



dlg = iup.dialog{ iup.vbox{ iup.hbox{canvas, iup.vbox{ label_counter, label_x, label_y}, iup.vbox{btn_print, btn_exit}}};  title = "My Canvas"}
--dlg:showxy(iup.CENTER, iup.CENTER)
dlg:show()


function idle_cb()
  label_counter.title = tonumber(label_counter.title) + 1;
  label_x.title = "x: "..pos_x;
  label_y.title = "y: "..pos_y;

  myCanvas.canvas:Clear()
  myCanvas:Draw(myCanvas.canvas)

  return iup.DEFAULT
end

-- Registers idle callback
iup.SetIdle(idle_cb)

if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end
