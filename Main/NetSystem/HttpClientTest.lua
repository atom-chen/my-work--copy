----
-- 文件名称：HttpClientTest.lua
-- 功能描述：http 测试
-- 文件说明：测试一下Lua中的httpRequest，没必要再封装起来
-- 作    者：王雷雷
-- 创建时间：2016-7-13
--  修改：


function TestHttp()
    -------------------------------------------XML------------------------------------------
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", "update.7hx.com:8088/server.xml")

    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print(xhr.response)
            local testStr = xhr.response
            testStr = TrimUTF8Header(testStr)
            local newHandler = simpleTreeHandler()
            local xmlParse = xmlParser(newHandler)
            local xmlTable = xmlParse:parse(testStr)
            dump(newHandler.root)
            dump(newHandler.root.servers.server)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)
    xhr:send()

    -------------------------------------------Jason-----------------------------------------
    local xhrBag = cc.XMLHttpRequest:new()
    xhrBag.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhrBag:open("POST", "http://www.7hx.com/WS/mbinterface.ashx")

    local function onReadyStateChanged1()
        if xhrBag.readyState == 4 and (xhrBag.status >= 200 and xhrBag.status < 207) then
            print(xhrBag.response)
            local testStr = xhrBag.response
            local rankTable = decodejson(testStr)
            dump(rankTable)
        else
            print("xhrBag.readyState is:", xhrBag.readyState, "xhrBag.status is: ",xhrBag.status)
        end
        xhrBag:unregisterScriptHandler()
        local currentCount = collectgarbage("count")
        print("currentCount", currentCount)
        --collectgarbage("collect")
        --xhrBag = nil
    end

    xhrBag:registerScriptHandler(onReadyStateChanged1)
    local szMD5 = string.format("%d%s%s", 1155161, "getlovesrank", "a2a553f252cd4123a81e172d951f900b")
    local encryptInstance = LuaLib.CEncrypt:new()
    local newSzMD5 = encryptInstance:MD5EncryptString32(szMD5)
    local requestData = string.format("cmd=%s&UserId=%d&cmdsign=%s", "getlovesrank", 1155161, newSzMD5)
    print("requestData", requestData)
    xhrBag:send(requestData)

end

