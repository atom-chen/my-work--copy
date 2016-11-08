----
-- 文件名称：UIQianDao.lua
-- 功能描述：签到界面
-- 文件说明：签到界面
-- 作    者：王雷雷
-- 创建时间：2016-9-8
--  修改:

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UIQianDao = class("UIQianDao", UIBase)

--减少重复调用全局
local mathCeil = math.ceil
local stringFormat = string.format

--构造(只做成员初始化)
function UIQianDao:ctor()
	UIBase.ctor(self)

    --ItemList
    self._ItemList = nil
    --签收按钮
    self._QianShouBtn = nil
    --数据改变的handler
    self._DataChangeHandler = nil
    --选中
    self._SelectedImage = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIQianDao:Load(resourceName)
	UIBase.Load(self, resourceName)

    self._QianShouBtn = self:GetUIByName("Button_QianShou")
    self._QianShouBtn:addTouchEventListener(self.OnQianShouBtnTouch) 
    local closeBtn = self:GetUIByName("Button_Close")
    closeBtn:addTouchEventListener(self.OnCloseBtnTouch)
    self._SelectedImage = self:GetUIByName("Image_Selected")
    self._ItemList = {}
    local itemPanel = nil
    local itemPanelName = ""
    --初始化七天签到的UI(第几天，奖励及图标)
    local someDayTxt = ChineseTable["CT_QianDao_SomeDay"]
    local qianDaoDataList = TableDataManager._QianDaoTableData
    --dump(qianDaoData, 10)
    for i = 1, 7 do
        itemPanelName = stringFormat("Panel_DayItem_%d", i)
        itemPanel = self:GetUIByName(itemPanelName)
        local textDay = seekNodeByName(itemPanel, "Text_ItemDayCount")
        local textGold = seekNodeByName(itemPanel, "Text_ItemGold")
        local imageIcon = seekNodeByName(itemPanel, "Image_ItemIcon")
        local itemBg = seekNodeByName(itemPanel, "Image_ItemBg")
        local imageTag = seekNodeByName(itemPanel, "Image_QianTag")
        self._ItemList[i] = {}
        self._ItemList[i].itemPanel = itemPanel
        self._ItemList[i].itemBg = itemBg
        self._ItemList[i].imageTag = imageTag
        --第几天
        local showDayTxt = stringFormat(someDayTxt, i)
        textDay:setString(showDayTxt)
        local qianDaoData = qianDaoDataList[i]
        --奖励文字(金币Or礼包)
        local showGoldTxt = ""
        if qianDaoData.rewardType == 1 then
            showGoldTxt = stringFormat("%d%s", qianDaoData.rewardVal, qianDaoData.rewardStr)
        elseif qianDaoData.rewardType == 2 then
            showGoldTxt = qianDaoData.rewardStr
        end
        textGold:setString(showGoldTxt)
        --图标
        imageIcon:loadTexture(qianDaoData.image)
        imageTag:setVisible(false)
    end
    
end

--卸载
function UIQianDao:Unload()
	UIBase.Unload(self)


end

--打开(UI内容初始化)
function UIQianDao:Open()
	UIBase.Open(self)
    self._SelectedImage:setVisible(false)
    self:RefreshUIInfo()
    self._DataChangeHandler = EventSystem:AddEvent(GameEvent.GE_QianDaoChange, self.OnDataChange) 
end

--关闭
function UIQianDao:Close()
	UIBase.Close(self)
    if self._DataChangeHandler ~= nil then
        EventSystem:RemoveEvent(self._DataChangeHandler)
        self._DataChangeHandler = nil
    end

end

--刷新UI
function UIQianDao:RefreshUIInfo()
    local qianDaoData = ServerDataManager._QianDaoData
    if qianDaoData == nil then
        self._QianShouBtn:setEnabled(false)
    else
        local days = qianDaoData._QianDaoDays
        for i = 1, 7 do
            local dayItems = self._ItemList[i]
            --选中当前
            if i == days + 1 then
                dayItems.imageTag:setVisible(false)
                --选中
                self._SelectedImage:setVisible(true)
                self._SelectedImage:retain()
                self._SelectedImage:removeFromParent()
                self._ItemList[i].itemBg:addChild(self._SelectedImage)
                self._SelectedImage:release()
            elseif i < days + 1 then
                dayItems.imageTag:setVisible(true)
            else
                dayItems.imageTag:setVisible(false)
            end
        end
        self._QianShouBtn:setEnabled(not qianDaoData._IsQianToday)
    end
end

----------------------------------------------------------------------

--请求签到
local function SendTodayQianDaoRequest()
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://service.7hx.com:8088/WS/mbinterface.ashx")

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
            local qianDaoTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(qianDaoTable, "qianDaoTable", 10)
            if qianDaoTable ~= nil and qianDaoTable.stat == true then
                local qianDaoData = ServerDataManager._QianDaoData 
                qianDaoData._QianDaoDays = qianDaoData._QianDaoDays + 1
                qianDaoData._IsQianToday = true
                --动画表现相关

                EventSystem:DispatchEvent(GameEvent.GE_QianDaoChange)
            end
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = stringFormat("%d%s%s", userID, "signon", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = stringFormat("cmd=%s&UserId=%d&cmdsign=%s", "signon", userID, newSzMD5)
    print("requestData ", requestData)
    xhrBag:send(requestData)
    
end

--签收按钮点击
function UIQianDao.OnQianShouBtnTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local qianDaoUI = UISystem:GetUIInstance(UIType.UIType_QianDao)
        SendTodayQianDaoRequest()
        qianDaoUI._QianShouBtn:setEnabled(false)
       --UISystem:CloseUI(UIType.UIType_QianDao)
    end
end
--关闭按钮点击
function UIQianDao.OnCloseBtnTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        UISystem:CloseUI(UIType.UIType_QianDao)
    end
end


-------------------------------------------------------------
function UIQianDao.OnDataChange()
    local qianDaoUI = UISystem:GetUIInstance(UIType.UIType_QianDao)
    qianDaoUI:RefreshUIInfo()
end

return UIQianDao


