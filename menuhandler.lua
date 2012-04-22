module(..., package.seeall)

-- 
-- Simple Menu Handler
-- I was going to do an XML menu reader, but I'd have to assign functions to it anyway
--

require 'loader'
require 'utils'

function MenuHandler(opts)
  assert(type(menu) == "table" or not menu, "Passed in menu must be a table of menu items, or nothing at all")
  self = {}

  self.menu = {}

  self.current = nil

  self.opts = opts

  if not self.opts.pos then self.opts.pos = {x=0,y=0} end
  if not self.opts.spacing then self.opts.spacing = 20 end

  --
  -- Adds an item to the menu
  --   Display is what will be shown on the menu. Should either be a string or a function that returns a string.
  --   Action is the function that will be run when they choose this. Doesn't make sense to add to a parent element.
  --   Parent is the Display name of the parent element. If the Display is a function, it will be run before comparison
  --
  self.addItem = function(self, display, action, parent)
    if parent then
      assert(#self.menu > 0, "Menu cannot add children because there are no parent elements")
    end
    local tempItem = {display = display, action = action, children = {}, parent = nil, empty = true, 
      getDisplay = function() return type(display) == 'function' and display() or display end
    }
    if parent then
      parent = self:findNode(parent)
      if parent then 
        tempItem.parent = parent
        table.insert(parent.children, tempItem)
        parent.empty = false
      else error("Cannot find parent element")
      end
    else
      table.insert(self.menu, tempItem)
    end

    if not self.current then
      self.current = tempItem
    end

    return tempItem
  end

  self.findNode = function(self, display, startNode)
    assert(#self.menu > 0, "Menu has no nodes to search")
    startNode = startNode or self.menu
    for _,v in ipairs(startNode) do
      if v.getDisplay() == display then return v end
      if #v.children > 0 then self:findNode(display, v.children) end
    end
    return nil
  end

  self.nextNode = function(self)
    local list = self.current.parent and self.current.parent.children or self.menu
    for i,v in ipairs(list) do
      if v == self.current then
        if i == #list then self.current = list[1]
        else self.current = list[i+1] end
        break
      end
    end
  end

  self.prevNode = function(self)
    local list = self.current.parent and self.current.parent.children or self.menu
    for i,v in ipairs(list) do
      if v == self.current then
        if i == 1 then self.current = list[#list]
        else self.current = list[i-1] end
        break
      end
    end
  end

  self.parent = function(self)
    if self.current.parent then
      self.current = self.current.parent
    end
  end

  self.child = function(self)
    if self.current.action then
      self.current.action()
      return
    end
    if not self.current.empty then
      self.current = self.current.children[1]
    end
  end

  local outerSelf = self

  self.screen = {
    name = "menu",
    enter = function(self) love.graphics.setColor(255, 255, 255, 255) end,
    draw = function(self)
      if outerSelf.opts.font then
        love.graphics.setFont(outerSelf.opts.font)
      end

      local list = outerSelf.current.parent and outerSelf.current.parent.children or outerSelf.menu
      for i,menu_item in ipairs(list) do
        local y = outerSelf.opts.spacing * (i-1) + 10
        love.graphics.print(menu_item.getDisplay(), outerSelf.opts.pos.x, outerSelf.opts.pos.y + y)
        if menu_item == outerSelf.current then
          love.graphics.print("-", outerSelf.opts.pos.x - 25, outerSelf.opts.pos.y + y)
        end
      end
    end,

    update = function(self, dt)
      if self.keyhandler:handle('menuup') then
        outerSelf:prevNode()
      elseif self.keyhandler:handle('menudown') then
        outerSelf:nextNode()
      elseif self.keyhandler:handle('menuexit') then
        outerSelf:parent()
      elseif self.keyhandler:handle('menuenter') then
        outerSelf:child()
      end
    end
  }

  return self
end

