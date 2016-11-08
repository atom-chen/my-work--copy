----
-- 文件名称：SCServerListType.lua
-- 功能描述：服务器列表
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-12
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCServerListType = class("SCServerListType", PacketBase)

--构造
function SCServerListType:ctor()
    PacketBase.ctor(self)

end

--Init
function SCServerListType:Init()
    PacketBase.Init(self)

end

--Destroy
function SCServerListType:Init()
    
end

--解析字节流
function SCServerListType:Read(byteStream)
    ServerDataManager._GamekTypeList = {}
    local gameTypeList = ServerDataManager._GamekTypeList
    --tagGameType 
    while byteStream:getAvailable() > 0   do
        local newGameKindData = ServerDataManager:CreateGameType()
        newGameKindData._wJoinID = byteStream:readUShort()
        newGameKindData._wSortID = byteStream:readUShort()
        newGameKindData._wTypeID = byteStream:readUShort()
        newGameKindData._szTypeName32 = byteStream:readConvertString(32)
        table.insert(gameTypeList, newGameKindData)
    end
    --dump(gameTypeList)
end

--处理
function SCServerListType:Execute()
    EventSystem:DispatchEvent(GameEvent.GE_ServerGameTypeList)
end

return SCServerListType