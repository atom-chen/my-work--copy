----
-- 文件名称：SCGRUserState.lua
-- 功能描述：游戏房间内 用户状态
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-8-10
--  修改：

local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRUserState = class("SCGRUserState", PacketBase)
--构造
function SCGRUserState:ctor()
    PacketBase.ctor(self)
end

--初始化
function SCGRUserState:Init()
    PacketBase.Init(self)

end

--销毁
function SCGRUserState:Destroy()
    PacketBase.Destroy(self)

end

--解析字节流
function SCGRUserState:Read(byteStream)
	local dwUserID = byteStream:readULong()
	local wTableID = byteStream:readUShort()
	local wChairID = byteStream:readUShort()
	local cbNewStatus = byteStream:readByte()
	local userData, oldChair = ServerDataManager:GetUserDataByUserID(dwUserID)
	--print("SCGRUserState ", dwUserID, wTableID, wChairID, cbNewStatus)
	if userData == nil then
		return
	end
	local oldTableID = userData._wTableID 
	--老的桌子号
	local INVALID_TABLEID = 0xffff
	--坐下
	if userData._wTableID == INVALID_TABLEID and  wTableID ~= INVALID_TABLEID then
		local oldTableDataList = ServerDataManager._RoomUserList[INVALID_TABLEID]
		--print("oldChair ", oldChair)
		table.remove(oldTableDataList, oldChair)
		--获取新桌子数据
		local tableDataList = ServerDataManager._RoomUserList[wTableID]
		if ServerDataManager._RoomUserList[wTableID] == nil then
			ServerDataManager._RoomUserList[wTableID] = {}
			tableDataList = ServerDataManager._RoomUserList[wTableID]
		end
		tableDataList[wChairID] = userData
		
	--起立
	elseif wTableID == INVALID_TABLEID and userData._wTableID ~= INVALID_TABLEID then
		local oldTableDataList = ServerDataManager._RoomUserList[userData._wTableID]
		oldTableDataList[userData._wChair] = nil
		local tableDataList = ServerDataManager._RoomUserList[INVALID_TABLEID]
		if tableDataList == nil then
			ServerDataManager._RoomUserList[INVALID_TABLEID] = {}
			tableDataList = ServerDataManager._RoomUserList[INVALID_TABLEID]
		end
		table.insert(tableDataList, userData)
	end

	userData._wTableID = wTableID
	userData._wChair = wChairID
	userData._cbUserStatus = cbNewStatus
	EventSystem:DispatchEvent(GameEvent.GE_GSRoom_UserChange)
	--dump(ServerDataManager._RoomUserList, "ServerDataManager._RoomUserList", 10)
	--如果是自己
	local selfUserID = ServerDataManager._SelfUserInfo._dwUserID
	if dwUserID == selfUserID then
		--print("me _cbUserStatus", userData._cbUserStatus, userData._wTableID, userData._wChair )
		if userData._cbUserStatus == 0x05 then
			ServerDataManager._CurrentTableID = wTableID
			ServerDataManager._MeChairID = wChairID
			--TODO:根据当前选择游戏的不同，进入不同的游戏逻辑，（如捕鱼类，麻将等）
			Game:SetGameState(GameState.GameState_Game)
		end
	end
	local meTableID = ServerDataManager._CurrentTableID
	--print("user state change ",meTableID,  wTableID, wChair, cbNewStatus, oldTableID, oldChairID)
	if meTableID ~= nil and (meTableID == wTableID or meTableID == oldTableID) then
		EventSystem:DispatchEvent(GameEvent.GE_GSRoom_TableChange, { tableID = wTableID, chairID = wChairID, oldTableID = oldTableID, oldChairID = oldChair})
	end


end

--包处理
function SCGRUserState:Execute()
    
end

return SCGRUserState

