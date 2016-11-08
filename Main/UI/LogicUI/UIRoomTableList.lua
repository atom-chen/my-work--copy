----
-- 文件名称：UIRoomTableList.lua
-- 功能描述：房间内桌子列表
-- 文件说明：房间内桌子列表
-- 作    者：王雷雷
-- 创建时间：2016-8-9
--  修改: 
-- TODO: 优化TableView的刷新

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local ITEM_CSB_NAME = "CSD/UI/UITableItem.csb"
local UIRoomTableList = class("UIRoomTableList", UIBase)

--构造(只做成员初始化)
function UIRoomTableList:ctor()
	UIBase.ctor(self)
    self._ItemPanel = nil
	--服务器 房间Tableview
	self._GridView = nil
    --桌子列表
    self._ItemCellList = nil
	--handler
    self._TableUserHandler = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIRoomTableList:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
   self._ItemPanel = self:GetUIByName("Panel_Tableview")
   local contentSize = self._ItemPanel:getContentSize()
   --代码中创建Tableview
   self._GridView =  CreateTableView(0, 0, contentSize.width, contentSize.height, cc.SCROLLVIEW_DIRECTION_HORIZONTAL, self)
   if self._ItemPanel ~= nil then
        self._ItemPanel:addChild(self._GridView)
   end
   local leftBtn = self:GetUIByName("Button_LeftArrow")
   leftBtn:addTouchEventListener(self.OnLeftArrowTouch)
   local rightBtn = self:GetUIByName("Button_RightArrow")
   rightBtn:addTouchEventListener(self.OnRightArrowTouch)
end

--卸载
function UIRoomTableList:Unload()
	UIBase.Unload(self)

    --TODO:卸载
end

--打开(UI内容初始化)
function UIRoomTableList:Open()
	UIBase.Open(self)
    self._GridView:reloadData()
    self._TableUserHandler = EventSystem:AddEvent(GameEvent.GE_GSRoom_UserChange, self.OnTableListRefresh) 

    ServerDataManager._IndexForReturn = 2
end

--关闭
function UIRoomTableList:Close()
	UIBase.Close(self)
    if self._TableUserHandler ~= nil then
        EventSystem:RemoveEvent(self._TableUserHandler)
        self._TableUserHandler = nil
    end

end

---------------------------------------------四个通用必须实现的接口-----------------------------------------------------
--如果后面有效率问题，再优化
function UIRoomTableList:RefreshTableList()
    local offset = self._GridView:getContentOffset()
    self._GridView:reloadData()
    self._GridView:setContentOffset(offset)
end

--获取Cell index:从1开始,只创建一次
function UIRoomTableList:GetItemCellByIndex(index)
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
function UIRoomTableList:InitCellContent(idx, curCell)
    if idx == nil or curCell == nil then
        return
    end

    local roomUserList = ServerDataManager._RoomUserList
    if roomUserList == nil then
    	return
    end
    local txtIndex = seekNodeByName(curCell, "Text_Index")
    txtIndex:setString(idx)
    curCell:setTag(idx - 1)
    local curData = roomUserList[idx - 1]
    --空桌子
    if curData == nil then
        for i = 0, 5 do
            local nodeName = "Node_UserItem_" .. tostring(i)
            local itemRootNode = seekNodeByName(curCell, nodeName)
            if itemRootNode ~= nil then
                local itemImage = seekNodeByName(itemRootNode, "Image_Head")
                local parentNode = itemImage:getParent()
                parentNode:setTag(idx - 1)
                itemImage:setTag(i)
                itemImage:addTouchEventListener(self.OnRoomTableTouch)
                local nameTxt = seekNodeByName(itemRootNode, "Text_Name")
                nameTxt:setString("")
            end
        end
    --有数据的桌子
    else
        for i = 0, 5 do
            local nodeName = "Node_UserItem_" .. tostring(i)
            local itemRootNode = seekNodeByName(curCell, nodeName)
            if itemRootNode ~= nil then
                local itemImage = seekNodeByName(itemRootNode, "Image_Head")
                local nameTxt = seekNodeByName(itemRootNode, "Text_Name")
                local parentNode = itemImage:getParent()
                parentNode:setTag(idx - 1)
                itemImage:setTag(i)
                itemImage:addTouchEventListener(self.OnRoomTableTouch)
                local curUserData = curData[i]
                if curUserData == nil then
                    nameTxt:setString("")
                    --itemImage
                else
                    nameTxt:setString(curUserData._szNickName)
                    --itemImage
                end
            end
        end
    end
end

--左移
function UIRoomTableList:ViewLeftMove()
    local offset = self._GridView:getContentOffset()
     local size = self._GridView:getContainer():getContentSize()
    offset.x = offset.x + 1000
    if offset.x > 0 then
        offset.x = 0
    end
    self._GridView:setContentOffset(offset)
end

--右移
function UIRoomTableList:ViewRightMove()
    local offset = self._GridView:getContentOffset()
    local size = self._GridView:getContainer():getContentSize()
    offset.x = offset.x - 1000
    if offset.x < -(size.width - 1000) then
        offset.x = -(size.width - 1000)
    end
    self._GridView:setContentOffset(offset)
end

-----------------------------------------Tableview回调处理 begin-----------------------------------------

function UIRoomTableList.ScrollViewDidScroll(view)
   
end

function UIRoomTableList.NumberOfCellsInTableView(view)
    --print("NumberOfCellsInTableView ", len)
    return 20
end

function UIRoomTableList.TableCellTouched(view, cell)

end

function UIRoomTableList.CellSizeForTable(view, idx)
    return 500, 460
end

function UIRoomTableList.TableCellAtIndex(view, idx)
    --print("TableCellAtIndex ", idx)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_RoomTableList)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local contentCell = uiInstance:GetItemCellByIndex(idx + 1)
    contentCell:removeFromParent()
    cell:addChild(contentCell, 0, idx + 1)
    uiInstance:InitCellContent(idx + 1, contentCell)
    return cell
end


-----------------------------------------Tableview回调处理 end -----------------------------------------


-------------------------------------------控件逻辑处理- Begin -------------------------------------------

--某桌子的椅子点击
function UIRoomTableList.OnRoomTableTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local chairID = sender:getTag()
        local parentNode = sender:getParent()
        local tableID = parentNode:getTag()
        print("OnRoomTableTouch ", tableID, chairID)
        --座位是否为空座位
        local tableData = ServerDataManager._RoomUserList[tableID]
        local userData = nil
        if tableData ~= nil then
            userData = tableData[chairID]
        end
        if userData ~= nil then
            print("not empty")
            return
        end
        --发送坐下请求
        local newSitDownPacket = require("Main.NetSystem.Packet.CSGRUserSitDown").new()
        newSitDownPacket._wTableID = tableID
        newSitDownPacket._wChairID = chairID
        NetSystem:SendGamePacket(newSitDownPacket)
    end
end
-------------------------------------------控件逻辑处理- End -------------------------------------------

function UIRoomTableList.OnTableListRefresh()
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_RoomTableList)
    uiInstance:RefreshTableList()
end


--左箭头
function UIRoomTableList:OnLeftArrowTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_RoomTableList)
        uiInstance:ViewLeftMove()
    end
end
--右箭头
function UIRoomTableList:OnRightArrowTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_RoomTableList)
        uiInstance:ViewRightMove()
    end
end

return UIRoomTableList
