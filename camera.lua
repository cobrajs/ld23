module(..., package.seeall)

require 'vector'

function Camera(maxWidth, maxHeight)
  self = vector.Vector:new(0,0)
  self.width = love.graphics.getWidth()
  self.height = love.graphics.getHeight()
  self.center = vector.Vector:new(self.width / 2, self.height / 2)
  self.minx = 0
  self.miny = 0
  self.maxx = maxWidth
  self.maxy = maxHeight

  self.update = function(self, x, y)
    self.x = x
    self.y = y

    if self.x > self.minx then self.x = self.minx end
    if self.y > self.miny then self.y = self.miny end

    if self.x < self.maxx then self.x = self.maxx end
    if self.y < self.maxy then self.y = self.maxy end
  end

  self.drawPos = function(self, x, y)
    return
      self.x >= self.minx and x or self.x <= self.maxx and self.maxx + x or self.center.x, 
      self.y >= self.miny and y or self.y <= self.maxy and self.maxy + y or self.center.y
  end

  return self
end
