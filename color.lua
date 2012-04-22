module(..., package.seeall)

local order = {'r','g','b','a'}

function Color(r, g, b, a)
  self = {}

  self.r = r
  self.g = g
  self.b = b
  self.a = a

  self.rgba = {r, g, b, a}
  self.rgb = {r, g, b}

  self.set = function(self, ...)
    local args = {...}
    for i=1,#args do
      args[i] = args[i] or self[order[i]]
      self.rgba[i] = args[i]
      self.rgb[i] = args[i]
      self[order[i]] = args[i]
    end
  end

  self.update = function(self)
    self.rgba[1] = self.r
    self.rgba[2] = self.g
    self.rgba[3] = self.b
    self.rgba[4] = self.a
    self.rgb[1] = self.r
    self.rgb[2] = self.g
    self.rgb[3] = self.b
  end
  return self
end

white = Color(255, 255, 255, 255)
black = Color(0, 0, 0, 255)
grey = Color(128, 128, 128, 255)
red = Color(255, 0, 0, 255)
green = Color(0, 255, 0, 255)
blue = Color(0, 0, 255, 255)
yellow = Color(255, 255, 0, 255)
