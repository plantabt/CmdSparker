;EasyCodeName=CmdSparker,1
.Const
	MAX_CMD_STR_LEN Equ 19	;最长命令长度
	WINDOW_WIDTH	Equ 380
	WINDOW_HEIGHT	Equ 220
	CAPTION_WIDE	Equ 23
	MAX_CMD_PAGE Equ 5 ;最大命令按钮条数


	LLKEYID_MAIN_HOT_KEY Equ 44	;lctrl +; 组合键的 消息id号

	TIMER_CHECK_MAIN_HOT_KEY Equ 101
	MAIN_HOT_KEY_TIMEOUT Equ 500	;呼出隐藏主窗口要在半秒内完成才有效

	TIMER_CHECK_COMMAND Equ 102
	COMMAND_TIMEOUT Equ 2000	;命令要在3秒内输入完成才有效

	CTRL_BTN_RUN_ON_STARTUP Equ 10H
	CTRL_BTN_EXIT_APP Equ 11H
	CTRL_BTN_UPGRADE Equ 12H
.Data?

	g_hFont	QWord ?
	IsMouseInCloseBtn QWord ?
	HBCOLOR_GRAYTEXT QWord ?
	HBCOLOR_HOTLIGHT QWord ?
	HBCOLOR_INACTIVECAPTION QWord ?
	HBCOLOR_HIGHLIGHT QWord ?
	MAIN_HOT_KEY_COUNT QWord ?
	IS_COMMAND_INPUTTING QWord ?
	CHAR_BUFF_COMMAND DB (MAX_CMD_STR_LEN + 1) Dup(?)

	IS_SET_COMMAND QWord ?
	IS_SELECT_CMD QWord ?
	SET_COMMAND_BUFF DB (MAX_CMD_STR_LEN + 1) Dup(?)
	SET_COMMAND_OLD_BUFF DB (MAX_CMD_STR_LEN + 1) Dup(?)


	HWND_CURRENT_CMDNAME QWord ?
	HWND_CURRENT_PAGE QWord ?
	HWND_CURRENT_ITEM QWord ?


.Data

	szClassName	DB		'CLASS_GODCMD', 0
	szTitle		DB		'GODCMD', 0
	G_STR_HOTKEY_SHOW DB 'LCTR+;', 0, LLKEYID_MAIN_HOT_KEY

.Code

start Proc
	Local hInst:QWord
	ECInvoke GetModuleHandle, NULL
	Mov hInst, Rax
	ECInvoke GetCommandLine
	ECInvoke WinMain, hInst, NULL, Rax, SW_SHOWDEFAULT
	ECInvoke ExitProcess, Rax
start EndP

WinMain Proc hInst:QWord, hPrevInst:QWord, lpCmdLine:QWord, nCmdShow:QWord
	Local msg:MSG, wc:WNDCLASSEX
	Local isStartup:QWord
	Local rcClient:RECT
comment#
	Local cmdinfo:BTN_CMD_INFO
	Local pOutValue:QWord
	Local pCmdskValue:QWord
	Local pOutSize:QWord
	Local pNextNode:QWord
	Local pExcPath:QWord
	Local pArgs:QWord
	Local pWorkDir:QWord
	Local value[100]:DB
	Local kname[40]:DB
	Local keyIdx:QWord
	Local pCmdsNode:QWord
	Local cmdName[80]:DB

	Local hMap:QWord
	#

	Mov hInst, Rcx
	Mov hPrevInst, Rdx
	Mov lpCmdLine, R8
	Mov nCmdShow, R9

	ECInvoke InitApi
	ECInvoke CoInitialize, NULL
	ECInvoke EnablePrivilege, SE_DEBUG_NAME
	;ECInvoke ReadAutoCmds

	ECInvoke IsFirstRun
	Test Al, Al
	Jz @F
	ECInvoke MessageBox, 0, CTXT('是否收录桌面快捷方式？'), CTXT('自动收录'), MB_YESNO OR MB_ICONQUESTION
	Cmp Rax, 6;6=yes
	Jnz nosort
	ECInvoke ReadAutoCmds
nosort:
	ECInvoke ChangeFirstRun, 0
@@:

	ECInvoke GetSystemIcon, 70H
	Mov G_ICON_SHUTDOWN, Rax
	ECInvoke GetSystemIcon, 238
	Mov G_ICON_RESTART, Rax

	;创建开机图标
	Mov rcClient.top, 0
	Mov rcClient.left, 0
	Mov rcClient.right, 16
	Mov rcClient.bottom, 16
	ECInvoke Icon_PowerOn, Addr rcClient, BUTTON_NORMAL_COLOR
	Mov G_ICON_POWERON, Rax



	

	;检查是否已经运行
	ECInvoke IsAnotherInstanceRunning, Addr G_INST_NAME
	Test Eax, Eax
	Jz noInstance
	ECInvoke ActivateWindow, Addr szClassName, Addr szTitle
	ECInvoke GetCurrentProcess
	ECInvoke TerminateProcess, Rax, 0
noInstance:


;ECInvoke ExitProcess, 0

	;Local icc:INITCOMMONCONTROLSEX	 ;Remove this line only if common controls are not going to be used
	;ECInvoke GdiplusStartup, Addr g_Graphics, 0, 0
Comment #
	ECInvoke LoadLibrary, CTXT("Riched20.dll")
	ECInvoke OleInitialize, 0
	
	;==========================================================================
	;Remove this lines, and the corresponding 'comctl32.inc' and 'comctl32.lib'
	;files from project explorer, if you are not going to use common controls.
	Mov icc.dwSize, SizeOf INITCOMMONCONTROLSEX
	Mov icc.dwICC, (ICC_WIN95_CLASSES OR ICC_DATE_CLASSES OR ICC_USEREX_CLASSES OR ICC_COOL_CLASSES OR ICC_INTERNET_CLASSES OR ICC_PAGESCROLLER_CLASS OR ICC_NATIVEFNTCTL_CLASS OR ICC_STANDARD_CLASSES)
	ECInvoke InitCommonControlsEx, Addr icc
	;===========================================================================
	#


	ECInvoke InitKbd, hInst




	Mov wc.cbSize, SizeOf WNDCLASSEX
	Mov wc.style, (CS_DBLCLKS OR CS_HREDRAW OR CS_VREDRAW)
	Lea Rax, WindowProcedure
	Mov wc.lpfnWndProc, Rax
	Mov wc.cbClsExtra, 0
	Mov wc.cbWndExtra, 0
	Mov Rax, hInst
	Mov wc.hInstance, Rax
	ECInvoke LoadIcon, hInst, MAIN_ICON
	Mov wc.hIcon, Rax
	ECInvoke LoadImage, NULL, OCR_NORMAL, IMAGE_CURSOR, 0, 0, (LR_DEFAULTSIZE OR LR_LOADMAP3DCOLORS OR LR_SHARED)
	Mov wc.hCursor, Rax
	Mov wc.hbrBackground, (COLOR_BTNFACE + 1)
	Mov wc.lpszMenuName, NULL
	Lea Rax, szClassName
	Mov wc.lpszClassName, Rax
	Mov wc.hIconSm, NULL




	ECInvoke RegisterClassEx, Addr wc

	ECInvoke CreateWindowEx, 0, Addr szClassName, Addr szTitle, WS_POPUP, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, NULL, NULL, hInst, NULL

	Mov G_MAIN_WINDOW, Rax



	ECInvoke SetHotKeys, Addr G_STR_HOTKEY_SHOW, 8

	ECInvoke CreateWindows, hInst



	;读取启动按钮的配置
	ECInvoke GetDlgItem, G_MAIN_WINDOW, CTRL_BTN_RUN_ON_STARTUP
	Push Rax
	ECInvoke ReadRunonStartup
	Mov isStartup, Rax
	Pop Rcx

	ECInvoke SetFlatIconButtonPushed, Rcx, Rax


	ECInvoke SetWindowRoundRect, G_MAIN_WINDOW

	ECInvoke CenterWindow, G_MAIN_WINDOW, 0, 0

	Mov Rdx, isStartup
	Xor Dl, 1
	
	ECInvoke ShowWindowEx, G_MAIN_WINDOW, Rdx

	;ECInvoke ShowWindow, G_MAIN_WINDOW, SW_SHOW
@@:	ECInvoke GetMessage, Addr msg, NULL, 0, 0
	Cmp Rax, 0
	Jle @F
	ECInvoke TranslateMessage, Addr msg
	ECInvoke DispatchMessage, Addr msg
	Jmp @B

@@:

	ECInvoke DestroyManualRunWindow, G_HWND_MANUAL_WINDOW

    ; 清理拖放操作
    ;ECInvoke OleUninitialize
	ECInvoke CoUninitialize
	ECInvoke UnregisterClass, Addr szClassName, hInst
	ECInvoke DestroyCursor, wc.hCursor

	Mov Rax, msg.wParam

	
	Ret
WinMain EndP

CreateWindows Proc  hInst:QWord
	Mov hInst, Rcx
	ECInvoke GetSysColorBrush, COLOR_GRAYTEXT
	Mov HBCOLOR_GRAYTEXT, Rax
	ECInvoke GetSysColorBrush, COLOR_HOTLIGHT
	Mov HBCOLOR_HOTLIGHT, Rax
	ECInvoke GetSysColorBrush, COLOR_INACTIVECAPTION
	Mov HBCOLOR_INACTIVECAPTION, Rax
	ECInvoke GetSysColorBrush, COLOR_HIGHLIGHT
	Mov HBCOLOR_HIGHLIGHT, Rax

	ECInvoke CreateSystemFont, G_FONT_SIZE, FALSE, 0
	Mov g_hFont, Rax

	ECInvoke CreateManualRunWindow, 6, 30
	Mov G_HWND_MANUAL_WINDOW, Rax

	ECInvoke CreatePagePanel, G_MAIN_WINDOW, CAPTION_WIDE, 4, WINDOW_WIDTH - CAPTION_WIDE - 2, WINDOW_HEIGHT - 8, hInst, 0, g_hFont, MAX_CMD_PAGE
	Mov G_HWND_PAGE_ROOT, Rax
	;读取配置信息

	;ECInvoke ReadCfgPair, Addr gCmdPairs
	ECInvoke ReadAllCmdItemCfg, G_HWND_PAGE_ROOT
	ECInvoke ShowWindow, G_HWND_PAGE_ROOT, SW_SHOW


	ECInvoke CreateConfigWindow, G_MAIN_WINDOW, CAPTION_WIDE, 4, WINDOW_WIDTH - CAPTION_WIDE - 2, WINDOW_HEIGHT - 8, hInst, 0, g_hFont
	Mov G_HWND_CONFIG_WINDOW, Rax
	ECInvoke ShowWindow, G_HWND_CONFIG_WINDOW, SW_HIDE

	ECInvoke CreateUpgradeWindow, G_MAIN_WINDOW, CAPTION_WIDE, 4, WINDOW_WIDTH - CAPTION_WIDE - 2, WINDOW_HEIGHT - 8, hInst, 0, g_hFont
	Mov G_HWND_UPGRADE_WINDOW, Rax
	ECInvoke ShowWindow, G_HWND_UPGRADE_WINDOW, SW_HIDE


	ECInvoke CreateRunCmdTip
	Mov G_HWND_TIP_WINDOW, Rax
	ECInvoke CreateFlatIconButton, G_MAIN_WINDOW, 0, 0, 23, 23, 9, CTRL_BTN_EXIT_APP, hInst, g_hFont, ID_ICON_X, BUTTON_FLAT_HILIGHT_COLOR, BUTTON_FLAT_NORMAL_COLOR, BUTTON_FLAT_CLICK_COLOR, 0, FALSE
	ECInvoke CreateFlatIconButton, G_MAIN_WINDOW, 0, 23, 23, 23, 15, CTRL_BTN_UPGRADE, hInst, g_hFont, ID_ICON_UPGRADE, BUTTON_FLAT_HILIGHT_COLOR, BUTTON_FLAT_NORMAL_COLOR, BUTTON_FLAT_CLICK_COLOR, 0, FALSE
	ECInvoke CreateFlatIconButton, G_MAIN_WINDOW, 0, 23 * 2, 23, 23, 15, CTRL_BTN_RUN_ON_STARTUP, hInst, g_hFont, ID_ICON_POWER_ON, BUTTON_FLAT_HILIGHT_COLOR, BUTTON_FLAT_NORMAL_COLOR, BUTTON_FLAT_CLICK_COLOR, 0, TRUE


	Ret
CreateWindows EndP


WindowProcedure Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
	Local hdc:QWord
	Local ps:PAINTSTRUCT
	Local pt:POINT
	Local captRect:RECT
	Local hBorderBrush:QWord
	Local tme:TRACKMOUSEEVENT
	Local hColor:QWord
	Local pen:HPEN
	Local hRgn:QWord
	Local rcClient:RECT
	Local hbrush:QWord
	Local memDc:QWord
	Local memBmp:QWord
	Local titleStr:QWord
	Local pOPath[MAX_PATH]:DB
	Local value[10]:DB
	Local vsize:QWord
	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9

		;ECInvoke SystemParametersInfo, SPI_SETCURSORS, 0, hHandCursor, SPIF_SENDCHANGE

@@:Cmp uMsg, WM_PAINT
	Jnz @F

        ECInvoke BeginPaint, hWnd, Addr ps
  
        ECInvoke GetClientRect, hWnd, Addr rcClient

        ECInvoke CreateRoundRectRgn, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, 4, 4
        Mov hRgn, Rax
        Mov Rax, ps.hdc
		Mov memDc, Rax

		ECInvoke FrameRgn, memDc, hRgn, HBCOLOR_GRAYTEXT, 1, 1
		ECInvoke DeleteObject, hRgn

		Mov ps.rcPaint.right, CAPTION_WIDE

        ; 绘制矩形
        ECInvoke FillRect, memDc, Addr ps.rcPaint, HBCOLOR_HOTLIGHT
		;画关闭按钮
		Mov Rax, HBCOLOR_HIGHLIGHT
		Mov hbrush, Rax
		Cmp IsMouseInCloseBtn, 1
		Jne nohl
		Mov Rax, HBCOLOR_INACTIVECAPTION
		Mov hbrush, Rax
nohl:

		Mov ps.rcPaint.bottom, CAPTION_WIDE
        ; 绘制矩形

        ECInvoke FillRect, memDc, Addr ps.rcPaint, hbrush
		;绘制X
        ECInvoke MoveToEx, memDc, 8, 8, 0
        ECInvoke LineTo, memDc, CAPTION_WIDE - 7, CAPTION_WIDE - 7
        ECInvoke MoveToEx, memDc, CAPTION_WIDE - 8, 8, 0
        ECInvoke LineTo, memDc, 7, CAPTION_WIDE - 7
        ;绘制开机图标
        Mov Rax, G_ICON_POWERON
		Mov Rax, [Rax].ICON_OBJECT.ICON_DC
        ECInvoke TransparentBlt, memDc, 4, 24, 16, 16, Rax, 0, 0, 16, 16, TRANS_COLOR

		ECInvoke NewStr, 0, 100
		Mov titleStr, Rax
		ECInvoke GetVersionString
		ECInvoke FormatStr, titleStr, Addr TITLE_FORMAT, Rax, 0, 0, 0, 0
		Mov rcClient.right, 23

		ECInvoke DrawWindowTitle, ps.hdc, Addr rcClient, titleStr
		ECInvoke DelStr, titleStr
		Mov Eax, rcClient.bottom
		Sub Eax, 23
		Mov rcClient.top, Eax
		Mov rcClient.left, 2
		Mov rcClient.right, 20
		Mov rcClient.bottom, 20

		ECInvoke DrawResIcon, ps.hdc, Addr rcClient, MAIN_ICON
		
        ECInvoke EndPaint, hWnd, Addr ps



@@:Cmp uMsg, WM_COMMAND
	Jnz @F
	Cmp wParam, CTRL_BTN_RUN_ON_STARTUP
	Jnz nc0
	ECInvoke GetDlgItem, hWnd, CTRL_BTN_RUN_ON_STARTUP
	ECInvoke GetFlatIconButtonPushed, Rax
	Push Rax
	ECInvoke SaveRunonStartup, Rax
	Pop Rax
	ECInvoke AddToStartup, Rax
	;ECInvoke PostMessage, hWnd, WM_SYSCOMMAND, SC_CLOSE, 0
nc0:Cmp wParam, CTRL_BTN_EXIT_APP
	Jnz nc1
	ECInvoke PostMessage, hWnd, WM_SYSCOMMAND, SC_CLOSE, 0
nc1:Cmp wParam, CTRL_BTN_UPGRADE
	Jnz nc2
	ECInvoke ShowWindow, G_HWND_PAGE_ROOT, SW_HIDE
	ECInvoke ShowWindow, G_HWND_CONFIG_WINDOW, SW_HIDE
	ECInvoke ShowWindow, G_HWND_UPGRADE_WINDOW, SW_SHOW

	ECInvoke GetWebPageAsync, Addr CHECK_UPDATE_URL, Addr CHROME_AGENT, Addr UpgradeCheck
nc2:

@@:Cmp uMsg, WM_KEYDOWN
	Jnz @F


@@:Cmp uMsg, WM_LBUTTONUP
	Jne @F


@@:Cmp uMsg, WM_LBUTTONDOWN
	Jne @F

        ECInvoke GetCursorPos, Addr pt
        ECInvoke GetWindowRect, hWnd, Addr captRect

		Mov Eax, captRect.left
        Add Eax, CAPTION_WIDE
        Mov captRect.right, Eax
		ECInvoke PtInRect, Addr captRect, pt
		Cmp Rax, 0
		Je @F
	        ;拖动窗口
	        ECInvoke PostMessage, hWnd, WM_SYSCOMMAND, (SC_MOVE OR HTCAPTION), pt
@@:Cmp uMsg, WM_KEYDOWN
	Jne @F

;	ECInvoke MessageBox, 0, 0, 0, 0
@@:Cmp uMsg, WM_MOUSEMOVE
	Jne @F
	comment #
	;;启用鼠标移入和移出事件的检测
    Mov tme.cbSize, SizeOf TRACKMOUSEEVENT
    Mov tme.dwFlags, TME_LEAVE
    Mov Rax, hWnd
    Mov tme.hwndTrack, Rax
    ECInvoke TrackMouseEvent, Addr tme

	ECInvoke GetClientRect, hWnd, Addr rcClose
	;计算关闭按钮rect
	Mov Eax, rcClose.left
	Add Eax, CAPTION_WIDE
	Mov rcClose.right, Eax
	
	Mov Eax, rcClose.top
	Add Eax, CAPTION_WIDE
	Mov rcClose.bottom, Eax

	;获得鼠标移动的x,y

	Mov Rax, lParam
	And Rax, 0FFFFH
	Mov pt.x, Eax

	Mov Rax, lParam
	Shr Eax, 16
	And Rax, 0FFFFH
	Mov pt.y, Eax

	Mov IsMouseInCloseBtn, 0
	ECInvoke PtInRect, Addr rcClose, pt
	Cmp Rax, 0
	Je notin
		;ECInvoke PostQuitMessage, 0
		Mov IsMouseInCloseBtn, 1
notin:
	ECInvoke InvalidateRect, hWnd, Addr rcClose, 0
	#
@@:Cmp uMsg, WM_CONFIG_UPDATE
	Jne @F
	ECInvoke SaveAllCmdItemInfo, G_HWND_PAGE_ROOT
@@:Cmp uMsg, WM_PAGE_UPDATE
	Jne @F
	;ECInvoke MessageBox, 0, CTXT("WM_PAGE_UPDATE"), 0, 0
	ECInvoke SaveAllCmdItemInfo, G_HWND_PAGE_ROOT
@@:Cmp uMsg, WM_MOUSELEAVE
	Jne @F
		comment #
		ECInvoke GetClientRect, hWnd, Addr rcClose
		;计算关闭按钮rect
		Mov Eax, rcClose.left
		Add Eax, CAPTION_WIDE
		Mov rcClose.right, Eax
		
		Mov Eax, rcClose.top
		Add Eax, CAPTION_WIDE
		Mov rcClose.bottom, Eax
		Mov IsMouseInCloseBtn, 0
		ECInvoke InvalidateRect, hWnd, Addr rcClose, 0
	Xor Eax, Eax
	Ret
#

@@:Cmp uMsg, WM_LLKBD_MSG
	Jne @F

	Cmp wParam, -1
	Jnz isllhotkey
		;普通按键处理
		Cmp IS_SELECT_CMD, 1
		Jnz notSelectCmd
		ECInvoke SetInputSelect, lParam
		Mov Eax, 1
		Ret
notSelectCmd:
		Cmp IS_SET_COMMAND, 1
		Jnz notCmdInput
		ECInvoke SetInputCommand, lParam
		Mov Eax, 0
		Ret
notCmdInput:
		;输入命令
		Cmp IS_COMMAND_INPUTTING, 1
		Jnz normalLLKEYProc
		;ctrl+;不参与命令命中
		ECInvoke GetKeyText, lParam, Addr value, Addr vsize
		ECInvoke IsKeyDown, lParam, Addr LCTR_162
		Test Eax, Eax
		Jnz isllhotkey
		ECInvoke IsKeyDown, lParam, Addr semicolon_186
		Test Eax, Eax
		Jnz isllhotkey
		ECInvoke AppendCommand, lParam

		Mov Eax, 1
		Ret


normalLLKEYProc:
		;key 的处理
		ECInvoke OnKeyDownProc, lParam
		Test Al, Al
		Jz haskey
		Ret
isllhotkey:
haskey:
	;热键处理
	Cmp wParam, LLKEYID_MAIN_HOT_KEY
	Jnz retHook

		Cmp MAIN_HOT_KEY_COUNT, 0;第一次按开启计时器
		Jnz nextCount0

			ECInvoke StopCmdInput
			ECInvoke StartCmdInput
			Inc MAIN_HOT_KEY_COUNT
			Jmp nextc
nextCount0:
		Cmp MAIN_HOT_KEY_COUNT, 1
		Jnz nextCount1

		;呼出主窗口
			;清空命令行k6
			comment #
			Lea Rax, CHAR_BUFF_COMMAND
			Mov QWord Ptr [Rax], 0
			Mov IS_COMMAND_INPUTTING, 0;关闭命令接受模式
			ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_MAIN_HOT_KEY
			ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_COMMAND
			#
			ECInvoke StopCmdInput
			ECInvoke IsWindowVisible, G_MAIN_WINDOW
			;bool 求反
			Mov Rdx, Rax
			Not Rdx
			And Rdx, 1

			ECInvoke ShowWindowEx, G_MAIN_WINDOW, Rdx
			Mov MAIN_HOT_KEY_COUNT, 0
			Jmp nextc
nextCount1:
nextc:
	Xor Eax, Eax
	Cmp IS_COMMAND_INPUTTING, 1
	Jnz uninput
			Mov Eax, 1
			Ret
retHook:

uninput:
@@:Cmp uMsg, WM_TIMER
	Jne @F

		Cmp wParam, TIMER_CHECK_MAIN_HOT_KEY
		Jne nexttm0
		;ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_MAIN_HOT_KEY
		;Mov MAIN_HOT_KEY_COUNT, 0
		;ECInvoke MessageBox, 0, 0, 0, 0
		ECInvoke CheckHotkeyTimeout
nexttm0:
	Cmp wParam, TIMER_CHECK_COMMAND
		Jne @F
		comment #
		ECInvoke ShowRunCmdTip, G_HWND_TIP_WINDOW, Addr CHAR_BUFF_COMMAND, FALSE
		ECInvoke WriteLog, CTXT("TIMER_CHECK_COMMAND timeout"), 1
		ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_COMMAND
		;Mov MAIN_HOT_KEY_COUNT, 0
		Lea Rax, CHAR_BUFF_COMMAND
		Mov QWord Ptr [Rax], 0
		Mov IS_COMMAND_INPUTTING, 0;关闭命令接受模式
		#
		ECInvoke CheckCommandTimeout
	Xor Eax, Eax
	Ret
	
@@:Cmp uMsg, WM_CREATE
	Jne @F

	Xor Eax, Eax
	Ret

@@:	Cmp uMsg, WM_ITEM_BTN_CLCK
	Jne @F

		Mov Rax, wParam
		Mov G_P_CURRENT_BTN_CMD_INFO, Rax
		ECInvoke CmdInfoMatchConfigFrame, wParam

		ECInvoke ShowWindow, G_HWND_PAGE_ROOT, SW_HIDE
		ECInvoke ShowWindow, G_HWND_CONFIG_WINDOW, SW_SHOW

@@:	Cmp uMsg, WM_CONTIGUOUS_LBDBCLCK
	Jne @F

		Mov Rax, lParam
		Mov HWND_CURRENT_ITEM, Rax
		ECInvoke GetDlgItem, Rax, CMD_CTRL_LABEL
		Mov HWND_CURRENT_CMDNAME, Rax
		Mov Rax, wParam
		Mov HWND_CURRENT_PAGE, Rax
		ECInvoke GetWindowText, HWND_CURRENT_CMDNAME, Addr SET_COMMAND_OLD_BUFF, (SizeOf SET_COMMAND_OLD_BUFF) - 1
		ECInvoke SetWindowText, HWND_CURRENT_CMDNAME, Addr CHAR_BUFF_COMMAND
		
		Mov IS_SET_COMMAND, 1
		Xor Eax, Eax
		Ret

@@:	Cmp uMsg, WM_DESTROY
	Jne @F
		ECInvoke UninitKbd
		ECInvoke DestoryContiguousCmdCtrl, G_HWND_PAGE_ROOT
		ECInvoke PostQuitMessage, 0
	Xor Eax, Eax
	Ret
@@:	Cmp uMsg, WM_COMMAND
	Jne @F
		ECInvoke OnCommand, hWnd, wParam
	Xor Eax, Eax
	Ret
@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam
	Ret
WindowProcedure EndP

UpgradeCheck Proc pContent:QWord
	Local pVStr:QWord
	Mov pContent, Rcx
	Test Rcx, Rcx
	Jz exit
	ECInvoke GetVersionString
	Mov pVStr, Rax

	ECInvoke ReplaceChr, pContent, ';', 0
	ECInvoke lstrlen, pVStr
	ECInvoke IsMemEqul, pVStr, pContent, Rax
	Test Al, Al
	Jnz notupg
	ECInvoke ShowUpgradeHLink, pContent, TRUE
	Jmp cntc
notupg:

	ECInvoke ShowUpgradeHLink, CTXT("已是最新"), TRUE

cntc:
	ECInvoke DelStr, pVStr

	ECInvoke DelStr, pContent
exit:

	Ret
UpgradeCheck EndP

;控件事件
OnCommand Proc ctrlHwnd:QWord, ctrlId:QWord
	Mov ctrlHwnd, Rcx
	Mov ctrlId, Rdx

	;Cmp Edx, DWord Ptr BTN_ADD_ID
	;Jne @F
	;ECInvoke MessageBox, 0, 0, 0, 0
;@@:

	Ret
OnCommand EndP

AppendCommand Proc keyCode:QWord
	Local value[10]:DB
	Local pCmdList:QWord
	Local pCmdManualList:QWord
	Local pItem:QWord
	Local vsize:QWord
	;Local loopList:QWord
	Local pAppPath:QWord
	Local appPath[MAX_PATH]:Byte
	Local pArgLine:QWord
	Local bWait:QWord
	Local bAdmin:QWord
	Local bShutdown:QWord
	Local bRestart:QWord
	Local pTmp:QWord
	Local pBtnCmdInfos:QWord
	Mov keyCode, Rcx
	Cmp IS_COMMAND_INPUTTING, 1
	Jne @F
	;ECInvoke WriteLog, CTXT("AppendCommand IS_COMMAND_INPUTTING=1"), 1

	ECInvoke GetKeyText, keyCode, Addr value, Addr vsize
	ECInvoke lstrlen, Addr CHAR_BUFF_COMMAND
	Add Rax, vsize
	Cmp Rax, MAX_CMD_STR_LEN
	Jge @F
	;esc 重置命令输入
	ECInvoke IsKeyDown, keyCode, Addr ESC_27
	Test Eax, Eax
	Jz notEsc
		Lea Rax, CHAR_BUFF_COMMAND
		Mov QWord Ptr [Rax], 0
		Mov IS_COMMAND_INPUTTING, 0
		Ret
notEsc:
		ECInvoke GlobalAlloc, GPTR, MAX_CMD_PAGE * MAX_CMD_ITEM * MAX_CMD_ITEM_BTN * 8 + 8
		Mov pCmdList, Rax
		ECInvoke GlobalAlloc, GPTR, MAX_CMD_PAGE * MAX_CMD_ITEM * MAX_CMD_ITEM_BTN * 8 + 8
		Mov pCmdManualList, Rax

		ECInvoke ZeroMemory, pCmdList, MAX_CMD_PAGE * MAX_CMD_ITEM * MAX_CMD_ITEM_BTN * 8 + 8
		ECInvoke ZeroMemory, pCmdManualList, MAX_CMD_PAGE * MAX_CMD_ITEM * MAX_CMD_ITEM_BTN * 8 + 8

		ECInvoke lstrcat, Addr CHAR_BUFF_COMMAND, Addr value
		comment #
		ECInvoke lstrlen, Addr CHAR_BUFF_COMMAND
		Cmp Eax, 2
		Jne a1
		Int 3
a1:
#

		ECInvoke ShowRunCmdTip, G_HWND_TIP_WINDOW, Addr CHAR_BUFF_COMMAND, TRUE
		ECInvoke GetCommandForCmdbtn, Addr CHAR_BUFF_COMMAND, MAX_CMD_PAGE, pCmdList, pCmdManualList
		Test Eax, Eax
		Jz _not_hit


	;	Mov loopList, 0
		Mov Rax, pCmdList
		Mov pTmp, Rax
		comment #
		Mov Rcx, [Rax]
		Cmp Rcx, 0
		Jz _not_hit
		Int 3
		#
_loop_list:
			;ECInvoke WriteLog, CTXT("check cmd 1"), 1

			Mov Rax, pTmp
			Add pTmp, 8
			Mov Rcx, [Rax]
			Mov pItem, Rcx
			Cmp Rcx, 0
			Je _gomcmd

			;ECInvoke ShowRunCmdTip, G_HWND_TIP_WINDOW, Addr CHAR_BUFF_COMMAND, FALSE

			ECInvoke CleanInputState
			Mov Rcx, pItem
		;	Mov R8, loopList
		;	Mov Rcx, [Rax + R8 * 8]
			Mov Rax, [Rcx].BTN_CMD_INFO.cmdbShutdown
			Mov bShutdown, Rax
			Mov Rax, [Rcx].BTN_CMD_INFO.cmdbRestart
			Mov bRestart, Rax

			Mov Rax, QWord Ptr [Rcx].BTN_CMD_INFO.cmdLine

			Test Eax, Eax
			Jz _not_app

			Mov Rcx, [Rcx].BTN_CMD_INFO.cmdType
			Cmp Rcx, BTN_CMD_TYPE_APP

			;Jnz _not_app

				;执行命令

				Cmp bShutdown, TRUE
				Jnz nxtc0

				ECInvoke ShutdownComputer
				Jmp _internal_cmd
nxtc0:
				Cmp bRestart, TRUE
				Jnz nxtc1
				ECInvoke RebootComputer
				Jmp _internal_cmd
nxtc1:
Comment #
				ECInvoke WriteLog, CTXT("Run: "), 0
				Mov Rcx, pItem
				Lea Rcx, [Rcx].BTN_CMD_INFO.cmdLine
				ECInvoke WriteLog, Rcx, 1
				#
				ECInvoke RunBtnCmdInfoCommand, pItem
				ECInvoke WriteLog, CTXT("run ------1"), 1

_not_app:
_internal_cmd:
		;	Inc loopList
		;	Mov Rax, loopList
		;	Cmp Rax, MAX_CMD_ITEM_BTN
			Jmp _loop_list
_gomcmd:

	;配置选择面板

	Mov Rax, pCmdManualList
	Cmp QWord Ptr [Rax], 0
	Je _not_hit
	Mov pTmp, Rax

	;ECInvoke ShowRunCmdTip, G_HWND_TIP_WINDOW, Addr CHAR_BUFF_COMMAND, FALSE
	ECInvoke CleanInputState
	;复制list到manualinfo
	ECInvoke GetWindowLongPtr, G_HWND_MANUAL_WINDOW, GWLP_USERDATA
	Mov Rax, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos
	Mov pBtnCmdInfos, Rax


	ECInvoke ManualResetPage, G_HWND_MANUAL_WINDOW
	ECInvoke ShowWindowEx, G_HWND_MANUAL_WINDOW, TRUE
	Mov IS_SELECT_CMD, 0
	Mov Rcx, pTmp
	Mov Rcx, [Rcx]
	Cmp Ecx, 0
	Je nosel
_loop_cpy:
	Mov IS_SELECT_CMD, 1

	Mov Rcx, pTmp
	Mov Rcx, [Rcx]
	Mov Rax, pBtnCmdInfos
	Mov [Rax], Rcx

	Add pTmp, 8
	Add pBtnCmdInfos, 8
	Mov Rcx, pTmp
	Mov Rcx, [Rcx]
	Cmp Rcx, 0
	Jnz _loop_cpy

	ECInvoke UpdateInWindow, G_HWND_MANUAL_WINDOW
nosel:

_not_hit:

	ECInvoke GlobalFree, pCmdList
	ECInvoke GlobalFree, pCmdManualList

@@:

	Ret
AppendCommand EndP

CleanInputState Proc
		;命中后重置输入
	Lea Rax, CHAR_BUFF_COMMAND
	Mov QWord Ptr [Rax], 0
	Mov IS_COMMAND_INPUTTING, 0
	Ret
CleanInputState EndP

IsKeyDown Proc  keyCode:QWord, keyName:QWord
	Local value[10] :DB
	Local vsize:QWord
	Mov keyCode, Rcx
	Mov keyName, Rdx

	ECInvoke GetKeyText, keyCode, Addr value, Addr vsize
	ECInvoke lstrcmpi, keyName, Addr value
	Test Eax, Eax
	Jnz notKey
	Mov Eax, 1
	Ret
notKey:
	Xor Eax, Eax
	Ret
IsKeyDown EndP

OnKeyDownProc Proc keyCode:QWord
	Mov keyCode, Rcx
	ECInvoke IsKeyDown, keyCode, Addr ESC_27
	Test Eax, Eax
	Jz nxtk0
	ECInvoke ShowWindow, G_HWND_PAGE_ROOT, SW_SHOW
	ECInvoke ShowWindow, G_HWND_CONFIG_WINDOW, SW_HIDE
	ECInvoke ShowWindow, G_HWND_UPGRADE_WINDOW, SW_HIDE
	Xor Eax, Eax
	Ret
nxtk0:
	Ret
OnKeyDownProc EndP


SetInputCommand Proc keyCode:QWord
	Local value[10]:DB
	Local vsize:QWord
	Mov keyCode, Rcx

	Cmp IS_SET_COMMAND, 1
	Jnz @F
	ECInvoke GetKeyText, keyCode, Addr value, Addr vsize
	;ECInvoke lstrcmpi, Addr ESC_27, Addr value
	ECInvoke IsKeyDown, keyCode, Addr ESC_27
	Test Eax, Eax
	Jz notEsc
		Lea Rax, CHAR_BUFF_COMMAND
		Mov QWord Ptr [Rax], 0
		Mov IS_SET_COMMAND, 0
		ECInvoke SetWindowText, HWND_CURRENT_CMDNAME, Addr SET_COMMAND_OLD_BUFF
		Ret
notEsc:
	;ECInvoke lstrcmpi, Addr RETURN_13, Addr value
	ECInvoke IsKeyDown, keyCode, Addr RETURN_13
	Test Eax, Eax
	Jz notEnter
		Mov IS_SET_COMMAND, 0
		ECInvoke SetWindowText, HWND_CURRENT_CMDNAME, Addr CHAR_BUFF_COMMAND
		ECInvoke SaveAllCmdItemInfo, G_HWND_PAGE_ROOT
		Lea Rax, CHAR_BUFF_COMMAND
		Mov QWord Ptr [Rax], 0
		Ret
notEnter:
	ECInvoke IsKeyDown, keyCode, Addr BACKSPACE_8
	;ECInvoke lstrcmpi, Addr BACKSPACE_8, Addr value
	Test Eax, Eax
	Jz notBackspace
		Lea Rax, CHAR_BUFF_COMMAND
		Cmp Byte Ptr [Rax], 0
		Jz @F
		Push Rax
		ECInvoke lstrlen, Rax
		Pop Rcx

		Mov Byte Ptr [Rcx + Rax - 1], 0
		ECInvoke SetWindowText, HWND_CURRENT_CMDNAME, Addr CHAR_BUFF_COMMAND
		Ret
notBackspace:
	ECInvoke lstrlen, Addr CHAR_BUFF_COMMAND
	Add Rax, vsize
	Cmp Rax, MAX_CMD_STR_LEN
	Jge @F
		ECInvoke lstrcat, Addr CHAR_BUFF_COMMAND, Addr value
		ECInvoke SetWindowText, HWND_CURRENT_CMDNAME, Addr CHAR_BUFF_COMMAND
@@:
	Ret
SetInputCommand EndP

SetInputSelect Proc keyCode:QWord
	Local value[10]:DB
	Local vsize:QWord
	Local number:QWord
	Mov keyCode, Rcx

	Cmp IS_SELECT_CMD, 1
	Jnz exit
	ECInvoke GetKeyText, keyCode, Addr value, Addr vsize
	;ECInvoke lstrcmpi, Addr ESC_27, Addr value
	ECInvoke IsKeyDown, keyCode, Addr ESC_27
	Test Eax, Eax
	Jz notEsc
		Lea Rax, CHAR_BUFF_COMMAND
		Mov QWord Ptr [Rax], 0
		Mov IS_SELECT_CMD, 0
		ECInvoke ShowWindow, G_HWND_MANUAL_WINDOW, SW_HIDE
		Ret
notEsc:
	ECInvoke IsKeyDown, keyCode, Addr A_65
	;ECInvoke lstrcmpi, Addr LEFT_37, Addr value
	Test Eax, Eax
	Jz notPrevious
	ECInvoke ManualPreviousPage, G_HWND_MANUAL_WINDOW
	Ret
notPrevious:
	ECInvoke IsKeyDown, keyCode, Addr semicolon_186
	;ECInvoke lstrcmpi, Addr RIGHT_39, Addr value
	Test Eax, Eax
	Jz notNext

	ECInvoke ManualNextPage, G_HWND_MANUAL_WINDOW
	Ret
notNext:
	Mov number, -1
	ECInvoke IsKeyDown, keyCode, Addr S_83
	Test Eax, Eax
	Jz not1

	Mov number, 0
not1:ECInvoke IsKeyDown, keyCode, Addr D_68
	Test Eax, Eax
	Jz not2
		Mov number, 1
not2:ECInvoke IsKeyDown, keyCode, Addr F_70
	Test Eax, Eax
	Jz not3
		Mov number, 2
not3:ECInvoke IsKeyDown, keyCode, Addr J_74
	Test Eax, Eax
	Jz not4
		Mov number, 3
not4:ECInvoke IsKeyDown, keyCode, Addr K_75
	Test Eax, Eax
	Jz not5
		Mov number, 4
not5:ECInvoke IsKeyDown, keyCode, Addr L_76
	Test Eax, Eax
	Jz not6
		Mov number, 5
not6:Cmp number, -1
	Jz notNumber
	;Mov Rdx, number
	;Inc Rdx

	ECInvoke GetManualCmd, G_HWND_MANUAL_WINDOW, number
	Test Rax, Rax
	Jz exit
	Mov Rcx, Rax
	Lea Rax, [Rax].BTN_CMD_INFO.cmdLine
	Mov Rax, [Rax]
	Test Rax, Rax
	Jz exit
	
	ECInvoke RunBtnCmdInfoCommand, Rcx
	ECInvoke FlashManualRunItem, G_HWND_MANUAL_WINDOW, number


Comment #
	Lea Rax, value
	Mov Dl, Byte Ptr [Rax]
	And Edx, 000000FFH
	Cmp Dl, 30H
	Jb notNumber
	Cmp Dl, 36H
	Jg notNumber
		Sub Dl, 30H
		Dec Dl
		ECInvoke GetManualCmd, G_HWND_MANUAL_WINDOW, Rdx
		ECInvoke RunBtnCmdInfoCommand, Rax
		Ret


		#
notNumber:

		comment #

	ECInvoke lstrcmpi, Addr BACKSPACE_8, Addr value
	Test Eax, Eax
	Jnz notBackspace
		Lea Rax, CHAR_BUFF_COMMAND
		Cmp Byte Ptr [Rax], 0
		Jz @F
		Push Rax
		ECInvoke lstrlen, Rax
		Pop Rcx

		Mov Byte Ptr [Rcx + Rax - 1], 0
		ECInvoke SetWindowText, HWND_CURRENT_CMDNAME, Addr CHAR_BUFF_COMMAND
		Ret
notBackspace:
	ECInvoke lstrlen, Addr CHAR_BUFF_COMMAND
	Add Rax, vsize
	Cmp Rax, MAX_CMD_STR_LEN
	Jge @F
		ECInvoke lstrcat, Addr CHAR_BUFF_COMMAND, Addr value
		ECInvoke SetWindowText, HWND_CURRENT_CMDNAME, Addr CHAR_BUFF_COMMAND
		#
exit:
	Ret
SetInputSelect EndP
StopCmdInput Proc
;	Lea Rax, CHAR_BUFF_COMMAND
;	Mov QWord Ptr [Rax], 0

	;Mov IS_COMMAND_INPUTTING, 0;关闭命令接受模式
	;ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_MAIN_HOT_KEY
	ECInvoke CheckHotkeyTimeout
	ECInvoke CheckCommandTimeout
	;ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_COMMAND
	ECInvoke ShowRunCmdTip, G_HWND_TIP_WINDOW, Addr CHAR_BUFF_COMMAND, FALSE
	;ECInvoke WriteLog, CTXT("StopCmdInput"), 1
	Ret
StopCmdInput EndP

StartCmdInput Proc
	ECInvoke SetTimer, G_MAIN_WINDOW, TIMER_CHECK_MAIN_HOT_KEY, MAIN_HOT_KEY_TIMEOUT, 0
	ECInvoke SetTimer, G_MAIN_WINDOW, TIMER_CHECK_COMMAND, COMMAND_TIMEOUT, 0
	Mov IS_COMMAND_INPUTTING, 1;开启命令接受模式
	;ECInvoke WriteLog, CTXT("StartCmdInput"), 1
	Ret
StartCmdInput EndP

CheckHotkeyTimeout Proc
	ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_MAIN_HOT_KEY
	Mov MAIN_HOT_KEY_COUNT, 0
	Ret
CheckHotkeyTimeout EndP

CheckCommandTimeout Proc

	ECInvoke ShowRunCmdTip, G_HWND_TIP_WINDOW, Addr CHAR_BUFF_COMMAND, FALSE
	;ECInvoke WriteLog, CTXT("TIMER_CHECK_COMMAND timeout"), 1
	ECInvoke KillTimer, G_MAIN_WINDOW, TIMER_CHECK_COMMAND
	;Mov MAIN_HOT_KEY_COUNT, 0
	Lea Rax, CHAR_BUFF_COMMAND
	Mov QWord Ptr [Rax], 0
	Mov IS_COMMAND_INPUTTING, 0;关闭命令接受模式

	Ret
CheckCommandTimeout EndP

