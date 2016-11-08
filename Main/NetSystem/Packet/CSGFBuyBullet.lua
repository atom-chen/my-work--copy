----
-- 文件名称：CSGFBuyBullet.lua
-- 功能描述：购买子弹
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-18

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGFBuyBullet = class("CSGFBuyBullet", PacketBase)

function CSGFBuyBullet:ctor()
    PacketBase.ctor(self)
    --
    self._lScore = 0
    self._bAdd = 0

end

--初始化
function CSGFBuyBullet:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGFBuyBullet:Destroy()

end

--写字节流
function CSGFBuyBullet:Write()
	self._OutputStream:writeLongLong(self._lScore)
	self._OutputStream:writeByte(self._bAdd)
end

return CSGFBuyBullet