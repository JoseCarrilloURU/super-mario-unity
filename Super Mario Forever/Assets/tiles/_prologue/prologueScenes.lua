local smatrsPlayer = require("_scripts/smatrs_player")
local music = require("_scripts/smatrs_music")

local solidAfterimages = require("_scripts/solidAfterimages")
local littleDialogue = require("_scripts/littleDialogue")
local cutscenePal = require("_scripts/cutscenePal")
local general = require("_scripts/generalStuff")

local partners = require("_scripts/smatrs_partners")

local chapterIntro = require("_scripts/smatrs_chapterIntro")
local logoRendering = require("_scripts/smatrs_logoRendering")

local smatrsCamera = require("_scripts/smatrs_camera")
local handycam = require("handycam")
local easing = require("ext/easing")

local loadscreenLevel = require("_scripts/smatrs_loadscreenLevel")

local languageFiles = require("_scripts/languageFiles")

local playerTeleportation = require("_scripts/smatrs_playerTeleportation")

local prologueScenes = {}


prologueScenes.houseMusic = "_music/Mario's House.ogg"


local function cameraCentreToPos()
    local x,y = handycam[1]:screenToWorld(camera.width*0.5,camera.height*0.5)

    return vector(x,y)
end


-- Mario's House / Toad Town
-- Originally one cutscene, but split into two, hence why they share so much
do
    prologueScenes.houseScene = cutscenePal.newScene("prologueHouse")
    prologueScenes.houseScene.canSkip = true

    prologueScenes.townScene = cutscenePal.newScene("prologueTown")
    prologueScenes.townScene.canSkip = true

    local sceneLanguageFile = languageFiles("cutscenes/prologueHouse")

    local marioSpawnPos = vector(-139680 + 16 + 2,-140128 - 4)
    local luigiSpawnPos = vector(-139328 + 32,-140128)
    local parakarrySpawnPos = vector(-139360 + 96,-140672 + 24)

    local marioPrePipeX = -138976 + 16
    local luigiPrePipeX = marioPrePipeX - 64

    local pipeEnterPos = vector(-138912 + 32,-140192)
    local pipeExitPos = vector(-201568 + 32,-200352)

    local playerEndPos = vector(-201408 - 80,-200288)


    local function spawnMario(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueHouse/mario.png")
        smatrsPlayer.setUpPlayerActor(actor)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},

            rest = {1, defaultFrameX = 2},
            wake = {2,3,4,5,6, defaultFrameX = 2,frameDelay = 6,loops = false},

            letterPrepare = {1, defaultFrameX = 3},
            letterHold = {2, defaultFrameX = 3},

            jump = {1,2, defaultFrameX = 4,frameDelay = 4,loops = false},
            fall = {3,4, defaultFrameX = 4,frameDelay = 4,loops = false},

            talk = {1,2,3,4, defaultFrameX = 5,frameDelay = 8},

            frontFacing = {1, defaultFrameX = 6},
            ouch = {3, defaultFrameX = 6},

            walk = {1,2,3,4,5,6, defaultFrameX = 7,frameDelay = 4.5},

            victory = {1,2,3,4, defaultFrameX = 8,frameDelay = 6,loops = false},
        },startAnimation = "rest"}

        scene.data.marioActor = actor
        return actor
    end

    local function spawnLuigi(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueHouse/luigi.png")
        actor.spriteOffset = vector(0,22)
        actor:setSize(24,54)
        actor:setFrameSize(100,100)

        actor:setUpAnimator{animationSet = {
            lineIdle = {1,2,3,2, defaultFrameX = 1,frameDelay = 12},
            lineLookUp = {4, defaultFrameX = 1},
            lineLook = {5, defaultFrameX = 1},

            walk = {1,2,3,4,5,6, defaultFrameX = 2,frameDelay = 4.5},

            turn = {1,2,3,4,5, defaultFrameX = 3,frameDelay = 16,loops = false},
            frontFacing = {3, defaultFrameX = 3},
            idle = {1, defaultFrameX = 3},

            jump = {1,2, defaultFrameX = 4,frameDelay = 4,loops = false},
            fall = {3,4, defaultFrameX = 4,frameDelay = 4,loops = false},

            tripFall = {1, defaultFrameX = 5},
            tripLand = {2,3, defaultFrameX = 5,frameDelay = 8,loops = false},
        },startAnimation = "lineIdle"}

        scene.data.luigiActor = actor
        return actor
    end

    local function spawnParakarry(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueHouse/parakarry.png")
        actor:setSize(32,64)
        actor:setFrameSize(100,100)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},
            talk = {1,2,3,4, defaultFrameX = 2,frameDelay = 12},
            throwFormer = {1,2, defaultFrameX = 3,frameDelay = 12,loops = false},
            throwLatter = {3,4, defaultFrameX = 3,frameDelay = 12,loops = false},
        },startAnimation = "idle"}

        actor.data.floatTimer = 0

        function actor:updateFunc()
            self.spriteOffset.y = math.sin(self.data.floatTimer/48*math.pi*2)*4 + 18
            self.data.floatTimer = self.data.floatTimer + 1
        end

        --actor.debug = true

        scene.data.parakarryActor = actor
        return actor
    end


    local function getLetterRotation(actor)
        return math.deg(math.atan2(actor.speedY,actor.speedX))
    end

    local function spawnLetter(scene)
        local parakarry = scene.data.parakarryActor
        local mario = scene.data.marioActor

        local letter = scene:spawnChildActor(parakarry.x - 16,parakarry.y + parakarry.height*0.5 + 12)
        scene.data.letterActor = letter

        local maxSpeed = 4
        
        letter.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueHouse/letter.png")
        letter.spritePivot = vector(0.5,0.5)

        letter.speedX = -maxSpeed
        letter.speedY = -2

        letter.gravity = 0.07
        letter.terminalVelocity = 1.2

        letter.spriteRotation = getLetterRotation(letter)

        function letter:updateFunc()
            local direction = math.sign((mario.x + mario.width*0.5) - (letter.x + letter.width*0.5))

            letter.speedX = math.clamp(letter.speedX + direction*0.1,-maxSpeed,maxSpeed)
            letter.spriteRotation = getLetterRotation(letter)
        end

        return letter
    end


    local function screenLetterMove(scene,easeFunc,duration,newX,newY,newRotation,newOpacity)
        local startX = scene.data.screenLetterX
        local startY = scene.data.screenLetterY
        local startRotation = scene.data.screenLetterRotation
        local startOpacity = scene.data.screenLetterOpacity

        local timer = 0

        while (timer < duration) do
            timer = timer + 1

            scene.data.screenLetterX = easeFunc(timer,startX,newX - startX,duration)
            scene.data.screenLetterY = easeFunc(timer,startY,newY - startY,duration)
            scene.data.screenLetterRotation = easeFunc(timer,startRotation,newRotation - startRotation,duration)
            scene.data.screenLetterOpacity = math.lerp(startOpacity,newOpacity,timer/duration)

            Routine.skip()
        end
    end


    local function marioWalkRoutine(scene,mario)
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.5,
            targets = {mario},zoom = 1,
        }

        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/lets-a-go3"))

        mario:walkAndWait{
            goal = marioPrePipeX,speed = 2,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 0.75,
            stopAnimation = "idle",
        }
    end

    local function luigiWalkRoutine(scene,luigi)
        Routine.wait(1.5)
            
        luigi:setAnimation("turn")
        luigi:waitUntilAnimationFinished()

        luigi:walkAndWait{
            goal = luigi.x + luigi.width*0.5 + 64,speed = 2,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 0.75,
        }

        -- Trip...
        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/wah1"))
        
        luigi:jumpAndWait{
            riseAnimation = "tripFall",landAnimation = "tripLand",
            speedX = 2,speedY = -5,
        }
        general.spawnLandingDust(luigi.x + luigi.width*0.5 + 8,luigi.y + luigi.height)
        SFX.play(Misc.resolveSoundFile("bowlingball"))

        while (math.abs(luigi.speedX) > 0.25) do
            luigi.speedX = luigi.speedX*0.95
            Routine.skip()
        end

        luigi.speedX = 0
        Routine.wait(0.5)

        -- Jump back up
        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/yah2"))

        luigi:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            speedX = 0,speedY = -8,resetSpeed = true,
        }
        general.spawnLandingDust(luigi.x + luigi.width*0.5,luigi.y + luigi.height)

        Routine.wait(0.25)

        -- Go!!!
        luigi:walkAndWait{
            goal = marioPrePipeX,speed = 3,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 1,
            stopAnimation = "idle",
        }
    end


    local function enterPipeRoutine(scene,actor)
        -- Set up properties to go down
        actor:setAnimation("frontFacing")

        actor.priority = -76

        actor.useAutoFloor = false
        actor.gravity = 0
        actor.terminalVelocity = 0

        SFX.play(17)
        general.actorEasedMove(actor, easing.inQuad,48, actor.centre.x,actor.y + actor.height + 64)


        --[[actor.speedY = 1.5

        -- Play a sound
        SFX.play(17)

        -- Wait...
        Routine.wait(1.1/math.abs(actor.speedY))

        actor.speedY = 0]]
    end

    local function exitPipeRoutine(scene,actor,goalY)
        -- Set up properties to go down
        actor:setAnimation("frontFacing")

        actor.priority = -76

        actor.useAutoFloor = false
        actor.gravity = 0
        actor.terminalVelocity = 0

        SFX.play(17)
        general.actorEasedMove(actor, easing.outQuad,48, actor.centre.x,goalY)
    end


    prologueScenes.houseScene.mainRoutineFunc = function(scene)
        -- Create actors
        local mario = spawnMario(scene,marioSpawnPos.x,marioSpawnPos.y)
        local luigi = spawnLuigi(scene,luigiSpawnPos.x,luigiSpawnPos.y)
        local parakarry = spawnParakarry(scene,parakarrySpawnPos.x,parakarrySpawnPos.y)

        luigi.direction = DIR_LEFT

        -- Set up some other stuff
        scene.data.screenLetterImage = Graphics.loadImageResolved("_graphics/cutscenes/prologueHouse/screenLetter.png")
        scene.data.screenLetterX = 0
        scene.data.screenLetterY = 0
        scene.data.screenLetterOpacity = 0
        scene.data.screenLetterRotation = 0

        general.initSceneSpotlight(scene)
        general.initSceneFade(scene)
        scene.data.fadeOpacity = 1
        scene.barsEnterProgress = 1
        scene.canSkip = false

        smatrsCamera.startCutsceneCamera()
        handycam[1].targets = {mario}
        handycam[1].xOffset = 64

        scene:setPlayerIsInactive(true)
        player.section = 3

        -- Fade in
        Routine.wait(1)

        music.forcedMusicPath = "_music/Mario's House.ogg"
        music.volumeModifier = 0
        music.forceMute = false
        music.preventMusicNameUpdate = true

        scene:runChildRoutine(general.fadeInMusic, 128)
        general.transitionSceneFadeOpacity(scene,128,0)

        music.preventMusicNameUpdate = false
        scene.canSkip = true

        ---    Mail Delivery    ---
        -- Parakarry flies down
        Routine.wait(3)

        parakarry.speedX = -3
        parakarry.speedY = 11

        while (math.abs(parakarry.speedX) > 0) do
            parakarry.speedX = general.approach(parakarry.speedX,0,math.max(0.03,math.abs(parakarry.speedX)*0.01))
            parakarry.speedY = general.approach(parakarry.speedY,0,math.max(0.05,math.abs(parakarry.speedY)*0.03))
            Routine.skip()
        end

        parakarry.speedX = 0
        parakarry.speedY = 0

        -- Mail call!
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.5,
            targets = {mario,parakarry},zoom = 1.25,
        }

        parakarry:setAnimation("talk")
        parakarry:talkAndWait{text = sceneLanguageFile.parakarry}
        parakarry:setAnimation("idle")

        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/huh1"))

        mario:setAnimation("wake")
        mario:waitUntilAnimationFinished()

        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/huh"))
        luigi:setAnimation("lineLookUp")

        -- Throw letter
        parakarry:setAnimation("throwFormer")
        parakarry:waitUntilAnimationFinished()

        local letter = spawnLetter(scene)

        parakarry:setAnimation("throwLatter")
        parakarry:waitUntilAnimationFinished()
        parakarry:setAnimation("idle")

        -- Parakarry flies off
        scene:runChildRoutine(function()
            Routine.wait(0.25)
            
            while (parakarry.y > parakarrySpawnPos.y) do
                parakarry.speedX = parakarry.speedX - 0.1
                parakarry.speedY = parakarry.speedY - 0.1
                Routine.skip()
            end

            parakarry:remove()
        end)

        handycam[1].targets = {cameraCentreToPos()}
        handycam[1].xOffset = 0
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 2,
            targets = {vector(mario.x + mario.width*0.5 + 192,mario.y + mario.height*0.5)},zoom = 1.5,
        }

        -- Mario catches the letter
        while (not mario:collidesWithActor(letter,16)) do
            Routine.skip()
        end

        mario:setAnimation("letterPrepare")
        luigi:setAnimation("lineLook")
        
        while (not mario:collidesWithActor(letter,0)) do
            Routine.skip()
        end

        mario:setAnimation("letterHold")
        letter:remove()


        ---    Letter appears on screen    ---
        SFX.play(Misc.resolveSoundFile("_sound/misc/letter"))

        -- Move in
        scene.data.screenLetterX = -16
        scene.data.screenLetterY = 160
        scene.data.screenLetterRotation = 25
        scene.data.screenLetterOpacity = 0

        screenLetterMove(scene, easing.outSine,48, 0,0,-5,1)

        -- Wait for input
        while (player.rawKeys.jump ~= KEYS_PRESSED and player.rawKeys.run ~= KEYS_PRESSED) do
            Routine.skip()
        end

        -- Move out
        screenLetterMove(scene, easing.inSine,32, -16,-128,-25,0)

        Routine.wait(0.5)


        ---    OKAY LUIGI, LETS GET OUTTA HERE.    ---
        -- Mario jumps
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/yah"))

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {mario.centre + vector(96,0),luigi.centre},zoom = 1.25,
        }

        mario.useAutoFloor = true
        mario.gravity = 0.4
        mario.terminalVelocity = 12

        mario:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            speedX = 1.75,speedY = -11,resetSpeed = true,
        }
        general.spawnLandingDust(mario.x + mario.width*0.5,mario.y + mario.height)

        Routine.wait(0.25)

        -- Mario talks to Luigi
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/talking5"))

        mario:setAnimation("talk")
        Routine.wait(0.5)

        luigi:setAnimation("idle")
        Routine.wait(1.5)

        mario:setAnimation("idle")
        Routine.wait(0.5)

        -- Luigi jumps up
        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/yah1"))

        luigi.gravity = 0.35
        luigi.terminalVelocity = 10
        luigi.useAutoFloor = true

        luigi:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            speedX = 0,speedY = -7,resetSpeed = true,
        }
        general.spawnLandingDust(luigi.x + luigi.width*0.5,luigi.y + luigi.height)

        Routine.wait(0.4)

        -- Ippy!
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/ippy"))
        mario:setAnimation("victory")

        Routine.wait(1.25)

        -- Brothers walk to the pipe
        local luigiWalkRoutineObj = scene:runChildRoutine(luigiWalkRoutine, scene,luigi)

        marioWalkRoutine(scene,mario)

        Routine.wait(0.5)

        -- Mario jumps in
        SFX.play(1)
        
        mario:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            goalX = pipeEnterPos.x,goalY = pipeEnterPos.y,resetSpeed = true,
        }
        general.spawnLandingDust(mario.x + mario.width*0.5,mario.y + mario.height)

        -- Luigi walks forward
        --[[luigi:walkAndWait{
            goal = marioPrePipeX,speed = 2,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 0.75,
            stopAnimation = "idle",
        }]]

        -- Mario goes in
        Routine.wait(0.25)
        scene:runChildRoutine(enterPipeRoutine, scene,mario)

        -- Luigi jumps in
        while (luigiWalkRoutineObj.isValid) do
            Routine.skip()
        end

        SFX.play(1)
        
        luigi:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            goalX = pipeEnterPos.x,goalY = pipeEnterPos.y,resetSpeed = true,
        }
        general.spawnLandingDust(luigi.x + luigi.width*0.5,luigi.y + luigi.height)
        
        -- Luigi goes in
        Routine.wait(0.25)
        enterPipeRoutine(scene,luigi)


        -- Spotlight closes
        Routine.wait(0.25)

        scene.data.spotlightCentre = vector(pipeEnterPos.x,pipeEnterPos.y + 16)
        scene.data.spotlightRadius = 768

        scene:runChildRoutine(general.fadeOutMusic, 64,true)
        general.transitionSceneSpotlight(scene, easing.outSine,80, scene.data.spotlightCentre,0,1)

        Routine.wait(0.5)
    end

    prologueScenes.houseScene.drawFunc = function(scene)
        if scene.data.screenLetterOpacity > 0 then
            Graphics.drawScreen{
                color = Color.black.. scene.data.screenLetterOpacity*0.5,
                priority = 3,
            }

            Graphics.drawBox{
                texture = scene.data.screenLetterImage,centred = true,priority = 4,
                color = Color.white.. scene.data.screenLetterOpacity,

                x = camera.width*0.5 + scene.data.screenLetterX,
                y = camera.height*0.5 + scene.data.screenLetterY,
                rotation = scene.data.screenLetterRotation,
            }
        end

        general.drawSceneSpotlight(scene)
        general.drawSceneFade(scene)
    end

    prologueScenes.houseScene.stopFunc = function(scene)
        handycam[1]:release()

        music.forcedMusicPath = ""
        music.volumeModifier = 1
        music.forceMute = false

        -- Start castle scene
        prologueScenes.castleScene:start()
    end


    prologueScenes.townScene.mainRoutineFunc = function(scene)
        -- Create actors
        local mario = spawnMario(scene,marioSpawnPos.x,marioSpawnPos.y)
        local luigi = spawnLuigi(scene,luigiSpawnPos.x,luigiSpawnPos.y)

        -- Set up some other stuff
        scene.data.exitPipeLayer = Layer.get("exit pipe")

        general.initSceneSpotlight(scene)
        scene.data.spotlightOpacity = 1
        
        music.forceMute = true

        playerTeleportation.dematerialise{instant = true}
        smatrsPlayer.generalSettings.mostlyIgnoreSecondPlayer = true


        player:teleport(playerEndPos.x,playerEndPos.y,true)
        player.direction = DIR_RIGHT
        scene:setPlayerIsInactive(true)


        ---    TOAD TOWN!!!    ---
        player:teleport(playerEndPos.x,playerEndPos.y,true)
        smatrsCamera.startCutsceneCamera()
        handycam[1]:reset()

        -- Luigi partner
        local luigiPartner = partners.create("luigi",player,false)

        scene.data.luigiPartner = luigiPartner
        luigiPartner.inactive = true


        Routine.wait(0.5)

        -- Spotlight opens slightly
        scene.data.spotlightCentre = vector(pipeExitPos.x,pipeExitPos.y - 32)

        SFX.play(Misc.resolveSoundFile("_sound/misc/spotlight_in"))
        general.transitionSceneSpotlight(scene, easing.outSine,24, scene.data.spotlightCentre,80,1)

        Routine.wait(0.25)

        -- Mario exits from pipe
        mario.bottomCentre = pipeExitPos + vector(0,64)
        mario.direction = DIR_RIGHT

        exitPipeRoutine(scene,mario,pipeExitPos.y)
        mario:setAnimation("idle")
        Routine.wait(1)

        -- Spotlight opens fully
        SFX.play(Misc.resolveSoundFile("_sound/misc/spotlight_finish"))
        general.transitionSceneSpotlight(scene, easing.inSine,64, scene.data.spotlightCentre,512,0)

        music.forceMute = false

        Routine.wait(0.25)


        -- Mario jumps down
        mario.floorY = playerEndPos.y

        mario.gravity = 0.4
        mario.terminalVelocity = 12

        SFX.play(1)
        mario:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            goalX = playerEndPos.x + 32,goalY = playerEndPos.y,speedPerBlock = 0.6,resetSpeed = true,
        }
        general.spawnLandingDust(mario.x + mario.width*0.5,mario.y + mario.height)

        Routine.wait(0.5)
        mario.direction = DIR_LEFT

        -- Luigi exits the pipe
        luigi.bottomCentre = pipeExitPos + vector(0,64)
        luigi.direction = DIR_RIGHT

        exitPipeRoutine(scene,luigi,pipeExitPos.y)
        luigi:setAnimation("idle")

        Routine.wait(1)

        -- Pipe lowers (with Luigi on it!)
        scene.data.exitPipeLayer.speedY = 2
        SFX.play(Misc.resolveSoundFile("_sound/misc/pipeRetract"))
        
        luigi.floorY = mario.floorY
        luigi.gravity = 0.35
        luigi.terminalVelocity = 10
        
        luigi:jumpAndWait{
            riseAnimation = "tripFall",landAnimation = "tripLand",
            speedX = 0,speedY = -5,
        }
        general.spawnLandingDust(luigi.x + luigi.width*0.5 + 8,luigi.y + luigi.height)

        SFX.play(Misc.resolveSoundFile("bowlingball"))
        Defines.earthquake = 3

        -- Mario reacts to Luigi's unfortunate fate
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/eek"),0.75)

        mario:setAnimation("ouch")
        Routine.wait(0.75)

        mario:walkAndWait{
            goal = playerEndPos.x,speed = 1.5,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 0.5,
            stopAnimation = "idle",
        }

        Routine.wait(1)

        -- Luigi jump back up
        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/yah1"))

        luigi:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            speedX = 0,speedY = -8,resetSpeed = true,
        }
        general.spawnLandingDust(luigi.x + luigi.width*0.5,luigi.y + luigi.height)

        Routine.wait(0.25)

        -- Okay, let's go
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/lets-a-go2"),0.75)

        mario:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            speedX = 0,speedY = -7,resetSpeed = true,
        }
        general.spawnLandingDust(mario.x + mario.width*0.5,mario.y + mario.height)

        Routine.wait(0.5)

        -- Turn around
        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/okidoki"),0.75)

        scene:setPlayerIsInactive(false)
        player.direction = DIR_RIGHT
        mario:remove()

        smatrsCamera.stopCutsceneCamera(1)
        Routine.wait(1)
    end

    prologueScenes.townScene.drawFunc = function(scene)
        general.drawSceneSpotlight(scene)
    end

    prologueScenes.townScene.skipRoutineFunc = function(scene)
        smatrsCamera.stopCutsceneCamera(0)
        scene:setPlayerIsInactive(false)
    end

    prologueScenes.townScene.stopFunc = function(scene)
        scene.data.exitPipeLayer:hide(true)
        scene.data.exitPipeLayer.speedY = 0

        scene.data.luigiPartner:resetFollowHistory()
        scene.data.luigiPartner.inactive = false

        player:teleport(playerEndPos.x,playerEndPos.y,true)
        player.direction = DIR_RIGHT

        music.forceMute = false
    end
end


-- Bowser's castle
do
    prologueScenes.castleScene = cutscenePal.newScene("prologueCastle")
    prologueScenes.castleScene.canSkip = true

    local sceneLanguageFile = languageFiles("cutscenes/prologueCastle")


    local bowserSpawnPos = vector(-118624 + 96,-120160)
    local kamekSpawnPos = vector(-120064,-120288 + 16)

    local kamekFlyX = -119040 + 16 + 128
    local kamekTeleportX = -119040 + 16 + 32

    local tobeSpawnPos = vector(kamekTeleportX + 32 + 64,kamekSpawnPos.y + 48)
    local voltombSpawnPos = vector(kamekTeleportX + 32 + 128,kamekSpawnPos.y)
    local goombooterSpawnPos = vector(kamekTeleportX + 32 + 192,kamekSpawnPos.y)


    local function createBowser(scene)
        local actor = scene:spawnChildActor(bowserSpawnPos.x,bowserSpawnPos.y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCastle/bowser.png")
        actor:setSize(128,128)
        actor:setFrameSize(172,160)

        actor.imageDirection = DIR_LEFT
        actor.direction = DIR_LEFT

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 16},
            laugh = {1,2,3,4, defaultFrameX = 2,frameDelay = 4},
            point = {1,2, defaultFrameX = 3,frameDelay = 8,loops = false},
		    angry = {3,4, defaultFrameX = 3,frameDelay = 6},
        },startAnimation = "idle"}

        --actor.debug = true

        scene.data.bowserActor = actor
        return actor
    end

    local function createKamek(scene)
        local actor = scene:spawnChildActor(kamekSpawnPos.x,kamekSpawnPos.y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCastle/kamek.png")
        actor:setSize(64,32)
        actor:setFrameSize(104,64)

        actor.imageDirection = DIR_RIGHT
        actor.direction = DIR_RIGHT

        actor:setUpAnimator{animationSet = {
            fly = {1,2, defaultFrameX = 1,frameDelay = 8},
            idle = {1, defaultFrameX = 2},
            wand = {1, defaultFrameX = 3},
            confused = {1, defaultFrameX = 4},
        },startAnimation = "idle"}

        --actor.debug = true

        actor.data.floatTimer = 0

        function actor:updateFunc()
            self.spriteOffset.y = math.sin(self.data.floatTimer/24)*6 + 8
            self.data.floatTimer = self.data.floatTimer + 1
        end

        scene.data.kamekActor = actor
        return actor
    end


    local function createTobe(scene)
        local actor = scene:spawnChildActor(tobeSpawnPos.x,tobeSpawnPos.y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCastle/tobe.png")
        actor.spriteOffset.y = 12
        actor:setSize(40,40)
        actor:setFrameSize(68,96)

        actor.imageDirection = DIR_RIGHT
        actor.direction = DIR_RIGHT

        actor:setUpAnimator{animationSet = {
            idle = {1,1,2,1,3,4, defaultFrameX = 1,frameDelay = 16},
            smug = {1, defaultFrameX = 2},
        },startAnimation = "idle"}

        actor.isInvisible = true
        actor.isFrozen = true

        actor.data.floatTimer = 0

        function actor:updateFunc()
            if self.isFrozen then
                return
            end

            self.spriteOffset.y = math.sin(self.data.floatTimer/20)*6 + 12
            self.data.floatTimer = self.data.floatTimer + 1
        end

        --actor.debug = true

        scene.data.tobeActor = actor
        return actor
    end

    local function createVoltomb(scene)
        local actor = scene:spawnChildActor(voltombSpawnPos.x,voltombSpawnPos.y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCastle/voltomb.png")
        actor.spriteOffset.y = 8
        actor:setSize(32,32)
        actor:setFrameSize(72,58)

        actor.imageDirection = DIR_RIGHT
        actor.direction = DIR_RIGHT

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},
            fall = {1,2,3, defaultFrameX = 2,frameDelay = 6},
        },startAnimation = "idle"}

        actor.isInvisible = true
        actor.isFrozen = true

        --actor.debug = true

        scene.data.voltombActor = actor
        return actor
    end

    local function createGoombooter(scene)
        local actor = scene:spawnChildActor(goombooterSpawnPos.x,goombooterSpawnPos.y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCastle/goombooter.png")
        actor.spriteOffset.y = 2
        actor:setSize(32,32)
        actor:setFrameSize(62,46)

        actor.imageDirection = DIR_RIGHT
        actor.direction = DIR_RIGHT

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3, defaultFrameX = 1,frameDelay = 12},
            confused = {1,2,3, defaultFrameX = 2,frameDelay = 12},
            angry = {1,2,3, defaultFrameX = 3,frameDelay = 12},
            jump = {1, defaultFrameX = 4},
            fall = {2, defaultFrameX = 4},
            ouch = {3, defaultFrameX = 4},
        },startAnimation = "idle"}

        actor:setAnimation("confused")
        actor.isInvisible = true
        actor.isFrozen = true

        --actor.debug = true

        scene.data.goombooterActor = actor
        return actor
    end



    local function spawnMagicActor(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCastle/magic.png")
        actor:setSize(32,32)
        actor:setFrameSize(32,32)

        actor.y = actor.y + actor.height*0.5

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4,5,6,7,8,9,10,11,12, defaultFrameX = 1,frameDelay = 2},
        },startAnimation = "idle"}

        actor.color.a = 0

        -- Spawn magic effects
        actor.data.effectTimer = 0

        function actor:updateFunc()
            self.data.effectTimer = self.data.effectTimer + 1

            if self.data.effectTimer >= 2 then
                local e = Effect.spawn(80,self.x + RNG.random(0,self.width),self.y + RNG.random(0,self.height))

                self.data.effectTimer = 0
            end
        end


        return actor
    end

    local function lackeySummonRoutine(scene,actor)
        -- Slowly fade in
        local magic = spawnMagicActor(scene,actor.x + actor.width*0.5,actor.y + actor.height*0.5)

        general.changeActorOpacity(magic,1,0.05)

        actor.isInvisible = false
        actor.color.a = 0

        general.changeActorOpacity(actor,1,0.05)

        general.changeActorOpacity(magic,0,0.1)
        magic:remove()

        Routine.wait(1)

        -- Fall!
        actor.isFrozen = false

        if actor == scene.data.goombooterActor then
            SFX.play(Misc.resolveSoundFile("_sound/misc/boss-fall"))
            actor:setAnimation("ouch")

            actor.useAutoFloor = true
            actor.gravity = 0.26
            actor.terminalVelocity = 8

            while (not actor.isOnFloor) do
                Routine.skip()
            end

            general.spawnLandingDust(actor.x + actor.width*0.5,actor.y + actor.height)
            SFX.play(Misc.resolveSoundFile("bowlingball"))
            Defines.earthquake = 5
        elseif actor == scene.data.voltombActor then
            SFX.play(Misc.resolveSoundFile("_sound/misc/boss-fall"))
            actor:setAnimation("fall")

            actor.useAutoFloor = true
            actor.gravity = 0.26
            actor.terminalVelocity = 8

            while (not actor.isOnFloor) do
                Routine.skip()
            end

            general.spawnLandingDust(actor.x + actor.width*0.5,actor.y + actor.height)
            actor:setAnimation("idle")
        end
    end

    local function lackeyDisappearRoutine(scene,actor)
        -- Slowly fade in
        local magic = spawnMagicActor(scene,actor.x + actor.width*0.5,actor.y + actor.height*0.5)

        general.changeActorOpacity(magic,1,0.05)
        general.changeActorOpacity(actor,0,0.05)
        general.changeActorOpacity(magic,0,0.1)

        actor.isInvisible = true
        actor.isFrozen = true
        magic:remove()
    end


    prologueScenes.castleScene.mainRoutineFunc = function(scene)
        -- Set up stuff
        general.initSceneSpotlight(scene)
        general.initSceneFade(scene)

        scene.data.fadeColor = Color.black
        scene.data.fadeOpacity = 1

        scene:setPlayerIsInactive(true)


        ---    ESTABLISHING SHOT    ---
        -- Set up stuff
        music.forceMute = true

        player.section = 6

        local bounds = player.sectionObj.boundary
        
        smatrsCamera.startCutsceneCamera()
        handycam[1].targets = {vector((bounds.left + bounds.right)*0.5,(bounds.top + bounds.bottom)*0.5)}
        handycam[1].zoom = 1

        Routine.wait(0.75)

        -- Fade in
        scene:runChildRoutine(general.fadeInMusic, 48)
        general.transitionSceneFadeOpacity(scene,32,0)

        music.forcedMusicPath = "_music/Bowser's Theme.ogg"
        music.volumeModifier = 1
        music.forceMute = false

        -- Zoom in
        Routine.wait(2)

        handycam[1]:transition{
            ease = handycam.ease(easing.inQuad),time = 2.5,
            zoom = 2,
        }

        Routine.wait(2)

        -- Fade out
        general.transitionSceneFadeOpacity(scene,32,1)


        ---    KAMEK TALKS TO BOWSER.    ---
        -- Create actors
        local bowser = createBowser(scene)
        local kamek = createKamek(scene)

        local tobe = createTobe(scene)
        local voltomb = createVoltomb(scene)
        local goombooter = createGoombooter(scene)

        handycam[1].targets = {kamek.centre}
        handycam[1].zoom = 1

        player.section = 4

        -- Fade in
        Routine.wait(0.5)

        general.transitionSceneFadeOpacity(scene,32,0)

        music.forcedMusicPath = "_music/Bowser's Theme.ogg"
        music.volumeModifier = 1
        music.forceMute = false

        -- Kamek flies in
        scene:runChildRoutine(function()
            kamek:walkAndWait{
                goal = kamekFlyX,speed = 3,
                --goal = kamekFlyX,speed = 20,
                walkAnimation = "fly",
                stopAnimation = "idle",
            }
        end)

        -- Camera movement
        Routine.wait(2)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 4,
            targets = {bowser.centre - vector(192,0)},zoom = 1.25,
        }
        cutscenePal.waitUntilTransitionFinished()

        -- Conversation!
        SFX.play(Misc.resolveSoundFile("_sound/voice/kamek/ihihihi"))
        kamek:talkAndWait{text = sceneLanguageFile.kamek1}
        SFX.play(Misc.resolveSoundFile("_sound/voice/bowser/dah"))
        bowser:talkAndWait{text = sceneLanguageFile.bowser1}
        kamek:talkAndWait{text = sceneLanguageFile.kamek2}
        bowser:talkAndWait{text = sceneLanguageFile.bowser2}

        -- Bowser laughs
        SFX.play(Misc.resolveSoundFile("_sound/voice/bowser/bwahahahahaha"))
        bowser:setAnimation("laugh")

        Routine.wait(3)
        bowser:setAnimation("idle")

        -- More conversation
        kamek:talkAndWait{text = sceneLanguageFile.kamek3}
		bowser:setAnimation("angry")
        bowser:talkAndWait{text = sceneLanguageFile.bowser3}

        SFX.play(Misc.resolveSoundFile("_sound/voice/kamek/muu"))
        kamek:setAnimation("confused")
        kamek:talkAndWait{text = sceneLanguageFile.kamek4}
        kamek:setAnimation("idle")
		bowser:setAnimation("idle")
        bowser:talkAndWait{text = sceneLanguageFile.bowser4}

        -- Point!!
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 1,
            targets = {bowser},zoom = 2,yOffset = -28,
        }
        cutscenePal.waitUntilTransitionFinished()

        SFX.play(Misc.resolveSoundFile("_sound/voice/bowser/gawwwww"))
        bowser:setAnimation("point")
        bowser:talkAndWait{text = sceneLanguageFile.bowser5}


        ---    KAMEK TELEPORTS THOSE LACKEYS IN!!    ---
        -- Camera movement
        kamek.x = kamekTeleportX - kamek.width*0.5

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {bowser,kamek},zoom = 1.25,
        }
        cutscenePal.waitUntilTransitionFinished()
        Routine.wait(0.25)

        -- Kamek uses wand
        SFX.play(Misc.resolveSoundFile("_sound/misc/nsmbwiiKamekMagic"))
        kamek:setAnimation("wand")
        bowser:setAnimation("idle")

        scene:runChildRoutine(lackeySummonRoutine, scene,tobe)
        Routine.wait(0.5)
        scene:runChildRoutine(lackeySummonRoutine, scene,voltomb)
        Routine.wait(0.5)
        scene:runChildRoutine(lackeySummonRoutine, scene,goombooter)
        Routine.wait(3)

        kamek:setAnimation("idle")

        -- Goombooter... makes a complaint about his rights and wishes to form a worker's union
        SFX.play(1)
        goombooter:jumpAndWait{
            speedX = 0,speedY = -5,
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
        }
        general.spawnLandingDust(goombooter.x + goombooter.width*0.5,goombooter.y + goombooter.height)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {goombooter,voltomb,tobe},zoom = 2,yOffset = -16,
        }
        cutscenePal.waitUntilTransitionFinished()

        goombooter:talkAndWait{text = sceneLanguageFile.goombooter1}
        voltomb:talkAndWait{text = sceneLanguageFile.voltomb1}
		tobe:setAnimation("smug")
        tobe:talkAndWait{text = sceneLanguageFile.tobe1}

        -- Bowser responds
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.5,
            targets = {bowser,goombooter},zoom = 2,xOffset = -16,yOffset = 8,
        }
        cutscenePal.waitUntilTransitionFinished()

        SFX.play(Misc.resolveSoundFile("_sound/voice/bowser/gwahahahahaha"))
		tobe:setAnimation("idle")
        bowser:talkAndWait{text = sceneLanguageFile.bowser6}

        handycam[1]:transition{
            ease = handycam.ease(easing.outQuad),time = 0.25,
            xOffset = -64,
        }

        goombooter:setAnimation("angry")
        goombooter:talkAndWait{text = sceneLanguageFile.goombooter2}

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutQuad),time = 0.75,
            xOffset = -16,
        }

		bowser:setAnimation("angry")
        bowser:talkAndWait{text = sceneLanguageFile.bowser7}
		bowser:setAnimation("idle")
        bowser:talkAndWait{text = sceneLanguageFile.bowser8}

        -- Okay, maybe they'll consider it.
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {bowser,kamek},zoom = 1.25,xOffset = 0,yOffset = 0,
        }
        cutscenePal.waitUntilTransitionFinished()

        tobe:talkAndWait{text = sceneLanguageFile.tobe2}
        goombooter:setAnimation("idle")
        goombooter:talkAndWait{text = sceneLanguageFile.goombooter3}
        voltomb:talkAndWait{text = sceneLanguageFile.voltomb2}

        bowser:talkAndWait{text = sceneLanguageFile.bowser9}
        kamek:talkAndWait{text = sceneLanguageFile.kamek5}

        -- Trio is teleported away
        SFX.play(Misc.resolveSoundFile("_sound/misc/nsmbwiiKamekMagic"))
        kamek:setAnimation("wand")
        
        scene:runChildRoutine(lackeyDisappearRoutine, scene,tobe)
        Routine.wait(0.5)
        scene:runChildRoutine(lackeyDisappearRoutine, scene,voltomb)
        Routine.wait(0.5)
        scene:runChildRoutine(lackeyDisappearRoutine, scene,goombooter)
        Routine.wait(1.5)

        kamek:setAnimation("idle")

        -- Bowser laughs
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 1,
            targets = {bowser},zoom = 2,yOffset = -8,
        }
        
        SFX.play(Misc.resolveSoundFile("_sound/voice/bowser/bwahahahahaha"))
        bowser:setAnimation("laugh")
        
        Routine.wait(1)
        scene:runChildRoutine(general.fadeOutMusic, 64,true)
        Routine.wait(1)

        -- Fade out
        scene.data.spotlightCentre = bowser.centre
        scene.data.spotlightRadius = 768

        scene:runChildRoutine(general.fadeOutMusic, 128,true)
        general.transitionSceneSpotlight(scene, easing.outSine,128, scene.data.spotlightCentre,0,1)

        Routine.wait(0.5)
    end

    prologueScenes.castleScene.drawFunc = function(scene)
        general.drawSceneSpotlight(scene)
        general.drawSceneFade(scene)
    end

    prologueScenes.castleScene.stopFunc = function(scene)
        music.forcedMusicPath = ""
        music.volumeModifier = 1
        music.forceMute = false
        
        handycam[1]:release()

        prologueScenes.townScene:start()
    end
end


-- Peach's castle
do
    prologueScenes.boardScene = cutscenePal.newScene("prologueBoard")
    prologueScenes.boardScene.canSkip = false

    local sceneLanguageFile = languageFiles("cutscenes/prologueBoard")


    local playerWalkAwayX = -194816 + 16

    local doorSpawnPos = vector(-194368,-200288)

    local marioSpawnPos = vector(-194560 - 48,-200288)
    local luigiSpawnPos = vector(marioSpawnPos.x - 48,marioSpawnPos.y)

    local piloTSpawnPos = vector(-193184 + 16,-200352)
    local balloonSpawnPos = vector(-192992 + 16,-200352)


    local function spawnMario(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/mario.png")
        smatrsPlayer.setUpPlayerActor(actor)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},
            surprised = {5, defaultFrameX = 1},

            walk = {1,2,3,4,5,6, defaultFrameX = 2,frameDelay = 4.5},

            jump = {1,2, defaultFrameX = 3,frameDelay = 4,loops = false},
            fall = {3,4, defaultFrameX = 3,frameDelay = 4,loops = false},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.terminalVelocity = 12
        actor.gravity = 0.4

        scene.data.marioActor = actor
        return actor
    end

    local function spawnLuigi(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/luigi.png")
        actor.spriteOffset = vector(0,22)
        actor:setSize(24,54)
        actor:setFrameSize(100,100)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 14},
            surprised = {5, defaultFrameX = 1},

            walk = {1,2,3,4,5,6, defaultFrameX = 2,frameDelay = 4.5},

            jump = {1,2, defaultFrameX = 3,frameDelay = 4,loops = false},
            fall = {3,4, defaultFrameX = 3,frameDelay = 4,loops = false},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.terminalVelocity = 12
        actor.gravity = 0.35

        scene.data.luigiActor = actor
        return actor
    end

    local function spawnPeach(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/peach.png")
        actor.spriteOffset = vector(0,2)
        actor:setFrameSize(64,80)
        actor:setSize(32,64)

        actor.imageDirection = DIR_LEFT
        actor.direction = DIR_LEFT

        actor:setUpAnimator{animationSet = {
            idle = {1, defaultFrameX = 1},
            annoyed = {2, defaultFrameX = 1},
            surprised = {3, defaultFrameX = 1},

            walk = {1,2,3,4, defaultFrameX = 2,frameDelay = 8},
            walkFront = {1,2,3,4, defaultFrameX = 3,frameDelay = 12},

            talk = {1,2,3,4, defaultFrameX = 4,frameDelay = 12},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.terminalVelocity = 12
        actor.gravity = 0.4

        actor.color.a = 0

        scene.data.peachActor = actor
        return actor
    end

    local function spawnToadsworth(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/toadsworth.png")
        actor.spriteOffset = vector(0,2)
        actor:setFrameSize(52,52)
        actor:setSize(32,48)

        actor.imageDirection = DIR_LEFT
        actor.direction = DIR_LEFT

        actor:setUpAnimator{animationSet = {
            idle = {1,2, defaultFrameX = 1,frameDelay = 18},
            angry = {3,4, defaultFrameX = 1,frameDelay = 12},

            sad = {1, defaultFrameX = 2},
            surprised = {2, defaultFrameX = 2},
            front = {3, defaultFrameX = 2},

            walk = {1,2,3,4, defaultFrameX = 3,frameDelay = 12},
            walkFront = {1,2,3,4, defaultFrameX = 4,frameDelay = 12},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.terminalVelocity = 12
        actor.gravity = 0.4

        actor.color.a = 0

        scene.data.toadsworthActor = actor
        return actor
    end

    local function spawnPiloT(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/piloT.png")
        actor.spriteOffset = vector(0,2)
        actor.spritePivotOffset = vector(0,-32)
        actor:setFrameSize(64,64)
        actor:setSize(32,48)

        actor.imageDirection = DIR_LEFT
        actor.direction = DIR_LEFT

        actor:setUpAnimator{animationSet = {
            idle = {1,2, defaultFrameX = 1,frameDelay = 24},
            confident = {1,2, defaultFrameX = 2,frameDelay = 24},
            worried = {1,2, defaultFrameX = 3,frameDelay = 24},

            idleFront = {1,2, defaultFrameX = 4,frameDelay = 24},

            jumpConfident = {1, defaultFrameX = 5},
            jumpWorried = {2, defaultFrameX = 5},

            AAH = {1, defaultFrameX = 6},
            lie = {2, defaultFrameX = 6},

            sleep = {1,2, defaultFrameX = 7,frameDelay = 40},

            bow = {1, defaultFrameX = 8},
        },startAnimation = "sleep"}

        actor.useAutoFloor = true
        actor.terminalVelocity = 8
        actor.gravity = 0.26

        -- Create Z's when sleeping
        actor.data.zTimer = 0

        function actor:updateFunc()
            if self.animator.currentAnimation == "sleep" then
                self.data.zTimer = self.data.zTimer + 1

                if self.data.zTimer >= 80 then
                    local e = Effect.spawn(190,self.x + self.width*0.5 + 12*self.direction,self.y + self.height - 28)

                    e.x = e.x - e.width*0.5
                    e.y = e.y - e.height*0.5
                    e.direction = -self.direction

                    self.data.zTimer = 0
                end
            else
                self.data.zTimer = 0
            end
        end


        scene.data.piloTActor = actor
        return actor
    end

    local function spawnBalloon(scene,x,y)
        -- Spawn basket
        local basket = scene:spawnChildActor(x,y)

        basket.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/balloonBasket.png")
        basket:setFrameSize(132,96)
        basket:setSize(128,52)

        basket.priority = -22

        basket:setUpAnimator{animationSet = {
            empty = {1, defaultFrameX = 1},
            peach = {2, defaultFrameX = 1},
            mario = {3, defaultFrameX = 1},
            luigi = {4, defaultFrameX = 1},
            piloT = {5, defaultFrameX = 1},

            peachTalk = {1,2,3,2, defaultFrameX = 2,frameDelay = 12},
        },startAnimation = "empty"}

        scene.data.balloonBasketActor = basket

        -- Spawn the... balloon.
        local top = scene:spawnChildActor(x,y)

        top.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/balloonTop.png")
        top.spriteOffset = vector(0,-52)
        top:setFrameSize(224,294)
        top:setSize(128,52)

        top.priority = -23

        top:setUpAnimator{animationSet = {
            idle = {1,2,3,2,1,4,5,4, defaultFrameX = 1,frameDelay = 12},
        },startAnimation = "idle"}

        scene.data.balloonTopActor = top

        -- Attach the top to the basket
        function top:updateFunc()
            self.bottomCentre = basket.bottomCentre
        end
        
        return basket,top
    end


    local function brotherJumpRoutine(actor)
        SFX.play(1)

        actor:jumpAndWait{
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
            speedX = 0,speedY = -8.5,resetSpeed = true,
        }

        general.spawnLandingDust(actor.x + actor.width*0.5,actor.y + actor.height)
    end

    local function walkToPlatformRoutine(actor,walkAnimation,walkAnimationSpeed,stopAnimation)
        actor:walkAndWait{
            goal = actor.x + actor.width*0.5 + 1040,speed = 1,setDirection = true,
            --goal = actor.x + actor.width*0.5 + 1040,speed = 10,
            walkAnimation = walkAnimation,walkAnimationSpeed = walkAnimationSpeed,stopAnimation = stopAnimation,
        }
    end

    local function openAutoClosingBox(actor,args)
        args.uncontrollable = true

        local box = actor:talk(args)

        while (box ~= nil and box.isValid) do
            while (box.state ~= littleDialogue.BOX_STATE.STAY or not box.typewriterFinished) do
                Routine.skip(true)
            end

            Routine.wait(2)

            box:progress()

            if box.state == littleDialogue.BOX_STATE.OUT then
                while (box.isValid) do
                    Routine.skip(true)
                end
            end
        end
    end


    prologueScenes.boardScene.mainRoutineFunc = function(scene)
        -- Set up stuff
        local gatekeeperA = scene.data.gatekeeperA
        local gatekeeperB = scene.data.gatekeeperB

        general.initSceneFade(scene)

        scene.data.answeredYes = true
        scene.canSkip = false

        general.waitForPlayerToStop()

        -- Camera move
        smatrsCamera.startCutsceneCamera()

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.35,
            targets = {player,gatekeeperA},zoom = 1,
        }
        cutscenePal.waitUntilTransitionFinished()

        -- Yo waddup, bros
        gatekeeperA:talkAndWait{text = sceneLanguageFile.gatekeepersStart}

        if not scene.data.answeredYes then
            smatrsCamera.stopCutsceneCamera(0.35)

            scene.forcedKeys.left = true

            while ((player.x + player.width*0.5) > playerWalkAwayX) do
                Routine.skip()
            end

            return
        end


        -- Fade out
        scene:runChildRoutine(general.fadeOutMusic, 96,true)
        general.transitionSceneFadeOpacity(scene, 32,1)

        -- DELETE LUIGI!!!
        local partner = partners.getFirstPartner()

        if partner ~= nil then
            partner.inactive = true
        end

        -- Set stuff up
        local piloT = spawnPiloT(scene,piloTSpawnPos.x,piloTSpawnPos.y)

        local peach = spawnPeach(scene,doorSpawnPos.x,doorSpawnPos.y)
        local toadsworth = spawnToadsworth(scene,doorSpawnPos.x,doorSpawnPos.y)

        local mario = spawnMario(scene,marioSpawnPos.x,marioSpawnPos.y)
        local luigi = spawnLuigi(scene,luigiSpawnPos.x,luigiSpawnPos.y)

        local balloonBasket,balloonTop = spawnBalloon(scene,balloonSpawnPos.x,balloonSpawnPos.y)

        scene:setPlayerIsInactive(true)

        gatekeeperA.direction = DIR_RIGHT
        gatekeeperB.direction = DIR_LEFT
        gatekeeperA.color = Color.lightgrey
        gatekeeperB.color = Color.lightgrey

        handycam[1].targets = {doorSpawnPos}
        handycam[1].yOffset = -512

        Routine.wait(0.75)

        -- Fade back in
        general.transitionSceneFadeOpacity(scene, 32,0)
        scene.canSkip = true

        -- Camera movement
        Routine.wait(0.5)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 5,
            --ease = handycam.ease(easing.inOutSine),time = 0.5,
            zoom = 2,yOffset = -48,
        }
        cutscenePal.waitUntilTransitionFinished()

        Routine.wait(1)

        -- Door opens
        SFX.play(Misc.resolveSoundFile("_sound/misc/door open"))

        while (scene.data.doorAngle < 135) do
            scene.data.doorAngle = general.approach(scene.data.doorAngle,135,2)
            Routine.skip()
        end

        -- Music starts
        music.forcedMusicPath = "_music/Peachs Theme.ogg"
        music.volumeModifier = 1
        music.forceMute = false

        -- Peach walks out
        peach:setAnimation("walkFront")
        general.changeActorOpacity(peach,1,0.05)
        Routine.wait(0.5)
        peach:walkAndWait{
            goal = doorSpawnPos.x - 48,speed = 1.5,
            walkAnimation = "walk",stopAnimation = "idle",
        }

        gatekeeperA.direction = DIR_LEFT

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 1,
            targets = {peach,mario},zoom = 1.5,yOffset = 0,
        }

        -- Toadsworth walks out
        toadsworth:setAnimation("walkFront")
        general.changeActorOpacity(toadsworth,1,0.05)
        Routine.wait(0.5)
        toadsworth:setAnimation("idle")

        -- Talk
        peach:talkAndWait{text = sceneLanguageFile.peach1,talkAnimation = "talk",idleAnimation = "idle"}
        toadsworth:talkAndWait{text = sceneLanguageFile.toadsworth1}
        peach:talkAndWait{text = sceneLanguageFile.peach2,talkAnimation = "talk",idleAnimation = "idle"}
        toadsworth:talkAndWait{text = sceneLanguageFile.toadsworth2}
        peach:talkAndWait{text = sceneLanguageFile.peach3,talkAnimation = "talk",idleAnimation = "idle"}
        toadsworth:talkAndWait{text = sceneLanguageFile.toadsworth3}
        peach:setAnimation("annoyed")
        peach:talkAndWait{text = sceneLanguageFile.peach4}
        peach:setAnimation("idle")
        toadsworth:talkAndWait{text = sceneLanguageFile.toadsworth4}

        -- Mario and Luigi jump
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/oh yeah"))
        scene:runChildRoutine(brotherJumpRoutine,mario)

        Routine.wait(0.35)

        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/yah1"))
        scene:runChildRoutine(brotherJumpRoutine,luigi)

        -- Camera movement
        Routine.wait(1)
        
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {mario,luigi,peach,toadsworth},zoom = 1,
        }
        cutscenePal.waitUntilTransitionFinished()

        -- Talk.... AND walk...
        scene:runChildRoutine(walkToPlatformRoutine, mario,"walk",0.5,"idle")
        scene:runChildRoutine(walkToPlatformRoutine, luigi,"walk",0.5,"idle")
        scene:runChildRoutine(walkToPlatformRoutine, peach,"walk",1,"idle")
        scene:runChildRoutine(walkToPlatformRoutine, toadsworth,"walk",1,"idle")

        scene:runChildRoutine(function()
            openAutoClosingBox(toadsworth,sceneLanguageFile.toadsworth5)
            openAutoClosingBox(peach,sceneLanguageFile.peach5)
            openAutoClosingBox(toadsworth,sceneLanguageFile.toadsworth6)
        end)

        Routine.waitFrames(1170)

        -- He WHAT?!
        SFX.play(39)
        mario:setAnimation("surprised")
        luigi:setAnimation("surprised")
        peach:setAnimation("surprised")
        toadsworth:setAnimation("surprised")

        Routine.wait(0.5)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {toadsworth,piloTSpawnPos},zoom = 2.5,yOffset = -40,
        }
        cutscenePal.waitUntilTransitionFinished()

        -- What's he DOING?!?!?!?!?!?!
        Routine.wait(0.5)

        peach:talkAndWait{text = sceneLanguageFile.peach6}
        toadsworth:talkAndWait{text = sceneLanguageFile.toadsworth7}

        -- HE'S UPPPP!!!!
        scene:runChildRoutine(function()
            -- Fly into the air
            SFX.play(Misc.resolveSoundFile("_sound/voice/toad/shocked"))
            SFX.play(91)

            piloT.spriteRotationSpeed = 15
            piloT:jumpAndWait{
                riseAnimation = "AAH",landAnimation = "lie",
                speedX = 0,speedY = -8,
            }

            general.spawnLandingDust(piloT.x + piloT.width*0.5,piloT.y + piloT.height)

            piloT.spriteRotationSpeed = 0
            piloT.spriteRotation = 0

            SFX.play(Misc.resolveSoundFile("bowlingball"))
            Defines.earthquake = 3

            -- Get up
            Routine.wait(0.75)

            SFX.play(1)
            piloT:jumpAndWait{
                riseAnimation = "jumpWorried",landAnimation = "idle",
                speedX = 0,speedY = -6,
            }

            general.spawnLandingDust(piloT.x + piloT.width*0.5,piloT.y + piloT.height)
        end)

        Defines.earthquake = 8

        toadsworth:setAnimation("angry")
        openAutoClosingBox(toadsworth,sceneLanguageFile.toadsworth8)

        -- Talk
        mario:setAnimation("idle")
        luigi:setAnimation("idle")
        peach:setAnimation("idle")
        toadsworth:setAnimation("idle")

        mario.x = peach.x + peach.width*0.5 - 96 - mario.width*0.5
        luigi.x = mario.x + mario.width*0.5 - 48 - luigi.width*0.5

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {piloTSpawnPos},zoom = 1.25,xOffset = -128,yOffset = 0,
        }
        cutscenePal.waitUntilTransitionFinished()

        piloT:talkAndWait{text = sceneLanguageFile.piloT1}
        peach:talkAndWait{text = sceneLanguageFile.peach7,talkAnimation = "talk",idleAnimation = "idle"}
        toadsworth:talkAndWait{text = sceneLanguageFile.toadsworth9}
        piloT:talkAndWait{text = sceneLanguageFile.piloT2}

        -- Peach walks to the balloon
        scene:runChildRoutine(function()
            while ((piloT.centre.x - peach.centre.x) > 96) do
                Routine.skip()
            end

            piloT:setAnimation("bow")
            Routine.wait(1.5)
            piloT:setAnimation("idleFront")
        end)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {balloonBasket},zoom = 1.25,xOffset = -96,yOffset = -80,
        }

        peach:walkAndWait{
            goal = balloonBasket.centre.x,speed = 2,
            walkAnimation = "walk",walkAnimationSpeed = 1.5,
        }
        peach.isInvisible = true
        SFX.play(2)
        balloonBasket:talkAndWait{text = sceneLanguageFile.peach8,talkAnimation = "peachTalk",idleAnimation = "peach"}

        -- Brothers walk to the balloon
        local marioWalkRoutine = scene:runChildRoutine(function()
            mario:walkAndWait{
                goal = balloonBasket.centre.x + 48,speed = 2,
                walkAnimation = "walk",walkAnimationSpeed = 0.75,
            }
            mario.isInvisible = true
            SFX.play(2)

            balloonBasket:setAnimation("mario")
        end)

        local luigiWalkRoutine = scene:runChildRoutine(function()
            Routine.wait(0.75)

            luigi:walkAndWait{
                goal = balloonBasket.centre.x - 48,speed = 2,
                walkAnimation = "walk",walkAnimationSpeed = 0.75,
            }
            luigi.isInvisible = true
            SFX.play(2)

            balloonBasket:setAnimation("luigi")
        end)

        while (marioWalkRoutine.isValid or luigiWalkRoutine.isValid) do
            Routine.skip()
        end

        -- Pilo T. hops in
        piloT.direction = DIR_RIGHT
        piloT:setAnimation("idle")
        Routine.wait(0.5)

        piloT:talkAndWait{text = sceneLanguageFile.piloT3}
        SFX.play(1)
        piloT:jumpAndWait{
            riseAnimation = "jumpConfident",
            goalX = balloonBasket.centre.x - 24,goalY = balloonBasket.bottomCentre.y,resetSpeed = true,
        }

        piloT.isInvisible = true
        SFX.play(2)

        balloonBasket:setAnimation("piloT")

        -- Toadsworth talks
        toadsworth:talkAndWait{text = sceneLanguageFile.toadsworth10}
        balloonBasket:talkAndWait{text = sceneLanguageFile.piloT4}

        scene:runChildRoutine(toadsworth.walkAndWait, toadsworth,{
            goal = doorSpawnPos.x,speed = 1,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 1,stopAnimation = "idle",
        })

        -- GO GO GO!!
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {balloonSpawnPos},zoom = 1,xOffset = 0,yOffset = -128,
        }
        cutscenePal.waitUntilTransitionFinished()

        -- Balloon rises
        balloonBasket.gravity = -0.02
        Routine.wait(1)
        balloonBasket.gravity = 0
        Routine.wait(0.25)

        while (balloonBasket.speedX < 2) do
            balloonBasket.speedX = balloonBasket.speedX + 0.02
            Routine.skip()
        end

        balloonBasket.gravity = 0.008
        Routine.wait(1)

        -- Fade out
        scene:runChildRoutine(general.fadeOutMusic, 64,true)
        general.transitionSceneFadeOpacity(scene, 64,1)

        Routine.wait(0.5)
    end

    prologueScenes.boardScene.drawFunc = function(scene)
        general.drawSceneFade(scene)
    end

    prologueScenes.boardScene.stopFunc = function(scene)
        handycam[1]:release()

        music.forcedMusicPath = ""
        music.volumeModifier = 1
        music.forceMute = false

        -- Start crash scene
        if scene.data.answeredYes then
            prologueScenes.crashScene:start()
        end
    end


    local function createGatekeeper(x,y,direction)
        local actor = cutscenePal.spawnActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/gatekeeper.png")
        actor:setFrameSize(52,52)
        actor:setSize(52,52)

        actor.imageDirection = DIR_LEFT
        actor.direction = direction

        actor:setUpAnimator{animationSet = {
            idle = {1, defaultFrameX = 1},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.terminalVelocity = 12
        actor.gravity = 0.35

        return actor
    end


    local function drawCastleDoor(x,y,angle)
        local images = prologueScenes.boardScene.data.doorImages

        local rad = math.rad(angle)
        local cs = math.cos(rad)
        local sn = math.sin(rad)

        for i = 0,1 do
            local mainImage = images.front
            local sideImage = images.side

            if cs < 0 then
                mainImage = images.back
            end

            local direction = 1 - i*2
            local hingeX = x - mainImage.width*direction

            local mainWidth = mainImage.width*cs*direction

            Graphics.drawBox{
                texture = mainImage,priority = -46,sceneCoords = true,

                x = hingeX,
                y = y - mainImage.height,

                width = mainWidth,
                height = mainImage.height,
            }

            Graphics.drawBox{
                texture = sideImage,priority = -46,sceneCoords = true,

                x = hingeX + mainWidth,
                y = y - sideImage.height,

                width = sideImage.width*sn*direction,
                height = sideImage.height,
            }
        end
    end


    function prologueScenes.initBoardingStuff()
        prologueScenes.boardScene.data.gatekeeperA = createGatekeeper(-194496 + 16,-200288,DIR_LEFT)
        prologueScenes.boardScene.data.gatekeeperB = createGatekeeper(-194272 + 16,-200288,DIR_RIGHT)

        prologueScenes.boardScene.data.doorImages = {
            front = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/castleDoor_front.png"),
            back = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/castleDoor_back.png"),
            side = Graphics.loadImageResolved("_graphics/cutscenes/prologueBoard/castleDoor_side.png"),
        }
        prologueScenes.boardScene.data.doorAngle = 0
    end

    function prologueScenes.drawBoardingStuff()
        drawCastleDoor(doorSpawnPos.x,doorSpawnPos.y,prologueScenes.boardScene.data.doorAngle)
    end

    -- Register answers for gatekeeper's question
    littleDialogue.registerAnswer("gatekeeper",{
        text = sceneLanguageFile.gatekeeperQuestion.yes.answer,addText = sceneLanguageFile.gatekeeperQuestion.yes.response,
        chosenFunction = function(box)
            prologueScenes.boardScene.data.answeredYes = true
        end,
    })
    littleDialogue.registerAnswer("gatekeeper",{
        text = sceneLanguageFile.gatekeeperQuestion.no.answer,addText = sceneLanguageFile.gatekeeperQuestion.no.response,
        chosenFunction = function(box)
            prologueScenes.boardScene.data.answeredYes = false
        end,
    })
end


-- Balloon crashing scene
do
    prologueScenes.crashScene = cutscenePal.newScene("prologueCrash")
    prologueScenes.crashScene.canSkip = true

    local sceneLanguageFile = languageFiles("cutscenes/prologueCrash")


    local fallingStarImage = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/star.png")

    local logoPriority = 1
    local logoScale = 3.4


    local balloonSpawnPos = vector(-160000 + 400,-160224 + 80)

    local balloonBasketFlyPos = vector(balloonSpawnPos.x,balloonSpawnPos.y + 32)
    local balloonTopFlyPos = vector(balloonSpawnPos.x + 112,balloonSpawnPos.y + 48)

    local luigiHoldOffset = vector(-48,-64)

    local cameraBasePos = vector(-160000 + 400,-160608 + 300)


    local beachCameraStartPos = vector(-179232,-180736)
    local beachCameraStopPos = vector(-179616 - 16,-180224 + 32)

    local backgroundBalloonSpawnPos = vector(beachCameraStartPos.x - 256,beachCameraStartPos.y - 48)
    local backgroundMarioSpawnPos = vector(beachCameraStartPos.x - 224,beachCameraStartPos.y - 96)


    local function updateBalloonAttachment(actor)
        if not actor.data.onBalloon then
            return
        end

        local balloonBasket = prologueScenes.crashScene.data.balloonBasketActor

        actor.x = balloonBasket.x + (balloonBasket.width - actor.width)*0.5 + actor.data.balloonOffsetX
        actor.y = balloonBasket.y + balloonBasket.height - actor.height + actor.data.balloonOffsetY
    end

    local function initBalloonAttachment(actor,offsetX,offsetY)
        actor.data.onBalloon = true
        actor.data.balloonOffsetX = offsetX
        actor.data.balloonOffsetY = offsetY

        updateBalloonAttachment(actor)
    end


    local function spawnMario(scene)
        local actor = scene:spawnChildActor(0,0)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/mario.png")
        smatrsPlayer.setUpPlayerActor(actor)

        actor.priority = -43

        actor:setUpAnimator{animationSet = {
            idle = {1,1,1,1,2,3,4,5,6,6,6,6,4,3,2, defaultFrameX = 1,frameDelay = 12},

            confused = {1, defaultFrameX = 2},
            surprised = {2, defaultFrameX = 2},
            surprisedUp = {3, defaultFrameX = 2},

            fly = {1,2,3,4, defaultFrameX = 3,frameDelay = 3},
            flyLook = {5,6,7,8, defaultFrameX = 3,frameDelay = 3},

            fall = {1, defaultFrameX = 4},
        },startAnimation = "idle"}

        initBalloonAttachment(actor,42,-34)

        function actor:updateFunc()
            updateBalloonAttachment(self)
        end

        scene.data.marioActor = actor
        return actor
    end

    local function spawnLuigi(scene)
        local actor = scene:spawnChildActor(0,0)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/luigi.png")
        actor.spriteOffset = vector(0,22)
        actor:setSize(24,54)
        actor:setFrameSize(100,100)

        actor.priority = -44

        actor.imageDirection = DIR_RIGHT
        actor.direction = DIR_LEFT

        actor:setUpAnimator{animationSet = {
            sleep = {1,2,3,4,5,5,5,5,5,5,5, defaultFrameX = 1,frameDelay = 14},

            flyNormal = {1,2, defaultFrameX = 2,frameDelay = 2},
            holdNormal = {3,4, defaultFrameX = 2,frameDelay = 2},
            flyScared = {1,2, defaultFrameX = 3,frameDelay = 2},
            holdScared = {3,4, defaultFrameX = 3,frameDelay = 2},

            confused = {1, defaultFrameX = 4},
            surprised = {2, defaultFrameX = 4},
            surprisedUp = {3, defaultFrameX = 4},
        },startAnimation = "sleep"}

        initBalloonAttachment(actor,-44,-34)

        -- Create Z's when sleeping
        actor.data.zTimer = 0

        function actor:updateFunc()
            updateBalloonAttachment(self)
            
            if self.animator.currentAnimation == "sleep" then
                self.data.zTimer = self.data.zTimer + 1

                if self.data.zTimer >= 120 then
                    local e = Effect.spawn(190,self.x + self.width*0.5 + 12*self.direction,self.y + self.height - 28)

                    e.x = e.x - e.width*0.5
                    e.y = e.y - e.height*0.5
                    e.direction = self.direction

                    self.data.zTimer = 0
                end
            else
                self.data.zTimer = 0
            end
        end

        scene.data.luigiActor = actor
        return actor
    end

    local function spawnPeach(scene)
        local actor = scene:spawnChildActor(0,0)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/peach.png")
        actor.spriteOffset = vector(0,6)
        actor:setFrameSize(80,96)
        actor:setSize(32,64)

        actor.priority = -42

        actor.imageDirection = DIR_RIGHT
        actor.direction = DIR_RIGHT

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4,5,6,1,2,3,4,5,6,vector(2,1),vector(2,2),vector(2,3), defaultFrameX = 1,frameDelay = 10},
            talk = {4,5,6,7, defaultFrameX = 2,frameDelay = 10},

            confused = {1, defaultFrameX = 3},
            surprised = {2, defaultFrameX = 3},
            surprisedUp = {3, defaultFrameX = 3},

            fall = {1,2, defaultFrameX = 4,frameDelay = 4},
            fly = {3,4, defaultFrameX = 4,frameDelay = 4},
        },startAnimation = "idle"}

        initBalloonAttachment(actor,6,-32)

        function actor:updateFunc()
            updateBalloonAttachment(self)
        end

        scene.data.peachActor = actor
        return actor
    end

    local function spawnPiloT(scene)
        local actor = scene:spawnChildActor(0,0)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/piloT.png")
        actor.spriteOffset = vector(0,2)
        actor.spritePivotOffset = vector(0,-32)
        actor:setFrameSize(64,64)
        actor:setSize(32,48)

        actor.priority = -41

        actor.imageDirection = DIR_LEFT
        actor.direction = DIR_LEFT

        actor:setUpAnimator{animationSet = {
            idle = {1,1,1,1,1,1,1,1,1,1,2, defaultFrameX = 1,frameDelay = 12},

            confident = {3, defaultFrameX = 1},
            confused = {4, defaultFrameX = 1},

            surprised = {1,2, defaultFrameX = 3,frameDelay = 8},
            surprisedUp = {3, defaultFrameX = 3},

            AAH = {4, defaultFrameX = 4},
        },startAnimation = "idle"}

        initBalloonAttachment(actor,-22,-36)

        function actor:updateFunc()
            updateBalloonAttachment(self)
        end

        scene.data.piloTActor = actor
        return actor
    end


    local ropeLinePositions = {
        {vector(-56,-26),vector(-60,114)},
        {vector(-30,-30),vector(-32,120)},
        {vector(30,-30),vector(32,120)},
        {vector(56,-26),vector(60,114)},
    }
    local ropeLineColor = Color.fromHexRGB(0x697780)

    local function spawnBalloon(scene,x,y)
        -- Spawn basket
        local basket = scene:spawnChildActor(x,y)

        basket.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/balloonBasket.png")
        basket.spritePivotOffset = vector(0,-32)
        basket:setFrameSize(132,64)
        basket:setSize(128,64)

        basket.priority = -46

        basket.data.floatTimer = 0
        basket.data.attached = true

        scene.data.balloonBasketActor = basket

        function basket:updateFunc()
            if self.data.attached then
                self.speedY = math.cos(self.data.floatTimer/48)*0.15
                self.data.floatTimer = self.data.floatTimer + 1
            end
        end

        -- Spawn the... balloon.
        local top = scene:spawnChildActor(x,y)

        top.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/balloonTop.png")
        top.spritePivotOffset = vector(0,-180)
        top.spriteOffset = vector(0,-52)
        top:setFrameSize(224,294)
        top:setSize(128,52)

        top.priority = -47

        top:setUpAnimator{animationSet = {
            idle = {1,2,3,2,1,4,5,4, defaultFrameX = 1,frameDelay = 12},
            popped = {1,2,3,2,1,4,5,4, defaultFrameX = 2,frameDelay = 12},

            unattached = {6, defaultFrameX = 2},
        },startAnimation = "idle"}

        scene.data.balloonTopActor = top

        -- Attach the top to the basket
        function top:updateFunc()
            if basket.data.attached then
                self.bottomCentre = basket.bottomCentre
            end
        end

        -- Rope lines
        function basket:drawFunc()
            if basket.data.attached then
                return
            end

            for _,lineData in ipairs(ropeLinePositions) do
                local start = lineData[1]:rotate(self.spriteRotation)
                local stop = lineData[2]:rotate(top.spriteRotation)

                general.drawLine{
                    color = ropeLineColor,sceneCoords = true,
                    thickness = 2,priority = -48,
                    
                    x1 = self.x + self.width*0.5 + self.spriteOffset.x + self.spritePivotOffset.x + start.x,
                    y1 = self.y + self.height + self.spriteOffset.y + self.spritePivotOffset.y + start.y,

                    x2 = top.x + top.width*0.5 + top.spriteOffset.x + top.spritePivotOffset.x + stop.x,
                    y2 = top.y + top.height + top.spriteOffset.y + top.spritePivotOffset.y + stop.y,
                }
            end
        end

        return basket,top
    end


    local function spawnFallingStar(scene,yOffset)
        yOffset = yOffset or RNG.random(-256,256)

        local star = scene:spawnChildActor(cameraBasePos.x + 448,cameraBasePos.y - 300 + yOffset)

        star.image = fallingStarImage
        star.spriteOffset = vector(0,6)
        star.spritePivotOffset = vector(0,-22)
        star:setSize(32,32)

        star.priority = -30

        star.spriteRotationSpeed = -20

        star.speedX = -8
        star.speedY = 6

        star.data.afterimageTimer = 0

        SFX.play(Misc.resolveSoundFile("_sound/misc/cartoon-fall-2"),0.5)


        function star:updateFunc()
            star.data.afterimageTimer = star.data.afterimageTimer + 1

            if star.data.afterimageTimer >= 3 then
                general.spawnActorAfterimage(self,Color.fromHSV((lunatime.tick() / 64) % 1,0.8,0.9))
                star.data.afterimageTimer = 0

                --[[local e = Effect.spawn(755,self.x + self.width*0.5 + RNG.random(-4,4),self.y + self.height*0.5 + RNG.random(-4,4))
                
                e.priority = self.priority - 0.1]]
            end

            if (self.y + self.height) > (cameraBasePos.y + 300 + 64) then
                self:remove()
            end
        end


        return star
    end


    local function spawnBackgroundMario(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/backgroundMario.png")
        actor:setFrameSize(48,68)
        actor:setSize(48,68)

        actor.priority = -99

        actor:setUpAnimator{animationSet = {
            idle = {1,2, defaultFrameX = 1,frameDelay = 2},
        },startAnimation = "idle"}

        return actor
    end

    local function spawnBackgroundBalloon(scene,x,y)
        local actor = scene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/backgroundBalloon.png")
        actor:setFrameSize(68,64)
        actor:setSize(68,64)

        actor.priority = -99.5

        actor:setUpAnimator{animationSet = {
            idle = {1,2, defaultFrameX = 1,frameDelay = 4},
        },startAnimation = "idle"}

        return actor
    end

    
    local function initBackground(scene)
        scene.data.backgroundImages = {
            backClouds = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/bg_backClouds.png"),
            loopClouds = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/bg_loopClouds.png"),
            foreClouds = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/bg_foreClouds.png"),
            topClouds = Graphics.loadImageResolved("_graphics/cutscenes/prologueCrash/bg_topClouds.png"),
        }

        scene.data.backgroundSpeedX = 0
        scene.data.backgroundSpeedY = 0
        scene.data.backgroundX = 0
        scene.data.backgroundY = 0
    end

    local function drawBackground(scene)
        local images = scene.data.backgroundImages

        local bounds = player.sectionObj.origBoundary
        local scrollX = scene.data.backgroundX + ((camera.x + camera.width*0.5) - cameraBasePos.x)
        local scrollY = scene.data.backgroundY + ((camera.y + camera.height*0.5) - cameraBasePos.y)

        -- Back clouds
        Graphics.drawBox{
            texture = images.backClouds,priority = -98,
            shader = general.wrapShader,

            sourceX = scrollX*0.35,
            sourceWidth = camera.width,
            x = 0,

            sourceY = 0,
            sourceHeight = images.backClouds.height,
            y = -(scrollY*0.35 + 384),
        }

        -- Looping clouds
        Graphics.drawBox{
            texture = images.loopClouds,priority = -99,
            shader = general.wrapShader,

            sourceX = scrollX*0.25,
            sourceWidth = camera.width,
            x = 0,

            sourceY = scrollY*0.25,
            sourceHeight = camera.height,
            y = 0,
        }

        -- Fore clouds
        Graphics.drawBox{
            texture = images.foreClouds,priority = -4,
            shader = general.wrapShader,

            sourceX = scrollX*1.15,
            sourceWidth = camera.width,
            x = 0,

            sourceY = 0,
            sourceHeight = images.foreClouds.height,
            y = -(scrollY - 400),
        }

        -- Top clouds
        for i = 0,1 do
            Graphics.drawBox{
                texture = images.topClouds,priority = -4,
                shader = general.wrapShader,

                sourceX = scrollX*(1.1 + i*0.1),
                sourceWidth = camera.width,
                x = 0,

                sourceY = 0,
                sourceHeight = images.topClouds.height,
                y = -(scrollY + 64 + 48*i),
            }
        end
    end


    local function logoAppearRoutine(scene)
        SFX.play(Misc.resolveSoundFile("_sound/misc/logo_show_prologue"))

        while (scene.data.logoOpacity < 1) do
            scene.data.logoOpacity = math.min(1,scene.data.logoOpacity + 0.005)
            Routine.skip()
        end

        Routine.wait(1.1)

        while (scene.data.logoObject.overlayEnterTimer < 1) do
            scene.data.logoObject.overlayEnterTimer = math.min(1,scene.data.logoObject.overlayEnterTimer + 1/96)
            Routine.skip()
        end
    end


    local function actorEasedMove(actor, easeFunc,duration, newX,newY,newRotation)
        local startX = actor.x + actor.width*0.5
        local startY = actor.y + actor.height
        local startRotation = actor.spriteRotation

        local timer = 0

        while (timer < duration) do
            timer = timer + 1

            actor.x = easeFunc(timer,startX,newX - startX,duration) - actor.width*0.5
            actor.y = easeFunc(timer,startY,newY - startY,duration) - actor.height
            actor.spriteRotation = easeFunc(timer,startRotation,newRotation - startRotation,duration)

            Routine.skip()
        end
    end

    local function actorFloatRoutine(actor, frequency,distance)
        local timer = 0

        while (true) do
            actor.speedY = math.sin(timer/frequency)*distance
            timer = timer + 1

            Routine.skip()
        end
    end

    local function actorAttachRoutine(actor, attachedActor,offsetX,offsetY)
        while (true) do
            actor.x = attachedActor.x + (attachedActor.width - actor.width)*0.5 + offsetX
            actor.y = attachedActor.y + attachedActor.height - actor.height + offsetY
            Routine.skip()
        end
    end


    local function actorFlyOffRoutine(actor, acceleration)
        while (actor.x > (cameraBasePos.x - 448)) do
            actor.speedX = actor.speedX - acceleration
            Routine.skip()
        end

        actor.speedX = 0
        actor.isInvisible = true
        actor.isFrozen = true
    end


    prologueScenes.crashScene.mainRoutineFunc = function(scene)
        -- Set up stuff
        local balloonBasket,balloonTop = spawnBalloon(scene,balloonSpawnPos.x,balloonSpawnPos.y)

        local mario = spawnMario(scene)
        local luigi = spawnLuigi(scene)
        local peach = spawnPeach(scene)
        local piloT = spawnPiloT(scene)

        local riders = {mario,luigi,peach,piloT}

        smatrsCamera.startCutsceneCamera()
        handycam[1].targets = {cameraBasePos}

        general.initSceneFade(scene)
        scene.data.fadeOpacity = 1

        scene.data.rainingStars = false
        scene.data.starSpawnTimer = 0

        scene.data.onBeach = false
        scene.data.logoObject = logoRendering.createLogoObject()
        scene.data.logoOpacity = 0

        initBackground(scene)

        scene:setPlayerIsInactive(true)
        player.section = 2

        scene.data.backgroundSpeedX = 1.5

        music.forceMute = true

        -- Fade in
        Routine.wait(0.25)

        music.forcedMusicPath = "_music/Balloon Flight.ogg"
        music.volumeModifier = 1
        music.forceMute = false
        
        general.transitionSceneFadeOpacity(scene, 48,0)


        -- Talk
        Routine.wait(4)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 1,
            targets = {cameraBasePos},zoom = 1.5,xOffset = 112,yOffset = 48,
        }
        cutscenePal.waitUntilTransitionFinished()

        peach:talkAndWait{text = sceneLanguageFile.peach1,talkAnimation = "talk",idleAnimation = "idle"}
        piloT:talkAndWait{text = sceneLanguageFile.piloT1}
        peach:talkAndWait{text = sceneLanguageFile.peach2,talkAnimation = "talk",idleAnimation = "idle"}
        piloT:talkAndWait{text = sceneLanguageFile.piloT2}
        peach:talkAndWait{text = sceneLanguageFile.peach3,talkAnimation = "talk",idleAnimation = "idle",}
        piloT:talkAndWait{text = sceneLanguageFile.piloT3}

        -- THUNDER?!
        Routine.wait(1)
	
        SFX.play(Misc.resolveSoundFile("_sound/misc/dark_blast2"))
        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/wah"))
        music.forceMute = true

        mario:setAnimation("confused")
        luigi:setAnimation("confused")
        peach:setAnimation("confused")
        piloT:setAnimation("confused")

        scene.data.fadePriority = -1
        general.transitionSceneFadeOpacity(scene, 8,0.5)
        general.transitionSceneFadeOpacity(scene, 48,0)

        Routine.wait(1)

        peach:talkAndWait{text = sceneLanguageFile.peach4,talkAnimation = "talk",idleAnimation = "confused"}
        piloT:talkAndWait{text = sceneLanguageFile.piloT4}
        
        Routine.wait(1)

        -- Star falls
        spawnFallingStar(scene,96)

        Routine.wait(0.25)
        piloT:setAnimation("surprisedUp")
        Routine.wait(1.5)

        -- Stars start raining down
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            zoom = 1,xOffset = 0,yOffset = 0,
        }

        SFX.play(Misc.resolveSoundFile("_sound/voice/toad/help"))
        scene.data.rainingStars = true

        mario:setAnimation("surprised")
        luigi:setAnimation("surprised")
        peach:setAnimation("surprised")
        piloT:setAnimation("surprised")

        music.forcedMusicPath = "_music/Panic Pit.ogg"
        music.volumeModifier = 1
        music.forceMute = false

        -- HELP!!!
        Routine.wait(1)

        piloT:talkAndWait{text = sceneLanguageFile.piloT5}
        peach:talkAndWait{text = sceneLanguageFile.peach5}

        -- Star hits the balloon
        scene.data.rainingStars = false
        Routine.wait(1)

        local finalStar = spawnFallingStar(scene,-104)

        while ((finalStar.centre.x - balloonTop.centre.x) > 64) do
            Routine.skip()
        end

        Effect.spawn(853,finalStar.centre.x,finalStar.centre.y)
        finalStar.priority = -50

        Defines.earthquake = 7
        SFX.play(43)

        balloonTop:setAnimation("popped")
        mario:setAnimation("surprisedUp")
        luigi:setAnimation("surprisedUp")
        peach:setAnimation("surprisedUp")
        piloT:setAnimation("surprisedUp")

        -- Fall..... (the most complicated bit)
        Routine.wait(1.5)

        -- Make the background move down
        scene:runChildRoutine(function()
            while (scene.data.backgroundSpeedY < 12) do
                scene.data.backgroundSpeedY = general.approach(scene.data.backgroundSpeedY,12,0.25)
                Routine.skip()
            end
        end)

        -- Balloon moves
        local balloonBasketRoutine = scene:runChildRoutine(function()
            actorEasedMove(balloonBasket, easing.inOutSine,128, balloonBasketFlyPos.x,balloonBasketFlyPos.y,25)
            actorFloatRoutine(balloonBasket, 12,0.5)
        end)
        local balloonTopRoutine = scene:runChildRoutine(function()
            actorEasedMove(balloonTop, easing.inOutSine,192, balloonTopFlyPos.x,balloonTopFlyPos.y,30)
            actorFloatRoutine(balloonTop, 16,0.6)
        end)

        balloonBasket.data.attached = false
        balloonTop:setAnimation("unattached")

        -- Actors move up
        for _,actor in ipairs(riders) do
            actor.data.onBalloon = false
            actor.gravity = 0.1

            scene:runChildRoutine(function()
                Routine.skip()

                while (actor.speedY < 0) do
                    actor.speedX = actor.speedX*0.96
                    Routine.skip()
                end

                actor.gravity = 0
                actor.speedX = 0
                actor.speedY = 0
            end)
        end

        mario:setAnimation("fly")
        mario.speedX = 5
        mario.speedY = -5.5

        luigi:setAnimation("flyNormal")
        luigi.speedX = -2
        luigi.speedY = -3.5

        peach:setAnimation("fall")
        peach.speedX = 1
        peach.speedY = -6

        piloT:setAnimation("AAH")
        piloT.speedX = -1
        piloT.speedY = -5

        piloT.spriteRotationSpeed = 12
        luigi.direction = DIR_RIGHT

        SFX.play(Misc.resolveSoundFile("_sound/voice/group_fall"))

        -- Mario, Peach and Pilo T float
        local marioRoutine = scene:runChildRoutine(function()
            while (mario.speedY < 0) do
                Routine.skip()
            end
            
            actorFloatRoutine(mario, 16,0.75)
        end)

        local peachRoutine = scene:runChildRoutine(function()
            while (peach.speedY < 0) do
                Routine.skip()
            end
            
            actorFloatRoutine(peach, 14,-1)
        end)

        local piloTRoutine = scene:runChildRoutine(function()
            while (piloT.speedY < 0) do
                Routine.skip()
            end
            
            actorFloatRoutine(piloT, 12,2)
        end)
        
        -- Luigi holds on to the balloon
        local luigiRoutine = scene:runChildRoutine(function()
            while (luigi.speedY < 0) do
                Routine.skip()
            end
            
            actorEasedMove(luigi, easing.inOutSine,192, balloonBasketFlyPos.x + luigiHoldOffset.x,balloonBasketFlyPos.y + luigiHoldOffset.y,0)
            luigi:setAnimation("holdNormal")
            actorAttachRoutine(luigi, balloonBasket,luigiHoldOffset.x,luigiHoldOffset.y)
        end)


        -- Camera move
        Routine.wait(2)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {mario.centre,piloT.centre,peach.centre},zoom = 2,
        }
        cutscenePal.waitUntilTransitionFinished()

        piloT:talkAndWait{text = sceneLanguageFile.piloT6}

        -- Peach flies off
        Routine.wait(0.5)

        peach:setAnimation("fly")
        general.actorShakeRoutine(peach, 3,2,64)
        Routine.wait(0.25)

        SFX.play(Misc.resolveSoundFile("_sound/voice/peach/scream"))
        mario:setAnimation("flyLook")
        
        actorFlyOffRoutine(peach, 0.1)

        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/oh no"))
        
        -- Pilo T flies off
        Routine.wait(1)

        SFX.play(Misc.resolveSoundFile("_sound/voice/toad/fall"))

        actorFlyOffRoutine(piloT, 0.1)


        -- Camera move
        Routine.wait(0.5)

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {mario.centre,luigi.centre},zoom = 2,yOffset = -4,
        }
        cutscenePal.waitUntilTransitionFinished()

        -- Luigi tries to hold on...
        Routine.wait(0.25)

        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/angry"))
        luigi:setAnimation("holdScared")

        Routine.wait(1)
        general.actorShakeRoutine(luigi, 3,2,64)
        Routine.wait(0.5)

        -- But it failed!
        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/mariooo"))

        luigi:setAnimation("flyScared")
        luigi.gravity = -0.04
        luigiRoutine:abort()
        
        scene:runChildRoutine(actorFlyOffRoutine, luigi, 0.075)

        Routine.wait(0.75)
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/luigiiiiiii"))


        -- Camera move
        Routine.wait(0.5)

        mario:setAnimation("fly")

        handycam[1]:transition{
            ease = handycam.ease(easing.inOutSine),time = 0.75,
            targets = {mario.centre},zoom = 1.25,xOffset = -128,yOffset = 64,
        }
        cutscenePal.waitUntilTransitionFinished()

        -- Welp... guess I'll just fall...
        Routine.wait(1)

        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/mama mia (down'd)"))

        mario:setAnimation("fall")
        mario.terminalVelocity = 8
        mario.gravity = 0.1
        mario.speedX = 0.5
        mario.speedY = -3
        marioRoutine:abort()

        balloonBasket.terminalVelocity = 8
        balloonBasket.gravity = 0.035
        balloonBasket.speedX = 0.35
        balloonBasketRoutine:abort()

        balloonTop.terminalVelocity = 8
        balloonTop.gravity = 0.03
        balloonTop.speedX = 0.35
        balloonTopRoutine:abort()

        -- Background slows down
        while (scene.data.backgroundSpeedX ~= 0 or scene.data.backgroundSpeedY ~= 0) do
            scene.data.backgroundSpeedX = general.approach(scene.data.backgroundSpeedX,0,0.025)
            scene.data.backgroundSpeedY = general.approach(scene.data.backgroundSpeedY,0,0.05)

            Routine.skip()
        end

        -- Fade out
        scene:runChildRoutine(general.fadeOutMusic, 640,true)

        general.initSceneFade(scene)
        general.transitionSceneFadeOpacity(scene, 96,1)


        -- Initialise beach scene
        for _,actor in ipairs{mario,luigi,peach,piloT,balloonBasket,balloonTop} do
            actor.isInvisible = true
            actor.isFrozen = true
        end

        local backgroundBalloon = spawnBackgroundBalloon(scene,backgroundBalloonSpawnPos.x,backgroundBalloonSpawnPos.y)
        local backgroundMario = spawnBackgroundMario(scene,backgroundMarioSpawnPos.x,backgroundMarioSpawnPos.y)

        scene.data.onBeach = true

        player.section = 1

        handycam[1]:reset()
        handycam[1].targets = {beachCameraStartPos}

        Routine.wait(1)

        -- Fade in
        scene:runChildRoutine(general.transitionSceneFadeOpacity, scene, 64,0)

        backgroundBalloon.speedX = -0.55
        backgroundBalloon.speedY = 1.05
        backgroundMario.speedX = -0.5
        backgroundMario.speedY = 1

        handycam[1]:transition{
            ease = handycam.ease(easing.outSine),time = 7,
            targets = {beachCameraStopPos},
        }
        cutscenePal.waitUntilTransitionFinished()

        Routine.wait(3)

        scene.canSkip = false
        scene.hasBars = false
        scene.barsExitDuration = 64

        scene:runChildRoutine(logoAppearRoutine,scene)
        Routine.wait(8.5)

        general.transitionSceneFadeOpacity(scene, 128,1)
        Routine.wait(1)
    end

    prologueScenes.crashScene.updateFunc = function(scene)
        if Misc.isPaused() then
            return
        end

        scene.data.backgroundX = scene.data.backgroundX + scene.data.backgroundSpeedX
        scene.data.backgroundY = scene.data.backgroundY + scene.data.backgroundSpeedY
        
        if scene.data.rainingStars then
            scene.data.starSpawnTimer = scene.data.starSpawnTimer - 1

            if scene.data.starSpawnTimer <= 0 then
                scene.data.starSpawnTimer = RNG.randomInt(48,96)
                spawnFallingStar(scene)
            end
        end
    end

    prologueScenes.crashScene.drawFunc = function(scene)
        general.drawSceneFade(scene)

        if not scene.data.onBeach then
            drawBackground(scene)
        end

        if scene.data.logoOpacity > 0 then
            general.applyBlur(logoPriority - 0.1,Color.grey.. scene.data.logoOpacity)
            
            scene.data.logoObject:draw{
                color = Color(1,1,1,scene.data.logoOpacity),
                priority = logoPriority,

                x = camera.width*0.5,y = camera.height*0.5,
                scaleX = logoScale,scaleY = logoScale,
            }
        end
    end

    prologueScenes.crashScene.stopFunc = function(scene)
        handycam[1]:release()

        music.forcedMusicPath = ""
        music.volumeModifier = 1
        music.forceMute = false

        -- Start chapter intro screen
        player.section = 5

        chapterIntro.scene.data.chapter = 1
        chapterIntro.scene.data.finishFunc = function(scene)
            SaveData.storyProgress = general.STORY_PROGRESS.C1.CRASH_LANDING
            GameData.justCameFromPrologue = true
            GameData.saveQueued = true
            
            loadscreenLevel.chapterArtIndex = 1

            local levelFilename = "1-1 - Crash Landing.lvlx"

            SaveData.lastEnteredMapLevel = levelFilename
            Level.load(levelFilename)
        end

        chapterIntro.scene:start()
    end
end


function prologueScenes.onInitAPI()
    registerEvent(prologueScenes,"onDraw","drawBoardingStuff")
end


return prologueScenes