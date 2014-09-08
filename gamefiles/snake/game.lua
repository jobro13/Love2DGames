local game = {}

local snake = require "gamefiles/snake/snake"
local tile = require "gamefiles/snake/tile"
local scheduler = require "gamefiles/lovesched"

game.BorderSize = 10
game.BorderColor = {125,125,125}

game.Started = false 

game.GameOverRestartTime = 3 

game.PowerUpTimer = 0 
game.PowerUpTimeMin = 2
game.PowerUpTimeMax = 4 

game.quitkey = "escape"

function game:setmsg(msg)
	self.msg = msg 
	scheduler.add(2, 
		function()
			if self.msg == msg then 
				self.msg = nil 
			end 
		end)
end 


function game:getgridbounds()
	local wx, wy = love.window.getDimensions()
	return math.floor(wx/self.gridsize), math.floor(wy/self.gridsize)
end 

function game:setOccupied(x,y,isOccupied, by)
	if isOccupied then 
		if self.grid[x] then 
			if not self.grid[x][y] then 
				self.grid[x][y] = {by}
			else 
				table.insert(self.grid[x][y], by)
				if #self.grid[x][y] > 1 then 
					self.grid.CS[x.."x"..y] = {x,y}
				end
			end  
		else 
			self.grid[x] = {[y] = {by}}
		end 
	else 
		if self.grid[x] then 
			if self.grid[x][y] then 
				local len = #self.grid[x][y]
				if len == 1 and self.grid[x][y][1] == by then 
					self.grid[x][y] = nil 
				elseif len > 1 then 
					for i,v in pairs(self.grid[x][y]) do 
						if v == by then 
							table.remove(self.grid[x][y], i)
							break 
						end 
					end 
					if #self.grid[x][y] == 1 then 
						self.grid.CS[x.."x"..y] = nil
					end 
				end
			end
		end
	end 
end

function game:getOccupied(x,y)
	if self.grid[x] then 
		return self.grid[x][y]
	end 
end 

function game:addsnake(name, keymap, color)
	local new = snake:new()
	new.Name = name 
	new.keymap = keymap 
	new.color = color 
	new.game = self
	new.position[2] = new.position[2] + 5 * #self.snakes
	table.insert(self.snakes, new) 
	new:drawfirst()
end 


function game:new()
	local o = setmetatable({}, {__index=self})
	o.gamefield = love.graphics.newCanvas()
	o.gamefield:clear()
	love.graphics.setCanvas(o.gamefield)
	o.grid = {}
	o.grid.CS = {}
	o.snakes = {}
	--[[o.snake = snake:new()
	o.snakes = {o.snake}
	o.snake.game = o
	o.snake.Name = "groene slang"
	o.snake.keymap = {
	up = "up",
	down = "down",
	left = "left",
	right = "right"	
	}--]]

	o:addsnake("groene slang",
		nil, nil)
	o:addsnake("rode slang", 
		{w = "up",
		s = "down", 
		d = "right",
		a = "left"}, 
		{255,0,0})

	--[[o:addsnake("oranje slang", 
		{i ="up",
		j = "left",
		k = "down",
		l = "right"},
		{255,130,130})--]]

	--o.snakes[2].speed= 30


	o.gridsize = o.snakes[1].size
	local x,y = love.window.getDimensions()
	love.graphics.setColor(unpack(self.BorderColor))
	love.graphics.rectangle("line", 0,0,x,y)
	love.graphics.setCanvas()
	return o
end 

function game:drawfield() 
	if not self.Started then 
		return 
	end
	love.graphics.setColor(255,255,255,255)

	love.graphics.draw(self.gamefield,0,0)
end 

function game:drawtitle()
	love.graphics.setColor(255,255,255)
	love.graphics.print("Snake!", 200,200)
	love.graphics.print("Druk op een toets om te starten ...",200,220)

end 

function game:gameover()
	self.GameOver = true 
	self.GameOverTimer = 0 
	local alive = self.snakes[1]
	self.won = alive.Name
end 

function game:update(dt)

	love.graphics.setCanvas(self.gamefield)
	if not self.GameOver then 
		for i,v in pairs(self.snakes) do 
			v:update(dt)
			local hpos = v.pdata[1]
			local max_x, max_y = self:getgridbounds(max_x, max_y)
		--[[	if hpos[1] > max_x or hpos[1] < 0 or hpos[2] > max_y or hpos[2] < 0 then 
				v:remove()
			end--]] 
		end 
		for i,v in pairs(self.grid.CS) do 	
			local data = self.grid[v[1]][v[2]]
			--print("CS", v[1], v[2], #data)
			if #data > 1 then
				local snakes = {}
				local tile
				local bomb 
				for i,v in pairs(data) do 
					if v.class == "snake" then 
						table.insert(snakes,v)
						print('snake')
					elseif v.class == "tile" then 
						tile = v
						print('tile')
					elseif v.class == "bomb" then 
						bomb = v 
					end 
				end 
				if #snakes >= 2 then 
					for i = 2, #snakes do 
						local sn = snakes[i]
						sn:remove()
					end 
					if tile then 
						tile:touch(snakes[1])
					end 
				elseif tile and #snakes >= 1 then 
					tile:touch(snakes[1])
				elseif bomb and #snakes == 1 then 
					snakes[1]:remove() 
				end

				
			end 
		end 
		if #self.snakes == 1 then 
			self:gameover()
		end 

		-- place power ups?

		if not self.PowerUpTimerSet then
			self.PowerUpTimerSet = love.math.random() * (self.PowerUpTimeMax - self.PowerUpTimeMin) + self.PowerUpTimeMin 
		end 

		self.PowerUpTimer = self.PowerUpTimer + dt 

		if self.PowerUpTimer >= self.PowerUpTimerSet then 
			local x = tile:new()
			x:make(self)
			self.PowerUpTimer = 0 
			self.PowerUpTimerSet = love.math.random() * (self.PowerUpTimeMax - self.PowerUpTimeMin) + self.PowerUpTimeMin 
		end 


	else 
		self.GameOverTimer = self.GameOverTimer + dt 
		love.graphics.setBlendMode("alpha")
		if not self.printed then
			love.graphics.print("De " .. self.won .. " heeft gewonnen!", 200,200)
			self.printed = true 
		end

		if self.GameOverTimer > self.GameOverRestartTime then 
			self.RequestNewStart = true 
		end 
	end 
	scheduler.check(dt)
	love.graphics.setCanvas()
	
end

function game:keydown(key)
	if key == self.quitkey then 
		love.event.quit()
	end 
	if not self.Started then 
		self.Started = true 
	else
		for i,v in pairs(self.snakes) do 
			if v.keymap[key] then 
				v:newDirection(v.keymap[key]) 
			end 
		end
	end 
end 

return game 