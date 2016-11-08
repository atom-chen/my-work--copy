----
-- 文件名称：GameMainScene.lua
-- 功能描述：游戏主场景
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-11
--  修改：

local require = require
local GameFishManager = require("Main.Logic.GameFishManager")
local GameBulletManager = require("Main.Logic.GameBulletManager")
local armatureManager = ccs.ArmatureDataManager:getInstance()

local ServerDataManager = ServerDataManager
local UISystem = UISystem
local FishSoundDefine = FishSoundDefine
local SoundPlay = SoundPlay
--local AngleRectIsCollisionPt = AngleRectIsCollisionPt
local PtInRectLua = PtInRectLua
local mathAbs = math.abs
local StringFormat = string.format
local tableInsert = table.insert
local tableRemove = table.remove
local mathMax = math.max
local mathAbs = math.abs
local mathFloor = math.floor
local mathCeil = math.ceil
local mathRandom = math.random
local osClock = os.clock
local pairs = pairs
local selfScene = nil
--垃圾收集时间间隔
local GC_TIME = 20
local ZERO_PT = cc.p(0, 0)
local CENTER_PT = cc.p(0.5, 0.5)
--延时创建的鱼
local DelayFishData = class("DelayFishData")
function DelayFishData:ctor()
    --数据
    self._CurDelayTime = 0
    self._nSpriteID = 0
    self._nServerID = 0
    self._nPathType = 0
    self._nXPos = 0
    self._nYPos = 0
    self._wActionID = 0
    self._speedArray = 0
    self._moveTimeArray = 0
    self._rotationArray = 0
    self._pointArray = 0
    self._cbProperty = 0
    self._wMultiple = 0
end

--锁鱼
local LockFishInfo = class("LockFishInfo")
function LockFishInfo:ctor()
    --椅子号(从0开始的)
    self._wChairID = 0
    --服务器ID
    self._LockFishServerID = 0
    --客户端ID
    self._LockFishClientID = 0
end



--格子大小
local  TILES_SIZE_Y = 360
local TILES_SIZE_X = 360

local GameMainScene = class("GameMainScene")

--rootScene：ccscene,  resPrefix:资源前缀 
function GameMainScene:ctor(rootScene, resPrefix)
	--root scene
	self._RootScene = rootScene
    --资源 前缀
    self._ResPrefixName = resPrefix
    --root node
    self._RootNode = nil
    --Fish 根节点
    self._FishRootNodeTable = nil
    --Bullet根节点
    self._BulletRootNode = nil
    --渔网根节点
    self._FishNetRootNode = nil
    --特效节点
    self._NetEffectNode = nil
    --金币节点
    self._GoldNode = nil
    --场景背景
    self._SceneBgSprite = nil
    self._SceneBgSprite2 = nil
    --背景水波
    self._WaterNode = nil
    --切场景时的水波
    self._ArmatureWave = nil
    --自动开炮
    self._IsAutoShoot = true
    --是否切换场景
    self._IsChangeSceneing = false
    --切换场景逻辑计时
    self._ChangeSceneTimer = 0
	-----测试---------
    self._AutoShootTimer = 0
    --延时创建的鱼
    self._DelayFishList = nil
    --当前场景索引
    self._CurentSceneIndex = 0
    --测试性能Timer
    self._ProfileTimer = 0
    --锁鱼信息
    self._LockFishInfoList = 0
    --锁鱼的动画Sprite(不停转的圆圈)
    self._LockFishSpriteList = 0
    --Shoot interval
    self._ShootInterval = 0.25
    self._IsAddSpeed = false
    --金币空闲队列
    self._FreeGoldList = 0
    --金币使用队列
    self._UsedGoldList = 0
    --缓存的动画名字列表(鱼网，金币，鱼，子弹等)
    --空闲渔网列表
    self._FreeFishNetList = 0
    --渔网粒子列表
    self._FreeNetEffectList = 0
    --大鱼特效节点
    self._BigFishEffectNode = nil
    self._BigFishParticle = nil
    --缓存消息包
    self._ShootPacket = 0
    self._HitFishPacket = 0
    self._CacheAnimNameList = {}
    --当前正在播放的背景音乐 
    self._CurPlayMusic = -1
    --场景格子列表
    self._TileList = nil
    --横向格子数
    self._XTiles = 0
    --纵向格子数
    self._YTiles = 0
    --垃圾收集
    self._LastGCTime = 0
    self._FishNodeOrder = -30
    --是否在振屏
    self._IsShake = false
    --是否定屏
    self._IsFreeze = false
    self._FreezeTimer = 10
    --我捕到的鱼列表
    self._MyFishList = {}
end

--Init
function GameMainScene:Init()
    selfScene = self
    if self._RootNode == nil then
        self._RootNode = cc.Node:create()
        self._RootScene:addChild(self._RootNode)
    end
    if self._FishRootNodeTable == nil then
        self._FishRootNodeTable = {}
    end
    if self._WaterNode == nil then
        self._WaterNode = cc.Node:create()
        self._RootNode:addChild(self._WaterNode, 1)
    end
    if self._BulletRootNode == nil then
        self._BulletRootNode = cc.Node:create()
        self._RootNode:addChild(self._BulletRootNode, 2)
    end
    if self._FishNetRootNode == nil then
        self._FishNetRootNode = cc.Node:create()
        self._RootNode:addChild(self._FishNetRootNode, 3)
    end
    if self._GoldNode == nil then
        self._GoldNode = cc.Node:create()
        self._RootNode:addChild(self._GoldNode, 4)
    end
    if self._NetEffectNode == nil then
        self._NetEffectNode = cc.Node:create()
        self._RootNode:addChild(self._NetEffectNode, 5)
    end
    if self._BigFishEffectNode == nil then
        self._BigFishEffectNode = cc.Node:create()
        self._RootNode:addChild(self._BigFishEffectNode, 2)
    end
    if self._BigFishParticle == nil then
        self._BigFishParticle = cc.ParticleSystemQuad:create("Art/Particle/Test01.plist")
        self._BigFishEffectNode:addChild(self._BigFishParticle, 2)
        self._BigFishParticle:stopSystem()
    end 
    self._ShootInterval = 0.25
    self._IsAddSpeed = false
    self._IsAutoShoot = false

    self._LockFishInfoList = {}
    self._LockFishSpriteList = {}
    self._FreeGoldList = {}
    self._FreeFishNetList = {}
    self._FreeNetEffectList = {}
    local newSprite = nil
    for i = 1, 200 do
        newSprite = cc.Sprite:create()
        newSprite:retain()
        tableInsert(self._FreeGoldList, newSprite)
    end
    local fishFrameName = "w01_01.png"
    for i = 1, 100 do
        newSprite = cc.Sprite:createWithSpriteFrameName(fishFrameName)
        newSprite:retain()
        tableInsert(self._FreeFishNetList, newSprite)
    end

    GameFishManager:Init(self)
    GameBulletManager:Init()
    self._CurPlayMusic = -1
    --初始化格子,用于优化碰撞检测
    self._TileList = {}
    self._XTiles  = mathCeil(1280 / TILES_SIZE_X)
    self._YTiles  = mathCeil(720 / TILES_SIZE_Y)
    print("Tiles", self._YTiles, self._XTiles)
    for i = 1, self._YTiles do
        self._TileList[i] = {}
        for j = 1, self._XTiles do
            self._TileList[i][j] = {}
        end
    end
    self._IsShake = false

end

--Destroy
function GameMainScene:Destroy()
    print("GameMainScene:Destroy ------------------------------------------")
    --TODO:删除这些
    self._LockFishInfoList = nil

    --锁定标志Sprite
    for k, v in pairs(self._LockFishSpriteList)do
        if v ~= nil then
            v:release()
        end
    end
    self._LockFishSpriteList = nil

    for k, v in pairs(self._FreeGoldList)do
        if v ~= nil then
            v:release()
        end
    end
    self._FreeGoldList = nil

    for k, v in pairs(self._FreeFishNetList)do
        if v ~= nil then
            v:release()
        end
    end
    self._FreeFishNetList = nil

    for k, v in pairs(self._FreeNetEffectList)do
        if v ~= nil then
            v:release()
        end
    end
    self._FreeNetEffectList = nil

    --动画缓存移除动画
    local animationCache = cc.AnimationCache:getInstance()
    for k, v in pairs(self._CacheAnimNameList)do
        animationCache:removeAnimation(v)
    end

    GameFishManager:Destroy()
    GameBulletManager:Destroy()
    self._RootNode:removeAllChildren()
    self._RootNode:removeFromParent()
    self._RootNode = nil 
    armatureManager:removeArmatureFileInfo( self._ResPrefixName .. "public/res/Wave.ExportJson")
    armatureManager:removeArmatureFileInfo( self._ResPrefixName .. "public/res/DecorationAction.ExportJson")

    self._FishRootNodeTable = nil
    self._BulletRootNode = nil
    self._FishNetRootNode = nil
    self._NetEffectNode = nil
    self._ShootPacket = 0
    self._HitFishPacket = 0 
    self._MyFishList = nil
end

--是否自动发炮
function GameMainScene:SetAutoShoot(isAuto)
    self._IsAutoShoot = isAuto
end
--
function GameMainScene:GetAutoShoot()
    return  self._IsAutoShoot
end

--是否加速
function GameMainScene:SetIsAddSpeed(isAddSpeed)
    self._IsAddSpeed = isAddSpeed
    if self._IsAddSpeed == true then
        self._ShootInterval = 0.1
    else
        self._ShootInterval = 0.25
    end
end
--
function GameMainScene:GetIsAddSpeed()
    return self._IsAddSpeed
end

--主角是否锁鱼
function GameMainScene:SetIsLockFish(isLock)
    if isLock == false then
        local meChairID = ServerDataManager._MeChairID
        self._LockFishInfoList[meChairID] = nil

        local lockFishSprite = self:GetLockSprite(meChairID)
        if lockFishSprite ~= nil then
            lockFishSprite:removeFromParent(false)
        end
        local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
        gameSceneUI:SetLockFish(meChairID, -1)
    end
end
--
function GameMainScene:GetGameFishManager()
    return GameFishManager
end
--添加游戏过程中用到的动画
function GameMainScene:AddSceneCacheAnim(animName)
    tableInsert(self._CacheAnimNameList, animName) 
end

--播放背景音乐
function GameMainScene:PlayBgMusic()
    if self._CurPlayMusic ~= -1 then
        SoundPlay:StopFishSoundByID(self._CurPlayMusic)
        self._CurPlayMusic = -1
    end
    local soundIndex = self._CurentSceneIndex % 4
    if ServerDataManager._CurSelGameID == 3000 and self._CurentSceneIndex == 0 then
        soundIndex = 4
    end
    self._CurPlayMusic = SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_Bg_1 + soundIndex)
end

--初始场景 index 从0开始
function GameMainScene:SetSceneIndex(index)
    --collectgarbage("stop")
    --print("GameMainScene:SetSceneIndex mem: ", collectgarbage("count"))
    --UI显示与隐藏
    UISystem:CloseUI(UIType.UIType_GameLoading)
    SoundPlay:StopAllSound()
    local sceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
    sceneUI:SetVisible(true)

    self._LastGCTime = osClock()

    local bgImageCount = TableDataManager:GetSceneBgCount()
    if bgImageCount ~= 0 then
        self._CurentSceneIndex = index % bgImageCount
    end

    --print("SetSceneIndex ", index)
    --背景音乐
    self:PlayBgMusic()
    --移除装饰物

    --移除背景
    if self._SceneBgSprite ~= nil then
        self._SceneBgSprite:removeAllChildren(true)
        self._SceneBgSprite:removeFromParent()
        self._SceneBgSprite = nil
    end
    --创建新的场景背景及装饰物
    local realIndex = 1
    local bgImageCount = TableDataManager:GetSceneBgCount()
    if bgImageCount ~= 0 then
        realIndex = (index + 1) % bgImageCount + 1
    end
    local bgPathName = TableDataManager:GetSceneBgByIndex( self._ResPrefixName, realIndex)
    self._SceneBgSprite = cc.Sprite:create(bgPathName)
    self._SceneBgSprite:setAnchorPoint(cc.p(0, 0))
    self._SceneBgSprite:setPosition(cc.p(0, 0))
    self._SceneBgSprite:setTextureRect(cc.rect(0, 0, 1280, 720))
    self._RootNode:addChild(self._SceneBgSprite, -100)
    self:decorationScene(self._SceneBgSprite, self._CurentSceneIndex)
    --背景波纹

    local frameCache =  cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames(self._ResPrefixName .. "public/res/Water.plist")
    local animCache = cc.AnimationCache:getInstance()
    local frameAnimName = "Water"
    local waterAnim = animCache:getAnimation(frameAnimName)
    if waterAnim == nil then
        local frameArray = {}
        for i = 1, 32 do
            local curFrameName = StringFormat("Water_%02d.png", i)
            local frame = frameCache:getSpriteFrame(curFrameName)
            frameArray[i] = frame
        end
        waterAnim = cc.Animation:createWithSpriteFrames(frameArray)
        waterAnim:setDelayPerUnit(0.1)
        waterAnim:setLoops(0xFFFFFFFF)
        animCache:addAnimation(waterAnim, frameAnimName)
        self:AddSceneCacheAnim(frameAnimName)
    end
    for i = 0, 7 do
        for j = 0, 4 do
            local animate = cc.Animate:create(waterAnim)
            local waterSp = cc.Sprite:createWithSpriteFrameName("Water_01.png")
            local wSize = waterSp:getContentSize()
            waterSp:setAnchorPoint(ZERO_PT)
            waterSp:setOpacity(200)
            waterSp:setPosition(cc.p((wSize.width - 0.1) * i, (wSize.height - 0.1) * j))
            self._WaterNode:addChild(waterSp)
            waterSp:runAction(animate)
        end
    end
    print("SetSceneIndex ", bgPathName)
end

--水草等装饰物 index:场景索引
function GameMainScene:decorationScene(bgSprite, index)
    if index >= 3 then
        return
    end
    bgSprite:removeAllChildren(true)
    local csbName = StringFormat("CSD/FishScene/FishBg_%d.csb", index)
    local decorNode = cc.CSLoader:createNode(csbName)
    --print("decorationScene----------------------------------------" , index)
    bgSprite:addChild(decorNode, 1, 1)
end
--开始切场景 (一波鱼结束)
function GameMainScene:ChangeScene(index)
    collectgarbage("collect")
    self._LastGCTime = osClock()
    --print("GameMainScene:ChangeScene mem: ", collectgarbage("count"))
    local bgImageCount = TableDataManager:GetSceneBgCount()
    if bgImageCount ~= 0 then
        self._CurentSceneIndex = index % bgImageCount
    end

    SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_Wave)


    self._SceneBgSprite:setAnchorPoint(cc.p(0, 0))
    self._SceneBgSprite:setTextureRect(cc.rect(0, 0, 1280, 720))
    self._SceneBgSprite:setPosition(cc.p(0, 0))

    print("ChangeScene ", index, self._CurentSceneIndex)

    self._IsChangeSceneing = true
    local realIndex = 1
    if bgImageCount ~= 0 then
        realIndex = (index + 1) % bgImageCount + 1
    end
    local bgPathName = TableDataManager:GetSceneBgByIndex(self._ResPrefixName, realIndex)
    self._SceneBgSprite2 = cc.Sprite:create(bgPathName)
    self._SceneBgSprite2:setAnchorPoint(cc.p(0, 0))
    self._SceneBgSprite2:setPosition(cc.p(0, 0))
    self._SceneBgSprite2:setTextureRect(cc.rect(0, 0, 1280, 720))
    self._RootNode:addChild(self._SceneBgSprite2, -101)
    --装饰物
    self:decorationScene(self._SceneBgSprite2, self._CurentSceneIndex)

    if self._ArmatureWave == nil then
        armatureManager:addArmatureFileInfo( self._ResPrefixName .. "public/res/Wave.ExportJson")
        self._ArmatureWave = ccs.Armature:create("Wave")
        self._ArmatureWave:getAnimation():playWithIndex(0)
        self._RootNode:addChild(self._ArmatureWave)
    end
    local waveSize = self._ArmatureWave:getContentSize()
    local width = 1280
    local height = 720
    --波浪动画
    self._ArmatureWave:retain() --此处的retain，后面紧接着进行了release()
    self._ArmatureWave:removeFromParent()
    self._RootNode:addChild(self._ArmatureWave)
    self._ArmatureWave:release()
    self._ArmatureWave:setVisible(true)
    self._ArmatureWave:setPosition(cc.p(0,  height / 2))
    local moveToAction = cc.MoveTo:create(4.5, cc.p(width + waveSize.width / 2, height / 2))
    local callBackAction = cc.CallFunc:create(self.OnChangeSceneEnd)
    local seq = cc.Sequence:create(moveToAction, callBackAction)
    self._ArmatureWave:runAction(seq)
    self._ChangeSceneTimer = 0
    --print("ChangeScene end ", bgPathName)
    --延时创建的鱼清空
    self._DelayFishList = {}
    local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
    for i = 0, 5 do
        self._LockFishInfoList[i] = nil
        gameSceneUI:SetLockFish(i, -1)
    end


end

--切场景动画结束
function GameMainScene.OnChangeSceneEnd()
    local gamePlay = Game:GetCurStateInstance()
    if gamePlay.GetGameScene ~= nil then
        local mainScene = gamePlay:GetGameScene()
        if mainScene ~= nil then
            mainScene:OnChangeSceneFinish()
        end
    end
end

--切场景完成的处理
function GameMainScene:OnChangeSceneFinish()
    --print("OnChangeSceneFinish")
    if self._IsChangeSceneing == true then
        print("OnChangeSceneFinish true ......")
        self._IsChangeSceneing = false
        self._ChangeSceneTimer = 0
        --删除所有鱼
        for k, v in pairs(GameFishManager._FishTable)do
            GameFishManager:DestroyFish(k, "OnChangeSceneEnd")
        end
        --删除老背景
        self._SceneBgSprite:removeAllChildren(true)
        self._SceneBgSprite:removeFromParent()
        self._SceneBgSprite = nil
        --波浪
        self._ArmatureWave:setVisible(false)
        --替换背景
        self._SceneBgSprite = self._SceneBgSprite2
        self._SceneBgSprite2:setAnchorPoint(cc.p(0, 0))
        self._SceneBgSprite2:setPosition(cc.p(0, 0))
        self._SceneBgSprite2:setLocalZOrder(-100)
        --背景音乐
        self:PlayBgMusic()
    end
end
--获取鱼网节点
function GameMainScene:GetFishNode(filename)
    if self._FishRootNodeTable == nil then
        self._FishRootNodeTable = {}
    end
    local fishNode = self._FishRootNodeTable[filename]
    if fishNode == nil then
        self._FishNodeOrder = self._FishNodeOrder + 1
        fishNode = cc.Node:create()
        self._RootNode:addChild(fishNode, self._FishNodeOrder)
        self._FishRootNodeTable[filename] = fishNode
        print("create Fish Node", filename)
    end
    return fishNode
end
--创建鱼
function GameMainScene:CreateNewFish(spriteID, serverID, pathType, nXPos, nYPos, wActionID, speedArray, moveTimeArray, rotationArray, pointArray, cbProperty, wMultiple)
    --print("CreateNewFish ", nXPos, nYPos)
   local newFish =  GameFishManager:CreateFishBySpriteID(spriteID)
   newFish:SetServerID(serverID)
   if speedArray ~= nil then
        for i = 1, #speedArray do
            newFish:SetSpeedArray(i, speedArray[i])
        end
   end
   if moveTimeArray ~= nil then
        for i = 1, #moveTimeArray do
            newFish:SetMoveTimeArray(i, moveTimeArray[i])
        end
   end
   if rotationArray ~= nil then
        for i = 1, #rotationArray do
            newFish:SetRotationArray(i, rotationArray[i])
        end
   end
   if pointArray ~= nil then
        for i = 1, #pointArray do
            newFish:SetPointArray(i, pointArray[i])
        end
   end

   newFish:SetFishPath(pathType, wActionID)
   newFish:SetPosition(nXPos, nYPos)
   newFish:SetMultiple(wMultiple)
   newFish:SetAttrib(cbProperty)

   local fishNode = self:GetFishNode(newFish._FishTextureName)
   fishNode:addChild(newFish:GetFishNode())
   if self._IsFreeze == true then
        newFish:FreezeFish()
   end
   --self._FishRootNode:addChild(newFish:GetFishNode())
   --self._RootNode:addChild(newFish:GetFishNode())
   return newFish
end

--延时创建的鱼
function GameMainScene:AddDelayFish(delayTime, spriteID, serverID, pathType, nXPos, nYPos, wActionID, speedArray, moveTimeArray, rotationArray, pointArray, cbProperty, wMultiple)
    if self._DelayFishList == nil then
        self._DelayFishList = {}
    end
    local newDelayData = DelayFishData.new()
    newDelayData._CurDelayTime = delayTime
    newDelayData._nSpriteID = spriteID
    newDelayData._nServerID = serverID
    newDelayData._nPathType = pathType
    newDelayData._nXPos = nXPos
    newDelayData._nYPos = nYPos
    newDelayData._wActionID = wActionID
    newDelayData._speedArray = speedArray
    newDelayData._moveTimeArray = moveTimeArray
    newDelayData._rotationArray = rotationArray
    newDelayData._pointArray = pointArray
    newDelayData._cbProperty = cbProperty
    newDelayData._wMultiple = wMultiple
    tableInsert(self._DelayFishList, newDelayData)
end
--

--创建子弹 wChairID:从0开始
function GameMainScene:CreateBullet(wChairID, dwBulletID, rotate, isAndroid)
    if wChairID == ServerDataManager._MeChairID then
        SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_Fire)
    end
    local bulletType = ServerDataManager:GetBulletType(wChairID)
    local newBullet = GameBulletManager:CreateBullet(bulletType, dwBulletID, wChairID, isAndroid)
    local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
    if gameSceneUI ~= nil then
              
       local x, y =  gameSceneUI:GetBarrelWorldPos(wChairID)
       local localPos = self._RootNode:convertToNodeSpace(cc.p(x, y))
       local contentSize = newBullet:GetContentSize()
       newBullet:SetPosition(localPos.x, localPos.y)
       local bulletX, bulletY = newBullet:GetPosition()
       local isFix, newDegree = self:FixBulletAngle(wChairID, degree, bulletX, bulletY)
        local newRotate = 0
        if isFix == true then
            newRotate = newDegree
        else
            newRotate = gameSceneUI:ConvertBulletRotate(wChairID, rotate)
        end
        newBullet:SetRotate(newRotate)


       local lockInfo = self._LockFishInfoList[wChairID] 
       if lockInfo ~= nil then
            newBullet:SetLockFish(lockInfo._LockFishClientID)
        end
    end
    local node = newBullet:GetBulletNode()
    --self._RootNode:addChild(node)
    self._BulletRootNode:addChild(node)
end

--渔网帧动画
function GameMainScene:GetFishNetAnim()
    local animationCache = cc.AnimationCache:getInstance()
    local frameAnimName = "FishNet"
    local animation = animationCache:getAnimation(frameAnimName)
    if animation == nil then
        local spriteFrameCache = cc.SpriteFrameCache:getInstance()
        local frameArray = {}
        for i = 1, 11 do
            local curFrameName = StringFormat("w01_0%i.png", i)
            local frame = spriteFrameCache:getSpriteFrame(curFrameName)
            frameArray[i] = frame
        end
        animation = cc.Animation:createWithSpriteFrames(frameArray, 0.03)
        animationCache:addAnimation(animation, frameAnimName)
        self:AddSceneCacheAnim(frameAnimName)
    end
    local animate = cc.Animate:create(animation)
    return animate
end

--
local function RemoveFishNet(node)
    local parentNode = node:getParent()
    if parentNode ~= nil then
        local curTag = node:getTag()
        local parentTag = parentNode:getTag()
        --print("RemoveFishNet curTag", curTag)
        --local effect = node:getChildByTag(1)
        if selfScene._NetEffectNode ~= nil then
           local  effectParent = selfScene._NetEffectNode:getChildByTag(parentTag)
           local effect 
           if effectParent ~= nil then
                effect = effectParent:getChildByTag(curTag)
           end
           selfScene:AddToFreeNetEffect(effect)
           effectParent:removeAllChildren()
           effectParent:removeFromParent(true)
        end

        selfScene:AddToFreeNetList(node)
        parentNode:removeAllChildren()
        parentNode:removeFromParent(true)
    end
end
--渔网位置（2个网，3个网，4个网）
local fishWidthHalf = 63
local effectPos = 88
local pos2 = 
{
    {-fishWidthHalf , 0},
    {fishWidthHalf , 0}
}
local pos3 = 
{
    {0, fishWidthHalf },
    {-fishWidthHalf , -fishWidthHalf }, 
    {fishWidthHalf, -fishWidthHalf }, 
}
local pos4 = 
{
    {-fishWidthHalf, fishWidthHalf },
    {fishWidthHalf, fishWidthHalf },
    {-fishWidthHalf, -fishWidthHalf }, 
    {fishWidthHalf, -fishWidthHalf }, 
}

--获取空闲的渔网
function GameMainScene:GetFreeFishNet()
    local len = #self._FreeFishNetList
    if len == 0 then
        local fishFrameName = "w01_01.png"
        newSprite = cc.Sprite:createWithSpriteFrameName(fishFrameName)
        newSprite:retain()
        tableInsert(self._FreeFishNetList, newSprite)
        len = 1
    end
    local freeNet = self._FreeFishNetList[len]
    tableRemove(self._FreeFishNetList)
    return freeNet
end
--add
function GameMainScene:AddToFreeNetList(curNetSprite)
    if curNetSprite == nil then
        return
    end
    tableInsert(self._FreeFishNetList, curNetSprite)
    curNetSprite:retain()

end
--渔网粒子特效
function GameMainScene:GetFreeNetEffect()
    local len = #self._FreeNetEffectList
    if len == 0 then
        local newParticle = cc.ParticleSystemQuad:create("Art/Particle/FishNet_1.plist")
        newParticle:retain()
        tableInsert(self._FreeNetEffectList, newParticle)
        len = 1
        --print("net effect not enough ", len)
    end
    local freeEffect = self._FreeNetEffectList[len]
    tableRemove(self._FreeNetEffectList)
    return freeEffect
end
--add
function GameMainScene:AddToFreeNetEffect(curParticle)
    --print("AddToFreeNetEffect ", curParticle)
    if curParticle == nil then
        print("AddToFreeNetEffect curParticle == nil ")
        return
    end
    tableInsert(self._FreeNetEffectList, curParticle)
    --print("NetEffect now len", #self._FreeNetEffectList)
    curParticle:retain()
    curParticle:stopSystem()
    curParticle:removeFromParent()
end

--
local netTag = 0
local function GetNetEffectTag()
    netTag = netTag + 1
    if netTag > 10000 then
        netTag = 0
    end
    --print("GetNetEffectTag " , netTag)
    return netTag
end

--创建渔网
local fishNetColor = cc.c3b(158,252,255)
function GameMainScene:CreateFishNet(wChairID, posX, posY, rotate, bulletType)
    if wChairID == ServerDataManager._MeChairID then
        local chairData = ServerDataManager:GetCurrentChairData(wChairID)
        local isSuper = false
        if chairData ~= nil and chairData._IsSuperCannon then
            isSuper = true
        end
        if isSuper then
            SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_PowerNet)
        else
            SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_Net)
        end
    end
    local netRootNode = cc.Node:create()
    netRootNode:setPosition(posX, posY)
    local netEffectNode = cc.Node:create()
    netEffectNode:setPosition(posX, posY)
    self._FishNetRootNode:addChild(netRootNode)--self._RootNode:addChild(netRootNode)
    self._NetEffectNode:addChild(netEffectNode)
    netRootNode:setRotation(rotate)
    netEffectNode:setRotation(rotate)
    local isShowEffect = ServerDataManager._ConfigData._EnableSpecial
    local curTag = GetNetEffectTag() --1
    netEffectNode:setTag(curTag)
    netRootNode:setTag(curTag)
    --两个渔网
    if bulletType == 1 or bulletType == 7 then

       for i = 1, 2 do
            local newSprite = self:GetFreeFishNet()
            newSprite:setPosition(pos2[i][1], pos2[i][2])
            --print("net width:", newSprite:getContentSize().width, newSprite:getContentSize().height)
            netRootNode:addChild(newSprite)
            --防止点击退出时的内存泄露
            newSprite:release()
            newSprite:setTag(i)

            if isShowEffect > 0 then
                local particleSystem = self:GetFreeNetEffect()
                --particleSystem:setPosition(effectPos, effectPos)
                --newSprite:addChild(particleSystem)
                --print("curTag ", curTag)
                particleSystem:setPosition(pos2[i][1], pos2[i][2])
                netEffectNode:addChild(particleSystem)
                particleSystem:setTag(i)
                particleSystem:resetSystem()
                particleSystem:release()
            end
            newSprite:setColor(fishNetColor)
            local delay = cc.DelayTime:create(0.1)
            local callFunc = cc.CallFunc:create(RemoveFishNet)
            local seq = cc.Sequence:create(self:GetFishNetAnim(), delay, callFunc)
            newSprite:runAction(seq)
        end

    --三个渔网
    elseif bulletType == 3 or bulletType == 9 then
        for i = 1, 3 do
            local newSprite = self:GetFreeFishNet()
            newSprite:setPosition(pos3[i][1], pos3[i][2])
            netRootNode:addChild(newSprite)
             --防止点击退出时的内存泄露
            newSprite:release()
            newSprite:setTag(i)
            if isShowEffect > 0 then
                local particleSystem = self:GetFreeNetEffect()
                --particleSystem:setPosition(effectPos, effectPos)
                --newSprite:addChild(particleSystem)
                --print("curTag ", curTag)
                particleSystem:setPosition(pos3[i][1], pos3[i][2])
                netEffectNode:addChild(particleSystem)
                particleSystem:setTag(i)
                particleSystem:resetSystem()
                particleSystem:release()
            end

            newSprite:setColor(fishNetColor)
            local delay = cc.DelayTime:create(0.1)
            local callFunc = cc.CallFunc:create(RemoveFishNet)
            local seq = cc.Sequence:create(self:GetFishNetAnim(), delay, callFunc)
            newSprite:runAction(seq)
        end
    --四个渔网
    elseif bulletType == 5 or bulletType == 11 then
        for i = 1, 4 do
            local newSprite = self:GetFreeFishNet() 
            newSprite:setPosition(pos4[i][1], pos4[i][2])
            netRootNode:addChild(newSprite)
            --防止点击退出时的内存泄露
            newSprite:release()
            newSprite:setTag(i)
            if isShowEffect > 0 then
                local particleSystem = self:GetFreeNetEffect()
                --particleSystem:setPosition(effectPos, effectPos)
                --newSprite:addChild(particleSystem)
                --print("curTag ", curTag)
                particleSystem:setPosition(pos4[i][1], pos4[i][2])
                netEffectNode:addChild(particleSystem)
                particleSystem:setTag(i)
                particleSystem:resetSystem()
                particleSystem:release()
            end
            newSprite:setColor(fishNetColor)
            local delay = cc.DelayTime:create(0.1)
            local callFunc = cc.CallFunc:create(RemoveFishNet)
            local seq = cc.Sequence:create(self:GetFishNetAnim(), delay, callFunc)
            newSprite:runAction(seq)
        end
    end
end

--获取LockSprite(锁定鱼的标识)
function GameMainScene:GetLockSprite(wChairID)
    local lockSprite = self._LockFishSpriteList[wChairID]
    --创建一个
    if lockSprite == nil then
        local frameName = "frame1.png"
        lockSprite = cc.Sprite:createWithSpriteFrameName(frameName)
        lockSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)))
        self._LockFishSpriteList[wChairID] = lockSprite
        lockSprite:setAnchorPoint(cc.p(0.5, 0.5))
        lockSprite:retain()
    end
    return lockSprite
end

--根据点击位置获取点中的鱼
function GameMainScene:LockFishByPos(worldX, worldY)
    local lockFish = nil
    for k, v in pairs(GameFishManager._FishTable)do
        local fishPosX, fishPosY = v:GetPosition()
        local fishW = v:GetFishWidth()
        local fishH = v:GetFishHeight()
        local max = math.max(fishW, fishH)
        local isContinue = true
        --排除掉很明显的不会碰撞的情形
        if (fishPosX - worldX) * (fishPosX - worldX) + (fishPosY - worldY) * (fishPosY - worldY) > max * max then
            isContinue = false
        end
        --local rect = v1._FishSprite:getBoundingBox()
        if isContinue and AngleRectIsCollisionPt(0, 0,fishW, fishH, 1, 1, v:GetRotate(), v:GetRotate(), cc.p(fishPosX, fishPosY), cc.p(worldX, worldY)) then
            lockFish = v
            break
        end
    end
    return lockFish
end

--子弹碰到鱼的处理 
function GameMainScene:HitFish(hitBullet, hitFish)
    if hitBullet == nil or hitFish == nil then
        return
    end

    --创建鱼网
    local x, y = hitBullet:GetPosition()
    local bulletRotate = hitBullet:GetRotate()
    self:CreateFishNet(hitBullet:GetChair(), x, y, bulletRotate, hitBullet._Type)
    --特殊鱼时，找出OtherFish
    local curCount = 0
    local otherFishList = nil
    local fishX, fishY = hitFish:GetPosition()
    if hitFish:IsBombFish() then
        otherFishList = {}
        for k, v in pairs(GameFishManager._FishTable)do
            if curCount > 98 then
                break
            end
            if v ~=  hitFish and v._IsCanCheckBounds == true then
                curCount = curCount + 1
                tableInsert(otherFishList, v:GetServerID())
            end
        end
    elseif hitFish:IsRangeBombFish() then
        otherFishList = {}
        for k, v in pairs(GameFishManager._FishTable)do
            if curCount > 98 then
                break
            end
            if v ~=  hitFish and  v._IsCanCheckBounds == true then
                local curFishX, curFishY = v:GetPosition()
                local offX = curFishX - fishX
                local offY = curFishY - fishY
                if offX * offX + offY * offY < 500 * 500 then
                    curCount = curCount + 1
                    tableInsert(otherFishList, v:GetServerID())
                end
            end
        end
    end

    if self._HitFishPacket == 0 then
        self._HitFishPacket = require("Main.NetSystem.Packet.CSGFHitFish").new()
    end
    self._HitFishPacket:Init()
    --自己的
    local meChairID = ServerDataManager._MeChairID
    if hitBullet:GetChair() == meChairID then
        --
        self._HitFishPacket._wFishID = hitFish:GetServerID()
        self._HitFishPacket._wBulletID = hitBullet:GetServerID()
        self._HitFishPacket._wHitUser = meChairID
        self._HitFishPacket._bAndroid = hitBullet:GetIsAndroid()
        self._HitFishPacket._cbOtherCount = 0
        local x, y = hitFish:GetPosition()
        self._HitFishPacket._nXpos = x
        self._HitFishPacket._nYPos = y
        self._HitFishPacket._OtherFishList = otherFishList
        NetSystem:SendGamePacket(self._HitFishPacket) 

    --机器人
    elseif hitBullet:GetIsAndroid() == true then
        self._HitFishPacket._wFishID = hitFish:GetServerID()
        self._HitFishPacket._wBulletID = hitBullet:GetServerID()
        self._HitFishPacket._wHitUser = hitBullet:GetChair()
        self._HitFishPacket._bAndroid = hitBullet:GetIsAndroid()
        self._HitFishPacket._cbOtherCount = 0
        local x, y = hitFish:GetPosition()
        self._HitFishPacket._nXpos = x
        self._HitFishPacket._nYPos = y
        self._HitFishPacket._OtherFishList = otherFishList
        NetSystem:SendGamePacket(self._HitFishPacket) 
    end
end

--锁鱼包的处理
function GameMainScene:OnPlayerLockFish(wChairID, spriteID, fishServerID)
    --print("OnPlayerLockFish--------------------")
    local fish, clientID = GameFishManager:GetFishByServerID(fishServerID)
    if fish ~= nil then
         --print("OnPlayerLockFish--------------------fish ~= nil ", clientID)
        local lockInfo = LockFishInfo.new()
        lockInfo._wChairID = wChairID
        lockInfo._LockFishServerID = fishServerID
        lockInfo._LockFishClientID = clientID
        self._LockFishInfoList[wChairID] = lockInfo

        --表现
        local lockFishSprite = self:GetLockSprite(wChairID)
        lockFishSprite:removeFromParent(true)
        self._RootNode:addChild(lockFishSprite, 2)
        lockFishSprite:stopAllActions()
        lockFishSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)))
        lockFishSprite:setOpacity(255)
        if wChairID == ServerDataManager._MeChairID then
            lockFishSprite:setColor(cc.c3b(158,252,255))
        else

        end
        --改变炮筒朝向
        local fishNode = fish:GetFishNode()
        local fishX, fishY = fish:GetPosition()
        local parentNode = fishNode:getParent()
        local worldPos = parentNode:convertToWorldSpace(cc.p(fishX, fishY))
        local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
        if gameSceneUI ~= nil then
            gameSceneUI:ChangeRotateByPos(wChairID, worldPos)
            gameSceneUI:SetLockFish(wChairID, fish:GetSpriteID())
        end
    end
end
--机器人锁鱼
function GameMainScene:OnAndroidLockFish(wChairID)
    --找出倍率>20的，最多 30条 随机发给服务器
    local resultFish = nil
    local curCount = 0
    local resultTable = {}
    for k, v in pairs(GameFishManager._FishTable)do
        if v:IsCanCheckBounds() == true then
            if v._Multiple > 20 then
                tableInsert(resultTable, k)
                curCount = curCount + 1
                if curCount >= 30 then
                    break
                end
            end
        end
    end
    if curCount > 0 then
        local index = mathRandom(1, curCount)
        local fishClientID = resultTable[index]
        local lockFish = GameFishManager._FishTable[fishClientID]
        if lockFish ~= nil then
            --print("OnAndroidLockFish ", fish._CurrentID)
            local cslockfishPacket = require("Main.NetSystem.Packet.CSGSLockFish").new()
            cslockfishPacket._wSpriteID  = lockFish._SpriteID
            cslockfishPacket._wFishID = lockFish:GetServerID()  
            cslockfishPacket._wChairID  =   wChairID
            NetSystem:SendGamePacket(cslockfishPacket)
        end
    end
end

--获取金币序列帧动画
function GameMainScene:GetGoldFrameAnim(nIndex)
    local animName = StringFormat("GOLD_%d", nIndex)
    local animationCache = cc.AnimationCache:getInstance()
    local frameAnim = animationCache:getAnimation(animName)
    if frameAnim == nil then
        local spriteFrameCache = cc.SpriteFrameCache:getInstance()
        local frameArray = {}
        local frameName = ""
        local frame = nil
        for i = 1, 12 do
            frameName = StringFormat("gold_%d_0%d.png", nIndex - 1, i) --gold_0_01 gold_1_01 
            frame = spriteFrameCache:getSpriteFrame(frameName)
            frameArray[i] = frame
        end
        frameAnim = cc.Animation:createWithSpriteFrames(frameArray, 0.08)
        animationCache:addAnimation(frameAnim, animName)
        self:AddSceneCacheAnim(animName)
    end
    local animate = cc.Animate:create(frameAnim)
    return animate
end

--金币动画完成的回调
local function GoldAnimFinish(sender)
    local mainScene = selfScene
    if mainScene == nil then
        return
    end
    sender:removeFromParent(true)
    sender:retain()
    tableInsert(mainScene._FreeGoldList, sender)
end

--捕到鱼时的金币动画 multiple:倍率
function GameMainScene:StartGoldMove(wChairID, fish, lMultiple)
    if fish == nil then
        return
    end
    local nIndex = 0
    if fish._Multiple >= 10 then
        nIndex = 1
    else
        nIndex = 2
    end

    local fishParentNode = fish:GetFishNode():getParent()
    local fishPosX, fishPosY = fish:GetPosition()
    local fishWorldPos = fishParentNode:convertToWorldSpace(cc.p(fishPosX, fishPosY))
    local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
    local destPosX, destPosY = gameSceneUI:GetGoldDestWorldPos(wChairID)
    local destPos = cc.p(destPosX, destPosY)

    local goldCount = mathFloor(lMultiple / 2) 
    if goldCount > 10 then
        goldCount = 10
    end
    local currentCount = #self._FreeGoldList
    --print("StartGoldMove ", goldCount, currentCount)
    local mathSql = math.sqrt
    for i = 1, goldCount do
        local len = #self._FreeGoldList
        local sprite = self._FreeGoldList[len]
        if sprite ~= nil then
            sprite:removeFromParent(true)
            self._GoldNode:addChild(sprite, 4)--self._RootNode:addChild(sprite, 4)
            sprite:setRotation(fish:GetRotate())
            sprite:setPosition(fishPosX + i * 40, fishPosY)
            local animate = self:GetGoldFrameAnim(nIndex)
            local subPos = cc.pSub(destPos, cc.p(fishPosX + i * 40, fishPosY))
            local distance = mathSql(subPos.x * subPos.x + subPos.y * subPos.y) 
            local moveTime = distance / 400
            local callFunc = cc.CallFunc:create(GoldAnimFinish) 
            local seq = cc.Sequence:create(cc.DelayTime:create(0.4), cc.MoveTo:create(moveTime, destPos), callFunc)
            sprite:runAction(cc.RepeatForever:create(animate))
            sprite:runAction(seq)
            tableRemove(self._FreeGoldList)
            sprite:release()
        end
    end
end
--捕中鱼时分数移除
local function RemoveNodeCall(node)
    node:removeFromParent(true)
end

--显示捕中鱼的分数显示
local fishScorePos1 = cc.p(0, 80)
local fishScorePos2 = cc.p(0, -50)
function GameMainScene:StartCaptureFishScore(wChairID, fish, score)
    if wChairID  ~= ServerDataManager._MeChairID or score == nil or fish == nil then
        return
    end
    local fishSocre = cc.LabelAtlas:_create(score,  self._ResPrefixName .. "public/res/goldNum5.png", 55, 61, string.byte("0"))
    fishSocre:setAnchorPoint(CENTER_PT)
    local x, y = fish:GetPosition()
    fishSocre:setPosition(x, y)
    self._RootNode:addChild(fishSocre, 4)
    local moveBy0 = cc.MoveBy:create(0.2, fishScorePos1)
    local moveBy1 = cc.MoveBy:create(0.2, fishScorePos2)
    local scoreRemoveCall = cc.CallFunc:create(RemoveNodeCall) 
    local seq = cc.Sequence:create(moveBy0, moveBy1, cc.DelayTime:create(0.1), cc.FadeOut:create(0.5), scoreRemoveCall)
    fishSocre:runAction(seq)
end

--振屏
local shakeX1 = cc.p(-25, 0)
local shakeX2 = cc.p(25, 0)
local shakeY1 = cc.p(0, 18)
local shakeY2 = cc.p(0, -18)

local function ShakeEndFun()
    selfScene._SceneBgSprite:setPosition(0, 0)
    selfScene._IsShake = false
end
function GameMainScene:ShakeScreen()
    if self._IsShake then
        return
    end
    local moveBy0 = cc.MoveBy:create(0.05, shakeX1)
    local moveBy1 = cc.MoveBy:create(0.05, shakeY1)
    local moveBy2 = cc.MoveBy:create(0.05, shakeX2)
    local moveBy3 = cc.MoveBy:create(0.05, shakeY2)
    local seq = cc.Sequence:create(moveBy0, moveBy1, moveBy2, moveBy3, NULL)
    local repeatAct = cc.Repeat:create(seq, 3);
    local callback = cc.CallFunc:create(ShakeEndFun)
    self._SceneBgSprite:runAction(cc.Sequence:create(repeatAct,  callback))

end

--定屏
function GameMainScene:FreezeFish()
    for k, v in pairs(GameFishManager._FishTable)do
        v:FreezeFish()
    end
end

--解定屏
function GameMainScene:UnfreezeFish()
    for k, v in pairs(GameFishManager._FishTable)do
        v:UnFreezeFish()
    end
end

--抓到鱼的处理（鱼死时，分数，金币，声音 特效 特殊鱼的特殊处理）
--      fishInfo._wFishID 
--    fishInfo._wFishMultiple 
--    fishInfo._lFishScore 
function GameMainScene:OnCaptureFish(wChairID, llUserScore, cbProperty, fishCount, lTotalScore, lMultiple, fishinfoList)
    local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
    gameSceneUI:UpdatePlayerScore(wChairID, llUserScore)
    local isShowEffect = ServerDataManager._ConfigData._EnableSpecial
    local isMyself = (ServerDataManager._MeChairID == wChairID )

    --删除指定的鱼
    --是否这条鱼已播放过声音，避免播放多个声音
    local isPlaySound = false
    if fishCount > 0 then
        for i = 1, fishCount do
            for k, v in pairs(GameFishManager._FishTable)do
                if v:GetServerID() ==  fishinfoList[i]._wFishID then
                    isPlaySound = false
                    --统计打死鱼数目 
                    local spriteID = v:GetSpriteID()
                    if isMyself then
                        if self._MyFishList[spriteID] == nil then
                            self._MyFishList[spriteID] = 0
                        end
                        self._MyFishList[spriteID] = self._MyFishList[spriteID] + 1
                    end
                    --定屏
                    if v:IsFreezeFish() then
                        if self._IsFreeze == false then
                            self:FreezeFish()
                            self._IsFreeze = true
                            self._FreezeTimer = 10
                        end
                        if isShowEffect > 0 then
                            --定屏特效
                        end
                    end
                    --炸弹
                    if v:IsBombFish() or v:IsRangeBombFish() then
                        if isShowEffect > 0 then
                            local fishX, fishY = v:GetPosition()
                            self._BigFishEffectNode:setPosition(fishX, fishY)
                            self._BigFishParticle:resetSystem()
                            print("bomb particle show-------------------------------")
                            if isMyself then
                               SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_BombFish) 
                               isPlaySound = true
                            end
                        end
                    end
                    --倍率 > 25
                    if v:GetMultiple() > 25 then
                        self:ShakeScreen()
                    end
                    --金币移动动画
                    self:StartGoldMove(wChairID, v, fishinfoList[i]._wFishMultiple)
                    --分数展示
                    self:StartCaptureFishScore(wChairID, v, fishinfoList[i]._lFishScore)

                    --声音的处理
                    --if isMyself then
                        if isPlaySound == false then
                            --鬼子特殊处理
                            local soundID = 0
                            if spriteID == 1020 then
                                soundID = FishSoundDefine.Fish_GuiZiBack
                            elseif spriteID == 1024 then
                                soundID = FishSoundDefine.Fish_GuiZiDie
                            elseif spriteID == 1025 then
                                soundID = FishSoundDefine.Fish_GZCderDie
                            else
                                if v:GetMultiple() > 25 then
                                    local count = FishSoundDefine.Fish_FishDeadEnd - FishSoundDefine.Fish_FishDeadStart
                                    soundID = FishSoundDefine.Fish_FishDeadStart + mathRandom(0, count)
                                else
                                    soundID = FishSoundDefine.Fish_FishDieScore
                                end
                            end
                            SoundPlay:PlayFishSoundByID(soundID)
                        end
                    --end
                    GameFishManager:DestroyFish(k, "OnCaptureFish")
                    break
                end
            end
        end
    end

end

--延时创建的鱼
function GameMainScene:CheckDelayFish(deltaTime)
    if self._DelayFishList == nil then
        return
    end

    for k, v in pairs(self._DelayFishList)do
        v._CurDelayTime = v._CurDelayTime - deltaTime
        if v._CurDelayTime <= 0 then
            self:CreateNewFish(v._nSpriteID, v._nServerID, v._nPathType, v._nXPos, v._nYPos, v._wActionID, v._speedArray, v._moveTimeArray, v._rotationArray, v._pointArray, v._cbProperty, v._wMultiple)
            self._DelayFishList[k] = nil
        end
    end
end

--正在切换场景的逻辑
local textureRect = cc.rect(0, 0, 1, 1)
local oriSize = cc.size(1280, 720)
function GameMainScene:ChangeSceneUpdate(deltaTime)
    local fRectWidth = self._ArmatureWave:getPositionX()
    self._ChangeSceneTimer = self._ChangeSceneTimer + deltaTime
    if  self._ChangeSceneTimer > 0.01 then
        self._ChangeSceneTimer = 0
        if fRectWidth <= 1280 then
            if self._SceneBgSprite ~= nil then
              textureRect.x = fRectWidth
              textureRect.y = 0
              textureRect.width = 1280 - fRectWidth
              textureRect.height = 720
              oriSize.width = 1280 * 2 - textureRect.width
              self._SceneBgSprite:setTextureRect(textureRect, false, oriSize)
              --移除装饰物
              local decorRoot = self._SceneBgSprite:getChildByTag(1)
              if decorRoot ~= nil then
                 local allDecor = decorRoot:getChildren()
                 local count = #allDecor
                 for i = 1, count do
                    local decNode = allDecor[i]
                    local posX = decNode:getPositionX()
                    if  posX < fRectWidth then
                        --获取tag只是为了让逻辑只执行一次
                        local tag = decNode:getTag()
                        if tag ~= 2 then
                            decNode:setTag(2)
                            local fadeAction = cc.FadeOut:create(0.6)
                            decNode:setCascadeOpacityEnabled(true)
                            decNode:runAction(fadeAction)
                        end
                    end
                 end
              end
            end
            --移除鱼
             for k, v in pairs(GameFishManager._FishTable)do
                local posX, posY = v:GetPosition()
                if posX < fRectWidth then
                    v:StartFade()
                end
            end

        else
            self:OnChangeSceneFinish()
        end
    end
end

--加炮(isAdd: true 加炮 false 减炮)
function GameMainScene:SetIsAddFire(isAdd)
    local newPacket = require("Main.NetSystem.Packet.CSFireMultiple").new()
    newPacket._bAdd = isAdd
    NetSystem:SendGamePacket(newPacket)
    --print("SetIsAddFire ", isAdd)
end

--校正角度,锁定鱼时，强制成鱼位置的角度
function GameMainScene:FixUIBarrelAngle(wChairID, degree)
    local fixDegree = degree
    local isFix = false
    local lockInfo = self._LockFishInfoList[wChairID]
    if lockInfo ~= nil then
        --改变炮筒朝向
        local fish = GameFishManager._FishTable[lockInfo._LockFishClientID]
        if fish ~= nil then
            local fishX, fishY = fish:GetPosition()
            local fishNode = fish:GetFishNode()
            local parentNode = fishNode:getParent()
            local worldPos = parentNode:convertToWorldSpace(cc.p(fishX, fishY))
            local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
            fixDegree = gameSceneUI:ChangeRotateByPos(wChairID, worldPos)
            isFix = true
        end
    end
    return isFix, fixDegree
end
--校正子弹角度，锁定鱼时，强制成鱼位置的角度
function GameMainScene:FixBulletAngle(wChairID, degree, bulletX, bulletY)
     local fixDegree = degree
    local isFix = false
    local lockInfo = self._LockFishInfoList[wChairID]
    if lockInfo ~= nil then
        local fishClientID = lockInfo._LockFishClientID
        local fish = GameFishManager._FishTable[fishClientID]
        if fish ~= nil then
            local fishPosX, fishPosY = fish:GetPosition()
            if fish:IsInvalidPos(fishPosX, fishPosY) == false then
                local subPos = cc.pSub(cc.p(fishPosX, fishPosY), cc.p(bulletX, bulletY))
                local angle = cc.pToAngleSelf(subPos)
                fixDegree = 90 - angle *  57.29577951
                isFix = true
            end
        end
    end
    return isFix, fixDegree
end
--处理自动开炮
function GameMainScene:AutoShoot(deltaTime)
    if self._IsAutoShoot == true then
        self._AutoShootTimer = self._AutoShootTimer + deltaTime
        if self._AutoShootTimer > self._ShootInterval then
            self._AutoShootTimer = 0
            local gameSceneData = ServerDataManager:GetGameSceneData()
            if GameBulletManager:GetMyBulletCount() < gameSceneData._cbMaxBullet then
                --分数判定
                local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
                if gameSceneUI ~= nil then
                     local meChairID = ServerDataManager._MeChairID
                     local lockInfo = self._LockFishInfoList[meChairID]
                    if lockInfo ~= nil then
                        --改变炮筒朝向
                        local fish = GameFishManager._FishTable[lockInfo._LockFishClientID]
                        if fish ~= nil then
                            local fishX, fishY = fish:GetPosition()
                            local fishNode = fish:GetFishNode()
                            local parentNode = fishNode:getParent()
                            local worldPos = parentNode:convertToWorldSpace(cc.p(fishX, fishY))
                            local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
                            gameSceneUI:ChangeRotateByPos(meChairID, worldPos)
                        end
                    end
                    local degree = gameSceneUI:GetBarrelRotate(meChairID)
                    ServerDataManager._MeBulletCount = ServerDataManager._MeBulletCount + 1
                    if self._ShootPacket == 0 then
                        self._ShootPacket = require("Main.NetSystem.Packet.CSGFUserShoot").new()
                    end
                    self._ShootPacket:Init()
                    self._ShootPacket._fAngle = degree
                    self._ShootPacket._wBulletID = ServerDataManager._MeBulletCount 
                    NetSystem:SendGamePacket(self._ShootPacket)
                end
            end
        end
    end
end
--更新锁定标志Sprite
function GameMainScene:UpdateLockSprite()
    if self._LockFishInfoList == nil then
        return
    end
    
   for i = 1, 6 do
        local lockFishInfo = self._LockFishInfoList[i - 1]
        local lockFishSprite = self:GetLockSprite(i - 1)
        if lockFishInfo ~= nil then
            lockFishClientID = lockFishInfo._LockFishClientID
            local lockFish = GameFishManager._FishTable[lockFishClientID]
            if lockFish ~= nil then
                lockFishSprite:setVisible(true)
                local x, y = lockFish:GetPosition()
                lockFishSprite:setPosition(x, y)
            end
        else
            lockFishSprite:setVisible(false)
        end
   end
end
--Update
function GameMainScene:Update(deltaTime)

    self._ProfileTimer = self._ProfileTimer + deltaTime
    --垃圾收集 
    local nowTime = osClock()
    if nowTime -  self._LastGCTime > GC_TIME then
        self._LastGCTime = nowTime
        collectgarbage("collect")
    end

    --处理定屏
    if self._IsFreeze == true then
        self._FreezeTimer = self._FreezeTimer - deltaTime
        if self._FreezeTimer < 0 then
            self._FreezeTimer = 0
            self._IsFreeze  = false
            self:UnfreezeFish()
        end
    end

    --local beginClock = os.clock()
    --切换场景中时
    if self._IsChangeSceneing == true then
        self:ChangeSceneUpdate(deltaTime)
    else
        --切场景时不会开炮
        self:AutoShoot(deltaTime)
    end
    
    self:CheckDelayFish(deltaTime)
    --子弹数目，鱼数目太多时，降低碰撞检测的频率
    local bulletCount = GameBulletManager._CurrentCount
    local fishCount = GameFishManager._CurrentCount

	GameFishManager:Update(deltaTime)
    GameBulletManager:Update(deltaTime, GameFishManager)

    self:UpdateLockSprite()
    --local hitBeginClock = os.clock()
    self:NewFishBulletCollision()
    --self:OldFishBulletCollision()
    --删除标记的子弹
    for k, v in pairs(GameBulletManager._BulletTable)do
        if v._IsWillDelete == true then
            GameBulletManager:DestroyBullet(k)
        end
    end
end



--碰撞检测 
function GameMainScene:OldFishBulletCollision()
    --碰撞检测
    for k, v in pairs(GameBulletManager._BulletTable)do
        local wChairID = v:GetChair()
        local lockFishClientID = v._LockFishClientID
        local bulletPosX, bulletPosY = v:GetPosition()
        --锁定鱼
        if lockFishClientID ~= -1 then
            local targetFish = GameFishManager._FishTable[lockFishClientID]
            if targetFish == nil then
                self._LockFishInfoList[wChairID] = nil
                local lockFishSprite = self:GetLockSprite(wChairID)
                lockFishSprite:removeFromParent(false)
                v:SetLockFish(-1)
                local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
                gameSceneUI:SetLockFish(wChairID, -1)
                --print("GameMainScene:Update targetFish == nil ")
            else
                --是否碰到锁定的鱼
                local fishPosX, fishPosY = targetFish:GetPosition()
                local fishW = targetFish:GetFishWidth()
                local fishH = targetFish:GetFishHeight()
                local max = mathMax(fishW, fishH)
                local isContinue = true
                --排除掉很明显的不会碰撞的情形
                if mathAbs(fishPosX - bulletPosX) > ( max / 2 + 120)  or  mathAbs(fishPosY - bulletPosY) > (max / 2 + 120 ) then
                     isContinue = false
                end
                if isContinue and PtInRectLua(fishW, fishH,  targetFish:GetRotate(), targetFish._PosT, v._PosT) then  --AngleRectIsCollisionPt(0, 0,fishW, fishH, 1, 1, targetFish:GetRotate(), v:GetRotate(), cc.p(fishPosX, fishPosY), cc.p(bulletPosX, bulletPosY))
                    self:HitFish(v, targetFish)
                    v._IsWillDelete = true
                end
              
            end
        --没锁定鱼
        else
            if v._IsWillDelete == false then
                if v._IsCheckHit == true then
                    for k1, v1 in pairs(GameFishManager._FishTable)do
                        if  v1._IsCanCheckBounds == true then
                            local fishPosX, fishPosY = v1:GetPosition()
                            local fishW = v1:GetFishWidth()
                            local fishH = v1:GetFishHeight()
                            local max = mathMax(fishW, fishH)
                            local isContinue = true

                            --排除掉很明显的不会碰撞的情形
                            if mathAbs(fishPosX - bulletPosX) > ( max / 2 + 120)  or  mathAbs(fishPosY - bulletPosY) > (max / 2 + 120 ) then
                                 isContinue = false
                            end
                            if isContinue and PtInRectLua(fishW, fishH,  targetFish:GetRotate(), v1._PosT, v._PosT) then --AngleRectIsCollisionPt(0, 0,fishW, fishH, 1, 1, v1:GetRotate(), v:GetRotate(), cc.p(fishPosX, fishPosY), cc.p(bulletPosX, bulletPosY)) 
                                self:HitFish(v, v1)
                                v._IsWillDelete = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

----------------------------------------------------新的碰撞检测，基于格子筛选的碰撞检测------------------------------

--格子校正
function GameMainScene:FixTileRow(tile)
    if tile < 1 then
        tile = 1
    elseif tile > self._YTiles then
        tile = self._YTiles
    end
    return tile
end

function GameMainScene:FixTileCol(tile)
    if tile < 1 then
        tile = 1
    elseif tile > self._XTiles then
        tile = self._XTiles
    end
    return tile
end

--填充格子信息
function GameMainScene:FillTile()
    --清空
    for i = 1, self._YTiles do
        for j = 1, self._XTiles do
            self._TileList[i][j] = {}
        end
    end
    --将所有鱼填充到所占的格子里
    local minX 
    local maxX 
    local minY 
    local maxY 
    local startRow 
    local endRow 
    local startCol 
    local endCol
    for k, v in pairs(GameFishManager._FishTable)do
        if v._IsCanCheckBounds == true then
           local fishRect =  v:GetFishBoundingBox()
           if fishRect ~= nil then
                minX = fishRect.x
                maxX = minX + fishRect.width
                minY = fishRect.y
                maxY = minY + fishRect.height
                startRow = mathCeil(minY / TILES_SIZE_Y)
                endRow = mathCeil(maxY / TILES_SIZE_Y)
                startCol = mathCeil(minX / TILES_SIZE_X)
                endCol = mathCeil(maxX / TILES_SIZE_X)
                startRow = self:FixTileRow(startRow)
                endRow = self:FixTileRow(endRow)
                startCol = self:FixTileCol(startCol)
                endCol = self:FixTileCol(endCol)
                for i = startRow, endRow do
                    for j = startCol, endCol do
                        tableInsert(self._TileList[i][j], k)
                    end
                end
           end
        end
    end
end

--清理格子
function GameMainScene:ClearTiles()
    for i = 1, self._YTiles do
        for j = 1, self._XTiles do
            self._TileList[i][j] = {}
        end
    end
end

--填充格子
function GameMainScene:AddToTile(i, j, id)
    tableInsert(self._TileList[i][j], id)
end

--新的碰撞检测，基于格子筛选的碰撞检测
function GameMainScene:NewFishBulletCollision()
    --碰撞检测
    for k, v in pairs(GameBulletManager._BulletTable)do
        local wChairID = v:GetChair()
        local lockFishClientID = v._LockFishClientID
        local bulletPosX, bulletPosY = v:GetPosition()
        local bulletRect = v:GetBoundingBox()
        local bulletPos = cc.p(bulletPosX, bulletPosY)
        --锁定鱼
        if lockFishClientID ~= -1 then
            local targetFish = GameFishManager._FishTable[lockFishClientID]
            if targetFish == nil then
                self._LockFishInfoList[wChairID] = nil
                local lockFishSprite = self:GetLockSprite(wChairID)
                lockFishSprite:removeFromParent(false)
                v:SetLockFish(-1)
                local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
                gameSceneUI:SetLockFish(wChairID, -1)
                --print("GameMainScene:Update targetFish == nil ")
            else
                --是否碰到锁定的鱼
                local fishPosX, fishPosY = targetFish:GetPosition()
                local fishW = targetFish:GetFishWidth()
                local fishH = targetFish:GetFishHeight()
                local max = mathMax(fishW, fishH)
                local isContinue = true
                --排除掉很明显的不会碰撞的情形
                if mathAbs(fishPosX - bulletPosX) > ( max / 2 + 120)  or  mathAbs(fishPosY - bulletPosY) > (max / 2 + 120 ) then
                     isContinue = false
                end
                if isContinue and AngleRectIsCollisionPt(0, 0,fishW, fishH, 1, 1, targetFish:GetRotate(), v:GetRotate(), cc.p(fishPosX, fishPosY), bulletPos) then
                    self:HitFish(v, targetFish)
                    v._IsWillDelete = true
                end
              
            end
        --没锁定鱼
        else

            if v._IsWillDelete == false and bulletRect ~= nil then
                --print("v._IsWillDelete == false and bulletRect ~= nil")
                local minX 
                local maxX 
                local minY 
                local maxY 
                local startRow 
                local endRow 
                local startCol 
                local endCol
                if v._IsCheckHit == true then
                    minX = bulletRect.x
                    maxX = minX + bulletRect.width
                    minY = bulletRect.y
                    maxY = minY + bulletRect.height
                    startRow = mathCeil(minY / TILES_SIZE_Y)
                    endRow = mathCeil(maxY / TILES_SIZE_Y)
                    startCol = mathCeil(minX / TILES_SIZE_X)
                    endCol = mathCeil(maxX / TILES_SIZE_X)
                    startRow = self:FixTileRow(startRow)
                    endRow = self:FixTileRow(endRow)
                    startCol = self:FixTileCol(startCol)
                    endCol = self:FixTileCol(endCol)
                    local isFind = false
                    local hitList = {}
                     --print("v._IsCheckHit == true ", startRow, endRow, startCol, endCol, self._XTiles, self._YTiles)
                    --遍历格子内的鱼，找出能碰撞的
                    for i = startRow, endRow do
                        if isFind then
                            break
                        end
                        for j = startCol, endCol do
                           if isFind then
                                break
                           end
                           local fishList =  self._TileList[i][j]
                           if #fishList ~= 0 then
                                --print(" #fishList ~= 0")
                                local fishTable = GameFishManager._FishTable
                                for index = 1, #fishList do
                                    local fishID = fishList[index]
                                    local fish = fishTable[fishID]
                                    local fishPosX, fishPosY = fish:GetPosition()
                                    local fishW = fish:GetFishWidth()
                                    local fishH = fish:GetFishHeight()
                                    if hitList[fishID] == nil then
                                        hitList[fishID] = true
                                        if  AngleRectIsCollisionPt(0, 0, fishW, fishH, 1, 1, fish:GetRotate(), 0, cc.p(fishPosX, fishPosY), bulletPos) then
                                            self:HitFish(v, fish)
                                            v._IsWillDelete = true
                                            isFind = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--桌子 信息改变
function GameMainScene.OnTableInfoChange(userData)
    --dump(userData, "GameMainScene.OnTableInfoChange", userData)

end


return GameMainScene
