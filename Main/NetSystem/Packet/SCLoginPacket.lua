----
-- 文件名称：SCLoginPacket.lua
-- 功能描述：登录成功包
-- 文件说明： 登录成功逻辑：服务器的数据缓存，  刷新UI
-- 作    者：王雷雷
-- 创建时间：2016-7-11
--  修改：



local PacketBase = require "Main.NetSystem.PacketBase"
local SCLoginPacket = class("SCLoginPacket", PacketBase)
--构造
function SCLoginPacket:ctor()
	PacketBase.ctor(self)
end

--初始化
function SCLoginPacket:Init()
	PacketBase.Init(self)

end

--销毁
function SCLoginPacket:Destroy()
	PacketBase.Destroy(self)
end

--解析字节流
function SCLoginPacket:Read(byteStream)
    local selfServerInfo = ServerDataManager._SelfUserInfo
    selfServerInfo._wFaceID = byteStream:readUShort()
    selfServerInfo._cbGender = byteStream:readByte()
    selfServerInfo._dwUserID = byteStream:readULong()
    selfServerInfo._dwGameID = byteStream:readULong()
    selfServerInfo._dwCustomID = byteStream:readULong()
    selfServerInfo._dwExperience = byteStream:readULong()
    selfServerInfo._dwLoveLiness = byteStream:readULong()
    selfServerInfo._szAccounts32 = byteStream:readConvertString(32)
    selfServerInfo._szNickName32 = byteStream:readConvertString(32)
    selfServerInfo._lUserScore = byteStream:readLongLong()
    selfServerInfo._lUserInsure = byteStream:readLongLong()
    --dump(selfServerInfo, "SCLoginPacket selfServerInfo", 10)
end

--包处理
function SCLoginPacket:Execute()
    EventSystem:DispatchEvent(GameEvent.GE_UserInfoChange)
end





return SCLoginPacket

