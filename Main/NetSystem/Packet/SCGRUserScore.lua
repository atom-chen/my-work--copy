----
-- 文件名称：SCGRUserScore.lua
-- 功能描述：游戏房间内 用户分数
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRUserScore = class("SCGRUserScore", PacketBase)

local ServerDataManager = ServerDataManager
local Game = Game
local GameState = GameState

local function Clear()
	ServerDataManager = nil
	Game = nil
	GameState = nil
	ServerDataManager = _G["ServerDataManager"]
	Game = _G["Game"]
	GameState = _G["GameState"]
	print("SCGRUserScore Clear() ---------")
end

--Clear()

--构造
function SCGRUserScore:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGRUserScore:Init()
    PacketBase.Init(self)

    --当前用户的ChairID
    self._wChairID = -1
    self._wTableID = -1
    self._Score = -1
    self._dwUserID = 0
    self._lInsure = 0
end

--销毁
function SCGRUserScore:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCGRUserScore:Read(byteStream)
	local dwUserID = byteStream:readULong()
	self._dwUserID = dwUserID
	local userData = ServerDataManager:GetUserDataByUserID(dwUserID)
	if userData == nil then
		return
	end
	self._wChairID = userData._wChair
	self._wTableID = userData._wTableID
	userData._lScore = byteStream:readLongLong()
	userData._lGrade = byteStream:readLongLong()
	userData._lInsure = byteStream:readLongLong()
	userData._dwWinCount = byteStream:readULong()
	userData._dwLostCount = byteStream:readULong()
	userData._dwDrawCount = byteStream:readULong()
	userData._dwFleeCount = byteStream:readULong()
	userData._dwUserMedal = byteStream:readULong()
	userData._dwExperience = byteStream:readULong()
	userData._lLoveLiness = byteStream:readLong()

	--如果自己
	self._Score = userData._lScore
	self._lInsure = userData._lInsure
end

--包处理
function SCGRUserScore:Execute()
	--如果是自己，存储到_SelfUserInfo
	local selfData = ServerDataManager._SelfUserInfo
	if selfData ~= nil then
		if selfData._dwUserID == self._dwUserID then
			selfData._lUserScore = self._Score
			print("self score ", selfData._lUserScore, self._lInsure)
			EventSystem:DispatchEvent(GameEvent.GE_UserInfoChange)
		end
	end
	if Game == nil then
		Game = _G["Game"]
	end
	if GameState == nil then
		GameState = _G["GameState"]
	end
    local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		return
	end
	if self._wChairID == -1 or self._wTableID == -1 then
		return
	end
	if self._wTableID ~= ServerDataManager._CurrentTableID then
		return
	end
	--更新玩家UI显示
	local uigameScene = UISystem:GetUIInstance(UIType.UIType_GameScene)
	if uigameScene ~= nil then
		uigameScene:UpdatePlayerScore(self._wChairID, self._Score)
	end
end

return SCGRUserScore

