----
-- 文件名称：GameFishManager
-- 功能描述：
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-07-16
--  修改：
local GameFish = require("Main.Logic.GameFish")
local GameFishManager = class("GameFishManager")
local mathCeil = math.ceil
local tableInsert = table.insert
local tableRemove = table.remove
--格子大小
local TILES_SIZE_Y = 360
local TILES_SIZE_X = 360

local pairs = pairs

--测试用 随机列表
local TEMP_TEST_FISH = {1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 15300, 15301, 15302, 15403, 15404, 15405}
--临时测试
--随机创建鱼
function GameFishManager:CreateRandomFish()
	local randID = math.random(1, 21)
	return self:CreateFishBySpriteID(TEMP_TEST_FISH[randID])
end
--随机鱼的path
function GameFishManager:GetRandomPath()
	local randPath = math.random(1, 200)
	return randPath
end


--构造
function GameFishManager:ctor()
    --Fish
    self._FishTable = nil
    --当前ID
    self._CurrentID = 0
    --当前数目 
    self._CurrentCount = 0
    --UI上展示用Fish
    self._UIFishList = nil
    --UI上展示用Fish当前ID
    self._CurrentUIID = 0
    --Scene的弱引用
    self._CurScene = nil

    --对象池
    self._FishPoolFree = nil

end 

--初始化
function GameFishManager:Init(curScene)
	if self._FishTable == nil then
		self._FishTable = {}
	end
	self._CurrentID = 0
	if self._UIFishList == nil then
		self._UIFishList = {}
	end
	self._CurrentUIID = 0
	self._CurrentCount = 0
	self._CurScene = curScene
    self._FishPoolFree = {}
	--预先创建 300 GameFish的Lua对象
	for i = 1, 300 do
		local newFish = GameFish.new()
		tableInsert(self._FishPoolFree, newFish)
	end
end

--销毁
function GameFishManager:Destroy()
	self:DestroyAllUIFish()
	self:DestroyAllFish()
	self._FishTable = nil
	self._UIFishList = nil
	self._CurrentID = 0
	self._CurrentUIID = 0
	self._CurrentCount = 0
	self._CurScene = nil
    self._FishPoolFree = nil
end

--
function GameFishManager:GetFreeLuaFish()
	local len = #self._FishPoolFree	
	if len == 0 then
		local newFish = GameFish.new()
		tableInsert(self._FishPoolFree, newFish)
		print("not enough, create fish ......")
	end
	local curFish = tableRemove(self._FishPoolFree)
	return curFish
end
--
function GameFishManager:AddFreeLuaFish(curFish)
	tableInsert(self._FishPoolFree, curFish)

end

--创建鱼通过表格中的ID
function GameFishManager:CreateFishBySpriteID(spriteID)
	local newFish = self:GetFreeLuaFish()--GameFish.new()
	newFish:Init(spriteID)
	self._CurrentID = self._CurrentID + 1
	self._CurrentCount  =  self._CurrentCount + 1
	--print("CreateFishBySpriteID ", self._CurrentID)
	self._FishTable[self._CurrentID] = newFish
	newFish:SetClientID(self._CurrentID)
	return newFish
end
--创建UI上显示用的Fish,锁定鱼时展示用
function GameFishManager:CreateSceneUIFish(spriteID)
	local newFish = self:GetFreeLuaFish() --GameFish.new()
	newFish:Init(spriteID)
	self._CurrentUIID = self._CurrentUIID + 1
	self._UIFishList[self._CurrentUIID] = newFish
	newFish:SetClientID(self._CurrentUIID)
	return newFish
end
--获取UI上展示用的Fish
function GameFishManager:GetUIFishByClient(uiClientID)
	return self._UIFishList[uiClientID]
end

--获取Fish
function GameFishManager:GetFishByServerID(serverID)
	local resultFish = nil
	local resultID = nil
	for k, v in pairs(self._FishTable)do
		if v:GetServerID() == serverID then
			resultFish = v
			resultID = k
			break
		end
	end
	return resultFish, resultID
end
--销毁 鱼
function GameFishManager:DestroyFish(fishID, tag)
	local fish = self._FishTable[fishID] 
	fish:Destroy()
	self:AddFreeLuaFish(fish)
	self._FishTable[fishID] = nil
	self._CurrentCount = self._CurrentCount - 1
	--print("DestroyFish", fishID, self._CurrentCount, tag)
end
--删除所有的Fish
function GameFishManager:DestroyAllFish()
	for k, v in pairs(self._FishTable)do
		v:Destroy()
		self:AddFreeLuaFish(v)
	end
	self._FishTable = {}
end
--销毁 UI上展示用的鱼
function GameFishManager:DestroyUIFish(uiClientID)
	local clientFish = self._UIFishList[uiClientID]
	clientFish:Destroy()
	self:AddFreeLuaFish(clientFish)
	self._UIFishList[uiClientID] = nil
end
--销毁 删除所有UI上锁定鱼
function GameFishManager:DestroyAllUIFish()
	if self._UIFishList ~= nil then
		for k, v in pairs(self._UIFishList)do
			v:Destroy()
			self:AddFreeLuaFish(v)
		end
	end

	self._UIFishList = {}
end
--帧更新
function GameFishManager:Update(deltaTime)
	if self._FishTable == nil then
		return
	end
	--将所有鱼填充到所占的格子里
	self._CurScene:ClearTiles()
    local minX 
    local maxX 
    local minY 
    local maxY 
    local startRow 
    local endRow 
    local startCol 
    local endCol
	for k, v in pairs(self._FishTable)do
		local x, y = v:GetPosition()
		v:Update(deltaTime)
		if v:IsCanCheckBounds() == true then
			if v:IsInvalidPos(x, y) == true then
				self:DestroyFish(k, "IsInvalidPos")
			else
				--填充到场景格子里
			   local fishRect =  v:GetFishBoundingBox()
	           if fishRect ~= nil then
	                minX = fishRect.x
	                maxX = minX + fishRect.width
	                minY = fishRect.y
	                maxY = minY + fishRect.height
	                startRow = mathCeil(minY / TILES_SIZE_Y)
	                endRow = mathCeil(maxY / TILES_SIZE_Y)
	                startCol = mathCeil(minX / TILES_SIZE_X)
	                endCol = mathCeil(maxX / TILES_SIZE_X)
	                startRow = self._CurScene:FixTileRow(startRow)
	                endRow = self._CurScene:FixTileRow(endRow)
	                startCol = self._CurScene:FixTileCol(startCol)
	                endCol = self._CurScene:FixTileCol(endCol)
	                for i = startRow, endRow do
	                    for j = startCol, endCol do
	                        self._CurScene:AddToTile(i, j, k)
	                    end
	                end
	           end
			end
		end 
	end
end


return GameFishManager.new()