--
-- This is just a simple testing file to make sure these libraries work
-- Probably won't work if you don't have all the same images I have :P
--

require 'vector'
require 'camera'
require 'loader'
require 'utils'
require 'tileset'
require 'player'
require 'keyhandler'
require 'screenhandler'
require 'menuhandler'
require 'polar'
require 'asteroid'
require 'shapes'

function love.load()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
  center = vector.Vector:new(WIDTH/2,HEIGHT/2)

  earf = {}
  earf.image = utils.loadImage('earf_top.png')
  earf.circle = shapes.Circle(center.x, center.y, earf.image:getWidth() / 2)

  -- camera = camera.Camera(WIDTH - map.width, HEIGHT - map.height)

  -- p = player.Player(0, 0)

  -- love.keyboard.setKeyRepeat(0.1, 0.01)

  asteroids = {}
  table.insert(asteroids, asteroid.Asteroid(center))

  keyhandle = keyhandler.KeyHandler()

  level = 1

  player = {
    ang = 0, 
    floor = earf.circle.r + 4, 
    dst = earf.circle.r + 4, 
    jump = 0, 
    canJump = true,
    topCircle = shapes.Circle(0, 0, 4),
    drawCircle = shapes.Circle(0, 0, 4),
    bottomCircle = shapes.Circle(0, 0, 4),
    height = function(self) return self.dst - self.floor end,
    updateCircles = function(self, center)
      self.bottomCircle.x, self.bottomCircle.y = math.cartesian(self, center)
      self.topCircle.x, self.topCircle.y = math.cartesian({dst = self.dst + self.bottomCircle.r * 2, ang = self.ang}, center)
      self.drawCircle.x, self.drawCircle.y = math.cartesian({dst = self.dst + self.bottomCircle.r, ang = self.ang}, center)
    end,
    tileset = tileset.Tileset('spaceman.png', 8, 8)
  }

  asteroids = asteroid.AsteroidHandler(center, function(self, dt)
    --[[
    if shapes.Collides(player.circle, self.circle) then
      self:pushBack(player.circle) 
    end
    --]]

    if shapes.Collides(self.circle, earf.circle) then
      self.grounded = true
      self:pushBack(earf.circle)
    else
      self.grounded = false
      self.ang = utils.wrap(self.ang + dt * level, 360)
    end
  end)



  gravity = vector.Vector:new(0, 0.2) 
  screens = screenhandler.ScreenHandler()
  screens.keyhandler = keyhandle
  screens:addScreen({
    name = 'game',
    rotate = 0,
    player = player,
    -- camera = camera,
    draw = function(self)
      self.player.tileset:draw(self.player.drawCircle.x, self.player.drawCircle.y, 1, math.rad(utils.wrap(self.player.ang + 90, 360)), 1, 1, 8, 8)
      --love.graphics.circle('fill', self.player.topCircle.x, self.player.topCircle.y, self.player.topCircle.r)
      --love.graphics.circle('fill', self.player.bottomCircle.x, self.player.bottomCircle.y, self.player.bottomCircle.r)
      love.graphics.draw(earf.image, center.x, center.y, math.rad(self.rotate), 1, 1, earf.circle.r, earf.circle.r)
      love.graphics.print(self.rotate, 10, 10)

      asteroids:draw()

      -- p:draw(camera:drawPos(p.pos.x, p.pos.y))
    end,
    update = function(self, dt)
      self.rotate = utils.wrap(self.rotate + dt * level, 360)

      -- Player Update

      self.player:updateCircles(center)

      if self.player.jump == 0 then
        self.player.ang = utils.wrap(self.player.ang + dt * level, 360)
      end

      local doit = self.keyhandler:check('left')
      if doit then
        self.player.ang = utils.wrap(self.player.ang - 2, 360)
      end
      doit = self.keyhandler:check('right')
      if doit then
        self.player.ang = utils.wrap(self.player.ang + 2, 360)
      end
      doit = self.keyhandler:check('jump')
      if doit and self.player.jump == 0 and self.player.canJump then
        self.player.jump = self.player.jump + 20
        self.player.canJump = false
      end

      if self.player.jump > 0 then
        if self.player:height() < self.player.jump then
          self.player.dst = self.player.dst + 1
        else
          -- self.player.jump = 0
          if self.player:height() > self.player.jump then
            local fall = true
            for _,v in ipairs(asteroids.asteroids) do
              if shapes.Collides(v.circle, self.player.circle) then 
                self.player.canJump = true
                fall = false
              end
            end
            self.player.dst = self.player.dst - 0.5 * (fall and 1 or 0)
          end
        end
      end

      -- Asteroids update

      asteroids:update(dt)

      doit = self.keyhandler:check('spawn')
      if doit and doit > 0.5 then
        asteroids:addAsteroid()
        self.keyhandler:reset('spawn')
      end

      if self.keyhandler:check('uplevel') then
        level = level + 1
      end
      -- p:update(dt)
      -- p:collide(map:FindLayer('Collision'))

      --p.vel:add(gravity)
    end
  })

  screens:addScreen({
    name = 'pause',
    draw = function(self)
      love.graphics.print('PAUSED', center.x - 20, center.y - 5)
    end,
    update = function(self)
      doit = self.keyhandler:check('jump')
      if doit then
        screens:switchScreen(1)
      end
    end
  })
end

function love.update(dt)
  screens.keyhandler:updateTimes(dt)
  screens:update(dt)
end

function love.draw()
  screens:draw()
end

function love.keypressed(key, uni)
  screens.keyhandler:update(key, true)

  if screens.keyhandler:check('quit') then
    love.event.push('quit')
  end
end

function love.keyreleased(key, uni)
  screens.keyhandler:update(key, false)
end

function love.focus(f)
  if not f then
    screens:switchScreen(2)
  end
end

function love.quit()
  -- keyhandle:write()
end
