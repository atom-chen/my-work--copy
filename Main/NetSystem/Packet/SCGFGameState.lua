----
-- 文件名称：SCGFGameState.lua
-- 功能描述：游戏状态
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-11
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGFGameState = class("SCGFGameState", PacketBase)
--构造
function SCGFGameState:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCGFGameState:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGFGameState:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGFGameState:Read(byteStream)
	local cbGameStatus = byteStream:readByte()
	local cbAllowLookon = byteStream:readByte()
	
	print("SCGFGameState:Read")
end

--包处理
function SCGFGameState:Execute()
	
end

return SCGFGameState

