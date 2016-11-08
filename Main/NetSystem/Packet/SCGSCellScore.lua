----
-- 文件名称：SCGSCellScore.lua
-- 功能描述：游戏房间内 用户状态
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSCellScore = class("SCGSCellScore", PacketBase)
--构造
function SCGSCellScore:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGSCellScore:Init()
    PacketBase.Init(self)

end

--销毁
function SCGSCellScore:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCGSCellScore:Read(byteStream)



end

--包处理
function SCGSCellScore:Execute()
    
end

return SCGSCellScore

