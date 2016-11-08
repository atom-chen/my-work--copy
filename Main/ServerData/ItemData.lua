----
-- 文件名称：ItemData
-- 功能描述：物品数据
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-11
--  修改：

local ItemData = class("ItemData")

function ItemData:ctor()
    --表格ID
    self._TableID = 0
    --表格数据
    self._TableData = nil
    --ServerID
    self._ServerID = 0
    --类型
    self._ItemType = 0
    self._ItemType2 = 0
    --签名
    self._Sign = 0
    --数量
    self._Count = 0
end

return ItemData