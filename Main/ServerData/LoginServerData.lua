----
-- 文件名称：LoginServerData
-- 功能描述：服务器列表   游戏种类
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-12
--  修改：


local LoginServerData = class("LoginServerData")

--构造
function LoginServerData:ctor()
    -- 缓存的用户名
    self._UserAccount = ""
    self._Password = ""
    --注册的用户名与密码
    self._RegAccount = ""
    self._RegPwd = ""
    --当前的操作类型(默认为登录， 0:登录 1：注册)
    self._CurActionType = 0
end


return LoginServerData