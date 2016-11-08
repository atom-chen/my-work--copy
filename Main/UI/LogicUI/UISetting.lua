----
-- 文件名称：UISetting.lua
-- 功能描述：设置
-- 文件说明：设置
-- 作    者：金兴泉
-- 创建时间：2016-8-12
--  修改

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UISetting = class("UISetting", UIBase)

local ITEM_CSB_NAME = "CSD/UI/UISetting.csb"

--构造(只做成员初始化)
function UISetting:ctor()
    UIBase.ctor(self)
    
    --TableView父面板
    self._ViewPanel = nil
    self._ViewBk = nil
    self._CheckBoxMusic = nil
    self._CheckBoxEffect = nil
    self._CheckBoxSpecial = nil
    self._CheckBoxShake = nil
    self._CheckBoxNotice = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UISetting:Load(resourceName)
    UIBase.Load(self, resourceName)
    
    --控件赋值
    self._ViewPanel = self:GetUIByName("Panel_Root")
    local closeBtn = self:GetUIByName("Button_Close")
    self._ViewPanel:addTouchEventListener(self.OnSettingCloseTouch)
    closeBtn:addTouchEventListener(self.OnSettingCloseTouch)
    self._CheckBoxMusic = self:GetUIByName("CheckBox_Music")
    self._CheckBoxEffect = self:GetUIByName("CheckBox_Effect")
    self._CheckBoxSpecial = self:GetUIByName("CheckBox_Special")
    self._CheckBoxShake = self:GetUIByName("CheckBox_Shake")
    self._CheckBoxNotice = self:GetUIByName("CheckBox_Notice")
end

--卸载
function UISetting:Unload()
    UIBase.Unload(self)
end

--打开(UI内容初始化)
function UISetting:Open()
    UIBase.Open(self)
    
    local configData = ServerDataManager._ConfigData
    if (configData._EnableMusic  > 0) then
        self._CheckBoxMusic:setSelected(true)
     else
        self._CheckBoxMusic:setSelected(false)
    end
    
    if (configData._EnableEffect > 0) then
        self._CheckBoxEffect:setSelected(true)
    else
        self._CheckBoxEffect:setSelected(false)
    end
    
    if (configData._EnableSpecial  > 0) then
        self._CheckBoxSpecial:setSelected(true)
    else
        self._CheckBoxSpecial:setSelected(false)
    end
    
    if (configData._EnableShake  > 0) then
        self._CheckBoxShake:setSelected(true)
    else
        self._CheckBoxShake:setSelected(false)
    end
    
    if (configData._EnableNotice  > 0) then
        self._CheckBoxNotice:setSelected(true)
    else
        self._CheckBoxNotice:setSelected(false)
    end
    
end

--关闭
function UISetting:Close()
    UIBase.Close(self)
end


--关闭按钮
function UISetting:OnSettingCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
    
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)

        local uiInstance = UISystem:GetUIInstance(UIType.UIType_Setting)
        local configData = ServerDataManager._ConfigData

        if (uiInstance._CheckBoxMusic:isSelected() == true) then
            local isChange = (configData._EnableMusic == 0)
            configData._EnableMusic = 1
            if isChange then
                SoundPlay:ResumeCurBgMusic()
            end
        else
           configData._EnableMusic = 0
            SoundPlay:StopCurBgMusic()
        end
        
        if (uiInstance._CheckBoxEffect:isSelected() == true) then
            configData._EnableEffect = 1
        else
            configData._EnableEffect = 0
        end
        
        if (uiInstance._CheckBoxSpecial:isSelected() == true) then
           configData._EnableSpecial = 1
        else
            configData._EnableSpecial = 0
        end
        
        if (uiInstance._CheckBoxShake:isSelected() == true) then
            configData._EnableShake = 1
        else
            configData._EnableShake = 0
        end
        
        if (uiInstance._CheckBoxNotice:isSelected() == true) then
            configData._EnableNotice = 1
        else
            configData._EnableNotice = 0
        end

        ServerDataManager:SaveLocalConfig()
        UISystem:CloseUI(UIType.UIType_Setting)
    end
end

return UISetting


