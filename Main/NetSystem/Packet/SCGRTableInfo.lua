----
-- 文件名称：SCGRTableInfo.lua
-- 功能描述：登录完成包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRTableInfo = class("SCGRTableInfo", PacketBase)
--构造
function SCGRTableInfo:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGRTableInfo:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRTableInfo:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRTableInfo:Read(byteStream)
	
end

--包处理
function SCGRTableInfo:Execute()
    print("room server info")
end

return SCGRTableInfo

