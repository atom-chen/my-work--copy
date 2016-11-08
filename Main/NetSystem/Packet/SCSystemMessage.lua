----
-- 文件名称：SCSystemMessage.lua
-- 功能描述：GameServer 系统消息
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCSystemMessage = class("SCSystemMessage", PacketBase)
--构造
function SCSystemMessage:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCSystemMessage:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCSystemMessage:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCSystemMessage:Read(byteStream)
	local wType = byteStream:readUShort();			
	local wLength = byteStream:readUShort();		
	local szString = byteStream:readConvertString(-1);	
	print("SCSystemMessage:Read ", szString)
	
end

--包处理
function SCSystemMessage:Execute()
	
end

return SCSystemMessage

