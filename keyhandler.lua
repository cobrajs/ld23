module(..., package.seeall)

assert(type(love) ~= nil, 'Love2D is required for this package')

require 'xml'
require 'utils'
require 'loader'

function KeyHandler()
  self = {}

  self.pressed = {}
  self.downtime = {}

  self.keys = {}
  self.actions = {}

  self.load = function(self)
    dofile 'keys.lua'
    for _,v in ipairs(keys) do
      self.keys[v.key] = v.action
      self.pressed[v.key] = false
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
