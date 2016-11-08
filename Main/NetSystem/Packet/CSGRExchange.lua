----
-- 文件名称：CSGRExchange.lua
-- 功能描述：CDK兑换
-- 文件说明：
-- 作    者：金兴泉
-- 创建时间：2016-8-19

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGRExchange = class("CSGRExchange", PacketBase)

function CSGRExchange:ctor()
    PacketBase.ctor(self)
    --CDK
    self._szCDK = ""
end

--初始化
function CSGRExchange:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGRExchange:Destroy()

end

--写字节流
function CSGRExchange:Write()
    self._OutputStream:WriteConvertStringFixlen(self._szCDK, 16)
end

return CSGRExchange