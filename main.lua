

updateTime= 0.1
time = 0

function love.load()
	spr_ball = love.graphics.newImage("Content/kula.png")
	spr_playfield  = love.graphics.newImage("Content/playfield.png")
	CreatePlayfield()
end

function love.update(dt)
	time = time + dt
	if time > updateTime then
		updatePlayfield()
		time = time -updateTime
	end
end

function CreatePlayfield()
	playfield = {}
	playfield.x = 400
	playfield.y = 100
	playfield.width = 7
	playfield.height = 16
	for x=1,playfield.width do
		playfield[x] = {}
		for y=1,playfield.height do
			playfield[x][y] = love.math.random(7)-1
		end
	end
end

function updatePlayfield()
	local buffer = createBuffer()
	for x=1,playfield.width do
		for y=playfield.height,1,-1 do
			 
			if buffer[x][y] ~= 0 and playfield.height ~= y then
				local xPathRight = 0
				local xPathLeft = 0
				if y%2 == 0 then
					xPathLeft = -1
				else
					xPathRight = 1
				end

				local canFallPathRight = x+xPathRight <= playfield.width  and buffer[x+xPathRight][y+1] == 0
				local canFallPathLeft = x+xPathLeft ~= 0 and buffer[x+xPathLeft][y+1] == 0
				local canFallPathDown = canFallPathRight and canFallPathLeft and y+1 ~= playfield.height and buffer[x][y+2] == 0

				if canFallPathDown then
					moveBall(x,y,x,y+2)
				elseif canFallPathRight then
					moveBall(x,y,x+xPathRight,y+1)
				elseif canFallPathLeft then
					moveBall(x,y,x+xPathLeft,y+1)
				end
			end
		end
	end
	checkConnection()
end

function createBuffer()
	local buffer = {}
	for x=1,playfield.width do
		buffer[x] = {}
		for y=1,playfield.height do
			buffer[x][y] = playfield[x][y]
		end
	end
	return buffer
end

function moveBall(fromX,fromY,toX,toY)
	playfield[toX][toY] = playfield[fromX][fromY] 
	playfield[fromX][fromY] = 0
end

function checkConnection()
	buffer = createBuffer()

	for x=1,playfield.width do
		for y=1,playfield.height do
			if buffer[x][y] ~= 0 then

				connected = {}
				connectionSize = 0
				continueConnection(x,y,buffer[x][y])

				if connectionSize > 2 then
					for i=1,connectionSize do
						-- NILL PROBLEM
						destroyBall(connected[i].x,connected[i].y)
					end
				end

			end
		end
	end
end

function continueConnection(x,y,color)
	if isInsideBounds(x,y) and buffer[x][y] == color then
		local pos = {}
		pos.x = x
		pos.y = y
		connectionSize = connectionSize+1
		table.insert(connected, pos)
		buffer[x][y] = 0
		continueConnection(x-1,y,color)
		continueConnection(x+1,y,color)
		continueConnection(x,y+1,color)
		continueConnection(x,y-1,color)
		if y%2 == 0 then
			continueConnection(x-1,y+1,color)
			continueConnection(x-1,y-1,color)
		else
			continueConnection(x+1,y+1,color)
			continueConnection(x+1,y-1,color)
		end
	end
end
function isInsideBounds(x,y)
	return x ~= 0 and y ~= 0 and x <= playfield.width and y <= playfield.height
end

function destroyBall(x,y)
	if isInsideBounds(x,y) then
		playfield[x][y] = 0
		
	end 
end



function love.draw()
	love.graphics.clear()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(spr_playfield,playfield.x,playfield.y)
	for x=1,playfield.width do
		for y=1,playfield.height do

			if playfield[x][y] > 0 then
				color = playfield[x][y] 
				if color == 1 then
					love.graphics.setColor(255,0,0)
				elseif color == 2 then
					love.graphics.setColor(0,255,0)
				elseif color == 3 then
					love.graphics.setColor(0,150,255)
				elseif color == 4 then
					love.graphics.setColor(255,0,255)
				elseif color == 5 then
					love.graphics.setColor(255,255,0)
				elseif color == 6 then
					love.graphics.setColor(0,255,255)

				end

				love.graphics.draw(spr_ball,playfield.x+ x*32+(y%2)*16,playfield.y+ y*26)

			end
		end
	end
	
end