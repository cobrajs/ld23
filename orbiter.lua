module(..., package.seeall)

require 'utils'
require 'vector'
require 'color'

function Orbiter()
  self = {}

  self.polPos = {ang = 0, dst = 0}
  self.pos = vector.Vector:new(0, 0)

  self.offset = -100

  self.center = vector.Vector:new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

  self.orbitPointSize = 2
  self.orbitColor = color.Color(unpack(color.white.rgba))
  self.orbit = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

  self.color = color.Color(unpack(color.white.rgba))
  self.size = 10
  self.speed = 0.4

  self.updateOrbit = function(self)
    love.graphics.setCanvas(self.orbit)
    love.graphics.setBackgroundColor(self.orbitColor.r, self.orbitColor.g, self.orbitColor.b, 0)
    love.graphics.clear()
    love.graphics.setBackgroundColor(0, 0, 0, 255)
    love.graphics.setColor(self.orbitColor.rgba)
    love.graphics.setPointSize(self.orbitPointSize)
    for i=0,360, (200 - self.offset)/100 do
      love.graphics.point(
        math.cos(math.rad(i)) * (self.center.x + self.offset) + self.center.x,
        math.sin(math.rad(i)) * (self.center.y + self.offset) + self.center.y 
      )
    end
    love.graphics.setCanvas()
    love.graphics.setColor(color.white.rgba)
  end

  self:updateOrbit()

  self.update = function(self, dt)
    self.polPos.ang = utils.wrapAng(self.polPos.ang + self.speed)
    self.pos.x = math.cos(math.rad(self.polPos.ang)) * (self.center.x + self.offset) + self.center.x 
    self.pos.y = math.sin(math.rad(self.polPos.ang)) * (self.center.y + self.offset) + self.center.y

    if self.updateCallback then
      self:updateCallback(dt)
    end
  end

  self.draw = function(self)
    love.graphics.setColor(color.white.rgba)
    love.graphics.draw(self.orbit, 0, 0)
    if self.drawCallback then
      self:drawCallback()
    else
      love.graphics.setColor(self.color.rgba)
      love.graphics.circle('fill', self.pos.x, self.pos.y, self.size)
    end
    love.graphics.setColor(color.white.rgba)
  end

  return self
end
