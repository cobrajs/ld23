module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'

function Player(global)
  local self = {}

  self.global = global
  
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

  self.changeAnim = function(self, newAnim, newDir)
    if newAnim == self.anim and newDir == self.dir then return end
    self.anim = newAnim
    self.dir = newDir
    self.animPos = self.anim[self.dir].start
    self.animState = 0
  end

  
  -- Put some vars in here to restart the game easier
  self.init = function(self)
    -- Jump state vars
    self.jump = 0
    self.fall = false
    self.canJump = true

    -- Polar position setting
    self.pos.ang = 0
    self.pos.dst = self.floor

    self.vel.ang = 0
    self.vel.dst = 0

    self:updateCircles()

    -- Anim vars
    self.animPos = 1
    self.animState = 0
    self.animDelay = 0
    self.anim = self.image.anims.stand
    self.dir = 'right'

    -- Game state info
    self.health = 100
    self.air = 100
    self.collected = 0

    self.punching = false
  end

  self:init()

  -- Sounds
  self.hitsound = love.audio.newSource('sounds/ow.ogg')
  self.jumpsound = love.audio.newSource('sounds/jetpack.ogg')
  self.walksound = love.audio.newSource('sounds/walk.ogg')

  self.damage = function(self, amount)
    self.health = self.health - amount
    love.audio.play(self.hitsound)
    if self.health <= 0 then
      global:lose()
    end
  end

  --
  -- Standard update and delete functions 
  --
  self.update = function(self, dt)
    -- Handle animation updating

    self:changeAnim( 
      self.jump > 0     and self.image.anims.jump or
      self.fall         and self.image.anims.fall or
      self.vel.ang ~= 0 and self.image.anims.walk or
      self.punching     and self.image.anims.punch or
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
          self.pos.dst = self.pos.dst - self.vel.dst
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
          love.audio.stop(self.jumpsound)
        end
      end
    end

    -- Add velocity to position
    self.pos.ang = utils.wrapAng(self.pos.ang + self.vel.ang)
    self.pos.dst = self.pos.dst + self.vel.dst

    for _,v in ipairs(global.asteroids.asteroids) do
      if shapes.Collides(v.circle, self.bottomCircle) then 
        self.pos.ang = utils.wrapAng(self.pos.ang - self.vel.ang * 2)
        self.vel.ang = 0
      end
      if shapes.Collides(v.circle, self.topCircle) and v.grounded == false then
        local ta = shapes.Dist(v.circle, self.topCircle)
        local tb = shapes.Dist(self.topCircle, self.bottomCircle)
        local ba = shapes.Dist(v.circle, self.bottomCircle)
        local a = ba - tb
        local ang = math.deg(math.asin(a/ta))
        local top = math.cos(math.rad(ang))
        if ang > 45 then
          self:damage(1000)
        else
          self.pos.ang = self.pos.ang + top * (v.ang > self.pos.ang and -1 or 1)
        end
      end
    end

    self:updateCircles()
    self.global.logger:update('Health', self.health)
  end

  self.draw = function(self, x, y)
    self.image:draw(self.drawCircle.x, self.drawCircle.y, self.animPos + self.animState, math.rad(utils.wrap(self.pos.ang + 90, 360)), 1, 1, self.drawCircle.r * 2, self.drawCircle.r * 2)
    self.topCircle:draw('line')
    self.bottomCircle:draw('line')
  end

  --
  -- Handle key presses
  --
  self.keyhandle = function(self, keyhandle)
    self.punching = keyhandle:check('punch') and true or false

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

    if math.abs(self.vel.ang) > 0 and not self:inAir() then
      love.audio.play(self.walksound)
    else
      love.audio.stop(self.walksound)
    end

    if keyhandle:check('jump') and self.canJump then
      self.jump = self.jump + self.drawCircle.r * 5
      self.canJump = false
      love.audio.play(self.jumpsound)
    end
  end

  return self
end

