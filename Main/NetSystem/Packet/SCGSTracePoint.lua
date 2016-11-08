----
-- 文件名称：SCGSTracePoint.lua
-- 功能描述：游戏场景添加鱼
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-12
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
	--print("SCGSTracePoint Clear() ---------")
end

--Clear()


local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSTracePoint = class("SCGSTracePoint", PacketBase)
--构造
function SCGSTracePoint:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCGSTracePoint:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSTracePoint:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCGSTracePoint:Read(byteStream)
	if Game == nil then
		Game = _G["Game"]
	end
	if GameState == nil then
		GameState = _G["GameState"]
	end

	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		--dump(Game, "Game")
		--dump(ServerDataManager, "ServerDataManager")
		--dump(GameState, "GameState")
		printInfo("------------------not Game State, recieve SCGSTracePoint packet")
		return
	end
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	if mainScene == nil then
		printInfo("------------------mainScene == nil, recieve SCGSTracePoint packet")
		return
	end
	while byteStream:getAvailable() > 0 do
		local  wFishID = byteStream:readUShort()--鱼ID
		local wSpriteID = byteStream:readUShort()--鱼类型
		local nPathIndex1 =  byteStream:readInt() --鱼轨迹
		local nCreateDelayTime = byteStream:readInt()
		local wMultiple = byteStream:readUShort()
		local cbProperty = byteStream:readByte()

		local wActionID = byteStream:readUShort()--动作类型
		local nXPos = byteStream:readInt() --初始坐标，当nPathIndex1为-1时有效
		local nYPos = byteStream:readInt()

		local fRotationList = {}  --初始角度，当nPathIndex1为-1时有效
		local tableInsert = table.insert
		local value = nil
		for i = 1, 5 do
			value = byteStream:readFloat()
			tableInsert(fRotationList, value)
		end
		local nMoveTimeList = {}
		for i = 1, 5 do
			value = byteStream:readInt()
			tableInsert(nMoveTimeList, value)
		end
		local pointArray = {}
		for i = 1, 5 do
			pointArray[i] = cc.p(0, 0)
		end
		local nMoveEndXList = {}
		for i = 1, 5 do
			value = byteStream:readInt()
			tableInsert(nMoveEndXList, value)
			pointArray[i].x = value
		end
		local nMoveEndYList = {}
		for i = 1, 5 do
			value = byteStream:readInt()
			tableInsert(nMoveEndYList, value)
			pointArray[i].y = value
		end
		--倍率

		if nCreateDelayTime <= 0 then
			--print("newFish", wSpriteID, wFishID, nPathIndex1, nXPos, nYPos)
			local speedArray = {}
			local newFish = mainScene:CreateNewFish(1000 + wSpriteID, wFishID, nPathIndex1, nXPos, nYPos, wActionID, speedArray, nMoveTimeList, fRotationList, pointArray, cbProperty, wMultiple)
			newFish:SetAttrib(cbProperty)
		else
			--缓存数据
			mainScene:AddDelayFish(nCreateDelayTime, 1000 + wSpriteID, wFishID, nPathIndex1, nXPos, nYPos, wActionID, speedArray, nMoveTimeList, fRotationList, pointArray, cbProperty, wMultiple)
		end
	end
end

--包处理
function SCGSTracePoint:Execute()
	
end

return SCGSTracePoint

