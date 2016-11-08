----
-- 文件名称：CSGSLockFish.lua
-- 功能描述：锁定鱼
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-25
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGSLockFish = class("CSGSLockFish", PacketBase)

function CSGSLockFish:ctor()
    PacketBase.ctor(self)
	self._wSpriteID	 = 0	
	self._wFishID = 0		
	self._wChairID	= 0		
end

--初始化
function CSGSLockFish:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGSLockFish:Destroy()

end

--写字节流
function CSGSLockFish:Write()
	self._OutputStream:writeUShort(self._wSpriteID)
    self._OutputStream:writeUShort(self._wFishID)
    self._OutputStream:writeUShort(self._wChairID)
end

return CSGSLockFish