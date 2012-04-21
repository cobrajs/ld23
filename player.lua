module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'

function Player(startx, starty)
  local self = {}
  -- Position vars
  self.pos = vector.Vector:new(startx, starty)
  self.vel = vector.Vector:new(0, 0)

  -- Animation vars
  --self.image = tileset.Tileset('gfx/player.png', 2, 2)
  self.image = tileset.XMLTileset('gfx/player_tiles.xml')
  self.width = self.image.tilewidth
  self.height = self.image.tileheight
  self.rect = shapes.Rect(self.pos.x, self.pos.y, self.width, self.height)
  self.animPos = 1
  self.animState = 0
  self.animDelay = 0
  self.anim = self.image.anims.stand

  -- Key Handler
  self.keyhandle = {
    left = vector.Vector:new(-0.5,0),
    right = vector.Vector:new(0.5,0),
    up = vector.Vector:new(0,-0.5),
    down = vector.Vector:new(0,0.5)
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

