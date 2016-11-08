----
-- 文件名称：UIUpdate.lua
-- 功能描述：游戏更新UI
-- 文件说明：游戏更新UI
-- 作    者：王雷雷
-- 创建时间：2016-10-14
--  修改

--此处文字 特殊，写在此文件中，其它文件的不要这样做
local function GetTextByCode(state, param)
    if state == UpdateEventCode.READY_REQUEST then
        return "版本检查中......"
    elseif state == UpdateEventCode.READY_MD5LIST then
        return "请求文件......"
    elseif state ==  UpdateEventCode.ERROR_VERSION_REQUEST  then
        return "请求版本信息失败"
    elseif state == UpdateEventCode.ERROR_MD5LIST_REQUEST then
        return "请求文件列表失败"
    elseif state == UpdateEventCode.READY_DOWNLOAD then
        return "下载安装包中，请耐心等待......"
    elseif state == UpdateEventCode.MD5LIST_GET then
        return "下载资源文件，请耐心等待......"
    elseif state == UpdateEventCode.ERROR_DOWNLOAD then
        return "下载文件出错：" .. param
    end
end



local UIBase = require("Main.UI.UIBase")

local UIUpdate = class("UIUpdate", UIBase)

--构造(只做成员初始化)
function UIUpdate:ctor()
	UIBase.ctor(self)
    --更新面板
    self._UpdatePanel = nil
    --提示框
    self._TipPanel = nil
    --状态文字
    self._StateText = nil
    --更新内容文字
    self._ContentText = nil
    --确定，取消按钮
    self._TipOkBtn = nil
    self._TipCancelBtn = nil
    --进度条
    self._ProgressBar = nil


    ------------
    self._UpdateType = 0
    self._OkBtnPosX = 0
    self._CancelBtnPosX = 0
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIUpdate:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
    self._UpdatePanel = self:GetUIByName("Panel_Update")
    self._TipPanel = self:GetUIByName("Panel_Tip")
    self._StateText = self:GetUIByName("Text_Update")
    self._ContentText = self:GetUIByName("Text_UpdateContent")
    self._ProgressBar = self:GetUIByName("LoadingBar_Update")
    self._TipOkBtn = self:GetUIByName("Button_OK")
    self._TipCancelBtn = self:GetUIByName("Button_Cancel")
    self._TipOkBtn:addTouchEventListener(self.OnUpdateOkTouch)
    self._TipCancelBtn:addTouchEventListener(self.OnUpdateCancelTouch)
    self._OkBtnPosX = self._TipOkBtn:getPositionX()
    self._CancelBtnPosX = self._TipCancelBtn:getPositionX()
end

--卸载
function UIUpdate:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UIUpdate:Open()
	UIBase.Open(self)

    self._TipPanel:setVisible(false)
    self._UpdatePanel:setVisible(true)
    self._ProgressBar:setVisible(false)
    self._StateText:setString(GetTextByCode(UpdateEventCode.READY_REQUEST))
end

--关闭
function UIUpdate:Close()
	UIBase.Close(self)
   
end

--更新提示框
function UIUpdate:ShowUpdateTip(updateType, contentStr, isForce)
    self._TipPanel:setVisible(true)
    self._ContentText:setString(contentStr)
    self._StateText:setString("")
    self._UpdateType = updateType
    if isForce == true then
        self._TipOkBtn:setVisible(true)
        self._TipOkBtn:setPositionX((self._OkBtnPosX + self._CancelBtnPosX) / 2)
        self._TipCancelBtn:setVisible(false)
    else
        self._TipOkBtn:setVisible(true)
        self._TipOkBtn:setPositionX(self._OkBtnPosX)
        self._TipCancelBtn:setVisible(true)
        self._TipCancelBtn:setPositionX(self._CancelBtnPosX)
    end
end

--更新进度
function UIUpdate:UpdateProgress(progress)
    self._ProgressBar:setPercent(progress)
end

--设置状态
function UIUpdate:SetStateText(eventCode, param)
    print("UIUpdate:SetStateText  ", eventCode, param)
    self._StateText:setString(GetTextByCode(eventCode, param))
end

--确定
function UIUpdate.OnUpdateOkTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local updateUI = UISystem:GetUIInstance(UIType.UIType_Update)
        updateUI._TipPanel:setVisible(false)
        local updateInstance = LuaLib.ClientUpdate:GetInstance()
        --完整包
        if updateUI._UpdateType == 0 then
            local targetPlatform = cc.Application:getInstance():getTargetPlatform()
            --安卓下
            if targetPlatform == cc.PLATFORM_OS_ANDROID  then
                updateInstance:StartAPKDownload()
                updateUI:SetStateText(UpdateEventCode.READY_DOWNLOAD)
            --PC下 
            elseif targetPlatform == cc.PLATFORM_OS_WINRT or targetPlatform == cc.PLATFORM_OS_WP8 or targetPlatform == cc.PLATFORM_OS_WINDOWS then
                 Game:SetGameState(GameState.GameState_Login)
            --IOS
            else

            end
            updateUI._ProgressBar:setVisible(true)
            updateUI._ProgressBar:setPercent(0)
        --资源更新 
        elseif updateUI._UpdateType == 1  then
            updateInstance:RequestServerMD5Res()
            updateUI._StateText:setString(GetTextByCode(UpdateEventCode.READY_MD5LIST))
            updateUI._ProgressBar:setVisible(true)
            updateUI._ProgressBar:setPercent(0)
        end
    end
end

--取消
function UIUpdate.OnUpdateCancelTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        Game:SetGameState(GameState.GameState_Login)
    end
end

return UIUpdate


