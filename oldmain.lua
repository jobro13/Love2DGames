socket = require "socket"



local fontsize = 12

local did_draw = false 

-- are you fucking kidding me !?

gamestate = {}

local hmap = {
	[0.9] = {r = {230,255}, same = true},
	[0.8] = {r = {100,180}, same=true },
	[0.6] = {r = {0,0}, g = {127,255}, b = {0,0}},
	[0] = {r = {0,0}, g = {0,0}, b = {127,255}}
}

function gettile(h)
	local i 
	local oi
	for ind, val in pairs(hmap) do 
		if ind <= h then
			if i then 
				if ind > i then 
					i = ind  
				end 
			else 

				i = ind 
			end 
		end 
	end 
	for ind, val in pairs(hmap) do 
		if ind >= i then 
			if oi then 
				if ind < oi then 
					oi = ind 
				end 
			else 
				oi = ind 
			end 
		end 
	end
	if oi == i then 
		oi = 1
	end 
	return i, h - i, (h - i) / (oi - i)
end 

function love.load()

love.math.setRandomSeed(os.time() * 100 / 13)

local flags = select(3, love.window.getMode())
local disp = flags.display
local movx, movy = love.window.getDesktopDimensions(disp)

flags.fullscreentype = "desktop"

love.window.setMode(movx, movy, flags)

--love.window.setFullscreen(true)

local loadbarsize = 0.3 

local midscrx = movx/2 
local midscry = movy/2 

local sizex, sizey = loadbarsize * movx, 50

local xpos = midscrx - sizex/2 
local ypos = midscry - sizey/2

love.graphics.setColor(255,255,255)
love.graphics.rectangle("line", xpos, ypos, sizex, sizey)

function fillbar(sizeof)
	love.graphics.setColor(0,255,0)
	love.graphics.rectangle("fill", xpos + 2, ypos + 2, (sizex-4) * sizeof, sizey-4)
end 

fillbar(1)


local permx, permy = love.math.random(), love.math.random()

local x, y = love.window.getDimensions()
local modg = 1
local usx, usy = x/modg, y/modg
print(x,y)
for rx=0,x do 
	for ry = 0, y do 
		local c = love.math.noise(rx/usx + permx, ry/usy + permy)

		if not gamestate[rx] then 
			gamestate[rx] = {}
		end 

		local tile_id, hdp, port = gettile(c)
		local cd = hmap[tile_id]
		local function randn(low,up)
			return math.floor( low + math.random() * (up-low) + 0.5)
		end 
		local function slidef(low,up,port)
			return low + port * (up-low)
		end 
		
		local r,g,b 

		r = slidef(cd.r[1], cd.r[2], port)
		if not cd.same then 
			g = slidef(cd.g[1], cd.g[2], port)
			b = slidef(cd.b[1], cd.b[2], port)
		else 
			g,b = r,r 
		end 
		newo = {r,g,b}
		gamestate[rx][ry] = newo

	end 
end 
	love.graphics.setBlendMode("alpha")
	print(love.window.getDimensions())
	buffer = love.graphics.newCanvas(love.window.getDimensions())
	buffer:clear()
	love.graphics.setCanvas(buffer)
	for x,v in pairs(gamestate) do 
		for y,c in pairs(v) do 
			local my = {c[1], c[2], c[3]}
			for i,v in pairs(my) do 
				my[i] = math.floor(v + 0.5)
			end 
			love.graphics.setColor(my[1], my[2], my[3], 255)
			love.graphics.point(x-0.5,y-0.5)
		end 
	end 
	love.graphics.setCanvas()

end

world_drawn = false 

local worldshowp = 1
local worldshowstop = 0.3
local frame_min = 0.1

local old

function love.update(dt)
	worldshowp = worldshowp - frame_min * dt 
	if worldshowp < worldshowstop then 
		worldshowp = worldshowstop 
	end 

end 

function love.draw()
		-- draw world 
		--love.graphics.print(0,0,love.timer.getFPS())
		love.graphics.setBlendMode("premultiplied")
		love.graphics.setColor(255*worldshowp,255*worldshowp,255*worldshowp,255*worldshowp)
		love.graphics.draw(buffer)
		
		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(255,255,255)
		love.graphics.print(love.timer.getFPS(), 0,0)
		
		--love.graphics.setColor(0,0,0,255*worldshowp)
		--love.graphics.rectangle("fill", 0,0,love.window.getDimensions())

end 