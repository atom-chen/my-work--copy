----
-- 文件名称：CSGFHitFish.lua
-- 功能描述：框架消息 用户准备
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-19

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGFHitFish = class("CSGFHitFish", PacketBase)

function CSGFHitFish:ctor()
    PacketBase.ctor(self)
    --fishID
    self._wFishID = nil
    self._wBulletID = nil
    self._wHitUser = nil
    self._bAndroid = nil
    self._cbOtherCount = 0
    self._nXpos = 0
    self._nYPos = 0
    self._OtherFishList = nil
end

--初始化
function CSGFHitFish:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGFHitFish:Destroy()
	PacketBase.Destroy(self)
	self._OtherFishList = nil
end

--写字节流
function CSGFHitFish:Write()
	self._OutputStream:writeUShort(self._wFishID)
	self._OutputStream:writeUShort(self._wBulletID)
	self._OutputStream:writeUShort(self._wHitUser)
	local bIsAndroid = 0
	if self._bAndroid == true then
		bIsAndroid = 1
	end
	self._OutputStream:writeByte(bIsAndroid)
	if self._OtherFishList == nil then
		self._cbOtherCount = 0
	else
		self._cbOtherCount = #self._OtherFishList
		if self._cbOtherCount > 100 then
			self._cbOtherCount = 100
		end
	end

	self._OutputStream:writeByte(self._cbOtherCount)
	self._OutputStream:writeInt(self._nXpos)
	self._OutputStream:writeInt(self._nYPos)
	if self._cbOtherCount > 0 then
		for i = 1, self._cbOtherCount do
			self._OutputStream:writeUShort(self._OtherFishList[i])
		end
	end
end

return CSGFHitFish