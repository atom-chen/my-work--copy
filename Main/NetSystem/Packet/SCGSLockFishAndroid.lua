----
-- 文件名称：SCGSLockFishAndroid.lua
-- 功能描述：机器人锁鱼
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-13
--  修改：
local Game = Game
local GameState = GameState
local ServerDataManager = ServerDataManager

local function Clear()
	ServerDataManager = nil
	Game = nil
	GameState = nil
	ServerDataManager = _G["ServerDataManager"]
	Game = _G["Game"]
	GameState = _G["GameState"]
	print("SCGSLockFishAndroid Clear() ---------")
end

--Clear()

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSLockFishAndroid = class("SCGSLockFishAndroid", PacketBase)
--构造
function SCGSLockFishAndroid:ctor()
    PacketBase.ctor(self)
    --
    self._wChairID = -1
end

--初始化
function SCGSLockFishAndroid:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSLockFishAndroid:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSLockFishAndroid:Read(byteStream)
	--print("SCGSLockFishAndroid:Read ")
	self._wChairID = byteStream:readUShort()
end

--包处理
function SCGSLockFishAndroid:Execute()
	if Game == nil then
		Game = _G["Game"]
	end
	if GameState == nil then
		GameState = _G["GameState"]
	end

	--print("SCGSLockFishAndroid:Execute ")
	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		return
	end
	if self._wChairID == -1 then
		return
	end
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	if mainScene == nil then
		printInfo("------------------mainScene == nil, recieve SCGSLockFishAndroid packet")
		return
	end
	mainScene:OnAndroidLockFish(self._wChairID)

end

return SCGSLockFishAndroid

