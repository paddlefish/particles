
-- Example: Physics
-- Grabbity by Xcmd
-- Updated by Dresenpai
-- Updated 0.8.0 by Bartoleo
math.randomseed( os.time() )

local removeObject = function()

end

local aparatus = {
	{ 390, 290 },
	{ 390, 90 },
	{ 300, 10 },
	{ 90, 10 },
	{ 10, 90 },
	{ 10, 500 },
	{ 90, 590 },
	{ 300, 590 },
	{ 390, 500 },
	{ 390, 310 },
--	{},
--	{ 200, 10 },
--	{ 790, 10, },
--	{ 790, 590, beginContact = removeObject, },
--	{ 200, 590 },
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

local function randomValue( multiplier )
	return ( math.random() - 0.5 ) * multiplier
end
local function randomSpeed( multiplier )
	return randomValue( multiplier ), randomValue( multiplier )
end

function love.load()

	love.graphics.setFont(love.graphics.newFont( 11))

	love.physics.setMeter( 32 )
	myWorld = love.physics.newWorld(0, 9.81*32, true)  -- updated Arguments for new variant of newWorld in 0.8.0
	gravity="none"
	myWorld:setGravity(0, 0)
	myWorld:setCallbacks( beginContact, endContact, preSolve, postSolve )

for o = 1, 10 do
	for i = 1, 10 do
		local myBallBody = love.physics.newBody( myWorld, 200 + i * 10 + o * 5, 300 + o * 10 ,"dynamic" )
		myBallShape = love.physics.newCircleShape( 0, 0, 3 )
		myBallFixture = love.physics.newFixture(myBallBody, myBallShape)
		myBallFixture:setRestitution( 1.1 )
		myBallBody:setMassData(0,0,1,0)
		myBallBody:setLinearVelocity( randomSpeed( 300 ) )
		myBallFixture:setUserData("ball")
		myBallBodies[ #myBallBodies + 1 ] = myBallBody
	end
end

for _, wall in ipairs( aparatus ) do
	if wall[ 3 ] and wall[ 4 ] then
		local body = love.physics.newBody( myWorld, 0,0 ,"static")
		love.graphics.print( string.format( "%d,%d,%d,%d", wall[ 1 ], wall[ 2 ], wall[ 3 ], wall[ 4 ] ), 400, 25 + _* 20 )
		local shape = love.physics.newEdgeShape( unpack( wall, 1, 4 ) )
		local fixture = love.physics.newFixture( body, shape )
		wall.body = body
		wall.shape = shape
		wall.fixture = fixture
		fixture:setUserData( wall )
	end
end

	prepostsolve = false

end

function love.update( dt )
   myWorld:update( dt )
end

function love.draw()
	for _, wall in ipairs( aparatus ) do
		if wall.body and wall.shape then
		   love.graphics.line( wall.body:getWorldPoints( wall.shape:getPoints() ) )
		end
	end
   
	for _, myBallBody in ipairs( myBallBodies ) do
	   love.graphics.circle("line", myBallBody:getX(), myBallBody:getY(), myBallShape:getRadius())
	end

   love.graphics.print( "gravity:"..gravity, 25, 25 )
   if prepostsolve then
      love.graphics.print( "space : disable preSolve/postSolve Logging", 400, 25 )
   else
      love.graphics.print( "space : enable preSolve/postSolve Logging", 400, 25 )
   end
   love.graphics.print( "arrows : change gravity direction", 400, 36 )
for _, wall in ipairs( aparatus ) do
	if wall[ 3 ] and wall[ 4 ] then
		local body = love.physics.newBody( myWorld, 0,0 ,"static")
		love.graphics.print( string.format( "%d,%d,%d,%d", wall[ 1 ], wall[ 2 ], wall[ 3 ], wall[ 4 ] ), 400, 25 + _* 20 )
	end
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
   coll( a, b, c, "beginContact",true )
end

function endContact( a, b, c )
   coll( a, b, c, "endContact",true )
end

function preSolve( a, b, c )
   if prepostsolve then
     coll( a, b, c, "preSolve",false )
   end
end

function postSolve( a, b, c )
   if prepostsolve then
     coll( a, b, c, "postSolve",false )
   end
end

local function ifnil(ptest,preturn)
   if p==nil then
      return preturn
   end
   return ptest
end

function coll( a, b, c, ctype,detail )

   local f, r = c:getFriction(), c:getRestitution()
   --local s = c:getSeparation()   
   local px1, py1, px2, py2 = c:getPositions()
   --local vx, vy = c:getVelocity()
   local nx, ny = c:getNormal()
   local aa = a:getUserData()
	if aa[ ctype ] then
		aa[ ctype ]( aa )
	end
   local bb = b:getUserData()
	if bb[ ctype ] then
		bb[ ctype ]( bb )
	end

end

