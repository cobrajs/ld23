module(..., package.seeall)

require 'utils'
require 'xml'

--
-- Inputs:
--    image : Already loaded image from love
--    xtiles : Number of tiles along x axis
--    ytiles : Number of tiles along y axis
-- Returns a new tileset
--
function Tileset(image, xtiles, ytiles)
  assert(type(xtiles) == 'number' and type(ytiles) == 'number', 'xtiles and ytiles must be numbers') 
  local self = {}
  if type(image) == 'string' then
    self.image = utils.loadImage(image)
  end
  self.quads = {};
  self.xtiles = xtiles
  self.ytiles = ytiles
  self.tilewidth = self.image:getWidth() / self.xtiles
  self.tileheight = self.image:getHeight() / self.ytiles
  for y=0,ytiles - 1 do
    for x=0,xtiles - 1 do
      table.insert(self.quads, love.graphics.newQuad(
                x * self.tilewidth, y * self.tileheight,
                self.tilewidth, self.tileheight,
                self.image:getWidth(), self.image:getHeight()
      ))
    end
  end

  --
  -- Inputs: 
  --    X : X position of where to draw
  --    Y : Y position of where to draw
  --
  --    tileNum : Number of tile to draw
  --      or
  --    tileX : X position of tile to draw
  --    tileY : Y position of tile to draw
  --
  --
  self.drawXY = function(self, x, y, tileX, tileY, r, sx, sy, ox, oy)
    local tileNum = tileY and tileY * self.xtiles + tileX + 1 or tileX
    self:draw(x, y, tileNum, r, sx, sy, ox, oy)
  end

  self.draw = function(self, x, y, tileNum, r, sx, sy, ox, oy)
    assert(tileNum > 0 and tileNum <= #self.quads, 'Invalid tileNum: ' .. tileNum)
    love.graphics.drawq(self.image, self.quads[tileNum], x, y, r, sx, sy, ox, oy)
  end

  return self
end

function XMLTileset(xmlsource)
  local parsedXML = xml.LoadXML(love.filesystem.read(xmlsource))
  if type(parsedXML) == 'table' then
    local image = xml.FindInXML(parsedXML, 'image')
    local anims = xml.FindAllInXML(parsedXML, 'anim')
    local self = Tileset(image.xarg.source, tonumber(parsedXML[2].xarg.tilesx), tonumber(parsedXML[2].xarg.tilesy))
    self.anims = {}
    for i,v in ipairs(anims) do
      local temp = {
        start = tonumber(v.xarg.start), 
        fin = tonumber(v.xarg['end']),
        len = tonumber(v.xarg['end']) - tonumber(v.xarg.start)
      }
      if self.anims[v.xarg.name] then
        self.anims[v.xarg.name][v.xarg.dir] = temp
      else
        self.anims[v.xarg.name] = {[v.xarg.dir] = temp}
      end
    end
    return self
  else
    return nil
  end
end

