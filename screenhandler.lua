module(..., package.seeall)

--
-- A very simple Screen Handler for multiple screens
--

function ScreenHandler()
  self = {}

  self.screens = {}

  self.current = 1

  self.keyhandler = nil

  self.names = {}

  self.addScreen = function(self, newScreen)
    assert(type(newScreen) == 'table' and newScreen.draw and newScreen.update, 'Invalid screen')
    newScreen.keyhandler = self.keyhandler
    if newScreen.capture then
      newScreen.background = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    else
      newScreen.background = nil
    end
    table.insert(self.screens, newScreen)
    if newScreen.name then
      self.names[newScreen.name] = #self.screens
    end
  end

  self.switchScreen = function(self, screen) 
    if type(screen) == 'string' then
      screen = self.names[screen]
    end
    local current = self.screens[self.current]
    local next = self.screens[screen]
    if current and next then
      if current.exit then current:exit() end
      if next.capture then
        love.graphics.setCanvas(next.background)
        love.graphics.clear()
        current:draw()
        love.graphics.setCanvas()
      end
      self.current = screen
      if next.enter then next:enter() end
    end
  end

  self.onScreen = function(self, onscreen)
    if type(onscreen) == 'string' then
      onscreen = self.names[onscreen]
    end
    if self.current == onscreen then return true end
    return false
  end

  self.draw = function(self)
    if self.screens[self.current].background then
      love.graphics.draw(self.screens[self.current].background, 0, 0)
    end
    self.screens[self.current]:draw()
  end

  self.update = function(self, dt)
    self.screens[self.current]:update(dt)
  end

  return self
end

