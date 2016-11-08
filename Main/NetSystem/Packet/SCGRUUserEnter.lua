----
-- 文件名称：SCGRUUserEnter.lua
-- 功能描述：登录完成包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRUUserEnter = class("SCGRUUserEnter", PacketBase)
--构造
function SCGRUUserEnter:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGRUUserEnter:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRUUserEnter:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCGRUUserEnter:Read(byteStream)
	local gameID = byteStream:readULong()
	local userID = byteStream:readULong()
	local dwGroupID = byteStream:readULong()

	local wFaceID = byteStream:readUShort()
	local dwCustomID = byteStream:readULong()
	local cbGender = byteStream:readByte()
	local cbMemberOrder = byteStream:readByte()
	local cbMasterOrder = byteStream:readByte()
	local wTableID = byteStream:readUShort()
	local wChair = byteStream:readUShort()

	local cbUserStatus = byteStream:readByte()

	local lScore = byteStream:readLongLong()
	local lGrade = byteStream:readLongLong()
	local lInsure = byteStream:readLongLong()

	local dwWinCount = byteStream:readULong()
	local dwLostCount = byteStream:readULong()
	local dwDrawCount = byteStream:readULong()
	local dwFleeCount = byteStream:readULong()
	local dwUserMedal = byteStream:readULong()
	local dwExperience = byteStream:readULong()
	local lLoveLiness = byteStream:readLong()

	local szNickName = ""
	local szGroupName = ""
	local szUnderWrite = ""

    --扩展信息
    if byteStream:getAvailable() > 0 then
    	local wDataSize = byteStream:readUShort()
    	local wDataDescribe = byteStream:readUShort()
    	--用户昵称
    	if wDataDescribe == 10 then
    		szNickName = byteStream:readConvertString(-1)
    	--用户社团
    	elseif wDataDescribe == 11 then
    		szGroupName = byteStream:readConvertString(-1)
    	--个性签名
    	elseif wDataDescribe == 12 then
			szUnderWrite = byteStream:readConvertString(-1)
    	end
    end

    --数据保存

   	if ServerDataManager._RoomUserList == nil then
		ServerDataManager._RoomUserList = {}
	end
	--print("SCGRUUserEnter:Read-----------------")
    --dump(ServerDataManager)
    
	--游戏
	--[[
	if ServerDataManager._RoomUserList[gameID] == nil then
		ServerDataManager._RoomUserList[gameID] = {}
	end
	]]--
	--local curGameUserList = ServerDataManager._RoomUserList[gameID]
	local INVALID_TABLEID = 0xffff
	local tableUserList = nil
	local curInfo = nil
	if wTableID == INVALID_TABLEID then
		local curGameUserList = ServerDataManager._RoomUserList
		if curGameUserList[wTableID] == nil then
			curGameUserList[wTableID] = {}
		end
		curInfo= ServerDataManager:CreateUserData()
		table.insert(curGameUserList[wTableID], curInfo)
	else
		local curGameUserList = ServerDataManager._RoomUserList
		if curGameUserList[wTableID] == nil then
			curGameUserList[wTableID] = {}
		end
		tableUserList = curGameUserList[wTableID] 
		if tableUserList[wChair] == nil then
			tableUserList[wChair] = ServerDataManager:CreateUserData()
		end
		curInfo = tableUserList[wChair]
	end

	curInfo._dwUserID = userID
	curInfo._dwGroupID = dwGroupID
	curInfo._szNickName = szNickName
	curInfo._szGroupName = szGroupName
	curInfo._szUnderWrite = szUnderWrite
	curInfo._wFaceID = wFaceID
	curInfo._dwCustomID = dwCustomID
	curInfo._cbGender = cbGender
	curInfo._cbMemberOrder = cbMemberOrder
	curInfo._cbMasterOrder = cbMasterOrder
	curInfo._wTableID = wTableID 
	curInfo._wChair = wChair
	curInfo._cbUserStatus = cbUserStatus

	curInfo._lScore = lScore
	curInfo._lGrade = lGrade
	curInfo._lInsure = lInsure

	curInfo._dwWinCount = dwWinCount
	curInfo._dwLostCount = dwLostCount
	curInfo._dwDrawCount = dwDrawCount
	curInfo._dwFleeCount = dwFleeCount
	curInfo._dwUserMedal = dwUserMedal
	curInfo._dwExperience = dwExperience
	curInfo._lLoveLiness = lLoveLiness

	curInfo._cbEnlistStatus = cbEnlistStatus

	curInfo._lExpand = lExpand
	--dump(ServerDataManager._RoomUserList, "_RoomUserList", 10)
	--如果是自己
	local selfUserID = ServerDataManager._SelfUserInfo._dwUserID
	if selfUserID == curInfo._dwUserID then
		EventSystem:DispatchEvent(GameEvent.GE_UserInfoChange)
	end

	EventSystem:DispatchEvent(GameEvent.GE_GSRoom_UserChange)
	local meTableID = ServerDataManager._CurrentTableID
	--print("user enter or leave ",meTableID,  wTableID, wChair, szNickName)
	if meTableID ~= nil and meTableID == wTableID then
		EventSystem:DispatchEvent(GameEvent.GE_GSRoom_TableChange, { tableID = wTableID, chair = wChair})
	end
end

--包处理
function SCGRUUserEnter:Execute()
    --print("room server info")
end

return SCGRUUserEnter

