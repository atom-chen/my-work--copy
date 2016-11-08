----
-- 文件名称：SCGSChangeScene.lua
-- 功能描述：切换场景
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-11
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSChangeScene = class("SCGSChangeScene", PacketBase)
--构造
function SCGSChangeScene:ctor()
    PacketBase.ctor(self)
    --当前场景
    self._cbSceneIndex = 0
end

--初始化
function SCGSChangeScene:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSChangeScene:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSChangeScene:Read(byteStream)
	print("SCGSChangeScene:Read ")
	self._cbSceneIndex = byteStream:readByte()
end

--包处理
function SCGSChangeScene:Execute()
	local currentState = Game:GetCurrentGameState()
	if 	currentState ~= GameState.GameState_Game then
		return
	end
	local gamePlay = Game:GetCurStateInstance()
	local mainScene = gamePlay:GetGameScene()
	if mainScene == nil then
		printInfo("------------------mainScene == nil, recieve SCGSCaptureFish packet")
		return
	end
	mainScene:ChangeScene(self._cbSceneIndex)
end

return SCGSChangeScene

