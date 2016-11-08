----
-- 文件名称：GameLogo.lua
-- 功能描述：游戏Logo
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-9-13
--  修改：

local GameLogo = class("GameLogo")

--构造
function GameLogo:ctor()
    --Scene
     self._RootScene = nil
end

--初始化
function GameLogo:Init()
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
    UISystem:OpenUI(UIType.UIType_Logo)
    
end

--销毁 
function GameLogo:Destroy()
    if self._RootScene ~= nil then
    	self._RootScene:release()
    	self._RootScene = 0
    end
end

--帧更新
function GameLogo:Update(delta)
    
end

return GameLogo

