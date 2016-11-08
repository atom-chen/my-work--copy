----
-- 文件名称：GameEvent.lua
-- 功能描述：事件定义
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-06-30
--  修改：



--事件   全局
GameEvent = 
{
    GameEvent_Test = "TestEvent",
    
    --网络相关 copy from SocketTcp.lua
    NE_CONNECTED = "SOCKET_TCP_CONNECTED",
    NE_CONNECTFAIL = "EVENT_CONNECT_FAILURE",
    
    --测试
    --主角数据改变
    GE_UserInfoChange = "GE_UserInfoChange",
    --签到数据改变
    GE_QianDaoChange = "GE_QianDaoChange",
    GE_ServerGameList = "GE_ServerGameList",
    GE_ServerGameTypeList = "GE_ServerGameTypeList",
    --物品数据改变
    GE_ITEM_CHANGE = "GE_ITEM_CHANGE",
    --排行榜数据改变
    GE_RANK_CHANGE = "GE_Rank_Change",
    --游戏服务器登陆成功
    GE_GSLogin_Success = "GE_GSLogin_Success",
    --游戏房间玩家刷新
    GE_GSRoom_UserChange = "GE_GSRoom_UserChange",
    --桌子用户信息改变
    GE_GSRoom_TableChange = "GE_GSRoom_TableChange",
    --抽奖排行榜数据改变
    GE_CJRankDataChange = "GE_CJRankDataChange",
}