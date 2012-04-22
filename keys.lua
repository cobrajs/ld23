keys = {}

function addKey(actionName, key)
  table.insert(keys, {action = actionName, key = key})
end

-- Player keys
addKey('left', 'left')
addKey('right', 'right')
addKey('jump', 'up')
addKey('jump', 'x')
addKey('jump', ' ')
addKey('punch','c')
addKey('punch','shift')

-- Quit/exit to menu
addKey('quit', 'q')
addKey('quit', 'escape')

-- Menu keys
addKey('menuup', 'up')
addKey('menudown', 'down')
addKey('menuenter', 'return')
addKey('menuenter', 'right')
addKey('menuenter', ' ')
addKey('menuexit', 'left')

-- Debug keys
addKey('doflare', 'f')
addKey('spawn', 'n')
addKey('spawn', 'return')
addKey('uplevel', '=')
addKey('downlevel', '-')
