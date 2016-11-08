----
-- 文件名称：CSGFUserShoot.lua
-- 功能描述：玩家开炮
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-11

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGFUserShoot = class("CSGFUserShoot", PacketBase)

function CSGFUserShoot:ctor()
    PacketBase.ctor(self)
    --
    self._fAngle = 0
    self._wBulletID = 0

end

--初始化
function CSGFUserShoot:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGFUserShoot:Destroy()
	PacketBase.Destroy(self)
end

--写字节流
function CSGFUserShoot:Write()
	self._OutputStream:writeFloat(self._fAngle)
	self._OutputStream:writeUShort(self._wBulletID)
end

return CSGFUserShoot