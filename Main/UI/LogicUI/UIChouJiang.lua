----
-- 文件名称：UIChouJiang.lua
-- 功能描述：抽奖界面
-- 文件说明：抽奖界面
-- 作    者：王雷雷
-- 创建时间：2016-9-10
--  修改:

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UIChouJiang = class("UIChouJiang", UIBase)
local ITEM_CSB_NAME = "CSD/UI/UICJPaiHang.csb"


--减少重复调用全局
local mathCeil = math.ceil
local stringFormat = string.format

--构造(只做成员初始化)
function UIChouJiang:ctor()
	UIBase.ctor(self)
    --Gold
    self._TextGold = nil
    self._TextCount = nil
    --转盘
    self._ZhuanPanSprite = nil
    -- handler
    self._InfoChangeHandler = nil
    -------------------------------------奖励面板---------------------------------------
    self._PanelPrize = nil
    --单抽奖励名称Text
    self._TextPrizeName = nil
    self._ImagePrize = nil
    self._CurPrizeID = 0
    self._CurPrizeName = ""
    --单抽奖励根节点
    self._NodeDanChou = nil
    --十连抽
    self._PrizeList = nil
    self._NodeTenPrize = nil
    self._TenPrizeItemList = nil
    -------------------------------排行榜---------------------------------------
    self._RankHandler = nil
    --控件
    self._RankTypeBtnList = nil
    self._ItemCellList = nil
    self._RankTableView = nil
    --当前排行榜类型
    self._RankType = 1
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIChouJiang:Load(resourceName)
	UIBase.Load(self, resourceName)

    self._TextGold = self:GetUIByName("AtlasLabel_Gold") 
    self._TextCount = self:GetUIByName("AtlasLabel_Count")

    local btClose = self:GetUIByName("Button_Close") 
    btClose:addTouchEventListener(self.OnCloseTouch)
    local btBag = self:GetUIByName("Button_Bag") 
    btBag:addTouchEventListener(self.OnBagTouch)
    local btTryOne = self:GetUIByName("Button_TryOne")
    btTryOne:addTouchEventListener(self.OnTryOneTouch)
    local btTryTen = self:GetUIByName("Button_TryTen")
    btTryTen:addTouchEventListener(self.OnTryTenTouch)

    self._ZhuanPanSprite = self:GetUIByName("Sprite_ZhuanPan")

    ----------------------奖励面板相关-----------------------
    self._PanelPrize = self:GetUIByName("Panel_Prize")
    self._PanelPrize:addTouchEventListener(self.OnPanelPrizeTouch)
    --self._TextPrizeName = seekNodeByName(self._PanelPrize, "Text_PrizeName")
    self._ImagePrize = seekNodeByName(self._PanelPrize, "Image_PrizeItem")
    self._NodeDanChou = seekNodeByName(self._PanelPrize, "Node_DanChou")
    self._NodeTenPrize = seekNodeByName(self._PanelPrize, "Node_TenPrize")
    self._TenPrizeItemList = {}
    for i = 1, 10 do
        local itemName = stringFormat("Image_PrizeItem_%d", i)
        self._TenPrizeItemList[i] = seekNodeByName(self._NodeTenPrize, itemName)
    end

    ------------------排行榜相关-------------------------
    self._RankTypeBtnList = {} 
    local nameList = {"Btn_DayRank", "Btn_WeekRank", "Btn_MonthRank"}
    for i = 1, 3 do
        self._RankTypeBtnList[i] = self:GetUIByName(nameList[i])
        self._RankTypeBtnList[i]:setTag(i)
        self._RankTypeBtnList[i]:addTouchEventListener(self.OnRankTypeTouch)
    end
    local viewPanel = self:GetUIByName("Panel_PaiHang")
    local contentSize = viewPanel:getContentSize()
    self._RankTableView = CreateTableView(0, 0, contentSize.width, contentSize.height, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    if viewPanel ~= nil then
        viewPanel:addChild(self._RankTableView)
    end
end

--卸载
function UIChouJiang:Unload()
	UIBase.Unload(self)

end

--打开(UI内容初始化)
function UIChouJiang:Open()
	UIBase.Open(self)
    self._PanelPrize:setVisible(false)
    self:SendCJInfoRequest()
    if ServerDataManager._CJRankDataList == nil then
        self:SendRankRequest()
    end
    self:RefreshUIInfo()
    self._InfoChangeHandler = EventSystem:AddEvent(GameEvent.GE_UserInfoChange, self.OnSelfInfoChange)
    self._RankHandler = EventSystem:AddEvent(GameEvent.GE_CJRankDataChange, self.OnRankDataChange)
    self._RankType = 1
    self:RefreshRankInfo()
    
end

--关闭
function UIChouJiang:Close()
	UIBase.Close(self)

    if self._InfoChangeHandler ~= nil then
        EventSystem:RemoveEvent(self._InfoChangeHandler)
        self._InfoChangeHandler = nil
    end
    if self._RankHandler ~= nil then
        EventSystem:RemoveEvent(self._RankHandler)
        self._RankHandler = nil
    end
end

------------------------------------------------------------------
--刷新UI信息
function UIChouJiang:RefreshUIInfo()
    local meInfo = ServerDataManager._SelfUserInfo
    self._TextGold:setString(meInfo._lUserInsure)
    self._TextCount:setString(meInfo._CJCount)
end

--刷新排行榜数据
function UIChouJiang:RefreshRankInfo()
    print("UIChouJiang:RefreshRankInfo reloadData ")
    self._RankTableView:reloadData()
end

--获取Cell index:从1开始,只创建一次
function UIChouJiang:GetItemCellByIndex(index)
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

--idx 从1开始 (初始化排行榜内容)
function UIChouJiang:InitCellContent(idx, contentCell)
    if idx == nil or contentCell == nil then
        return
    end
    local rankDataList = ServerDataManager._CJRankDataList
    if rankDataList == nil then
        return
    end

    local allRankData = rankDataList[self._RankType]
    local rankData = allRankData[idx]
    local textIndex = seekNodeByName(contentCell, "Text_Index")
    local textName = seekNodeByName(contentCell, "Text_Nick")
    local textGold = seekNodeByName(contentCell, "AtlasLabel_Gold")
    print("UIChouJiang:InitCellContent ", idx)
    --dump(rankData)
    if rankData ~= nil then
        --目前缺少 数字0的资源，所以这样写
        if idx == 10 then
            textIndex:setString("0")
        else
            textIndex:setString(tostring(idx))
        end
        textName:setString(rankData._NickName)
        textGold:setString(tostring(rankData._Gold))
    end
end


-------------------------------Tableview 回调 Begin----------------------------------------------------------

function UIChouJiang.ScrollViewDidScroll(view)
 
end

function UIChouJiang.NumberOfCellsInTableView(view)
    local len = 0
    local rankDataList = ServerDataManager._CJRankDataList
    if  rankDataList ~= nil then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
        local allRank = rankDataList[uiInstance._RankType]
        if allRank ~= nil then
            len = #allRank
        end
    end
    print("NumberOfCellsInTableView ", len)
    return len
end

function UIChouJiang.TableCellTouched(view, cell)

end

function UIChouJiang.CellSizeForTable(view, idx)
    return 520, 40
end

function UIChouJiang.TableCellAtIndex(view, idx)
    --print("TableCellAtIndex ", idx)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
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



-------------------------------Tableview 回调 End----------------------------------------------------------


--请求抽奖基础信息 baseInfo
function UIChouJiang:SendCJInfoRequest()
    print("SendFanKuiRequest ", title, content)
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://service.7hx.com:8088/WS/mbprize.ashx")

    local function onReadyStateChanged()
        print("onReadyStateChanged", xhrBag.readyState)
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
            local chouJiangTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(chouJiangTable, "chouJiangTable", 10)
            if chouJiangTable ~= nil and chouJiangTable.data ~= nil then
                local meInfo = ServerDataManager._SelfUserInfo
                meInfo._lUserInsure = chouJiangTable.data.InsureScore
                meInfo._CJCount =  chouJiangTable.data.PrizeCount
                EventSystem:DispatchEvent(GameEvent.GE_UserInfoChange)
            end
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = stringFormat("%d%s%s", userID, "pirzebaseinfo", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = stringFormat("cmd=%s&UserId=%d&cmdsign=%s", "pirzebaseinfo", userID, newSzMD5)
    xhrBag:send(requestData)
    
end

--发送抽奖（prize：单抽  slc：十连抽）
function UIChouJiang:SendCJOp(opStr)
    print("SendFanKuiRequest ", title, content)
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://service.7hx.com:8088/WS/mbprize.ashx")
    --回应
    local function onReadyStateChanged()
        print("onReadyStateChanged", xhrBag.readyState)
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
            local chouJiangTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(chouJiangTable, "chouJiangTable", 10)
            if chouJiangTable ~= nil  then
                if chouJiangTable.stat == false then
                    if chouJiangTable.msg ~= nil and chouJiangTable.msg ~= "" then
                         UISystem:ShowMessageBoxOne(chouJiangTable.msg) 
                    end
                    return
                end

                local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
                local len = #chouJiangTable.data
                --抽到的是否是物品类
                local haveItem = false
                --单抽(播放动画)
                if len == 1 then
                    --显示单抽时的动画
                     cjInstance:SetZp(chouJiangTable.data[1].id)
                     cjInstance._CurPrizeName = chouJiangTable.data[1].name
                     cjInstance._CurPrizeID = chouJiangTable.data[1].id
                     local chouJiangData = TableDataManager._ChouJiangData
                     local cfgData = chouJiangData[cjInstance._CurPrizeID]
                     if cfgData ~= nil then
                        if cfgData.type ~= 1 then
                            haveItem = true
                        end
                     end
                --十连抽（直接刷新奖励面板）
                else
                    cjInstance._PanelPrize:setVisible(true)
                    cjInstance._NodeDanChou:setVisible(false)
                    cjInstance._NodeTenPrize:setVisible(true)
                    local chouJiangData = TableDataManager._ChouJiangData
                    for i = 1, len do
                        local serverData = chouJiangTable.data[i]
                        local id = serverData.id
                        local imageItem = cjInstance._TenPrizeItemList[i]
                        --图标
                        if id ~= nil then
                            local iconItem = imageItem:getChildByName("Image_Icon")
                            local cfgData = chouJiangData[id]
                            if cfgData ~= nil then
                                if cfgData.type ~= 1 then
                                    haveItem = true
                                end
                                iconItem:loadTexture(cfgData.image)
                            end

                        end
                        --文字
                        local nameItem = imageItem:getChildByName("Text_PrizeName")
                        nameItem:setString(serverData.name)
                    end
                end
                --抽到的是物品时，请求背包数据
                if haveItem == true then
                    local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
                    lobbyInstance:SendBagDataRequest()
                end

            end
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = stringFormat("%d%s%s", userID, opStr, "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = stringFormat("cmd=%s&UserId=%d&cmdsign=%s", opStr, userID, newSzMD5)
    xhrBag:send(requestData)
end
--发送排行榜请求
function UIChouJiang.SendRankRequest()
    print("SendRankRequest ")
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://service.7hx.com:8088/WS/mbprize.ashx")

    local function onReadyStateChanged()
        print("onReadyStateChanged", xhrBag.readyState)
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
            local cjRankTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(cjRankTable, "cjRankTable", 10)
            if cjRankTable ~= nil  then
                local len = #cjRankTable
                ServerDataManager._CJRankDataList = {}
                for i = 1, 3 do
                    ServerDataManager._CJRankDataList[i] = {}
                    local dayRank = cjRankTable[i]
                    for j = 1, #dayRank do
                        local serverData = dayRank[j]
                        if serverData ~= nil then
                            local newRankData = ServerDataManager:CreateCJRankData()
                            newRankData._RankIndex = j
                            newRankData._NickName = serverData.NickName
                            newRankData._Gold = serverData.ItemCount
                            ServerDataManager._CJRankDataList[i][j] = newRankData
                        end
                    end
                end
                EventSystem:DispatchEvent(GameEvent.GE_CJRankDataChange)
            end
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = stringFormat("%d%s%s", userID, "ranklog", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = stringFormat("cmd=%s&UserId=%d&cmdsign=%s", "ranklog", userID, newSzMD5)
    xhrBag:send(requestData)
    
end

--设置转盘
function UIChouJiang:SetZp(curIndex)
    self._ZhuanPanSprite:setRotation(0)
    --转的总圈数
    local rotDeg = curIndex * 30 + 5 * 360
    --转动角速度
    local degSpeed = 270
    local rotBy = cc.RotateBy:create(rotDeg / degSpeed,  rotDeg)
    local easeOut = cc.EaseSineOut:create(rotBy)
    local seq = cc.Sequence:create(easeOut, cc.CallFunc:create(self.OnZpRotateEnd), nil)
    self._ZhuanPanSprite:runAction(seq)
end
--转盘动画结束,显示单抽奖励面板
function UIChouJiang.OnZpRotateEnd(sender)
    local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
    cjInstance._PanelPrize:setVisible(true)
    cjInstance._NodeDanChou:setVisible(true)
    cjInstance._NodeTenPrize:setVisible(false)
    local id = cjInstance._CurPrizeID
    local imageItem = cjInstance._ImagePrize
    local chouJiangData = TableDataManager._ChouJiangData
    --图标
    if id ~= nil then
        local iconItem = imageItem:getChildByName("Image_Icon")
        local cfgData = chouJiangData[id]
        if cfgData ~= nil then
            iconItem:loadTexture(cfgData.image)
        end
    end
    --文字
    local nameItem = imageItem:getChildByName("Text_PrizeName")
    nameItem:setString(cjInstance._CurPrizeName)

end
-----------------------------------------------------------------
--背包按钮
function UIChouJiang.OnBagTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --避免频繁请求数据(第一次时去请求)
        local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
        if ServerDataManager._BagItemDataList == nil then
            lobbyInstance:SendBagDataRequest()
        end
        UISystem:OpenUI(UIType.UIType_Bag)
    end
end


--关闭按钮
function UIChouJiang.OnCloseTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        UISystem:CloseUI(UIType.UIType_ChouJiang)
    end
end

--单抽
function UIChouJiang.OnTryOneTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
        cjInstance:SendCJOp("prize")
    end
end
--十连抽
function UIChouJiang.OnTryTenTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
        cjInstance:SendCJOp("slc")
    end
end

--抽奖 奖励 面板
function UIChouJiang.OnPanelPrizeTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        sender:setVisible(false)
        local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
        cjInstance:SendCJInfoRequest()
    end
end

--排行榜类型点击
function UIChouJiang.OnRankTypeTouch(sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
        cjInstance._RankType = sender:getTag()
        cjInstance:RefreshRankInfo()
     end
end
--------------------------------自定义事件--------------------------------
--金币等信息发生改变时的回调
function UIChouJiang.OnSelfInfoChange()
    local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
    cjInstance:RefreshUIInfo()
end

--排行榜数据改变
function UIChouJiang.OnRankDataChange()
    local cjInstance = UISystem:GetUIInstance(UIType.UIType_ChouJiang)
    cjInstance:RefreshRankInfo()
end
--

return UIChouJiang


