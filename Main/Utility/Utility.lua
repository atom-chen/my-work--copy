-- 
-- 文件名称：Utility
-- 功能描述：通用功能的函数
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-6-30
--  修改：
-- 
--全局控制变量,自动战斗用来测试PVE
TEST_AUTO_BATTLE = false

local PacketPathPrefix = "main.NetSystem.Packet."

function loadLua(path)
    local BasePath = ""
    local DirList = {}
    if device.platform == "android" then
        local pathdrir string.gsub(cc.FileUtils:getInstance():fullPathForFilename("server.xml"), "res/server.xml", "")
        BasePath = pathdrir
    end
    for entry in lfs.dir(BasePath.."src/main/NetSystem/Packet/"..path) do
        local isLua = entry ~= "__init__.lua" and string.find(entry, ".lua") ~= nil
        local isLc = entry ~= "__init__.lc" and string.find(entry, ".lc") ~= nil
        if entry ~= "." and entry ~= ".." and (isLua or isLc) then
            local s, n = string.gsub(entry, "%.lua+", "")
            local start, endIndex = string.find(s, "CS")
            table.insert(DirList, PacketPathPrefix..path.."."..s)
        end
    end 
    return DirList
end

--分割字符串到表
function Split(str, delim, maxNb)
    -- Eliminate bad cases...   
    local localstring = string
    if localstring.find(str, delim) == nil then  
        return { str }  
    end  
    if maxNb == nil or maxNb < 1 then  
        maxNb = 0    -- No limit   
    end  
    local result = {}  
    local pat = "(.-)" .. delim .. "()"   
    local nb = 0  
    local lastPos   
    for part, pos in localstring.gfind(str, pat) do  
        nb = nb + 1  
        result[nb] = part   
        lastPos = pos   
        if nb == maxNb then break end  
    end  
    -- Handle the last field   
    if nb ~= maxNb then  
        result[nb + 1] = localstring.sub(str, lastPos)   
    end  
    return result   
end

function SplitSet(str)
    local data = {}
    for s in string.gfind(str, "[^(]+") do
        local v,_ = string.gsub(s, '%)', "")
        table.insert(data, Split(v, ',')) 
    end
    return data
end

function SplitSet2(str)
    local data = {}
    for s in string.gfind(str, "[^(]+") do
        local v,_ = string.gsub(s, '%)', "")
        table.insert(data, v) 
    end
    return data
end

--查找节点
function seekNodeByName(parent, name)
    if not parent or parent.getChildren == nil then
        return
    end

    if parent:getName() == name then
        return parent
    end

    local findNode
    local children = parent:getChildren()
    local childCount = parent:getChildrenCount() 
    if childCount < 1 then
        return
    end
    for i=1, childCount do
        if "table" == type(children) then
            parent = children[i]
        elseif "userdata" == type(children) then
            parent = children:objectAtIndex(i - 1)
        end

        if parent then
            findNode = seekNodeByName(parent, name)
            if findNode then
                return findNode
            end
        end
    end

    return
end

--去除字符
function TrimString(strContent, flag)
    if strContent == 0 or strContent == nil then
        return
    end
    return string.gsub(strContent, flag, "")
end

--以下为序列化函数
function basicSerialize (o)  
    if type(o) == "number" then  
       return tostring(o)  
    else       -- assume it is a string  
       return string.format("%q", o)  
    end  
end 

--保存Table数据到Lua文件
function SaveTable(file, name, value, saved)  
    saved = saved or {}    
    if type(value) == "number" or type(value) == "string" then  
        file.write(file,name.." = ")  
        file.write(file,basicSerialize(value).."\r\n")  
    elseif type(value) == "table" then  
        file.write(file,name.." = ")
        if saved[value] then     -- value already saved?  
            -- use its previous name  
            file.write(file,saved[value].."\r\n")  
        else  
            saved[value] = name -- save name for next time  
            file.write(file,"{}\r\n")     -- create a new table  
            for k,v in pairs(value) do -- save its fields  
                local fieldname = string.format("%s[%s]", name, basicSerialize(k))  
                SaveTable(file,fieldname, v, saved)  
            end  
        end  
    else
    --nothing to do
    --error("cannot save a " .. type(value))  
    end  
end 
--保存Lua Table到文件
function SaveTableToFile(fileName, name, toSaveData)
    local file = io.open(fileName, "wb")
    SaveTable(file,name,toSaveData)
    io.close(file)
end

function SortTable(a, b) 
     print("==============================")
    return tonumber(a.id) < tonumber(b.id)
end

--保存Table数据到Lua文件
function SaveTable1(file, value)    
    if type(value) == "table" then 
        print("==+++++++++++++++++++++++++++++++===="..value[20].id)
        table.sort(value, SortTable)
        local level = 20
        for i, v in pairs(value) do
            print(i.."----------------------------"..v["id"])
            local data = SplitSet(value[level]["pvp"])
          
            
            local warrior = false
            file.write(file,level.."    \t")
            for j = 1, #data do
                if math.floor(tonumber(data[j][1]) / 100000) > 1 then
                    warrior = true
                    file.write(file, "("..data[j][1]..","..data[j][4]..")") 
                elseif math.floor(tonumber(data[j][1]) / 100000) == 1 and warrior then
                    warrior = false
                    file.write(file, "("..data[j][1]..","..data[j][4]..")") 
                end
            end
            file.write(file,"\t\r\n")  
            level = level + 10
        end 
    end  
end

require "Main.Utility.LuaBit.bit"

--copy from C++
local PRODUCT_VER = 6
function Process_Version(mainVer, subVer, build)
 local part1 = bitLib.blshift(PRODUCT_VER, 24) 
 local part2 = bitLib.blshift(mainVer, 16) 
 local part3 = bitLib.blshift(subVer, 8)
 return part1 + part2 + part3 + build
end

--去掉UTF8的头
function TrimUTF8Header(oriString)
    local strHead = string.format("%s%s%s", string.char(239), string.char(187), string.char(191))
    local newStr = string.gsub(oriString, strHead, "")
    return newStr
end
--[[
--字符集转化
local cdGToU = iconv.new("utf-8", "gb2312")
function GB2312ToUTF8(srcString)
    return cdGToU:iconv(srcString)
end

local cdUToG = iconv.new("gb2312","utf-8")
function UTF8ToGB2312(srcString)
    return cdUToG:iconv(srcString)
end

local cdU8ToU16 = iconv.new("utf-16le", "utf-8")
function UTF8ToUTF16(srcString)
    return cdU8ToU16:iconv(srcString)
end

local cdUTF16ToUTF8 = iconv.new("utf-8", "utf-16le")
function UTF16ToUTF8(srcString)
    return cdUTF16ToUTF8:iconv(srcString)
end
]]--
--简单加密 string
function SimpleEncryptString(str)
    local len = string.len(str)
    local conStr = ""
    for i = 1, len do
       local charStr =  string.sub(str, i, i)
       local charByte = string.byte(charStr)
       local conByte = bitLib.bxor(charByte, 0x7f)
       conStr = conStr .. string.char(conByte)
    end
    return conStr
end

--
function GetPlatformDeviceType()
    local currPlatform = cc.Application:getInstance():getTargetPlatform()
    if (currPlatform == cc.PLATFORM_OS_WINDOWS) or (currPlatform == cc.PLATFORM_OS_WINRT) or (currPlatform == cc.PLATFORM_OS_WP8)then
        return 0x10
    elseif currPlatform == cc.PLATFORM_OS_ANDROID then
        return 0x10
    else
        return 0x40
    end
end

function GetProcessVersion()
    return Process_Version(6, 0, 3)
end