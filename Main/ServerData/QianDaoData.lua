----
-- 文件名称：QianDaoData
-- 功能描述：签到数据
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-9-9
--  修改： 

local QianDaoData = class("QianDaoData")

function QianDaoData:ctor()
	--签到天数
	self._QianDaoDays = -1
	--今天是否已签到
	self._IsQianToday = false
end

return QianDaoData