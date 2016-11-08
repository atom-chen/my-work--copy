----
-- 文件名称：GameBullet
-- 功能描述：子弹
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-21
--  修改：

local GameBullet = class("GameBullet")
local StringFormat = string.format
--构造
function GameBullet:ctor()
	--子弹 serverID
	self._ServerID = nil
	--是否来自服务器
	self._IsFromServer = true
	--类型
	self._Type = nil
	--所属位子
	self._BelongChair = 0
	--Sprite
	self._BulletSprite = nil
	--是否机器人
	self._IsAndroid = false
	--是否要删除
	self._IsWillDelete = false
	--速度
	self._MoveSpeed = 10
	--标准间隔时间
	self._HitInterval = 0.05
	--子弹碰撞检测时间间隔
	self._BulletHitTimer = 0
	--锁定鱼的
	self._LockFishClientID = -1
	--是否碰撞检测
	self._IsCheckHit = true
	--
	self._PosT = cc.p(0, 0)
	--
	self._IsInit = false
end

--
function GameBullet:Reset()
	self._ServerID = nil
	self._IsFromServer = true
	self._Type = nil
	self._BelongChair = 0
	self._BulletSprite = nil
	self._IsAndroid = false
	self._IsWillDelete = false
	self._MoveSpeed = 10
	self._HitInterval = 0.05
	self._BulletHitTimer = 0
	self._LockFishClientID = -1
	self._IsCheckHit = true
	self._PosT = cc.p(0, 0)
end
--初始化
function GameBullet:Init(bulletType)
	if self._IsInit then
		self:Reset()
	end
	self._IsInit = true
	self._Type = bulletType
	--Sprite
    local frameName = StringFormat("bullet_0%d.png", bulletType)
    self._BulletSprite = cc.Sprite:createWithSpriteFrameName(frameName)
    if self._BulletSprite ~= nil then
    	self._BulletSprite:retain()
    	self._BulletSprite:setAnchorPoint(cc.p(0.5, 0.5))
    end
    --动画
    local newAnimate = self:CreateAnimate(bulletType)
    if self._BulletSprite ~= nil then
    	self._BulletSprite:runAction(cc.RepeatForever:create(newAnimate))
    end
end

--销毁
function GameBullet:Destroy()
	if self._BulletSprite ~= nil then
		self._BulletSprite:release()
		self._BulletSprite:removeAllChildren()
		self._BulletSprite:removeFromParent()
		self._BulletSprite = nil
	end
	self._PosT = nil
end

--rotate
function GameBullet:SetRotate(rotation)
	if self._BulletSprite ~= nil then
		self._BulletSprite:setRotation(rotation)
	end
end
--
function GameBullet:GetRotate()
	if self._BulletSprite == nil then
		return
	end
	return self._BulletSprite:getRotation()
end
--getPosition
function GameBullet:GetPosition()
	if self._BulletSprite == nil then
		return
	end
	local x, y = self._BulletSprite:getPosition()
	self._PosT.x = x
	self._PosT.y = y
	return x, y
end
--
function GameBullet:SetPosition(x, y)
	if self._BulletSprite ~= nil then
		self._BulletSprite:setPosition(x, y)
	end
end

--
function GameBullet:SetChair(wChairID)
	 self._BelongChair = wChairID
end
--获取 位子 
function GameBullet:GetChair()
	return self._BelongChair
end
--是否机器人
function GameBullet:SetIsAndroid(isAndroid)
	self._IsAndroid = isAndroid
end
--是否机器人
function GameBullet:GetIsAndroid()
	return self._IsAndroid
end

function GameBullet:GetBoundingBox()
	if self._BulletSprite == nil then
		return nil
	end
	return self._BulletSprite:getBoundingBox()
end
--
function GameBullet:GetContentSize()
	if self._BulletSprite == nil then
		return
	end
	self._BulletSprite:getContentSize()
end
--ServerID
function GameBullet:SetServerID(serverID)
	self._ServerID = serverID
end
--
function GameBullet:GetServerID()
	return self._ServerID
end
--获取Node
function GameBullet:GetBulletNode()
	return self._BulletSprite
end

--锁定鱼的Client ID
function GameBullet:SetLockFish(clientID)
	self._LockFishClientID = clientID
end
--获取 当前的mainscene
local function GetCurretnScene()
	local gamePlay = Game:GetCurStateInstance()
	return gamePlay:GetGameScene()
end
--创建序列帧动画(每个子弹2帧图)
function GameBullet:CreateAnimate(bulletType)
	local frameAnimName = StringFormat("BULLET_STATE_%d", self._Type)
	local animationCache = cc.AnimationCache:getInstance()
	local frameAnim = animationCache:getAnimation(frameAnimName)
	if frameAnim == nil then
		local spriteFrameCache = cc.SpriteFrameCache:getInstance()
		local frameArray = {}
		for i = 1, 2 do
			local curFrameName = StringFormat("bullet_0%i.png", bulletType + i - 1)
			local frame = spriteFrameCache:getSpriteFrame(curFrameName)
			frameArray[i] = frame
		end
		frameAnim = cc.Animation:createWithSpriteFrames(frameArray, 0.5)
		animationCache:addAnimation(frameAnim, frameAnimName)
		GetCurretnScene():AddSceneCacheAnim(frameAnimName)
	end
	local animate = cc.Animate:create(frameAnim)
	return animate
end
--设置碰撞检测间隔时间
function GameBullet:SetHitInterval(interval)
	self._HitInterval = interval
end
--
function GameBullet:Update(deltaTime)
	--[[
	--根据游戏的运行情况，动态改变子弹的碰撞间隔时间，
	self._IsCheckHit = false

	self._BulletHitTimer = self._BulletHitTimer + deltaTime
	if deltaTime < 0.034 then
		self._HitInterval = 0
	elseif deltaTime < 0.05 then
		self._HitInterval = 0.1
	elseif deltaTime < 0.1 then
		self._HitInterval = 0.2
	else
		self._HitInterval = 0.5
	end
	if self._BulletHitTimer > self._HitInterval then
		self._BulletHitTimer = 0
		self._IsCheckHit = true
	end
	----结束 动态改变子弹的碰撞间隔时间
	]]--
end

return GameBullet



