----
-- 文件名称：GameFish
-- 功能描述：
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-14
--  修改：

local spriteFrameCache = cc.SpriteFrameCache:getInstance()

local FishAttrib = 
{
	enFreeze=0x01, --定屏
	enBomb=0x02,  --炸弹
	enBoss=0x04,  --动态倍率鱼
	enSameDie=0x08, --同类炸弹
	enLine=0x10, --连线鱼
	enRangeBomb=0x20, --范围炸弹
	enLighting=0x40, -- 闪电鱼
	enJumpBomb=0x80,  --超级炸弹
}

local GameFish = class("GameFish")
local StringFormat = string.format
local ipairs = ipairs
local tonumber = tonumber
local FISHSPEED_ACT_TAG = 100
--构造
function GameFish:ctor()
	--表数据的引用
	self._FishConfigData = nil
	--Fish Sprite
	self._FishSprite = nil
	--path data
	self._PathData = nil
	self._PathID = -1
	--表格ID
	self._SpriteID = 0
	--ClientID
	self._ClientID = 0
	--Server ID
	self._ServerID = nil
	--是否要删除
	self._IsWillDelete = false
	--鱼的运动时间
	self._FishTime = 0
	--当前鱼的运动时间
	self._CurTime = 0
	--起始位置
	self._nStartX = 0
	self._nStartY = 0
	self._nWidth = 0
	self._nHeight = 0
	--倍率
	self._Multiple = 0
	--是否可检测边界(false 用于初始位置就在非法位置的情况)
	self._IsCanCheckBounds = true
	--属性
	self._Attrib = nil
	--渐隐
	self._IsFade = false
	--
	self._MoveTimeList = {}
	self._SpeedList = {}
	self._PointList = {}
	self._RotateList = {}
	--
	self._PosT = cc.p(0, 0)
	self._IsInit = false
	self._FishTextureName = ""
	--是否炸弹鱼
	self._IsBomb = false
	self._IsFreeze = false
	self._IsRangeBomb = false

end 

--回调
function GameFish.FishDieAppearCall(node)
	--[[
	node:removeAllChildren()
	node:stopAllActions()
	node:removeFromParent()
	]]--
	print("FishDieAppearCall ")
end

--值重置
function GameFish:Reset()
	self._FishConfigData = nil
	self._FishSprite = nil
	self._PathData = nil
	self._PathID = -1
	self._SpriteID = 0
	self._ClientID = 0
	self._ServerID = nil
	self._IsWillDelete = false
	self._FishTime = 0
	self._CurTime = 0
	self._nStartX = 0
	self._nStartY = 0
	self._nWidth = 0
	self._nHeight = 0
	self._Multiple = 0
	self._FishAttrib = 0
	self._IsCanCheckBounds = true
	self._Attrib = nil
	self._IsFade = false
	self._MoveTimeList = {}
	self._SpeedList = {}
	self._PointList = {}
	self._RotateList = {}
	self._PosT = cc.p(0, 0)
	self._FishTextureName = ""
end
--初始化
function GameFish:Init(spriteID)
	--
	if self._IsInit == true then
		self:Reset()
	end

	self._IsInit = true
	self._SpriteID = spriteID
	local fishConfigData = TableDataManager:GetFishDataByID(spriteID)
	if fishConfigData == nil then
		print("GameFish:Init fishConfigData == nil", spriteID)
	end
	self._FishConfigData = fishConfigData
	local fishAttrData = fishConfigData._attr
	if fishAttrData ~= nil then
		if fishAttrData.group == nil or tonumber(fishAttrData.group) == 0 then
			local frame = spriteFrameCache:getSpriteFrame(fishAttrData.firstname)
			if frame ~= nil then
				local texture = frame:getTexture()
				if texture ~= nil then
					self._FishTextureName = texture:getPath()
					--print("FishTexture: ", self._FishTextureName)
				end
			end
			self._FishSprite = cc.Sprite:createWithSpriteFrameName(fishAttrData.firstname)
			if self._FishSprite ~= nil then
				self._FishSprite:retain()
			end
			self._FishSprite:setTag(10001)
			self._FishSprite:setAnchorPoint(cc.p(0.5, 0.5))
			--动画创建
			--local callFunc = cc.CallFunc:create(self.FishDieAppearCall)
			--local sequence = cc.Sequence:create(self:CreateAnimate(fishAttrData), callFunc, nil)
			self._FishSprite:runAction(self:CreateAnimate(fishAttrData))
			if fishAttrData.scale ~= nil then
				self._FishSprite:setScale(fishAttrData.scale)
			end
			if fishAttrData.rectwidth ~= nil and fishAttrData.rectheight ~= nil then
				self._FishSprite:setContentSize(cc.size(fishAttrData.rectwidth, fishAttrData.rectheight))
				self._nWidth = fishAttrData.rectwidth 
				self._nHeight = fishAttrData.rectheight
			end

			if fishAttrData.ration ~= nil and tonumber(fishAttrData.ration) == -1 then
				local rotateBy = cc.RotateBy:create(1, 90)
				self._FishSprite:runAction(cc.RepeatForever:create(rotateBy))
			end
		else
			self._FishTextureName = "Group"
			--print("FishTexture: ", self._FishTextureName)
			local subFishData = fishConfigData.data
			self._FishSprite = cc.Sprite:create()
			self._FishSprite:retain()
			self._FishSprite:setTag(10002)
			self._FishSprite:setAnchorPoint(cc.p(0.5, 0.5))

			if fishAttrData.scale ~= nil then
				self._FishSprite:setScale(fishAttrData.scale)
			end
			if fishAttrData.rectwidth ~= nil and fishAttrData.rectheight ~= nil then
				self._FishSprite:setContentSize(cc.size(fishAttrData.rectwidth, fishAttrData.rectheight))
				self._nWidth = fishAttrData.rectwidth 
				self._nHeight = fishAttrData.rectheight
			end

			if fishAttrData.ration ~= nil then
				if tonumber(fishAttrData.ration) == -1 then
					local rotateBy = cc.RotateBy:create(1, 90)
					self._FishSprite:runAction(cc.RepeatForever:create(rotateBy))
				else

				end	
			end

			for i, v in ipairs(subFishData)do
				local subFishAttr = TableDataManager:GetFishDataByID(tonumber(v._attr.spriteid))
				local subFishSprite = self:CreateSubFish(subFishAttr._attr)
				if v._attr.zorder ~= nil then
					subFishSprite:setLocalZOrder(v._attr.zorder)
				end
				if v._attr.posx ~= nil and v._attr.posy ~= nil then
					subFishSprite:setPosition(tonumber(v._attr.posx), tonumber(v._attr.posy))
				end
				self._FishSprite:addChild(subFishSprite)
			end
		end
	end
end
--


--销毁
function GameFish:Destroy()
	if self._FishSprite ~= nil then
		self._FishSprite:release()
		self._FishSprite:removeAllChildren()
		self._FishSprite:removeFromParent()
		self._FishSprite = nil
	end
	self._FishConfigData = nil
	self._PathData = nil
	self._MoveTimeList = nil
	self._SpeedList = nil
	self._PointList = nil
	self._RotateList = nil
	self._PosT = nil
end

--
function GameFish:GetFishTextureName()


end

--SpriteID
function GameFish:GetSpriteID()
	return self._SpriteID
end
--运动路径
function GameFish:SetFishPath(pathID, actionID)
	self._PathID = pathID
	if pathID == -1 then
		self._PathData = nil
		local moveAction = self:CreatePathAction(pathID, false, actionID)
		self._FishSprite:runAction(moveAction)
		return 
	end
	self._PathData = TableDataManager:GetFishPathDataByID(pathID)
	local moveAction = self:CreatePathAction(pathID, false)
	self._FishSprite:runAction(moveAction)
end
--设置倍率
function GameFish:SetMultiple(multiple)
	self._Multiple = multiple
end
--获取倍率
function GameFish:GetMultiple()
	return self._Multiple
end
--位置
function GameFish:GetPosition()
	if self._FishSprite == nil then
		return
	end
	local x, y = self._FishSprite:getPosition()
	self._PosT.x = x
	self._PosT.y = y
	return x, y
end

--是否非法的位置
function GameFish:IsInvalidPos(x, y)
	local size = self._FishSprite:getContentSize()
	if x >= 1280 + size.width / 2 or x <= -size.width / 2 or y <= -size.height / 2 or y >= 720 + size.height / 2 then
		return true
	end
	return false
end

--起始位置
function GameFish:SetPosition(x, y)
	--print("GameFish:SetPosition enter ", x, y)
	if self._FishSprite == nil then
		print("error: self._FishSprite == nil ")
		return
	end
	--[[]]
	if self._PathData ~= nil then
		local actionInfo = self._PathData.Information
		local pathX = actionInfo[1]._attr.startpos_x
		local pathY = actionInfo[1]._attr.startpos_y
		x = x + pathX
		y = y + pathY
		self._FishSprite:setPosition(x, y)
	else
		local fScaleX = 1280 / 1440
		local fScaleY = 720 / 900
		x = x * fScaleX
		y = 720 - y * fScaleY
		self._FishSprite:setPosition(x, y)
	end

	self._nStartX = x
	self._nStartY = y
	--初始位置为非法位置时，不检测边界
	if self:IsInvalidPos(x, y) == true then
		self._IsCanCheckBounds = false
	end
	--print("GameFish:SetPosition end", x, y)
end

--大小
function GameFish:GetContentSize()
	if self._FishSprite == nil then
		return
	end
	return self._FishSprite:getContentSize()
end
--
function GameFish:GetFishWidth()
	if self._nWidth == 0 then
		return self:GetContentSize().width
	end
	return self._nWidth * self._FishSprite:getScaleX()
end
--
function GameFish:GetFishHeight()
	if self._nHeight == 0 then
		return self:GetContentSize().height
	end
	return self._nHeight * self._FishSprite:getScaleY()
end

function GameFish:GetRotate()
	if self._FishSprite == nil then
		return
	end
	return self._FishSprite:getRotation()
end
--获取根节点
function GameFish:GetFishNode()
	return self._FishSprite
end
--属性
function GameFish:SetAttrib(attrib)
	self._Attrib = attrib
	--计算好，在Lua中做位运算效率低
	self._IsBomb = (bitLib.band(attrib, FishAttrib.enBomb) == 1)
	self._IsFreeze = (bitLib.band(attrib, FishAttrib.enFreeze) == 1) 
	self._IsRangeBomb = (bitLib.band(attrib, FishAttrib.enRangeBomb) == 1) 

end
--
function GameFish:GetFishBoundingBox()
	if self._FishSprite == nil then
		return nil
	end
	return self._FishSprite:getBoundingBox()
end
local function GetCurretnScene()
	local gamePlay = Game:GetCurStateInstance()
	return gamePlay:GetGameScene()
end
--创建序列帧动画
function GameFish:CreateAnimate(fishAttrData)
	local animationCache = cc.AnimationCache:getInstance()
	local frameAnim = animationCache:getAnimation(fishAttrData.commonname)
	if frameAnim == nil then
		local duration = fishAttrData.duration
		local frameCount = fishAttrData.framecount
		local frameArray = {}
		for i = 1, frameCount do
			local frameName = StringFormat("%s%02d.png", fishAttrData.commonname, i - 1)
			local  currentFrame = spriteFrameCache:getSpriteFrame(frameName)
			frameArray[i] = currentFrame
		end
		frameAnim = cc.Animation:createWithSpriteFrames(frameArray)
		frameAnim:setDelayPerUnit(duration / frameCount)
		frameAnim:setLoops(0xFFFFFFFF)
		frameAnim:setRestoreOriginalFrame(true)
		animationCache:addAnimation(frameAnim, fishAttrData.commonname)
		GetCurretnScene():AddSceneCacheAnim(fishAttrData.commonname)
	end
	local animate = cc.Animate:create(frameAnim)
	return animate
end
--创建subfish
function GameFish:CreateSubFish(fishAttrData)
	local subFishSprite = cc.Sprite:createWithSpriteFrameName(fishAttrData.firstname)
	--动画创建
	--local callFunc = cc.CallFunc:create(self.FishDieAppearCall)
	--local sequence = cc.Sequence:create(self:CreateAnimate(fishAttrData), callFunc, nil)
	subFishSprite:runAction(self:CreateAnimate(fishAttrData))
	if fishAttrData.scale ~= nil then
		subFishSprite:setScale(fishAttrData.scale)
	end
	if fishAttrData.rectwidth ~= nil and fishAttrData.rectheight ~= nil then
		subFishSprite:setContentSize(cc.size(fishAttrData.rectwidth, fishAttrData.rectheight))
	end
	if fishAttrData.ration ~= nil then
		if tonumber(fishAttrData.ration) == -1 then
			local rotateBy = cc.RotateBy:create(1, 90)
			subFishSprite:runAction(cc.RepeatForever:create(rotateBy))
		else
			local rotateBy = cc.RotateBy:create(1, tonumber(fishAttrData.ration))
			subFishSprite:runAction(cc.RepeatForever:create(rotateBy))
		end
	end

	return subFishSprite
end

--
function GameFish:SetSpeedArray(nIndex, speed)
	self._SpeedList[nIndex] = speed
end
--
function GameFish:SetRotationArray(nIndex, rotation)
	self._RotateList[nIndex] = rotation
end
--
function GameFish:SetMoveTimeArray(nIndex, moveTime)
	self._MoveTimeList[nIndex] = moveTime
end
--
function GameFish:SetPointArray(nIndex, cPoint)
	self._PointList[nIndex] = cPoint
end

--创建Path action(鱼的运动轨迹)
function GameFish:CreatePathAction(nIndex, bIsRandomSpeed, serverActionID)
	self._FishTime = 0
	local moveAction = nil

	--bIsRandomSpeed
	--不合理的配置 fSpeedRate    ????需要规则，或者配表
	local fSpeedRate = 60

	local actionCfgID = nil
	local actionInfo = nil
	if self._PathData ~= nil then
		local actionType = self._PathData.ActionType
		if actionType ~= nil then
			actionCfgID = tonumber(actionType._attr.actionid)
		end
		actionInfo = self._PathData.Information
	else
		actionCfgID = serverActionID
	end

	if actionCfgID == 6001 then
		local actionArray = {}
		local pointList = self._PointList
		local movetimeList = self._MoveTimeList
		if pointList == nil or movetimeList == nil then
			printError("---------6001 invalid param")
		end
		local index = 1
		local moveVec = cc.p(0, 0)
		local isFind = false
		for i = 1, 5 do
			if movetimeList[i] ~= 0 then
				local newAction = cc.MoveBy:create(movetimeList[i], pointList[i])
				actionArray[index] = newAction
				if isFind == false then
					--排除掉开始不动的情况
					if (pointList[i].x == 0 and pointList[i].y == 0) == false then
						moveVec.x = pointList[i].x
						moveVec.y = pointList[i].y
						isFind = true
					end
				end
				index = index + 1
			end
		end
		moveAction = cc.Sequence:create(actionArray) 
		local angle = cc.pToAngleSelf(moveVec)
		local degreeAngle = 57.29577951 * angle * -1
		self._FishSprite:setRotation( degreeAngle)
		--print("actionCfgID ", actionCfgID, degreeAngle, pointList[1].x, pointList[1].y, self._SpriteID)
	elseif actionCfgID == 6002 then
		local bezierArray = {}
		for i = 1, #actionInfo - 1 do
			local currentPoint = cc.p(actionInfo[i]._attr.startpos_x, actionInfo[i]._attr.startpos_y)
			local nextPoint = cc.p(actionInfo[i + 1]._attr.startpos_x, actionInfo[i + 1]._attr.startpos_y)
			local curCtrlPoint = cc.p(actionInfo[i]._attr.controlpos_x, actionInfo[i]._attr.controlpos_y)
			local bezier = 
			{
				cc.p(0, 0),
				cc.pSub(curCtrlPoint, currentPoint),
				cc.pSub(nextPoint, currentPoint),
			}
			local newBezier = cc.BezierBy_2:create(actionInfo[i]._attr.movetime / fSpeedRate, bezier)
			bezierArray[i] = newBezier
		end
		moveAction = cc.Sequence:create(bezierArray) 
		--
	elseif actionCfgID == 6003 then
		local actionArray = {}
		local pointList = self._PointList
		local rotateList = self._RotateList
		local movetimeList = self._MoveTimeList
		local index = 1
		local mathSin = math.sin
		local mathCos = math.cos
		local pos = cc.p(0, 0)
		local firstPos = pos
		local isFind = false
		for i = 1, 5 do
			if movetimeList[i] ~= 0 then
				pos.x = pointList[i].x * mathSin(rotateList[1] / (57.29577951))
				pos.y = pointList[i].x * mathCos(rotateList[1] / (57.29577951))
				local newAction = cc.MoveBy:create(movetimeList[i], pos)
				actionArray[index] = newAction
				if isFind == false then
					if (pos.x == 0 and pos.y == 0) == false then
						firstPos = pos
						isFind = true
					end
				end
				index = index + 1
			end
		end
		local angle = cc.pToAngleSelf(firstPos)
		local degreeAngle = 57.29577951 * angle * -1
		self._FishSprite:setRotation(degreeAngle)
		--print("actionCfgID", actionCfgID, degreeAngle, firstPos.x, firstPos.y, self._SpriteID)
		moveAction = cc.Sequence:create(actionArray) 
	elseif actionCfgID == 6004 then
		local infoCount = #actionInfo
		if infoCount ~= 2 then
			printError("---------infoCount infoCount ~= 2 ")
			return nil
		end
		--actionInfo[1].startpos_x
		local startPos = cc.p(actionInfo[1]._attr.startpos_x, actionInfo[1]._attr.startpos_y)
		local endPos = cc.p(actionInfo[2]._attr.startpos_x, actionInfo[2]._attr.startpos_y)
		local moveDir = cc.pSub(endPos, startPos)
		local angle = cc.pToAngleSelf(moveDir)
		local degreeAngle = 57.29577951 * angle * -1
		self._FishSprite:setRotation( degreeAngle)

		moveAction = cc.MoveBy:create(actionInfo[1]._attr.movetime / fSpeedRate, moveDir)
		--print("actionCfgID", actionCfgID, degreeAngle, moveDir.x, moveDir.y, self._SpriteID)
	end
	--print("self._FishTime ", self._FishTime)
	local newSpeed = cc.Speed:create(moveAction, 1)
	newSpeed:setTag(FISHSPEED_ACT_TAG)
	return newSpeed
end

--定屏
function GameFish:FreezeFish()
	if self._FishSprite == nil then
		return
	end
	local speedAction = self._FishSprite:getActionByTag(FISHSPEED_ACT_TAG)
	if speedAction ~= nil then
		speedAction:setSpeed(0)
	end
end

--解定屏
function GameFish:UnFreezeFish()
	if self._FishSprite == nil then
		return
	end
	local speedAction = self._FishSprite:getActionByTag(FISHSPEED_ACT_TAG)
	if speedAction ~= nil then
		speedAction:setSpeed(1)
	end
end
--开始渐隐(切换场景)
function GameFish:StartFade()
	if self._IsFade == false then
		self._IsFade = true
		local fadeAction = cc.FadeOut:create(0.6)
		self._FishSprite:setCascadeOpacityEnabled(true)
		self._FishSprite:runAction(fadeAction)
	end
end

--ClientID
function GameFish:SetClientID(clientID)
	self._ClientID = clientID
end
--获取ClientID
function GameFish:GetClientID()
	return self._ClientID 
end
--设置ServerID
function GameFish:SetServerID(serverID)
	self._ServerID = serverID
end
--服务器ID
function GameFish:GetServerID()
	return self._ServerID 
end
--是否可检测到边界
function GameFish:IsCanCheckBounds()
	return self._IsCanCheckBounds
end

-------------------------------------鱼的属性
--是否全屏炸弹
function GameFish:IsBombFish()
	return self._IsBomb
end

--是否范围炸弹
function GameFish:IsRangeBombFish()
	return self._IsRangeBomb
end

--是否定屏鱼
function GameFish:IsFreezeFish()
	return self._IsFreeze
end

-------------------------------------
--Update
function GameFish:Update(deltaTime)
	--首次由非法位置变为合理位置后，就可以检测边界
	if self._IsCanCheckBounds == false then
		local nowPosX, nowPosY = self:GetPosition()
		if self:IsInvalidPos(nowPosX, nowPosY) == false then
			self._IsCanCheckBounds = true
		end
	end
end

return GameFish


