module(..., package.seeall)

require 'tileset'
require 'vector'
require 'utils'

local requireds = {'filename'}

function Actor(opts)
  self = {}

  for _,n in ipairs(requireds) do assert(opts[n], n.." is required") end

  self.image = tileset.XMLTileset(opts.filename)
  self.pos = opts.startPos
  self.script = opts.script

  self.animState = 1
  self.animPos = 0
  self.dir = 'right'
  self.anim = nil

  self.scriptStep = 1

  self.nextAction = function(self)
    self.scriptStep = self.scriptStep + 1 
    if self.script[self.scriptStep] then
      self[self.script[self.scriptStep].func](self, self.script[self.scriptStep].params)
    end
  end

  self.move = function(self, params)
    assert(params.x and params.y, 'X and Y missing from call to move')
    self.pos.x = self.pos.x + params.x
    self.pos.y = self.pos.y + params.y
  end

  self.moveTo = function(self, params)
    assert(params.x and params.y, 'X and Y missing from call to move')
    self.pos.x = params.x
    self.pos.y = params.y
  end

  self.switchAnim = function(self)
  end

  return self
end
