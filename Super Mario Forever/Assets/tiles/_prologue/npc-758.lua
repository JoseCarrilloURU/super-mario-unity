local walker = require("_scripts/npc/walkerAI")

local yoshi = {}
local npcID = NPC_ID

local npcConfig = {
	id = npcID,

	gfxheight = 64,
	gfxwidth = 64,

	width = 32,
	height = 56,

	gfxoffsetx = 0,
	gfxoffsety = 0,

	frames = 10,
	framestyle = 1,
	framespeed = 8,

	speed = 1,

	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,

	jumphurt = true, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = true, --Held NPC hurts other NPCs if false
	harmlessthrown = true, --Thrown NPC hurts other NPCs if false

	variants = 3,
	priority = -45,
	maxDistance = 150,
	walkSpeed = 0.5,
	idleTime = 75,
	walkTime = 48,
}

walker.register(npcID, npcConfig, {
    frameCount = {2, 6,  2}, -- frame count for each state - idle, walk and talk
    frameDelay = {24, 8,  8}, -- frame delay for each state
    initFrame  = {1, 3, 9}, -- inital frame
})

return yoshi