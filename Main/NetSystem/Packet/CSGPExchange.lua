----
-- 文件名称：CSGPExchange.lua
-- 功能描述：CDK兑换
-- 文件说明：
-- 作    者：金兴泉
-- 创建时间：2016-8-19

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGPExchange = class("CSGPExchange", PacketBase)

function CSGPExchange:ctor()
    PacketBase.ctor(self)
    --
    self._dwUserID = 0
    --CDK
    self._szCDK = ""
end

--初始化
function CSGPExchange:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGPExchange:Destroy()

end

--写字节流
function CSGPExchange:Write()
    self._OutputStream:writeULong(self._dwUserID)
    self._OutputStream:WriteConvertStringFixlen(self._szCDK, 16)
end

return CSGPExchange