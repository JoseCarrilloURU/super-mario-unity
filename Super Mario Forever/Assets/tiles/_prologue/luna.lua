local GP = require("_scripts/GroundPound")
local extraBGOProperties = require("_scripts/extraBGOProperties")
local wavyWater = require("_scripts/wavyWater")
local bgoTemplates = require("_scripts/smatrs_bgoTemplates")

local dynamicBackgrounds = require("_scripts/dynamicBackgrounds")

local smatrsPlayer = require("_scripts/smatrs_player")

local playerTeleportation = require("_scripts/smatrs_playerTeleportation")
local pipeEntrances = require("_scripts/smatrs_pipeEntrances")

local levelStart = require("_scripts/smatrs_levelStart")

local trainingCourseScenes = require("trainingCourseScenes")
local prologueScenes = require("prologueScenes")

local bookSceneSetup = require("_scripts/smatrs_bookSceneSetup")
local bookIntro = require("bookIntroScene")

local mainMenu = require("_scripts/smatrs_mainMenu")
local music = require("_scripts/smatrs_music")

local chapterIntro = require("_scripts/smatrs_chapterIntro")

local partners = require("_scripts/smatrs_partners")
local luigi = require("_scripts/partner_luigi")

local pauseSetup = require("_scripts/smatrs_pause_setup")

smatrsPlayer.generalSettings.slowMode = false
levelStart.enabled = false
levelStart.transitionEnabled = false

pauseSetup.haveRestartOption = false
pauseSetup.haveExitOption = false

pipeEntrances.dontTeleportOtherPlayersMap[2] = true
pipeEntrances.dontTeleportOtherPlayersMap[3] = true


wavyWater.registerSection(4,{
    image = Graphics.loadImageResolved("_graphics/wavyWater/lava.png"),
    frames = 1,framespeed = 8,
    waveFrequency = 180,
    height = 64,
})

wavyWater.registerSection(6,{
    image = Graphics.loadImageResolved("_graphics/wavyWater/lava.png"),
    frames = 1,framespeed = 8,
    waveFrequency = 180,
    height = 160 - 16,
})

wavyWater.registerSection(1,{
    image = Graphics.loadImageResolved("_graphics/wavyWater/sunset2.png"),
    frames = 6,framespeed = 8,

    height = 64,
    waveFrequency = 180,
    drawToBuffer = true,

    reflectionStrength = 0.25,
})

-- BGO setup
bgoTemplates.registerBush{27}

extraBGOProperties.registerID(80,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*2)*10
    end,

    pivotY = 1.0,

  
})

extraBGOProperties.registerID(67,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*2)*10
    end,

    pivotY = 1.0,

})

extraBGOProperties.registerID(81,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*2)*10
    end,

    pivotY = 1.0,

})

extraBGOProperties.registerID(75,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(55,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*2)*10
    end,

    pivotY = 1.0,

})

extraBGOProperties.registerID(56,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*2)*10
    end,

    pivotY = 1.0,

})

extraBGOProperties.registerID(54,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*2)*10
    end,

    pivotY = 1.0,

})


extraBGOProperties.registerID(156,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = t*60
    end,

    pivotY = 0.5,
    pivotX = 0.5,

})




extraBGOProperties.registerID(99,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1.0,

  
})

extraBGOProperties.registerID(246,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1.0,

  
})

extraBGOProperties.registerID(275,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(276,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(277,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(337,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(338,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(63,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(62,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(339,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})

extraBGOProperties.registerID(239,{
    movementFunc = function(v,t)
        local data = extraBGOProperties.getData(v)

        data.rotation = math. sin(t*1)*5
    end,

    pivotY = 1,
    pivotX = 0.5,
    offsetY = 0.125,

})


-- Background setup
dynamicBackgrounds.registerLayer(8,"water",function(layer,sectionObj,cameraObj)
    local uniforms = layer.uniforms

    uniforms.topParallax = 0.35
    uniforms.bottomParallax = 1

    uniforms.topAlpha = 1
    uniforms.bottomAlpha = 1

    uniforms.textureSize = vector(layer.image.width,layer.image.height)
    uniforms.scroll = (camera.x - sectionObj.origBoundary.left) + lunatime.tick()*0.5

    uniforms.stepSize = 12
end)


local function setUpPlayersForBook()
    for _,p in ipairs(Player.get()) do
        p.section = 5
        p.forcedState = FORCEDSTATE_INVISIBLE
        p.forcedTimer = 0

        p.x = p.sectionObj.boundary.left
        p.y = p.sectionObj.boundary.top
    end

    Graphics.activateHud(false)
end

local function startBookScene()
    setUpPlayersForBook()

    bookSceneSetup.initialise()
    bookSceneSetup.cameraPosition = bookIntro.menuCameraPosition
    bookSceneSetup.cameraRotation = bookIntro.menuCameraRotation
    bookIntro.scene:start()
end

local function startBookTrailerScene()
    setUpPlayersForBook()

    bookSceneSetup.initialise()
    bookIntro.trailerScene:start()
end

local function startBookOpeningMenu()
    setUpPlayersForBook()

    bookSceneSetup.initialise()
    bookSceneSetup.cameraPosition = bookIntro.menuCameraPosition
    bookSceneSetup.cameraRotation = bookIntro.menuCameraRotation

    mainMenu.init()
    mainMenu.start(true)

    mainMenu.smoothTransitionOut = true
    mainMenu.startGameFunc = function()
        bookIntro.scene:start()
    end
end

function onStart()
    prologueScenes.initBoardingStuff()
    
    if Misc.inEditor() then
        --playerTeleportation.dematerialise{instant = true}

        --partners.create("luigi",player,false).inactive = true
        --partners.create("luigi",player,false)

        --prologueScenes.houseScene:start()
        --prologueScenes.castleScene:start()
        --prologueScenes.townScene:start()
        --prologueScenes.crashScene:start()

        --player.section = 5
        --chapterIntro.scene.data.chapter = 1
        --chapterIntro.scene:start()

        --startBookScene()
        startBookOpeningMenu()
        --startBookTrailerScene()
    else
        --prologueScenes.houseScene:start()
        startBookOpeningMenu()
    end

    smatrsPlayer.generalSettings.mostlyIgnoreSecondPlayer = true
    
    for _,p in ipairs(Player.get()) do
        if p.idx > 1 then
            p.data.cameraWeight = 0
        end
    end
end


function onSectionChange(sectionIdx,p)
    smatrsPlayer.generalSettings.slowMode = (sectionIdx ~= 7)
end

function onWarp(warp,p)
    smatrsPlayer.generalSettings.slowMode = (p.section ~= 7)
end


-- Toad town dialogue scenes
local genericDiscussion = require("_scripts/smatrs_genericDiscussion")
local languageFiles = require("_scripts/languageFiles")

do
    local discussionsLanguageFile = languageFiles("discussions/prologue_toadTown")

    genericDiscussion.register("toad1",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad1)
    end)

    genericDiscussion.register("toad2",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad2)
    end)

    genericDiscussion.register("toad3",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad3)
    end)

    genericDiscussion.register("toad4",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad4)
    end)

    genericDiscussion.register("toad5",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad5)
    end)

    genericDiscussion.register("toad6",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad6)
    end)

    genericDiscussion.register("toad7",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad7)
    end)

    genericDiscussion.register("toad8",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad8)
    end)

    genericDiscussion.register("toad9",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad9)
    end)

    genericDiscussion.register("todd",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)

        genericDiscussion.npcTalk(npc,discussionsLanguageFile.todd)

    end)

    genericDiscussion.register("toad10",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad10)
    end)

    genericDiscussion.register("toad11",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad11)
    end)

    genericDiscussion.register("bup",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.bup)
    end)

    genericDiscussion.register("toad12",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad12)
    end)

    genericDiscussion.register("toad13",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad13)
    end)

    genericDiscussion.register("toad14",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.toad14)
    end)
end

-- Training course dialogue scenes
do
    local discussionsLanguageFile = languageFiles("discussions/prologue_trainingCourse")

    genericDiscussion.register("formaT",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.formaT)
    end)

    genericDiscussion.register("formaT_postMultiplayerIntro",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.formaT_postMultiplayerIntro)
    end)

    genericDiscussion.register("sign1",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign1)
    end)

    genericDiscussion.register("sign2",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign2)
    end)

    genericDiscussion.register("sign3",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign3)
    end)

    genericDiscussion.register("sign4",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign4)
    end)

    genericDiscussion.register("sign5",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign5)
    end)

    genericDiscussion.register("sign6",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign6)
    end)

    genericDiscussion.register("sign7",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign7)
    end)

    genericDiscussion.register("sign8",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.sign8)
    end)

    genericDiscussion.register("signflip",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.signflip)
    end)

    genericDiscussion.register("killboard",function(npc)
        genericDiscussion.zoomToNPC(npc,1.5)
        genericDiscussion.walkInFront(npc,-48)
        genericDiscussion.npcTalk(npc,discussionsLanguageFile.killboard)
    end)

end

-- Talk icons
do
    local npcTalkIcon = require("_scripts/npc/npcTalkIcon")

    npcTalkIcon.register(758,"normal")
    npcTalkIcon.register(107,"normal")
    npcTalkIcon.register(118,"normal")
    npcTalkIcon.register(136,"normal")
    npcTalkIcon.register(156,"normal")
    npcTalkIcon.register(94,"normal")
    npcTalkIcon.register(117,"normal")
    npcTalkIcon.register(198,"normal")
    npcTalkIcon.register(851,"normal")
end