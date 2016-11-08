----
-- 文件名称：UIFishHelp.lua
-- 功能描述：捕鱼游戏 帮助界面 
-- 文件说明：捕鱼游戏 帮助界面 
-- 作    者：王雷雷
-- 创建时间：2016-11-3
--  修改
local mathCeil = math.ceil
local mathMax = math.max
local tostring = tostring
local UIBase = require("Main.UI.UIBase")

local FishItemWidth = 165
local FishItemHeight = 90
local UIFishHelp = class("UIFishHelp", UIBase)
local GameFishManager = require("Main.Logic.GameFishManager")
--构造(只做成员初始化)
function UIFishHelp:ctor()
	UIBase.ctor(self)
    --
   self._scrollview = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIFishHelp:Load(resourceName)
	UIBase.Load(self, resourceName)
    --print("UIFishHelp:Load")
	--控件赋值
	local closeBtn = self:GetUIByName("Button_Close")
    closeBtn:addTouchEventListener(self.OnCloseTouch)
    local scrollview = self:GetUIByName("ScrollView_FishItem")
    local gameSceneData = ServerDataManager:GetGameSceneData()
    local viewSize = scrollview:getContentSize()
    local fishList = gameSceneData._wSpriteID
    local scrollSize = cc.size(viewSize.width, 0)
    if fishList ~= nil then
        local count = #fishList
        --5列
        local colCount = 5
        local row = 0
        local col = 0
        --先创建一个，取出宽高,计算最大高度，以实现前面的鱼在上面 maxHeight - 
        local newItem =  cc.CSLoader:createNode("CSD/UI/UIFishHelpItem.csb")
        local size = newItem:getContentSize()
        local maxHeight = mathCeil(count / colCount) * size.height
        for i = 1, count do
            row = mathCeil(i / colCount)
            col = i % colCount
            if col == 0 then
                col = colCount
            end
            newItem =  cc.CSLoader:createNode("CSD/UI/UIFishHelpItem.csb")
            if newItem ~= nil then
                newItem:setTag(i)
                scrollview:getInnerContainer():addChild(newItem)
                newItem:setPosition(size.width * (col - 1), maxHeight - row  * size.height)
            end
        end
        scrollSize.height = maxHeight
        scrollview:setInnerContainerSize(scrollSize)
    end
    self._scrollview = scrollview
end

--卸载
function UIFishHelp:Unload()
	UIBase.Unload(self)
    --卸载掉 UIFish
    self._scrollview = nil
end

--打开(UI内容初始化)
function UIFishHelp:Open()
	UIBase.Open(self)
    self:InitHelpContent()
end

--关闭
function UIFishHelp:Close()
	UIBase.Close(self)
end

-------------------------------------------------------------------------------------------------------------
--copy from GameFish.lua
local FishAttrib = 
{
    enFreeze=0x01, --定屏
    enBomb=0x02,  --炸弹
    enBoss=0x04,  --动态倍率鱼
    enSameDie=0x08, --同类炸弹
    enLine=0x10, --连线鱼
    enRangeBomb=0x20, --范围炸弹
    enLighting=0x40, -- 闪电鱼
    enJumpBomb=0x80,  --超级炸弹
}

--初始化帮助界面
function UIFishHelp:InitHelpContent()
    --Fish
    local fishCon = self._scrollview:getInnerContainer()
    local fishCount = self._scrollview:getChildrenCount()
    local gameSceneData = ServerDataManager:GetGameSceneData()
    for i = 1, fishCount do
        local item =  fishCon:getChildByTag(i)   
        local text = item:getChildByName("Text_Count")
        local fishRootNode = item:getChildByName("Node_Fish")
        local childCount = fishRootNode:getChildrenCount()
        --没有初始化过，进行初始化
        if childCount == 0 then
            local spriteID = gameSceneData._wSpriteID[i]
            --print("InitHelpContent fish:", spriteID, i)
            if spriteID  ~= 0 then
                local newLockFish = GameFishManager:CreateSceneUIFish(spriteID)
                local fishNode = newLockFish:GetFishNode()
                if fishNode ~= nil then
                    local fishRect =  fishNode:getBoundingBox()
                    local scale = 0.3
                    if FishItemWidth ~= 0 and FishItemHeight ~= 0 then
                       local xScale =  fishRect.width / FishItemWidth
                       local yScale = fishRect.height / FishItemHeight
                       if xScale < 1 and  yScale < 1 then
                            scale = 0.9
                       else
                            local maxScale = mathMax(xScale, yScale)
                            scale = 1 / maxScale
                       end
                    end 
                    fishRootNode:addChild(fishNode)

                    fishNode:setScale(scale * fishNode:getScaleX())
                    fishNode:setTag(newLockFish:GetClientID())
                end
                local cbProperty = gameSceneData._cbProperty[i]
                --print("judge ---", i, cbProperty)
                local isFreeze = (bitLib.band(cbProperty, FishAttrib.enFreeze) ~= 0)
                local isBomb = (bitLib.band(cbProperty, FishAttrib.enBomb) ~= 0)
                local isRange = (bitLib.band(cbProperty, FishAttrib.enRangeBomb) ~= 0)
                --print("judge result ", i, isFreeze, isBomb, isRange, cbProperty, FishAttrib.enFreeze, FishAttrib.enBomb, FishAttrib.enRangeBomb)
                if isFreeze  or isBomb  or isRange  then
                    local fishName = ""
                    if isFreeze then
                        fishName = ChineseTable["CT_FishGame_Freeze"]
                    elseif isBomb then
                        fishName = ChineseTable["CT_FishGame_BombFish"]
                    elseif isRange then
                        fishName = ChineseTable["CT_FishGame_BombRange"]
                    end
                    text:setString(fishName)
                else
                    local multiple = tostring(gameSceneData._wFishMultiple[i])
                    text:setString(multiple)
                end

            end 
        end
    end
end
--

-------------------------------------------控件逻辑处理--------------------------------------------
--关闭
function UIFishHelp:OnCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:CloseUI(UIType.UIType_FishHelp)
    end
end

return UIFishHelp


