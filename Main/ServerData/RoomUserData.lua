----
-- 文件名称：RoomUserData.lua
-- 功能描述：房间玩家信息
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改：  

local RoomUserData = class("RoomUserData")

function RoomUserData:ctor()
	self._dwUserID = 0
	self._dwGroupID = 0
	self._szNickName = ""
	self._szGroupName = ""
	self._szUnderWrite = ""
	self._wFaceID = 0
	self._dwCustomID = 0
	self._cbGender = 0
	self._cbMemberOrder = 0
	self._cbMasterOrder = 0
	self._wTableID = 0
	self._wChair = 0
	self._cbUserStatus = 0

	self._lScore = 0
	self._lGrade = 0
	self._lInsure = 0

	self._dwWinCount = 0
	self._dwLostCount = 0
	self._dwDrawCount = 0
	self._dwFleeCount = 0
	self._dwUserMedal = 0
	self._dwExperience = 0
	self._lLoveLiness = 0

	self._cbEnlistStatus = 0

	self._lExpand = 0

	--客户端的
	self._IsSuperCannon = false
	

end

return RoomUserData