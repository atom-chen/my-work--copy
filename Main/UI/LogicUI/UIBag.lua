----
-- 文件名称：UIBag.lua
-- 功能描述：背包界面
-- 文件说明：背包界面
-- 作    者：王雷雷
-- 创建时间：2016-8-3
--  修改:TODO:物品出售等的操作

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")
--减少重复调用全局
local mathCeil = math.ceil
local stringFormat = string.format

local UIBag = class("UIBag", UIBase)

--物品Cell对应的资源
local ITEM_CSB_NAME = "CSD/UI/UIBagItem.csb"
--一行显示4个
local ITEM_COUNT_ROW = 4

--构造(只做成员初始化)
function UIBag:ctor()
	UIBase.ctor(self)
    --物品的父面板
    self._ItemPanel = nil
    self._GridView = nil
    self._BtnClose = nil
    --背包物品
    self._ImageCurItem = nil
    self._TxtCurDes = nil
    self._BtnSell = nil
    self._BtnUse = nil
    --物品列表
    self._ItemCellList = nil
    self._ItemDataEventHandler = nil--
    --弹出面板
    self._PopUseAllPanel = nil
    self._PopSellAllPanel = nil
    self._OldSellPosX = 0
    self._OldSellPosY = 0
    self._OldUsePosX = 0
    self._OldUsePosY = 0
    --------------------------------
    self._CurSelectItemIndex = 0
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIBag:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
   self._ItemPanel = self:GetUIByName("Panel_ItemPanel")
   self._BtnClose = self:GetUIByName("Button_Close")
   self._ImageCurItem = self:GetUIByName("Image_CurItem")
   self._TxtCurDes = self:GetUIByName("Text_CurDes")
   self._BtnSell = self:GetUIByName("Button_Sell")
   self._BtnUse = self:GetUIByName("Button_Use")
   self._PopUseAllPanel = self:GetUIByName("Panel_PopUseAll")
   self._PopSellAllPanel = self:GetUIByName("Panel_PopSellAll")
    local useBtn0 = seekNodeByName(self._PopUseAllPanel, "Button_UseSingle")
    local useBtn1 = seekNodeByName(self._PopUseAllPanel, "Button_UseAll")
    local sellBtn0 = seekNodeByName(self._PopSellAllPanel, "Button_SellSingle")
    local sellBtn1 = seekNodeByName(self._PopSellAllPanel, "Button_SellAll")
    useBtn0:setTag(0)
    useBtn1:setTag(1)
    sellBtn0:setTag(0)
    sellBtn1:setTag(1)
    useBtn0:addTouchEventListener(self.OnBagUseAllBtnClick)
    useBtn1:addTouchEventListener(self.OnBagUseAllBtnClick)
    sellBtn0:addTouchEventListener(self.OnBagSellAllBtnClick)
    sellBtn1:addTouchEventListener(self.OnBagSellAllBtnClick)

   local contentSize = self._ItemPanel:getContentSize()
   --代码中创建Tableview
   self._GridView =  CreateTableView(0, 0, contentSize.width, contentSize.height, cc.TABLEVIEW_FILL_BOTTOMUP, self)
   if self._ItemPanel ~= nil then
        self._ItemPanel:addChild(self._GridView)
   end
    self._BtnClose:addTouchEventListener(self.OnBagCloseTouch)
    self._BtnSell:addTouchEventListener(self.OnBagSellItemTouch)
    self._BtnUse:addTouchEventListener(self.OnBagUseItemTouch)
    self._PopUseAllPanel:addTouchEventListener(self.OnBagUseallPanelClick)
    self._PopSellAllPanel:addTouchEventListener(self.OnBagSellallPanelClick)


    self._OldSellPosX, self._OldSellPosY = self._BtnSell:getPosition()
    self._OldUsePosX, self._OldUsePosY = self._BtnUse:getPosition()

    self._PopUseAllPanel:setVisible(false)
    self._PopSellAllPanel:setVisible(false)
end

--卸载
function UIBag:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UIBag:Open()
	UIBase.Open(self)
    self._GridView:reloadData()
    self._PopUseAllPanel:setVisible(false)
    self._PopSellAllPanel:setVisible(false)
    self:RefreshLeftItemInfo(-1)
    self._CurSelectItemIndex = 0
    --自定义事件
    self._ItemDataEventHandler = EventSystem:AddEvent(GameEvent.GE_ITEM_CHANGE, self._OnBagItemChange)
end

--关闭
function UIBag:Close()
	UIBase.Close(self)
    if self._ItemDataEventHandler ~= nil then
        EventSystem:RemoveEvent(self._ItemDataEventHandler)
        self._ItemDataEventHandler = nil
    end

end

--获取Cell index:从1开始,只创建一次
function UIBag:GetItemCellByIndex(index)
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

--idx 从1开始, 物品显示初始化
function UIBag:InitCellContent(idx, contentCell)
    if idx == nil or contentCell == nil then
        return
    end
    local itemDataList = ServerDataManager._BagItemDataList
    if itemDataList == nil then
        return
    end
    local startIndex = (idx - 1) * ITEM_COUNT_ROW 
    local curCell = self._ItemCellList[idx]
    for i = 1, 4 do
       local itemPanelName = stringFormat("Panel_Item_%d", i)
       local itemPanel = seekNodeByName(curCell, itemPanelName)
       if itemPanel ~= nil then
            local itemImage = itemPanel:getChildByName("Image_Item")
            local nameTxt = itemPanel:getChildByName("Text_Name")
            local countTxt = itemPanel:getChildByName("AtlasLabel_Count")
           local curData = itemDataList[startIndex + i]
           if curData == nil then
                itemPanel:setVisible(false)
           else
                itemImage:setSwallowTouches(false)
                itemPanel:setSwallowTouches(false)
                itemImage:addTouchEventListener(self.OnBagItemTouch)
                itemPanel:addTouchEventListener(self.OnBagItemTouch)
                itemImage:setTag(startIndex + i)
                itemPanel:setTag(startIndex + i)
                local tableData = curData._TableData
                if tableData ~= nil then
                    itemImage:loadTexture(tableData.image)
                    nameTxt:setString(tableData.name)
                else
                    print("tableData == nil", curData._ItemType, curData._ItemType2)
                end
                countTxt:setString(curData._Count)
           end
       end
    end
end

--
function UIBag:RefreshBagItem()
    self._GridView:reloadData()
end

--刷新左侧物品信息(当前选中的物品信息)
function UIBag:RefreshLeftItemInfo(index)

    if index <= 0 then
        self._ImageCurItem:setVisible(false)
        self._TxtCurDes:setString("")
        self._BtnSell:setVisible(false)
        self._BtnUse:setVisible(false)
    else
        local itemDataList = ServerDataManager._BagItemDataList
        if itemDataList == nil then
            return
        end
        local curData = itemDataList[index]
        if curData ~= nil then
            self._ImageCurItem:setVisible(true)
            local tableData = curData._TableData
            if tableData ~= nil then
                self._ImageCurItem:loadTexture(tableData.image)
                self._TxtCurDes:setString(tableData.des)
            else
                self._ImageCurItem:loadTexture("")
                self._TxtCurDes:setString("")
            end
            
            --使用与出售都显示
            if tableData.isSell == 1 and tableData.isUse == 1 then
                self._BtnSell:setPositionX(self._OldSellPosX)
                self._BtnUse:setPositionX(self._OldUsePosX)
                self._BtnSell:setVisible(true)
                self._BtnUse:setVisible(true)
            --只显示一个或者都不显示
            else
                local newPosx = self._OldUsePosX + (self._OldSellPosX - self._OldUsePosX) / 2
                if tableData.isSell == 1 then
                    self._BtnSell:setVisible(true)
                    self._BtnSell:setPositionX(newPosx)
                    self._BtnUse:setVisible(false)
                elseif tableData.isUse == 1 then
                    self._BtnSell:setVisible(false)
                    self._BtnUse:setVisible(true)
                    self._BtnUse:setPositionX(newPosx)
                else
                    self._BtnSell:setVisible(false)
                    self._BtnUse:setVisible(false)
                end
            end
        else
            self._ImageCurItem:setVisible(false)
            self._TxtCurDes:setString("")
            self._BtnSell:setVisible(false)
            self._BtnUse:setVisible(false)
        end
    end
end
-----------------------------------------Tableview回调处理 begin-----------------------------------------

function UIBag.ScrollViewDidScroll(view)
    --print("ScrollViewDidScroll")
end

function UIBag.NumberOfCellsInTableView(view)
    local len = 0
    local itemDataList = ServerDataManager._BagItemDataList
    if itemDataList ~= nil then
        local count = #itemDataList
        len = mathCeil(count / ITEM_COUNT_ROW)
    end
    --print("NumberOfCellsInTableView ", len)
    return len
end

function UIBag.TableCellTouched(view, cell)

end

function UIBag.CellSizeForTable(view, idx)
    return 580, 180
end

function UIBag.TableCellAtIndex(view, idx)
    print("UIBag.TableCellAtIndex ", idx)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_Bag)
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

--TODO: 发送背包物品操作 请求
--useType(0:1个，1：全部)
local function SendBagItemQuest(cmdStr, useType, sign, itemType, itemType1, itemCount, itemID)

    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://service.7hx.com:8088/WS/box.ashx")

    local function onReadyStateChanged()
        if xhrBag.readyState == 4 then
            if xhrBag.status ~= 200 then
                UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            if xhrBag.response == nil then
               UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            local testStr = xhrBag.response
            local bagTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(bagTable, "bagTable", 10)
            if bagTable.msg ~= nil and bagTable.msg ~= "" then
                 UISystem:ShowMessageBoxOne(bagTable.msg) 
            end
            local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
            lobbyInstance:SendBagDataRequest()
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = string.format("%d%s%s", userID, cmdStr, "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = string.format("cmd=%s&UserId=%d&cmdsign=%s&sign=%s&type=%d&type2=%d&itemcount=%d&usetype=%d&id=%d", cmdStr, userID, newSzMD5, sign, itemType
        ,itemType1, itemCount, useType, itemID)
    print("requestData", requestData)
    xhrBag:send(requestData)
    
end
-----------------------------------------Tableview回调处理 end -----------------------------------------

-------------------------------------------控件逻辑处理- Begin -------------------------------------------
--物品点击
function UIBag.OnBagItemTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local index = sender:getTag()
        print("OnBagItemTouch" , index)
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_Bag)
        uiInstance._CurSelectItemIndex = index
        uiInstance:RefreshLeftItemInfo(index)
    end
end

--出售
function UIBag.OnBagSellItemTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_Bag)
        uiInstance._PopSellAllPanel:setVisible(true)
    end
end
--使用
function UIBag.OnBagUseItemTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_Bag)
        uiInstance._PopUseAllPanel:setVisible(true)
    end  
end
--使用全部点击
function UIBag.OnBagUseAllBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_Bag)
        local useType = sender:getTag()
        local index = uiInstance._CurSelectItemIndex
         local itemDataList = ServerDataManager._BagItemDataList
        if itemDataList == nil then
            return
        end
        local curData = itemDataList[index]
        --发送使用
        SendBagItemQuest("use", useType, curData._Sign, curData._ItemType, curData._ItemType2, curData._Count, curData._ServerID)
        uiInstance._PopUseAllPanel:setVisible(false)
        uiInstance._CurSelectItemIndex = -1
        uiInstance:RefreshLeftItemInfo(-1)
    end  
end

--出售全部点击
function UIBag.OnBagSellAllBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_Bag)
        local useType = sender:getTag()
        local index = uiInstance._CurSelectItemIndex
         local itemDataList = ServerDataManager._BagItemDataList
        if itemDataList == nil then
            return
        end
        local curData = itemDataList[index]
        --发送出售
        SendBagItemQuest("sell", useType, curData._Sign, curData._ItemType, curData._ItemType2, curData._Count, curData._ServerID)
        uiInstance._PopSellAllPanel:setVisible(false)
        uiInstance._CurSelectItemIndex = -1
        uiInstance:RefreshLeftItemInfo(-1)
    end  
end

--使用全部面板点击
function UIBag.OnBagUseallPanelClick(sender)
    sender:setVisible(false)
end

--出售全部
function UIBag.OnBagSellallPanelClick(sender)
    sender:setVisible(false)
end

--关闭
function UIBag:OnBagCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        UISystem:CloseUI(UIType.UIType_Bag)
    end  
end


-------------------------------------------控件逻辑处理- End -------------------------------------------

----------------------自定义事件----------------------
--背包物品改变事件
function UIBag._OnBagItemChange()
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_Bag)
    uiInstance:RefreshBagItem()
end



return UIBag


