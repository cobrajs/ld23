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
require 'sun'
require 'spacestation'
require 'bullet'
require 'city'

require 'logger'

function love.load()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()

  global = {}

  global.debug = false

  global.center = vector.Vector:new(WIDTH/2,HEIGHT/2)

  global.earf = {}
  global.earf.image = utils.loadImage('earf_top.png')
  global.earf.circle = shapes.Circle(global.center.x, global.center.y, global.earf.image:getWidth() / 2)
  global.earf.shake = 0

  global.keyhandle = keyhandler.KeyHandler()

  global.init = function(self, objects)
    -- Init all game vars, and call inits on objects

    --
    -- Difficulty setting
    --
    self.spinlevel = 5
    self.flareMaxTimer = 8
    self.flareMaxTimerDec = 5
    self.flareTimer = self.flareMaxTimer
    self.asteroidMaxTimer = 3
    self.asteroidMaxTimerDec = 5
    self.asteroidTimer = self.asteroidMaxTimer

    if objects then
      self.player:init()

      self.bullets:init()

      self.asteroids:init()

      self.sun:init()

      self.spacestation:init()

      self.cities:init()
    end
  end

  global:init()

  global.lose = function(self)
    screens:switchScreen('lose')
  end

  --
  -- Debug logger
  --

  global.logger = logger.Logger()

  global.font = love.graphics.newFont('gfx/SPACEMAN.TTF', 24)
  global.smallFont = love.graphics.newFont('gfx/SPACEMAN.TTF', 12)
  love.graphics.setFont(global.font)

  global.music = love.audio.newSource('sounds/purple.ogg')
  global.music:setLooping(true)
  global.music:play()

  --
  -- Objects
  --

  global.player = player.Player(global)

  global.bullets = bullet.BulletHandler()

  global.asteroids = asteroid.AsteroidHandler(global.center, function(self, dt)
    local ret = false
    --[[
    if shapes.Collides(global.player.bottomCircle, self.circle) then
      self:pushBack(global.player.bottomCircle) 
    end

    if shapes.Collides(global.player.topCircle, self.circle) then
      self:pushBack(global.player.topCircle) 
    end
    --]]

    if shapes.Collides(self.circle, global.earf.circle) and not self.grounded then
      self.rotate = false
      self.grounded = true
      self:pushBack(global.earf.circle)
      global.earf.shake = 3
      ret = true
      local tempCircle = shapes.Circle(self.circle.x, self.circle.y, self.circle.r * 2)
      for i,city in ipairs(global.cities.cities) do
        if shapes.Collides(city.circle, tempCircle) then
          table.remove(global.cities.cities, i)
        end
      end
    end

    if self.grounded then
      self.ang = utils.wrap(self.ang + dt * global.spinlevel, 360)
    end
    return ret
  end)

  global.sun = sun.Sun()

  global.spacestation = spacestation.SpaceStation()

  global.cities = city.CityHandler(global)

  global.gravity = {ang = 0, dst = 0.5} 

  global.backImage = utils.loadImage('title.png')

  global.started = false

  --
  -- Screens!
  --

  screens = screenhandler.ScreenHandler()
  screens.keyhandler = global.keyhandle
  screens.font = global.font
  screens:addScreen({
    name = 'game',
    rotate = 0,
    player = global.player,
    enter = function(self) 
      love.graphics.setBackgroundColor(10,10,10,255) 
      global.started = true
    end,
    draw = function(self)
      if global.earf.shake > 0 then
        love.graphics.translate(math.cartesian({ang=math.random(360), dst=global.earf.shake}))
        global.earf.shake = global.earf.shake - 0.5
      end

      love.graphics.draw(global.earf.image, global.center.x, global.center.y, math.rad(self.rotate), 1, 1, global.earf.circle.r, global.earf.circle.r)

      global.sun:draw()
      global.spacestation:draw()
      global.cities:draw()

      global.asteroids:draw()

      self.player:draw()

      global.bullets:draw()
    end,
    update = function(self, dt)
      global.logger:update('Rot', math.floor(self.rotate))

      self.rotate = utils.wrap(self.rotate + dt * global.spinlevel, 360)

      -- Player Update

      self.player:keyhandle(self.keyhandler)
      self.player:update(dt)

      -- Asteroids update

      if global.asteroids:update(dt) then
        global.earf.shake = 3
      end

      -- Timer events

      global.flareTimer = global.flareTimer - dt
      if global.flareTimer <= 0 then
        global.flareTimer = global.flareMaxTimer
        global.flareMaxTimer = global.flareMaxTimer - dt * global.flareMaxTimerDec
        global.sun:startFlare(global.bullets)
      end

      global.asteroidTimer = global.asteroidTimer - dt
      if global.asteroidTimer <= 0 then
        global.asteroidTimer = global.asteroidMaxTimer
        global.asteroidMaxTimer = global.asteroidMaxTimer - dt * global.asteroidMaxTimerDec
        global.cities:addCity(
          global.asteroids:addAsteroid()
        )
        local t = global.cities.cities[#global.cities.cities]
        local tempCircle = shapes.Circle(t.circle.x, t.circle.y, t.circle.r * 2)
        for _,asteroid in ipairs(global.asteroids.asteroids) do
          if shapes.Collides(asteroid.circle, t.circle) then
            table.remove(global.cities.cities)
            break
          end
        end
      end

      -- Handle some debug keypresses

      if self.keyhandler:handle('spawn') then
        global.cities:addCity(
          global.asteroids:addAsteroid()
        )
        local t = global.cities.cities[#global.cities.cities]
        for _,asteroid in ipairs(global.asteroids.asteroids) do
          if shapes.Collides(asteroid.circle, t.circle) then
            table.remove(global.cities.cities)
            break
          end
        end
      end

      if self.keyhandler:handle('uplevel') then
        --global.spinlevel = global.spinlevel + 1
        for _,v in ipairs(global.asteroids.asteroids) do
          v:damage(1)
        end
      end

      if self.keyhandler:handle('doflare') then
        global.sun:startFlare(global.bullets)
      end

      -- Update other objects
      global.sun:update(dt)
      global.spacestation:update(dt)
      global.cities:update(dt)

      -- Update bullets, run collisions
      global.bullets:update(dt)
      global.bullets:collide(global.earf)

      local damage = 
        ((global.bullets:collide(self.player.topCircle) or 0) +
        (global.bullets:collide(self.player.bottomCircle) or 0)) * 20
      if damage > 0 then self.player:damage(damage) end

      if global.bullets:collide(global.spacestation.circle) then
        global.spacestation:doHit()
      end

      for _,asteroid in ipairs(global.asteroids.asteroids) do
        global.bullets:collide(asteroid)
      end

      global.logger:update('Bullets', #global.bullets.bullets)
    end
  })

  screens:addScreen({
    name = 'pause',
    capture = true,
    enter = function(self) love.graphics.setBackgroundColor(0,0,0,255) end,
    draw = function(self)
      love.graphics.setFont(global.font)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print('PAUSED', 50, HEIGHT - 50)
    end,
    update = function(self)
      if self.keyhandler:check('jump') then
        screens:switchScreen('game')
      end
    end
  })

  screens:addScreen({
    name = 'lose',
    capture = true,
    delay = 2,
    enter = function(self) 
      self.delay = 2
      love.graphics.setBackgroundColor(0,0,0,255) 
    end,
    draw = function(self)
      love.graphics.setFont(global.font)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print('Game Over', 10, HEIGHT - global.font:getHeight() * 2.2)
      if self.delay <= 0 then
        love.graphics.print('Hit enter to continue', 10, HEIGHT - global.font:getHeight() * 1.1)
      end
    end,
    update = function(self, dt)
      self.delay = self.delay - dt
      if self.delay <= 0 then
        if self.keyhandler:handle('menuenter') then
          screens:switchScreen('menu')
          global:init()
        end
      end
    end
  })

  screens:addScreen({
    name = 'help',
    lines = {
      'Keys','Arrows to move','x to jump','c to punch','q for menu',
      '','Dodge the sun flares','','Dodge the asteroids','',
      'Save those in danger','','Jump to space station','to get more air','',
      'But only if you have','saved some cities first'
    },
    pos = 10,
    padding = 24,
    draw = function(self)
      love.graphics.setFont(global.font)
      for i,v in ipairs(self.lines) do
        local y = self.pos + (i-1) * self.padding
        if y > 0 then
          local offset = global.font:getWidth(v)
          love.graphics.print(v, global.center.x - offset / 2, self.pos + (i-1) * self.padding)
        end
      end
    end,
    update = function(self, dt)
    end
  })

  screens:addScreen({
    name = 'credits',
    lines = {
      'Earf Defender','','by','','Allen Schmidt','cobrajs',
      '','','Made in 48 hours','For Ludum Dare 23','','April 2012',
      '','','Written using','Love2D and Lua','My Custom libraries','',
      'Graphics done with','Aseprite','','Sounds done with','AS3sfxr',
      'Audacity','','Other tools','VIM','Github','','','To contact me',
      'cobrasoft@gmail.com','','','End of text.','','','Really, it is',
      '','','Are you still here?','','','Go play another game','','',
      'Fine, stay here.','','',"I'm just ignoring you now",'','',"I think I'll go for a walk",
      '','',"I'm walking away now",'','','...','','',"You can't be serious",
      '','','Hmm... ok.','','','Want to hear a secret?','','',
      'I really wanted to be a', 'different game.', '','Something more platformy',
      '','What?','',"No, this isn't platformy",'',"It's something else",'',
      'A non-platformer','','Cause I said so','','',"I'm just wasting time now",'',
      'I should stop adding to this','','Because I have more left','to add to the game.','',
      'But this is more fun','','','Ok, fine.','',"I'm ending this.",'','','','','The End'
    },
    pos = global.center.y,
    padding = 24,
    scrollSpeed = 40,
    enter = function(self) self.pos = global.center.y end,
    draw = function(self)
      love.graphics.setFont(global.font)
      for i,v in ipairs(self.lines) do
        local y = self.pos + (i-1) * self.padding
        if y > 0 then
          local offset = global.font:getWidth(v)
          love.graphics.print(v, global.center.x - offset / 2, self.pos + (i-1) * self.padding)
        end
      end
    end,
    update = function(self, dt)
      self.pos = self.pos - dt * self.scrollSpeed
    end
  })

  screens:addScreen({
    name = 'title',
    delay = 2,
    image = global.backImage,
    draw = function(self)
      love.graphics.draw(self.image, 0, 0)
    end,
    update = function(self, dt)
      self.delay = self.delay - dt
      if self.delay <= 0 then
        screens:switchScreen('menu')
      end
    end
  })

  global.menuhandler = menuhandler.MenuHandler({
    spacing = 24,
    pos = {x = 100, y = 220},
    font = global.font,
    backImage = global.backImage
  })
  global.menuhandler:addItem('Start', function(self) if global.started then global:init(true) end screens:switchScreen('game') end)
  global.menuhandler:addItem('Resume', function(self) if global.started then screens:switchScreen('game') end end)
  --global.menuhandler:addItem('Options')
  global.menuhandler:addItem('Help', function(self) screens:switchScreen('help') end)
  global.menuhandler:addItem('Credits', function(self) screens:switchScreen('credits') end)
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

  if global.debug then
    global.logger:draw()
  end
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
  if screens:onScreen('game') or screens:onScreen('pause') then
    if not f then
      screens:switchScreen('pause')
    else
      screens:switchScreen('game')
    end
  end
end

function love.quit()
  -- keyhandle:write()
end
