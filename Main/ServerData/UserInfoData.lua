----
-- 文件名称：UserInfoData
-- 功能描述：服务器下发数据缓存
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-11
--  修改：

local UserInfoData = class("UserInfoData")

function UserInfoData:ctor()
    --头像标识
    self._wFaceID = 0
    --用户性别
    self._cbGender = 0
    --用户ID
    self._dwUserID = 0
    --游戏ID
    self._dwGameID = 0
    --自定索引
    self._dwCustomID = 0
    --经验数值
    self._dwExperience = 0
    --用户魅力值
    self._dwLoveLiness = 0
    --登录帐号
    self._szAccounts32 = ""
    --用户昵称
    self._szNickName32 = ""
    --用户金币
    self._lUserScore = 0
    --用户银行
    self._lUserInsure = 0
    --抽奖次数
    self._CJCount = 0
end

return UserInfoData