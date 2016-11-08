----
-- 文件名称：SCCangKuSuccell.lua
-- 功能描述：仓库操作成功
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-9-8
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCCangKuSuccell = class("SCCangKuSuccell", PacketBase)
--构造
function SCCangKuSuccell:ctor()
    PacketBase.ctor(self)
    --
    self._dwUserID = 0
    self._llUserScore = 0
    self._llUserInsure = 0
    self._szDesStr = ""
end

--初始化
function SCCangKuSuccell:Init()
    PacketBase.Init(self)

end

--销毁
function SCCangKuSuccell:Destroy()
    PacketBase.Destroy(self)
end

--解析字节流
function SCCangKuSuccell:Read(byteStream)
    self._dwUserID = byteStream:readULong()
    self._llUserScore = byteStream:readLongLong()
    self._llUserInsure = byteStream:readLongLong()
    self._szDesStr = byteStream:readConvertString(-1)
end

--包处理
function SCCangKuSuccell:Execute()
    local meInfo = ServerDataManager._SelfUserInfo
    meInfo._lUserScore = self._llUserScore
    meInfo._lUserInsure = self._llUserInsure
    EventSystem:DispatchEvent(GameEvent.GE_UserInfoChange)
    if self._szDesStr ~= nil and self._szDesStr ~= "" then
        UISystem:ShowMessageBoxOne(self._szDesStr)
    end
end

return SCCangKuSuccell

