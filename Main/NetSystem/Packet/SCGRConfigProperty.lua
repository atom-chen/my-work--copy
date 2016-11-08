----
-- 文件名称：SCGRConfigProperty.lua
-- 功能描述：道具配置
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRConfigProperty = class("SCGRConfigProperty", PacketBase)
--构造
function SCGRConfigProperty:ctor()
    PacketBase.ctor(self)
	--房间属性
	self._wTableCount = 0					--桌子数目
	self._wChairCount = 0					--椅子数目

	--房间配置
	self._wServerType = 0					--房间类型
	self._dwServerRule = 0					--房间规则
end

--初始化
function SCGRConfigProperty:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRConfigProperty:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCGRConfigProperty:Read(byteStream)
	
end

--包处理
function SCGRConfigProperty:Execute()
    print("room server info")
end

return SCGRConfigProperty

