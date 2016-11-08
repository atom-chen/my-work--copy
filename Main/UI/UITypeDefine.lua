----
-- 文件名称：UITypeDefine
-- 功能描述：UI类型定义
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2016-6-28
--  修改：

--UI类型定义  全局的 
UIType = 
{
	--Logo
	UIType_Logo = 0,
	--登录
	UIType_Login = 1,
	--大厅
	UIType_Lobby = 2,
	--提示框
	UIType_MessageBox = 3,
	--背包
	UIType_Bag = 4,
	--排行榜
	UIType_Rank = 5,
	--房间列表
	UIType_RoomList = 6,
	--房间桌子列表
	UIType_RoomTableList = 7,
	--GameScene
	UIType_GameScene = 8,
	--兑换
    UIType_Cdk = 9,
	--客服
    UIType_Kefu = 10,
    --设置
    UIType_Setting = 11,
    --仓库
    UIType_CangKu = 12,
    --签到
    UIType_QianDao = 13,
    --反馈
    UIType_FanKui = 14,
    --抽奖
    UIType_ChouJiang = 15,
    --游戏加载条
    UIType_GameLoading = 16,
    --游戏更新UI
    UIType_Update = 17,
    --捕鱼帮助界面
    UIType_FishHelp = 18,
    --捕鱼结算界面 退出界面
    UIType_FishQuit = 19,


	UIType_Count = 100,
}


--UI脚本数据 全局的 
UIScriptData = 
{
	--Logo
	[UIType.UIType_Logo] = 
	{
		UIScript = "UILogo",
		UICSBName = "CSD/UI/UILogo.csb",
	},
	--登录
	[UIType.UIType_Login] = {
								UIScript = "UILogin",
								UICSBName = "CSD/UI/UILogin.csb",
							},
	--大厅	
    [UIType.UIType_Lobby] = {
                                UIScript = "UILobby",
								UICSBName = "CSD/UI/UILobby.csb",
							},
	--提示框
	[UIType.UIType_MessageBox] = 
							{
							    UIScript = "UIMessageBox",
								UICSBName = "CSD/UI/UIMessageBox.csb",

							},
	--背包
	[UIType.UIType_Bag] = 
					{
							UIScript = "UIBag",
							UICSBName = "CSD/UI/UIBag.csb",
					},
	--排行榜
	[UIType.UIType_Rank] = 
				{
						UIScript = "UIRank",
						UICSBName = "CSD/UI/UIRank.csb",
				},	
	--当前选择游戏的服务器房间列表
	[UIType.UIType_RoomList] = 
				{
						UIScript = "UIGameRoomList",
						UICSBName = "CSD/UI/UIGameRoomList.csb",
				},	
	--房间桌子列表			
	[UIType.UIType_RoomTableList] = 
				{
						UIScript = "UIRoomTableList",
						UICSBName = "CSD/UI/UIRoomTableList.csb",
				},	
	--游戏中
	[UIType.UIType_GameScene] = 
		{
			UIScript = "UIFishGame/UIGameScene",
			UICSBName = "CSD/UI/UIGameScene.csb",
		},	
								

	--兑换           
    [UIType.UIType_Cdk] = 
    {
        UIScript = "UICdk",
        UICSBName = "CSD/UI/UICdk.csb",
    },			
			
	--客服       
    [UIType.UIType_Kefu] = 
    {
        UIScript = "UIKefu",
        UICSBName = "CSD/UI/UIKefu.csb",
    },	
    --设置       
    [UIType.UIType_Setting] = 
    {
        UIScript = "UISetting",
        UICSBName = "CSD/UI/UISetting.csb",
    },	
    --仓库
    [UIType.UIType_CangKu] = 
    {
        UIScript = "UICangKu",
        UICSBName = "CSD/UI/UICangKu.csb",
	},	
	--签到
	[UIType.UIType_QianDao] = 
	{
		UIScript = "UIQianDao",
		UICSBName = "CSD/UI/UIQianDao.csb",
	},
	--反馈
	[UIType.UIType_FanKui] = 
	{
		UIScript = "UIFanKui",
		UICSBName = "CSD/UI/UIFanKui.csb",
	},
	--抽奖
	[UIType.UIType_ChouJiang] = 
	{
		UIScript = "UIChouJiang",
		UICSBName = "CSD/UI/UIChouJiang.csb",
	},
	--游戏加载条
	[UIType.UIType_GameLoading] = 
	{
		UIScript = "UIGameLoading",
		UICSBName = "CSD/UI/UIGameLoading.csb",
	},
	--游戏更新UI
	[UIType.UIType_Update] = 
	{
		UIScript = "UIUpdate",
		UICSBName = "CSD/UI/UIUpdate.csb",
	},
	--捕鱼帮助 
	[UIType.UIType_FishHelp] = 
	{
		UIScript = "UIFishGame.UIFishHelp",
		UICSBName = "CSD/UI/UIFishHelp.csb",
	},
	--捕鱼 退出界面 结算界面
	[UIType.UIType_FishQuit] = 
	{
		UIScript = "UIFishGame.UIFishQuit",
		UICSBName = "CSD/UI/UIQuitFish.csb",
	},	
}