----
-- 文件名称：UIFishQuit.lua
-- 功能描述：捕鱼游戏 结算界面 退出界面
-- 文件说明：捕鱼游戏 结算界面 
-- 作    者：王雷雷
-- 创建时间：2016-11-4
--  修改
local mathCeil = math.ceil
local mathMax = math.max
local tostring = tostring
local UIBase = require("Main.UI.UIBase")

local FishItemWidth = 165
local FishItemHeight = 90

local UIFishQuit = class("UIFishQuit", UIBase)
local GameFishManager = require("Main.Logic.GameFishManager")
--构造(只做成员初始化)
function UIFishQuit:ctor()
	UIBase.ctor(self)
    --
   self._scrollview = nil
   --弱引用
   self._MainScene = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIFishQuit:Load(resourceName)
	UIBase.Load(self, resourceName)
    --print("UIFishQuit:Load")
	--控件赋值
	local closeBtn = self:GetUIByName("Button_Close")
    closeBtn:addTouchEventListener(self.OnCloseTouch)
    local quitBtn = self:GetUIByName("Button_QuitGame")
    quitBtn:addTouchEventListener(self.OnQuitTouch)
    
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
        local scale = 0.9
        local newItem =  cc.CSLoader:createNode("CSD/UI/UIFishHelpItem.csb")
        local size = newItem:getContentSize()
        local maxHeight = mathCeil(count / colCount) * size.height * scale
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
                newItem:setScale(scale)
                newItem:setPosition(size.width * scale * (col - 1), maxHeight - row  * size.height * scale )
            end
        end
        scrollSize.height = maxHeight
        scrollview:setInnerContainerSize(scrollSize)
    end
    self._scrollview = scrollview
end

--卸载
function UIFishQuit:Unload()
	UIBase.Unload(self)
    --卸载掉 UIFish
    self._scrollview = nil
end

--打开(UI内容初始化)
function UIFishQuit:Open(curScene)
	UIBase.Open(self)
    self._MainScene = curScene
    self:InitHelpContent()
end

--关闭
function UIFishQuit:Close()
	UIBase.Close(self)
    self._MainScene = nil
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
function UIFishQuit:InitHelpContent()
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
        local spriteID = gameSceneData._wSpriteID[i]
        if childCount == 0 then
            print("UIFishQuit InitHelpContent fish:", spriteID, i)
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
            end 
        end
        if self._MainScene ~= nil then
            local count = self._MainScene._MyFishList[spriteID]
            if count == nil then
                count = 0
            end
            text:setString(tostring(count))
        end
    end
end
--

-------------------------------------------控件逻辑处理--------------------------------------------
--关闭
function UIFishQuit:OnCloseTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:CloseUI(UIType.UIType_FishQuit)
    end
end
--退出
function UIFishQuit:OnQuitTouch(eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:CloseUI(UIType.UIType_FishQuit)
        --通知服务器 起立
        local standUpPkt = require("Main.NetSystem.Packet.CSGRUserStandUp").new()
        standUpPkt._wTableID = ServerDataManager._CurrentTableID
        standUpPkt._wChairID = ServerDataManager._MeChairID
        NetSystem:SendGamePacket(standUpPkt)

        local buyBulletPkt = require("Main.NetSystem.Packet.CSGFBuyBullet").new()
        buyBulletPkt._lScore = 0
        buyBulletPkt._bAdd = 0
        NetSystem:SendGamePacket(buyBulletPkt)

        --返回到大厅
        local currentState = Game:GetCurrentGameState()
        if  currentState ~= GameState.GameState_Game then
            return
        end
        Game:SetGameState(GameState.GameState_Lobby)
        local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
        lobbyInstance:RefreshLobbyRtGame()
    end
end
return UIFishQuit


