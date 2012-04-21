module(..., package.seeall)

--
-- A very simple Screen Handler for multiple screens
--

function ScreenHandler()
  self = {}

  self.screens = {}

  self.current = 1

  self.keyhandler = nil

  self.addScreen = function(self, newScreen)
    assert(type(newScreen) == 'table' and newScreen.draw and newScreen.update, 'Invalid screen')
    newScreen.keyhandler = self.keyhandler
    table.insert(self.screens, newScreen)
  end

  self.switchScreen = function(self, screenNum) 
    if screenNum > 0 and screenNum <= #self.screens and self.screens[screenNum] then
      if self.screens[self.current].exit then self.screens[self.current]:exit() end
      self.current = screenNum
      if self.screens[self.current].enter then self.screens[self.current]:enter() end
    end
  end

  self.draw = function(self)
    self.screens[self.current]:draw()
  end

  self.update = function(self, dt)
    self.screens[self.current]:update(dt)
  end

  return self
end

