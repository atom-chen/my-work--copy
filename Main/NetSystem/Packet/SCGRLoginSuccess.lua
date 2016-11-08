----
-- 文件名称：SCGRLoginSuccess.lua
-- 功能描述：GameServer 登录成功包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-12
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRLoginSuccess = class("SCGRLoginSuccess", PacketBase)
--构造
function SCGRLoginSuccess:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCGRLoginSuccess:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGRLoginSuccess:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRLoginSuccess:Read(byteStream)


end

--包处理
function SCGRLoginSuccess:Execute()
	--清理房间桌子用户数据
	ServerDataManager._RoomUserList = nil
	EventSystem:DispatchEvent(GameEvent.GE_GSLogin_Success)
	--Game:SetGameState(GameState.GameState_Game)
end

return SCGRLoginSuccess

