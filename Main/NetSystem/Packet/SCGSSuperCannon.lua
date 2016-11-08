----
-- 文件名称：SCGSSuperCannon.lua
-- 功能描述：超级炮(能量炮)
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-16
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
	print("SCGSSuperCannon Clear() ---------")
end

--Clear()

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSSuperCannon = class("SCGSSuperCannon", PacketBase)
--构造
function SCGSSuperCannon:ctor()
    PacketBase.ctor(self)
    self._wChairID = -1
    self._isSuperCannon = false
end

--初始化
function SCGSSuperCannon:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSSuperCannon:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSSuperCannon:Read(byteStream)
	--print("SCGSSuperCannon:Read ")
	self._wChairID = byteStream:readUShort()
	local flag = byteStream:readByte()
	if flag == 1 then
		self._isSuperCannon = true
	else
		self._isSuperCannon = false
	end
end

--包处理
function SCGSSuperCannon:Execute()
	if Game == nil then
		Game = _G["Game"]
	end
	if GameState == nil then
		GameState = _G["GameState"]
	end
	if ServerDataManager == nil then
		ServerDataManager = _G["ServerDataManager"]
	end
    --print("SCGSSuperCannon:Execute ")
	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		return
	end
	if self._wChairID == -1 then
		return
	end
	--dump(ServerDataManager, "SCGSSuperCannon:Execute")

	local meTableID = ServerDataManager._CurrentTableID
	local chairList = ServerDataManager._RoomUserList[meTableID]
	if chairList == nil then
		return
	end
	local userData = chairList[self._wChairID]
	if userData == nil then
		return
	end
	userData._IsSuperCannon = self._isSuperCannon
	local gameSceneUI = UISystem:GetUIInstance(UIType.UIType_GameScene)
	if gameSceneUI ~= nil then
		gameSceneUI:SetSuperCannon(self._wChairID, self._isSuperCannon)
	end
end

return SCGSSuperCannon

