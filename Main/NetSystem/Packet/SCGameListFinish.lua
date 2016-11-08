----
-- 文件名称：SCGameListFinish.lua
-- 功能描述：服务器列表完成
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-5
--  修改：



local PacketBase = require "Main.NetSystem.PacketBase"
local SCGameListFinish = class("SCGameListFinish", PacketBase)

--构造
function SCGameListFinish:ctor()
    PacketBase.ctor(self)

end

--Init
function SCGameListFinish:Init()
    PacketBase.Init(self)

end

--Destroy
function SCGameListFinish:Init()
    
end

--解析字节流
function SCGameListFinish:Read(byteStream)

end

--处理
function SCGameListFinish:Execute()
    
end

return SCGameListFinish