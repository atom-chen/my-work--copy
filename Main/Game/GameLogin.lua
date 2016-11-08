----
-- 文件名称：GameLogin.lua
-- 功能描述：游戏登录流程
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-24
--  修改：

local GameLogin = class("GameLogin")

--构造
function GameLogin:ctor()
    --Scene
     self._RootScene = nil
     --当前的粒子特效
end

--初始化
function GameLogin:Init()
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
    UISystem:OpenUI(UIType.UIType_Login)
    SoundPlay:StopAllSound()
    SoundPlay:PlaySoundByID(SoundDefine.Logon_BgMusic)
    
end

--销毁 
function GameLogin:Destroy()
    if self._RootScene ~= nil then
    	self._RootScene:release()
    	self._RootScene = 0
    end
end

--帧更新
local testTime = 0
function GameLogin:Update(delta)

end

return GameLogin

