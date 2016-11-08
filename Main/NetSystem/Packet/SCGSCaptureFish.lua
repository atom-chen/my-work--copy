----
-- 文件名称：SCGSCaptureFish.lua
-- 功能描述：抓到鱼
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-15
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSCaptureFish = class("SCGSCaptureFish", PacketBase)
local Game = Game
local GameState = GameState

local function Clear()
	Game = nil
	GameState = nil
	Game = _G["Game"]
	GameState = _G["GameState"]

end

--Clear()

--构造
function SCGSCaptureFish:ctor()
    PacketBase.ctor(self)

	self._wChairID	= 0					--打中鱼的玩家
	self._llUserScore = 0					--玩家当前分数
	self._cbProperty = 0						--打中的鱼的属性
	self._cbCaptureCount = 0
	self._lTotalScore = 0
	self._lTotalMultiple = 0
	--self._fishScoreInfo[MAX_HITFISH];
	self._FishList = nil
end

--初始化
function SCGSCaptureFish:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSCaptureFish:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSCaptureFish:Read(byteStream)
	--print("SCGSCaptureFish:Read ")
	
	self._wChairID = byteStream:readUShort()
	self._llUserScore = byteStream:readLongLong()
	self._cbProperty = byteStream:readByte()
	self._cbCaptureCount = byteStream:readByte()
	self._lTotalScore = byteStream:readLong()
	self._lTotalMultiple = byteStream:readLong()
	local fishInfo = {}
	self._FishList = {}
	for i = 1, self._cbCaptureCount do
		fishInfo._wFishID = byteStream:readUShort()
		fishInfo._wFishMultiple = byteStream:readUShort()
		fishInfo._lFishScore = byteStream:readLong()
		table.insert(self._FishList, fishInfo)
	end
end

--包处理
function SCGSCaptureFish:Execute()
	--print("SCGSCaptureFish:Execute", self._wChairID, self._fAngle, self._wBulletID)
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
	--对于频繁调用的接口，不走EventSystem 

	--场景中：创建子弹
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	if mainScene == nil then
		printInfo("------------------mainScene == nil, recieve SCGSCaptureFish packet")
		return
	end
	mainScene:OnCaptureFish(self._wChairID, self._llUserScore, self._cbProperty, self._cbCaptureCount, self._lTotalScore, self._lTotalMultiple, self._FishList)
end

return SCGSCaptureFish

