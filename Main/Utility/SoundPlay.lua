-- 
-- 文件名称：SoundPlay.lua
-- 功能描述：音效播放 辅助函数
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-9-18
--  修改：
-- 
local AudioEngine = ccexp.AudioEngine
local TableDataManager = TableDataManager
SoundPlay = class("SoundPlay")
--构造
function SoundPlay:ctor()
	--当前正在播放的背景音乐id
	self._CurPlayMusicID = -1
	--当前播放的背景音乐配置表中的ID
	self._CurMusicTableID = -1
	--播放方式
	self._CurPlayMusicType = 1
end

--播放音效
function SoundPlay:PlaySoundByID(id)
	
	if TableDataManager == nil then
		TableDataManager = _G["TableDataManager"]
	end
	local soundCfgData = TableDataManager._SoundData[id]
	if soundCfgData ~= nil then
		local settngCfgData = ServerDataManager._ConfigData
		if settngCfgData._EnableMusic == 0 and soundCfgData.soundType == 2 then
			self._CurMusicTableID = id
			self._CurPlayMusicType = 1
			return -1
		end
    	if settngCfgData._EnableEffect == 0 and soundCfgData.soundType == 1 then
    		return -1
    	end
		--音乐
		local curID = AudioEngine:play2d(soundCfgData.fileName, (soundCfgData.isLoop == 1))
		if soundCfgData.soundType == 2 then
			self._CurPlayMusicID = curID
			self._CurMusicTableID = id
			self._CurPlayMusicType = 1
		end
		return curID
	end
end

--停止所有
function SoundPlay:StopAllSound()
	AudioEngine:stopAll()
	self._CurPlayMusicID = -1
end

--播放捕鱼中的音效
function SoundPlay:PlayFishSoundByID(id)
	local soundCfgData = TableDataManager._FishSoundData[id]
	if soundCfgData ~= nil then
		local settngCfgData = ServerDataManager._ConfigData
		if settngCfgData._EnableMusic == 0 and soundCfgData.soundType == 2 then
			self._CurMusicTableID = id
			self._CurPlayMusicType = 2
			return -1
		end
    	if settngCfgData._EnableEffect == 0 and soundCfgData.soundType == 1 then
    		return -1
    	end

		local curID = AudioEngine:play2d(soundCfgData.fileName, (soundCfgData.isLoop == 1))
		if soundCfgData.soundType == 2 then
			self._CurPlayMusicID = curID
			self._CurMusicTableID = id
			self._CurPlayMusicType = 2
		end
		return curID
	end
end

--停止某个音效()
function SoundPlay:StopFishSoundByID(id)
	if self._CurPlayMusicID == id then
		self._CurPlayMusicID = -1
	end
	return AudioEngine:stop(id)
end

--停止当前背景音乐
function SoundPlay:StopCurBgMusic()
	if self._CurPlayMusicID ~= -1 then
		AudioEngine:stop(self._CurPlayMusicID)
		self._CurPlayMusicID = -1
	end
end

--重新播放背景音乐
function SoundPlay:ResumeCurBgMusic()
	if self._CurMusicTableID ~= -1 then
		if self._CurPlayMusicType == 1 then
			self:PlaySoundByID(self._CurMusicTableID)
		else
			self:PlayFishSoundByID(self._CurMusicTableID)
		end
	end
end

return SoundPlay
