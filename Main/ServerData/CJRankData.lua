----
-- 文件名称：CJRankData.lua
-- 功能描述：抽奖排行榜数据
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-9-12
--  修改：  

local CJRankData = class("CJRankData")

function CJRankData:ctor()
	--排名
	self._RankIndex = 0
	--昵称
	self._NickName = ""
	--金币数
	self._Gold = 0
end

return CJRankData