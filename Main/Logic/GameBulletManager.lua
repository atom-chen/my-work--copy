----
-- 文件名称：GameBulletManager
-- 功能描述：子弹管理器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-21
--  修改：

local GameBullet = require("Main.Logic.GameBullet")
local GameBulletManager = class("GameBulletManager")
local DEGREE_PER_RADIUS = 57.29577951
local pairs = pairs
local mathSin = math.sin
local mathCos = math.cos
local tableInsert = table.insert
local tableRemove = table.remove

--构造函数
function GameBulletManager:ctor()
	--当前ID
	self._CurID = 0
	--子弹管理器
	self._BulletTable = {}
	--
	self._CurrentCount = 0
	--主角发射子弹数(用于控制同时存在的子弹数目)
	self._CurMyBulletCount = 0
	--Free 
	self._BulletPoolFree = nil
end
--初始化
function GameBulletManager:Init()
	self._CurID = 0
	self._BulletTable = {}
	self._BulletPoolFree = {}
	--预先创建 120个 GameBullet的Lua对象
	for i = 1, 120 do
		local newBullet = GameBullet.new()
		tableInsert(self._BulletPoolFree, newBullet)
	end

	self._CurrentCount = 0
	self._CurMyBulletCount = 0
end

--销毁
function GameBulletManager:Destroy()
	self:DestroyAllBullet()
	self._CurrentCount = 0
	self._CurMyBulletCount = 0
	self._CurID = 0
	self._BulletPoolFree = nil
end

--
function GameBulletManager:GetFreeLuaBullet()
	local len = #self._BulletPoolFree	
	if len == 0 then
		local newBullet = GameBullet.new()
		tableInsert(self._BulletPoolFree, newBullet)
		print("not enough, create bullet......")
	end
	local curBullet = tableRemove(self._BulletPoolFree)
	return curBullet
end
--
function GameBulletManager:AddFreeLuaBullet(curBullet)
	tableInsert(self._BulletPoolFree, curBullet)
end

--创建
function GameBulletManager:CreateBullet(bulletType, serverID, wChairID, isAndroid)
	local newBullet = self:GetFreeLuaBullet()--GameBullet.new()
	newBullet:Init(bulletType)
	newBullet:SetServerID(serverID)
	newBullet:SetChair(wChairID)
    newBullet:SetIsAndroid(isAndroid)
	self._CurID = self._CurID + 1
	self._BulletTable[self._CurID] = newBullet
	self._CurrentCount = self._CurrentCount + 1
	if wChairID == ServerDataManager._MeChairID then
		self._CurMyBulletCount = self._CurMyBulletCount + 1
	end
	return newBullet
end
--删除
function GameBulletManager:DestroyBullet(bulletID)
	local bullet = self._BulletTable[bulletID]
	if bullet:GetChair() == ServerDataManager._MeChairID then
		self._CurMyBulletCount = self._CurMyBulletCount - 1
	end
	bullet:Destroy()
	self:AddFreeLuaBullet(bullet)
	self._BulletTable[bulletID] = nil
	self._CurrentCount = self._CurrentCount - 1
	--print("DestroyBullet", self._CurrentCount)
end
--删除所有的子弹
function GameBulletManager:DestroyAllBullet()
	for k, v in pairs(self._BulletTable)do
		v:Destroy()
	end
	self._BulletTable = nil
end

--获取 自己的子弹数
function GameBulletManager:GetMyBulletCount()
	return self._CurMyBulletCount
end
--Update()
function GameBulletManager:Update(deltaTime, fishManager)
	for k, v in pairs(self._BulletTable)do
		--if k ~= 1 then
			local x, y = v:GetPosition()
			--如果锁定了鱼，校正下角度
			local fishClientID = v._LockFishClientID
			if fishClientID ~= nil and fishClientID ~= -1 then
				local fish = fishManager._FishTable[fishClientID]
				if fish ~= nil then
					local fishPosX, fishPosY = fish:GetPosition()
					if fish:IsInvalidPos(fishPosX, fishPosY) == false then
						local subPos = cc.pSub(cc.p(fishPosX, fishPosY), cc.p(x, y))
						local angle = cc.pToAngleSelf(subPos)
						local degree = 90 - angle *  57.29577951
						v:SetRotate(degree)
					end
				end
			end
			local rotate = v:GetRotate()
			--位置合法性判定
			if x > 1280 or x < 0 then
				rotate = (360 - rotate)
				v:SetRotate(rotate)
				if x > 1280 then
					x = 1280
				elseif x < 0 then
					x = 0
				end
			end
			if y > 720 or y < 0 then
				rotate = 180 - rotate
				if y > 720 then
					y = 720
				elseif y < 0 then
					y = 0
				end
				v:SetRotate(rotate)
			end
			--运动轨迹
			local speed = 900
			--子弹的初始朝向是向上的，dx dy
			rotate = v:GetRotate()
			local dx = speed * deltaTime * mathSin(rotate / DEGREE_PER_RADIUS)
			local dy = speed * deltaTime * mathCos(rotate / DEGREE_PER_RADIUS)

			v:SetPosition(x + dx, y + dy)
			v:Update(deltaTime)
		--end
	end
end
--


return GameBulletManager.new()