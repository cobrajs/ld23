module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'

    tileset = tileset.Tileset('spaceman.png', 8, 8)

function Player(opts)
  local self = {}

  self.floor = opts.earf.circle.r

  -- Polar position vars
  self.pos = {ang = 0, dst = self.floor}
  self.vel = {ang = 0, dst = 0}

  self.jump = 0
  self.canJump = true

  self.topCircle = shapes.Circle(0,0,4)
  self.drawCircle = shapes.Circle(0,0,4)
  self.bottomCircle = shapes.Circle(0,0,4)

  self.height = function(self) return self.pos.dst - self.floor end
  
  self.updateCircles = function(self)
    self.bottomCircle.x, self.bottomCircle.y = math.cartesian(self.pos, self.center)
    self.topCircle.x, self.topCircle.y = math.cartesian({dst = self.pos.dst + self.bottomCircle.r * 2, ang = self.pos.ang}, center)
    self.drawCircle.x, self.drawCircle.y = math.cartesian({dst = self.pos.dst + self.bottomCircle.r, ang = self.pos.ang}, center)
  end

  -- Animation vars
  --self.image = tileset.Tileset('gfx/player.png', 2, 2)
  self.image = tileset.XMLTileset('gfx/player_tiles.xml')
  self.width = self.image.tilewidth
  self.height = self.image.tileheight
  self.animPos = 1
  self.animState = 0
  self.animDelay = 0
  self.anim = self.image.anims.stand

  -- Key Handler
  self.keyhandle = {
    left = {ang = -2, dst = 0},
    right = {ang = 2, dst = 0}
  }

  self.update = function(self, dt)
    if self.vel.x ~= 0 then
      if love.timer.getTime() - self.animDelay > 1 / math.abs(self.vel.x) then
        self.animState = self.animState > 0 and 0 or self.animState + 1
        self.animDelay = love.timer.getTime()
      end
      self.animPos = self.vel.x > 0 and self.anim.right.start or self.anim.left.start
    end
    self.pos:add(self.vel)
  end

  self.collide = function(layer)

  end

  self.draw = function(self, x, y)
    self.image:draw(x or self.pos.x, y or self.pos.y, self.animPos + self.animState)
  end

  self.handleKeyPress = function(self, keys, key)
    local action = ''
    for k,v in pairs(keys) do
      if key == k then action = v end
    end
    if self.keyhandle[action] then
      self.vel:add(self.keyhandle[action])
    end
  end

  return self
end

