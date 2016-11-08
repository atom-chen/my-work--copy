----
-- 文件名称：UICangKu.lua
-- 功能描述：仓库界面
-- 文件说明：仓库界面
-- 作    者：王雷雷
-- 创建时间：2016-9-8
--  修改:

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UICangKu = class("UICangKu", UIBase)

--减少重复调用全局
local mathCeil = math.ceil
local stringFormat = string.format

--构造(只做成员初始化)
function UICangKu:ctor()
	UIBase.ctor(self)
    --主面板
    self._MainPanel = nil
    --弹出密码面板
    self._PwdPanel = nil
    --文本 背包，仓库金币
    self._AtlasLabelBagGold = nil
    self._AtlasLabelCKGold = nil
    self._TextFieldGoldCount = nil
    --密码
    self._TextFieldPwd = nil
    --当前输入的金币数
    self._CurGoldCount = 0
    self._SelfInfoChangeHandler = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UICangKu:Load(resourceName)
	UIBase.Load(self, resourceName)

    self._MainPanel =  self:GetUIByName("Panel_Bg")
    self._PwdPanel = self:GetUIByName("Panel_Pwd")

    local takeBtn = self:GetUIByName("Button_Take")
    local saveBtn = self:GetUIByName("Button_Save")
    local closeBtn = self:GetUIByName("Button_Close")
    local takePwdOkBtn =  self:GetUIByName("Button_OK")
    takeBtn:addTouchEventListener(self.OnTakeBtnTouch)
    saveBtn:addTouchEventListener(self.OnSaveBtnTouch)
    closeBtn:addTouchEventListener(self.OnCloseBtnTouch)
    takePwdOkBtn:addTouchEventListener(self.OnPwdOkBtnTouch)

    self._AtlasLabelBagGold = self:GetUIByName("AtlasLabel_BagGold")
    self._AtlasLabelCKGold = self:GetUIByName("AtlasLabel_CKGold")
    self._TextFieldGoldCount = self:GetUIByName("TextField_GoldCount")
    self._TextFieldPwd = self:GetUIByName("TextField_pwd")

    self._TextFieldGoldCount:setString("")
end

--卸载
function UICangKu:Unload()
	UIBase.Unload(self)

end

--打开(UI内容初始化)
function UICangKu:Open()
	UIBase.Open(self)

    self._MainPanel:setVisible(true)
    self._PwdPanel:setVisible(false)
    self:RefreshUIUserInfo()
    self._TextFieldGoldCount:setString("")
    self._CurGoldCount = 0

    self._SelfInfoChangeHandler = EventSystem:AddEvent(GameEvent.GE_UserInfoChange, self.OnSelfInfoChange)
end

--关闭
function UICangKu:Close()
	UIBase.Close(self)
    if self._SelfInfoChangeHandler ~= nil then
        EventSystem:RemoveEvent(self._SelfInfoChangeHandler)
        self._SelfInfoChangeHandler = nil
    end
end

--刷新金币数量的显示
function UICangKu:RefreshUIUserInfo()
    local selfInfo = ServerDataManager._SelfUserInfo
    self._AtlasLabelBagGold:setString(selfInfo._lUserScore)
    self._AtlasLabelCKGold:setString(selfInfo._lUserInsure)
end
-------------------------------------------

--取走
function UICangKu.OnTakeBtnTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local cangKuUI = UISystem:GetUIInstance(UIType.UIType_CangKu)
        local txtGold = cangKuUI._TextFieldGoldCount:getString()
        --不能为空
        if string.len(txtGold) == 0  then
            local tipContent = ChineseTable["CT_CangKu_NoGold"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        --只能为数字
        local goldCountNum = tonumber(txtGold)
        if goldCountNum == nil then
            local tipContent = ChineseTable["CT_CangKu_GoldMustNumber"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        --最少为1
        if goldCountNum < 1 then
            local tipContent = ChineseTable["CT_CangKu_GoldLessOne"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        --最大值判定
        local selfInfo = ServerDataManager._SelfUserInfo
        if goldCountNum > selfInfo._lUserInsure then
            local tipContent = ChineseTable["CT_CangKu_GoldMoreOwn"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        cangKuUI._CurGoldCount = goldCountNum
        cangKuUI._PwdPanel:setVisible(true)
        cangKuUI._TextFieldPwd:setString("")
    end
end

--存仓库
function UICangKu.OnSaveBtnTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local cangKuUI = UISystem:GetUIInstance(UIType.UIType_CangKu)
        local txtGold = cangKuUI._TextFieldGoldCount:getString()
        --不能为空
        if string.len(txtGold) == 0  then
            local tipContent = ChineseTable["CT_CangKu_NoGold"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        --只能为数字
        local goldCountNum = tonumber(txtGold)
        if goldCountNum == nil then
            local tipContent = ChineseTable["CT_CangKu_GoldMustNumber"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        --最少为1
        if goldCountNum < 1 then
            local tipContent = ChineseTable["CT_CangKu_GoldLessOne"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        local takePacket = require("Main.NetSystem.Packet.CSLCangKuSaveScore").new()
        takePacket._llSaveScore = goldCountNum
        NetSystem:SendPacketToLoginServer(takePacket)  
        cangKuUI._TextFieldGoldCount:setString("")
    end
end

--密码确认 确定按钮点击
function UICangKu.OnPwdOkBtnTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local cangKuUI = UISystem:GetUIInstance(UIType.UIType_CangKu)
        local pwdTxt = cangKuUI._TextFieldPwd:getString()
        if string.len(pwdTxt) == 0 then
            local tipContent = ChineseTable["CT_Login_PasswordNULL"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        local takePacket = require("Main.NetSystem.Packet.CSLCangKuTakeScore").new()
        takePacket._llSaveScore = cangKuUI._CurGoldCount  
        local encryptInstance = LuaLib.CEncrypt:new()
        local passwordStr = encryptInstance:MD5EncryptString32(pwdTxt)
        takePacket._szPassword33 = passwordStr   
        NetSystem:SendPacketToLoginServer(takePacket)  
        cangKuUI._PwdPanel:setVisible(false)
        cangKuUI._TextFieldGoldCount:setString("")
    end
end

--关闭
function UICangKu.OnCloseBtnTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        UISystem:CloseUI(UIType.UIType_CangKu)
    end
end


------------------------------------------------
--个人信息改变
function UICangKu.OnSelfInfoChange()
    local cangKuUI = UISystem:GetUIInstance(UIType.UIType_CangKu)
    cangKuUI:RefreshUIUserInfo()
end

return UICangKu


