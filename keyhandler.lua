module(..., package.seeall)

assert(type(love) ~= nil, 'Love2D is required for this package')

require 'xml'
require 'utils'

function KeyHandler()
  self = {}

  self.pressed = {}
  self.downtime = {}
  self.pressHandle = {}
  self.fromLast = {}

  self.keys = {}
  self.actions = {}

  self.load = function(self)
    local chunk = love.filesystem.load('keys.lua')
    local keys = chunk()
    for _,v in ipairs(keys) do
      self.keys[v.key] = v.action
      self.pressed[v.key] = false
      self.pressHandle[v.key] = false
      self.fromLast[v.key] = 0
      self.downtime[v.key] = 0
      if type(self.actions[v.action]) == 'table' then
        table.insert(self.actions[v.action], v.key)
      else
        self.actions[v.action] = {v.key}
      end
    end
  end

  self:load()

  self.update = function(self, key, state)
    if self.pressed[key] ~= nil then 
      self.pressed[key] = state 
      self.pressHandle[key] = state 
      self.downtime[key] = 0
    end
  end

  self.updateTimes = function(self, dt)
    for k,v in pairs(self.pressed) do
      if v then 
        self.downtime[k] = self.downtime[k] + dt
      end
    end
  end

  self.check = function(self, action)
    local key = self:pressedKey(action)
    if key then
      return self.downtime[key]
    end
    return nil
  end

  self.handle = function(self, action)
    local key = self:pressedKey(action)
    if key then
      if self.pressHandle[key] then
        self.pressHandle[key] = false
        return true
      end
    end
    return false
  end

  self.reset = function(self, action)
    local key = self:pressedKey(action)
    if key then
      self.downtime[key] = 0
    end
  end

  self.pressedKey = function(self, action)
    action = self.actions[action]
    if action then
      for _,v in ipairs(action) do
        if self.pressed[v] then
          return v
        end
      end
    end
    return nil
  end

  return self
end
