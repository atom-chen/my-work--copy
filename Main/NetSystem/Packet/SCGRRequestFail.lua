----
-- 文件名称：SCGRRequestFail.lua
-- 功能描述：请求失败
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-16
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRRequestFail = class("SCGRRequestFail", PacketBase)
--构造
function SCGRRequestFail:ctor()
    PacketBase.ctor(self)
    --错误信息
    self._ErrStr = ""
end

--初始化
function SCGRRequestFail:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRRequestFail:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCGRRequestFail:Read(byteStream)
	local errCode = byteStream:readLong()
	self._ErrStr = byteStream:readConvertString(-1)

end

--包处理
function SCGRRequestFail:Execute()
    print("room server info")
    UISystem:ShowMessageBoxOne(self._ErrStr)
end

return SCGRRequestFail

