local bookSceneSetup = require("_scripts/smatrs_bookSceneSetup")

local littleDialogue = require("_scripts/littleDialogue")
local cutscenePal = require("_scripts/cutscenePal")

local languageFiles = require("_scripts/languageFiles")

local easing = require("ext/easing")

local general = require("_scripts/generalStuff")
local music = require("_scripts/smatrs_music")

local prologueScenes = require("prologueScenes")

local bookIntro = {}



local sceneLanguageFile = languageFiles("cutscenes/bookIntro")

local textPageCounts = {
    -- This list contains the number of text boxes to display for each page and the amount of time to wait before turning.
    {boxPages = 2,waitTimes = {311,253},extraWaitTime = 0},
    {boxPages = 2,waitTimes = {254,211},extraWaitTime = 0},
    {boxPages = 2,waitTimes = {288,297},extraWaitTime = 0},
    {boxPages = 2,waitTimes = {300,293},extraWaitTime = 0},
    {boxPages = 2,waitTimes = {300,293},extraWaitTime = 0},
    {boxPages = 1,waitTimes = {302},extraWaitTime = 0.75},
    {boxPages = 4,waitTimes = {197,249,271,211},extraWaitTime = 0},
    {boxPages = 1,waitTimes = {278},extraWaitTime = 0},
    {boxPages = 2,waitTimes = {320,309},extraWaitTime = 0},
    {boxPages = 1,waitTimes = {330},extraWaitTime = 1.25},
}


bookIntro.scene = cutscenePal.newScene("bookIntro")
bookIntro.scene.canSkip = true


local function playTurnSound()
    SFX.play(RNG.irandomEntry(bookIntro.scene.data.bookTurnSounds))
end


bookIntro.menuCameraPosition = vector(0,0,-600):rotate(-15,45,0) + vector(155,-65,0)
bookIntro.menuCameraRotation = vector(-15,45,0)

bookIntro.initialCameraPosition = vector(0,0,-500):rotate(-15,45,0) + vector(0,-65,0)
bookIntro.initialCameraRotation = vector(-15,45,0)


bookIntro.scene.barsEnterDuration = 48

bookIntro.scene.mainRoutineFunc = function(scene)
    --bookSceneSetup.initialise()

    general.initSceneFade(scene)
    --scene.data.fadeOpacity = 1
    --scene.barsEnterProgress = 1

    scene.hasBars = false
    scene.canSkip = false

    scene.data.bookTurnSounds = {
        Misc.resolveSoundFile("_sound/misc/book_pageTurn_1"),
        Misc.resolveSoundFile("_sound/misc/book_pageTurn_2"),
        Misc.resolveSoundFile("_sound/misc/book_pageTurn_3"),
    }

    -- Set camera position
    --bookSceneSetup.cameraPosition = bookIntro.initialCameraPosition
    --bookSceneSetup.cameraRotation = bookIntro.initialCameraRotation

    scene:runChildRoutine(bookSceneSetup.transitionCameraPosition, bookIntro.initialCameraPosition,easing.inOutSine,128)
    scene:runChildRoutine(bookSceneSetup.transitionCameraRotation, bookIntro.initialCameraRotation,easing.inOutSine,128)


    --Routine.wait(0.2)
    --general.transitionSceneFadeOpacity(scene, 64,0)
    Routine.wait(2)

    scene.hasBars = true
    scene.canSkip = true
    Routine.wait(1.5)

    music.forcedMusicPath = "_music/opening.ogg"
    music.volumeModifier = 1
    music.forceMute = false
    Routine.wait(1)

    -- Open dialogue box
    scene.data.box = littleDialogue.create{
        text = sceneLanguageFile.mainText,
        uncontrollable = true,
        --silent = true,
        pauses = false,
        forcedPosX = camera.width*0.5,
        forcedPosY = camera.height - 16,
        forcedPosHorizontalPivot = 0.5,
        forcedPosVerticalPivot = 1,
        settings = {
            useMaxWidthAsBoxWidth = true,
            openSoundEnabled = false,
            scrollSoundEnabled = false,
            closeSoundEnabled = false,
        },
    }

    scene:runChildRoutine(function()
        Routine.waitFrames(442)
        scene.data.box:progress()
    end)

    Routine.wait(0.75)

    -- Rotate camera to the front of the book
    scene:runChildRoutine(bookSceneSetup.rotateAroundPoint, vector(-25,0,0),vector(-50,0,0),1,easing.inOutQuad,512)
    Routine.wait(1)
    scene:runChildRoutine(bookSceneSetup.transitionBookCoverRotation, -190,easing.inOutQuad,384)
    Routine.wait(7)

    scene:runChildRoutine(function()
        for i = 1,6 do
            bookSceneSetup.turnPage(vector(2,1),vector(1,1),64)
            playTurnSound()
            Routine.wait(0.2)
        end
    
        bookSceneSetup.turnPage(vector(2,1),vector(1,2),80)
        playTurnSound()
        Routine.wait(0.2)
        bookSceneSetup.turnPage(vector(2,2),vector(1,3),112)
        playTurnSound()
    end)

    Routine.wait(1.5)

    scene:runChildRoutine(bookSceneSetup.transitionCameraPosition, vector(-50,-bookSceneSetup.camera.flength*0.5 - 25,-12):rotate(0,0,0),easing.inOutQuad,192)
    scene:runChildRoutine(bookSceneSetup.transitionCameraRotation, vector(-90,0,0),easing.inOutQuad,192)

    Routine.waitFrames(128)
    scene.data.box:progress()


    local pageFrame = 3

    for index,data in ipairs(textPageCounts) do
        local textPageTimes = {}

        for i = 1,data.boxPages do
            Routine.waitFrames(data.waitTimes[i])
            scene.data.box:progress()
        end

        Routine.wait(data.extraWaitTime)

        if index < #textPageCounts then
            bookSceneSetup.turnPage(vector(2,pageFrame),vector(1,pageFrame + 1))
            playTurnSound()
            pageFrame = pageFrame + 1
        end
    end

    Routine.wait(1.5)

    scene:runChildRoutine(bookSceneSetup.rotateAroundPoint, vector(-20,0,0),vector(-50,0,0),1.25,easing.inQuad,256)
    Routine.waitFrames(96)

    scene.canSkip = false
    general.transitionSceneFadeOpacity(scene, 160,1)
    Routine.wait(9)
end

bookIntro.scene.skipRoutineFunc = function(scene)
    Routine.run(general.fadeOutMusic, 48,true)
end

bookIntro.scene.stopFunc = function(scene)
    if scene.data.box ~= nil and scene.data.box.isValid then
        scene.data.box.state = littleDialogue.BOX_STATE.REMOVE
    end

    bookSceneSetup.deinitialise()

    player.forcedState = FORCEDSTATE_NONE
    player.forcedTimer = 0
    
    prologueScenes.houseScene:start()
end

bookIntro.scene.drawFunc = function(scene)
    general.drawSceneFade(scene)
end


bookIntro.trailerScene = cutscenePal.newScene("bookTrailer")

bookIntro.trailerScene.canSkip = false
bookIntro.trailerScene.hasBars = false

bookIntro.trailerScene.mainRoutineFunc = function(scene)
    general.initSceneFade(scene)
    scene.data.fadeOpacity = 1

    bookSceneSetup.cameraRotation = bookIntro.menuCameraRotation
    bookSceneSetup.cameraPosition = bookIntro.menuCameraPosition + vector.quat(0,bookSceneSetup.cameraRotation.y,0)*vector(-128,0,0)

    Routine.wait(1)
    
    scene:runChildRoutine(general.transitionSceneFadeOpacity, scene, 160,0)
    scene:runChildRoutine(bookSceneSetup.transitionCameraPosition, bookIntro.menuCameraPosition,easing.outQuad,192)

    Routine.wait(1000)
end

bookIntro.trailerScene.drawFunc = function(scene)
    general.drawSceneFade(scene)
end


return bookIntro