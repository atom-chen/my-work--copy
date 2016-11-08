----
-- 文件名称：GameKind
-- 功能描述：服务器列表   游戏种类
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-12
--  修改：

local GameKind = class("GameKind")

function GameKind:ctor()
    self._wTypeID  = 0                          --类型索引
    self._wJoinID  = 0                         --挂接索引
    self._wSortID   = 0                          --排序索引
    self._wKindID    = 0                        --类型索引
    self._wGameID     = 0                       --模块索引
    self._dwOnLineCount   = 0                  --在线人数
    self._dwFullCount    = 0                     --满员人数
    self._szKindName32   = 0                      --游戏名字
    self._szProcessName32  = 0                  --进程名字
end

return GameKind