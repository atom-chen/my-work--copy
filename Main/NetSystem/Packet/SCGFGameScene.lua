----
-- 文件名称：SCGFGameScene.lua
-- 功能描述：游戏场景
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-11
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGFGameScene = class("SCGFGameScene", PacketBase)
--构造
function SCGFGameScene:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCGFGameScene:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGFGameScene:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGFGameScene:Read(byteStream)
	print("SCGFGameScene:Read ")
	
	local tableInsert = table.insert
	ServerDataManager._BarrelDataList = {}
	local gameSceneData = ServerDataManager:GetGameSceneData()
	gameSceneData._cbSceneIndex = byteStream:readByte()
	gameSceneData._cbMaxBullet = byteStream:readByte()
	gameSceneData._lCellScore = byteStream:readLong()
	gameSceneData._lUserAllScore = {}
	local newScore = 0
	for i = 1, 6 do
		newScore =  byteStream:readLong()
		tableInsert(gameSceneData._lUserAllScore, newScore)
	end
	gameSceneData._lUserCellScore = {}
	for i = 1, 6 do
		newScore =  byteStream:readLong()
		tableInsert(gameSceneData._lUserCellScore, newScore)
	end
	gameSceneData._wSpriteID = {}	
	local spriteID = 0
	for i = 1, 36 do
		spriteID = byteStream:readUShort()
		if spriteID ~= 0 then
			tableInsert(gameSceneData._wSpriteID, spriteID)
		end
	end
	gameSceneData._wFishMultiple = {}	
	local multiple = 0
	for i = 1, 36 do
		multiple = byteStream:readUShort()
		tableInsert(gameSceneData._wFishMultiple, multiple)
	end
	gameSceneData._cbProperty = {}		
	local property = 0
	for i = 1, 36 do
		property = byteStream:readByte()
		tableInsert(gameSceneData._cbProperty, property)
	end
	gameSceneData._lMultipleScore = byteStream:readLong()		
	if gameSceneData._lMultipleScore < 10 then
		gameSceneData._lMultipleScore = 10
	end
	
	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		print("------------------not Game State, recieve scene packet")
		return
	end
	--dump(gameSceneData, "gameSceneData", 4)
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	mainScene:SetSceneIndex(gameSceneData._cbSceneIndex)
	local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
	if gameSceneUI ~= nil then
		gameSceneUI:RefreshPlayerBarrel()
	end
end

--包处理
function SCGFGameScene:Execute()
	
end

return SCGFGameScene

