----
-- 文件名称：CSLogonMobile.lua
-- 功能描述：登录包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-4
--  修改：分离出公共函数   2016-8-9

local PacketBase = require "Main.NetSystem.PacketBase"

local CSLogonMobile = class("CSLogonMobile", PacketBase)

function CSLogonMobile:ctor()
    PacketBase.ctor(self)
    
    self._wGameID = 0                    --游戏标识
    self._dwProcessVersion = 0            --进程版本
    self._cbDeviceType = 0                --设备类型
    self._wBehaviorFlags = 0              --行为标识
    self._wPageTableCount = 0             --分页桌数
    self._dwUserID = 0                    --用户 I D
    self._szPassword33 = ""               --登录密码
    self._szMachineID33 = ""             --机器标识
end

--初始化
function CSLogonMobile:Init()
    PacketBase.Init(self)
    
end

--Destroy
function CSLogonMobile:Destroy()

end

--写字节流
function CSLogonMobile:Write()
    --temp 测试数值
    self._cbDeviceType = GetPlatformDeviceType()
    self._dwUserID = ServerDataManager._SelfUserInfo._dwUserID
    self._dwProcessVersion = GetProcessVersion()
    local loginData = ServerDataManager._LoginServerData
    local encryptInstance = LuaLib.CEncrypt:new()
    self._szPassword33 = encryptInstance:MD5EncryptString32(loginData._Password)
    self._OutputStream:writeUShort(self._wGameID)           --无值
    self._OutputStream:writeULong(self._dwProcessVersion)
    self._OutputStream:writeUByte(self._cbDeviceType)
    self._OutputStream:writeUShort(self._wBehaviorFlags)    --无值
    self._OutputStream:writeUShort(self._wPageTableCount)   --无值
    self._OutputStream:writeULong(self._dwUserID)
    self._OutputStream:WriteConvertStringFixlen(self._szPassword33, 33)
    self._OutputStream:WriteConvertStringFixlen(self._szMachineID33, 33)
    --dump(self)
end

return CSLogonMobile