----
-- 文件名称：MyMain.lua
-- 功能描述：游戏逻辑入口
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-10-17
--  修改：将自己的逻辑入口从cocos2d独立出来


local function MyTraceBack(msg)
    if UISystem ~= nil then
        UISystem:ShowMessageBoxOne(msg)
    end
end

function __G__TRACKBACK__(msg)
    print(msg)
    MyTraceBack(msg)
end

--几个通用文件
require "Main.Utility.Json" 
require "Main.Utility.Xml"
require "Main.Utility.XmlHandler"
require "Main.GameConfig"
require "Main.Utility.Utility"
require "Main.DataPool.ChineseTable"


--初始化全局变量
function InitGameGlobal()
    local UISystemClass = require "Main.UI.UISystem"
    UISystem = UISystemClass.new()
    UISystem:Init()
    
    require "Main.Event.EventDefine"
    local EventSystemClass = require "Main.Event.EventSystem"
    EventSystem = EventSystemClass.new()
    local TableDataManagerClass = require "Main.DataPool.TableDataManager"
    TableDataManager = TableDataManagerClass.new()
    TableDataManager:Init()

    require "Main.Utility.SoundPlay"

    local ServerDataManagerClass = require "Main.ServerData.ServerDataManager"
    ServerDataManager = ServerDataManagerClass.new()
    ServerDataManager:Init()
    
    local NetSystemClass = require "Main.NetSystem.NetSystem"
    NetSystem = NetSystemClass.new()
    NetSystem:Init()
end

--重置全局变量
function ResetGlobal()
    Game = nil
    UISystem = nil
    EventSystem = nil
    TableDataManager = nil
    ServerDataManager = nil
    NetSystem = nil
end

function GetNetSystem()
    return NetSystem
end


function MyMain()
    InitGameGlobal()
    Game = require "Main.Game.Game"
    Game:Init()
    Game:SetGameState(GameState.GameState_Logo)
end

