local game = require "gamefiles/snake/game"

local cgame 

function love.load()
	love.math.setRandomSeed(os.time())
	local flags = select(3, love.window.getMode())
	local disp = flags.display
	local movx, movy = love.window.getDesktopDimensions(disp)

	flags.fullscreentype = "desktop"

	love.window.setMode(movx, movy, flags)
	love.window.setFullscreen(true)
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
		if cgame.msg then 
			local oc = {love.graphics.getColor()}
			love.graphics.setColor(255,255,255)
		--	love.graphics.print(cgame.msg, 200,200)
			love.graphics.setColor(unpack(oc))
		end 
	else 
		cgame:drawtitle()
	end
end 

love.keypressed = function(...)
	cgame:keydown(...)
end 