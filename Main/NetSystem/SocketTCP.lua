--[[
For quick-cocos2d-x
SocketTCP lua
@author zrong (zengrong.net)
Creation: 2013-11-12
Last Modification: 2013-12-05
@see http://cn.quick-x.com/?topic=quickkydsocketfzl
]]
local SOCKET_TICK_TIME = 0.1 			-- check socket data interval
local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local scheduler = require("Main.NetSystem.scheduler")
local socket = require "socket"
local ByteArray = require "Main.Utility.ByteArray"
local PacketParse = require("Main.NetSystem.PacketParser")
local SocketTCP = class("SocketTCP")

SocketTCP.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTCP.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTCP.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTCP.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

SocketTCP._VERSION = socket._VERSION
SocketTCP._DEBUG = socket._DEBUG
SocketTCP._ENDIAN = ByteArray.ENDIAN_BIG
--modify 
local EventSystem = EventSystem

function SocketTCP.getTime()
	return socket.gettime()
end

function SocketTCP:ctor(__host, __port, __retryConnectWhenFailure)

    self.host = __host
    self.port = __port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.name = 'SocketTCP'
	self.tcp = nil
	self.isRetryConnect = __retryConnectWhenFailure
	self.isConnected = false
	--加密相关
	self._SendSeed = 0
	self._SendXorKey = 0
	self._RecieveXorKey = 0
	self._RecieveSeed = 0
	self._SendPacketCount = 0
	self._PacketParser = nil
	self._Tag = 0
	self._NetUseTimer = 0
end


function SocketTCP:dispatchEvent(eventName)
    EventSystem:DispatchEvent(eventName)
end

function SocketTCP:dispatchEventWithData(eventName, data)
    EventSystem:DispatchEvent(eventName, data)
end

function SocketTCP:setName( __name )
	self.name = __name
	return self
end

function SocketTCP:SetTag(tag)
	self._Tag = tag
end

function SocketTCP:setTickTime(__time)
	SOCKET_TICK_TIME = __time
	return self
end

function SocketTCP:setReconnTime(__time)
	SOCKET_RECONNECT_TIME = __time
	return self
end

function SocketTCP:setConnFailTime(__time)
	SOCKET_CONNECT_FAIL_TIMEOUT = __time
	return self
end

function SocketTCP:connect(__host, __port, __retryConnectWhenFailure)
	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")
	--printInfo("%s.connect(%s, %d)", self.name, self.host, self.port)
	self.tcp = socket.tcp()
	self.tcp:settimeout(0)

	local function __checkConnect()
		local __succ = self:_connect()
		if __succ then
			self:_onConnected()
		end
		return __succ
	end

	if not __checkConnect() then
		-- check whether connection is success
		-- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
		local __connectTimeTick = function ()
			--printInfo("%s.connectTimeTick", self.name)
			if self.isConnected then return end
			self.waitConnect = self.waitConnect or 0
			self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
			if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
				self.waitConnect = nil
				self:close()
				self:_connectFailure()
			end
			__checkConnect()
		end
		self.connectTimeTickScheduler = scheduler.scheduleGlobal(__connectTimeTick, SOCKET_TICK_TIME)
	end
end

function SocketTCP:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	self.tcp:send(__data)
end

function SocketTCP:close( ... )
	printInfo("%s.close", self.name)
	self.tcp:close();
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler.unscheduleGlobal(self.tickScheduler) end
	self:dispatchEvent(SocketTCP.EVENT_CLOSE)
end

-- disconnect on user's own initiative.
function SocketTCP:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function SocketTCP:_connect()
	local __succ, __status = self.tcp:connect(self.host, self.port)
	--print("SocketTCP._connect:", self.host, self.port, __succ, __status)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function SocketTCP:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	self._SendPacketCount = 0
	self:dispatchEvent(SocketTCP.EVENT_CLOSED)
end

function SocketTCP:_onDisconnect()
	printInfo("%s._onDisConnect", self.name);
	self.isConnected = false
	self:dispatchEvent(SocketTCP.EVENT_CLOSED)
	self:_reconnect();
end

-- connecte success, cancel the connection timerout timer
function SocketTCP:_onConnected()
	printInfo("%s._onConnectd", self.name)
	self.isConnected = true
    self:dispatchEventWithData(SocketTCP.EVENT_CONNECTED, {name = self.name})
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end

	local __tick = function()
		local startTime = os.clock()
		while true do
			-- if use "*l" pattern, some buffer will be discarded, why?
			local __body, __status, __partial = self.tcp:receive("*a")	-- read the package body
			--print("body:", __body, "__status:", __status, "__partial:", __partial, self.name)
    	    if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
		    	self:close()
		    	if self.isConnected then
		    		self:_onDisconnect()
		    	else
		    		self:_connectFailure()
		    	end
		   		return
	    	end
		    if 	(__body and string.len(__body) == 0) or
				(__partial and string.len(__partial) == 0)
			then break end
			if __body and __partial then __body = __body .. __partial end
            --self:dispatchEventWithData({name=SocketTCP.EVENT_DATA, data=(__partial or __body), partial=__partial, body=__body})
            if self._PacketParser == nil then
            	self._PacketParser = PacketParse.new(self._Tag)
            	self._PacketParser:Init()
            end
            self._RecieveSeed,  self._RecieveXorKey = self._PacketParser:OnPacketData(__partial or __body, self._RecieveSeed,  self._RecieveXorKey)
		end
		local endTime = os.clock()
		--print("SocketTCP endTime ", endTime, startTime)
		self._NetUseTimer = endTime - startTime
	end
    
	-- start to read TCP data
	self.tickScheduler = scheduler.scheduleGlobal(__tick, SOCKET_TICK_TIME)
end

function SocketTCP:_connectFailure(status)
	printInfo("%s._connectFailure", self.name);
	self:dispatchEventWithData(SocketTCP.EVENT_CONNECT_FAILURE, {name = self.name})
	self:_reconnect();
end

-- if connection is initiative, do not reconnect
function SocketTCP:_reconnect(__immediately)
	if not self.isRetryConnect then return end
	printInfo("%s._reconnect", self.name)
	if __immediately then self:connect() return end
	if self.reconnectScheduler then scheduler.unscheduleGlobal(self.reconnectScheduler) end
	local __doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler.performWithDelayGlobal(__doReConnect, SOCKET_RECONNECT_TIME)
end

--发送数据包
function SocketTCP:SendPacket(msgPacket)
	if self._SendPacketCount == 0 then
		local oriKey = bitLib.bxor(0x00000010, 0xA55AA55A)
		self._SendXorKey = oriKey
		--print("SendPacket _SendSeed = 0 ", oriKey, self._SendXorKey)
		self._RecieveXorKey = self._SendXorKey
	end
	local data, seed, xorKey = msgPacket:GetPacketByteStream(self._SendSeed, self._SendXorKey, self._SendPacketCount)
    self:send(data)
    self._SendSeed = seed
    self._SendXorKey = xorKey
    self._SendPacketCount = self._SendPacketCount + 1

end

return SocketTCP
