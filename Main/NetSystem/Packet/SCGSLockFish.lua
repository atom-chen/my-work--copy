----
-- 文件名称：SCGSLockFish.lua
-- 功能描述：锁鱼
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-26
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

end

--Clear()


local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSLockFish = class("SCGSLockFish", PacketBase)
--构造
function SCGSLockFish:ctor()
    PacketBase.ctor(self)

	self._wSpriteID	 = 0	
	self._wFishID = 0		
	self._wChairID	= 0		
end

--初始化
function SCGSLockFish:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSLockFish:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSLockFish:Read(byteStream)
	--print("SCGSLockFish:Read ")
	self._wSpriteID = byteStream:readUShort()
    self._wFishID = byteStream:readUShort()
    self._wChairID = byteStream:readUShort()
end

--包处理
function SCGSLockFish:Execute()
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
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	if mainScene == nil then
		printInfo("------------------mainScene == nil, recieve SCGSLockFish packet")
		return
	end
	--wChairID, spriteID, fishServerID
	mainScene:OnPlayerLockFish(self._wChairID, self._wSpriteID, self._wFishID)

end

return SCGSLockFish

