keys = {}

function addKey(actionName, key)
  table.insert(keys, {action = actionName, key = key})
end

addKey('left', 'left')
addKey('right', 'right')
addKey('jump', 'up')
addKey('jump', 'x')
addKey('jump', 'c')
addKey('jump', ' ')
addKey('quit', 'q')
addKey('quit', 'escape')
addKey('spawn', 'n')
addKey('spawn', 'return')
addKey('uplevel', '=')
addKey('downlevel', '-')
