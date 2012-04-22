module(..., package.seeall)

require 'polar'
require 'shapes'
require 'tileset'
require 'vector'
require 'utils'

function Asteroid(center)
  self = {}

  local atype = math.random(2)
  if atype == 1 then
    x = math.random(love.graphics.getWidth())
    y = (math.random(2) - 1) * love.graphics.getHeight()
  else
    x = (math.random(2) - 1) * love.graphics.getWidth()
    y = math.random(love.graphics.getHeight())
  end

  self.center = center or {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

  self.ang, self.dst = math.polar({x=x, y=y}, self.center)

  self.rot = 0
  self.rotate = true

  self.speed = 1

  self.damageLevel = 0

  self.image = (math.random(3)-1) * 8 + 1

  self.grounded = false

  --[[
  self.ps = love.graphics.newParticleSystem(utils.loadImage('dust.png'), 64)
  self.ps:setLifetime(-1)
  self.ps:setParticleLife(0.5)
  self.ps:setDirection(math.rad(self.ang))
  self.ps:setEmissionRate(16)
  self.ps:setSpread(math.rad(90))
  self.ps:setSpin(1)
  self.ps:setSpinVariation(0.5)
  self.ps:setSizeVariation(0.6)
  self.ps:setPosition(x, y)
  self.ps:setSpeed(1,3)
  self.ps:start()
  --]]

  self.circle = shapes.Circle(0, 0, love.graphics.getWidth() / 40)

  self.draw = function(self, images)
    --love.graphics.circle('fill', self.circle.x, self.circle.y, self.circle.r)
    --love.graphics.draw(self.ps)
    images:draw(self.circle.x, self.circle.y, self.image, math.rad(utils.wrap(self.rot + self.ang, 360)), 1, 1, self.circle.r, self.circle.r)
    self.circle:draw('line')
  end

  self.update = function(self, dt)
    if not self.grounded then
      self.dst = self.dst - self.speed
    end

    if self.rotate then self.rot = utils.wrap(self.rot + 1, 360) end

    self:updateCircle()

    --self.ps:setPosition(self.circle.x, self.circle.y)
    --self.ps:update(dt)
  end

  self.updateCircle = function(self)
    self.circle.x, self.circle.y = math.cartesian(self, self.center)
  end

  self:updateCircle()

  self.pushBack = function(self, circle)
    if not circle then
      self.dst = self.dst + self.speed
    else
      local vect = vector.Vector:new(circle.x - self.circle.x, circle.y - self.circle.y)
      local dist = vect:mag() - (self.circle.r + circle.r) + 1
      vect:norm()
      vect:abs()
      self.circle.x = self.circle.x + dist * vect.x * (circle.x > self.circle.x and 1 or -1)
      self.circle.y = self.circle.y + dist * vect.y * (circle.y > self.circle.y and 1 or -1)
      self.ang, self.dst = math.polar(self.circle, center)
    end
    self:updateCircle()
  end

  return self
end

function AsteroidHandler(center, updateCallback)
  self = {}

  self.asteroids = {}

  self.updateCallback = updateCallback or function(self, dt) end

  self.center = center or {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

  self.images = tileset.Tileset('asteroids.png', 8, 8)

  self.asteroidhit = love.audio.newSource('sounds/asteroidhit.ogg')

  self.init = function(self)
    for i=1,#self.asteroids do
      table.remove(self.asteroids)
    end
    self.asteroidhit:stop()
  end

  self.addAsteroid = function(self)
    table.insert(self.asteroids, Asteroid(self.center))
  end

  self.draw = function(self)
    for _,asteroid in ipairs(self.asteroids) do
      asteroid:draw(self.images)
    end
  end

  self.update = function(self, dt)
    local ret = false
    for _,asteroid in ipairs(self.asteroids) do
      asteroid:update(dt)

      if not asteroid.grounded then
        for _,a2 in ipairs(self.asteroids) do
          if a2 ~= asteroid and a2.grounded then
            if shapes.Collides(asteroid.circle, a2.circle) then
              asteroid.rotate = false
              asteroid.grounded = true
              ret = true
              if not self.asteroidhit:isStopped() then self.asteroidhit:stop() end
              self.asteroidhit:play()
              --asteroid:pushBack(a2.circle, asteroid.circle)
            end
          end
        end
      end

      if self.updateCallback(asteroid, dt) then
        if not self.asteroidhit:isStopped() then self.asteroidhit:stop() end
        self.asteroidhit:play()
      end

    end

    return ret
  end

  self.collide = function(self, object)
    local ret = nil
    for i,v in ipairs(self.asteroids) do
      if shapes.Collides(v.circle, object.circle or object) then
        ret = (ret or 0) + 1
      end
    end
    return ret
  end

  return self
end
