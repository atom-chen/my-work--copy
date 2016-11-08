----
-- 文件名称：GameServer
-- 功能描述：服务器列表   游戏种类
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-5
--  修改：

local GameServer = class("GameServer")

function GameServer:ctor()
	self._wKindID = 0						--名称索引
	self._wNodeID = 0						--节点索引
	self._wSortID = 0						--排序索引
	self._wServerID = 0						--房间索引
	self._wServerPort = 0					--房间端口
	self._dwOnLineCount = 0					--在线人数
	self._dwFullCount = 0					--满员人数
	self._szServerAddr = ""					--房间名称[32]
	self._szServerName = ""					--房间名称[LEN_SERVER]32
end

return GameServer