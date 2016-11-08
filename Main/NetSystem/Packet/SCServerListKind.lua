----
-- 文件名称：SCServerListKind.lua
-- 功能描述：游戏列表
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-12
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCServerListKind = class("SCServerListKind", PacketBase)

--构造
function SCServerListKind:ctor()
    PacketBase.ctor(self)

end

--Init
function SCServerListKind:Init()
    PacketBase.Init(self)

end

--Destroy
function SCServerListKind:Init()
    
end

--解析字节流
function SCServerListKind:Read(byteStream)
    ServerDataManager._GamekindList = {}
    local gameKindList = ServerDataManager._GamekindList
    local tempList = {}
    --tagGameKind
    while byteStream:getAvailable() > 0   do
        local newGameKindData = ServerDataManager:CreateGameKind()
        newGameKindData._wTypeID = byteStream:readUShort()
        newGameKindData._wJoinID = byteStream:readUShort()
        newGameKindData._wSortID = byteStream:readUShort()
        newGameKindData._wKindID = byteStream:readUShort()
        newGameKindData._wGameID = byteStream:readUShort()
        newGameKindData._dwOnLineCount = byteStream:readULong()
        newGameKindData._dwFullCount = byteStream:readULong()
        newGameKindData._szKindName32 = byteStream:readConvertString(32)
        newGameKindData._szProcessName32 = byteStream:readConvertString(32)
        --dump(newGameKindData)
        table.insert(tempList, newGameKindData)
    end
    --临时 过滤掉客户端没有配置的游戏列表
    local gameListData = TableDataManager._GameConfigData
    for k, v in pairs(tempList)do
        if gameListData[v._wGameID] == nil then
            tempList[k] = nil
        end
    end
    ServerDataManager._GamekindList = {}
    gameKindList = ServerDataManager._GamekindList
    for k, v in pairs(tempList)do
        table.insert(gameKindList, v)
    end
end

--处理
function SCServerListKind:Execute()
    EventSystem:DispatchEvent(GameEvent.GE_ServerGameList)
end

return SCServerListKind