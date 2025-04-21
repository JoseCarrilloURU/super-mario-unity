local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local general = require("_scripts/generalStuff")


local checkpointFlag = {}
local npcID = NPC_ID

local checkpointFlagSettings = {
	id = npcID,
	
	gfxwidth = 64,
	gfxheight = 96,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 64,
	height = 96,
	
	frames = 8,
	framestyle = 0,
	framespeed = 4,
	
	speed = 1,
	
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt = true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = true,

	notcointransformable = true,
	ignorethrownnpcs = true,
	staticdirection = true,
	luahandlesspeed = true,

	grabside = false,
	grabtop = false,

	--lightradius = 100,
	--lightbrightness = 1,
	--lightoffsetx = 0,
	--lightoffsety = 0,
	--lightcolor = Color.white,
}

npcManager.setNpcSettings(checkpointFlagSettings)
npcManager.registerHarmTypes(npcID,{},{})

Checkpoint.registerNPC(npcID)


local confettiEmitter = Particles.Emitter(0,0,Misc.resolveFile("_graphics/particles/confetti.ini"))


function checkpointFlag.onInitAPI()
	npcManager.registerEvent(npcID, checkpointFlag, "onStartNPC")
	npcManager.registerEvent(npcID, checkpointFlag, "onTickNPC")
	npcManager.registerEvent(npcID, checkpointFlag, "onDrawNPC")

	registerEvent(checkpointFlag, "onDraw")
end


local function getCheckpoint(v)
	return v.data._basegame.checkpoint
end

function checkpointFlag.onStartNPC(v)
	if GameData.inTimeTrials then
		v:kill(HARM_TYPE_VANISH)
	end
end

function checkpointFlag.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end

	local c = getCheckpoint(v)

	if not data.initialized then
		data.initialized = true
		data.active = c.collected
		
		data.bounce = false

		if c.powerup ~= nil then -- this actually IS necessary, due to an oversight in checkpoints' metatables...
			c.powerup = nil
		end
	end

	if data.bounce and v.collidesBlockBottom then
		data.bounce = false
		v.speedY = -2
	end

	if not data.active then
		if Colliders.collide(v,player) then
			local effectX = v.x + v.width*0.5 + 6
			local effectY = v.y + v.height - 64

			general.spawnPowerupEffects(768,effectX,effectY,2,4,0)
			general.spawnPowerupEffects(769,effectX,effectY,2,4,45)

			confettiEmitter.x = effectX
			confettiEmitter.y = effectY
			confettiEmitter:emit(20)


			data.bounce = true
			v.speedY = -4

			c:collect(player)
		end

		if Checkpoint.getActive() == c then
			data.active = true
		end
	elseif Checkpoint.getActive() ~= c then
		data.active = false
		c:reset()
	end

	npcutils.applyLayerMovement(v)
end

function checkpointFlag.onDrawNPC(v)
	if v.despawnTimer <= 0 then return end

	local data = v.data

	npcutils.restoreAnimation(v)

	if data.active then
		v.animationFrame = v.animationFrame + npcutils.getTotalFramesByFramestyle(v)
	end
end


function checkpointFlag.onDraw()
	if confettiEmitter:count() > 0 then
		confettiEmitter:draw(-4.5,true,nil,true)
	end
end


return checkpointFlag