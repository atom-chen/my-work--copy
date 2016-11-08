----
-- 文件名称：CSGRUserSitDown.lua
-- 功能描述：坐下请求
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGRUserSitDown = class("CSGRUserSitDown", PacketBase)

function CSGRUserSitDown:ctor()
    PacketBase.ctor(self)
    --桌子号
    self._wTableID = 0
    --椅子号
    self._wChairID = 0
    --
    self._szPassword = ""
end

--初始化
function CSGRUserSitDown:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGRUserSitDown:Destroy()

end

--写字节流
function CSGRUserSitDown:Write()
    self._OutputStream:writeUShort(self._wTableID)
    self._OutputStream:writeUShort(self._wChairID)
    self._OutputStream:WriteConvertStringFixlen(self._szPassword, 33)
end

return CSGRUserSitDown