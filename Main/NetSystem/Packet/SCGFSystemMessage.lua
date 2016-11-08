----
-- 文件名称：SCGFSystemMessage.lua
-- 功能描述：GameServer 系统消息
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGFSystemMessage = class("SCGFSystemMessage", PacketBase)
--构造
function SCGFSystemMessage:ctor()
    PacketBase.ctor(self)
    --当前消息
    self._CurMsg = ""
end

--初始化
function SCGFSystemMessage:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGFSystemMessage:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGFSystemMessage:Read(byteStream)
	local wType = byteStream:readUShort();			
	local wLength = byteStream:readUShort();		
	local szString = byteStream:readConvertString(-1);	
	print("SCGFSystemMessage:Read ", szString)
	--table.insert(ServerDataManager._MessageList, szString)
end

--包处理
function SCGFSystemMessage:Execute()
	
end

return SCGFSystemMessage

