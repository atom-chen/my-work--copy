----
-- 文件名称：PacketParser.lua
-- 功能描述：网络包解包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-2
--  修改：

local ByteArray = require "Main.Utility.ByteArray"
local PacketParser = class("PacketParser")


PacketParser.PACKET_VERSION_LEN = 1
PacketParser.PACKET_CHECKCODE_LEN = 1
PacketParser.PACKET_LEN = 2
PacketParser.PACKET_HEAD_SIZE = 8
PacketParser.PACKET_MAX_LEN = 16384
PacketParser.ENDIAN = ByteArray.ENDIAN_LITTLE

function PacketParser:ctor(tag)
	self._InputStream = nil
    --
    self._Tag = tag
end

--初始化
function PacketParser:Init()
	self._InputStream = ByteArray.new(self.ENDIAN)

end

--解包
function PacketParser:OnPacketData(data, seed, recvXorKey)
--local beginTime = os.clock()
   local __byteString = data
    if __byteString == nil then
        return
    end
    local newBufferData = 0
    local wSize = 0
    local seed = seed
    local recvXorKey = recvXorKey
    self._InputStream:setPos(self._InputStream:getLen() + 1)
    self._InputStream:writeBuf(__byteString)
    self._InputStream:setPos(1)
    --print(" PacketParser:OnPacketData ", self._InputStream:toString())
    local preLen = self.PACKET_HEAD_SIZE
    --根据self里包头定义解析包
    while self._InputStream:getAvailable() >= preLen do
        --print("getAvailable ", preLen, self._InputStream:getAvailable())
        local dataVersion = self._InputStream:readByte()
        if dataVersion ~= 0x05 then
            printError("Error Packet dataVersion not 0x05")
        end
        local checkCode = self._InputStream:readByte()
        local contentLen = self._InputStream:readUShort()
        local size = 4 --已读的字节数
        --print("getAvailable contentLen", contentLen)
        if self._InputStream:getAvailable() < contentLen - size then 
            -- restore the position to the head of data, behind while loop, 
            -- we will save this incomplete buffer in a new buffer,
            -- and wait next parsePackets performation.
            printf("received data is not enough, waiting... need %u, get %u", contentLen, self._InputStream:getAvailable())
            --printInfo("buf:", self._InputStream:toString())
            self._InputStream:setPos(self._InputStream:getPos() - size)
            break 
        end
        --
        if contentLen <= self.PACKET_MAX_LEN then
            --解密Buffer
            local decryptPos = self._InputStream:getPos() - size
            local bufferData = self._InputStream:getBytes(decryptPos, decryptPos + contentLen - 1)
            --print("bufferData ", decryptPos, contentLen, self._InputStream:getLen(), bufferData)
            --printInfo("bufferData %s ", bufferData)
            newBufferData, wSize, seed, recvXorKey = DecryptBufferLua(bufferData, seed, recvXorKey)
            local packetStream = ByteArray.new(self.ENDIAN)
            packetStream:writeBuf(newBufferData, 1, contentLen)
            --printInfo("new Packet ", packetStream:toString())
            packetStream:setPos(5)
            local mainCmdID = packetStream:readUShort()
            local subCmdID = packetStream:readUShort()
            --print("new Packet cmdID ", mainCmdID, subCmdID, wSize, seed, recvXorKey)
            local tableKey = bitLib.blshift(mainCmdID, 16) + subCmdID
            local netPacket = NetSystem:GetNetPacket(self._Tag, tableKey)
            if netPacket ~= nil then --if self:IsValidPacketType(type) then
                --printInfo("%d process packet type = %s, contentLen = %d",type, string.format("0x%x",type), contentLen)
                local newPacket = netPacket.new()
                newPacket:Read(packetStream)
                newPacket:Execute() 
                self._InputStream:setPos(self._InputStream:getPos() + contentLen - size)
            else
                --跳过该包不处理
                printInfo("skip packet cmdID %d %d contentLen = %d tag: %d", mainCmdID, subCmdID, contentLen, self._Tag)
                self._InputStream:setPos(self._InputStream:getPos() + contentLen - size)
            end
        else
           --error
            printError("invalid contentLen: %d", contentLen)
        end
    end
    -- clear buffer on exhausted
    if self._InputStream:getAvailable() <= 0 then
        self._InputStream = ByteArray.new(self.ENDIAN)
    else
        -- some datas in buffer yet, write them to a new blank buffer.
        printf("cache incomplete buff,len: %u, available: %u", self._InputStream:getLen(), self._InputStream:getAvailable())
        local __tmp = ByteArray.new(self.ENDIAN)
        self._InputStream:readBytes(__tmp, 1, self._InputStream:getAvailable())
        self._InputStream = __tmp
        printf("tmp len: %u, availabl: %u", __tmp:getLen(), __tmp:getAvailable())
        print("buf:", __tmp:toString())
    end
    --local endTime = os.clock()
    --print("PacketParser:OnPacketData use time: %f", endTime - beginTime)
    return seed, recvXorKey
end


return PacketParser