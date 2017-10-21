

TimePerUpdate = 0.09
updateTimer = 0

chargedTime = 0
maxChargeTime = 1.5

currentBall = 2
nextBall = 3

ballDestroyQueue = {}
movingBalls = {}
BALL_WIDTH = 32
BALL_HEIGHT = 26

playfield = {}
playfield.x = 400
playfield.y = 100
playfield.width = 7
playfield.height = 16

function getNextBall()
	return 3
end

function DrawFirePath()
	for i=0,20 do
		DrawFirePathDot(i)
	end
end

function DrawFirePathDot(value)
	local x = (playfield.width-0.5)*BALL_WIDTH*(chargedTime/maxChargeTime)
	x = x +playfield.x+BALL_WIDTH*1.5
	love.graphics.circle("fill",x,value*BALL_HEIGHT,4)
end

function love.load()
	spr_ball = love.graphics.newImage("Content/kula.png")
	spr_playfield  = love.graphics.newImage("Content/playfield.png")
	updateTimer = TimePerUpdate
	CreatePlayfield()

	movingBalls.amount = 0
	ballDestroyQueue.amount = 0
end

function love.update(dt)
	if(love.mouse.isDown(1)) then
		chargedTime = math.clamp(0,chargedTime+dt,maxChargeTime)

	elseif chargedTime> 0 then
		local fallPos = chargedTime/maxChargeTime
		printPos = math.round(chargedTime/maxChargeTime *(playfield.width-1)*2)+2
		printPos = printPos/2

		if printPos%1 ~= 0 then
			playfield[math.floor(printPos)][2] =currentBall
		else
			playfield[math.floor(printPos)][1] =currentBall
		end

		currentBall = nextBall
		nextBall =getNextBall()
		--7.5
		chargedTime = 0
	end
	updateTimer = updateTimer - dt
	if updateTimer < 0 then
		updatePlayfield()
		updateTimer = updateTimer +TimePerUpdate
	end
end

function love.draw()
	love.graphics.clear()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(spr_playfield,playfield.x,playfield.y)
	DrawFirePath()

	for x=1,playfield.width do
		for y=1,playfield.height do

			if playfield[x][y] ~= 0 then
				drawBall(ballXPos(x,y),
					ballYPos(y),
					playfield[x][y])
			end
			drawMovingBalls(updateTimer/TimePerUpdate)
			if printPos ~= nil then
				love.graphics.setColor(255,255,255)
				love.graphics.print(printPos,10,10)
			end

			drawBall(344,200+chargedTime/maxChargeTime * 300,currentBall)
		end
	end


end



function CreatePlayfield()
	for x=1,playfield.width do
		playfield[x] = {}
		for y=1,playfield.height do
			playfield[x][y] = love.math.random(7)-1
		end
	end
end

function updatePlayfield()
	if ballDestroyQueue.amount>0 then
		destroyBall(ballDestroyQueue[ballDestroyQueue.amount].x,ballDestroyQueue[ballDestroyQueue.amount].y)
		ballDestroyQueue.amount = ballDestroyQueue.amount-1
--			ballDestroyQueue[ballDestroyQueue.amount].x,ballDestroyQueue[ballDestroyQueue.amount].y
		return 0
	end

	if movingBalls ~= nil then
		local x,y 
		for i=1, movingBalls.amount do
			playfield[movingBalls[i].toX][movingBalls[i].toY] = movingBalls[i].col

		--	lerp(ballXPos(b.fromX,b.fromY),ballXPos(b.toX,b.toY),1-t)
		--	y = lerp(ballYPos(b.fromY),ballYP
		end
		movingBalls.amount = 0
	end

	local playfieldIsstatic = true
	buffer = createBuffer()
	for x=1,playfield.width do
		for y=playfield.height,1,-1 do
			 
			if playfield[x][y] ~= 0 and playfield.height ~= y then
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
					playfieldIsstatic= false
				elseif canFallPathRight then
					moveBall(x,y,x+xPathRight,y+1)
					playfieldIsstatic= false
				elseif canFallPathLeft then
					moveBall(x,y,x+xPathLeft,y+1)
					playfieldIsstatic= false
				end
			end
		end
	end

	if playfieldIsstatic then checkConnection() end
	return 1
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
	local i = movingBalls.amount+1
	if movingBalls[i] == nil then movingBalls[i] = {} end
	movingBalls[i].fromX = fromX
	movingBalls[i].fromY = fromY
	movingBalls[i].toX = toX
	movingBalls[i].toY = toY
	movingBalls[i].col = playfield[fromX][fromY]
	movingBalls.amount = i

	buffer[toX][toY] = buffer[fromX][fromY] 
	buffer[fromX][fromY] = 0
	playfield[fromX][fromY] = 0
end

function drawMovingBalls(t)
	if movingBalls ~= nil then
		local x,y 
		for i=1, movingBalls.amount do
			local b = movingBalls[i]
			t = math.clamp(0,t,1)
			
			x = lerp(ballXPos(b.fromX,b.fromY),ballXPos(b.toX,b.toY),1-t)
			
			y = lerp(ballYPos(b.fromY),ballYPos(b.toY),1-t)
			
			drawBall(x,y,movingBalls[i].col)
			
		end
	end
end

function ballXPos(x,y)
	return playfield.x+ x*BALL_WIDTH+(y%2)*BALL_WIDTH/2
end

function ballYPos(y)
	return playfield.y+ y*BALL_HEIGHT
end

function lerp(a,b,t) return (1-t)*a + t*b end

function lerp2(a,b,t) return a+(b-a)*t end

function cerp(a,b,t) local f=(1-math.cos(t*math.pi))*.5 return a*(1-f)+b*f end

function math.clamp(low, n, high) return math.min(math.max(low, n), high) end

function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

function endMovement()
	for ball in pairs(movingBalls) do
		playfield[ball.toX][ball.toY] = ball.col

		for k,v in pairs(ball) do ball[k]=nil end
	end
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
						queueBallDestruction(connected[i].x,connected[i].y)
					end
				--	time = updateTime
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

function queueBallDestruction(x,y)
	if isInsideBounds(x,y) then
		local i = ballDestroyQueue.amount+1
		if ballDestroyQueue[i] == nil then ballDestroyQueue[i] = {} end
		ballDestroyQueue[i].x = x
		ballDestroyQueue[i].y = y
		ballDestroyQueue.amount = i
		playfield[x][y] = -1
	end
end

function destroyBall(x,y)
	if isInsideBounds(x,y) then
		playfield[x][y] = 0
		
	end 
end

function drawBall(x,y,col)
	if col == 1 then
		love.graphics.setColor(255,0,0)
	elseif col == 2 then
		love.graphics.setColor(0,255,0)
	elseif col == 3 then
		love.graphics.setColor(0,150,255)
	elseif col == 4 then
		love.graphics.setColor(255,0,255)
	elseif col == 5 then
		love.graphics.setColor(255,255,0)
	elseif col == 6 then
		love.graphics.setColor(0,255,255)
	elseif col == -1 then
		love.graphics.setColor(255,255,255)
	end
	love.graphics.draw(spr_ball,x,y)

end

