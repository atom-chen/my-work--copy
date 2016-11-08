----
-- 文件名称：UIFanKui.lua
-- 功能描述：反馈界面
-- 文件说明：反馈界面
-- 作    者：王雷雷
-- 创建时间：2016-9-10
--  修改:

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UIFanKui = class("UIFanKui", UIBase)

--减少重复调用全局
local mathCeil = math.ceil
local stringFormat = string.format

--构造(只做成员初始化)
function UIFanKui:ctor()
	UIBase.ctor(self)
    --所有按钮
    self._CheckBoxList = nil
    --所有Text
    self._TextList = nil
    --内容 
    self._TextFieldContent = nil
    --当前选择的索引
    self._SelectIndex = 0
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIFanKui:Load(resourceName)
	UIBase.Load(self, resourceName)
    local checkName = ""
    local textName = ""
    self._CheckBoxList = {}
    self._TextList = {}
    for i = 1, 4 do
        checkName = stringFormat("CheckBox_%d", i)
        textName = stringFormat("TextType_%d", i)
        self._CheckBoxList[i] = self:GetUIByName(checkName)
        self._CheckBoxList[i]:addEventListener(self.OnCheckBoxTouch)
        self._CheckBoxList[i]:setTag(i)
        self._TextList[i] = self:GetUIByName(textName)
    end
    --
    local btnCommit = self:GetUIByName("Button_Commit")
    btnCommit:addTouchEventListener(self.OnCommitTouch)
    local btClose = self:GetUIByName("Button_Close") 
    btClose:addTouchEventListener(self.OnCloseTouch)
    self._TextFieldContent = self:GetUIByName("TextField_Content")
end

--卸载
function UIFanKui:Unload()
	UIBase.Unload(self)

end

--打开(UI内容初始化)
function UIFanKui:Open()
	UIBase.Open(self)
    self:SetSelect(1, true)

end

--关闭
function UIFanKui:Close()
	UIBase.Close(self)

end

-----------------------------------------------------------------
--设置 选择的
function UIFanKui:SetSelect(index, select)
    if select == true then
        self._SelectIndex = index  
    else
        self._SelectIndex = 0
    end

    for i = 1, 4 do
        local isSelected = false
        if index == i then
            isSelected = select
        end
        self._CheckBoxList[i]:setSelected(isSelected)
    end
end

-- 反馈 请求
 function UIFanKui:SendFanKuiRequest(title, content)
    print("SendFanKuiRequest ", title, content)
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
            local fankuiTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(fankuiTable, "fankuiTable", 10)
            if fankuiTable ~= nil and fankuiTable.stat == true then
                UISystem:ShowMessageBoxOne(ChineseTable["CT_FanKui_Reply"]) 
            end
            UISystem:CloseUI(UIType.UIType_FanKui)
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = stringFormat("%d%s%s", userID, "feedback", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)

    local requestData = stringFormat("cmd=%s&UserId=%d&cmdsign=%s&title=%s&content=%s", "feedback", userID, newSzMD5, title, content)
    --print("requestData ", requestData)
    xhrBag:send(requestData)
    
end

--选中的
function UIFanKui.OnCheckBoxTouch(sender, eventType)
    local fankuiUI = UISystem:GetUIInstance(UIType.UIType_FanKui)
    if eventType == ccui.CheckBoxEventType.selected then
        local tag = sender:getTag()
        fankuiUI:SetSelect(tag, true)
    elseif eventType == ccui.CheckBoxEventType.unselected then
        local tag = sender:getTag()
        fankuiUI:SetSelect(tag, false)
    end
end

--提交按钮点击
function UIFanKui.OnCommitTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local fankuiUI = UISystem:GetUIInstance(UIType.UIType_FanKui)
        local curIndex = fankuiUI._SelectIndex
        if curIndex == 0 then
            curIndex = 1
        end
        local title = fankuiUI._TextList[curIndex]:getString()
        local content = fankuiUI._TextFieldContent:getString()
        if string.len(content) == 0 then
            local showText = ChineseTable["CT_FanKui_ContentNull"]
             UISystem:ShowMessageBoxOne(showText) 
            return 
        end
        fankuiUI:SendFanKuiRequest(title, content)
    end
end

--关闭按钮
function UIFanKui.OnCloseTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        UISystem:CloseUI(UIType.UIType_FanKui)
    end
end


return UIFanKui


