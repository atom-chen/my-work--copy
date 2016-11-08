----
-- 文件名称：GameLobby.lua
-- 功能描述：游戏登录流程
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-11
--  修改：

local GameLobby = class("GameLobby")


function GameLobby:ctor()
    --Scene
    self._RootScene = nil
    
end

--初始化
function GameLobby:Init()
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
    SoundPlay:StopAllSound()
    SoundPlay:PlaySoundByID(SoundDefine.Lobby_BgMusic)
    UISystem:OpenUI(UIType.UIType_Lobby)
    
end

--销毁
function GameLobby:Destroy()
    print("GameLobby:Destroy")
    if self._RootScene ~= nil then
        self._RootScene:removeAllChildren(true)
        self._RootScene:release()
        self._RootScene = nil
    end
    
end

--
function GameLobby:Update()
    
end

return GameLobby