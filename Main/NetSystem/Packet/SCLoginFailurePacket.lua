----
-- 文件名称：SCLoginFailurePacket.lua
-- 功能描述：登录成功包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-12
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCLoginFailurePacket = class("SCLoginFailurePacket", PacketBase)
--构造
function SCLoginFailurePacket:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCLoginFailurePacket:Init()
    PacketBase.Init(self)

end

--销毁
function SCLoginFailurePacket:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCLoginFailurePacket:Read(byteStream)
	local resultCode = byteStream:readLong()
	local szDes = byteStream:readConvertString(-1)
	UISystem:ShowMessageBoxOne(szDes)
end

--包处理
function SCLoginFailurePacket:Execute()
    
end

return SCLoginFailurePacket

