----
-- 文件名称：SCCangKuTakeFail.lua
-- 功能描述：仓库操作成功
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-9-8
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCCangKuTakeFail = class("SCCangKuTakeFail", PacketBase)
--构造
function SCCangKuTakeFail:ctor()
    PacketBase.ctor(self)
    self._ResultCode = 0
    self._SzDes = ""
end

--初始化
function SCCangKuTakeFail:Init()
    PacketBase.Init(self)

end

--销毁
function SCCangKuTakeFail:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCCangKuTakeFail:Read(byteStream)
    self._ResultCode = byteStream:readLong()
	self._SzDes = byteStream:readConvertString(-1)
end

--包处理
function SCCangKuTakeFail:Execute()
	UISystem:ShowMessageBoxOne(self._SzDes)
end

return SCCangKuTakeFail

