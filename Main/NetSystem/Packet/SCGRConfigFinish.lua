----
-- 文件名称：SCGRConfigFinish.lua
-- 功能描述：登录完成包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRConfigFinish = class("SCGRConfigFinish", PacketBase)
--构造
function SCGRConfigFinish:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGRConfigFinish:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRConfigFinish:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRConfigFinish:Read(byteStream)
	
end

--包处理
function SCGRConfigFinish:Execute()
    print("room config finish")
end

return SCGRConfigFinish

