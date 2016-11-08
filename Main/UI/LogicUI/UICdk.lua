----
-- 文件名称：UICdk.lua
-- 功能描述：兑换
-- 文件说明：兑换
-- 作    者：金兴泉
-- 创建时间：2016-8-12
--  修改

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UICdk = class("UICdk", UIBase)

local ITEM_CSB_NAME = "CSD/UI/UICdk.csb"

--构造(只做成员初始化)
function UICdk:ctor()
    UIBase.ctor(self)
    
    self._CdkTextField = nil
    self._BtnCdk = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UICdk:Load(resourceName)
    UIBase.Load(self, resourceName)
    --控件赋值
    self._CdkTextField = self:GetUIByName("TextField_Cdk")
    self._BtnCdk = self:GetUIByName("Button_Cdk")
    
--    回调函数
    self._BtnCdk:addTouchEventListener(self.OnCdkTouch)
    
    self._ViewPanel = self:GetUIByName("Panel_Root")
    local btnClose = self:GetUIByName("Button_Close")
    self._ViewPanel:addTouchEventListener(self.OnCloseTouch)
    btnClose:addTouchEventListener(self.OnCloseTouch)
end

--卸载
function UICdk:Unload()
    UIBase.Unload(self)
end

--打开(UI内容初始化)
function UICdk:Open()
    UIBase.Open(self)
    
    self._CdkTextField:setPlaceHolder(ChineseTable["CT_Cdk_Num"])
    self._CdkTextField:setString("")
end

--关闭
function UICdk:Close()
    UIBase.Close(self)
end

-------------------------------------------控件逻辑处理--------------------------------------------
--立即兑换
function UICdk:OnCdkTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:CloseUI(UIType.UIType_Cdk)
        
        local cdkInstance = UISystem:GetUIInstance(UIType.UIType_Cdk)
        local textPassword = cdkInstance._CdkTextField:getString()
        --密码合法性检查
        if string.len(textPassword) == 0 then
            local tipContent = ChineseTable["CT_Cdk_NumNULL"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        if string.len(textPassword) < 16 then
            local tipContent = ChineseTable["CT_Cdk_NumLen"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        local netSystem = NetSystem
        if netSystem:IsConnectLoginServer() == true then
            local csExchange = (require "Main.NetSystem.Packet.CSGPExchange").new()
            csExchange._dwUserID = ServerDataManager._SelfUserInfo._dwUserID
            csExchange._szCDK = textPassword
            netSystem:SendPacketToLoginServer(csExchange)
        else
            local csExchange = (require "Main.NetSystem.Packet.CSGRExchange").new()
            csExchange._szCDK = textPassword
            netSystem:SendGamePacket(csExchange)
        end
    end  
end
--关闭按钮的处理
function UICdk:OnCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:CloseUI(UIType.UIType_Cdk)
    end
end

return UICdk


