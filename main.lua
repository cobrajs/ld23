--
-- This is just a simple testing file to make sure these libraries work
-- Probably won't work if you don't have all the same images I have :P
--

require 'vector'
require 'utils'
require 'player'
require 'keyhandler'
require 'screenhandler'
require 'menuhandler'
require 'polar'
require 'asteroid'
require 'shapes'

require 'logger'

function love.load()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()

  global = {}

  global.center = vector.Vector:new(WIDTH/2,HEIGHT/2)

  global.earf = {}
  global.earf.image = utils.loadImage('earf_top.png')
  global.earf.circle = shapes.Circle(global.center.x, global.center.y, global.earf.image:getWidth() / 2)

  global.keyhandle = keyhandler.KeyHandler()

  global.spinlevel = 2

  global.player = player.Player(global)

  global.logger = logger.Logger()

  global.font = love.graphics.newFont('gfx/SPACEMAN.TTF', 24)
  love.graphics.setFont(global.font)

  global.asteroids = asteroid.AsteroidHandler(global.center, function(self, dt)
    if shapes.Collides(global.player.bottomCircle, self.circle) then
      self:pushBack(global.player.bottomCircle) 
    end

    if shapes.Collides(global.player.topCircle, self.circle) then
      self:pushBack(global.player.topCircle) 
    end

    if shapes.Collides(self.circle, global.earf.circle) then
      self.rotate = false
      self.grounded = true
      self:pushBack(global.earf.circle)
    else
      self.grounded = false
    end

    if self.grounded then
      self.ang = utils.wrap(self.ang + dt * global.spinlevel, 360)
    end
  end)

  global.gravity = {ang = 0, dst = 0.5} 

  screens = screenhandler.ScreenHandler()
  screens.keyhandler = global.keyhandle
  screens.font = global.font
  screens:addScreen({
    name = 'game',
    rotate = 0,
    player = global.player,
    shake = vector.Vector:new(0, 0),
    enter = function(self) love.graphics.setBackgroundColor(10,10,10,255) end,
    draw = function(self)
      -- love.graphics.translate(shake.x, shake.y)
      love.graphics.draw(global.earf.image, global.center.x, global.center.y, math.rad(self.rotate), 1, 1, global.earf.circle.r, global.earf.circle.r)

      global.asteroids:draw()

      self.player:draw()
      --p:draw(camera:drawPos(p.pos.x, p.pos.y))
    end,
    update = function(self, dt)
      global.logger:update('Rot', math.floor(self.rotate))

      self.rotate = utils.wrap(self.rotate + dt * global.spinlevel, 360)

      -- Player Update

      self.player:keyhandle(self.keyhandler)
      self.player:update(dt)

      -- Asteroids update

      global.asteroids:update(dt)

      doit = self.keyhandler:check('spawn')
      if doit and doit > 0.1 then
        global.asteroids:addAsteroid()
        self.keyhandler:reset('spawn')
      end

      if self.keyhandler:check('uplevel') then
        global.spinlevel = global.spinlevel + 1
      end
    end
  })

  screens:addScreen({
    name = 'pause',
    capture = true,
    enter = function(self) love.graphics.setBackgroundColor(0,0,0,255) end,
    draw = function(self)
      --love.graphics.setColor(50, 50, 50, 200)
      --love.graphics.rectangle('fill', 40, HEIGHT - 50, 200, 40)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print('PAUSED', 50, HEIGHT - 50)
    end,
    update = function(self)
      doit = self.keyhandler:check('jump')
      if doit then
        screens:switchScreen('game')
      end
    end
  })

  global.menuhandler = menuhandler.MenuHandler({
    spacing = 24,
    pos = {x = 200, y = 200},
    font = global.font
  })
  global.menuhandler:addItem('Start', function(self) screens:switchScreen('game') end)
  global.menuhandler:addItem('Quit', function(self) love.event.push('quit') end)
  screens:addScreen(global.menuhandler.screen)

  screens:switchScreen('menu')

end

function love.update(dt)
  screens.keyhandler:updateTimes(dt)
  screens:update(dt)
end

function love.draw()
  screens:draw()
  global.logger:draw()
end

function love.keypressed(key, uni)
  screens.keyhandler:update(key, true)

  if screens.keyhandler:check('quit') then
    if screens:onScreen('menu') then
      love.event.push('quit')
    else
      screens:switchScreen('menu')
    end
  end
end

function love.keyreleased(key, uni)
  screens.keyhandler:update(key, false)
end

function love.focus(f)
  if not f then
    screens:switchScreen('pause')
  else
    screens:switchScreen('game')
  end
end

function love.quit()
  -- keyhandle:write()
end
