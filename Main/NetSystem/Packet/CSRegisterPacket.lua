----
-- 文件名称：CSRegisterPacket.lua
-- 功能描述：登录包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-4
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSRegisterPacket = class("CSRegisterPacket", PacketBase)

function CSRegisterPacket:ctor()
    PacketBase.ctor(self)
    --模块标识
    self._wModuleID = 0xFFFF
    --广场版本
    self._dwPlazaVer = 0
    --设备类型
    self._cbDeviceType = 0
    --密码 33
    self._szLogonPass = 0
    self._szInsurePass = 0
    --头像
    self._wFaceID = 0
    --用户性别
    self._cbGender = 0
    --登录帐号 32
    self._szAccounts = 0
    self._szNickName = 0
    --机器标识33
    self._szMachineID = 0
    --12
    self._szMobile = 0
    --33
    self._szQQKey = 0
    -- QQ、微信 区分
    self._cbMBKind = 0
end

--初始化
function CSRegisterPacket:Init()
    PacketBase.Init(self)

end

--Destroy
function CSRegisterPacket:Destroy()

end

--写字节流
function CSRegisterPacket:Write()
    --临时数据
    self._dwPlazaVersion = Process_Version(6,0,3)
    self._cbDeviceType = 0x10
    self._wFaceID = 1
    self._cbGender = 0
    self._szMachineID = ""
    self._szMobile = ""
    self._szQQKey = ""
    self._cbMBKind = 0xFF

    self._OutputStream:writeUShort(self._wModuleID)
    self._OutputStream:writeULong(self._dwPlazaVersion)
    self._OutputStream:writeUByte(self._cbDeviceType)
    self._OutputStream:WriteConvertStringFixlen(self._szLogonPass, 33)
    self._OutputStream:WriteConvertStringFixlen(self._szInsurePass, 33)
    self._OutputStream:writeUShort(self._wFaceID)
    self._OutputStream:writeUByte(self._cbGender)
    self._OutputStream:WriteConvertStringFixlen(self._szAccounts, 32)
    self._OutputStream:WriteConvertStringFixlen(self._szNickName, 32)
    self._OutputStream:WriteConvertStringFixlen(self._szMachineID, 33)
    self._OutputStream:WriteConvertStringFixlen(self._szMobile, 12)
    self._OutputStream:WriteConvertStringFixlen(self._szQQKey, 33)
    self._OutputStream:writeUByte(self._cbMBKind)   
end

return CSRegisterPacket