----
-- 文件名称：CSGFGameOption.lua
-- 功能描述：框架消息 游戏配置
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-11

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGFGameOption = class("CSGFGameOption", PacketBase)

function CSGFGameOption:ctor()
    PacketBase.ctor(self)

    self._cbAllowLookon = 0    --旁观标志
    self._dwFrameVersion = 0   --框架版本
    self._dwClientVersion = 0  --游戏版本
end

--初始化
function CSGFGameOption:Init()
    PacketBase.Init(self)

    self._cbAllowLookon = 0
    self._dwFrameVersion = GetProcessVersion()
    self._dwClientVersion = GetProcessVersion()

end

--Destroy
function CSGFGameOption:Destroy()

end

--写字节流
function CSGFGameOption:Write()
    self._OutputStream:writeUByte(self._cbAllowLookon)
    self._OutputStream:writeULong(self._dwFrameVersion)
    self._OutputStream:writeULong(self._dwClientVersion)
end

return CSGFGameOption