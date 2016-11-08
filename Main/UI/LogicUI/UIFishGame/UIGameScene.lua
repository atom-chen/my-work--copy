----
-- 文件名称：UIGameScene.lua
-- 功能描述：游戏场景UI(对于频繁刷新的UI，不会通过EventSystem刷新，而是直接调用)
-- 文件说明：游戏场景UI
-- 作    者：王雷雷
-- 创建时间：2016-8-13
--  修改

local stringFormat = string.format
local tableInsert = table.insert

local UIBase = require("Main.UI.UIBase")

local UIGameScene = class("UIGameScene", UIBase)

local PlayerInfoUI = class("PlayerInfoUI")

local FishSoundDefine = FishSoundDefine
local SoundPlay = SoundPlay

local GameBulletManager = nil 
function PlayerInfoUI:ctor()
	--
	self._Panel = nil
	--炮筒Sprite
	self._BulletSprite = nil
	--名字
	self._TextChairName = nil
	--分数
	self._AtlasLabelCurScore = nil
	--炮弹分数
	self._BarrelScore = nil
end

--构造(只做成员初始化)
function UIGameScene:ctor()
	UIBase.ctor(self)
	--用户信息UI 
	self._PlayerInfoUIList = {}
	--
	self._TouchPanel = nil
	--用户信息改变
	self._InfoChangeHandler = nil
	--是否要锁鱼
	self._IsLockFish = false
	--当前对应的MainScene
	self._MainScene = nil
	--左侧五个按钮
	self._LeftButtonList = nil
	--右侧按钮
	self._RightButtonList = nil
	--右侧按钮控制节点
	self._NodeRightButton = nil
	--按钮选中时的动画Sprite
	self._AnimSpriteList = nil
	--测试文本
	self._TextTest = nil
	--Lock精灵
	self._LockSpriteList = nil
	self._LockSpritePosList = nil
	--缓存动画列表
	self._AnimNameList = nil
	--
	self._ShootPacket = 0
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIGameScene:Load(resourceName)
	UIBase.Load(self, resourceName)
	local infoPanelName = ""
	for i = 1, 6 do
		infoPanelName = "Panel_Barrel_" .. tostring(i)
		local panel = self:GetUIByName(infoPanelName)
		if panel ~= nil then
			local newInfoUI = PlayerInfoUI.new()
			newInfoUI._Panel = panel
			newInfoUI._TextChairName = seekNodeByName(panel,"Text_ChairName")
			newInfoUI._AtlasLabelCurScore = seekNodeByName(panel,"AtlasLabel_CurScore")
			newInfoUI._BulletSprite =  seekNodeByName(panel,"Sprite_Barrel")
			newInfoUI._BarrelScore = seekNodeByName(panel,"AtlasLabel_Score")
			self._PlayerInfoUIList[i] = newInfoUI
		end
	end
	self._TouchPanel = self:GetUIByName("Panel_TouchPanel")
	self._TouchPanel:setSwallowTouches(false)
	self._TouchPanel:addTouchEventListener(self.OnTouchPanel)
	local nameList = {"Button_Speed","Button_AutoFire","Button_Lock","Button_AddFire","Button_SubFire"}
	self._LeftButtonList = {}
	self._AnimSpriteList = {}
	for i = 1, 5 do
		self._LeftButtonList[i] = self:GetUIByName(nameList[i])
		self._LeftButtonList[i]:setTag(i)
		self._LeftButtonList[i]:addTouchEventListener(self.OnTouchLeftButton)
		if i == 4 or i == 5 then
			self._LeftButtonList[i]:setPressedActionEnabled(true)
		end
		--创建选中时的动画Sprite
		local newAnimSprite = cc.Sprite:createWithSpriteFrameName("phone_quan.png")
		newAnimSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)))
		local contentSize = self._LeftButtonList[i]:getContentSize()
		newAnimSprite:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
		self._LeftButtonList[i]:addChild(newAnimSprite)
		self._AnimSpriteList[i] = newAnimSprite
		newAnimSprite:setVisible(false)
	end
	self._LockSpriteList = {}
	self._LockSpritePosList = {}
	local lockName = nil
	for i = 1, 6 do
		lockName = stringFormat("Sprite_Lock_%d",i)
		self._LockSpriteList[i] = self:GetUIByName(lockName)
		self._LockSpriteList[i]:setVisible(false)
		local posX, posY = self._LockSpriteList[i]:getPosition()
		self._LockSpritePosList[i] = cc.p(posX, posY)
	end
	--self._RightButtonList
	self._RightButtonList = {}
	local rightNameList = {"Button_Setup", "Button_Help","Button_Quit", "Button_Hide"}
	for i = 1, 4 do
		local curButton = self:GetUIByName(rightNameList[i])
		curButton:setTag(i)
		curButton:setPressedActionEnabled(true)
		curButton:addTouchEventListener(self.OnTouchRightButton)
		self._RightButtonList[i] = curButton
	end
	self._NodeRightButton = self:GetUIByName("Node_RightButton")
	self._TextTest = self:GetUIByName("Text_Test")
	self._TextTest:setString("")
end

--卸载
function UIGameScene:Unload()

    local animationCache = cc.AnimationCache:getInstance()
	if self._AnimNameList ~= nil then
		for k, v in pairs(self._AnimNameList)do
			animationCache:removeAnimation(v)
		end
		self._AnimNameList = nil
	end

	--
	UIBase.Unload(self)
	--销毁
	self._PlayerInfoUIList = nil
	self._TouchPanel = nil
	self._InfoChangeHandler = nil
	self._IsLockFish = false
	self._MainScene = nil
	self._LeftButtonList = nil
	self._RightButtonList = nil
	self._NodeRightButton = nil
	self._AnimSpriteList = nil
	self._TextTest = nil
	self._LockSpriteList = nil
	self._LockSpritePosList = nil
	self._ShootPacket = 0
end

--打开(UI内容初始化)
function UIGameScene:Open(curScene)
	UIBase.Open(self)
	self:SetCurrentScene(curScene)
	self._IsLockFish = false
	self._MainScene:SetAutoShoot(false)
	self._MainScene:SetIsAddSpeed(false)
	for i = 1, 5 do
		self._AnimSpriteList[i]:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)))
		self._AnimSpriteList[i]:setVisible(false)
	end
	for i = 1, 6 do
		self._LockSpriteList[i]:setVisible(false)
	end
	self:RefreshPlayerInfo()
	self._InfoChangeHandler = EventSystem:AddEvent(GameEvent.GE_GSRoom_TableChange, self.OnUserInfoChange)

end

--关闭
function UIGameScene:Close()
	UIBase.Close(self)
	if self._InfoChangeHandler ~= nil then
		EventSystem:RemoveEvent(self._InfoChangeHandler)
		self._InfoChangeHandler = nil
	end

	--移除所有晃悠的鱼
	local fishMgr = self._MainScene:GetGameFishManager()
	fishMgr:DestroyAllUIFish()
end

--设置当前的Scene, 弱引用
function UIGameScene:SetCurrentScene(scene)
	self._MainScene = scene
end
-------------------------------------------------------------------------------------------------------------
--获取每个炮筒的高度
--[[
function UIGameScene:GetBarrelHeight(nIndex, isSuperCan)
	if nIndex == 2 then
		if isSuperCan then
			return 113
		end
		return 90
	elseif nIndex == 3 then
		if isSuperCan then
			return 110
		end
		return 90
	elseif nIndex == 4 then
		return 100
	end
end
]]
--预留接口：获取实际的旋转角度(uiIndex 1 -- 6 ) 本地 --》世界
function UIGameScene:GetRealRotateDegree(uiIndex, rotateDegree)
	return (90 - rotateDegree)
	--[[
	--由于 初始朝向为向上，所以是 90 - degreee
	if uiIndex >= 1 and uiIndex <= 3 then
		rotate = (90 - rotateDegree) 
	--上面的玩家
	else
		rotate = (90 - rotateDegree) 
	end
	return rotate
	]]
end

--预留接口：转换服务器下发的角度（炮筒的旋转角度）
function UIGameScene:ConvertServerRotate(uiIndex, serverRotate)
	return serverRotate
	--[[
	if uiIndex >= 1 and uiIndex <= 3 then
		return serverRotate
	--上面的玩家
	else
		return serverRotate
	end
	]]
end

--预留接口：转换子弹的角度（serverRotate：炮筒的旋转角度）
function UIGameScene:ConvertBulletRotate(wChair, serverRotate)
	local uiIndex = self:GetUIIndex(wChair)
	if uiIndex >= 1 and uiIndex <= 3 then
		return serverRotate
	--上面的玩家
	else
		return 180 + serverRotate
	end
end

function UIGameScene:ConvertBulletRotAngle(wChair, serverRotate)
	local uiIndex = self:GetUIIndex(wChair)
	if uiIndex >= 1 and uiIndex <= 3 then
		return serverRotate
	--上面的玩家
	else
		return (3.14159 + serverRotate)
	end
end

--获取炮口的位置(子弹初始位置) wChair:从0开始
function UIGameScene:GetBarrelWorldPos(wChair)
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]

	local contentSize = infoUI._BulletSprite:getContentSize()
	--0.75 为炮口占整个高度的比例
	local offsetY = contentSize.height * 0.75 
	local rotateDegree = infoUI._BulletSprite:getRotation() 
	local dir = cc.pForAngle((90 - rotateDegree )/  57.29577951)
	local bulletLocalPos = cc.pMul(dir, offsetY)
	local parentNode = infoUI._BulletSprite:getParent()
	local posX, posY = infoUI._BulletSprite:getPosition()
	local worldPos = parentNode:convertToWorldSpace(cc.pAdd(cc.p(posX, posY), bulletLocalPos))
	--print("GetBarrelWorldPos worldPos", wChair, worldPos.x, worldPos.y)
	return worldPos.x, worldPos.y
end

--获取 捕获鱼时移动的金币的目标点
function UIGameScene:GetGoldDestWorldPos(wChair)
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	local posX, posY = infoUI._BulletSprite:getPosition()
	local parentNode = infoUI._BulletSprite:getParent()
	local worldPos = parentNode:convertToWorldSpace(cc.p(posX, posY))
	return worldPos.x, worldPos.y
end
--
function UIGameScene:GetBarrelRotate(wChair)
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]

	return infoUI._BulletSprite:getRotation()
end
--
function UIGameScene:SetBarrelRotate(wChair, degreee)
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	return infoUI._BulletSprite:setRotation(degreee)
end

--根据数据索引（从0开始）获取对应的UI索引(从1开始), 由于 自己永远显示在UI的下方，这里有个位置转化 
function UIGameScene:GetUIIndex(dataIndex)
	local meChair = ServerDataManager._MeChairID
	if meChair >= 3 and meChair <= 5 then
		if dataIndex == meChair then
			return dataIndex - 2
		elseif dataIndex == meChair - 3 then
			return meChair + 1
		end
	end
	return dataIndex + 1
end

--更新玩家的信息
function UIGameScene:RefreshPlayerInfo()
	print("UIGameScene:RefreshPlayerInfo")

	local currentTableID = ServerDataManager._CurrentTableID
	local tableDataList = ServerDataManager._RoomUserList
	if tableDataList == nil then
		print("UIGameScene:RefreshPlayerInfo tableDataList == nil")
		return
	end
	local chairDataList = tableDataList[currentTableID]
	print(currentTableID)
	--dump(tableDataList, "tableDataList ", 10)
	if chairDataList == nil then
		print("UIGameScene:RefreshPlayerInfo chairDataList == nil", currentTableID)
		return
	end
	--初始化六个玩家的信息
	for i = 1, 6 do
		local dataIndex = i - 1
		local info = chairDataList[dataIndex]
		local uiIndex = self:GetUIIndex(dataIndex)
		local infoUI = self._PlayerInfoUIList[uiIndex]
		if info == nil then
			infoUI._Panel:setVisible(false)
		else
			infoUI._Panel:setVisible(true)
			infoUI._TextChairName:setString(info._szNickName)
			infoUI._AtlasLabelCurScore:setString(info._lScore)
			local sceneData = ServerDataManager:GetGameSceneData()
			if sceneData ~= nil and sceneData ~= 0 then
				--print(info._szNickName, info._lScore, sceneData._lUserCellScore[i])
				infoUI._BarrelScore:setString(sceneData._lUserCellScore[i])
			end
		end
	end
end

--设置新的锁定鱼的ID(锁定鱼时 相应玩家旁 晃悠的鱼和锁定标志)
function UIGameScene:SetLockFish(wChair, fishSpriteID)
	--移除老的锁定的鱼
	local uiIndex = self:GetUIIndex(wChair)
	local lockSprite = self._LockSpriteList[uiIndex]
	local children = lockSprite:getChildren()
	local fishMgr = self._MainScene:GetGameFishManager()
	if children ~= nil then
		local len = #children
		if len > 0 then
			local fishNode = children[1]
			local uifishID = fishNode:getTag()
			if fishMgr ~= nil then
				fishMgr:DestroyUIFish(uifishID)
			end
		end
	end

	--添加新的
	if fishSpriteID == nil or fishSpriteID == -1 then
		lockSprite:setVisible(false)
	else
		local newLockFish = fishMgr:CreateSceneUIFish(fishSpriteID)
		local fishNode = newLockFish:GetFishNode()
		if fishNode ~= nil then
			lockSprite:addChild(fishNode)
			fishNode:setTag(newLockFish:GetClientID())
			lockSprite:setVisible(true)
			fishNode:setRotation(-90)
			fishNode:setScale(0.5 * fishNode:getScaleX())
			local contentSize = lockSprite:getContentSize()
			fishNode:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
		end
		lockSprite:stopAllActions()
		local circleBy = LuaLib.CircleBy:create(2, self._LockSpritePosList[uiIndex], 20)
		lockSprite:runAction(cc.RepeatForever:create(circleBy))
	end

end
--更新所有玩家的炮筒
function UIGameScene:RefreshPlayerBarrel()
	local currentTableID = ServerDataManager._CurrentTableID
	local tableDataList = ServerDataManager._RoomUserList
	if tableDataList == nil then
		return
	end
	local chairDataList = tableDataList[currentTableID]
	for i = 1, 6 do
		local dataIndex = i - 1
		local info = chairDataList[dataIndex]
		if info ~= nil then
			local barrelIndex = ServerDataManager:GetBarrelNum(dataIndex)
			self:SetBarrelIndex(dataIndex, barrelIndex)
		end
		local sceneData = ServerDataManager:GetGameSceneData()
		if sceneData ~= nil and sceneData ~= 0 then
			local uiIndex = self:GetUIIndex(dataIndex)
			local infoUI = self._PlayerInfoUIList[uiIndex]
			infoUI._BarrelScore:setString(sceneData._lUserCellScore[i])
		end
	end
end

--更新玩家总分数 Score
function UIGameScene:UpdatePlayerScore(wChair, score)
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	if infoUI == nil then
		return
	end
	infoUI._AtlasLabelCurScore:setString(score)
end

--设置炮筒倍率 外观(wChair 从0开始, barrelMult: 2, 3, 4)
function UIGameScene:SetBarrelIndex(wChair, barrelMult)
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	if infoUI == nil then
		return
	end
	local currentTableID = ServerDataManager._CurrentTableID
	local chairDataList = ServerDataManager._RoomUserList[currentTableID]
	local isSuperCan = false
	if chairDataList ~= nil then
		local chairData = chairDataList[wChair]
		if chairData == nil then
			print("SetBarrelIndex ", currentTableID,  wChair, barrelMult)
		end
		isSuperCan = chairData._IsSuperCannon
	end
	infoUI._BulletSprite:stopAllActions()
	local frameName = ""
	if isSuperCan == false then
		frameName = string.format("Barrel%d_01.png", barrelMult)
	else
		frameName = string.format("SuperBarrel%d_01.png", barrelMult)
	end
	--print("SetBarrelIndex", wChair, currentTableID, isSuperCan, frameName)
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
	infoUI._BulletSprite:setSpriteFrame(frame)
	infoUI._BulletSprite:runAction(cc.FadeIn:create(0.3))

end
--更新某个玩家的倍率(wChair 从0开始)
function UIGameScene:UpdateBarrel(wChair)
	local barrelIndex = ServerDataManager:GetBarrelNum(wChair)
	self:SetBarrelIndex(wChair, barrelIndex)
	--cell score
	local sceneData = ServerDataManager:GetGameSceneData()
	if sceneData ~= nil and sceneData ~= 0 then
		local uiIndex = self:GetUIIndex(wChair)
		local infoUI = self._PlayerInfoUIList[uiIndex]
		infoUI._BarrelScore:setString(sceneData._lUserCellScore[wChair + 1])
	end
end

--播放发炮动画 wChair:数据索引, nBarrelIndex(炮筒类型) isFix:是否校正过
function UIGameScene:PlayBarrelAnim(wChair, rotate, isFix)
	local nBarrelIndex = ServerDataManager:GetBarrelNum(wChair)
	local currentTableID = ServerDataManager._CurrentTableID
	local chairDataList = ServerDataManager._RoomUserList[currentTableID]
	local isSuperCan = false
	if chairDataList ~= nil then
		local chairData = chairDataList[wChair]
		isSuperCan = chairData._IsSuperCannon
	end
	local firstFrameName = ""
	if isSuperCan == true then
		firstFrameName = stringFormat("SuperBarrel%d_01.png", nBarrelIndex)
	else
		firstFrameName = stringFormat("Barrel%d_01.png", nBarrelIndex)
	end
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	local frame = spriteFrameCache:getSpriteFrame(firstFrameName)
	infoUI._BulletSprite:setSpriteFrame(frame)
	if isFix == true then
		infoUI._BulletSprite:setRotation(rotate)
	else
		infoUI._BulletSprite:setRotation(self:ConvertServerRotate(uiIndex, rotate))
	end

	local animName = ""
	if isSuperCan == true then
		animName = stringFormat("SuperBarrel_%d", nBarrelIndex)
	else
		animName = stringFormat("Barrel_%d", nBarrelIndex)
	end
	local animationCache = cc.AnimationCache:getInstance()
	local frameAnim = animationCache:getAnimation(animName)
	if frameAnim == nil then
		local frameArray = {}
		for i = 1, 6 do
			local curFrameName = ""
			if isSuperCan == true then
				curFrameName = stringFormat("SuperBarrel%d_0%d.png", nBarrelIndex, i)
			else
				curFrameName = stringFormat("Barrel%d_0%d.png", nBarrelIndex, i)
			end
			local frame = spriteFrameCache:getSpriteFrame(curFrameName)
			frameArray[i] = frame
		end
		frameAnim = cc.Animation:createWithSpriteFrames(frameArray, 0.0525)
		frameAnim:setRestoreOriginalFrame(true)
		animationCache:addAnimation(frameAnim, animName)
		if self._AnimNameList == nil then
			self._AnimNameList = {}
		end
		tableInsert(self._AnimNameList, animName)
	end
	local animate = cc.Animate:create(frameAnim)
	infoUI._BulletSprite:runAction(animate)
end

--设置能量炮
function UIGameScene:SetSuperCannon(wChair, isSuperCan)
	local nBarrelIndex = ServerDataManager:GetBarrelNum(wChair)
	local currentTableID = ServerDataManager._CurrentTableID
	local firstFrameName = ""
	if isSuperCan == true then
		firstFrameName = stringFormat("SuperBarrel%d_01.png", nBarrelIndex)
	else
		firstFrameName = stringFormat("Barrel%d_01.png", nBarrelIndex)
	end
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
	local frame = spriteFrameCache:getSpriteFrame(firstFrameName)
	infoUI._BulletSprite:setSpriteFrame(frame)
end
--获取 炮筒的旋转角度
function UIGameScene:ChangeRotateByPos(wChair, curPos)
	local uiIndex = self:GetUIIndex(wChair)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	local parentNode = infoUI._BulletSprite:getParent()
	local x, y = infoUI._BulletSprite:getPosition()
	local worldPos = parentNode:convertToWorldSpace(cc.p(x, y))
	local dir = cc.pSub(curPos , worldPos)
	local angle = cc.pToAngleSelf(dir)
	angle = self:ConvertBulletRotAngle(wChair, angle)
	local degree = self:GetRealRotateDegree(uiIndex, angle * 57.29577951)
	infoUI._BulletSprite:setRotation(degree)
	--print("ChangeRotateByPos ", degree)
	return degree
end

--空白处点击的处理
function UIGameScene:OnBlankTouched(touchPos)
	--处理锁鱼
	if self._IsLockFish == true then
		local lockFish = self._MainScene:LockFishByPos(touchPos.x, touchPos.y)
		if lockFish ~= nil then
			print("OnBlankTouched ", lockFish._CurrentID)
			local cslockfishPacket = require("Main.NetSystem.Packet.CSGSLockFish").new()
			cslockfishPacket._wSpriteID	 = lockFish._SpriteID
			cslockfishPacket._wFishID = lockFish:GetServerID()	
			cslockfishPacket._wChairID	= 	ServerDataManager._MeChairID
			NetSystem:SendGamePacket(cslockfishPacket)
			return
		end
	end

	--发射子弹
	if GameBulletManager == nil then
		GameBulletManager =  require("Main.Logic.GameBulletManager")
	end
	local gameSceneData = ServerDataManager:GetGameSceneData()
	if gameSceneData == nil then
		return
	end

	if GameBulletManager:GetMyBulletCount() >= gameSceneData._cbMaxBullet then
		return
	end
	local meChairID = ServerDataManager._MeChairID
	local uiIndex = self:GetUIIndex(meChairID)
	local infoUI = self._PlayerInfoUIList[uiIndex]
	local parentNode = infoUI._BulletSprite:getParent()
	local x, y = infoUI._BulletSprite:getPosition()
	local worldPos = parentNode:convertToWorldSpace(cc.p(x, y))
	local dir = cc.pSub(touchPos , worldPos)
	local angle = cc.pToAngleSelf(dir)
	local realDegree = self:GetRealRotateDegree(uiIndex, angle * 57.29577951)
	infoUI._BulletSprite:setRotation(realDegree)
	--print("realDegree ",  realDegree,  worldPos.x , worldPos.y, touchPos.x, touchPos.y) 
	ServerDataManager._MeBulletCount = ServerDataManager._MeBulletCount + 1
	--TODO: 钱判定
	if self._ShootPacket == 0 then
		self._ShootPacket = require("Main.NetSystem.Packet.CSGFUserShoot").new()
	end
	self._ShootPacket:Init()
	self._ShootPacket._fAngle = realDegree
	self._ShootPacket._wBulletID = ServerDataManager._MeBulletCount 
	NetSystem:SendGamePacket(self._ShootPacket)
end

--左侧按钮点击的处理
function UIGameScene:OnTouchLeftBtns(sender)
	local tag = sender:getTag()
	--加速
	if tag == 1 then
		local isAddSpeed = self._MainScene:GetIsAddSpeed()
		isAddSpeed = not isAddSpeed
		self._MainScene:SetIsAddSpeed(isAddSpeed)
		self._AnimSpriteList[1]:setVisible(isAddSpeed)
	--自动
	elseif tag == 2 then
		local isAuto = self._MainScene:GetAutoShoot()
		isAuto = not isAuto
		self._MainScene:SetAutoShoot(isAuto)
		self._AnimSpriteList[2]:setVisible(isAuto)
	--锁定
	elseif tag == 3 then
		self._IsLockFish = not self._IsLockFish
		self._AnimSpriteList[3]:setVisible(self._IsLockFish)
		self._MainScene:SetIsLockFish(self._IsLockFish)
	--加炮
	elseif tag == 4 then
		self._MainScene:SetIsAddFire(true)
	--减炮
	elseif tag == 5 then
		self._MainScene:SetIsAddFire(false)
	end
end
--点击右侧按钮的处理
function UIGameScene:OnTouchRightBtns(sender)
	local tag = sender:getTag()
	print("OnTouchRightBtns", tag)
	--设置
	if tag == 1 then
		 UISystem:OpenUI(UIType.UIType_Setting)
	--帮助
	elseif tag == 2 then
		print("OnTouchRightBtns will UIType_FishHelp")
		UISystem:OpenUI(UIType.UIType_FishHelp)
	--退出
	elseif tag == 3 then
		--无用的Packet
		--[[
		local quitPacket = require("Main.NetSystem.Packet.CSGSQuitGame").new()
		NetSystem:SendGamePacket(quitPacket)
		]]--
		UISystem:OpenUI(UIType.UIType_FishQuit, self._MainScene)
	--隐藏	
	elseif tag == 4 then
		local visible = self._NodeRightButton:isVisible()
		self._NodeRightButton:setVisible(not visible)
	end
end
-----------------------------------------------------------------
--空白处panel点击
function UIGameScene.OnTouchPanel(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
    	local touchPos = sender:getTouchEndPosition()
        local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
        gameSceneUI:OnBlankTouched(touchPos)
        --[[
        --测试用
         local gamePlay = Game:GetCurStateInstance()
    	local mainScene = gamePlay:GetGameScene()
    	local index = mainScene._CurentSceneIndex + 1
    	mainScene:ChangeScene(index)
    	]]
    end
end
--左侧按钮点击
function UIGameScene.OnTouchLeftButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
        gameSceneUI:OnTouchLeftBtns(sender)
        SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_Button)
    end
end
--右侧几个按钮点击
function UIGameScene.OnTouchRightButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
        gameSceneUI:OnTouchRightBtns(sender)
        SoundPlay:PlayFishSoundByID(FishSoundDefine.Fish_Button)
    end
end

--用户信息改变 (有用户进入或离开)参数(	tableID = wTableID, chairID = wChairID, oldTableID = oldTableID, oldChairID = oldChair)
function UIGameScene.OnUserInfoChange(event)
	--dump(event._usedata, "event._usedata")
	if event._usedata ~= nil then
		local sceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
		if sceneUI == nil then
			return
		end
		local dataIndex = event._usedata.chairID
		local info = nil
		--离开
		if dataIndex == 0xffff then
			dataIndex = event._usedata.oldChairID
		--进入
		else
			info = ServerDataManager:GetCurrentChairData(dataIndex)
		end
		local uiIndex = sceneUI:GetUIIndex(dataIndex)
		local infoUI = sceneUI._PlayerInfoUIList[uiIndex]
		if info == nil then
			infoUI._Panel:setVisible(false)
		else
			infoUI._Panel:setVisible(true)
			infoUI._TextChairName:setString(info._szNickName)
			infoUI._AtlasLabelCurScore:setString(info._lScore)
			local sceneData = ServerDataManager:GetGameSceneData()
			if sceneData ~= nil and sceneData ~= 0 then
				local cellScore = sceneData._lUserCellScore[dataIndex + 1]
				if cellScore == 0 then
					cellScore = 100
				end
				infoUI._BarrelScore:setString(cellScore)
			end
			local barrelIndex = ServerDataManager:GetBarrelNum(dataIndex)
			sceneUI:SetBarrelIndex(dataIndex, barrelIndex)
		end
	end
end

return UIGameScene


