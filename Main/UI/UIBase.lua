----
-- 文件名称：UIBse.lua
-- 功能描述：UI父类，处理UI通用逻辑
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-24
--  修改：

local UIBase = class("UIBase");
local seekNodeByName = seekNodeByName
--构造
function UIBase:ctor()
    --实际的资源文件名
    self._RealResourceName = ""
    --根节点
    self._RootUINode = nil
    
end
-------------------------------------------- 所有UI必须实现的四个接口, Load  Unload Open Close begin --------------------------------------------
--Load
function UIBase:Load(resourceName)
    if self._RootUINode == nil then
        self._RootUINode = cc.CSLoader:createNode(resourceName)
        self._RealResourceName = resourceName
        if self._RootUINode ~= nil then
            self._RootUINode:retain()
            --调试用
            self._RootUINode:setTag(666)
        end
    end
end

--Unload
function UIBase:Unload()
    if self._RootUINode ~= nil then
        self._RootUINode:release()
        self._RootUINode = nil
        print("UIBase:Unload  ", self._RealResourceName)
    end
    
end

--Open 控件内容初始化
function UIBase:Open()


end

--Close 
function UIBase:Close()
    
end
-------------------------------------------- 所有UI必须实现的四个接口, Load  Unload Open Close end --------------------------------------------

--通过控件名称获取UI控件
function UIBase:GetUIByName(controlName)
    if self._RootUINode == nil then
        return
    end
    return seekNodeByName(self._RootUINode, controlName)
end
--获取根节点
function UIBase:GetUIRootNode()
    return self._RootUINode
end

--隐藏
function UIBase:SetVisible(isShow)
    if self._RootUINode == nil then
        return
    end
    self._RootUINode:setVisible(isShow)
end

return UIBase
