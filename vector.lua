module(..., package.seeall)

--
-- A basic Vector library
-- Only supports 2 dimensions, x and y
-- Supports in place (vector:add(b)) and return based (vect1 + vect2) operations
--

local function do_func(typ, a, b)
  local ret = Vector:new(a.x, a.y)
  ret[typ](ret,b)
  return ret
end

Vector = {
  __add = function(a,b) return do_func('add', a, b) end,
  __sub = function(a,b) return do_func('sub', a, b) end,
  __mul = function(a,b) return do_func('mul', a, b) end,
  __div = function(a,b) return do_func('div', a, b) end,
  __index = function(i,v,...) 
    if v=='add' or v=='sub' or v=='mul' or v=='div' then
      return function(self,b)
        b = type(b) == "table" and b or {x=b, y=b}
        Vector[v](self, b)
      end
    else
      return Vector[v]
    end
  end
}

function Vector:new(x,y)
  return setmetatable({ x = x, y = y }, Vector)
end

function Vector:print()
  print(self.x, self.y)
end

function Vector:add(b) 
  self.x, self.y = self.x + b.x, self.y + b.y
end

function Vector:sub(b) 
  self.x, self.y = self.x - b.x, self.y - b.y
end

function Vector:mul(b) 
  self.x, self.y = self.x * b.x, self.y * b.y
end

function Vector:div(b) 
  self.x, self.y = self.x / b.x, self.y / b.y
end

function Vector:norm()
  local m = self:mag()
  if m == 0 then m = 0.0001 end
  self.x = self.x / m
  self.y = self.y / m
end

function Vector:neg()
  self:mul(-1)
end

function Vector:mag()
  return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
end

function Vector:perp()
  self.x, self.y = -self.y, self.x
end

function Vector:reverse()
  self.x, self.y = -self.x, -self.y;
end

function Vector:dot(b)
  return self.x * b.x + self.y * b.y
end

function Vector:abs()
  self.x, self.y = math.abs(self.x), math.abs(self.y)
end

function Vector:reflect(w) 
  w:perp()
  w:norm()
  w:print()
  w = w * 2 * self:dot(w)
  w:print()
  self.x = self.x - w.x
  self.y = self.y - w.y
end
