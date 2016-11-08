----
-- 文件名称：ServerDataManager.lua
-- 功能描述：服务器下发数据缓存,所有动态数据的保存
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-27
--  修改：


local ServerDataManager = class("ServerDataManager")

local UserInfoData = require "Main.ServerData.UserInfoData"
local GameKindData = require "Main.ServerData.GameKind"
local GameType = require "Main.ServerData.GameType"
local LoginServerData = require "Main.ServerData.LoginServerData"
local ItemData = require "Main.ServerData.ItemData"
local RankData = require "Main.ServerData.RankData"
local GameServer = require "Main.ServerData.GameServer"
local RoomUserData = require "Main.ServerData.RoomUserData"
local GameSceneData = require "Main.ServerData.GameSceneData"
local ConfigData = require "Main.ServerData.ConfigData"
local QianDaoData = require "Main.ServerData.QianDaoData"
local CJRankData = require "Main.ServerData.CJRankData"

function ServerDataManager:ctor()


end

--初始化
function ServerDataManager:Init()
    --登陆缓存数据
    self._LoginServerData = LoginServerData.new()
    --self信息
    self._SelfUserInfo = UserInfoData.new()
    --签到数据
    self._QianDaoData = nil
    --服务器列表  游戏种类
    self._GamekindList = {}
    self._GamekTypeList = {}
    --{ [gameID] = {......} }
    self._GameServerList = {}
    --Http返回数据 背包物品数据 顺序连续的
    self._BagItemDataList = nil
    --排行榜数据
    self._RankDataList = nil
    --大厅当前选择的游戏ID(3000 3001 ......)
    self._CurSelGameID = 0
    --当前所在UI索引值，用于返回逻辑(0:登陆 1：大厅 2：房间内 )
    self._IndexForReturn = 0
    --当前连接的游戏服务器
    self._CurConnectGSIP = ""
    self._CurConnectGSPort = ""
    --Room用户信息 {[TableID] = {[1] = info }} (tableid chairID从0开始的)
    self._RoomUserList = nil
    --GameSceneData
    self._GameSceneData = nil
    
    --需要延时创建的鱼
    self._FishPackList = nil
    --当前的进入的游戏房间桌子ID TableID
    self._CurrentTableID = 0
    --炮筒倍率
    self._BarrelDataList = {}
    --自己所在的椅子ID(0开始的)
    self._MeChairID = -1
    --主角的子弹ID计数
    self._MeBulletCount = 0
    --抽奖排行榜数据
    self._CJRankDataList = nil
    --消息列表
    self._MessageList = nil
    self:LoadLocalConfig()
end
--销毁
function ServerDataManager:Destroy()
    self:ClearData()
end

--清理数据，用于从大厅返回登陆时
function ServerDataManager:ClearData()
    print("ServerDataManager:ClearData ----------------------")
    self._LoginServerData = LoginServerData.new()
    self._SelfUserInfo = UserInfoData.new()
    self._QianDaoData = nil
    self._GamekindList = {}
    self._GamekTypeList = {}
    self._GameServerList = {}
    self._BagItemDataList = nil
    self._RankDataList = nil
    self._CurSelGameID = 0
    self._IndexForReturn = 0
    self._CurConnectGSIP = ""
    self._CurConnectGSPort = ""
    self._RoomUserList = nil
    self._GameSceneData = nil
    self._FishPackList = nil
    self._CurrentTableID = 0
    self._BarrelDataList = {}
    self._MeChairID = -1
    self._MeBulletCount = 0
    self._CJRankDataList = nil
    self._MessageList = nil
end


function ServerDataManager:LoadLocalConfig()
    if (self._ConfigData) then
        self._ConfigData = nil
    end
    local userDefault = cc.UserDefault:getInstance()
    self._ConfigData = ConfigData.new()
    self._ConfigData._UserAccount = userDefault:getStringForKey("account","")
    local savePwd = userDefault:getStringForKey("pwd","")
    self._ConfigData._UserPassword = SimpleEncryptString(savePwd)
    self._ConfigData._EnableMusic = userDefault:getIntegerForKey("enablemusic",1)
    self._ConfigData._EnableEffect = userDefault:getIntegerForKey("enableeffect",1)
    self._ConfigData._EnableSpecial = userDefault:getIntegerForKey("enablespecial",1)
    self._ConfigData._EnableShake = userDefault:getIntegerForKey("enableshake",0)
    self._ConfigData._EnableNotice = userDefault:getIntegerForKey("enablenotice",1)
end

function ServerDataManager:SaveLocalConfig()
    if (self._ConfigData == nil) then
         return
    end
    local userDefault = cc.UserDefault:getInstance()
--    cc.UserDefault:getInstance():setStringForKey("account",self._ConfigData._UserAccount)
--    cc.UserDefault:getInstance():setStringForKey("pwd",self._ConfigData._UserPassword)
    userDefault:setIntegerForKey("enablemusic",self._ConfigData._EnableMusic)
    userDefault:setIntegerForKey("enableeffect",self._ConfigData._EnableEffect)
    userDefault:setIntegerForKey("enablespecial",self._ConfigData._EnableSpecial)
    userDefault:setIntegerForKey("enableshake",self._ConfigData._EnableShake)
    userDefault:setIntegerForKey("enablenotice",self._ConfigData._EnableNotice)
    
    userDefault:flush()
end


--创建游戏种类
function ServerDataManager:CreateGameKind()
    return GameKindData.new()
end

--创建类型
function ServerDataManager:CreateGameType()
    return GameType.new()
end

--创建GameServer 数据
function ServerDataManager:CreateGameServer()
    return GameServer.new()
end

--创建物品
function ServerDataManager:CreateItem()
	return ItemData.new()
end

--排行榜 数据
function ServerDataManager:CreateRankData()
    return RankData.new()
end
--创建签到数据
function ServerDataManager:CreateQianDaoData()
    return QianDaoData.new()
end

--创建UserData
function ServerDataManager:CreateUserData()
    return RoomUserData.new()
end

--创建抽奖排行榜数据
function ServerDataManager:CreateCJRankData()
    return CJRankData.new()
end

--获取 房间内某userID用户数据
function ServerDataManager:GetUserDataByUserID(dwUserID)
    if self._RoomUserList == nil then
        --print("ServerDataManager:GetUserDataByUserID nil", dwUserID)
        return nil
    end
    local userData = nil
    local resultChair = nil
    for k, v in pairs(self._RoomUserList)do
        if userData ~= nil then
            break
        end
        local tableData = v
        for k1, v1 in pairs(tableData)do
            if v1._dwUserID == dwUserID then
                userData = v1
                resultChair = k1
                break
            end
        end
    end
    return userData, resultChair
end

--
function ServerDataManager:GetGameSceneData()
    if self._GameSceneData == nil then
        self._GameSceneData =  GameSceneData.new()
    end
    return self._GameSceneData
end

--获取ChairData
function ServerDataManager:GetCurrentChairData(wChair)
    local chairDataList = self._RoomUserList[self._CurrentTableID]
    if chairDataList == nil then
        return
    end
    return chairDataList[wChair]
end
--根据积分获得炮筒样式
local function GetBarrelIndex(cellScore, roomCellScore, factor)
    if cellScore == nil or roomCellScore == nil or factor == nil then
        return 2
    end
    
    local nIndex = 2
    if cellScore <= 0.2 * factor * roomCellScore then
        nIndex = 2
    elseif cellScore <= 0.5 * factor * roomCellScore then
        nIndex = 3
    else
        nIndex = 4
    end
    return nIndex
end

--获得炮筒倍率 chairIndex 从0开始
function ServerDataManager:GetBarrelNum(chairIndex)
    local nRate = self._BarrelDataList[chairIndex]
    if nRate == nil then
        local scenePlayerData = self._GameSceneData
        nRate = GetBarrelIndex( scenePlayerData._lUserCellScore[chairIndex + 1], scenePlayerData._lCellScore, scenePlayerData._lMultipleScore)
        self._BarrelDataList[chairIndex] = nRate
    end
    return nRate
end
-- chairIndex 从0开始
function ServerDataManager:UpdateBarrel(chairIndex)
    local scenePlayerData = self._GameSceneData
    nRate = GetBarrelIndex( scenePlayerData._lUserCellScore[chairIndex + 1], scenePlayerData._lCellScore, scenePlayerData._lMultipleScore)
    self._BarrelDataList[chairIndex] = nRate
end
--获取子弹类型 chairIndex 从0开始
function ServerDataManager:GetBulletType(chairIndex)
    if self._RoomUserList == nil then
        return 1
    end
    local chairDataList = self._RoomUserList[self._CurrentTableID]
    if chairDataList == nil then
        print("ServerDataManager:GetBulletType chairDataList == nil")
        return 
    end
    local chairData = chairDataList[chairIndex]
    if chairData == nil then
        print("ServerDataManager:GetBulletType chairData == nil")
        return
    end
    local isSuper = chairData._IsSuperCannon
    local barelIndex = self:GetBarrelNum(chairIndex)
    if barelIndex == 2 then
        if isSuper == true then
            bulletType = 7
        else
            bulletType = 1
        end
    elseif barelIndex == 3 then
        if isSuper == true then
            bulletType = 9
        else
            bulletType = 3
        end
    elseif barelIndex == 4 then
        if isSuper == true then
            bulletType = 11
        else
            bulletType = 5
        end
    end
    return bulletType
end

return ServerDataManager