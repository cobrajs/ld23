module(..., package.seeall)

--
-- Various XML related functions
-- Stuff really mostly only works for a few use cases
--

--
-- Print out a full table
-- Only really works with tables that mostly only have numbers and strings
-- as keys and values (and tables as values)
--
function PrintTable(t,base)
  base = base or ''
  print(base..' = {}')
  for i,v in pairs(t) do
    local pi = type(i)=='number' and '['..i..']' or '.'..i
    if type(v) == 'table' then
      PrintTable(v, base..pi)
    else
      local pv = type(v)=='string' and '"'..v..'"' or v
      print(base..pi..' = '..pv)
    end
  end
end

--
-- Kinda sorta writes XML
--
function WriteXML(t, base, tag)
  local final = ''
  if not base then 
    final = '<?xml version="1.0" encoding="UTF-8"?>\n'
    final = final .. '<root>\n'
    base = ''
    tag =''
  end
  local xarg = {}
  local empty = true
  if #tag > 0 then
    for i,v in pairs(t) do if type(v) == 'table' then empty = false end end
    if not empty then final = final..base..'<'..tag..'>\n' end
  end
  for i,v in pairs(t) do
    if type(v) == 'table' then
      final = final..WriteXML(v, base..'  ', type(i) == 'number' and tag:sub(1,#tag-1) or i)
    else
      xarg[i] = v
      empty = true
    end
  end
  local xargs = ""
  for i,v in pairs(xarg) do xargs = xargs..' '..i..'="'..v..'"' end
  if #tag > 0 then
    if empty then final = final..base..'<'..tag..xargs..'/>\n'
    else final = final..base..'</'..tag..'>\n' end
  else
    final = final..'</root>\n'
  end
  return final
end

--
-- XML Parsing Stuff
--
-- LoadXML from http://lua-users.org/wiki/LuaXml
function LoadXML(s)
  local function LoadXML_parseargs(s)
    local arg = {}
    string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
      arg[w] = a
    end)
    return arg
  end
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=LoadXML_parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=LoadXML_parseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[stack.n].label)
  end
  return stack[1]
end

--
-- Find the first instance of something from a base node
--
function FindInXML(node, label)
  if not node or node.label == label then return node end
  for i, v in ipairs(node) do
    if type(v) == 'table' then 
      local fn = FindInXML(v, label)
      if type(fn) == 'table' and fn.label == label then return fn end
    end
  end
  return nil
end

--
-- Find all instances of something from a base node
--
function FindAllInXML(node, label)
  local ret = {}
  if node then
    if node.label == label then table.insert(ret, node) end
    for i, v in ipairs(node) do
      if type(v) == 'table' then 
        local fn = FindAllInXML(v, label)
        if #fn > 0 then
          for j, nd in pairs(fn) do table.insert(ret, nd) end
        end
      end
    end
  end
  return ret
end

