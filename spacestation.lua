module(..., package.seeall)

require 'orbiter'
require 'tileset'
require 'utils'
require 'shapes'

function SpaceStation()
  self = orbiter.Orbiter()

  self.offset = -100
  self.orbitColor:set(unpack(color.grey.rgba))

  self:updateOrbit()

  self.color:set(0,nil,0)

  self.speed = 0.1
  self.size = 5

  self.parentInit = self.init

  self.init = function(self)
    self:parentInit()

    self.rotate = 0

    self.hit = false
    self.hitDelay = 0
    self.hitFade = 0
  end

  self:init()

  self.circle = shapes.Circle(self.pos.x, self.pos.y, 25)

  self.image = tileset.Tileset('spacestation.png', 2, 2)
  self.imageOffset = {x = self.image.tilewidth / 2, y = self.image.tileheight / 2}

  self.doHit = function(self)
    self.hit = true
    self.hitDelay = 0.5
    self.hitFade = 98
  end

  self.updateCallback = function(self, dt)
    self.circle:updatePos(self.pos.x, self.pos.y)
    self.rotate = utils.wrapAng(self.rotate - 0.2)

    if self.hit then
      self.hitDelay = self.hitDelay - dt
      if self.hitDelay <= 0 then
        self.hit = false
        self.hitDelay = 0
      end
    end

    if self.hitFade % 2 == 0 then
      self.hitFade = self.hitFade - 2
      if self.hitFade <= 0 then self.hitFade = 0
      end
    end
  end

  self.drawCallback = function(self)
    self.image:draw(self.pos.x, self.pos.y, 1, math.rad(self.rotate), 1, 1, self.imageOffset.x, self.imageOffset.y)

    if self.hit or self.hitFade > 0 then
      self.circle:draw('line', {200, 200, 255, 50 * (self.hitFade / 100)})
    end
  end

  return self
end
