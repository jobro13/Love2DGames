local game = require "gamefiles/snake/game"

local cgame 

function love.load()
	love.math.setRandomSeed(os.time())
	cgame = game:new()
end 

function love.update(dt)

	if cgame.RequestNewStart then 
		cgame = game:new()
	elseif cgame.Started then 
		cgame:update(dt)
	end
end 

function love.draw()
	if cgame.Started then 
		cgame:drawfield()
	else 
		cgame:drawtitle()
	end
end 

love.keypressed = function(...)
	cgame:keydown(...)
end 