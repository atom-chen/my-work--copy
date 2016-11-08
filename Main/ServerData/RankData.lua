----
-- 文件名称：RankData
-- 功能描述：排行榜数据
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-4
--  修改：  暂时不用

local RankData = class("RankData")

function RankData:ctor()
	--排名
	self._RankIndex = 0
	--头像ID
	self._CustomID = 0
	--魅力值
	self._LoveLiness = 0
	--昵称
	self._NickName = ""
	--个性签名
	self._Des = ""
	--UserID
	self._UserID = 0
end

return RankData