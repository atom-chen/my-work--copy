----
-- 文件名称：UIGameLoading.lua
-- 功能描述：捕鱼游戏加载进度条
-- 文件说明：捕鱼游戏加载进度条
-- 作    者：王雷雷
-- 创建时间：2016-9-13
--  修改

local UIBase = require("Main.UI.UIBase")

local UIGameLoading = class("UIGameLoading", UIBase)

--构造(只做成员初始化)
function UIGameLoading:ctor()
	UIBase.ctor(self)
    --UI控件
    self._ImageBg = nil
    self._ProgBar = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIGameLoading:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
    self._ImageBg = self:GetUIByName("Image_bg")
    self._ProgBar = self:GetUIByName("LoadingBar_load")

end

--卸载
function UIGameLoading:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UIGameLoading:Open()
	UIBase.Open(self)
    
end

--关闭
function UIGameLoading:Close()
	UIBase.Close(self)

end

-------------------------------------------------------------------------------------------------------------
--设置背景图片
function UIGameLoading:SetBgImage(imagePath)
    self._ImageBg:loadTexture(imagePath)
end
--设置进度
function UIGameLoading:SetProgress(percent)
    self._ProgBar:setPercent(percent)
end
-------------------------------------------控件逻辑处理--------------------------------------------

return UIGameLoading


