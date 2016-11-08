----
-- 文件名称：GameUpdate.lua
-- 功能描述：游戏在线更新
-- 文件说明：此逻辑在正式测试后，永远不会改动，以确保游戏更新过程不会出错（因为若更新逻辑改动，
--           在下载更新文件时突然退出，且下载的文件与更新相关，很可能会导致程序错误）
-- 作    者：王雷雷
-- 创建时间：2016-10-14
--  修改:
---本地MD5文件名： LocalMD5.xml

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local luaj 
if targetPlatform == cc.PLATFORM_OS_ANDROID  then
   luaj =  require "cocos.cocos2d.luaj"
end
local stringFormat = string.format
local userDefault = cc.UserDefault:getInstance()
local ACTIVITY_CLASS_NAME = "org/cocos2dx/lua/AppActivity"
local COCOS2D_HELPER_CLASS = "org/cocos2dx/lib/Cocos2dxHelper"

local fileUtils = cc.FileUtils:getInstance()
local writePath = fileUtils:getWritablePath()

local GameUpdate = class("GameUpdate")

--构造
function GameUpdate:ctor()
    --Scene
     self._RootScene = nil
     --LuaLib.ClientUpdate
     self._UpdateInstance = nil
     --事件Handler
     self._UpdateHandler = nil
     --资源版本号
     self._ResVersion = 0
     --

end

--初始化
function GameUpdate:Init()
	--display为cocos framwwork的
    self._RootScene = display.newScene()
    display.runScene(self._RootScene)
    self._RootScene:retain()
    --初始化UI相关
    local uiRootNode = UISystem:GetUIRootNode()
    if uiRootNode ~= nil then  
        uiRootNode:removeFromParent(false)
        self._RootScene:addChild(uiRootNode)
    end
    UISystem:CloseAllUI()
    UISystem:OpenUI(UIType.UIType_Update)

    self._UpdateInstance = LuaLib.ClientUpdate:GetInstance()

    if targetPlatform == cc.PLATFORM_OS_ANDROID  then
        self._UpdateInstance:SetURL("http://update.qp178.com:8088/android/Update.xml")
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local ok,ret  = luaj.callStaticMethod(COCOS2D_HELPER_CLASS,"GetCacheDir",args,sigs)
        if ok then
            print("GetExternalDir ", ret)
            ret = string.format("%s/", ret)
            self._UpdateInstance:SetAPKDir(ret)
        end
    end
    --资源版本号，默认为app版本号，如果更新过，读取 "resVersion"
    self._ResVersion = self._UpdateInstance:GetAppVersion()
    local saveVersion = userDefault:getIntegerForKey("ResVersion", 0)
    if saveVersion ~= 0 then
        self._ResVersion = saveVersion
    end

    self._UpdateInstance:CheckVersionUpdate()

    self._UpdateHandler = EventSystem:AddEvent("ClientUpdateEvent", self.OnUpdateEvent)
end

--销毁 
function GameUpdate:Destroy()
    if self._RootScene ~= nil then
    	self._RootScene:release()
    	self._RootScene = 0
    end
    if self._UpdateHandler ~= nil then
        EventSystem:RemoveEvent(self._UpdateHandler)
        self._UpdateHandler = nil
    end
end

--清理Patch目录,所有更新下来的资源
function GameUpdate:CleanPatch()
    userDefault:setIntegerForKey("ResVersion", 0)
    local writePatch = string.format("%sPatch/", writePath)
    local ok = fileUtils:removeDirectory(writePatch)
    if not ok then
        print("CleanPatch fail ")
    end
end

--帧更新
function GameUpdate:Update(delta)
    
end

 UpdateEventCode =
{
    READY_MD5LIST = -3,
    READY_VER_REQUEST = -2,
    READY_DOWNLOAD = -1,
    ERROR_VERSION_REQUEST = 0,
    ERROR_VERSION_XML = 1,
    ERROR_MD5LIST_REQUEST = 2,
    ERROR_MD5LIST_XML = 3,
    ERROR_APK_REQUEST = 4,
    ERROR_DOWNLOAD = 5,
    ERROR_LOCALMD5_XML = 6,
    VERSION_INFO = 7,
    MD5LIST_GET = 8,
    PROGRESS_MD5_DOWNLOAD = 9,
    PROGRESS_APK_DOWNLOAD = 10,
}

--请求版本的更新内容(0:完整包更新 1：资源更新)
local function RequestVersionContent(updateType, contentURL, isForce)
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("GET", contentURL)

    local function onReadyStateChanged()
        if xhrBag.readyState == 4 then
            if xhrBag.status ~= 200 then
               
                return
            end
            if xhrBag.response == nil then
              
                return
            end
            local contentStr = xhrBag.response
            local updateUI = UISystem:GetUIInstance(UIType.UIType_Update)
            updateUI:ShowUpdateTip(updateType, contentStr, isForce)
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    xhrBag:send()
     
end

--更新事件处理
function GameUpdate.OnUpdateEvent(event)

    if Game:GetCurrentGameState() ~= GameState.GameState_Update then
        return
    end
    local eventCode = event:GetEventCode()
    print("OnUpdateEvent ", eventCode)
    local self = Game:GetCurStateInstance()
    local updateUI = UISystem:GetUIInstance(UIType.UIType_Update)
    --服务器版本信息
    if eventCode == UpdateEventCode.VERSION_INFO then
       local verServerInfo =  self._UpdateInstance:GetServerUpdateInfo()
       --判断app版本号
       local newAppVer = verServerInfo:GetAppVersion()
       local curAppVer = self._UpdateInstance:GetAppVersion()
       print("newAppVer ", newAppVer, "curAppVer", curAppVer)
       local isForce = false
       if curAppVer <  newAppVer then
            if curAppVer < verServerInfo:GetAppMinVersion() then
                isForce = true
            end
            RequestVersionContent(0, verServerInfo:GetAppContentURL(), isForce)
            return
       end
       --判断资源版本号
       local newResVer = verServerInfo:GetResVersion()
       if self._ResVersion < newResVer then
            if self._ResVersion < verServerInfo:GetResMinVersion() then
                 isForce = true
            end
            RequestVersionContent(1, verServerInfo:GetMD5ContentURL(), isForce)
            return
       end
       Game:SetGameState(GameState.GameState_Login)
    --资源下载进度   
    elseif eventCode == UpdateEventCode.PROGRESS_MD5_DOWNLOAD then
        local percent = self._UpdateInstance:GetPercent()
        updateUI:UpdateProgress(percent)
        if percent >= 100 then
            userDefault:setIntegerForKey("MD5State", 1)
            --第一次MD5更新，添加资源搜索路径
            local saveVersion = userDefault:getIntegerForKey("ResVersion", 0)
            if saveVersion == 0 then
                fileUtils:purgeCachedEntries()
                print("saveVersion ------", saveVersion)
                local writePath = fileUtils:getWritablePath()
                local writePatch = stringFormat("%sPatch/", writePath)
                fileUtils:addSearchPath(writePatch, true)
                local resPatch = stringFormat("%sPatch/res/", writePath)
                local srcPatch = stringFormat("%sPatch/src/", writePath)
                fileUtils:addSearchPath(resPatch, true)
                fileUtils:addSearchPath(srcPatch, true)
                print("writePath: ---------------", writePath)
            end
            --dump(Game, "Game Before")
            --重新加载Lua脚本
            ResetLoadedLua()
            ResetGlobal()
            require("Main.MyMain")
            MyMain()
            --dump(Game, "Game after")
            Game:SetGameState(GameState.GameState_Login)
            --写最新版本号：
            local verServerInfo = self._UpdateInstance:GetServerUpdateInfo()
            userDefault:setIntegerForKey("ResVersion", verServerInfo:GetResVersion())
            --重命名文件
            local writePatch = stringFormat("%sPatch/", writePath)
            fileUtils:renameFile(writePatch, "serverMD5.xml", "LocalMD5.xml")
        end
    --APK下载进度
    elseif eventCode == UpdateEventCode.PROGRESS_APK_DOWNLOAD then
        local percent = self._UpdateInstance:GetPercent()
        updateUI:UpdateProgress(percent)
        if percent >= 100 then 
            --安卓下的安装APK
            if targetPlatform == cc.PLATFORM_OS_ANDROID  then
                local apkPath = self._UpdateInstance:GetAPKDir()
                local writePath = stringFormat("%stempGame.apk", apkPath)
                local args = {writePath}
                local sigs = "(Ljava/lang/String;)I"
                local ok,ret  = luaj.callStaticMethod(ACTIVITY_CLASS_NAME,"InstallPatch",args,sigs)
                if not ok then
                    print("InstallPatch luaj error:", ret)
                else
                    print("InstallPatch The ret is:", ret)
                    --由于不确定新的安装包会不会清理老的更新资源，手动清理下已下载的所有更新资源
                    self:CleanPatch()
                end
            end
        end
    --资源下载
    elseif eventCode == UpdateEventCode.MD5LIST_GET then
        self._UpdateInstance:StartDownloadChangeFile()
        userDefault:setIntegerForKey("MD5State", 0)
        updateUI:SetStateText(eventCode)

    --下载出错
    elseif eventCode == UpdateEventCode.ERROR_DOWNLOAD then
        local fileName = self._UpdateInstance:GetErrorString()
        updateUI:SetStateText(eventCode, fileName)
    end

end

return GameUpdate

