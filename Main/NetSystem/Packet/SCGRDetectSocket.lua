----
-- 文件名称：SCGRDetectSocket.lua
-- 功能描述：网络检测包 (一个特殊的包)
-- 文件说明：     --这是一个特殊的包，竟然回包与收包是同一ID   
-- 作    者：王雷雷
-- 创建时间：2016-7-12
--  修改：
local PacketBase = require "Main.NetSystem.PacketBase"
local SCGRDetectSocket = class("SCGRDetectSocket", PacketBase)

--构造
function SCGRDetectSocket:ctor()
    PacketBase.ctor(self)
    --接收到的流
    self._RecieveStream = nil
end

--初始化
function SCGRDetectSocket:Init()
    PacketBase.Init(self)
    
end

--销毁
function SCGRDetectSocket:Destroy()
    PacketBase.Destroy(self)
    self._RecieveStream = nil
    print("SCGRDetectSocket:Destroy")
end

--包的读取
function SCGRDetectSocket:Read(byteStream)
    --print("SCGRDetectSocket:Read ", byteStream)
    self._RecieveStream = byteStream
end

--写包(特殊包的写，其它网络包不会出现即读又写的情况)
function SCGRDetectSocket:Write()
    --前四个字节是cmdInfo,所以从5开始
    self._OutputStream:writeBytes(self._RecieveStream, 5, self._RecieveStream:getLen() - 5)
end

--包处理(特殊的包，原样发出)
function SCGRDetectSocket:Execute()
   --print("SCGRDetectSocket:Execute ")
   local replyPacket = SCGRDetectSocket.new()
   replyPacket._RecieveStream = self._RecieveStream
   NetSystem:SendGamePacket(replyPacket)
end

return SCGRDetectSocket
