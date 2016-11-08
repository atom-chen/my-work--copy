----
-- 文件名称：SCGSGameEnd.lua
-- 功能描述：游戏结束
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-16
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSGameEnd = class("SCGSGameEnd", PacketBase)
--构造
function SCGSGameEnd:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCGSGameEnd:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSGameEnd:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSGameEnd:Read(byteStream)
	print("SCGSGameEnd:Read ")
	
end

--包处理
function SCGSGameEnd:Execute()
	print("SCGSGameEnd:Execute")
	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		return
	end
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	if mainScene == nil then
		printInfo("------------------mainScene == nil, recieve SCGSGameEnd packet")
		return
	end
	Game:SetGameState(GameState.GameState_Lobby)
	
end

return SCGSGameEnd

