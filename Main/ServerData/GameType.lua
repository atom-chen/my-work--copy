----
-- 文件名称：GameKind
-- 功能描述：服务器列表   游戏种类
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-12
--  修改：


local GameType = class("GameType")

function GameType:ctor()
    self._wJoinID = 0                            --挂接索引
    self._wSortID = 0                            --排序索引
    self._wTypeID  = 0                           --类型索引
    self._szTypeName32 = 0                       --种类名字
end

return GameType