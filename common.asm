;EasyCodeName=common,1
.Const
	TRANS_COLOR Equ 00FF00FFH
	STGM_READ Equ 00000000H
	G_FONT_SIZE Equ 14

	ProcessBasicInformation Equ 00H

.Data?
	G_ICON_SHUTDOWN QWord ?
	G_ICON_RESTART QWord ?
	G_HWND_TIP_WINDOW HWND ?
	G_MAIN_WINDOW 	QWord ?
	G_HWND_RUNMODE_WINDOW HWND ?
	G_CURRENT_CATCH_HWND HWND ?
	G_IS_SELECT_DONE QWord ?
	G_HWND_PAGE_ROOT HWND ?
	G_HWND_UPGRADE_WINDOW HWND ?
	G_HWND_CONFIG_WINDOW HWND ?
	G_HWND_MANUAL_WINDOW HWND ?
	G_ICON_POWERON QWord ?
	G_P_CURRENT_BTN_CMD_INFO QWord ?

	G_CURRENT_FORNT_FRAME HWND ?

	G_OLD_CURSOR HICON ?

	MAX_CMD_ITEM Equ 5
	MAX_CMD_ITEM_BTN Equ 6
.Data
	APP_NAME DB "CmdSparker", 0
	TITLE_FORMAT DB "CMDSPARKER  V%s", 0
	 LABEL_INFO DB "关于本软件", 0AH, 0DH, 0AH, 0DH, "CmdSparker V %s ", 0AH, 0DH, "版权所有 替计划实验室(PLAN T LABS)", 0AH, 0DH, 0AH, 0DH, 0AH, 0DH, 0AH, 0DH, 0AH, 0DH, 0AH, 0DH, 0AH, 0DH, "Copyright (C) 2023-7-10", 0
	 LABEL_UPGRADE DB "下载最新版：%s", 0
	 LABEL_BILIBILI_PAGE DB "BliBili: 使用教学", 0
	 LABEL_YOUTUBE_PAGE DB "YouTube: 使用教学", 0
	 LABEL_HOMEPAGE DB "替计划主页", 0
	G_INST_NAME DB 'CMDSPARKER_INSTANCE_X003k0', 0
	G_HOME_PAGE DB 'https://www.plt-labs.com', 0
	G_BILIBILI_PAGE DB 'https://www.plt-labs.com', 0
	G_YOUTUBE_PAGE DB 'https://www.plt-labs.com', 0
	CHECK_UPDATE_URL DB 'https://www.plt-labs.com/chkgodc', 0
	CHROME_AGENT DB 	'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36', 0

	GUID_CLSID_ShellLinkD	GUID < 000021401H, 0, 0, {0C0H, 0, 0, 0, 0, 0, 0, 046H}>
	GUID_IID_IShellLinkD	GUID < 0000214EEH, 0, 0, {0C0H, 0, 0, 0, 0, 0, 0, 046H}>
	IID_IShellLink 			GUID < 0EE140200H, 0, 0, {0C0H, 0, 0, 0, 0, 0, 0, 46H}>
	IID_IPersistFile 		GUID < 0000010BH, 0, 0, {0C0H, 0, 0, 0, 0, 0, 0, 46H}>
.Code

