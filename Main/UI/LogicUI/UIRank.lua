----
-- 文件名称：UIRank.lua
-- 功能描述：排行榜
-- 文件说明：排行榜
-- 作    者：王雷雷
-- 创建时间：2016-8-4
--  修改

local UIBase = require("Main.UI.UIBase")
require("Main.UI.UIHelper")

local UIRank = class("UIRank", UIBase)

local ITEM_CSB_NAME = "CSD/UI/UIRankItem.csb"

--构造(只做成员初始化)
function UIRank:ctor()
	UIBase.ctor(self)
    --TableView父面板
    self._TableviewPanel = nil
    self._Tableview = nil
    self._BtnClose = nil
    self._ItemCellList = nil
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UIRank:Load(resourceName)
	UIBase.Load(self, resourceName)

	--控件赋值
    self._TableviewPanel = self:GetUIByName("Panel_TableView")
    self._BtnClose = self:GetUIByName("Button_Close")
    local contentSize = self._TableviewPanel:getContentSize()
    self._Tableview = CreateTableView(0, 0, contentSize.width, contentSize.height, cc.TABLEVIEW_FILL_BOTTOMUP, self)
     if self._TableviewPanel ~= nil then
        self._TableviewPanel:addChild(self._Tableview)
   end

    self._BtnClose:addTouchEventListener(self.OnRankClose)

end

--卸载
function UIRank:Unload()
	UIBase.Unload(self)
end

--打开(UI内容初始化)
function UIRank:Open()
	UIBase.Open(self)
    self._Tableview:reloadData()
    self._RankDataHandler =  EventSystem:AddEvent(GameEvent.GE_RANK_CHANGE, self.OnRankDataChange)
end

--关闭
function UIRank:Close()
	UIBase.Close(self)
    if self._RankDataHandler ~= nil then
        EventSystem:RemoveEvent(self._RankDataHandler)
        self._RankDataHandler = nil
    end
end

--获取Cell index:从1开始,只创建一次
function UIRank:GetItemCellByIndex(index)
    if self._ItemCellList == nil then
        self._ItemCellList = {}
    end
    local curCell = self._ItemCellList[index] 
    if curCell == nil then
       curCell =  cc.CSLoader:createNode(ITEM_CSB_NAME) 
       curCell:retain()
       self._ItemCellList[index] = curCell
    end
    return self._ItemCellList[index]
end

--idx 从1开始 (初始化排行榜内容)
function UIRank:InitCellContent(idx, contentCell)
    if idx == nil or contentCell == nil then
        return
    end
    local rankDataList = ServerDataManager._RankDataList
    if rankDataList == nil then
        return
    end
    local rankData = rankDataList[idx]
    local textIndex = seekNodeByName(contentCell, "Text_RankIndex")
    local headImage = seekNodeByName(contentCell, "Image_Head")
    local textName = seekNodeByName(contentCell, "Text_Name")
    local textMeili = seekNodeByName(contentCell, "Text_MeiLi")
    local textDes = seekNodeByName(contentCell, "Text_Des")
    if rankData ~= nil then
        --目前缺少 数字0的资源，所以这样写
        if idx == 10 then
            textIndex:setString("0")
        else
            textIndex:setString(tostring(idx))
        end
        --头像
        textName:setString(rankData._NickName)
        textMeili:setString(tostring(rankData._LoveLiness))
        textDes:setString(rankData._Des)
    end
end

-------------------------------Tableview 回调 Begin----------------------------------------------------------

function UIRank.ScrollViewDidScroll(view)
 
end

function UIRank.NumberOfCellsInTableView(view)
    local len = 0
    local rankDataList = ServerDataManager._RankDataList
    if  rankDataList ~= nil then
        len = #rankDataList
    end
    --print("NumberOfCellsInTableView ", len)
    return len
end

function UIRank.TableCellTouched(view, cell)

end

function UIRank.CellSizeForTable(view, idx)
    return 1000, 95
end

function UIRank.TableCellAtIndex(view, idx)
    --print("TableCellAtIndex ", idx)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_Rank)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local contentCell = uiInstance:GetItemCellByIndex(idx + 1)
    contentCell:removeFromParent()
    cell:addChild(contentCell, 0, idx + 1)
    uiInstance:InitCellContent(idx + 1, contentCell)
    return cell
end



-------------------------------Tableview 回调 End----------------------------------------------------------

-------------------------------------------控件逻辑处理--------------------------------------------
--关闭
function UIRank:OnRankClose(eventType)
    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        UISystem:CloseUI(UIType.UIType_Rank)
    end  
end

---------------------------------------
function UIRank.OnRankDataChange()
     local uiInstance = UISystem:GetUIInstance(UIType.UIType_Rank)
     uiInstance._Tableview:reloadData()
end
return UIRank


