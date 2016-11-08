----
-- 文件名称：CSGRUserStandUp.lua
-- 功能描述：起立请求
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-31

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGRUserStandUp = class("CSGRUserStandUp", PacketBase)

function CSGRUserStandUp:ctor()
    PacketBase.ctor(self)
    --桌子号
    self._wTableID = 0
    --椅子号
    self._wChairID = 0
    --
    self._cbForceLeave = true
end

--初始化
function CSGRUserStandUp:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGRUserStandUp:Destroy()

end

--写字节流
function CSGRUserStandUp:Write()
    self._OutputStream:writeUShort(self._wTableID)
    self._OutputStream:writeUShort(self._wChairID)
    self._OutputStream:writeByte(1)
end

return CSGRUserStandUp