local littleDialogue = require("_scripts/littleDialogue")
local cutscenePal = require("_scripts/cutscenePal")
local general = require("_scripts/generalStuff")

local smatrsCamera = require("_scripts/smatrs_camera")
local handycam = require("handycam")
local easing = require("ext/easing")

local smatrsPlayer = require("_scripts/smatrs_player")
local partners = require("_scripts/smatrs_partners")
local music = require("_scripts/smatrs_music")

local playerTeleportation = require("_scripts/smatrs_playerTeleportation")

local funnySounds = require("_scripts/funnySounds")

local pointBlocks = require("_scripts/pointBlocks")

local languageFiles = require("_scripts/languageFiles")

local trainingCourseScenes = {}


-- Invite scene
do
    trainingCourseScenes.inviteScene = cutscenePal.newScene("trainingCourseInvite")

    local sceneLanguageFile = languageFiles("cutscenes/trainingCourseInvite")


    local function marioShakeHead()
        local mario = trainingCourseScenes.inviteScene.data.marioActor
        
        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/no"))
    
        trainingCourseScenes.inviteScene:runChildRoutine(function()
            mario:setAnimation("shakeHead")
            mario:waitUntilAnimationFinished()
            mario:setAnimation("idle")
        end)
    end


    littleDialogue.registerAnswer("instructorToad1",{
        text = sceneLanguageFile.formatTQuestion1.accept.answer,addText = sceneLanguageFile.formatTQuestion1.accept.response,
        chosenFunction = function(box)
            trainingCourseScenes.inviteScene.data.instructorToadActor:setAnimation("confident")
            trainingCourseScenes.inviteScene.data.answeredNo = false
        end,
    })
    littleDialogue.registerAnswer("instructorToad1",{
        text = sceneLanguageFile.formatTQuestion1.refuse.answer,addText = sceneLanguageFile.formatTQuestion1.refuse.response,
        chosenFunction = function(box)
            trainingCourseScenes.inviteScene.data.instructorToadActor:setAnimation("worried")
            marioShakeHead()
        end,
    })

    littleDialogue.registerAnswer("instructorToad2",{
        text = sceneLanguageFile.formatTQuestion2.accept.answer,addText = sceneLanguageFile.formatTQuestion2.accept.response,
        chosenFunction = function(box)
            trainingCourseScenes.inviteScene.data.instructorToadActor:setAnimation("confident")
            trainingCourseScenes.inviteScene.data.answeredNo = false
        end,
    })
    littleDialogue.registerAnswer("instructorToad2",{
        text = sceneLanguageFile.formatTQuestion2.refuse.answer,addText = sceneLanguageFile.formatTQuestion2.refuse.response,
        chosenFunction = function(box)
            trainingCourseScenes.inviteScene.data.answeredNo = true
            marioShakeHead()
        end,
    })


    local function spawnMario(x,y)
        local actor = trainingCourseScenes.inviteScene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/trainingCourseInvite/mario.png")
        smatrsPlayer.setUpPlayerActor(actor)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},
            turn = {5, defaultFrameX = 1,frameDelay = 4,loops = false},
            frontFacing = {5, defaultFrameX = 1},

            walk = {1,2,3,4,5,6, defaultFrameX = 2,frameDelay = 8},

            ledgeTeetering = {1,2,3,4, defaultFrameX = 3,frameDelay = 6},

            thumbsUp = {1,2,3, defaultFrameX = 4,frameDelay = 6,loops = false},
            shakeHead = {1,2,3,2,1,4,1,1, defaultFrameX = 5,frameDelay = 6,loops = false},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.gravity = 0.4
        actor.terminalVelocity = 12

        trainingCourseScenes.inviteScene.data.marioActor = actor

        return actor
    end

    local function spawnLuigi(x,y)
        local actor = trainingCourseScenes.inviteScene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/trainingCourseInvite/luigi.png")
        actor.spriteOffset = vector(0,22)
        actor.priority = -28
        actor:setSize(24,54)
        actor:setFrameSize(100,100)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},
            walk = {1,2,3,4,5,6, defaultFrameX = 2,frameDelay = 8},

            lookUp = {5, defaultFrameX = 1},
            turn = {6, defaultFrameX = 1,frameDelay = 4,loops = false},

            jump = {1,2, defaultFrameX = 3,frameDelay = 4,loops = false},
            fall = {3,4, defaultFrameX = 3,frameDelay = 4,loops = false},

            wave = {1,2,3,2, defaultFrameX = 4,frameDelay = 6},

            surprisedLookDown = {4, defaultFrameX = 4},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.gravity = 0.3
        actor.terminalVelocity = 12

        trainingCourseScenes.inviteScene.data.luigiActor = actor

        return actor
    end

    local function spawnInstructorToad(x,y)
        local actor = trainingCourseScenes.inviteScene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/trainingCourseInvite/instructorToad.png")
        actor.spriteOffset = vector(0,2)
        actor.priority = -67
        actor.imageDirection = DIR_LEFT
        actor:setFrameSize(64,64)
        actor:setSize(32,48)

        actor:setUpAnimator{animationSet = {
            idle = {1,2, defaultFrameX = 1,frameDelay = 24},
            confident = {1,2, defaultFrameX = 2,frameDelay = 24},
            worried = {1,2, defaultFrameX = 3,frameDelay = 24},

            idleFront = {1,2, defaultFrameX = 4,frameDelay = 24},
            worriedFront = {1,2, defaultFrameX = 5,frameDelay = 24},

            turn = {1, defaultFrameX = 4,frameDelay = 4,loops = false},
        },startAnimation = "idle"}

        trainingCourseScenes.inviteScene.data.instructorToadActor = actor

        return actor
    end

    local function spawnPipe(x)
        local actor = trainingCourseScenes.inviteScene:spawnChildActor(x,pointBlocks.getPointY("pipeSpawnY") + 64)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/trainingCourseInvite/pipe.png")
        actor.spriteOffset = vector(0,64)
        actor.priority = -66
        actor:setSize(64,64)

        trainingCourseScenes.inviteScene.data.pipeActor = actor

        return actor
    end


    trainingCourseScenes.inviteScene.mainRoutineFunc = function(scene)
        -- Set up things
        trainingCourseScenes.inviteScene.answeredNo = false
        general.initSceneSpotlight(scene)

        -- Wait for the player to halt
        general.waitForPlayerToStop()

        -- Set up actors
        local luigiPartner = partners.getFirstByType("luigi")

        local mario = spawnMario(player.x + player.width*0.5,player.y + player.height)
        local luigi = spawnLuigi(luigiPartner.x + luigiPartner.width*0.5,luigiPartner.y + luigiPartner.height)

        scene:setPlayerIsInactive(true)
        luigiPartner.inactive = true

        -- Luigi walks behind Mario
        scene:runChildRoutine(function()
            local goal = mario.centre.x - 52

            Routine.wait(0.1)

            luigi:walkAndWait{
                goal = goal,speed = 1.8,setDirection = math.abs(goal - luigi.centre.x) > 8,
                walkAnimation = "walk",walkAnimationSpeed = 1.8,stopAnimation = "idle",
            }

            if luigi.direction == DIR_LEFT then
                luigi.direction = DIR_RIGHT
                luigi:setAnimation("turn")
                luigi:waitUntilAnimationFinished()
                luigi:setAnimation("idle")
            end
        end)

        Routine.wait(0.5)

        -- Pipe rises from the ground
        local pipe = spawnPipe(mario.bottomCentre.x - 32)

        scene:runChildRoutine(function()
            local goal = pointBlocks.getPointY("pipeSpawnY")
            local pipeMoveRoutine = scene:runChildRoutine(general.actorEasedMove, pipe, easing.outQuad,64, pipe.centre.x,goal)

            SFX.play(Misc.resolveSoundFile("_sound/misc/pipeExtend"))

            while (pipeMoveRoutine.isValid) do
                mario.floorY = pipe.y
                luigi.floorY = pipe.y
                Routine.skip()
            end
        end)

        scene:runChildRoutine(function()
            -- Mario reacts to the Funny pipe
            Routine.wait(0.2)

            SFX.play(Misc.resolveSoundFile("_sound/voice/mario/whohoa"))
            mario:setAnimation("ledgeTeetering")
            mario.direction = DIR_RIGHT

            Routine.wait(1.8)

            mario:setAnimation("idle")
            Routine.wait(0.4)

            mario.direction = DIR_LEFT
            mario:setAnimation("turn")
            mario:waitUntilAnimationFinished()
            mario:setAnimation("idle")
        end)

        scene:runChildRoutine(function()
            -- Luigi reacts to the Funny pipe
            Routine.wait(0.2)

            while (luigi.animator.currentAnimation ~= "idle") do
                Routine.skip()
            end

            luigi:setAnimation("surprisedLookDown")
        end)

        scene:runChildRoutine(function()
            Routine.wait(1.5)

            smatrsCamera.startCutsceneCamera()
            handycam[1]:transition{
                ease = handycam.ease(easing.inOutQuad),time = 1.5,
                targets = {pipe.bottomCentre - vector(0,112)},zoom = 2,
            }
        end)

        Routine.wait(2.5)

        -- Instructor toad guy appears
        local instructorToad = spawnInstructorToad(pipe.centre.x,pipe.y + 64)

        scene:runChildRoutine(function()
            -- Luigi steps back a little
            Routine.wait(0.3)
            
            luigi:walkAndWait{
                goal = pipe.centre.x - 32,speed = 1,setDirection = false,
                walkAnimation = "walk",walkAnimationSpeed = 1,stopAnimation = "idle",
            }
        end)

        SFX.play(17)
        instructorToad:setAnimation("idleFront")
        instructorToad.direction = DIR_RIGHT
        general.actorEasedMove(instructorToad, easing.outQuad,48, pipe.centre.x,pipe.y)
        instructorToad.priority = -29


        Routine.wait(0.2)
        instructorToad:setAnimation("idle")

        instructorToad:talkAndWait{text = sceneLanguageFile.formaT1}

        -- Response to question
        if scene.data.answeredNo then
            Routine.wait(0.1)

            SFX.play(17)
            instructorToad:setAnimation("worriedFront")
            instructorToad.priority = -67
            general.actorEasedMove(instructorToad, easing.inQuad,48, pipe.centre.x,pipe.y + 64)

            instructorToad.isInvisible = true

            Routine.wait(0.3)

            -- Camera move
            handycam[1]:transition{
                ease = handycam.ease(easing.inOutQuad),time = 1.5,
                targets = {},zoom = 1,
            }
            Routine.wait(1.2)

            -- Mario turns around
            scene:runChildRoutine(function()
                mario.direction = DIR_RIGHT
                mario:setAnimation("turn")
                mario:waitUntilAnimationFinished()
                mario:setAnimation("idle")
            end)

            -- Pipe retracts
            local pipeMoveRoutine = scene:runChildRoutine(general.actorEasedMove, pipe, easing.inQuad,48, pipe.centre.x,pipe.y + pipe.height + 64)

            SFX.play(Misc.resolveSoundFile("_sound/misc/pipeRetract"))

            while (pipeMoveRoutine.isValid) do
                mario.floorY = pipe.y
                mario:snapToFloor()
                luigi.floorY = pipe.y
                luigi:snapToFloor()
                Routine.skip()
            end

            -- Luigi walks back up to Mario
            local goal,_ = luigiPartner:getFollowIdlePosition()

            luigi:walkAndWait{
                goal = goal + luigiPartner.width*0.5,speed = 1.5,
                walkAnimation = "walk",walkAnimationSpeed = 1.5,stopAnimation = "idle",
            }

            Routine.wait(0.25)

            -- Back to gameplay!
            player.x = mario.x + (mario.width - player.width)*0.5
            player.y = mario.y + mario.height - player.height
            scene:setPlayerIsInactive(false)

            luigiPartner.x = luigi.x + (luigi.width - luigiPartner.width)*0.5
            luigiPartner.y = luigi.y + luigi.height - luigiPartner.height
            luigiPartner.inactive = false
            luigiPartner:resetFollowHistory()

            return
        end


        Routine.wait(0.2)

        -- Sorry, Luigi, no COWARDS allowed.
        instructorToad.direction = DIR_LEFT
        instructorToad:setAnimation("turn")
        instructorToad:waitUntilAnimationFinished()
        instructorToad:setAnimation("idle",0)
        
        Routine.wait(0.5)
        instructorToad:setAnimation("worried")

        instructorToad:talkAndWait{text = sceneLanguageFile.formaT2}

        -- Luigi jumps down because he's a COWARD
        scene:runChildRoutine(function()
            Routine.wait(0.2)

            handycam[1]:transition{
                ease = handycam.ease(easing.inOutQuad),time = 0.8,
                targets = {pipe.bottomCentre - vector(32,80)},
            }
        end)

        luigi.direction = DIR_LEFT
        luigi.floorY = nil

        SFX.play(1)
        luigi:jumpAndWait{
            goalX = pipe.x - 64,goalY = pipe.y + pipe.height,speedPerBlock = 0.8,
            setDirection = true,resetSpeed = true,setPosition = true,
            riseAnimation = "jump",fallAnimation = "fall",
        }
        general.spawnLandingDust(luigi.x + luigi.width*0.5,luigi.y + luigi.height)
        
        luigi.direction = DIR_RIGHT
        luigi:setAnimation("turn")
        luigi:waitUntilAnimationFinished()
        luigi:setAnimation("idle")
        Routine.wait(0.5)

        SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/byebye"))
        luigi:setAnimation("wave")
        instructorToad:setAnimation("idle")

        -- Instructor Toad goes down pipe
        Routine.wait(1)

        SFX.play(17)
        instructorToad:setAnimation("idleFront")
        instructorToad.priority = -67
        general.actorEasedMove(instructorToad, easing.inQuad,48, pipe.centre.x,pipe.y + 64)
        instructorToad.isInvisible = true

        -- Mario walks over to Luigi
        mario:walkAndWait{
            goal = pipe.centre.x - 24,speed = 1.5,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 1.5,stopAnimation = "idle",
        }
        Routine.wait(0.3)

        SFX.play(Misc.resolveSoundFile("_sound/voice/mario/oki doki"))
        mario:setAnimation("thumbsUp")
        mario:waitUntilAnimationFinished()
        Routine.wait(0.8)

        -- Mario walks back over to the pipe
        mario.direction = DIR_RIGHT
        mario:setAnimation("turn")
        mario:waitUntilAnimationFinished()

        mario:walkAndWait{
            goal = pipe.centre.x,speed = 1,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 1,stopAnimation = "idle",
        }
        Routine.wait(0.3)

        SFX.play(17)
        mario:setAnimation("frontFacing")
        mario.priority = -67
        mario.useAutoFloor = false
        mario.floorY = nil
        mario.gravity = 0
        mario.terminalVelocity = 0

        general.actorEasedMove(mario, easing.inQuad,48, pipe.centre.x,pipe.y + 64)
        mario.isInvisible = true

        -- Spotlight out
        scene.data.spotlightCentre = pipe.bottomCentre - vector(0,64)
        scene.data.spotlightRadius = 768

        scene:runChildRoutine(general.fadeOutMusic, 64,true)
        general.transitionSceneSpotlight(scene, easing.outSine,80, scene.data.spotlightCentre,0,1)

        -- Teleport to training course
        local startPoint = pointBlocks.getPoint("trainingCourseStart")
        
        mario.bottomCentre = startPoint + vector(0,64)
        mario.isInvisible = false

        scene.data.spotlightCentre = startPoint - vector(0,24)
        player:teleport(startPoint.x,startPoint.y,true)

        Layer.get("training course return pipe"):show(true)

        scene.hasBars = false
        scene.barsEnterProgress = 0

        smatrsCamera.stopCutsceneCamera(0)

        Routine.wait(0.5)

        -- Spotlight opens slightly
        SFX.play(Misc.resolveSoundFile("_sound/misc/spotlight_in"))
        general.transitionSceneSpotlight(scene, easing.outSine,24, scene.data.spotlightCentre,80,1)

        -- Mario exits pipe
        Routine.wait(0.25)

        music.preventMusicNameUpdate = true
        music.volumeModifier = 1
        music.forceMute = false

        SFX.play(17)
        general.actorEasedMove(mario, easing.outQuad,48, startPoint.x,startPoint.y)

        scene:setPlayerIsInactive(false)
        mario:remove()

        Routine.wait(1)

        -- Spotlight opens fully
        SFX.play(Misc.resolveSoundFile("_sound/misc/spotlight_finish"))
        general.transitionSceneSpotlight(scene, easing.inSine,64, scene.data.spotlightCentre,512,0)

        Routine.wait(0.25)

        music.preventMusicNameUpdate = false
    end


    trainingCourseScenes.inviteScene.drawFunc = function(scene)
        general.drawSceneSpotlight(scene)
    end

    trainingCourseScenes.inviteScene.stopFunc = function(scene)
        smatrsCamera.stopCutsceneCamera(0)
        handycam[1]:release()

        --smatrsPlayer.generalSettings.mostlyIgnoreSecondPlayer = false
        --playerTeleportation.rematerialise{atSafeSpot = true}
    end
end


-- Return scene
do
    trainingCourseScenes.returnScene = cutscenePal.newScene("trainingCourseReturn")
    trainingCourseScenes.returnScene.canSkip = true

    local function spawnMario(x,y)
        local actor = trainingCourseScenes.returnScene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/trainingCourseReturn/mario.png")
        smatrsPlayer.setUpPlayerActor(actor)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},

            walk = {1,2,3,4,5,6, defaultFrameX = 2,frameDelay = 8},

            jump = {1,2, defaultFrameX = 3,frameDelay = 4,loops = false},
            fall = {3,4, defaultFrameX = 3,frameDelay = 4,loops = false},
        },startAnimation = "idle"}

        actor.useAutoFloor = true
        actor.gravity = 0.4
        actor.terminalVelocity = 12

        trainingCourseScenes.inviteScene.data.marioActor = actor

        return actor
    end
    
    local function spawnLuigi(x,y)
        local actor = trainingCourseScenes.returnScene:spawnChildActor(x,y)

        actor.image = Graphics.loadImageResolved("_graphics/cutscenes/trainingCourseReturn/luigi.png")
        actor.spriteOffset = vector(0,22)
        actor.priority = -28
        actor:setSize(24,54)
        actor:setFrameSize(100,100)

        actor:setUpAnimator{animationSet = {
            idle = {1,2,3,4, defaultFrameX = 1,frameDelay = 12},
            lookUp = {5, defaultFrameX = 1},

            coffee = {1,2,3,2,1,4,5,4,1,1,1, defaultFrameX = 2,frameDelay = 12},

            jump = {1,2, defaultFrameX = 3,frameDelay = 4,loops = false},
            fall = {3,4, defaultFrameX = 3,frameDelay = 4,loops = false},
        },startAnimation = "coffee"}

        actor.useAutoFloor = true
        actor.gravity = 0.3
        actor.terminalVelocity = 12

        trainingCourseScenes.returnScene.data.luigiActor = actor

        return actor
    end

    trainingCourseScenes.returnScene.mainRoutineFunc = function(scene)
        -- Setup
        local playerPoint = pointBlocks.getPoint("trainingCourseReturn_playerExit")
        local luigiPartner = partners.getFirstByType("luigi")

        scene.hasBars = false
        scene.canSkip = false

        -- Camera setup
        smatrsCamera.startCutsceneCamera()
        handycam[1].targets = {pointBlocks.getPoint("trainingCourseReturn_cameraFocus")}
        handycam[1].zoom = 1.5

        -- Luigi
        local luigi = spawnLuigi(playerPoint.x - 48,playerPoint.y)

        -- Wait for the player to finish getting out of the pipe
        player.direction = DIR_RIGHT

        while (player.forcedState ~= FORCEDSTATE_NONE) do
            Routine.skip()
        end

        scene.hasBars = true
        scene.canSkip = true

        -- Mario actor replaces player
        local mario = spawnMario(player.x + player.width*0.5,player.y + player.height)

        scene:setPlayerIsInactive(true)

        -- Luigi gets up
        Routine.wait(1)

        scene:runChildRoutine(function()
            luigi.direction = DIR_LEFT

            SFX.play(1)
            luigi:jumpAndWait{
                speedX = 0,speedY = -6,
                riseAnimation = "jump",fallAnimation = "fall",landAnimation = "lookUp",
            }
            general.spawnLandingDust(luigi.x + luigi.width*0.5,luigi.y + luigi.height)

            SFX.play(Misc.resolveSoundFile("_sound/voice/luigi/okidoki"))
        end)

        -- Mario jumps over
        Routine.wait(1.5)

        scene:runChildRoutine(function()
            Routine.wait(0.25)

            handycam[1]:transition{
                ease = handycam.ease(easing.inOutQuad),time = 0.75,
                targets = {playerPoint},
            }

            Routine.wait(0.25)

            luigi.direction = DIR_RIGHT
            Routine.wait(0.75)
            luigi:setAnimation("idle")
        end)

        mario:walkAndWait{
            goal = mario.x + mario.width*0.5 + 20,speed = 1.5,setDirection = true,
            walkAnimation = "walk",walkAnimationSpeed = 1.5,
        }

        SFX.play(1)
        mario:jumpAndWait{
            goalX = playerPoint.x,goalY = playerPoint.y,speedPerBlock = 0.6,
            resetSpeed = true,setPosition = true,setDirection = true,
            riseAnimation = "jump",fallAnimation = "fall",landAnimation = "idle",
        }
        general.spawnLandingDust(mario.x + mario.width*0.5,mario.y + mario.height)

        -- Zoom out to normal camera
        handycam[1]:transition{
            ease = handycam.ease(easing.inOutQuad),time = 1,
            zoom = 1,
        }
        
        cutscenePal.waitUntilTransitionFinished()
        Routine.wait(0.25)
    end

    trainingCourseScenes.returnScene.stopFunc = function(scene)
        local playerPoint = pointBlocks.getPoint("trainingCourseReturn_playerExit")
        local luigiPartner = partners.getFirstByType("luigi")

        player:teleport(playerPoint.x,playerPoint.y,true)
        scene:setPlayerIsInactive(false)

        luigiPartner.x,luigiPartner.y = luigiPartner:getFollowIdlePosition()
        luigiPartner:resetFollowHistory()
        luigiPartner.inactive = false

        smatrsCamera.stopCutsceneCamera(0)
    end
end


local rematerialiseWaiting = false


function trainingCourseScenes.onWarpEnter(eventObj,warp,p)
    if warp.idx == 1 then -- going back from training course
        if p.idx > 1 then
            eventObj.cancelled = true
        end
    end
end

function trainingCourseScenes.onPostWarpEnter(warp,p)
    if warp.idx == 1 then -- going back from training course
        playerTeleportation.dematerialise{}
    end
end

function trainingCourseScenes.onWarp(warp,p)
    if warp.idx == 1 then -- going back from training course
        smatrsPlayer.generalSettings.mostlyIgnoreSecondPlayer = true
        trainingCourseScenes.returnScene:start()

        funnySounds.enabled = true
    elseif warp.idx == 2 then -- going into from training course
        local luigiPartner = partners.getFirstByType("luigi")

        luigiPartner.inactive = true
        funnySounds.enabled = false

        if SaveData.sawMultiplayerIntro then
            smatrsPlayer.generalSettings.mostlyIgnoreSecondPlayer = false
            rematerialiseWaiting = true
        end
    end
end


function trainingCourseScenes.onTick()
    if rematerialiseWaiting and player.forcedState == FORCEDSTATE_NONE then
        playerTeleportation.rematerialise{atSafeSpot = true}
        rematerialiseWaiting = false
    end
end


function trainingCourseScenes.onInitAPI()
    registerEvent(trainingCourseScenes,"onWarpEnter")
    registerEvent(trainingCourseScenes,"onPostWarpEnter")
    registerEvent(trainingCourseScenes,"onWarp")
    registerEvent(trainingCourseScenes,"onTick")
end


return trainingCourseScenes