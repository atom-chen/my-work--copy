----
-- 文件名称：CSGFUserReady.lua
-- 功能描述：框架消息 用户准备
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-11

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGFUserReady = class("CSGFUserReady", PacketBase)

function CSGFUserReady:ctor()
    PacketBase.ctor(self)

end

--初始化
function CSGFUserReady:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGFUserReady:Destroy()

end

--写字节流
function CSGFUserReady:Write()

end

return CSGFUserReady