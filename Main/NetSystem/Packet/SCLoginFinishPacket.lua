----
-- 文件名称：SCLoginFinishPacket.lua
-- 功能描述：登录完成包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-12
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCLoginFinishPacket = class("SCLoginFinishPacket", PacketBase)
--构造
function SCLoginFinishPacket:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCLoginFinishPacket:Init()
    PacketBase.Init(self)

end

--销毁
function SCLoginFinishPacket:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCLoginFinishPacket:Read(byteStream)
    
end

--包处理
function SCLoginFinishPacket:Execute()
    --保存登陆的帐号与密码
     local loginData = ServerDataManager._LoginServerData
     local userDefault = cc.UserDefault:getInstance()
     --登陆
     if loginData._CurActionType == 0 then
        userDefault:setStringForKey("account", loginData._UserAccount)
        local savePwd = SimpleEncryptString(loginData._Password)
        userDefault:setStringForKey("pwd", savePwd)
        userDefault:flush()
     --注册
     else
        userDefault:setStringForKey("account", loginData._RegAccount)
        local savePwd = SimpleEncryptString(loginData._RegPwd)
        userDefault:setStringForKey("pwd", savePwd)
        userDefault:flush()
     end

    --进入大厅
    Game:SetGameState(GameState.GameState_Lobby)
end

return SCLoginFinishPacket

