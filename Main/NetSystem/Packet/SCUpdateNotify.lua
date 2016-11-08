----
-- 文件名称：SCUpdateNotify.lua
-- 功能描述：//升级提示
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCUpdateNotify = class("SCUpdateNotify", PacketBase)
--构造
function SCUpdateNotify:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCUpdateNotify:Init()
    PacketBase.Init(self)

end

--销毁
function SCUpdateNotify:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCUpdateNotify:Read(byteStream)
	

end

--包处理
function SCUpdateNotify:Execute()
    printInfo("SCUpdateNotify----------------------------")
end

return SCUpdateNotify

