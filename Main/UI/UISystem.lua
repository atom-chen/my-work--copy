----
-- 文件名称：UISystem.lua
-- 功能描述：UI的管理类
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-28
--  修改：

require("Main.UI.UITypeDefine")

local stringFormat = string.format
local UISystem = class("UISystem")
local UIScriptData = UIScriptData
--构造
function UISystem:ctor()
    --UI Table
    self._UITable = 0
    --所有UI的根节点
    self._UIRootNode = nil
end

--初始化
function UISystem:Init()
	if self._UITable == 0 then
		self._UITable = {}
	end
	if self._UIRootNode == nil then
		self._UIRootNode = cc.Node:create()
		self._UIRootNode:retain()
	end 
end

--销毁
function UISystem:Destroy()
	if self._UIRootNode ~= nil then
		self._UIRootNode:release()
		self._UIRootNode = nil
	end 

end
--加载UI
function UISystem:LoadUI(uiType)	
	local uiInfoData = UIScriptData[uiType]
	if uiInfoData == nil then
		printError("UISystem:LoadUI invalid uiType: %d, is it in  UITypeDefine.lua ??", uiType)
	end
	print("LoadUI", uiType)
	if self._UITable[uiType] == nil then
		local scriptPath = stringFormat("Main.UI.LogicUI.%s", uiInfoData.UIScript)
        local newUI = require(scriptPath)
        local newUIInstance = newUI.new()
        newUIInstance:Load(uiInfoData.UICSBName)
        self._UITable[uiType] = newUIInstance
        --add
        self._UIRootNode:addChild(newUIInstance:GetUIRootNode())
	end
	return self._UITable[uiType]
end

--卸载UI
function UISystem:UnloadUI(uiType)
	local uiInstance = self._UITable[uiType]
	if uiInstance == nil then
		return
	end
	local uiRootNode = uiInstance:GetUIRootNode()
	if uiRootNode ~= nil then
		uiRootNode:removeFromParent()
	end
	uiInstance:Unload()
	self._UITable[uiType] = nil
end

--打开UI
function UISystem:OpenUI(uiType, param)
	print("UISystem:OpenUI ", uiType)
	local currentUI = self._UITable[uiType]
	if currentUI == nil then
		currentUI = self:LoadUI(uiType)
	end
	currentUI:Open(param)
	local currentUIRootNode = currentUI:GetUIRootNode()
	if currentUIRootNode ~= nil then
        currentUIRootNode:removeFromParent(false)
        self._UIRootNode:addChild(currentUIRootNode)
	end
	return currentUI
end
--关闭UI
function UISystem:CloseUI(uiType)
	local currentUI = self._UITable[uiType]
	if currentUI == nil then
		return
	end
	print("UISystem:CloseUI ", uiType)
	currentUI:Close()
	local currentUIRootNode = currentUI:GetUIRootNode()
	currentUIRootNode:removeFromParent(false)
end

--关闭所有UI
function UISystem:CloseAllUI()
    for k, v in pairs(self._UITable)do
        self:CloseUI(k)
    end
end
--获取UI根节点
function UISystem:GetUIRootNode()
    return self._UIRootNode
end

--获取UI
function UISystem:GetUIInstance(uiType)
    return self._UITable[uiType]
end


------
function UISystem:ShowMessageBoxOne(content, callback)
	local uiMessageBox = self:OpenUI(UIType.UIType_MessageBox)
	uiMessageBox:SetButtonType(1)
	uiMessageBox:ShowText(content, callback)
end

return UISystem



