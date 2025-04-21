local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local pointBlocks = require("_scripts/pointBlocks")
local general = require("_scripts/generalStuff")

local killBoard = {}
local npcID = NPC_ID

local killBoardSettings = {
	id = npcID,

	gfxwidth = 32,
	gfxheight = 44,

	width = 32,
	height = 44,

	gfxoffsetx = 0,
	gfxoffsety = 0,

	frames = 2,
	framestyle = 0,
	framespeed = 8,

	luahandlesspeed = true,
	nowaterphysics = true,
	cliffturn = false,
	staticdirection = true,

	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt = true,
	nogravity = true,
	noblockcollision = true,
	notcointransformable = false,
	nofireball = true,
	noiceball = true,
	noyoshi = true,

	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = true,
	nowalldeath = false,


	terminalvelocity = -1,
}

npcManager.setNpcSettings(killBoardSettings)

function killBoard.onInitAPI()
	npcManager.registerEvent(npcID, killBoard, "onTickEndNPC")
	npcManager.registerEvent(npcID, killBoard, "onDrawNPC")
end

function killBoard.onTickEndNPC(v)
	if Defines.levelFreeze then return end

	local data = v.data

	if v.despawnTimer <= 0 then
		--data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true

		data.falling = true
		data.hurtPlayer = false

		data.leftLimit = pointBlocks.getPointX("killBoard_leftLimit")
		data.rightLimit = pointBlocks.getPointX("killBoard_rightLimit")

		data.floorY = pointBlocks.getPointY("killBoard_leftLimit")

		data.squimsh = 1
	end

	if data.falling then
		v.speedY = 14

		local predictedPlayerX = player.x + player.width*0.5 + player.speedX*math.max(0,((player.y + player.height) - (v.y + v.height))/v.speedY)
		local goalX = math.clamp(predictedPlayerX - v.width*0.5,data.leftLimit,data.rightLimit)

		v.x = math.lerp(v.x,goalX,0.125)

		if not data.hurtPlayer and Colliders.collide(player,v) then
			player:harm()
			data.hurtPlayer = true
		end

		if (v.y + v.height) >= data.floorY then -- hit the floor
			v.y = data.floorY - v.height
			v.speedY = 0
			
			data.falling = false

			v.spawnX = v.x
			v.spawnY = v.y
			v.spawnWidth = v.width
			v.spawnHeight = v.height
			v.spawnId = v.id

			v.msg = "killboard"
			v.friendly = true

			SFX.play(Misc.resolveSoundFile("_sound/misc/cartoon-slam"))

			general.spawnLandingDust(v.x + v.width*0.5,v.y + v.height)
		end

		v.animationFrame = 1
	else
		data.squimsh = math.max(0,data.squimsh - 1/16)
		v.animationFrame = 0
	end

	-- Don't despawn
	if v.section == player.section then
		v.despawnTimer = math.max(100,v.despawnTimer)
	end
end


function killBoard.onDrawNPC(v)
	if v.despawnTimer <= 0 then
		return 
	end

	local config = NPC.config[v.id]
	local data = v.data

	if data.sprite == nil then
		data.sprite = Sprite{texture = Graphics.sprites.npc[v.id].img,frames = npcutils.getTotalFramesByFramestyle(v),pivot = Sprite.align.BOTTOM}
	end

	local squimsher = math.sin(data.squimsh*math.pi*2.5)*data.squimsh*0.5

	data.sprite.x = v.x + v.width*0.5 + config.gfxoffsetx
	data.sprite.y = v.y + v.height + config.gfxoffsety

	data.sprite.scale = vector(1 - squimsher,1 + squimsher)

	data.sprite:draw{frame = v.animationFrame+1,priority = -46,sceneCoords = true}

	npcutils.hideNPC(v)
end


return killBoard