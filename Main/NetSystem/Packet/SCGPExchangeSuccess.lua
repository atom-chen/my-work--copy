----
-- 文件名称：SCGPExchangeSuccess.lua
-- 功能描述：CDK兑换
-- 文件说明：
-- 作    者：金兴泉
-- 创建时间：2016-8-19

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local SCGPExchangeSuccess = class("SCGPExchangeSuccess", PacketBase)

function SCGPExchangeSuccess:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGPExchangeSuccess:Init()
    PacketBase.Init(self)

end

--Destroy
function SCGPExchangeSuccess:Destroy()
    PacketBase.Destroy(self)
end


--解析字节流
function SCGPExchangeSuccess:Read(byteStream)
    local resultCode = byteStream:readLong()
    local szDes = byteStream:readConvertString(-1)
    UISystem:ShowMessageBoxOne(szDes)
end

--包处理
function SCGPExchangeSuccess:Execute()

end

return SCGPExchangeSuccess