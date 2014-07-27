local tile = {}

local scheduler = require "gamefiles/lovesched"

tile.class = "tile"

tile.types = {
	longer = 
		{color = {255,255,0}, 
		realsize = 4, -- amount of grid 
		
	}

}

tile.types.speed = {
	color = {0,0,255},
	realsize = 4
}

function tile:new()
	local o = {}
	return setmetatable(o, {__index=tile})
end

function tile:touch(snake)
	print("snake touch", snake.Name)
	if self.type == "longer" then 
		snake.supress = 20
	end 
	if self.type == "speed" then 
		snake.speed = snake.speed * 1.5
		-- for 5 seconds!
		scheduler.add(5, 
			function() 
				print("hi")
				snake.speed = snake.speed/1.5
			end
		)
	end
	self:remove() 
end 

function tile:remove()
	for x = self.gridx, self.gridx + self.gridsizeused - 1 do 
		for y = self.gridy, self.gridy + self.gridsizeused - 1 do 
			self.game:setOccupied(x, y, false, self)
			if not self.game.grid[x] or not self.game.grid[x][y] or #self.game.grid[x][y] == 0 then -- nothing on it
				local oc = {love.graphics.getColor()}
				love.graphics.setColor(0,0,0)
				local grid = self.game.gridsize
				love.graphics.rectangle("fill", x*grid, y*grid, grid, grid)

				love.graphics.setColor(unpack(oc))
			end 
		end 
	end 
end 



function tile:make(game)
	self.game = game 
	local c = {love.graphics.getColor()}
	local function newpos()
		local func = love.math.random 
		local xm, ym = game:getgridbounds()
		return math.floor(func() * xm + 0.5), math.floor(func() * ym + 0.5)
	end 

	local n = 0 
	for i,v in pairs(self.types) do 
		n = n + 1
	end 

	local typen = love.math.random(1,n)
	local ci = 0 
	for i,v in pairs(self.types) do 
		ci = ci + 1 
		if ci == typen then 
			self.type = i 
			break 
		end 
	end

	local o = self.types[self.type]
	love.graphics.setColor(unpack(o.color))
	local rootx, rooty 
	for i = 1,20 do 
		rootx, rooty = newpos()
		local t = game:getOccupied(rootx, rooty)
		if not t or #t == 0 then 
			break 
		end 
	end

	local rx, ry = rootx*game.gridsize, rooty*game.gridsize
	 -- pattern 
	 --[[
	for rowy, rowd in pairs(o.pattern) do 
		for rowx, rowsetting in pairs(rowd) do 
			local x,y = rx + rowx - 1 + 0.5, ry + rowy - 1 + 0.5
			
			if rowsetting == 1 then 
				love.graphics.setColor(unpack(o.color))
				love.graphics.point(x,y)
			else
				love.graphics.setColor(0,0,0)
				love.graphics.point(x,y)
			end 
		end 
	end--]]

	local plusx = (game.gridsize * o.realsize)/2
	local cx, cy = rx + plusx, ry + plusx
	self.gridsizeused = o.realsize
	love.graphics.circle("fill", cx, cy, plusx, 50)

	self.x = rx
	self.y = ry 
	self.gridx, self.gridy = rootx, rooty
	local ongridx, ongridy = o.realsize, o.realsize
	for x = 0, ongridx - 1 do 
		for y = 0, ongridy - 1 do 
			game:setOccupied(rootx + x,rooty + y, true, self)
		end 
	end

	love.graphics.setColor(unpack(c))

	if not istate then 
		istate = true 
		for x,d in pairs(game.grid) do 
			for y,l in pairs(d) do 
				for _,e in pairs(l) do 
					print(x .. " : " .. y .. " : " .. tostring(e.class), tostring(l.class))
				end 
			end 
		end
	end 
end 
return tile 

