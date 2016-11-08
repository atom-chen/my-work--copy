----
-- 文件名称：GameSceneData.lua
-- 功能描述：物品数据
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-11
--  修改：

local GameSceneData = class("GameSceneData")

function GameSceneData:ctor()
	self._cbSceneIndex = 0
	self._cbMaxBullet = 0
	self._lCellScore = 0
	--索引从1开始的
	self._lUserAllScore = {}
	--索引从1开始的
	self._lUserCellScore = {}

	self._wSpriteID = {}			--鱼的ID
	self._wFishMultiple = {}		--鱼的倍率
	self._cbProperty = {}			--打中的鱼的属性
	self._lMultipleScore = 0		--最大积分/最小积分
end

return GameSceneData