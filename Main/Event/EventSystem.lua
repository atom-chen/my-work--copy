----
-- 文件名称：EventSystem.lua
-- 功能描述：事件系统
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-30
--  修改：


local EventSystem = class("EventSystem")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function EventSystem:ctor()

end

--添加事件
function EventSystem:AddEvent(eventName, listener)
    local newListener = cc.EventListenerCustom:create(eventName,listener)
    eventDispatcher:addEventListenerWithFixedPriority(newListener, 1)
    return newListener
end

--移除事件
function EventSystem:RemoveEvent(newListener)
    eventDispatcher:removeEventListener(newListener) 
end
--移除事件
function EventSystem:RemoveEventByName(eventName)
    eventDispatcher:removeCustomEventListeners(eventName)
end

--触发事件
function EventSystem:DispatchEvent(eventName, userData)
    local event = cc.EventCustom:new(eventName)
    event._usedata = userData
    eventDispatcher:dispatchEvent(event)
end

return EventSystem