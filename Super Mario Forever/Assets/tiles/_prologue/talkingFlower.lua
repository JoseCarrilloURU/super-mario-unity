--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local textplus = require("textplus")
--Create the library table
local talkingFlower = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Custom local definitions below
local STATE_IDLE = 0
local STATE_TALK = 1
local STATE_TALK2 = 2

local tfont = textplus.loadFont("_fonts/pauseFont-noSpace-noShadow.ini")
local tbubb = Graphics.loadImageResolved("voicelines/bubble.png")
local tbubbL = Graphics.loadImageResolved("voicelines/bubbleLeft.png")
local tbubbR = Graphics.loadImageResolved("voicelines/bubbleRight.png")
local tbubbPoint = Graphics.loadImageResolved("voicelines/bubblePointer.png")

local function resetVars(data)
	data.talkTimer = 0
	data.waitTimer = data._settings.cooldown
	data.lerpTimer = 0
	data.lerpTimer2 = 0
	data.eventTalk = false
	data.eventTimer = 0
	data.msgOffset = -16
	data.alpha = 0
	data.canSFX = true
end

--Register events
function talkingFlower.register(id)
	npcManager.registerEvent(id, talkingFlower, "onTickEndNPC")
	npcManager.registerEvent(id, talkingFlower, "onDrawNPC")
	registerEvent(talkingFlower, "onEvent")
end

function talkingFlower.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	local settings = v.data._settings
	local cfg = NPC.config[v.id]
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
		
		data.state = STATE_IDLE
		
		data.canSFX = true
		data.canRender = true
		
		data.col = Colliders.Circle(v.x + (v.width / 2), v.y + (v.height / 2), settings.radius)
		--data.col:Debug(true)
		
		data.talkTimer = 0
		data.waitTimer = 0
		data.secondTimer = 0
		
		data.eventTalk = false
		data.eventTimer = 0
		
		data.lerpTimer = 0
		data.lerpTimer2 = 0
		data.msgOffset = -16
		
		data.alpha = 0
		
		v.friendly = true
		
		data.message = data.message or nil
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
	
	--Execute main AI. This template just jumps when it touches the ground.
	data.col.x = v.x + (v.width / 2)
	data.col.y = v.y + (v.height / 2)
	
	if cfg.flying then
		cfg.nogravity = true
		v.speedX = math.cos(lunatime.tick() * 0.04) * 0.3
		v.speedY = math.sin(lunatime.tick() * 0.02) * 0.3
	end
	
	if data.state == STATE_IDLE then
		if not cfg.flying then
			if lunatime.tick() % 14 < 7 then
				v.animationFrame = 0
			elseif lunatime.tick() % 14 < 15 then
				v.animationFrame = 1
			end
		else
			if lunatime.tick() % 14 < 7 then
				v.animationFrame = 0
			elseif lunatime.tick() % 14 < 15 then
				v.animationFrame = 1
			end
		end
		
		data.canRender = true
		
		data.waitTimer = data.waitTimer - 1
		data.lerpTimer = 0
		data.lerpTimer2 = 0
		data.msgOffset = -16
		data.alpha = 0
		
		if not settings.eventMsg then
			if Colliders.collide(data.col, player) and data.waitTimer <= 0 then
				data.waitTimer = 0
				data.state = STATE_TALK
				if data.canSFX and settings.message ~= 0 then
					if settings.useCustom then
						SFX.play(settings.messageCustom)
					else
						SFX.play("voicelines/"..settings.message..".ogg")
					end
					data.canSFX = false
				end
			end
		end
		
		if data.eventTalk == true then
			data.eventTimer = data.eventTimer + 1
			if data.eventTimer >= 15 then
				data.state = STATE_TALK
				data.waitTimer = 0
				if data.canSFX and settings.message ~= 0 then
					if settings.useCustom then
						SFX.play(settings.messageCustom)
					else
						SFX.play("voicelines/"..settings.message..".ogg")
					end
					data.canSFX = false
				end
			end
		end
	end
	
	if data.state == STATE_TALK then
		data.message = settings.text
		data.talkTimer = data.talkTimer + 1
		if data.talkTimer >= settings.msgduration then
			data.canRender = false
			data.eventTalk = false
			if settings.has2nd then
				data.state = STATE_TALK2
				resetVars(data)
				data.canRender = true
				if data.canSFX and settings.message2 ~= 0 then
					if settings.useCustom2 then
						SFX.play(settings.messageCustom2)
					else
						SFX.play("voicelines/"..settings.message2..".ogg")
					end
					data.canSFX = false
				end
			else
				if settings.alwaysTalk then
					data.state = STATE_IDLE
					resetVars(data)
				elseif not Colliders.collide(data.col, player) then
					data.state = STATE_IDLE
					resetVars(data)
				end
			end
		end
		
		if data.talkTimer < (settings.msgduration - 10) then
			data.lerpTimer = data.lerpTimer + 0.01
			--data.msgOffset = math.lerp(data.msgOffset, 0, data.lerpTimer)
			data.alpha = math.lerp(data.alpha, 1, data.lerpTimer)
		elseif data.talkTimer >= (settings.msgduration - 10) then
			data.lerpTimer2 = data.lerpTimer2 + 0.03
			--data.msgOffset = math.lerp(data.msgOffset, 16, data.lerpTimer2)
			data.alpha = math.lerp(data.alpha, 0, data.lerpTimer2)
		end
	end
	
	if data.state == STATE_TALK2 then
		data.message = settings.text2
		data.talkTimer = data.talkTimer + 1
		if data.talkTimer >= settings.msgduration then
			data.canRender = false
			data.eventTalk = false
			if settings.alwaysTalk then
				data.state = STATE_IDLE
				resetVars(data)
			elseif not Colliders.collide(data.col, player) then
				data.state = STATE_IDLE
				resetVars(data)
			end
		end
		
		if data.talkTimer < (settings.msgduration - 10) then
			data.lerpTimer = data.lerpTimer + 0.01
			--data.msgOffset = math.lerp(data.msgOffset, 0, data.lerpTimer2)
			data.alpha = math.lerp(data.alpha, 1, data.lerpTimer)
		elseif data.talkTimer >= (settings.msgduration - 10) then
			data.lerpTimer2 = data.lerpTimer2 + 0.03
			--data.msgOffset = math.lerp(data.msgOffset, 16, data.lerpTimer2)
			data.alpha = math.lerp(data.alpha, 0, data.lerpTimer2)
		end
	end
end

function talkingFlower.onDrawNPC(v)
	local data = v.data
	local settings = v.data._settings
	local cfg = NPC.config[v.id]
	
	--Text.print(data.state,0,0)
	
	if v.despawnTimer > 0 then
		if player.deathTimer == 40 then
			local random = RNG.randomInt(100,104)
			data.canSFX = true
			if data.canSFX then
				data.state = STATE_TALK
				SFX.play("voicelines/"..random..".ogg")
				if random == 100 then data.message = "Well then."
				elseif random == 101 then data.message = "Uh oh..."
				elseif random == 102 then data.message = "Aw..."
				elseif random == 103 then data.message = "You good?"
				elseif random == 104 then data.message = "Ah..."
				end
			end
			
			if cfg.flying then
				cfg.nogravity = true
				v.speedX = math.cos(lunatime.tick() * 0.04) * 0.3
				v.speedY = math.sin(lunatime.tick() * 0.02) * 0.3
			end
		end
	end
	
	if data.state == STATE_TALK or data.state == STATE_TALK2 then
		if player.deathTimer >= 40 then
			data.talkTimer = data.talkTimer + 1
			if data.talkTimer >= settings.msgduration then
				data.canRender = false
				if not Colliders.collide(data.col, player) then
					data.state = STATE_IDLE
					data.talkTimer = 0
					data.waitTimer = settings.cooldown
					data.canSFX = true
				end
			end
		end
		
		main = Sprite.box{
			texture = tbubb,
			x = v.x + (v.width / 2),
			y = v.y - 46 - 8 - data.msgOffset,
			width = 16 + (16 * #data.message),
			pivot = {0.5,0.5},
			color = Color.white ..data.alpha
		}
		
		left = Sprite.box{
			texture = tbubbL,
			x = v.x - (8 * #data.message) - 8,
			y = v.y - 46 - 8 - data.msgOffset,
			width = 16,
			pivot = {0,0.5},
			color = Color.white ..data.alpha
		}
		
		right = Sprite.box{
			texture = tbubbR,
			x = v.x + (8 * #data.message) + 24,
			y = v.y - 46 - 8 - data.msgOffset,
			width = 16,
			pivot = {0,0.5},
			color = Color.white ..data.alpha
		}
		
		pointer = Sprite.box{
			texture = tbubbPoint,
			x = v.x + (v.width / 2),
			y = v.y - 48 + 16 - data.msgOffset,
			width = 32,
			pivot = {0.5,0.5},
			color = Color.white ..data.alpha
		}
		
		if data.canRender then
			if not cfg.flying then
				if lunatime.tick() % 54 < 7 then
					v.animationFrame = 2
				elseif lunatime.tick() % 54 < 15 then
					v.animationFrame = 3
				elseif lunatime.tick() % 54 < 25 then
					v.animationFrame = 4
				elseif lunatime.tick() % 54 < 35 then
					v.animationFrame = 5
				elseif lunatime.tick() % 54 < 45 then
					v.animationFrame = 6
				elseif lunatime.tick() % 54 < 55 then
					v.animationFrame = 7
				elseif lunatime.tick() % 54 < 65 then
					v.animationFrame = 8
				elseif lunatime.tick() % 54 < 75 then
					v.animationFrame = 9
				end 
			else
				if lunatime.tick() % 14 < 7 then
					v.animationFrame = 2
				elseif lunatime.tick() % 14 < 15 then
					v.animationFrame = 3
				end
			end
			
			if player.deathTimer < 40 then
				main:draw{sceneCoords=true}
				left:draw{sceneCoords=true}
				right:draw{sceneCoords=true}
				pointer:draw{sceneCoords=true}
			else
				main:draw{sceneCoords=true, priority = -1, color=Color.white ..data.alpha}
				left:draw{sceneCoords=true, priority = -1, color=Color.white ..data.alpha}
				right:draw{sceneCoords=true, priority = -1, color=Color.white ..data.alpha}
				pointer:draw{sceneCoords=true, priority = -1, color=Color.white ..data.alpha}
			end
			
			textplus.print{
				x = v.x + (v.width / 2),
				y = v.y - 44 - 8 - data.msgOffset,
				text = data.message,
				sceneCoords = true,
				pivot = {0.5, 0.5},
				font = tfont,
				xscale = 1,
				yscale = 1,
				color = Color.black ..data.alpha,
			}
		else
			if not cfg.flying then
			if lunatime.tick() % 14 < 7 then
				v.animationFrame = 0
			elseif lunatime.tick() % 14 < 15 then
				v.animationFrame = 1
			end
			else
				if lunatime.tick() % 14 < 7 then
					v.animationFrame = 0
				elseif lunatime.tick() % 14 < 15 then
					v.animationFrame = 1
				end
			end
		end
	end
end

function talkingFlower.onEvent(n)
	for _,v in NPC.iterate(npcID) do
		local data = v.data
		local settings = v.data._settings
		
		if n == settings.eventName then
			if data.eventTalk == false then
				data.state = STATE_IDLE
				resetVars(data)
				data.eventTalk = true
			end
		end
	end 
end

--Gotta return the library table!
return talkingFlower