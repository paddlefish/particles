
-- Example: Physics
-- Grabbity by Xcmd
-- Updated by Dresenpai
-- Updated 0.8.0 by Bartoleo
math.randomseed( os.time() )
local needBall = 100

local removeObject = function()

end

local aparatus = {
	{ 590, 90 },
	{ 500, 10 },
	{ 90, 10 },
	{ 10, 90 },
	{ 10, 500 },
	{ 90, 590 },
	{ 500, 590 },
	{ 590, 500 },
	{ 590, 90 },
}

-- Convert the points into rectangles defining the edge
-- by connecting each to the next
local prev = nil
for _, wall in ipairs( aparatus ) do
	if not wall[ 1 ] then
		prev = nil
	end
	if prev then
		wall[ 3 ], wall[ 4 ] = prev[ 1 ], prev[ 2 ]
			-- Copy the x1, y1 coord of the prev edge onto this one
			-- note that lua indexes arrays starting at 1
			-- also isn't it cool that you can assign two things at once
	end
	prev = wall[ 1 ] and wall
end

local myBallBodies = {}
local log = {}

local function randomValue( multiplier )
	return ( math.random() - 0.5 ) * multiplier
end
local function randomSpeed( multiplier )
	local angle = randomValue( math.pi / 2 ) + math.pi
	local speed = randomValue( multiplier )
	return speed * math.cos( angle ), speed * math.sin( angle )
end
local function addBall( x, y )
	local myBallBody = love.physics.newBody( myWorld, x, y, "dynamic" )
	myBallShape = love.physics.newCircleShape( 0, 0, 0.001 )
	myBallFixture = love.physics.newFixture(myBallBody, myBallShape)
	myBallFixture:setRestitution( 1.1 )
	myBallBody:setMassData(0,0,1,0)
	myBallBody:setLinearVelocity( randomSpeed( 500 ) )
	myBallFixture:setUserData { ball = true }
	myBallBodies[ myBallBody ] = true
	log[ #log + 1 ] = { "Added ball at %d, %d", x, y }
end

function love.load()

	love.graphics.setFont(love.graphics.newFont( 11))

	love.physics.setMeter( 32 )
	myWorld = love.physics.newWorld(0, 9.81*32, true)  -- updated Arguments for new variant of newWorld in 0.8.0
	gravity="none"
	myWorld:setGravity(0, 0)
	myWorld:setCallbacks( beginContact, endContact, preSolve, postSolve )

	for _, wall in ipairs( aparatus ) do
		if wall[ 3 ] and wall[ 4 ] then
			local body = love.physics.newBody( myWorld, 0,0 ,"static")
			love.graphics.print( string.format( "%d,%d,%d,%d", wall[ 1 ], wall[ 2 ], wall[ 3 ], wall[ 4 ] ), 400, 25 + _* 20 )
			local shape = love.physics.newEdgeShape( unpack( wall, 1, 4 ) )
			local fixture = love.physics.newFixture( body, shape )
			wall.body = body
			wall.shape = shape
			wall.fixture = fixture
			wall.wall = true
			fixture:setUserData( wall )
		end
	end

	prepostsolve = false

end

local function emForce( body )
	local dx, dy = body:getLinearVelocity()
--	local dist = math.sqrt( dx * dx + dy * dy )
--	local angle = math.atan2( dx, dy )
--	angle = angle + math.pi / 2
--	local x2, y2 = dist * math.cos( angle ), dist * math.sin( angle )
	return dy, -dx
end

local function destroy( fixture )
	local a = fixture:getBody()
	if myBallBodies[ a ] then
		log[ #log + 1 ] = { "Destroyed ball %s", tostring( a ) }
		myBallBodies[ a ] = nil
		a:destroy()
		needBall = needBall + 1
	end
end

local t = 0.1
function love.update( dt )
    for myBallBody in pairs( myBallBodies ) do
        myBallBody:applyForce( emForce( myBallBody ) )
		local dx, dy = myBallBody:getLinearVelocity()
		local speed = math.sqrt( dx * dx + dy * dy )
		if speed < 50 then
			destroy( myBallBody:getFixtureList()[ 1 ] )
		end
    end
	myWorld:update( dt )
	if t - dt < 0 then
		if needBall > 0 then
			addBall( 200, 110 )
			needBall = needBall - 1
		end
		t = 0.1
	else
		t = t - dt
	end
end

function love.draw()
		love.graphics.setColor( 125, 125, 125 )
	for _, wall in ipairs( aparatus ) do
		if wall.body and wall.shape then
		   love.graphics.line( wall.body:getWorldPoints( wall.shape:getPoints() ) )
		end
	end
   
	for myBallBody in pairs( myBallBodies ) do
		local x, y = myBallBody:getPosition()
		love.graphics.setColor(255, 0, 0)
		love.graphics.circle("line", x, y, 1 + myBallShape:getRadius())
	end

	love.graphics.setColor( 125, 125, 125 )
	love.graphics.print( "gravity:"..gravity, 25, 25 )
	if prepostsolve then
	  love.graphics.print( "space : disable preSolve/postSolve Logging", 400, 25 )
	else
	  love.graphics.print( "space : enable preSolve/postSolve Logging", 400, 25 )
	end
	love.graphics.print( "arrows : change gravity direction", 400, 36 )
	for _, line in ipairs( log ) do
		love.graphics.print( string.format( unpack( line, 1, line.n ) ), 400, 25 + _ * 25 )
	end
	while #log > 15 do
		table.remove( log, 1 )
	end

end

function love.keypressed( key )
   if key == "up" then
      myWorld:setGravity(0, -9.81*32)
      gravity="up"
      for i,v in ipairs(myWorld:getBodyList( )) do
        v:setAwake( true )
      end
   elseif key == "down" then
      myWorld:setGravity(0, 9.81*32)
      gravity="down"
      for i,v in ipairs(myWorld:getBodyList( )) do
        v:setAwake( true )
      end
   elseif key == "left" then
      myWorld:setGravity(-9.81*32, 0)
      gravity="left"
      for i,v in ipairs(myWorld:getBodyList( )) do
        v:setAwake( true )
      end
  elseif key == "right" then
      myWorld:setGravity(9.81*32, 0)
      gravity="right"
      for i,v in ipairs(myWorld:getBodyList( )) do
        v:setAwake( true )
      end
   end

   if key == " " then
      prepostsolve = not prepostsolve
   end

   if key == "r" then
      love.load()
   end
end

function beginContact( a, b, c )
end

function endContact( a, b, c )
   local aa = a:getUserData()
   local bb = b:getUserData()
	if aa == bb then
		return
	end
	if aa.wall or bb.wall then
		if aa.ball then
			destroy( a )
		end
		if bb.ball then
			destroy( b )
		end
	end
end

function preSolve( a, b, c )
end

function postSolve( a, b, c )
end

local function ifnil(ptest,preturn)
   if p==nil then
      return preturn
   end
   return ptest
end

function coll( a, b, c, ctype,detail )
end

