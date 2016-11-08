
-- 文件名称：ExcelParse
-- 功能描述：解析excel数据表
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-6-30
--  修改：
-- 

require("Main.Utility.Utility")
local fileUtils = cc.FileUtils:getInstance()
--fieldTableData 字段定义Table  fieldTableData ~= nil 时，为新的表格调用方式
function ExcelParse(fileName, fieldTableData)
    --Army.txt
    local fileContent = fileUtils:getStringFromFile(fileName)
    local tablegetn = table.getn

    local linesdata = Split(fileContent,"\r\n")

    assert(tablegetn(linesdata) >= 4)
    --备注栏
    local rowhead = Split(linesdata[1],"\t")
    local colNumber = tablegetn(rowhead)
    --类型
    local rowtype = Split(linesdata[2],"\t")
    assert(tablegetn(rowtype) == colNumber)
    --字段名
    local colNameTable = Split(linesdata[3],"\t")
    assert(tablegetn(colNameTable) == colNumber)
    --字段替换
    if fieldTableData ~= nil then
        for k, v in pairs(colNameTable)do
            local newValue = fieldTableData[v]
            if newValue ~= nil then
                colNameTable[k] = newValue
            end
        end
    end
    local tableData = {}

    local lineindex = 4
    local tableinsert = table.insert
    while true do
        if linesdata[lineindex] == nil then
            break
        end
        local linedata = Split(linesdata[lineindex],"\t")
        if tablegetn(linedata) ~= colNumber then
            print("ExcelParse linedata error", lineindex, fileName)
        end
        assert(tablegetn(linedata) == colNumber)        

        local linetable = {}    

        local colIndex = 1
        while true do 
            if colIndex > colNumber then
                break
            end

            if rowtype[colIndex] == "number" or  rowtype[colIndex] == "float" then
                linetable[colNameTable[colIndex]] = tonumber(linedata[colIndex])
            else
                local colContent = linedata[colIndex]
                colContent = TrimString(colContent,"\"")
                if colContent ~= nil then
                    linetable[colNameTable[colIndex]] = colContent
                else
                    print("%s nil", colNameTable[colIndex])
                end
            end     
            colIndex = colIndex + 1     
        end

        tableinsert(tableData, tonumber(linedata[1]), linetable)

        lineindex = lineindex + 1
    end
    return  tableData
end