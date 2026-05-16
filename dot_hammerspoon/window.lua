-- half of screen
-- {frame.x, frame.y, window.w, window.h}
-- First two elements: we decide the position of frame
-- Last two elements: we decide the size of frame
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'left', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.3, 1}) end)
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'right', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.3, 1}) end)
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'up', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 0.6}) end)
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'down', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 1, 0.6}) end)
-- top left
-- {x pos, y pos, width, height} - position measured from top left of screen (0 = top/left, 1=bottom/right)
-- top left
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'w', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 0.5}) end)
-- top right
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'r', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 0.5}) end)
-- bottom left
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'x', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 0.5, 0.5}) end)
-- bottom right
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'v', function() hs.window.focusedWindow():moveToUnit({0.5, 0.5, 0.5, 0.5}) end)
--some new additions to this file
-- full screen
hs.hotkey.bind({'alt', 'ctrl', 'cmd', 'shift'}, 'e', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 1}) end)

-- left third
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 's', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.34, 1}) end)
-- middle third
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'd', function() hs.window.focusedWindow():moveToUnit({0.34, 0, 0.34, 1}) end)
-- right third
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'f', function() hs.window.focusedWindow():moveToUnit({0.68, 0, 0.32, 1}) end)

-- center screen
hs.hotkey.bind({'ctrl', 'alt', 'cmd', 'shift'}, 'c', function() hs.window.focusedWindow():centerOnScreen() end)
