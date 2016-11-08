----
-- 文件名称：UIKefu.lua
-- 功能描述：客服
-- 文件说明：客服
-- 作    者：金兴泉
-- 创建时间：2016-8-12
--  修改

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UIKefu = class("UIKefu", UIBase)

local ITEM_CSB_NAME = "CSD/UI/UIKefu.csb"

--构造(只做成员初始化)
function UIKefu:ctor()
    UIBase.ctor(self)
    self._ViewPanel = nil
    self._ViewBk = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIKefu:Load(resourceName)
    UIBase.Load(self, resourceName)
    self._ViewPanel = self:GetUIByName("Panel_Root")
    self._ViewPanel:addTouchEventListener(self.OnKefuCloseTouch)
    local closeBtn = self:GetUIByName("Button_Close")
    closeBtn:addTouchEventListener(self.OnKefuCloseTouch)
end

--卸载
function UIKefu:Unload()
    UIBase.Unload(self)
end

--打开(UI内容初始化)
function UIKefu:Open()
    UIBase.Open(self)
end

--关闭
function UIKefu:Close()
    UIBase.Close(self)
end

function UIKefu:OnKefuCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        UISystem:CloseUI(UIType.UIType_Kefu)
    end
end

return UIKefu


