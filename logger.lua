module(..., package.seeall)

require 'utils'

function Logger()
  self = {}

  self.logs = {}

  self.logOrder = {}

  self.outputPos = {x = 10, y = 10}

  self.spacing = 10

  self.font = love.graphics.newFont(10)

  self.draw = function(self)
    love.graphics.setFont(self.font)
    for i, v in ipairs(self.logOrder) do
      love.graphics.print(v..': '..self.logs[v], self.outputPos.x, self.outputPos.y + (i-1) * self.spacing)
    end
  end

  self.add = function(self, name, value)
    self.logs[name] = value
    table.insert(self.logOrder, name)
  end

  self.update = function(self, name, value)
    if self.logs[name] then
      self.logs[name] = value
    else
      self:add(name, value)
    end
  end

  return self
end
