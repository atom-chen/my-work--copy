----
-- 文件名称：NetSystem.lua
-- 功能描述：网络模块
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-1
--  修改：

local SocketTCP = require "Main.NetSystem.SocketTCP"
local NetPacketDefine = require "Main.NetSystem.PacketDefine"
local NetSystem = class("NetSystem")



function NetSystem:ctor()
    --Login
    self._LoginSocket = nil
    --Game
    self._GameSocket = nil
    --消息包的管理
    self._msgPacketTable = nil
end

--初始化
function NetSystem:Init()
    EventSystem:AddEvent(SocketTCP.EVENT_CONNECTED, self.OnConnected)
    --[[
    self._LoginSocket = SocketTCP.new()
    self._LoginSocket:setName("_LoginSocket")
    self._LoginSocket:connect("127.0.0.1", 8300)
    
    self._TestSocket = SocketTCP.new()
    self._TestSocket:setName("_TestSocket")
    self._TestSocket:connect("127.0.0.1", 8300)
    ]]--
    self._msgPacketTable = {[1] = {}, [2] = {}}
    
    self:RegisterAllPacket()
end

--注册所有网络包
function NetSystem:RegisterAllPacket()
    for k, v in pairs(NetPacketDefine)do
        for k1, v1 in pairs(v)do
            local len = #v1
            if len ~= 3 then
                printError("RegisterAllPacket define Error %d", k)
            end
            local scriptName = v1[1]
            local mainCmdID = v1[2]
            local subCmdID = v1[3]
            print(scriptName, mainCmdID, subCmdID)
            local packet = require ("Main.NetSystem.Packet." .. scriptName)
            packet._wMainCmdID = mainCmdID
            packet._wSubCmdID = subCmdID
            local tableKey = bitLib.blshift(mainCmdID, 16) + subCmdID
            if self._msgPacketTable[k][tableKey] ~= nil then
                printError("RegisterAllPacket tableKey exist Error: %s", scriptName)
            end
            self._msgPacketTable[k][tableKey] = packet
            print("register success!", mainCmdID, subCmdID, scriptName, k, tableKey)
        end
    end
end

--连接登录服务器
function NetSystem:ConnectLoginServer()
    if self._LoginSocket == nil then
        self._LoginSocket = SocketTCP.new()
        self._LoginSocket:setName("LoginSocket")
        self._LoginSocket:SetTag(1)
    end
    if self._LoginSocket.isConnected ~= true then
        self._LoginSocket:connect(LOGIN_SERVER_IP, LOGIN_SERVER_PORT)
    end
end

--连接游戏服务器
function NetSystem:ConnectGameServer(ip, port)
    if self._GameSocket ~= nil  then
        self._GameSocket:close()
        self._GameSocket = nil
    end
    self._GameSocket = SocketTCP.new()
    self._GameSocket:setName("GameSocket")
    self._GameSocket:SetTag(2)
    if self._GameSocket.isConnected ~= true then
        self._GameSocket:connect(ip, port)
    else
        print("ConnectGameServer connected")
    end
end
--是否已连接登录服务器
function NetSystem:IsConnectLoginServer()
    if self._LoginSocket == nil then
        return false
    end
    return self._LoginSocket.isConnected 
end

--是否有效的网络包
function NetSystem:GetNetPacket(tag, tableKey)
    if tag ~= 1 and tag ~= 2 then
         printError("NetSystem:GetNetPacket invalid tag: %d", tag)
    end
    return self._msgPacketTable[tag][tableKey]
end

--发送登录服务器Packet
function NetSystem:SendPacketToLoginServer(packet)
	if self._LoginSocket == nil then
		print("SendLoginPacket error self._LoginSocket == nil ")
		return
	end
    --print("NetSystem:SendPacketToLoginServer ", self._LoginSocket._SendSeed)
    self._LoginSocket:SendPacket(packet)
    packet:Destroy()
end

--发送游戏服务器Packet
function NetSystem:SendGamePacket(packet)
    if self._GameSocket == nil then
        print("SendLoginPacket error self._GameSocket == nil ")
        return
    end
    --print("NetSystem:SendPacketToLoginServer ", self._LoginSocket._SendSeed)
    self._GameSocket:SendPacket(packet)
    packet:Destroy()
end

--
function NetSystem.OnConnected(param)
    local beginTime = os.clock()
    print("NetSystem.OnConnected", beginTime, param._usedata.name)
    
    --[[
   --测试 网络包
    if param._usedata.name == "_LoginSocket" then
        local csLoginPacket = (require "Main.NetSystem.Packet.CSLoginPacket").new()
        csLoginPacket:Init()
        GetNetSystem():SendPacketToLoginServer(csLoginPacket)
        local endTime = os.clock()
        print("use time 1---", endTime - beginTime)

        local encryptInstance = LuaLib.CEncrypt:new()
        local testStr = encryptInstance:MD5EncryptString32("222222")
        print("testStr", testStr);
        local endedTime = os.clock()
        print("use time", endedTime - beginTime)
        --self:SendPacketToLoginServer(csLoginPacket)
    end
    ]]--
    --[[
    --测试 网络包
    if param._usedata.name == "_TestSocket" then
        local csLoginPacket = (require "Main.NetSystem.Packet.CSLoginPacket").new()
        csLoginPacket:Init()
        GetNetSystem()._TestSocket:SendPacket(csLoginPacket)
        local endTime = os.clock()
        print("use time 1---", endTime - beginTime)

        local encryptInstance = LuaLib.CEncrypt:new()
        local testStr = encryptInstance:MD5EncryptString32("222222")
        print("testStr", testStr);
        local endedTime = os.clock()
        print("use time", endedTime - beginTime)
        --self:SendPacketToLoginServer(csLoginPacket)
    end
    ]]--
end


return NetSystem
