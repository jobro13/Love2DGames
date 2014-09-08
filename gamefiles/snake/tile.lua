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

tile.types.freeze = {
	color = {255,0,255},
	realsize = 4
}

tile.types.bomb = {
	color = {127,127,127},
	realsize = 8

}

tile.types.color = {
	color = {0,255,255},
	realsize = 4
}

function tile:new()
	local o = {}
	return setmetatable(o, {__index=tile})
end

function tile:touch(snake)
	print("snake touch", snake.Name)
	if self.type == "longer" then 
		snake.supress = snake.supress + 40
	elseif self.type == "speed" then 
		snake.speed = snake.speed * 2
		-- for 5 seconds!
		scheduler.add(5, 
			function() 
				print("hi")
				snake.speed = snake.speed/2
			end
		)
	elseif self.type == "freeze" then 
		for i,v in pairs(self.game.snakes) do 
			if v ~= snake then 
				v.speed = v.speed/2
	
				scheduler.add(2,
					function()
						v.speed=v.speed*2
					end)
			end 
		end 
	elseif self.type == "bomb" then 
		local endp = snake.pdata[#snake.pdata]
		local lendp = snake.pdata[#snake.pdata-1]
		local dir = {lendp[1] - endp[1], lendp[2] - endp[2]}
		local bposx, bposy = endp[1] - dir[1], endp[2] - dir[2]

		local b = {class="bomb"}
		print("first")
		self.game:setOccupied(bposx, bposy, true, b)

		local drawx, drawy = bposx * self.game.gridsize, bposy * self.game.gridsize 

		local oc = {love.graphics.getColor()}

		love.graphics.setColor(255,255,255)
		love.graphics.rectangle("fill", drawx, drawy, self.game.gridsize, self.game.gridsize)

		love.graphics.setColor(unpack(oc))

		local bombradius = 5 -- for info only

		scheduler.add(5, 
			function() 
				print("secon")
				for x= bposx - 4, bposx + 4 do 
					for y = bposy - 4, bposy + 4 do
						if x ~= 0 and y ~= 0 then 
							self.game:setOccupied(x,y,true,b)
						end
					end 
				end

				local oc = {love.graphics.getColor()}

				love.graphics.setColor(255,255,255)
				local grids = self.game.gridsize
				love.graphics.rectangle("fill", drawx - 4 * grids, drawy - 4 *grids, 9*grids, 9*grids )

				love.graphics.setColor(unpack(oc))
			end)
			

		scheduler.add(10, 
			function() 
				-- remove bomb 
				print("removing")
				local oc = {love.graphics.getColor()}
				love.graphics.setColor(0,0,0)
				for x= bposx - 4, bposx + 4 do 
					for y = bposy - 4, bposy + 4 do
						

						local times = 1 
						if y == bposy and x == bposx then 
							times = 2 
						end 

						for i = 1, times do 
						self.game:setOccupied(x,y,false,b)
						local t = self.game.grid[x]
						local draw = true
						local grids = self.game.gridsize
						if t then 
							if t[y] then 
								if #t[y] > 0 then 
									draw = false
								else 
									for i,v in pairs(t[y]) do 
										print(v.class)
									end 
								end
							end
						end 

						if x == 0 and y == 0 then 
							print(draw)
						end 

						if draw then 
							print(x*grids, y*grids)
							love.graphics.rectangle("fill", x*grids, y*grids,grids,grids)
						end
						end 
					end 
				end

				love.graphics.setColor(unpack(oc))
			end)
	elseif self.type == "color" then 
		snake.color = {love.math.random(0,255), love.math.random(0,255), love.math.random(0,255)}
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

	
end 
return tile 

