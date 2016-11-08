----
-- 文件名称：UILogo.lua
-- 功能描述：游戏Logo展示
-- 文件说明：游戏Logo
-- 作    者：王雷雷
-- 创建时间：2016-9-13
--  修改

local UIBase = require("Main.UI.UIBase")

local UILogo = class("UILogo", UIBase)

--构造(只做成员初始化)
function UILogo:ctor()
	UIBase.ctor(self)
    --
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UILogo:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值

end

--卸载
function UILogo:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UILogo:Open()
	UIBase.Open(self)
    --layer 
    self._RootUINode:setCascadeOpacityEnabled(true)
    self._RootUINode:setOpacity(0)
    local fadeAction = cc.FadeIn:create(0.6)
    local delay = cc.DelayTime:create(2)
    local callFunc = cc.CallFunc:create(self.OnAnimFinish)
    local seq = cc.Sequence:create(fadeAction, delay, callFunc)
    self._RootUINode:runAction(seq)
end

--关闭
function UILogo:Close()
	UIBase.Close(self)
   
end

--动画完成的回调
function UILogo:OnAnimFinish()
    Game:SetGameState(GameState.GameState_Update)
end

return UILogo


