----
-- 文件名称：UIMessageBox.lua
-- 功能描述：信息提示框  
-- 文件说明：信息提示框
-- 作    者：王雷雷
-- 创建时间：2016-8-1
--  修改

local UIBase = require("Main.UI.UIBase")

local UIMessageBox = class("UIMessageBox", UIBase)

--构造(只做成员初始化)
function UIMessageBox:ctor()
	UIBase.ctor(self)
    --
    self._ButtonOK = nil
    self._ButtonCancel = nil
    self._TextTip = nil
    self._CallBack = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIMessageBox:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
	self._ButtonOK = self:GetUIByName("Button_OK")
	self._ButtonCancel = self:GetUIByName("Button_Cancel")
	self._TextTip = self:GetUIByName("Text_Tip")
    self._TextTip:ignoreContentAdaptWithSize(false)
    self._ButtonOK:addTouchEventListener(self.OnOkTouch)
    self._ButtonCancel:addTouchEventListener(self.OnCancelTouch)

end

--卸载
function UIMessageBox:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UIMessageBox:Open()
	UIBase.Open(self)
    self._TextTip:setString("")
    
end

--关闭
function UIMessageBox:Close()
	UIBase.Close(self)
    self._CallBack = nil
end

-------------------------------------------------------------------------------------------------------------
function UIMessageBox:SetButtonType(btnType)
    local width = 200
    local btnParent = self._ButtonOK:getParent()
    if btnType == 1 then
        self._ButtonOK:setVisible(true)
        self._ButtonCancel:setVisible(false)
        self._ButtonOK:setPositionX(btnParent:getContentSize().width * 0.5)
    else
        self._ButtonOK:setPositionX(width + 0.5 * self._ButtonOK:getContentSize().width)
        self._ButtonCancel:setPositionX(btnParent:getContentSize().width - width + 0.5 * self._ButtonCancel:getContentSize().width)
        self._ButtonOK:setVisible(true)
        self._ButtonCancel:setVisible(true)
    end
end

function UIMessageBox:ShowText(tipText, callback)
    self._CallBack = callback
    self._TextTip:setString(tipText)
end


-------------------------------------------控件逻辑处理--------------------------------------------
--确定按钮
function UIMessageBox:OnOkTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        if self._CallBack ~= nil then
            self._CallBack()
        end
        UISystem:CloseUI(UIType.UIType_MessageBox)
    end
end
--取消按钮
function UIMessageBox:OnCancelTouch(eventType)
    if eventType == ccui.TouchEventType.ended then

        UISystem:CloseUI(UIType.UIType_MessageBox)
    end
end


return UIMessageBox


