----
-- 文件名称：UILobby.lua
-- 功能描述： 临时测试  大厅UI   
-- 文件说明：大厅UI 
-- 作    者：王雷雷
-- 创建时间：2016-7-11
--  修改
--  

local CSLogonMobile = require "Main.NetSystem.Packet.CSLogonMobile"

local UIBase = require("Main.UI.UIBase")

local UILobby = class("UILobby", UIBase)
require("Main.UI.UIHelper")

local tableInsert = table.insert

--构造(只做成员初始化)
function UILobby:ctor()
    UIBase.ctor(self)
    --控件变量
    self._TextNick = nil
    self._TextID = nil
    self._TextGold = nil

    self._BtnFreeGold = nil
    self._BtnQianDao = nil
    self._BtnChongZhi = nil
    self._BtnCangKu = nil
    self._BtnBag = nil
    self._BtnDuiHuan = nil
    self._BtnRank = nil
    self._BtnChouJiang = nil
    self._BtnReturn = nil
    self._BtnKeFu = nil
    self._BtnFanKui = nil
    self._BtnMail = nil
    self._BtnSetup = nil

    self._TableviewPanel = nil
    --游戏TableView
    self._GameTableView = nil
    self._GameItemCellList = nil
    --游戏公告Panel
    self._PanelSystemInfo = nil
    --滚动的公告
    self._TextSystemInfo = nil
    ---------------------逻辑变量-------------------------

    self._IsCellMove = false
    --handler
    self._Handler = nil
    self._ConFailHandler = nil
    self._GameLoginHandler = nil
    --左侧按钮节点
    self._LeftButtonNode = nil
    self._RightButtonNode = nil
    --主角信息改变
    self._SelfInfoChangeHandler = nil
    --排行榜数据请求时间
    self._LastRequestRankTime = 0

    --当前消息索引 
    self._CurMsgIndex = 1
end

-------------------------------------------四个通用必须实现的接口-------------------------------------------
--加载(逻辑所需控件的初始化)
function UILobby:Load(resourceName)
    UIBase.Load(self, resourceName)
    self._TextNick = self:GetUIByName("Text_Lobby_NickName")
    self._TextID = self:GetUIByName("Text_Lobby_UserID")
    self._TextGold = self:GetUIByName("Text_Gold")
    self._LeftButtonNode = self:GetUIByName("Node_LeftButton")
    self._RightButtonNode = self:GetUIByName("Node_RightButton")
    self._BtnFreeGold = self:GetUIByName("Button_TakeGold")
    self._BtnFreeGold:setTag(1)
    self._BtnFreeGold:setPressedActionEnabled(true)
    self._BtnFreeGold:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnQianDao = self:GetUIByName("Button_QianDao")
    self._BtnQianDao:setTag(2)
    self._BtnQianDao:setPressedActionEnabled(true)
    self._BtnQianDao:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnChongZhi = self:GetUIByName("Button_ChongZhi")
    self._BtnChongZhi:setTag(3)
    self._BtnChongZhi:setPressedActionEnabled(true)
    self._BtnChongZhi:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnCangKu = self:GetUIByName("Button_CangCu")
    self._BtnCangKu:setTag(4)
    self._BtnCangKu:setPressedActionEnabled(true)
    self._BtnCangKu:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnBag = self:GetUIByName("Button_Bag")
    self._BtnBag:setTag(5)
    self._BtnBag:setPressedActionEnabled(true)
    self._BtnBag:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnDuiHuan = self:GetUIByName("Button_DuiHuan")
    self._BtnDuiHuan:setTag(6)
    self._BtnDuiHuan:setPressedActionEnabled(true)
    self._BtnDuiHuan:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnRank = self:GetUIByName("Button_Rank")
    self._BtnRank:setTag(7)
    self._BtnRank:setPressedActionEnabled(true)
    self._BtnRank:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnChouJiang = self:GetUIByName("Button_ChouJiang")
    self._BtnChouJiang:setTag(8)
    self._BtnChouJiang:setPressedActionEnabled(true)
    self._BtnChouJiang:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnReturn = self:GetUIByName("Button_return")
    self._BtnReturn:setTag(9)
    self._BtnReturn:setPressedActionEnabled(true)
    self._BtnReturn:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnMail = self:GetUIByName("Button_Mail")
    self._BtnMail:setTag(10)
    self._BtnMail:setPressedActionEnabled(true)
    self._BtnMail:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnSetup = self:GetUIByName("Button_Setup")
    self._BtnSetup:setTag(11)
    self._BtnSetup:setPressedActionEnabled(true)
    self._BtnSetup:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnKeFu = self:GetUIByName("Button_KeFu")
    self._BtnKeFu:setTag(12)
    self._BtnKeFu:setPressedActionEnabled(true)
    self._BtnKeFu:addTouchEventListener(self.OnLobbyBtnTouch)

    self._BtnFanKui = self:GetUIByName("Button_FanKui")
    self._BtnFanKui:setTag(13)
    self._BtnFanKui:setPressedActionEnabled(true)
    self._BtnFanKui:addTouchEventListener(self.OnLobbyBtnTouch)

    self._TableviewPanel = self:GetUIByName("Panel_GameTableView")
    local contentSize = self._TableviewPanel:getContentSize()
    self._GameTableView = CreateTableView(0, 0, contentSize.width, contentSize.height, cc.SCROLLVIEW_DIRECTION_HORIZONTAL, self)
    self._TableviewPanel:addChild(self._GameTableView)

    self._PanelSystemInfo = self:GetUIByName("Panel_Chat")
    self._TextSystemInfo = self:GetUIByName("Text_SystemInfo")
end

--卸载
function UILobby:Unload()
    UIBase.Unload(self)
    
end

--打开(UI内容初始化)
function UILobby:Open()
    UIBase.Open(self)
    --自定义事件逻辑
    self._Handler = EventSystem:AddEvent(GameEvent.NE_CONNECTED, self.OnServerConnected)
    self._ConFailHandler = EventSystem:AddEvent(GameEvent.NE_CONNECTFAIL, self.OnServerConFail)
    self._GameLoginHandler = EventSystem:AddEvent(GameEvent.GE_GSLogin_Success, self.OnGSLoginSccess)
    self._SelfInfoChangeHandler = EventSystem:AddEvent(GameEvent.GE_UserInfoChange, self.OnSelfInfoChange)
    self._IsCellMove = false
    self:RefreshUIUserInfo()
    self:SetGameListShow(true)
    self:RefreshGameList()
    self:SetShowLeftRightBtns(true)
    --
    local qianDaoData = ServerDataManager._QianDaoData 
    if qianDaoData == nil then
        self.SendQianDaoRequest()
    end
    --用于返回的
    ServerDataManager._IndexForReturn = 1

    --
    if ServerDataManager._MessageList == nil then
        self:SendMessageRequest()
    else
        self:ScrollSystemMsg()
    end

    self._CurMsgIndex = 1
    self._TextSystemInfo:setString("")

end

--关闭
function UILobby:Close()
    UIBase.Close(self)

    self._TextSystemInfo:stopAllActions()

    if self._Handler ~= nil then
        EventSystem:RemoveEvent(self._Handler)
        self._Handler = nil
    end
    if self._ConFailHandler ~= nil then
        EventSystem:RemoveEvent(self._ConFailHandler)
        self._ConFailHandler = nil
    end
    if self._GameLoginHandler ~= nil then
        EventSystem:RemoveEvent(self._GameLoginHandler)
        self._GameLoginHandler = nil
    end
    if self._SelfInfoChangeHandler ~= nil then
        EventSystem:RemoveEvent(self._SelfInfoChangeHandler)
        self._SelfInfoChangeHandler = nil
    end
end

-------------------------------------------------------------------------------------------------------------
--刷新UI
function UILobby:RefreshUIUserInfo()
    local selfInfo = ServerDataManager._SelfUserInfo
    self._TextNick:setString(selfInfo._szNickName32)
    self._TextID:setString(tostring(selfInfo._dwUserID))
    self._TextGold:setString(tostring(selfInfo._lUserScore))
    --print("UILobby:RefreshUIUserInfo", selfInfo._lUserScore)
end

--刷新游戏列表
function UILobby:RefreshGameList()
    self._GameTableView:reloadData()
end

--处理从游戏返回大厅时的UI刷新
function UILobby:RefreshLobbyRtGame()
    self:SetGameListShow(false)
    self:SetShowLeftRightBtns(false)
    UISystem:OpenUI(UIType.UIType_RoomTableList)
end
--处理从房间桌子返回大厅
function UILobby:RefreshRtRoom()
    self:SetGameListShow(true)
    self:SetShowLeftRightBtns(true)
    UISystem:CloseUI(UIType.UIType_RoomTableList)
    ServerDataManager._IndexForReturn = 1
end
--隐藏GameList
function UILobby:SetGameListShow(isShow)
    self._TableviewPanel:setVisible(isShow) 
end
--显示or隐藏两侧按钮
function UILobby:SetShowLeftRightBtns(isShow)
    self._LeftButtonNode:setVisible(isShow)
    self._RightButtonNode:setVisible(isShow)
end
--系统消息滚动完毕
function UILobby.OnMessageScrollEnd()
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
    uiInstance:ScrollSystemMsg()
end

--滚动系统文字 
function UILobby:ScrollSystemMsg()
    local msgList = ServerDataManager._MessageList
    local curCount = #msgList
    if curCount == 0 then
        return
    end
    if self._CurMsgIndex > curCount then
        self._CurMsgIndex = 1
    end
    self._TextSystemInfo:setString(msgList[self._CurMsgIndex])
    local moveStartX = self._PanelSystemInfo:getContentSize().width
    local oriPosX, oriPosY = self._TextSystemInfo:getPosition()
    self._TextSystemInfo:setPosition(moveStartX, oriPosY) 
    local offsetX = (self._TextSystemInfo:getContentSize().width + moveStartX)
    local moveSpeed = 80
    local moveBy = cc.MoveBy:create(offsetX / moveSpeed, cc.p(-offsetX, 0))
    local callFunc = cc.CallFunc:create(self.OnMessageScrollEnd)
    local delay = cc.DelayTime:create(1)
    local sequence = cc.Sequence:create(moveBy, delay, callFunc)
    self._TextSystemInfo:runAction(sequence)
    self._CurMsgIndex = self._CurMsgIndex + 1
end

--获取游戏Item（大游戏图标按钮等）
function UILobby:GetGameItemCellByIndex(index)
    if self._GameItemCellList == nil then
        self._GameItemCellList = {}
    end
    local curCell = self._GameItemCellList[index] 
    local csbName = nil
    local gameList = ServerDataManager._GamekindList
    if gameList ~= nil then
       local gameID =  gameList[index]._wGameID
       local cfgData = TableDataManager._GameConfigData[gameID]
       csbName = cfgData.csbName
    end

    if curCell == nil then
       curCell =  cc.CSLoader:createNode(csbName) 
       curCell:retain()
       curCell:setTag(index)
       self._GameItemCellList[index] = curCell
        print("GetGameItemCellByIndex ", index , curCell)
    end
    return self._GameItemCellList[index]

end


--初始化Game cell内容
function UILobby:InitGameCellContent(idx, contentCell)
    print("InitGameCellContent ", idx, contentCell)
    if contentCell == nil then
        return
    end
    contentCell:setTag(idx)
    local gameImage = seekNodeByName(contentCell, "Image_Game")
    if gameImage ~= nil then
        gameImage:setSwallowTouches(false)
        gameImage:addTouchEventListener(self.OnGameItemTouch)
        gameImage:setTag(idx)
    end
end
-------------------------------------------控件逻辑处理--------------------------------------------

--请求背包物品数据
function UILobby:SendBagDataRequest()
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://service.7hx.com:8088/WS/box.ashx")

    local function onReadyStateChanged()
        if xhrBag.readyState == 4 then
            if xhrBag.status ~= 200 then
                UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            if xhrBag.response == nil then
               UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            local testStr = xhrBag.response
            local bagTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(bagTable, "bagTable", 10)

            if bagTable.msg ~= nil and bagTable.msg ~= "" then
                 UISystem:ShowMessageBoxOne(bagTable.msg) 
                 return
            end
            --dump(bagTable, "bagTable", 10)
            --物品数据保存
            ServerDataManager._BagItemDataList = {}
            if bagTable.data ~= nil then
                local page = bagTable.data.page
                for i = 1, #page do
                    local newItem = ServerDataManager:CreateItem()
                    newItem._ServerID = page[i].ID
                    newItem._ItemType = page[i].ItemType
                    newItem._ItemType2 = page[i].ItemType2
                    --客户端配置表中的ID规则 
                    newItem._TableID = page[i].ItemType * 1000 + page[i].ItemType2
                    newItem._TableData = TableDataManager._ItemTableData[newItem._TableID]
                    newItem._Sign = page[i].sign
                    newItem._Count = page[i].ItemCount
                    tableInsert(ServerDataManager._BagItemDataList, newItem)
                end
                EventSystem:DispatchEvent(GameEvent.GE_ITEM_CHANGE)
            end
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = string.format("%d%s%s", userID, "myitmes", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = string.format("cmd=%s&UserId=%d&cmdsign=%s", "myitmes", userID, newSzMD5)
    print("requestData", requestData)
    xhrBag:send(requestData)

end

--请求排行榜数据
function SendRankDataRequest()
    local xhrRank = cc.XMLHttpRequest:new()
    xhrRank.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrRank:open("POST", "http://service.7hx.com:8088/WS/mbinterface.ashx")

    local function onReadyStateChanged()
        if xhrRank.readyState == 4 then
            xhrRank:unregisterScriptHandler()
            if xhrRank.status ~= 200 then
                UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            if xhrRank.response == nil then
               UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            local testStr = xhrRank.response
            local rankTable = decodejson(testStr)
            xhrRank:unregisterScriptHandler()
            --dump(rankTable, "rankTable", 10)
            if rankTable.msg ~= nil and rankTable.msg ~= "" then
                UISystem:ShowMessageBoxOne(rankTable.msg) 
                return
           end
           ServerDataManager._RankDataList = {}
           for i = 1, #rankTable do
                local serverData = rankTable[i]
                local newRankData = ServerDataManager:CreateRankData()
                newRankData._RankIndex = i
                newRankData._CustomID = serverData.CustomID
                newRankData._LoveLiness = serverData.LoveLiness
                newRankData._NickName = serverData.NickName
                newRankData._Des = serverData.UnderWrite
                newRankData._UserID = serverData.UserID
                tableInsert(ServerDataManager._RankDataList, newRankData)
           end
           EventSystem:DispatchEvent(GameEvent.GE_RANK_CHANGE)
        end
    end

    xhrRank:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = string.format("%d%s%s", userID, "getlovesrank", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = string.format("cmd=%s&UserId=%d&cmdsign=%s", "getlovesrank", userID, newSzMD5)
    xhrRank:send(requestData)

end

--请求签到数据
function UILobby.SendQianDaoRequest()
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://service.7hx.com:8088/WS/mbinterface.ashx")

    local function onReadyStateChanged()
        if xhrBag.readyState == 4 then
            if xhrBag.status ~= 200 then
                UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            if xhrBag.response == nil then
               UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            local testStr = xhrBag.response
            local qianDaoTable = decodejson(testStr)
            xhrBag:unregisterScriptHandler()
            --dump(qianDaoTable, "qianDaoTable", 10)
            if qianDaoTable ~= nil then
                local qianDaoData = ServerDataManager._QianDaoData 
                if qianDaoData == nil then
                    qianDaoData = ServerDataManager:CreateQianDaoData()
                    ServerDataManager._QianDaoData = qianDaoData
                end
                qianDaoData._QianDaoDays = qianDaoTable.data.signcount
                qianDaoData._IsQianToday = qianDaoTable.data.todaysign
                if qianDaoData._IsQianToday == false then
                    UISystem:OpenUI(UIType.UIType_QianDao)
                end
                EventSystem:DispatchEvent(GameEvent.GE_QianDaoChange)
            end
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    local userID = ServerDataManager._SelfUserInfo._dwUserID
    local szMD5 = string.format("%d%s%s", userID, "initdata", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = string.format("cmd=%s&UserId=%d&cmdsign=%s", "initdata", userID, newSzMD5)
    --print("requestData", requestData)
    xhrBag:send(requestData)
    
end

--请求消息数据  http://service.7hx.com:8088/WS/msg.ashx
function UILobby.SendMessageRequest()
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("GET", "http://service.7hx.com:8088/WS/msg.ashx")

    local function onReadyStateChanged()
        if xhrBag.readyState == 4 then
            if xhrBag.status ~= 200 then
                UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            if xhrBag.response == nil then
               UISystem:ShowMessageBoxOne(ChineseTable["CT_NetError"]) 
                return
            end
            local testStr = xhrBag.response
            local msgTable = decodejson(testStr)
            ServerDataManager._MessageList = {}
            --dump(msgTable)
            if msgTable.data ~= nil then
                local count = #msgTable.data
                if count ~= 0 then
                    for i = 1, count do
                        table.insert(ServerDataManager._MessageList, msgTable.data[i].msg)
                    end
                end
                local uiInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
                uiInstance:ScrollSystemMsg()
            end
        end
    end

    xhrBag:registerScriptHandler(onReadyStateChanged)
    xhrBag:send()
    
end

-----------------------------------------Tableview callback begin-----------------------------------------

function UILobby.ScrollViewDidScroll(view)
   -- print("ScrollViewDidScroll")
end

function UILobby.NumberOfCellsInTableView(view)
    local len = 0
    local gameList = ServerDataManager._GamekindList
    if gameList ~= nil then
        len = #gameList
    end
    --print("NumberOfCellsInTableView", len)
    return len
end

function UILobby.TableCellTouched(view, cell)
    --print("UILobby.TableCellTouched" )
    local tag = cell:getTag()
    local gameKindList = ServerDataManager._GamekindList
    local gameData = gameKindList[tag]
    if gameData ~= nil then
       print(gameData._wGameID) 
       ServerDataManager._CurSelGameID = gameData._wGameID
       UISystem:OpenUI(UIType.UIType_RoomList)
    end
end

function UILobby.CellSizeForTable(view, idx)
    return 340, 380  
end

function UILobby.TableCellAtIndex(view, idx)
    --print("TableCellAtIndex ", idx)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local realIdx = idx + 1
    local contentCell = uiInstance:GetGameItemCellByIndex(realIdx)
    contentCell:removeFromParent()
    cell:addChild(contentCell)
    cell:setTag(realIdx)
    uiInstance:InitGameCellContent(realIdx, contentCell)
    return cell
end

----------------------------------------------------Tableview callback end------------------------------------------------------

--其它大厅按钮
function UILobby.OnLobbyBtnTouch(sender, eventType)

    if eventType == ccui.TouchEventType.ended then
        SoundPlay:PlaySoundByID(SoundDefine.Common_Btn)
        local tag = sender:getTag()
        local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
        --免费领金
        if tag == 1 then

        --签到
        elseif tag == 2 then
             local qianDaoData = ServerDataManager._QianDaoData 
            if qianDaoData == nil then
                lobbyInstance.SendQianDaoRequest()
            end
            UISystem:OpenUI(UIType.UIType_QianDao)
        --充值
        elseif tag == 3 then

        --仓库
        elseif tag == 4 then
            UISystem:OpenUI(UIType.UIType_CangKu)
        --背包
        elseif tag == 5 then
            --避免频繁请求数据(第一次时去请求)
            if ServerDataManager._BagItemDataList == nil then
                lobbyInstance:SendBagDataRequest()
            end
            UISystem:OpenUI(UIType.UIType_Bag)
        --兑换
        elseif tag == 6 then
            UISystem:OpenUI(UIType.UIType_Cdk)
        --排行榜
        elseif tag == 7 then
            --避免频繁请求数据(第一次时请求或者间隔时间超过1分钟去请求)
            local curTime = os.time()
            local flapsedTime = curTime - lobbyInstance._LastRequestRankTime
            if ServerDataManager._RankDataList == nil or flapsedTime > 60 then
                SendRankDataRequest()
                lobbyInstance._LastRequestRankTime = curTime
            end
            UISystem:OpenUI(UIType.UIType_Rank)
        --抽奖
        elseif tag == 8 then
             UISystem:OpenUI(UIType.UIType_ChouJiang)
        --返回
        elseif tag == 9 then
            --从某房间内返回大厅
            if ServerDataManager._IndexForReturn == 2 then
                lobbyInstance:RefreshRtRoom()
            --返回登陆
            elseif ServerDataManager._IndexForReturn == 1 then
                ServerDataManager:ClearData()
                Game:SetGameState(GameState.GameState_Login)
            end


        --邮件
        elseif tag == 10 then

        --设置
        elseif tag == 11 then
            UISystem:OpenUI(UIType.UIType_Setting)
        --客服
        elseif tag == 12 then
            UISystem:OpenUI(UIType.UIType_Kefu)

        --反馈
        elseif tag == 13 then
            UISystem:OpenUI(UIType.UIType_FanKui)
        end
    end
end

--某个游戏图点击
function UILobby.OnGameItemTouch(sender, eventType)
    local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
    if eventType == ccui.TouchEventType.ended then

    end
end

--------------------------------------------------------
function UILobby.OnServerConnected(param)
    if param._usedata.name == "GameSocket" then
        local packet = CSLogonMobile.new()
        NetSystem:SendGamePacket(packet)
    end
end

function UILobby.OnServerConFail(param)
    if param._usedata.name == "GameSocket" then
        
    end
end
--服务器返回游戏服务器登录成功
function UILobby.OnGSLoginSccess()
    local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
    lobbyInstance:SetGameListShow(false) 
    lobbyInstance:SetShowLeftRightBtns(false)
    UISystem:CloseUI(UIType.UIType_RoomList)
    UISystem:OpenUI(UIType.UIType_RoomTableList)
end

function UILobby.OnSelfInfoChange()
    local lobbyInstance = UISystem:GetUIInstance(UIType.UIType_Lobby)
    lobbyInstance:RefreshUIUserInfo()
end

return UILobby
