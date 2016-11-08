----
-- 文件名称：UIGameRoomList.lua
-- 功能描述：游戏服务器房间
-- 文件说明：游戏服务器房间
-- 作    者：王雷雷
-- 创建时间：2016-8-8
--  修改:


local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local ITEM_CSB_NAME = "CSD/UI/UIRoomItem.csb"
local UIGameRoomList = class("UIGameRoomList", UIBase)

--构造(只做成员初始化)
function UIGameRoomList:ctor()
	UIBase.ctor(self)

	--服务器 房间Tableview
	self._GridView = nil
	--名字
    self._TextGameName = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIGameRoomList:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
   self._ItemPanel = self:GetUIByName("Panel_BagPanel")
   self._BtnClose = self:GetUIByName("Button_Close")
    self._TextGameName = self:GetUIByName("Text_GameName")
   local contentSize = self._ItemPanel:getContentSize()
   --代码中创建Tableview
   self._GridView =  CreateTableView(0, 0, contentSize.width, contentSize.height, cc.SCROLLVIEW_DIRECTION_HORIZONTAL, self)
   if self._ItemPanel ~= nil then
        self._ItemPanel:addChild(self._GridView)
   end
    self._BtnClose:addTouchEventListener(self.OnRoomListCloseTouch)

end

--卸载
function UIGameRoomList:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UIGameRoomList:Open()
	UIBase.Open(self)
    self._GridView:reloadData()
    local curGameTableID = ServerDataManager._CurSelGameID
    local cfgData = TableDataManager._GameConfigData[curGameTableID]
    if cfgData ~= nil then
        self._TextGameName:setString(cfgData.name)
    end

end

--关闭
function UIGameRoomList:Close()
	UIBase.Close(self)

end

--获取Cell index:从1开始,只创建一次
function UIGameRoomList:GetItemCellByIndex(index)
    if self._ItemCellList == nil then
        self._ItemCellList = {}
    end
    local curCell = self._ItemCellList[index] 
    if curCell == nil then
       curCell =  cc.CSLoader:createNode(ITEM_CSB_NAME) 
       curCell:retain()
       self._ItemCellList[index] = curCell
    end
    return self._ItemCellList[index]
end

--idx 从1开始 
function UIGameRoomList:InitCellContent(idx, curCell)
    if idx == nil or curCell == nil then
        return
    end
    local gameID = ServerDataManager._CurSelGameID
    local gameServerList = ServerDataManager._GameServerList
    local currentList = gameServerList[gameID]
    if currentList == nil then
    	return
    end

    local itemImage = seekNodeByName(curCell, "Image_Bg")
    local nameTxt = seekNodeByName(curCell, "Text_RoomName")
    local goldTxt = seekNodeByName(curCell, "Text_Gold")
    local stateImage = seekNodeByName(curCell, "Image_State")

    local curData = currentList[idx]
    if curData == nil then
    	return
    end
    itemImage:setSwallowTouches(false)
    print("InitCellContent itemImage", idx)
    itemImage:addTouchEventListener(self.OnGameRoomTouch)
    itemImage:setTag(idx)
    nameTxt:setString(curData._szServerName)
end

-----------------------------------------Tableview回调处理 begin-----------------------------------------

function UIGameRoomList.ScrollViewDidScroll(view)
    --print("ScrollViewDidScroll")
end

function UIGameRoomList.NumberOfCellsInTableView(view)
    local len = 0
    local gameID = ServerDataManager._CurSelGameID
    local gameServerList = ServerDataManager._GameServerList
    local currentList = gameServerList[gameID]
    if currentList ~= nil then
        len  = #currentList
    end
    --print("NumberOfCellsInTableView ", len)
    return len
end

--某房间点击
function UIGameRoomList.TableCellTouched(view, cell)
    print("UIGameRoomList.TableCellTouched")
    local gameID = ServerDataManager._CurSelGameID
    local gameServerList = ServerDataManager._GameServerList
    local currentList = gameServerList[gameID]
    if currentList == nil then
        return
    end
    local index = cell:getTag()
    local curData = currentList[index]
    if curData == nil then
        return
    end
    --临时 替换掉服务器下发的IP地址
    curData._szServerAddr = LOGIN_SERVER_IP
    print("ConnectGameServer", curData._szServerAddr, curData._wServerPort)
    --条件判定
    -- 服务器地址判定
    if string.len(curData._szServerAddr) == 0 then
         UISystem:ShowMessageBoxOne(ChineseTable["CT_GameServer_InvalidIP"]) 
        return
    end
    --是否已满
    local rate = curData._dwOnLineCount / curData._dwFullCount
    if rate > 0.9 then
         UISystem:ShowMessageBoxOne(ChineseTable["CT_GameRoom_Full"]) 
        return
    end
    --连接服务器
    print("OnGameRoomTouch ConnectGameServer ......")
    NetSystem:ConnectGameServer(curData._szServerAddr, curData._wServerPort)
end

function UIGameRoomList.CellSizeForTable(view, idx)
    return 330, 320
end

function UIGameRoomList.TableCellAtIndex(view, idx)
    --print("TableCellAtIndex ", idx)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_RoomList)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local contentCell = uiInstance:GetItemCellByIndex(idx + 1)
    contentCell:removeFromParent()
    cell:addChild(contentCell, 0, idx + 1)
    cell:setTag(idx + 1)
    uiInstance:InitCellContent(idx + 1, contentCell)
    return cell
end


-----------------------------------------Tableview回调处理 end -----------------------------------------


-------------------------------------------控件逻辑处理- Begin -------------------------------------------
--某房间点击
function UIGameRoomList.OnGameRoomTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
	
	end
end

--关闭
function UIGameRoomList.OnRoomListCloseTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
		UISystem:CloseUI(UIType.UIType_RoomList)
	end
end
-------------------------------------------控件逻辑处理- End -------------------------------------------


return UIGameRoomList
