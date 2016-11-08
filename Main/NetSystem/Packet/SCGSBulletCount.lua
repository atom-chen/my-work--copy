----
-- 文件名称：SCGSBulletCount.lua
-- 功能描述：加减分
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-15
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSBulletCount = class("SCGSBulletCount", PacketBase)
--构造
function SCGSBulletCount:ctor()
    PacketBase.ctor(self)
    self._wChairID = 0
    self._bAdd = false
    self._llScore = 0
end

--初始化
function SCGSBulletCount:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSBulletCount:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSBulletCount:Read(byteStream)
	print("SCGSBulletCount:Read ")
	self._wChairID = byteStream:readUShort()
	local isAdd = byteStream:readByte()
	if isAdd == 1 then
		self._bAdd = true
	end

	self._llScore = byteStream:readLongLong()
end

--包处理
function SCGSBulletCount:Execute()
	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		return
	end
	local gameSceneData = ServerDataManager:GetGameSceneData()

	--对于频繁调用的接口，不走EventSystem 

	--UI上的表现：播放炮筒动画
	local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
	if gameSceneUI ~= nil then
		if self._bAdd == true then
			gameSceneData._lUserAllScore[self._wChairID + 1] = self._llScore
			gameSceneUI:UpdatePlayerScore(self._wChairID, self._llScore)
		else
			gameSceneData._lUserAllScore[self._wChairID + 1] = 0
			gameSceneUI:UpdatePlayerScore(self._wChairID, 0)
		end
	end
end

return SCGSBulletCount

