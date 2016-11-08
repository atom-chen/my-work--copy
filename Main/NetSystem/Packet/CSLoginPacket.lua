----
-- 文件名称：CSLoginPacket.lua
-- 功能描述：登录包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-4
--  修改：TODO: MachineID

local PacketBase = require "Main.NetSystem.PacketBase"

local CSLoginPacket = class("CSLoginPacket", PacketBase)

function CSLoginPacket:ctor()
    PacketBase.ctor(self)
    self._wModuleID = 0xFFFF
    self._dwPlazaVersion = GetProcessVersion()
    self._cbDeviceType = GetPlatformDeviceType()
    self._szPassword33 = ""
    self._szAccounts = ""
    self._szMachineID33 = ""
    self._szMobilePhone12 = ""
end

--初始化
function CSLoginPacket:Init()
    PacketBase.Init(self)

end

--Destroy
function CSLoginPacket:Destroy()

end

--写字节流
function CSLoginPacket:Write()
	--temp 测试
	--[[
	local wMainCmdID = 100
	local wSubCmdID = 2
    local wModuleID = 0xFFFF
    local dwPlazaVersion = Process_Version(6, 0, 3)
    local cbDeviceType = 0x10
    local szPassword33 = ""
    local encryptInstance = LuaLib.CEncrypt:new()
    local szPassword33 = encryptInstance:MD5EncryptString32("222222")
    local szAccounts = "qwe123456"
    local szMachineID33 = ""
    local szMobilePhone12 = ""
    print("CSLoginPacket", wModuleID, dwPlazaVersion, cbDeviceType, szPassword33, szAccounts, szMachineID33, szMobilePhone12)
    ]]--
    self._OutputStream:writeUShort(self._wModuleID)
    self._OutputStream:writeULong(self._dwPlazaVersion)
    self._OutputStream:writeUByte(self._cbDeviceType)
    self._OutputStream:WriteConvertStringFixlen(self._szPassword33, 33)
    self._OutputStream:WriteConvertStringFixlen(self._szAccounts, 32)
    self._OutputStream:WriteConvertStringFixlen(self._szMachineID33, 33)
    self._OutputStream:WriteConvertStringFixlen(self._szMobilePhone12, 12)
    
end

return CSLoginPacket