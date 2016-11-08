----
-- 文件名称：SCGRLogonFailPacket.lua
-- 功能描述：登录完成包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-12
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRLogonFailPacket = class("SCGRLogonFailPacket", PacketBase)
--构造
function SCGRLogonFailPacket:ctor()
    PacketBase.ctor(self)
    self._ErrCode = 0
    self._szDescribeString = ""
end

--初始化
function SCGRLogonFailPacket:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRLogonFailPacket:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRLogonFailPacket:Read(byteStream)
    self._ErrCode = byteStream:readLong()
    self._szDescribeString = byteStream:readConvertString(-1)

end

--包处理
function SCGRLogonFailPacket:Execute()
    print("SCGRLogonFailPacket ", self._ErrCode, self._szDescribeString)
    UISystem:ShowMessageBoxOne(self._szDescribeString)
end

return SCGRLogonFailPacket

