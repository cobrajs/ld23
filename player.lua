module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'

function Player(global)
  local self = {}

  self.global = global
  
  -- Jump state vars
  self.jump = 0
  self.fall = false
  self.canJump = true

  self.floor = global.earf.circle.r

  self.height = function(self) return self.pos.dst - self.floor end
  self.inAir = function(self) return self.jump > 0 or self.fall end

  -- Polar position vars
  self.pos = {ang = 0, dst = self.floor}
  self.vel = {ang = 0, dst = 0}
  
  -- Collision circles
  self.topCircle = shapes.Circle(0,0,love.graphics.getWidth()/80)
  self.drawCircle = shapes.Circle(0,0,love.graphics.getWidth()/80)
  self.bottomCircle = shapes.Circle(0,0,love.graphics.getWidth()/80)

  self.updateCircles = function(self)
    self.bottomCircle.x, self.bottomCircle.y = math.cartesian(self.pos, self.global.center)
    self.topCircle.x, self.topCircle.y = math.cartesian({dst = self.pos.dst + self.bottomCircle.r * 2, ang = self.pos.ang}, self.global.center)
    self.drawCircle.x, self.drawCircle.y = math.cartesian({dst = self.pos.dst + self.bottomCircle.r, ang = self.pos.ang}, self.global.center)
  end

  -- Animation vars
  self.image = tileset.XMLTileset('gfx/player_tiles.xml')
  self.animPos = 1
  self.animState = 0
  self.animDelay = 0
  self.anim = self.image.anims.stand
  self.dir = 'right'

  self.changeAnim = function(self, newAnim, newDir)
    if newAnim == self.anim and newDir == self.dir then return end
    self.anim = newAnim
    self.dir = newDir
    self.animPos = self.anim[self.dir].start
    self.animState = 0
  end

  -- Game state info
  -- Percentage based health
  self.health = 100
  self.collected = 0

  --
  -- Standard update and delete functions 
  --
  self.update = function(self, dt)
    -- Handle animation updating

    self:changeAnim( 
      self.jump > 0     and self.image.anims.jump or
      self.fall         and self.image.anims.fall or
      self.vel.ang ~= 0 and self.image.anims.walk or
                            self.image.anims.stand,
      self.vel.ang ~= 0 and (self.vel.ang > 0 and 'right' or 'left') or self.dir
    )

    if self.vel.ang ~= 0 then
      if love.timer.getTime() - self.animDelay > 0.1 then
        if self.anim[self.dir].fin - self.anim[self.dir].start > 0 then
          self.animState = self.animPos + self.animState >= self.anim[self.dir].fin and 0 or self.animState + 1
        end
        self.animDelay = love.timer.getTime()
      end
    end

    -- Jump handling
    if not self:inAir() then
      self.pos.ang = self.pos.ang + dt * self.global.spinlevel
    end

    if self.fall and self:height() <= 0 then
      self.vel.dst = 0
      self.pos.dst = self.floor
      self.fall = false
      self.jump = 0
      self.canJump = true
    end

    if self:height() > 0 then
      self.fall = true
      self.canJump = false
      for _,v in ipairs(global.asteroids.asteroids) do
        if shapes.Collides(v.circle, self.bottomCircle) then 
          self.canJump = true
          self.fall = false
        end
      end
      self.vel.dst = -0.5 * (self.fall and 1 or 0)
    end

    if self.jump > 0 then
      if self:height() < self.jump then
        self.vel.dst = 2
      else
        self.jump = 0
        if self:height() > self.jump then
          self.fall = true
        end
      end
    end

    -- Add velocity to position
    self.pos.ang = utils.wrap(self.pos.ang + self.vel.ang, 360)
    self.pos.dst = self.pos.dst + self.vel.dst

    self:updateCircles()
    self.global.logger:update('Health', self.health)
  end

  self.draw = function(self, x, y)
    self.image:draw(self.drawCircle.x, self.drawCircle.y, self.animPos + self.animState, math.rad(utils.wrap(self.pos.ang + 90, 360)), 1, 1, self.drawCircle.r * 2, self.drawCircle.r * 2)
  end

  --
  -- Handle key presses
  --
  self.keyhandle = function(self, keyhandle)
    if keyhandle:check('left') then
      self.vel.ang = self.vel.ang - (self:inAir() and 0.05 or 0.2)
    elseif keyhandle:check('right') then
      self.vel.ang = self.vel.ang + (self:inAir() and 0.05 or 0.2)
    else
      if self.vel.ang > 0.5 then
        self.vel.ang = self.vel.ang - (self:inAir() and 0.1 or 1)
      elseif self.vel.ang < -0.5 then
        self.vel.ang = self.vel.ang + (self:inAir() and 0.1 or 1)
      elseif self.vel.ang >= -0.5 and self.vel.ang <= 0.5 then
        self.vel.ang = 0
      end
    end

    self.vel.ang = utils.clamp(-2, self.vel.ang, 2)

    if keyhandle:check('jump') and self.canJump then
      self.jump = self.jump + self.drawCircle.r * 5
      self.canJump = false
    end
  end

  return self
end

