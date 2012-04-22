module(..., package.seeall)

require 'utils'
require 'vector'
require 'polar'
require 'color'
require 'shapes'

function Bullet(x, y, ang, dst, drawCallback, updateCallback)
  self = {}

  self.pos = vector.Vector:new(x, y)
  self.vel = vector.Vector:new(math.cartesian({ang = ang, dst = dst})) 

  self.circle = shapes.Circle(self.pos.x, self.pos.y, 2)

  self.type = 1

  self.drawCallback = drawCallback or nil
  self.updateCallback = updateCallback or nil

  self.draw = function(self)
    love.graphics.setColor(color.yellow.rgba)
    love.graphics.circle('fill', self.pos.x, self.pos.y, self.circle.r)
    love.graphics.setColor(color.white.rgba)
  end

  self.update = function(self, dt)
    self.pos:add(self.vel)

    self.circle.x, self.circle.y = self.pos.x, self.pos.y

    if self.pos.x < 0 or self.pos.x > love.graphics.getWidth() or self.pos.y < 0 or self.pos.y > love.graphics.getHeight() then
      return false
    end

    if self.updateCallback then
      self:updateCallback(dt)
    end
    return true
  end

  return self
end

function BulletHandler()
  self = {}

  self.bullets = {}

  self.shothit = love.audio.newSource('sounds/shothit.ogg', 'static')

  self.init = function(self)
    for i=1,#self.bullets do
      table.remove(self.bullets)
    end
    self.shothit:stop()
  end

  self.draw = function(self)
    for _,v in ipairs(self.bullets) do
      v:draw()
    end
  end

  self.update = function(self, dt)
    for i,v in ipairs(self.bullets) do
      if not v:update(dt) then table.remove(self.bullets, i) end
    end
  end

  self.collide = function(self, object)
    local ret = nil
    for i,v in ipairs(self.bullets) do
      if shapes.Collides(v.circle, object.circle or object) then
        table.remove(self.bullets, i)
        love.audio.play(self.shothit)
        ret = (ret or 0) + 1
      end
    end
    return ret
  end

  self.add = function(self, ...)
    table.insert(self.bullets, Bullet(...))
  end

  return self
end
