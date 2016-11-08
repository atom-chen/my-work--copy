----
-- 文件名称：SCGRConfigServer.lua
-- 功能描述：登录完成包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRConfigServer = class("SCGRConfigServer", PacketBase)
--构造
function SCGRConfigServer:ctor()
    PacketBase.ctor(self)
	--房间属性
	self._wTableCount = 0						--桌子数目
	self._wChairCount = 0						--椅子数目

	--房间配置
	self._wServerType = 0						--房间类型
	self._dwServerRule = 0						--房间规则
end

--初始化
function SCGRConfigServer:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRConfigServer:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRConfigServer:Read(byteStream)
	
end

--包处理
function SCGRConfigServer:Execute()
    print("room server info")
end

return SCGRConfigServer

