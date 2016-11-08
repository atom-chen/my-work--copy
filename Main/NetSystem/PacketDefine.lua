----
-- 文件名称：PacketDefine.lua
-- 功能描述：网络包定义
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-7-11
--  修改：修改结构定义，  由于 CmdID会存在重复的情况，所以添加登陆服务器与游戏服务器标识  20160811

--注意大括号后面的,
local NetPacketDefine = 
{
    --登陆服务器
    [1] = 
    {
        --Lua脚本文件名      mainCmdID  subCmdID
       ----------------------------------------CS  客户端-->服务器------------------------------------------------------
        --登录
        {"CSLoginPacket", 100, 2},
        {"CSRegisterPacket", 100, 3},
        
        ----3 用户服务
        --仓库 存款 取款，
         {"CSLCangKuSaveScore", 3, 400},
         {"CSLCangKuTakeScore", 3, 401},
        --CDK兑换
         {"CSGPExchange", 3, 412},

        -----------------------------------------SC 服务器-->客户端------------------------------------------------------
       --登录成功
        {"SCLoginPacket", 100, 100},
        --登录完成
        {"SCLoginFinishPacket", 100, 102},
        --登录失败
        {"SCLoginFailurePacket", 100, 101},
        --升级提示
        {"SCUpdateNotify", 100, 200},
        --网络检测
        {"SCDetectSocket", 0, 1},
        --ServerList种类列表
        {"SCServerListKind", 101, 101},
        --ServerList 
        {"SCServerListType", 101, 100},
        --GameServer
        {"SCGameServerList", 101, 102},
        --列表发送完成
        {"SCGameListFinish", 101, 200},
        --        CDK兑换
        {"SCGPExchangeSuccess", 3, 413},
        --仓库取款成功
        {"SCCangKuSuccell", 3, 405},
        --仓库取款失败
        {"SCCangKuTakeFail", 3, 406},

    },
    --游戏服务器
    [2] = 
    {
        --Lua脚本文件名      mainCmdID  subCmdID
        ----------------------------------------CS  客户端-->服务器------------------------------------------------------
        {"CSLogonMobile", 1, 2},
            --GameServer 坐下
        {"CSGRUserSitDown", 3, 3},
        --起立
        {"CSGRUserStandUp", 3, 4},
        --        CDK兑换
        {"CSGRExchange", 5, 6},
        --100 框架消息
        --游戏配置
        {"CSGFGameOption", 100, 1},
        --用户准备
        {"CSGFUserReady", 100, 2},
        --购买子弹
        {"CSGFBuyBullet", 200, 2},
        --开炮
        {"CSGFUserShoot", 200, 3},
        --子弹碰到鱼
        {"CSGFHitFish", 200, 7},
        --加减炮
        {"CSFireMultiple", 200, 8},
        --机器人锁鱼
        {"CSGSLockFish", 200, 10},
        --退出游戏
        {"CSGSQuitGame", 200, 11},

        -----------------------------------------SC 服务器-->客户端-------------------------------------------------------
         --网络检测
        {"SCGRDetectSocket", 0, 1},
        --登陆
        {"SCGRLogonFailPacket", 1, 101 },
        {"SCGRLoginSuccess", 1, 100},
        {"SCGRLoginFinish", 1, 102},

        --2配置命令
        --列表配置
        {"SCGRConfigColumn", 2, 100},   
        --房间配置
        {"SCGRConfigServer", 2, 101},
        --道具配置
        {"SCGRConfigProperty", 2, 102},
        --配置完成
        {"SCGRConfigFinish", 2, 103},
        --玩家权限
        {"SCGRConfigUserRight", 2, 104},

        --3 用户信息
        --用户进入
        {"SCGRUUserEnter", 3, 100},
        --用户分数
        {"SCGRUserScore", 3, 101},
        --用户状态
        {"SCGRUserState", 3, 102},
        --
        {"SCGRRequestFail", 3, 103},    

        --4 状态信息
        --桌子信息
        {"SCGRTableInfo", 4, 100},
        --桌子状态
        {"SCGRTableState", 4, 101},

        --100
        --游戏状态
        {"SCGFGameState", 100, 100},
        --系统消息
        {"SCGFSystemMessage", 100, 200},
        --游戏场景
        {"SCGFGameScene", 100, 101},
  
        --200  捕鱼游戏过程
        --鱼的轨迹坐标
        {"SCGSTracePoint", 200, 102},
        {"SCGSUserShoot", 200, 103},
        {"SCGSCaptureFish", 200, 104},
        {"SCGSBulletCount", 200, 105},
        --切换场景
        {"SCGSChangeScene", 200, 108},
        {"SCGSCellScore", 200, 110},
        --彩金信息
        {"SCGSBonusInfo", 200, 111},
        --锁鱼
        {"SCGSLockFish", 200, 113},
        --更新Boss积分
        {"SCGSUpdateBossScore", 200, 114},
        --机器人锁鱼
        {"SCGSLockFishAndroid", 200, 115},
        --游戏结束 --无用的包
        {"SCGSGameEnd", 200, 116},
        --超级炮
        {"SCGSSuperCannon", 200, 117},      

        --1000 系统命令
        {"SCSystemMessage", 1000, 1},
    },


};

return NetPacketDefine


