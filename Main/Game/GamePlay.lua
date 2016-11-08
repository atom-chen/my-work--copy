----
-- 文件名称：GamePlay.lua
-- 功能描述：游戏中 GameFishPlay，给捕鱼游戏使用的
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-14
--  修改：

local GameMainScene = require("Main.Logic.GameMainScene")
--性能分析
 require("Main.Utility.Profiler")
 local profiler = newProfiler()

local osClock = os.clock
--游戏状态
local GamePlayState = 
{
    --预加载资源
    LOAD_SCENE_RESOURCE = 0,
    LOAD_SCENE_lOADING = 1,
    --游戏中
    GAME_PLAYING = 2,
}

local GamePlay = class("GamePlay")
local mathCeil = math.ceil
--构造函数
function GamePlay:ctor()
    --当前游戏状态
    self._CurrentGameState = 0
    --Scene
    self._RootScene = nil
    --当前已加载数目 
    self._CurrentLoadedCount = 0
    --需加载的数目
    self._LoadCount = 0
    --游戏场景
    self._GameMainScene = nil
    --当前选中游戏的表格配置数据
    self._GameCfgData = nil
end

--初始化
function GamePlay:Init()
    collectgarbage("stop")
    --display为cocos framwwork的
    self._RootScene = display.newScene()
    display.runScene(self._RootScene)
    self._RootScene:retain()
    --初始化UI相关
    local uiRootNode = UISystem:GetUIRootNode()
    if uiRootNode ~= nil then  
        uiRootNode:removeFromParent(false)
        self._RootScene:addChild(uiRootNode, 1000)
    end
    UISystem:CloseAllUI()
    self._GameCfgData = TableDataManager._GameConfigData[ServerDataManager._CurSelGameID]
    local fishXml = self._GameCfgData.fishXmlName
    local pathXml = self._GameCfgData.pathXmlName
    TableDataManager:InitGameCfg(fishXml, pathXml)

    self:SetGamePlayState(GamePlayState.LOAD_SCENE_RESOURCE)
end

--销毁
function GamePlay:Destroy()
    print("GamePlay:Destroy--------------------------------")

    self._GameCfgData = nil

    if self._GameMainScene ~= nil then
        self._GameMainScene:Destroy()
        self._GameMainScene = nil
    end

    if self._RootScene ~= nil then
        self._RootScene:removeAllChildren(true)
        self._RootScene:release()
        self._RootScene = nil
    end

    --卸载掉UI
    UISystem:UnloadUI(UIType.UIType_GameScene)
    UISystem:UnloadUI(UIType.UIType_FishHelp)
    UISystem:UnloadUI(UIType.UIType_FishQuit)
    local textureCache =  cc.Director:getInstance():getTextureCache()
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:removeUnusedSpriteFrames()
    textureCache:removeUnusedTextures()
    collectgarbage("restart")

    --[[
    profiler:stop()
    local outfile = io.open( "profile.txt", "w+" )
    profiler:report( outfile )
    outfile:close()
    ]]--

    --textureCache:getCachedTextureInfo()
end

--获取 GameScene
function GamePlay:GetGameScene()
    return self._GameMainScene
end

--设置游戏状态
function GamePlay:SetGamePlayState(newState)
    self._CurrentGameState = newState
    --print("GamePlay:SetGamePlayState", newState)

    --预加载资源到缓存
    if self._CurrentGameState == GamePlayState.LOAD_SCENE_RESOURCE then
        local loadUIInstance = UISystem:OpenUI(UIType.UIType_GameLoading)

        self._CurrentLoadedCount = 0
        self._LoadCount = 0
        local resourcePrefix = self._GameCfgData.artPrefixName
        local loadingBgName = self._GameCfgData.loadBgName
        loadUIInstance:SetBgImage(loadingBgName)
        --预加载的资源
        local fishImages = TableDataManager._GameFishXmlData.client.fishimages
        if fishImages == nil then
            print("fishImages == nil")
        end
        self._LoadCount = #fishImages.file
        local textureCache = cc.Director:getInstance():getTextureCache()
        local function ImageLoaded(texture)
            self._CurrentLoadedCount = self._CurrentLoadedCount + 1
            --print("currentLoaded ", self._CurrentLoadedCount)
            local currentFileData =  fishImages.file[self._CurrentLoadedCount]
            if currentFileData ~= nil then
                cc.SpriteFrameCache:getInstance():addSpriteFrames(resourcePrefix .. currentFileData._attr.plist)
            end
            local curPercent = mathCeil(self._CurrentLoadedCount / self._LoadCount * 100)
            loadUIInstance:SetProgress(curPercent)
        end

        for k, v in pairs(fishImages.file)do
            local attr = v._attr
            if  attr ~= nil then
                textureCache:addImageAsync(resourcePrefix .. attr.png, ImageLoaded)
            end
        end
        self._CurrentGameState = GamePlayState.LOAD_SCENE_lOADING

    elseif self._CurrentGameState == GamePlayState.GAME_PLAYING then
        if self._GameMainScene == nil then
            self._GameMainScene = GameMainScene.new(self._RootScene, self._GameCfgData.artPrefixName)
        end
        local currentUI = UISystem:OpenUI(UIType.UIType_GameScene, self._GameMainScene)
        self._GameMainScene:Init()
        currentUI:SetCurrentScene(self._GameMainScene)
        currentUI:SetVisible(false)
        --
        local newPacket = require("Main.NetSystem.Packet.CSGFGameOption").new()
        NetSystem:SendGamePacket(newPacket)
        local readyPacket = require("Main.NetSystem.Packet.CSGFUserReady").new()
        NetSystem:SendGamePacket(readyPacket)
        local buyBulletPacket = require("Main.NetSystem.Packet.CSGFBuyBullet").new()
        local selfScore = ServerDataManager._SelfUserInfo._lUserScore
        print("selfScore ", selfScore)
        buyBulletPacket._lScore = selfScore
        buyBulletPacket._bAdd = 1
        NetSystem:SendGamePacket(buyBulletPacket)
    end
end

--帧更新
local timer = 0

function GamePlay:Update(deltaTime)
    --local time = osClock()
    --[[
    timer = timer + 1
    if timer == 1 then
        profiler:start()
    end
    ]]--
    
    if self._CurrentGameState == GamePlayState.LOAD_SCENE_lOADING then
        if self._CurrentLoadedCount == self._LoadCount then
            self:SetGamePlayState(GamePlayState.GAME_PLAYING)
        end
    elseif self._CurrentGameState == GamePlayState.GAME_PLAYING then
        if self._GameMainScene ~= nil then
            self._GameMainScene:Update(deltaTime)
        end
        --[[
        --打印测试信息
        local endTime = osClock()
        local useTime = endTime - time
        if timer > 10 then
            timer = 0
            local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
            if gameSceneUI ~= nil then
                local loginTime = 0
                local gameTime = 0
                if NetSystem._LoginSocket ~= nil then
                    loginTime = NetSystem._LoginSocket._NetUseTimer
                end
                if NetSystem._GameSocket ~= nil then
                    gameTime = NetSystem._GameSocket._NetUseTimer
                end

                local showStr = string.format("           PlayTime: %.3f net: %.3f, %.3f ", useTime, loginTime, gameTime)
                gameSceneUI._TextTest:setString(showStr)
            end
        end
       ]]--
    end
end


return GamePlay