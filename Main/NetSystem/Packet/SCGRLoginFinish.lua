----
-- 文件名称：SCGRLoginFinish.lua
-- 功能描述：GameServer 登录成功包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRLoginFinish = class("SCGRLoginFinish", PacketBase)
--构造
function SCGRLoginFinish:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCGRLoginFinish:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGRLoginFinish:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRLoginFinish:Read(byteStream)


end

--包处理
function SCGRLoginFinish:Execute()
	
end

return SCGRLoginFinish

