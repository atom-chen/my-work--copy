----
-- 文件名称：ConfigData
-- 功能描述：客户端配置
-- 文件说明：
-- 作    者：金兴泉
-- 创建时间：2016-8-25
--  修改：

local ConfigData = class("ConfigData")

function ConfigData:ctor()
    self._UserAccount = nil
    self._UserPassword = nil
    self._EnableMusic = 0
    self._EnableEffect = 0
    self._EnableSpecial = 0
    self._EnableShake = 0
    self._EnableNotice = 0
end

return ConfigData