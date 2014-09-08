local snake = {}

snake.color = {0,255,0}

snake.speed = 30

snake.size = 4

snake.class = "snake"

snake.keymap = {
	up = "up",
	down = "down",
	left = "left",
	right = "right"
}

function snake:new()
	local o = {}
	o.posused = {}
	o.pdata = {}
	return setmetatable(o, {__index=self})
end 

snake.direction = {1, 0}
snake.position = {40,20}

snake.length = 1

snake.supress = 40
snake.plusmove = 0

function snake:remove()
	for i,v in pairs(self.pdata) do 
	--	self.game:setOccupied(v[1], v[2], false, self )
	end
	for i,v in pairs(self.game.snakes) do 
		if v == self then 
			table.remove(self.game.snakes, i)
			break 
		end 
	end
	self.game:setmsg("De "..self.Name.. " is af!")
end 

function snake:newDirection(dirkey)
	local NO = {self.direction[1] * -1, self.direction[2] * -1}
	local old = self.direction
	if dirkey == "up" then 
		self.direction = {0, -1}
	elseif dirkey == "down" then
		self.direction = {0,1}
	elseif dirkey == "left" then 
		self.direction = {-1, 0}
	elseif dirkey == "right" then 
		self.direction = {1,0}
	end 
	if self.direction[1] == NO[1] and self.direction[2] == NO[2] then 
		self.direction = old 
	end
end 

function snake:occupy(x,y, isOccupied)
	self.game:setOccupied(x,y,isOccupied, self)
end 

function snake:update(dt)
	local move = math.floor(dt * self.speed + 0.5 + self.plusmove) 
	love.graphics.setColor(unpack(self.color))
	if move >= 1 then 
		-- delete last entries
		self.plusmove = self.plusmove - move
		if self.plusmove < 0 then 
			self.plusmove = 0 
		end 
		love.graphics.setColor(0,0,0)
		if move < self.supress then 
			self.supress = self.supress - move 
		else 
			self.supress = 0 
		end 

		local movedel = move - self.supress 
		local pdl = #self.pdata
		if movedel >= 1 then 
			for i = 1, move do 
				local ri = i-1 
				local data = self.pdata[pdl - ri]
				if data then
				love.graphics.rectangle("fill",data[1]*self.size, data[2]*self.size, self.size, self.size)
				self.pdata[pdl-ri] = nil 
				
				self:occupy(data[1], data[2], false )
				end
			end	 
		end
		local hpos = self.pdata[1]

		love.graphics.setColor(self.color)
		local xmax, ymax = self.game:getgridbounds(max_x, max_y)

		for i = 1, move do 
			local x, y = hpos[1] + i * self.direction[1], hpos[2] + i * self.direction[2]
			if x > xmax then 
				x = x - xmax
			end 
			if x < 0 then 
				x = xmax + x 
			end 
			if y > ymax then 
				y = y - ymax
			end 
			if y < 0 then 
				y = ymax + y 
			end 

			local new = {x,y}
			love.graphics.rectangle("fill",x*self.size, y*self.size, self.size, self.size)
			table.insert(self.pdata, 1, new)
			
			self:occupy(x,y,true)
		end 
	else 
		self.plusmove = self.plusmove + dt * self.speed
	end 
end 

function snake:drawfirst()
	local ardir = {self.direction[1] * -1, self.direction[2] * -1}
	local cx, cy = self.position[1], self.position[2]
	local ox,oy = cx,cy
	love.graphics.setColor(unpack(self.color))

	for i = 1, self.length do
		local ari = i-1
		cx = ox + ari * ardir[1]
		cy = oy + ari * ardir[2] 
		table.insert(self.pdata, {cx,cy})
		print(cx,cy)
		love.graphics.rectangle("fill", cx*self.size,cy*self.size, self.size, self.size)
		self:occupy(cx,cy, true)
	end 
end 

return snake 