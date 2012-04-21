module(..., package.seeall)

--
-- Loads Tiled maps
--

require 'utils'
require 'xml'

function LoadMapLove(mapname)
  assert(type(love) ~= nil, 'Love2D is required for this function')
  local parsedXML = xml.LoadXML(love.filesystem.read(mapname))
  return ParseMap(parsedXML)
end

function LoadMapLua(mapname)
  local f = io.open(mapname)
  local parsedXML = xml.LoadXML(f:read('*a'))
  f:close()
  return ParseMap(parsedXML)
end

function ParseMap(parsedXML)
  local map = {}
  local tilesets = xml.FindAllInXML(parsedXML, 'tileset')
  map.tilesets = ParseTilesets(tilesets)
  local layers = xml.FindAllInXML(parsedXML, 'layer')
  map.layers = {}
  for i, v in pairs(layers) do
    table.insert(map.layers, ParseLayer(v))
  end
  local objectgroups = xml.FindAllInXML(parsedXML, 'objectgroup')
  map.objectgroups = {}
  for i, v in pairs(objectgroups) do
    table.insert(map.objectgroups, ParseObjectGroup(v))
  end
  map.width = map.layers[1].width * map.tilesets.images[1].tilewidth
  map.height = map.layers[1].height * map.tilesets.images[1].tileheight
  map.FindLayer = FindLayer
  map.FindObject = FindObject
  return map
end

function ParseObjectGroup(objgrp)
  assert(type(objgrp) == 'table' and objgrp.label == 'objectgroup', "Passed something that is not an objectgroup")
  local a = {}
  utils.CopyXargs(a, objgrp.xarg)
  local objects = xml.FindAllInXML(objgrp, 'object')
  a.objects = {}
  for i,v in ipairs(objects) do
    a.objects[i] = v.xarg
  end
  return a
end

function ParseTilesets(tilesets)
  local a = {}
  a.images = {}
  a.tiles = {}
  for i,v in pairs(tilesets) do
    local gid = tonumber(v.xarg.firstgid)
    local image = xml.FindInXML(v, 'image')
    assert(type(image) == 'table', "Problem with tileset image")
    local img = {}
    utils.CopyXargs(img, image.xarg)
    utils.CopyXargs(img, v.xarg)
    img.trans = utils.RGBToTable(img.trans)
    img.tileX, img.tileY = img.width/img.tilewidth, img.height/img.tileheight
    for y=1,img.tileY do
      for x=1,img.tileX do
        local tmp = {}
        tmp.image = img
        tmp.x = x
        tmp.y = y
        a.tiles[gid] = tmp
        gid = gid + 1
      end
    end
    table.insert(a.images, img)
  end
  return a
end

function ParseLayer(layer)
  assert(type(layer) == 'table' and layer.label == 'layer', "Passed something that is not a layer")
  local a = {}
  utils.CopyXargs(a, layer.xarg)
  a.grid = {}
  for y,yd in ipairs(string.split(layer[1][1], '\n')) do
    if utils.hasNum(yd) then
      local temp = {}
      for x, xd in ipairs(string.split(yd, ',')) do
        if utils.isNum(xd) then
          table.insert(temp, xd)
        end
      end
      table.insert(a.grid, temp)
    end
  end
  assert(#a.grid == a.height, "Invalid map height (Expected: "..a.height.."; Got: "..#a.grid..")")
  assert(#a.grid[1] == a.width, "Invalid map width (Expected: "..a.width.."; Got: "..#a.grid[1]..")")
  return a
end

function pt(t,o) 
  for i,j in pairs(t) do print(i,o and j[o] or j) end 
end

function FindLayer(map, layerName)
  for _,layer in ipairs(map.layers) do
    if layer.name and layer.name:lower() == layerName:lower() then
      return layer
    end
  end
  return nil
end

function FindObject(map, objType, objName)
  for i,objgroup in ipairs(map.objectgroups) do
    for _,obj in ipairs(objgroup.objects) do
      if obj.name and obj.type and obj.name:lower() == objName:lower() and obj.type:lower() == objType:lower() then
        return obj
      end
    end
  end
  return nil
end


--
-- Iterates over tiles visible in the current camera view
--
function tileIter(camera, layer, image)
  local minx = math.floor(-camera.x / image.tilewidth)
  local miny = math.floor(-camera.y / image.tileheight)
  local maxx = math.floor(minx + camera.width / image.tilewidth) + 1
  local maxy = math.floor(miny + camera.height / image.tileheight) + 1
  local x = minx - 1
  local y = miny
  return function()
    x = x + 1
    if x > maxx then
      y = y + 1
      x = minx
      if y > maxy then
        return nil
      end
    end
    if y < 0 or x < 0 or x >= layer.width or y >= layer.height then
      return 0, camera.x + x * image.tilewidth, camera.y + y * image.tileheight
    else 
      return layer.grid[y+1][x+1], camera.x + x * image.tilewidth, camera.y + y * image.tileheight
    end
  end
end
