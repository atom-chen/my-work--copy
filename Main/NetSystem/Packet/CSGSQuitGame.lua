----
-- 文件名称：CSGSQuitGame.lua
-- 功能描述：退出游戏
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-31
--  修改：无用了   2016-8-31

local PacketBase = require "Main.NetSystem.PacketBase"

local CSGSQuitGame = class("CSGSQuitGame", PacketBase)

function CSGSQuitGame:ctor()
    PacketBase.ctor(self)
end

--初始化
function CSGSQuitGame:Init()
    PacketBase.Init(self)

end

--Destroy
function CSGSQuitGame:Destroy()

end

--写字节流
function CSGSQuitGame:Write()

end

return CSGSQuitGame