--程序入口 
--入口文件在正式上线后，不能做任何改动，否则有可能会导致热更新后的逻辑错误

local stringFormat = string.format
local tableInsert = table.insert
local ipairs = ipairs


--文件搜索路径
local fileUtils = cc.FileUtils:getInstance()
fileUtils:setPopupNotify(false)
fileUtils:addSearchPath("src/")
fileUtils:addSearchPath("res/")
local writePath = fileUtils:getWritablePath()
--
local userDefault = cc.UserDefault:getInstance()
local md5State = userDefault:getIntegerForKey("MD5State", 1)
--非法的状态，即在下载更新资源过程中退出过, 清除已经下载过的所有资源
if md5State == 0 then
    userDefault:setIntegerForKey("ResVersion", 0)
    local writePatch = stringFormat("%sPatch/", writePath)
    local ok = fileUtils:removeDirectory(writePatch)
    if not ok then
        print("CleanPatch fail ")
    end
    userDefault:setIntegerForKey("MD5State", 1)
end

local saveVersion = userDefault:getIntegerForKey("ResVersion", 0)
--如果有过更新，添加更新目录Patch Patch/res Patch/src 到搜索路径
if saveVersion ~= 0 then
    local writePatch = stringFormat("%sPatch/", writePath)
    fileUtils:addSearchPath(writePatch, true)
    local resPatch = stringFormat("%sPatch/res/", writePath)
    local srcPatch = stringFormat("%sPatch/src/", writePath)
    fileUtils:addSearchPath(resPatch, true)
    fileUtils:addSearchPath(srcPatch, true)
    print("writePath: ---------------", writePath)
end

--------------------------热更新相关，重写 require,记录所有require的lua文件，待更新完毕后，重新加载所有文件---------------------------
local oriRequire = require
local loadedTable = package.loaded
local reloadTable = {}
function require(name)
    if loadedTable[name] == nil then
        tableInsert(reloadTable, name)
         print("my require ", name)
    end
    local ret, _ = oriRequire(name)
    return  ret
end

--重置 Loaded
function ResetLoadedLua()
    for i, v in ipairs(reloadTable)do
        loadedTable[v] = nil
        --print("reload lua nil ", v)
    end 
end

--重新加载所有Lua脚本
function ReloadAllLua()
    local tempCopy = clone(reloadTable)
    reloadTable = {}
    for i, v in ipairs(tempCopy)do
       require(v)
       print("reload lua ", v)
    end 
end
--------------------------------------

require "config"
require "cocos.init"

local function main()
    require("app.MyApp"):create():run()
    require("Main.MyMain")
    MyMain()
end

function __G__TRACKBACK__(msg)
    print(msg)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
