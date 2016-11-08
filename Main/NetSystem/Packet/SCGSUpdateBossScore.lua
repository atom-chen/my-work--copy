----
-- 文件名称：SCGSUpdateBossScore.lua
-- 功能描述：更新Boss积分
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-16
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGSUpdateBossScore = class("SCGSUpdateBossScore", PacketBase)
--构造
function SCGSUpdateBossScore:ctor()
    PacketBase.ctor(self)

end

--初始化
function SCGSUpdateBossScore:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGSUpdateBossScore:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGSUpdateBossScore:Read(byteStream)
	print("SCGSUpdateBossScore:Read ")
	
end

--包处理
function SCGSUpdateBossScore:Execute()
	
end

return SCGSUpdateBossScore

