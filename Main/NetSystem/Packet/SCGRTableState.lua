----
-- 文件名称：SCGRTableState.lua
-- 功能描述：桌子状态
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRTableState = class("SCGRTableState", PacketBase)
--构造
function SCGRTableState:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGRTableState:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRTableState:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCGRTableState:Read(byteStream)
	local wTableID = byteStream:readUShort()
	local cbTableLock = byteStream:readByte()
	local cbPlayStatus = byteStream:readByte()
	
end

--包处理
function SCGRTableState:Execute()
    
end

return SCGRTableState

