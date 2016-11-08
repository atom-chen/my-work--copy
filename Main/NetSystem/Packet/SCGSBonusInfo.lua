----
-- 文件名称：SCGSBonusInfo.lua
-- 功能描述：更新 炮筒倍率
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-13
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSBonusInfo = class("SCGSBonusInfo", PacketBase)
--构造
function SCGSBonusInfo:ctor()
    PacketBase.ctor(self)
    self._wChairID = 0
    self._lCellScore = 0
end

--初始化
function SCGSBonusInfo:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSBonusInfo:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSBonusInfo:Read(byteStream)
	--print("SCGSBonusInfo:Read ")
	self._wChairID = byteStream:readUShort()
	self._lCellScore = byteStream:readLong()
end

--包处理
function SCGSBonusInfo:Execute()
	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		return
	end
	local gameSceneData = ServerDataManager:GetGameSceneData()
	gameSceneData._lUserCellScore[self._wChairID + 1] = self._lCellScore
	ServerDataManager:UpdateBarrel(self._wChairID)
	--print("SCGSBonusInfo ", self._wChairID, self._lCellScore)
	local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
	if gameSceneUI ~= nil then
		gameSceneUI:UpdateBarrel(self._wChairID)
	end

end

return SCGSBonusInfo

