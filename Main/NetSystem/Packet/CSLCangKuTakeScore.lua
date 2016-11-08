----
-- 文件名称：CSLCangKuTakeScore.lua
-- 功能描述：仓库 存款包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-9-8
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"

local CSLCangKuTakeScore = class("CSLCangKuTakeScore", PacketBase)

function CSLCangKuTakeScore:ctor()
    PacketBase.ctor(self)
    --userID
    self._dwUserID  = 0              
    --存款       
    self._llSaveScore = 0    
    --银行密码
    self._szPassword33 = ""           
    --机器码
    self._szMachineID33 = ""
end

--初始化
function CSLCangKuTakeScore:Init()
    PacketBase.Init(self)

end

--Destroy
function CSLCangKuTakeScore:Destroy()

end

--写字节流
function CSLCangKuTakeScore:Write()
    self._dwUserID = ServerDataManager._SelfUserInfo._dwUserID
    self._OutputStream:writeULong(self._dwUserID)
    self._OutputStream:writeLongLong(self._llSaveScore)
    self._OutputStream:WriteConvertStringFixlen(self._szPassword33, 33)
    self._OutputStream:WriteConvertStringFixlen(self._szMachineID33, 33)
end

return CSLCangKuTakeScore