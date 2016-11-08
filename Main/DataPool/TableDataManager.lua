----
-- 文件名称：TableDataManager.lua
-- 功能描述：表格数据管理器:所有.txt .xml 静态数据表结构定义，表数据的管理
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-24
--  修改：
-- 

require("Main.DataPool.DataConstDefine")
require("Main.DataPool.DataTableDefine")
require("Main.Utility.ExcelParse")
local tonumber = tonumber
local TableDataManager = class("TableDataManager")

--构造
function TableDataManager:ctor()
    --测试数据表
    self._TestDataTable = 0
    --物品表数据
    self._ItemTableData = 0
    --游戏配置表数据(各个游戏数据)
    self._GameConfigData = 0
    --签到表数据
    self._QianDaoTableData = 0
    --抽奖表
    self._ChouJiangData = nil
    --音效表
    self._SoundData = nil
    --Fish音效
    self._FishSoundData = nil

    --GameFish data
    self._GameFishXmlData = nil
    --排序的GameFish
    self._GameFishSortData = nil
    --Fish Path
    self._FishPathData = nil
    --排序的PathData
    self._FishPathSortData = nil

end

--初始化
function TableDataManager:Init()
    self:InitLobbyCfg()
end

--Get接口
function TableDataManager:GetFishDataByID(configID)
    return self._GameFishSortData[configID]
end

function TableDataManager:GetFishPathDataByID(configID)
    return self._FishPathSortData[configID]
end

--初始化大厅相关配置
function TableDataManager:InitLobbyCfg()
    self._TestDataTable = ExcelParse("Data/TestData.txt")
    self._ItemTableData = ExcelParse("Data/Item.txt")
    self._GameConfigData  = ExcelParse("Data/GameList.txt")
    self._QianDaoTableData = ExcelParse("Data/QianDao.txt")
    self._ChouJiangData = ExcelParse("Data/ChouJiang.txt")
    self._SoundData = ExcelParse("Data/Sound.txt")
    self._FishSoundData = ExcelParse("Data/FishSound.txt")
    --dump(self._TestDataTable)
    --dump(self._ItemTableData)

end
--初始化游戏过程相关的配置
function TableDataManager:InitGameCfg(fishXml, pathXml)
    self:ParseGameFishXML(fishXml)
    self:SortFishData()

    self:ParseFishPathXML(pathXml)
    self:SortFishPathData()
end
------------------------------------------XML数据-----------------------------------------------

--获取游戏场景中的背景图数目 
function TableDataManager:GetSceneBgCount()
    if self._GameFishXmlData == nil then
        return 0
    end
    return #self._GameFishXmlData.client.bgimages.sprite
end
--获取某张背景图
function TableDataManager:GetSceneBgByIndex(prefixName, index)
    if self._GameFishXmlData == nil then
        return ""
    end
    local allBg = self._GameFishXmlData.client.bgimages.sprite
    local count = #allBg
    if index >= 1 and index <= count then
        return prefixName .. allBg[index]._attr.path
    end
end
--parse GameFish.xml，
function TableDataManager:ParseGameFishXML(fileName)
    if self._GameFishXmlData ~= nil then
        self._GameFishXmlData = nil
    end
    local fileUtils = cc.FileUtils:getInstance()
    local fileName = fileUtils:getStringFromFile(fileName)
    local newHandler = simpleTreeHandler()
    local xmlParse = xmlParser(newHandler)
    fileName = TrimUTF8Header(fileName)
    local xmlTable = xmlParse:parse(fileName)
    self._GameFishXmlData = newHandler.root
end

--parse PathIndex.xml
function TableDataManager:ParseFishPathXML(fileName)
    if self._FishPathData ~= nil then
        self._FishPathData = nil
    end
    local fileUtils = cc.FileUtils:getInstance()
    local fileName = fileUtils:getStringFromFile(fileName)
    local newHandler = simpleTreeHandler()
    local xmlParse = xmlParser(newHandler)
    fileName = TrimUTF8Header(fileName)
    local xmlTable = xmlParse:parse(fileName)
    self._FishPathData = newHandler.root
end

--解析其中的Fish data
function TableDataManager:SortFishData()
    self._GameFishSortData = {}
    for k, v in pairs(self._GameFishXmlData.client.sprite)do
        if v._attr ~= nil and v._attr.id ~= nil then
            self._GameFishSortData[tonumber(v._attr.id)] = v
        end
    end
end

--排序Path Data
function TableDataManager:SortFishPathData()
    self._FishPathSortData = {}
    for k, v in pairs(self._FishPathData.Data.PathIndex)do
        local actionID = v.id
        if actionID == nil then

        end
        self._FishPathSortData[tonumber(actionID)] = v
    end
end


return TableDataManager

