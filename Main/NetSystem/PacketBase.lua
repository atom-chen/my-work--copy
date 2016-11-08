----
-- 文件名称：PacketBase.lua
-- 功能描述：网络包
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-2
--  修改：

local ByteArray = require "Main.Utility.ByteArray"
local PacketBase = class("PacketBase")
local PacketKey = 0xA55AA55A

PacketBase.ENDIAN = ByteArray.ENDIAN_LITTLE
PacketBase.CMDSIZE = 4

--构造
function PacketBase:ctor()
    --数据流
    self._OutputStream = nil
    --------------------包头信息 begin--------------------
    --版本标识
    self._cbVersion = 0x05
    --效验字段
    self._cbCheckCode = 0xcc
    --数据包大小
    self._wPacketSize = 0
    --主命令码
    self._wMainCmdID = nil
    --子命令码
    self._wSubCmdID = nil
    --加密Key
    self._dwXorKey = nil
   --------------------包头信息 end--------------------
   self:Init()
end

--初始化
function PacketBase:Init()
    if self._OutputStream == nil then
        self._OutputStream = ByteArray.new(PacketBase.ENDIAN)
    end
    
end

--清理
function PacketBase:Destroy()
	self._OutputStream = nil
end

--读流
function PacketBase:Read(byteStream)
    --printInfo("PacketBase:Read type = %d buffer: %s", self._PacketID, byteStream:toString(16))
    
end

--写TCP头信息(8字节头)
function PacketBase:WriteHead()
    if self._OutputStream == nil then
        return
    end
    self._OutputStream:writeByte(self._cbVersion)
    self._OutputStream:writeByte(self._cbCheckCode)
    self._OutputStream:writeUShort(self._wPacketSize)
    self._OutputStream:writeUShort(self._wMainCmdID)
    self._OutputStream:writeUShort(self._wSubCmdID)
end

--写流
function PacketBase:Write()
    print("=====================")
end


--发送时获取发送的stream isFirst 是否是连接建立后的第一次发包 sendPacketCount
function PacketBase:GetPacketByteStream(seed, xorKey, sendPacketCount)
    self:WriteHead()
    self:Write()
    --print("send packet GetPacketByteStream  ", self._wMainCmdID, self._wSubCmdID, self._cbCheckCode, sendPacketCount, seed, xorKey)
    --print("send packet content:", self._OutputStream:toString(16))
    local len = self._OutputStream:getLen()
    local newStr, wSize, sendRound, dwXorKey = EncryptBufferLua(self._OutputStream:getBytes(1, len), seed, xorKey, sendPacketCount);
    --dump(newStr)
    --print("C++ EncryptBufferLua", newStr, wSize, sendRound, dwXorKey)
    self._OutputStream:setPos(1)
    self._OutputStream:writeBuf(newStr)
    --print("after EncryptBufferLua packet content:", self._OutputStream:toString(16))
     --print("send packet GetPacketByteStream  end ", newStr, self._wMainCmdID, self._wSubCmdID, wSize, sendRound, dwXorKey)
    return self._OutputStream:getPack(), sendRound, dwXorKey
end

--接收到包的处理
function PacketBase:Execute()
    
end


return PacketBase


--[[
--生成加密Key（废弃的接口）
function PacketBase:GenerateKey()
    --约定值

    local ranNumber = math.random(1, 2^32-1)
    self._dwXorKey = bitLib.bxor(ranNumber, PacketKey)
    self._dwXorKey = ConvertLuaDWord(self._dwXorKey)
    return self._dwXorKey
end

--随机映射(废弃的接口)
local function SeedRandMap(wSeed)
    local result =  wSeed * 241103 + 2533101
    --result 如果超出DWord
    result = ConvertLuaDWord(result)
    local resultFinal = bitLib.blshift(result, 16)
    --resultFinal 如果超出 Word
    resultFinal = ConvertLuaWord(resultFinal)
    return resultFinal
end

--加密(废弃的接口，Lua中的位运算耗时太高，移到C++中去了)
function PacketBase:Encryt(xorKey, seed)
    print("PacketBase:Encryt ", os.clock(), seed)
    local bufferLen = self._OutputStream:getLen()
    local opBuffer = self._OutputStream._buf
    local isFirst = false
    if seed == 0 then
        isFirst = true
    end
    local oriSeed = seed
    --TCPCommand 长度 (World * 2)
    local commandLen = 4 
    local wEncryptSize = bufferLen - commandLen
    local wSnapCount = 0
    local sizeDword = 4
    local mod = (wEncryptSize % sizeDword) 
    --将数据变为四字节的倍数,不足补0
    if mod ~= 0 then
        wSnapCount = sizeDword - mod
        for i = 1, wSnapCount do
            opBuffer[bufferLen + i] = 0
        end
        --print("Encryt 0 ", wSnapCount)
    end


    local stringByte = string.byte
    --校验和  查词典写入映射值(key value)
    local cbCheckCode = 0
    for i = commandLen + 1,  bufferLen do
        local currentValue = stringByte(opBuffer[i])
        cbCheckCode = cbCheckCode + currentValue
        cbCheckCode = ConvertLuaByte(cbCheckCode)
        local nIndex = ConvertLuaByte(seed + cbCheckCode)
        opBuffer[i] = c_SendByteMap[nIndex]
        seed = seed + 11
        seed = ConvertLuaInt(seed)
    end
    cbCheckCode = bitLib.bnot(cbCheckCode) + 1
    cbCheckCode = ConvertLuaByte(cbCheckCode)
    print("PacketBase:Encryt after map before Encrypt", self._OutputStream:toString(16), os.clock())
    --加密数据
    local wEncrypCount = (wEncryptSize + wSnapCount) / sizeDword;
    local dwIndex = 1 + commandLen
    local stream = self._OutputStream
    stream:setPos(dwIndex)
    for i = 1, wEncrypCount do
        local currentValue = stream:readULong()
        local newValue = bitLib.bxor(currentValue, xorKey) 
        newValue = ConvertLuaDWord(newValue)
        stream:setPos(dwIndex)
        stream:writeULong(newValue)
        stream:setPos(dwIndex)
        local currentWordValue = stream:readUShort()
        xorKey = SeedRandMap(currentWordValue)
        currentWordValue = stream:readUShort()
        local dwValue =  ConvertLuaDWord(SeedRandMap(currentWordValue))
        local newValue = bitLib.blshift(dwValue, 16)
        newValue = ConvertLuaDWord(newValue)
        xorKey = bitLib.bor(xorKey, newValue)
        xorKey = bitLib.bxor(xorKey, PacketKey)
        dwIndex = dwIndex + 4 -- 4: DWROD占用字节数
    end

    if isFirst then
        print("write first ")
        --8: Head大小
        stream:InsertDword(xorKey, 8)
    end
    print("PacketBase:Encryt  after Encrypt", self._OutputStream:toString(16), os.clock())
    return seed, xorKey
end
--解密(废弃的接口)
function PacketBase:Decryt()

end

]]
--TCP_Head C++数据结构
--[[
    //数据包命令信息
    struct TCP_Command
    {
        WORD                                wMainCmdID;                         //主命令码
        WORD                                wSubCmdID;                          //子命令码
    };

    //数据包结构信息
    struct TCP_Info
    {
        BYTE                                cbVersion;                          //版本标识
        BYTE                                cbCheckCode;                        //效验字段
        WORD                                wPacketSize;                        //数据大小
    };

    //网络包头
    struct TCP_Head
    {
        TCP_Info                            TCPInfo;                            //基础结构
        TCP_Command                         CommandInfo;                        //命令信息
    };
]]

--[[
--发送映射
local c_SendByteMap =
{
    0x70,0x2F,0x40,0x5F,0x44,0x8E,0x6E,0x45,0x7E,0xAB,0x2C,0x1F,0xB4,0xAC,0x9D,0x91,
    0x0D,0x36,0x9B,0x0B,0xD4,0xC4,0x39,0x74,0xBF,0x23,0x16,0x14,0x06,0xEB,0x04,0x3E,
    0x12,0x5C,0x8B,0xBC,0x61,0x63,0xF6,0xA5,0xE1,0x65,0xD8,0xF5,0x5A,0x07,0xF0,0x13,
    0xF2,0x20,0x6B,0x4A,0x24,0x59,0x89,0x64,0xD7,0x42,0x6A,0x5E,0x3D,0x0A,0x77,0xE0,
    0x80,0x27,0xB8,0xC5,0x8C,0x0E,0xFA,0x8A,0xD5,0x29,0x56,0x57,0x6C,0x53,0x67,0x41,
    0xE8,0x00,0x1A,0xCE,0x86,0x83,0xB0,0x22,0x28,0x4D,0x3F,0x26,0x46,0x4F,0x6F,0x2B,
    0x72,0x3A,0xF1,0x8D,0x97,0x95,0x49,0x84,0xE5,0xE3,0x79,0x8F,0x51,0x10,0xA8,0x82,
    0xC6,0xDD,0xFF,0xFC,0xE4,0xCF,0xB3,0x09,0x5D,0xEA,0x9C,0x34,0xF9,0x17,0x9F,0xDA,
    0x87,0xF8,0x15,0x05,0x3C,0xD3,0xA4,0x85,0x2E,0xFB,0xEE,0x47,0x3B,0xEF,0x37,0x7F,
    0x93,0xAF,0x69,0x0C,0x71,0x31,0xDE,0x21,0x75,0xA0,0xAA,0xBA,0x7C,0x38,0x02,0xB7,
    0x81,0x01,0xFD,0xE7,0x1D,0xCC,0xCD,0xBD,0x1B,0x7A,0x2A,0xAD,0x66,0xBE,0x55,0x33,
    0x03,0xDB,0x88,0xB2,0x1E,0x4E,0xB9,0xE6,0xC2,0xF7,0xCB,0x7D,0xC9,0x62,0xC3,0xA6,
    0xDC,0xA7,0x50,0xB5,0x4B,0x94,0xC0,0x92,0x4C,0x11,0x5B,0x78,0xD9,0xB1,0xED,0x19,
    0xE9,0xA1,0x1C,0xB6,0x32,0x99,0xA3,0x76,0x9E,0x7B,0x6D,0x9A,0x30,0xD6,0xA9,0x25,
    0xC7,0xAE,0x96,0x35,0xD0,0xBB,0xD2,0xC8,0xA2,0x08,0xF3,0xD1,0x73,0xF4,0x48,0x2D,
    0x90,0xCA,0xE2,0x58,0xC1,0x18,0x52,0xFE,0xDF,0x68,0x98,0x54,0xEC,0x60,0x43,0x0F
};

--接收映射
local c_RecvByteMap =
{
    0x51,0xA1,0x9E,0xB0,0x1E,0x83,0x1C,0x2D,0xE9,0x77,0x3D,0x13,0x93,0x10,0x45,0xFF,
    0x6D,0xC9,0x20,0x2F,0x1B,0x82,0x1A,0x7D,0xF5,0xCF,0x52,0xA8,0xD2,0xA4,0xB4,0x0B,
    0x31,0x97,0x57,0x19,0x34,0xDF,0x5B,0x41,0x58,0x49,0xAA,0x5F,0x0A,0xEF,0x88,0x01,
    0xDC,0x95,0xD4,0xAF,0x7B,0xE3,0x11,0x8E,0x9D,0x16,0x61,0x8C,0x84,0x3C,0x1F,0x5A,
    0x02,0x4F,0x39,0xFE,0x04,0x07,0x5C,0x8B,0xEE,0x66,0x33,0xC4,0xC8,0x59,0xB5,0x5D,
    0xC2,0x6C,0xF6,0x4D,0xFB,0xAE,0x4A,0x4B,0xF3,0x35,0x2C,0xCA,0x21,0x78,0x3B,0x03,
    0xFD,0x24,0xBD,0x25,0x37,0x29,0xAC,0x4E,0xF9,0x92,0x3A,0x32,0x4C,0xDA,0x06,0x5E,
    0x00,0x94,0x60,0xEC,0x17,0x98,0xD7,0x3E,0xCB,0x6A,0xA9,0xD9,0x9C,0xBB,0x08,0x8F,
    0x40,0xA0,0x6F,0x55,0x67,0x87,0x54,0x80,0xB2,0x36,0x47,0x22,0x44,0x63,0x05,0x6B,
    0xF0,0x0F,0xC7,0x90,0xC5,0x65,0xE2,0x64,0xFA,0xD5,0xDB,0x12,0x7A,0x0E,0xD8,0x7E,
    0x99,0xD1,0xE8,0xD6,0x86,0x27,0xBF,0xC1,0x6E,0xDE,0x9A,0x09,0x0D,0xAB,0xE1,0x91,
    0x56,0xCD,0xB3,0x76,0x0C,0xC3,0xD3,0x9F,0x42,0xB6,0x9B,0xE5,0x23,0xA7,0xAD,0x18,
    0xC6,0xF4,0xB8,0xBE,0x15,0x43,0x70,0xE0,0xE7,0xBC,0xF1,0xBA,0xA5,0xA6,0x53,0x75,
    0xE4,0xEB,0xE6,0x85,0x14,0x48,0xDD,0x38,0x2A,0xCC,0x7F,0xB1,0xC0,0x71,0x96,0xF8,
    0x3F,0x28,0xF2,0x69,0x74,0x68,0xB7,0xA3,0x50,0xD0,0x79,0x1D,0xFC,0xCE,0x8A,0x8D,
    0x2E,0x62,0x30,0xEA,0xED,0x2B,0x26,0xB9,0x81,0x7C,0x46,0x89,0x73,0xA2,0xF7,0x72
};
]]
