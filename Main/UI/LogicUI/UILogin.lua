----
-- 文件名称：UIlogin.lua
-- 功能描述：登录UI   临时测试框架UI
-- 文件说明：登录UI
-- 作    者：王雷雷
-- 创建时间：2016-6-29
--  修改

local UIBase = require("Main.UI.UIBase")

local UILogin = class("UILogin", UIBase)

--构造(只做成员初始化)
function UILogin:ctor()
	UIBase.ctor(self)
    --登录背景图
    self._ImageBg = nil

    self._LoginPanel = nil
	--登陆按钮
	self._LoginButton = nil
	--帐号输入框 
	self._AccountTextField = nil
	--密码输入框
	self._PasswordTextField = nil

    -----注册面板
    self._RegPanel = nil
    self._RegAccountTxtField = nil
    self._RegPasswordTxtField = nil
    self._RegConfirmTxtField = nil
    self._RegCommitBtn = nil
    self._BtnReg = nil
    self._RegCloseBtn = nil
    self._BtnYouKe = nil
    self._BtnAccount = nil
    self._BtnAccountClose = nil
	--事件Handler
	self._UserInfoHandler = nil
    self._ServerConnectedHandler = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UILogin:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
    self._ImageBg = self:GetUIByName("Image_loginBack")
    self._LoginPanel = self:GetUIByName("Panel_Login")
	self._LoginButton = self:GetUIByName("Button_Login")
    self._BtnReg = self:GetUIByName("Button_Register")
	self._AccountTextField = self:GetUIByName("TextField_Account")
	self._PasswordTextField = self:GetUIByName("TextField_Password")
    self._RegPanel = self:GetUIByName("Panel_Register")
    self._RegAccountTxtField = self:GetUIByName("Text_Reg_Account")
    self._RegPasswordTxtField = self:GetUIByName("Text_Reg_Password")
    self._RegConfirmTxtField = self:GetUIByName("Text_Reg_ConfirmPassword")
    self._RegCommitBtn = self:GetUIByName("Button_Reg_Commit")
    self._RegCloseBtn = self:GetUIByName("Button_Reg_Close")
    self._BtnAccount = self:GetUIByName("Button_Account")
    self._BtnAccountClose  = self:GetUIByName("Button_CloseAccount")
	--注册回调函数
    self._LoginButton:addTouchEventListener(self.OnLoginTouch)
    self._RegCommitBtn:addTouchEventListener(self.OnRegisterCommitTouch)
    self._BtnReg:addTouchEventListener(self.OnRegisterTouch)
    self._RegCloseBtn:addTouchEventListener(self.OnRegisterCloseTouch)
    self._BtnAccount:addTouchEventListener(self.OnAccountLoginTouch)
    self._BtnAccountClose:addTouchEventListener(self.OnAccountCloseTouch)
end

--卸载
function UILogin:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UILogin:Open()
	UIBase.Open(self)
	
    self._AccountTextField:setPlaceHolder(ChineseTable["CT_Login_Account"])
    self._PasswordTextField:setPlaceHolder(ChineseTable["CT_Login_Password"])
    self._AccountTextField:setString("")
    self._PasswordTextField:setString("")
    
    local ConfigData = ServerDataManager._ConfigData
    self._AccountTextField:setString(ConfigData._UserAccount)
    self._PasswordTextField:setString(ConfigData._UserPassword)
    
    --测试
--    self._AccountTextField:setString('qwe1234')
--    self._PasswordTextField:setString('111111')
    
    --自定义事件逻辑
    self._ServerConnectedHandler = EventSystem:AddEvent(GameEvent.NE_CONNECTED, self.OnServerConnected)
    self._UserInfoHandler = EventSystem:AddEvent(GameEvent.GE_UserInfoChange, self.OnSelfInfoChange)

    --
    self._LoginPanel:setVisible(false)
    self._RegPanel:setVisible(false)

    --添加水泡粒子
    self._ImageBg:removeAllChildren()
    local particleSystem = cc.ParticleSystemQuad:create("Art/Particle/ShuiPao.plist")
    particleSystem:setPosition(100, 200)
    particleSystem:setDuration(-1)
    self._ImageBg:addChild(particleSystem)
end

--关闭
function UILogin:Close()
    --清理掉粒子
    self._ImageBg:removeAllChildren()
	UIBase.Close(self)
    if self._ServerConnectedHandler ~= nil then
        EventSystem:RemoveEvent(self._ServerConnectedHandler)
        self._ServerConnectedHandler = nil
    end
    if self._UserInfoHandler ~= nil then
        EventSystem:RemoveEvent(self._UserInfoHandler)
        self._UserInfoHandler = nil
    end

end

-------------------------------------------------------------------------------------------------------------
--刷新UI
function UILogin:RefreshUIUserInfo()
    

end

-------------------------------------------控件逻辑处理--------------------------------------------
--登陆界面注册按钮点击
function UILogin:OnLogonRegClick()
    self._LoginPanel:setVisible(false)
    self._RegPanel:setVisible(true)

end

--登陆逻辑处理
function UILogin:OnLoginTouch(eventType)
	--dump(eventType)
	if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        local netSystem = NetSystem
		local loginInstance = UISystem:GetUIInstance(UIType.UIType_Login)
        local textAccount = loginInstance._AccountTextField:getString()
        local textPassword = loginInstance._PasswordTextField:getString()

        local loginData = ServerDataManager._LoginServerData
        loginData._UserAccount = textAccount
        loginData._Password = textPassword
        loginData._CurActionType = 0
        --用户名合法性检查
        if string.len(textAccount) == 0 then
            local tipContent = ChineseTable["CT_Login_AccountNULL"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        local resultStr = string.match(textAccount, "[^A-Za-z0-9_]+")
        if resultStr ~= nil then
            local tipContent = ChineseTable["CT_Login_AccountChinese"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        --密码合法性检查
        if string.len(textPassword) == 0 then
            local tipContent = ChineseTable["CT_Login_PasswordNULL"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        if string.len(textPassword) < 6 then
            local tipContent = ChineseTable["CT_Login_PasswordLen"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end

        if netSystem:IsConnectLoginServer() == true then
            local beginTime = os.clock()
            local csLoginPacket = (require "Main.NetSystem.Packet.CSLoginPacket").new()
            csLoginPacket._szAccounts = textAccount
            local encryptInstance = LuaLib.CEncrypt:new()
            local passwordStr = encryptInstance:MD5EncryptString32(textPassword)
            csLoginPacket._szPassword33 = passwordStr
            local endedTime = os.clock()
            print("use time", endedTime - beginTime)
            netSystem:SendPacketToLoginServer(csLoginPacket)
        else
            netSystem:ConnectLoginServer()
        end

        --printInfo("UILogin:OnLoginTouch %s %s", textAccount, textPassword)
	end
end
--注册按钮点击
function UILogin:OnRegisterTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        local loginInstance = UISystem:GetUIInstance(UIType.UIType_Login)
        loginInstance:OnLogonRegClick()
    end
end

--注册取消点击
function UILogin:OnRegisterCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        local loginInstance = UISystem:GetUIInstance(UIType.UIType_Login)
        loginInstance._RegPanel:setVisible(false)
    end
end

--提交注册touch
function UILogin:OnRegisterCommitTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        print(OnRegisterCommitTouch)
        local netSystem = NetSystem
        local loginInstance = UISystem:GetUIInstance(UIType.UIType_Login)
        local textAccount = loginInstance._RegAccountTxtField:getString()
        local textPassword = loginInstance._RegPasswordTxtField:getString()
        local textconfirmpwd = loginInstance._RegConfirmTxtField:getString()
        local loginData =  ServerDataManager._LoginServerData
        loginData._CurActionType = 1
        loginData._RegAccount = textAccount
        loginData._RegPwd = textPassword
        --用户名合法性检查
        if string.len(textAccount) == 0 then
            local tipContent = ChineseTable["CT_Login_AccountNULL"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        local resultStr = string.match(textAccount, "[^A-Za-z0-9_]+")
        if resultStr ~= nil then
            local tipContent = ChineseTable["CT_Login_AccountChinese"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        --密码合法性检查
        if string.len(textPassword) == 0 then
            local tipContent = ChineseTable["CT_Login_PasswordNULL"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        if string.len(textPassword) < 6 then
            local tipContent = ChineseTable["CT_Login_PasswordLen"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end
        if textconfirmpwd ~= textPassword then
            local tipContent = ChineseTable["CT_Login_RegPwdNotSame"]
            UISystem:ShowMessageBoxOne(tipContent)
            return
        end

        if netSystem:IsConnectLoginServer() == true then
            local beginTime = os.clock()
            local csRegPacket = (require "Main.NetSystem.Packet.CSRegisterPacket").new()
            csRegPacket._szAccounts = textAccount
            local encryptInstance = LuaLib.CEncrypt:new()
            local passwordStr = encryptInstance:MD5EncryptString32(textPassword)
            csRegPacket._szLogonPass = passwordStr
            csRegPacket._szInsurePass = passwordStr
            local endedTime = os.clock()
            print("use time", endedTime - beginTime)
            netSystem:SendPacketToLoginServer(csRegPacket)
        else
            netSystem:ConnectLoginServer()
        end

        --printInfo("UILogin:OnLoginTouch %s %s", textAccount, textPassword)
    end
end
--帐号登陆
function UILogin:OnAccountLoginTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        local loginInstance = UISystem:GetUIInstance(UIType.UIType_Login)
        loginInstance._RegPanel:setVisible(false)
        loginInstance._LoginPanel:setVisible(true)
    end
end
--
function UILogin:OnAccountCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        local loginInstance = UISystem:GetUIInstance(UIType.UIType_Login)
        loginInstance._LoginPanel:setVisible(false)
    end
end

-----------------------------------------------事件处理 --------------------------------------
--登录服务器连接成功，发送登录包或者注册包
function UILogin.OnServerConnected(param)
    if param._usedata.name == "LoginSocket" then
        local loginData = ServerDataManager._LoginServerData
        --登陆
        local netSystem = NetSystem
        if loginData._CurActionType == 0 then
            local beginTime = os.clock()
            local netSystem = NetSystem
            local csLoginPacket = (require "Main.NetSystem.Packet.CSLoginPacket").new()
            csLoginPacket._szAccounts = loginData._UserAccount
            local encryptInstance = LuaLib.CEncrypt:new()
            local passwordStr = encryptInstance:MD5EncryptString32(loginData._Password)
            csLoginPacket._szPassword33 = passwordStr
            local endedTime = os.clock()
            netSystem:SendPacketToLoginServer(csLoginPacket)
            print("csLoginPacket use time", endedTime - beginTime)
        --注册
        else
            local beginTime = os.clock()
            local csRegPacket = (require "Main.NetSystem.Packet.CSRegisterPacket").new()
            csRegPacket._szAccounts = loginData._RegAccount
            local textPassword = loginData._RegPwd
            local encryptInstance = LuaLib.CEncrypt:new()
            local passwordStr = encryptInstance:MD5EncryptString32(textPassword)
            csRegPacket._szLogonPass = passwordStr
            csRegPacket._szInsurePass = passwordStr
            local endedTime = os.clock()
            print("use time", endedTime - beginTime)
            netSystem:SendPacketToLoginServer(csRegPacket)
        end
    end
end

--用户信息改变
function UILogin.OnSelfInfoChange()
    local loginUIInstance = UISystem:GetUIInstance(UIType.UIType_Login)
    loginUIInstance:RefreshUIUserInfo()
end

return UILogin


