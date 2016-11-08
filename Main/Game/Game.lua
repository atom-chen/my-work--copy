----
-- 文件名称：Game.lua
-- 功能描述：游戏逻辑入口
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-24
--  修改：

--整个游戏的状态
--Logo展示
--更新
--登陆
--游戏大厅
--游戏

-----所有Game状态实例需要实现的 方法: Init Destroy  Update(delta)
local GameLogo = require("Main.Game.GameLogo")
local GameLogin = require("Main.Game.GameLogin")
local GameLobby = require("Main.Game.GameLobby")
local GamePlay = require("Main.Game.GamePlay")
local GameUpdate = require("Main.Game.GameUpdate")

--游戏状态  全局的
GameState = 
{
    --Logo
    GameState_Logo = 0,
    --在线更新
    GameState_Update = 1,
    --登陆
    GameState_Login = 2,
    --大厅
    GameState_Lobby = 3,
    --游戏 捕鱼
    GameState_Game = 4,
    --备用状态：其它游戏(斗地主)
    GameState_DDZ = 5,
}


local Game = class("Game");

--构造
function Game:ctor()
    --当前游戏状态
    self.mCurrentGameState = 0;
    --状态实例Table
    self.mStateInstanceTable = 0;
end

--Update
local function FuncGameUpdate(delta)
    Game:Update(delta)
end

--初始化
function Game:Init()
    self.mStateInstanceTable = {}
    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(FuncGameUpdate, 0, false)

    --注册所有游戏状态
    self:RegisterGameState(GameState.GameState_Logo, GameLogo)
    self:RegisterGameState(GameState.GameState_Login, GameLogin)
    self:RegisterGameState(GameState.GameState_Lobby, GameLobby)
    self:RegisterGameState(GameState.GameState_Game, GamePlay)
    self:RegisterGameState(GameState.GameState_Update, GameUpdate)
    
end

--获取游戏状态
function Game:GetCurrentGameState()
    return self.mCurrentGameState
end

--游戏状态设定
function Game:SetGameState(state)
    if self.mStateInstanceTable == 0 then
        printError("Game:SetGameState mStateInstanceTable == 0")
        return
    end
    --老实例的销毁
    local  oldGameStateInstance = self.mStateInstanceTable[self.mCurrentGameState]
    if oldGameStateInstance ~= nil then
        oldGameStateInstance:Destroy()
    end
    self.mCurrentGameState = state
    --新实例初始化 
    local newStateInstance = self.mStateInstanceTable[self.mCurrentGameState]
    if newStateInstance == nil then
        printError("Game:SetGameState newStateInstance == 0 : %d", self.mCurrentGameState)
        return
    end
    newStateInstance:Init()
end

--获取各状态实例
function Game:GetCurStateInstance()
    return self.mStateInstanceTable[self.mCurrentGameState]
end

--注册实例(未注册的，调用 gameClass.new )
function Game:RegisterGameState(state, gameClass)

    if self.mStateInstanceTable == 0 then
        printError("Game:RegisterGameState mStateInstanceTable == 0")
        return
    end
    local currentInstance = self.mStateInstanceTable[state]
    if currentInstance == nil then
        self.mStateInstanceTable[state] = gameClass.new()
    end
end

--Update
function Game:Update(delta)
    local currentInstance = self.mStateInstanceTable[self.mCurrentGameState]
    if currentInstance == nil then
        printError("Game:Update currentInstance == nil ", self.mCurrentGameState)
        return
    end
    currentInstance:Update(delta)
    
end





return Game