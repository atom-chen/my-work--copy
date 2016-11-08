----
-- 文件名称：SCGRConfigUserRight.lua
-- 功能描述：登录完成包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRConfigUserRight = class("SCGRConfigUserRight", PacketBase)
--构造
function SCGRConfigUserRight:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGRConfigUserRight:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRConfigUserRight:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRConfigUserRight:Read(byteStream)

end

--包处理
function SCGRConfigUserRight:Execute()
    print("room column info")
end

return SCGRConfigUserRight

