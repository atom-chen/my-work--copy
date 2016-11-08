----
-- 文件名称：SCGSUserShoot.lua
-- 功能描述：开炮
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-15
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSUserShoot = class("SCGSUserShoot", PacketBase)
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
	--dump(Game, "SCGSUserShoot Game")
end

--Clear()

--构造
function SCGSUserShoot:ctor()
    PacketBase.ctor(self)
    --
    self._wChairID = -1
    self._fAngle = 0
    self._wBulletID = 0
    self._IsAndroid = false
    self._llScore = 0
end

--初始化
function SCGSUserShoot:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSUserShoot:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSUserShoot:Read(byteStream)
	--print("SCGSUserShoot:Read ")
	
	self._wChairID = byteStream:readUShort()
	self._fAngle = byteStream:readFloat()
	local bAndroid = byteStream:readByte()
	if bAndroid == 1 then
		self._IsAndroid = true
	else
		self._IsAndroid = false
	end
	self._llScore = byteStream:readLongLong()
	self._wBulletID = byteStream:readUShort()

end

--包处理
function SCGSUserShoot:Execute()
	--print("SCGSUserShoot:Execute", self._wChairID, self._fAngle, self._wBulletID)
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
	local gameSceneData = ServerDataManager:GetGameSceneData()
	gameSceneData._lUserAllScore[self._wChairID + 1] = self._llScore
	--对于频繁调用的接口，不走EventSystem 


	--场景中：创建子弹
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	if mainScene == nil then
		printInfo("------------------mainScene == nil, recieve SCGSUserShoot packet")
		return
	end
	local isFix, resultDegree = mainScene:FixUIBarrelAngle(self._wChairID, self._fAngle)
	mainScene:CreateBullet(self._wChairID, self._wBulletID, self._fAngle, self._IsAndroid)
	--UI上的表现：播放炮筒动画
	local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
	if gameSceneUI ~= nil then
		gameSceneUI:PlayBarrelAnim(self._wChairID, resultDegree, isFix)
		gameSceneUI:UpdatePlayerScore(self._wChairID, self._llScore)
	end
end

return SCGSUserShoot

