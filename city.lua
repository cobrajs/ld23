module(..., package.seeall)

require 'utils'
require 'shapes'

function City(asteroid, offset)
  self = {}

  self.image = utils.loadImage('city.png')

  print(asteroid.dst, offset, (asteroid.dst / asteroid.speed * offset))
  self.pos = {ang = asteroid.ang + (asteroid.dst / asteroid.speed * offset) , dst = 0}

  self.circle = shapes.Circle(0, 0, 16)

  self.asteroid = asteroid

  self.updateCircle = function(self)
    self.circle.x, self.circle.y = math.cartesian(self.pos, self.asteroid.center)
  end

  self:updateCircle()

  self.update = function(self, dt)
    self:updateCircle()
  end

  self.draw = function(self)
    love.graphics.draw(self.image, self.circle.x, self.circle.y, math.rad(utils.wrapAng(self.pos.ang + 90)), 1, 1, self.circle.r, self.circle.r)
  end

  return self
end

function CityHandler(global)
  self = {}

  self.cities = {}

  self.global = global
  self.offsetCollect = 0

  self.init = function(self)
    for i=1,#self.cities do table.remove(self.cities) end
  end

  self.addCity = function(self, asteroid)
    local a = City(asteroid, self.global.spinlevel * self.offsetCollect)
    a.pos.dst = global.earf.circle.r + a.circle.r - 6
    table.insert(self.cities, a)
  end

  self.update = function(self, dt)
    for _,city in ipairs(self.cities) do
      city.pos.ang = city.pos.ang + dt * self.global.spinlevel
      city:update(dt)
    end
    self.offsetCollect = dt
  end

  self.draw = function(self)
    for _,city in ipairs(self.cities) do
      city:draw()
    end
  end

  return self
end
