Game = {}
game=Game 

Game.Started = false 
Game.GameOver = false 

Game.ShipY = 0
Game.ShipSpeed = 300


Game.ShipColor = {0,0,255}

Game.ShipSize = {X=20,Y=20}

Game.ShipBorderOffset = 10

Game.ScreenSize = {}

Game.Boxes = {} 
Game.BoxColor = {255,0,0}

Game.BoxMinSize = 10
Game.BoxMaxSize = 30 

Game.BoxSpeed = 50
Game.BoxSpeedIncrease = 25
Game.BoxSpeedstd = Game.BoxSpeed  

Game.BoxSpawnDensityMin = 0.25 
Game.BoxSpawnDensityMax = 1 

Game.IncreaseValues = {
	ShipSpeed = 10,
	BoxSpawnDensityMin = -0.2,
	BoxSpawnDensityMax = -0.2


}

for i,v in pairs(Game.IncreaseValues) do 
	Game[i.."bak"] = Game[i]
end 

function Game:Restore()
	for i,v in pairs(Game.IncreaseValues) do 
		Game[i] = Game[i.."bak"]
	end 
end 



function Game:CheckHits(box, boxlist)
	local boxlist = boxlist or Game.Boxes 

	local sampled = false 

	local function pointIsInArea(x,y, ox, oxs, oy, oys)
		--print("ship x", x, "y", y, "boxl: x,y, xsize, ysize", ox, oxs, oy, oys)
		if x >= ox and x <= ox + oxs then 
			if y >= oy and y <= oy + oys then 
				return true 
			end 
		end 
		return false 
	end 
	local hit = false 
	local points = {
	{box.x, box.y}, {box.x + box.xs, box.y},
	{box.x, box.y + box.ys}, {box.x + box.xs, box.y + box.ys} }
	for i, point in pairs(points) do 
		for ind, val in pairs(boxlist) do 
			if pointIsInArea(point[1], point[2], val.x, val.xs, val.y, val.ys) then 
				val.Hit = true 
				hit = true 
			end 
			sampled = true 
		end 

	end 
	return hit 
end 

function rscale(min,max)
	return min + love.math.random() * (max-min)
end 

function Game:NewBox()
	local y = love.math.random() * Game.ScreenSize.Y 
	local x = Game.ScreenSize.X 
	local ds = Game.BoxMaxSize - Game.BoxMinSize 
	local sizex, sizey = Game.BoxMinSize + love.math.random() * ds, Game.BoxMinSize + love.math.random() * ds
	table.insert(Game.Boxes,  {x=x, y=y, xs = sizex, ys = sizey}  )
end 

function game.Init() 
	game.ShipY = Game.ScreenSize.Y/2 - Game.ShipSize.Y/2 
end 


function love.load()
	love.math.setRandomSeed(os.time())
	local x,y = love.window.getDimensions()
	Game.ScreenSize.X = x 
	Game.ScreenSize.Y = y 
end 

local last = 0 
local newbox = rscale(Game.BoxSpawnDensityMin, Game.BoxSpawnDensityMax)

local gtimer = 0

function love.update(dt)
	if Game.Started and not Game.GameOver then 
		last = last + dt 
		game.BoxSpeed = game.BoxSpeed + (dt * game.BoxSpeedIncrease)
		if last > newbox then 
			last=0
			newbox = rscale(Game.BoxSpawnDensityMin, Game.BoxSpawnDensityMax)
			Game:NewBox()
		end 
		local hit = Game:CheckHits({x=Game.ShipBorderOffset, y=Game.ShipY, xs =Game.ShipSize.X, ys = Game.ShipSize.Y })
		if hit then 
			Game.GameOver = true 
		end 
		local rem = {} 
		for i,v in pairs(Game.Boxes) do 
			v.x = v.x - (dt * Game.BoxSpeed)
			if v.x < (-(v.xs)) then 
				Game.Boxes[i] = nil 
			end 
		end 
		if love.keyboard.isDown("up") then 
			local new = Game.ShipY - (dt * Game.ShipSpeed)
			Game.ShipY = new 
		end 
		if love.keyboard.isDown("down") then 
			local new = Game.ShipY + (dt * Game.ShipSpeed)
			Game.ShipY = new 
		end 

		local newy = Game.ShipY 
		local maxY = Game.ScreenSize.Y - Game.ShipSize.Y 

		if newy < 0 then 
			Game.ShipY = 0 
		elseif newy > maxY then 
			Game.ShipY = maxY 
		end 

		for i,v in pairs(Game.IncreaseValues) do 
			Game[i] = Game[i] + dt * v 
			if i:match("BoxSpawnDensity") then 
				if i:match "Min" then 
					if Game[i] < 0.05 then 
						Game[i] = 0.05
					end 
				else 
					if Game[i] < 0.15 then 
						Game[i] = 0.15
					end 
				end 
			end  
		end 
	elseif game.GameOver then 
		gtimer = gtimer + dt 
		if gtimer > 3 then 
			gtimer = 0 
			last=0
			game.GameOver = false 
			game.Started = false 
			game.Boxes = {}
			game.BoxSpeed = game.BoxSpeedstd 
			game:Restore()
		end 
	end 
end 

function love.draw()
	
	if game.Started then 
		love.graphics.setColor(unpack(Game.ShipColor)) 
	-- draw ship 

		love.graphics.rectangle("fill",Game.ShipBorderOffset, Game.ShipY, Game.ShipSize.X, Game.ShipSize.Y)

		love.graphics.setColor(unpack(game.BoxColor))
		for i,v in pairs(game.Boxes) do 
			if v.Hit then 
				love.graphics.setColor(255,255,255)
			else 
				love.graphics.setColor(unpack(game.BoxColor))
			end
			love.graphics.rectangle("line", v.x, v.y, v.xs, v.ys)
		end 

	else 
		love.graphics.setColor(255,255,255)
		love.graphics.print("Druk op een toets om te starten .. ")
	end 

end 

function love.keypressed(key)
	if not game.Started then 
		game.Started = true
		game.Init()
	end 
end 