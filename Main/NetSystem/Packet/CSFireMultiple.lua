----
-- 文件名称：CSFireMultiple.lua
-- 功能描述：加减炮
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-27

--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSFireMultiple = class("CSFireMultiple", PacketBase)

function CSFireMultiple:ctor()
    PacketBase.ctor(self)

    self._bAdd = 0

end

--初始化
function CSFireMultiple:Init()
    PacketBase.Init(self)

end

--Destroy
function CSFireMultiple:Destroy()

end

--写字节流
function CSFireMultiple:Write()
	local byteAdd = 0
	if self._bAdd == true then
		byteAdd = 1
	end
	self._OutputStream:writeByte(byteAdd)
end

return CSFireMultiple