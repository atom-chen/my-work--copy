----
-- 文件名称：SCGameServerList.lua
-- 功能描述：游戏服务器列表
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-5
--  修改：


local PacketBase = require "Main.NetSystem.PacketBase"
local SCGameServerList = class("SCGameServerList", PacketBase)

--构造
function SCGameServerList:ctor()
    PacketBase.ctor(self)

end

--Init
function SCGameServerList:Init()
    PacketBase.Init(self)

end

--Destroy
function SCGameServerList:Init()
    
end

--排序函数
local function SortFunc(a, b)
    if a == nil or b == nil then
        return false
    end
    if a._wSortID < b._wSortID then
        return true
    else
        return false
    end
end
--解析字节流
function SCGameServerList:Read(byteStream)
	ServerDataManager._GameServerList = {}
	local gameServerList = ServerDataManager._GameServerList
	--tagGameServer
	 while byteStream:getAvailable() > 0   do
        local newServerData = ServerDataManager:CreateGameServer()
        newServerData._wKindID = byteStream:readUShort()
        newServerData._wNodeID = byteStream:readUShort()
        newServerData._wSortID = byteStream:readUShort()
        newServerData._wServerID = byteStream:readUShort()
        newServerData._wServerPort = byteStream:readUShort()
        newServerData._dwOnLineCount = byteStream:readULong()
        newServerData._dwFullCount = byteStream:readULong()
        newServerData._szServerAddr = byteStream:readConvertString(32)
        newServerData._szServerName = byteStream:readConvertString(32)
       -- dump(newServerData, "newServerData", 5)
        local subList = gameServerList[newServerData._wKindID]
        if subList == nil then
            gameServerList[newServerData._wKindID] = {}
            subList = gameServerList[newServerData._wKindID]
        end
        table.insert(subList, newServerData)
        --table.insert(gameServerList, newServerData)
    end

    for k, v in pairs(gameServerList)do
        local subList = v
        table.sort(subList, SortFunc)
    end
    dump(gameServerList, "SortServerList", 5)
end

--处理
function SCGameServerList:Execute()
    
end

return SCGameServerList
