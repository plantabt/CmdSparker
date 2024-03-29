;EasyCodeName=Controls,1
.Const
	BCM_SETNOTE Equ 00001609H
	BS_COMMANDLINK Equ 0000000EH
	;enum of btn cmdtype
	BTN_CMD_TYPE_CMD Equ 0
	BTN_CMD_TYPE_APP Equ 1
	;enum end
	MANUAL_WINDOW_WIDTH Equ 48 * 6 + 8 + 4 * 5
	MANUAL_WINDOW_HEIGHT Equ 48 + 8
	RUNMODE_WINDOW_HEIGHT Equ MANUAL_WINDOW_HEIGHT

	MANUAL_ICON_SIZE Equ 48
	RUNMODE_ICON_SIZE Equ 48

	MANUAL_BORDER_COLOR Equ 00EE6644H
	MANUAL_PLATE_COLOR Equ 00EE6644H / 2

	BORDER_COLOR Equ 00EE6644H
	BTN_BGK_COLOR Equ 00995555H
	BUTTON_NORMAL_COLOR Equ 00990000H
	BUTTON_HILIGHT_COLOR Equ 00FF6622H
	BUTTON_CLICK_COLOR Equ 00FF9966H

	HLINK_NORMAL_COLOR Equ 00AE0000H
	HLINK_HILIGHT_COLOR Equ 00FF0000H
	HLINK_CLICK_COLOR Equ 00880000H


	BUTTON_FLAT_NORMAL_COLOR Equ 00E48001H
	BUTTON_FLAT_HILIGHT_COLOR Equ 00E3D8CDH
	BUTTON_FLAT_CLICK_COLOR Equ 00CCA075H

	IMG_ITEM_WIDTH	Equ 48
	IMG_ITEM_HEIGHT	Equ 48

	MAX_FLASH_COUNT Equ 4

	WM_CONTIGUOUS_LBDBCLCK Equ WM_USER + 150H
	WM_ITEM_BTN_CLCK Equ WM_CONTIGUOUS_LBDBCLCK + 1
	WM_CFG_CHANGE Equ WM_ITEM_BTN_CLCK + 1
	WM_IMAGE_CHANGE Equ WM_CFG_CHANGE + 1
	WM_PAGE_UPDATE Equ WM_IMAGE_CHANGE + 1
	WM_CONFIG_UPDATE Equ WM_PAGE_UPDATE + 1
	WM_ICON_BTN_DOWN Equ WM_CONFIG_UPDATE + 1
	WM_ICON_BTN_UP Equ WM_ICON_BTN_DOWN + 1
	WM_ICON_BTN_MOVE Equ WM_ICON_BTN_UP + 1

	CMD_CTRL_LABEL Equ 201H
	CMD_BTN_ID_BASE Equ 10
	CTRL_PAGE_ID_BASE Equ 20
	CTRL_ITEM_ID_BASE Equ 30

	CTRL_BTN_PREVIOUS_PAGE Equ 50
	CTRL_BTN_NEXT_PAGE Equ 51

	CTRL_PAGE_NUMBER Equ 88

	CTRL_UPGRADE_CHKB_WAIT_EXIT Equ 100
	CTRL_UPGRADE_GOTO_WEBSIT Equ 101

	CTRL_CONFIG_BTN_EXIT_SETTING Equ 100
	CTRL_CONFIG_BTN_GUN_SIGHT Equ CTRL_CONFIG_BTN_EXIT_SETTING + 1
	CTRL_CONFIG_BTN_OPENFILE Equ CTRL_CONFIG_BTN_GUN_SIGHT + 1
	;配置窗口控件定义
	CTRL_CFG_EDIT_CMDLINE Equ 20H
	CTRL_CFG_EDIT_ARGS Equ 21H
	CTRL_CFG_CHKB_WAIT_EXIT Equ 22H
	CTRL_CFG_CHKB_RUN_ADMIN Equ 23H
	CTRL_CFG_CHKB_RUN_MANUAL Equ 24H
	CTRL_CFG_CHKB_SHUTDOWN Equ 25H
	CTRL_CFG_CHKB_RESTART Equ 26H
	MAX_CMD_PAIR Equ 50
.Data?
	PagePanelPropertys PAGE_PANEL_PROPERTY<?>
	G_ITEM_FLASH_QUEUE QWord ?
	G_ITEM_CURRENT_FLASH_NODE QWord ?
	;gCmdPairs DB SizeOf(CMD_PAIR_STRUCT) * MAX_CMD_PAIR Dup(?)
.Data

 CBUTTON DB "BUTTON", 0
 CSTATIC DB "STATIC", 0
 CEDIT DB 'EDIT', 0
 UnsetHotKey DB "UNSET", 0
 CPAGE_PANEL DB 'CLASS_PAGE_PANEL', 0
 CPANEL_CTRL DB 'CLASS_PANEL_CTRL', 0
 CLASS_IMAGE_BUTTON DB 'CLASS_IMAGE_BUTTON', 0
 CCONFIG_FRAME DB 'CCONFIG_FRAME', 0
 UPGRADE_FRAME DB 'UPGRADE_FRAME', 0
 CLASS_MANUAL_WINDOW DB 'CLASS_MANUAL_WINDOW', 0
 CLASS_CMDBAR_WINDOW DB 'CLASS_CMDBAR_WINDOW', 0
 CLASS_SHOW_CMD_NAME_WINDOW DB 'CLASS_SHOW_CMD_NAME_WINDOW', 0
.Code

CreateBaseCtrl Proc hParent:HWND, cbClassName:QWord, cbTitle:QWord, style:QWord, exStyle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord
	;Local hWnd:QWord
	Mov hParent, Rcx
	Mov cbClassName, Rdx
	Mov cbTitle, R8
	Mov style, R9

	ECInvoke CreateWindowEx, exStyle, cbClassName, cbTitle, style, xpos, ypos, nWidth, nHeight, hParent, cbID, cbhInst, 0
	Push Rax
	ECInvoke SetWindowFont, Rax, hfont
	Pop Rax
	Ret
CreateBaseCtrl EndP

CreateBaseWindow Proc parentHwnd:QWord, exStyle:QWord, style:QWord, wndProc:QWord, pClassName:QWord, pTitle:QWord, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, ctrlID:QWord, hFont:QWord
	Local hwnd:QWord

	Mov parentHwnd, Rcx
	Mov exStyle, Rdx
	Mov style, R8
	Mov wndProc, R9

	Mov Rdx, wndProc
	Mov R8, pClassName
	ECInvoke RegisterCtrlClass, _hInst, Rdx, R8
	ECInvoke CreateWindowEx, exStyle, pClassName, pTitle, style, xpos, ypos, iWidth, iHeight, parentHwnd, ctrlID, _hInst, 0
	Mov hwnd, Rax
	Cmp hFont, 0
	Je @F
	ECInvoke SetWindowFont, Rax, hFont
@@:
	ECInvoke SetWindowLongPtr, hwnd, GWL_WNDPROC, wndProc
	Mov Rax, hwnd
	Ret
CreateBaseWindow EndP

CreateRoundrectWindow Proc hParent:QWord, exStyle:QWord, style:QWord, wndProc:QWord, pClassName:QWord, pTitle:QWord, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, ctrlID:QWord, hFont:QWord
	Local hWnd:QWord

	Mov hParent, Rcx
	Mov exStyle, Rdx
	Mov style, R8
	Mov wndProc, R9


	ECInvoke CreateBaseWindow, hParent, exStyle, style, wndProc, pClassName, pTitle, xpos, ypos, iWidth, iHeight, _hInst, ctrlID, hFont
	Mov hWnd, Rax
	ECInvoke SetWindowRoundRect, Rax
	Mov Rax, hWnd
	Ret
CreateRoundrectWindow EndP

CreateButton Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord

	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9
	ECInvoke CreateBaseCtrl, hParent, Addr CBUTTON, cbTitle, (WS_CHILD OR WS_VISIBLE), 0, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont

	Ret
CreateButton EndP

CreateGroupBox Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord

	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9
	ECInvoke CreateBaseCtrl, hParent, Addr CBUTTON, cbTitle, (WS_CHILD OR WS_VISIBLE OR BS_GROUPBOX), 0, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont

	Ret
CreateGroupBox EndP

CreateCheckBox Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord, checked:QWord

	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9
	ECInvoke CreateBaseCtrl, hParent, Addr CBUTTON, cbTitle, (WS_CHILD OR WS_VISIBLE OR BS_AUTOCHECKBOX), 0, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont
	ECInvoke CheckDlgButton, hParent, cbID, checked
	Ret
CreateCheckBox EndP

CreateRadio Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord

	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9
	ECInvoke CreateBaseCtrl, hParent, Addr CBUTTON, cbTitle, (WS_CHILD OR WS_VISIBLE OR BS_AUTORADIOBUTTON), 0, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont

	Ret
CreateRadio EndP


CreateLabel Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord, appStyle:QWord
	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9
	Mov Rax, appStyle
	Xor Rax, (WS_CHILD OR WS_VISIBLE)
	ECInvoke CreateBaseCtrl, hParent, Addr CSTATIC, cbTitle, Rax, 0, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont
	Ret
CreateLabel EndP

CreateEdit Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, exStyle:QWord, hfont:QWord
	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9
	ECInvoke CreateBaseCtrl, hParent, Addr CEDIT, cbTitle, (WS_CHILD OR WS_VISIBLE OR ES_AUTOHSCROLL), exStyle, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont
	Ret
CreateEdit EndP

CreateLabelEdit Proc hParent:HWND, lbTitle:QWord, edTitle:QWord, xpos:QWord, ypos:QWord, lbWidth:QWord, edWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord
	Mov hParent, Rcx
	Mov lbTitle, Rdx
	Mov edTitle, R8
	Mov xpos, R9

	Mov Rax, ypos
	Add Rax, 4
	Mov R9, cbID
	Inc R9
	ECInvoke CreateLabel, hParent, lbTitle, xpos, Rax, lbWidth, nHeight, R9, cbhInst, hfont, 0
	Mov Rax, xpos
	Add Rax, lbWidth

	Mov xpos, Rax
	;Inc cbID
	ECInvoke CreateEdit, hParent, edTitle, xpos, ypos, edWidth, nHeight, cbID, cbhInst, WS_EX_CLIENTEDGE, hfont
	Ret
CreateLabelEdit EndP

CreateHLink Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, exStyle:QWord, pUrl:QWord
	Local hWnd:HWND
	Local pHlinkBtnInfo:QWord
	Local hlfont:HFONT
	Local pText:QWord
	Local newUrl:QWord
	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9

	ECInvoke NewStr, pUrl, 0
	Mov newUrl, Rax
	ECInvoke NewStr, 0, MAX_PATH
	Mov pText, Rax
	ECInvoke lstrcpy, Rax, cbTitle

;	ECInvoke CreateWindowEx, 0, _T("STATIC"), _T("点击这里访问链接"), WS_CHILD | WS_VISIBLE | SS_NOTIFY, 50, 50, 200, 30, hWnd, (HMENU) 1001, GetModuleHandle(NULL), NULL)
;	ECInvoke CreateBaseCtrl, hParent, Addr CBUTTON, cbTitle, (WS_CHILD OR WS_VISIBLE OR BS_COMMANDLINK), exStyle, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont
	;ECInvoke CreateBaseCtrl, hParent, Addr CBUTTON, cbTitle, (WS_VISIBLE OR WS_CHILD OR BS_COMMANDLINK), exStyle, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hfont
	;ECInvoke CreateFont, 14, 0, 0, 0, FW_BOLD, FALSE, TRUE, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, (DEFAULT_PITCH OR FF_SWISS), CTXT("Arial")
	ECInvoke CreateSystemFont, 14, TRUE, 0
	Mov hlfont, Rax
	ECInvoke CreateBaseCtrl, hParent, Addr CSTATIC, 0, (WS_VISIBLE OR WS_CHILD OR SS_NOTIFY OR SS_CENTER), exStyle, xpos, ypos, nWidth, nHeight, cbID, cbhInst, hlfont
	Mov hWnd, Rax

	

	ECInvoke GlobalAlloc, GPTR, SizeOf (HLINK_BTN_INFO)
	Mov pHlinkBtnInfo, Rax
	Mov Rcx, hlfont
	Mov [Rax].HLINK_BTN_INFO.hFont, Rcx
	Mov Rcx, newUrl
	Mov [Rax].HLINK_BTN_INFO.pUrl, Rcx
	Mov Rcx, pText
	Mov [Rax].HLINK_BTN_INFO.pText, Rcx
	Mov Ecx, HLINK_NORMAL_COLOR
	Mov [Rax].HLINK_BTN_INFO.CUR_COLOR, Ecx
	ECInvoke SetWindowLongPtr, hWnd, GWLP_USERDATA, pHlinkBtnInfo

	ECInvoke SetWindowSubclass, hWnd, Addr HLinkCtrlProc, 1, 0

	Mov Rax, hWnd
	Ret
CreateHLink EndP

SetHLinkText Proc hWnd:HWND, pText:QWord
	Local pHlinkBtnInfo:QWord
	Local tmp:QWord
	Mov hWnd, Rcx
	Mov pText, Rdx

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pHlinkBtnInfo, Rax
	Mov Rcx, [Rax].HLINK_BTN_INFO.pText
	Mov tmp, Rcx
	ECInvoke lstrcpy, tmp, pText
	ECInvoke UpdateInWindow, hWnd
	Ret
SetHLinkText EndP

DestoryHLink Proc hWnd:HWND
	Local pHlinkBtnInfo:QWord
	Mov hWnd, Rcx
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pHlinkBtnInfo, Rax
	;free purl
	Mov Rax, [Rax].HLINK_BTN_INFO.pUrl
	ECInvoke DelStr, Rax
	;delete object
	Mov Rax, pHlinkBtnInfo
	Mov Rax, [Rax].HLINK_BTN_INFO.hFont
	ECInvoke DeleteObject, Rax
	;free text
	Mov Rax, pHlinkBtnInfo
	Mov Rax, [Rax].HLINK_BTN_INFO.pText
	ECInvoke DelStr, Rax
	;free info
	ECInvoke GlobalFree, pHlinkBtnInfo
	Ret
DestoryHLink EndP

CreateImgButton Proc hParent:HWND, cbTitle:QWord, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord
	Local hwnd:QWord
	Local oldWndProc:QWord
	Mov hParent, Rcx
	Mov cbTitle, Rdx
	Mov xpos, R8
	Mov ypos, R9

	;ECInvoke CreateBaseWindow, hParent, 0, (WS_CHILD OR WS_VISIBLE), Addr ImageBtnCtrlProc, Addr CLASS_IMAGE_BUTTON, 0, xpos, ypos, nWidth, nHeight, cbhInst, cbID, hfont
	ECInvoke CreateWindowEx, 0, Addr CBUTTON, cbTitle, (WS_CHILD OR WS_VISIBLE), xpos, ypos, nWidth, nHeight, hParent, cbID, cbhInst, 0
	Mov hwnd, Rax
	ECInvoke SetWindowFont, hwnd, hfont
	ECInvoke DragAcceptFiles, hwnd, TRUE

	;ECInvoke SetWindowLongPtr, hwnd, GWLP_WNDPROC, Offset ImageBtnCtrlProc
	Mov oldWndProc, Rax

	Mov Rax, hwnd
	ECInvoke GlobalAlloc, GPTR, SizeOf (BTN_CMD_INFO)
	Push Rax
	ECInvoke ZeroMemory, Rax, SizeOf BTN_CMD_INFO
	Pop R8
;	Mov Rax, oldWndProc

;	Mov [R8 + BTN_CMD_INFO.oldWndProc], Rax
	ECInvoke SetWindowLongPtr, hwnd, GWLP_USERDATA, R8
	ECInvoke SetWindowSubclass, hwnd, Offset ImageBtnCtrlProc, 1, 0
	Mov Rax, hwnd
	Ret
CreateImgButton EndP

CreateRunCmdTip Proc ;pTitle:QWord;, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, ctrlID:QWord
	Local hWnd:HWND
	;Mov pTitle, Rcx
	;Mov xpos, Rdx
	;Mov ypos, R8
	;Mov iWidth, R9

	ECInvoke CreateRoundrectWindow, 0, 0, WS_POPUP, Addr ShowRunCmdTipProc, Addr CLASS_SHOW_CMD_NAME_WINDOW, 0, 0, 0, 400, 400, 0, 0, 0
	Mov hWnd, Rax
	ECInvoke SetWindowPos, hWnd, HWND_TOPMOST, 0, 0, 1, 1, SWP_NOMOVE
	;ECInvoke CenterWindow, hWnd
;	ECInvoke BrushWindow, hWnd
;	ECInvoke ShowWindowEx, hWnd, FALSE

	;ECInvoke DestroyWindow, hWnd
	Mov Rax, hWnd
	Ret
CreateRunCmdTip EndP

ShowRunCmdTipThread Proc qhb:QWord
	Local hWnd:HWND
	Local delay:DWord
	Local bShow:DWord
	Mov qhb, Rcx
	Mov Rax, Rcx

	Mov Rcx, Rax
	And Ecx, 0FFFFFFFFH
	Mov hWnd, Rcx
	Shr Rax, 32
	Mov bShow, Eax
	Xor Al, 1
	Xor Edx, Edx
	Mov Ecx, 2000
	IMul Eax, Ecx

	Mov delay, Eax
Comment #
	Cmp bShow, 1
	Je @F
	ECInvoke Sleep, delay
@@:
#
	ECInvoke UpdateInWindow, hWnd

	ECInvoke ShowWindowEx, hWnd, bShow
	Ret
ShowRunCmdTipThread EndP

ShowRunCmdTip Proc hWnd:QWord, pText:QWord, bShow:DWord
	Local qhb:QWord
	Mov hWnd, Rcx
	Mov pText, Rdx
	Mov bShow, R8d


	Mov Eax, bShow
	Shl Rax, 32
	Or Rax, Rcx
	Mov qhb, Rax

	ECInvoke SetWindowText, hWnd, pText
	ECInvoke CreateThread, 0, 0, Addr ShowRunCmdTipThread, qhb, 0, 0


	Ret
ShowRunCmdTip EndP

DestroyRunCmdTip Proc hWnd:QWord
	Mov hWnd, Rcx
	ECInvoke PostMessage, hWnd, WM_SYSCOMMAND, SC_CLOSE, 0
	Ret
DestroyRunCmdTip EndP

GetFlatIconButtonPushed Proc hWnd:QWord
	Local ibi:QWord
	Mov hWnd, Rcx

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov ibi, Rax
	Mov Rax, QWord Ptr [Rax].ICON_BTN_INFO.STATE

	Ret
GetFlatIconButtonPushed EndP

SetFlatIconButtonPushed Proc hWnd:QWord, state:QWord
	Local ibi:QWord
	Mov hWnd, Rcx
	Mov state, Rdx

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov ibi, Rax
	Mov Rcx, state
	Mov QWord Ptr [Rax].ICON_BTN_INFO.STATE, Rcx

	Ret
SetFlatIconButtonPushed EndP

CreateFlatIconButton Proc hParent:HWND, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, iconSize:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord, IconId:QWord, inColor:QWord, normalColor:QWord, downColor:QWord, iconColor:QWord, isPushType:QWord
	Local hWnd:QWord
	Local hRect:RECT
	Local iconRect:RECT
	Local ibi:QWord

	Mov hParent, Rcx
	Mov xpos, Rdx
	Mov ypos, R8
	Mov nWidth, R9


	ECInvoke GlobalAlloc, GPTR, SizeOf ICON_BTN_INFO
	Mov ibi, Rax
	ECInvoke ZeroMemory, ibi, SizeOf ibi

	ECInvoke CreateWindowEx, 0, Addr CBUTTON, 0, (WS_CHILD OR WS_VISIBLE OR  BS_FLAT), xpos, ypos, nWidth, nHeight, hParent, cbID, cbhInst, 0
	Mov hWnd, Rax
	;ECInvoke GetClientRect, hWnd, Addr hRect


	Mov iconRect.left, 0
	Mov iconRect.top, 0
	Mov Rax, iconSize
	Mov iconRect.right, Eax
	Mov iconRect.bottom, Eax
	ECInvoke CreateIconWithID, IconId, Addr iconRect, iconColor

	Mov Rcx, ibi
	Mov QWord Ptr [Rcx].ICON_BTN_INFO.PICON_OBJECT, Rax
	Mov Rax, inColor
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.IN_COLOR, Eax
	Mov Rax, normalColor
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.NORMAL_COLOR, Eax
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.CURR_COLOR, Eax
	Mov Rax, downColor
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.DOWN_COLOR, Eax
	Mov Rax, isPushType
	Mov QWord Ptr [Rcx].ICON_BTN_INFO.IS_PUSH_TYPE, Rax
	Mov QWord Ptr [Rcx].ICON_BTN_INFO.STATE, FALSE
;	ECInvoke GlobalAlloc, GPTR, SizeOf (BTN_CMD_INFO)
;	Push Rax
;	ECInvoke ZeroMemory, Rax, SizeOf BTN_CMD_INFO
;	Pop R8
	ECInvoke SetWindowLongPtr, hWnd, GWLP_USERDATA, ibi
	ECInvoke SetWindowSubclass, hWnd, Offset FlatIconBtnProc, 1, 0
	Ret
CreateFlatIconButton EndP

CreateIconButton Proc hParent:HWND, xpos:QWord, ypos:QWord, nWidth:QWord, nHeight:QWord, cbID:QWord, cbhInst:QWord, hfont:QWord, IconId:QWord, inColor:QWord, normalColor:QWord, downColor:QWord
	Local hWnd:QWord
;	Local hRgn:QWord
	Local hRect:RECT
	Local ibi:QWord

	Mov hParent, Rcx
	;Mov cbTitle, Rdx
	Mov xpos, Rdx
	Mov ypos, R8
	Mov nWidth, R9

	ECInvoke GlobalAlloc, GPTR, SizeOf ICON_BTN_INFO
	Mov ibi, Rax
	ECInvoke ZeroMemory, ibi, SizeOf ibi

	ECInvoke CreateWindowEx, 0, Addr CBUTTON, 0, (WS_CHILD OR WS_VISIBLE OR  BS_FLAT), xpos, ypos, nWidth, nHeight, hParent, cbID, cbhInst, 0
	Mov hWnd, Rax
	ECInvoke GetClientRect, hWnd, Addr hRect




	ECInvoke CreateIconWithID, IconId, Addr hRect, normalColor

	Mov Rcx, ibi
	Mov QWord Ptr [Rcx].ICON_BTN_INFO.PICON_OBJECT, Rax

	Mov Rax, inColor
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.IN_COLOR, Eax
	Mov Rax, normalColor
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.NORMAL_COLOR, Eax
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.CURR_COLOR, Eax
	Mov Rax, downColor
	Mov DWord Ptr [Rcx].ICON_BTN_INFO.DOWN_COLOR, Eax

;	ECInvoke GlobalAlloc, GPTR, SizeOf (BTN_CMD_INFO)
;	Push Rax
;	ECInvoke ZeroMemory, Rax, SizeOf BTN_CMD_INFO
;	Pop R8
	ECInvoke SetWindowLongPtr, hWnd, GWLP_USERDATA, ibi
	ECInvoke SetWindowSubclass, hWnd, Offset IconBtnProc, 1, 0
	Ret
CreateIconButton EndP

RegisterCtrlClass Proc _hInst:QWord, wndProc:QWord, pClassName:QWord
	Local wc:WNDCLASSEX
	Mov _hInst, Rcx
	Mov wndProc, Rdx
	Mov pClassName, R8


	ECInvoke IsClassRegistered, pClassName
	Cmp Rax, 0
	Jnz @F


	Mov wc.cbSize, SizeOf WNDCLASSEX
	Mov wc.style, (CS_DBLCLKS OR CS_HREDRAW OR CS_VREDRAW)

	Mov Rax, wndProc
	Mov wc.lpfnWndProc, Rax
	Mov wc.cbClsExtra, 0
	Mov wc.cbWndExtra, 0
	Mov Rax, _hInst
	Mov wc.hInstance, Rax
	Mov wc.hIcon, NULL
	ECInvoke LoadImage, NULL, OCR_NORMAL, IMAGE_CURSOR, 0, 0, (LR_DEFAULTSIZE OR LR_LOADMAP3DCOLORS OR LR_SHARED)
	Mov wc.hCursor, Rax
	Mov wc.hbrBackground, (COLOR_BTNFACE + 1)
	Mov wc.lpszMenuName, NULL
	Mov Rax, pClassName
	Mov wc.lpszClassName, Rax
	Mov wc.hIconSm, NULL
	ECInvoke RegisterClassEx, Addr wc
@@:
	Ret
RegisterCtrlClass EndP


CreateCmdBarWindow Proc itemCount:DWord, pageCount:DWord, iconSize:DWord, wndProc:QWord
	Local hInst:QWord
	Local hWnd:QWord
	Local rRect:RECT
	Local pCmdBarWindowInfo:QWord
	Local pIconObject:QWord
	Local icoCnt:DWord
	Local iWidth:DWord
	Local iHeight:DWord
	Local iCmdInfoSize:DWord
	Mov itemCount, Ecx
	Mov pageCount, Edx
	Mov iconSize, R8d
	Mov wndProc, R9


	ECInvoke GetModuleHandle, 0
	Mov hInst, Rax

	ECInvoke GlobalAlloc, GPTR, SizeOf (CMDBAR_WINDOW_INFO)
	Push Rax
	ECInvoke ZeroMemory, Rax, SizeOf (CMDBAR_WINDOW_INFO)
	Pop Rax
	Mov pCmdBarWindowInfo, Rax
	Lea Rax, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos
	Push Rax

	Mov Eax, itemCount
	Lea Rax, [Rax * 8]
	Mov Ecx, pageCount
	Xor Edx, Edx
	IMul Eax, Ecx
	Mov iCmdInfoSize, Eax
	ECInvoke GlobalAlloc, GPTR, Rax;多少个按钮
	Pop Rcx
	Mov [Rcx], Rax


	Mov Eax, itemCount
	Xor Edx, Edx
	Mov Ecx, iconSize
	IMul Eax, Ecx
	Add Eax, 8
	Mov iWidth, Eax
	Mov Eax, itemCount
	Dec Eax
	Xor Edx, Edx
	Mov Ecx, 4
	IMul Eax, Ecx
	Add iWidth, Eax

	Mov Eax, iconSize
	Add Eax, 8
	Mov iHeight, Eax


	ECInvoke CreateBaseWindow, 0, 0, WS_POPUP, wndProc, Addr CLASS_CMDBAR_WINDOW, 0, 0, 0, iWidth, iHeight, hInst, 0, 0

	Mov hWnd, Rax

	Mov rRect.top, 0
	Mov rRect.left, 0
	Mov Eax, iconSize
	Mov rRect.right, Eax
	Mov rRect.bottom, Eax
	ECInvoke Icon_Roundrect, Addr rRect, MANUAL_PLATE_COLOR, 4
	Mov pIconObject, Rax

	Mov Rcx, pCmdBarWindowInfo
	Lea R8, [Rcx].CMDBAR_WINDOW_INFO.pIconRoundrect
	Mov [R8], Rax

	Mov Eax, itemCount
	Lea R8, [Rcx].CMDBAR_WINDOW_INFO.iBtnCount
	Mov [R8], Rax

	;save info buffer size
	Mov R8d, iCmdInfoSize
	Mov [Rcx].CMDBAR_WINDOW_INFO.iBtnCmdInfoSize, R8
	Mov Rcx, [Rcx].CMDBAR_WINDOW_INFO.pBtnCmdInfos
	ECInvoke ZeroMemory, Rcx, iCmdInfoSize

	ECInvoke SetWindowLongPtr, hWnd, GWLP_USERDATA, pCmdBarWindowInfo

	ECInvoke SetWindowRoundRect, hWnd

	ECInvoke CenterWindow, hWnd, 0, 0
	ECInvoke ShowWindowEx, hWnd, FALSE


	Mov Rax, hWnd
	Ret
CreateCmdBarWindow EndP

DestroyCmdBarWindow Proc hWnd:HWND
	Local pRunModeInfo:QWord
	Mov hWnd, Rcx
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pRunModeInfo, Rax
	Mov Rcx, [Rax].CMDBAR_WINDOW_INFO.pIconRoundrect
	ECInvoke DestroyIconObject, Rcx

	Mov Rax, pRunModeInfo
	Mov Rcx, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos
	ECInvoke GlobalFree, Rcx
	ECInvoke DestroyWindow, hWnd
	;ECInvoke CloseWindow, hWnd
	Ret
DestroyCmdBarWindow EndP

CreateRunModeWindow Proc itemCount:DWord, pageCount:DWord
	;Mov itemCount, ecx
	ECInvoke CreateCmdBarWindow, Rcx, Rdx, RUNMODE_ICON_SIZE, Addr RunModeWndProc
	Ret
CreateRunModeWindow EndP

DestroyRunModeWindow Proc hWnd:HWND
;	Mov hWnd, Rcx
	ECInvoke DestroyCmdBarWindow, Rcx
	Ret
DestroyRunModeWindow EndP

CreateManualRunWindow Proc itemCount:DWord, pageCount:DWord
	;Mov itemCount, Rcx
	;mov pageCount,rdx
	ECInvoke CreateCmdBarWindow, Rcx, Rdx, RUNMODE_ICON_SIZE, Addr ManualRunWndProc
	Ret
CreateManualRunWindow EndP

FlashThread Proc hWnd:QWord
	Local count:DWord
	Local xPos:DWord
	Local hdc:HDC
	Local pNode:QWord
	Local flashItemNode:FLASH_ITEM_NODE
	Mov hWnd, Rcx
	Mov count, 0

	ECInvoke GetDC, hWnd
	Mov hdc, Rax

	ECInvoke GetQueue, Addr G_ITEM_FLASH_QUEUE

	Mov pNode, Rax

	Mov Rax, [Rax].NODE.Value
	ECInvoke memcpy, Addr flashItemNode, Rax, SizeOf FLASH_ITEM_NODE

	Mov Eax, flashItemNode.index
	Xor Edx, Edx
	Mov Ecx, 4
	IMul Eax, Ecx
	Mov xPos, Eax

	Mov Eax, flashItemNode.index
	Xor Edx, Edx
	Mov Ecx, MANUAL_ICON_SIZE
	IMul Eax, Ecx
	Add xPos, Eax
	Add xPos, 4

_loop_flash:
	ECInvoke PatBlt, hdc, xPos, 4, MANUAL_ICON_SIZE, MANUAL_ICON_SIZE, DSTINVERT
	ECInvoke Sleep, 30 ;flash stamp
	ECInvoke PatBlt, hdc, xPos, 4, MANUAL_ICON_SIZE, MANUAL_ICON_SIZE, DSTINVERT
	ECInvoke Sleep, 30 ;flash stamp
	ECInvoke UpdateInWindow, hWnd
	Inc count
	Cmp count, MAX_FLASH_COUNT
	Jb _loop_flash

	ECInvoke ReleaseDC, hWnd, hdc
	ECInvoke DeleteDC, hdc
	ECInvoke DestroyNode, pNode

	Ret
FlashThread EndP

FlashManualRunItem Proc hWnd:QWord, itemIdx:DWord
	Local flashItem:FLASH_ITEM_NODE
	Mov hWnd, Rcx
	Mov itemIdx, Edx

	ECInvoke ZeroMemory, Addr flashItem, SizeOf flashItem

	Mov Ecx, itemIdx
	Mov flashItem.FLASH_ITEM_NODE.index, Ecx
	Mov flashItem.FLASH_ITEM_NODE.fCount, MAX_FLASH_COUNT

	ECInvoke CreateQueueNode, Addr flashItem, SizeOf FLASH_ITEM_NODE
	Mov G_ITEM_FLASH_QUEUE, Rax
	ECInvoke InsertQueue, Addr G_ITEM_FLASH_QUEUE, Rax


	ECInvoke CreateThread, 0, 0, Addr FlashThread, hWnd, 0, 0
	Ret
FlashManualRunItem EndP

DestroyManualRunWindow Proc hWnd:HWND
;	Mov hWnd, Rcx
	ECInvoke DestroyCmdBarWindow, Rcx
	Ret
DestroyManualRunWindow EndP

GetPage Proc idx:QWord
	Mov idx, Rcx
	Lea Rax, PagePanelPropertys.hPages
	Mov Rax, [Rax + Rcx * 8]
	Ret
GetPage EndP

NextPage Proc

	Mov Rax, PagePanelPropertys.iCurrentPage
	Inc Eax
	ECInvoke ShowPage, Rax
	;Mov Rcx, PagePanelPropertys.iCurrentPage
	;Add Rcx, Rax
	;Mov PagePanelPropertys.iCurrentPage, Rcx
	Ret
NextPage EndP

PreviousPage Proc

	Mov Rax, PagePanelPropertys.iCurrentPage
	Dec Eax
	ECInvoke ShowPage, Rax
;	Mov Rcx, PagePanelPropertys.iCurrentPage
	;Sub Rcx, Rax
	;Mov PagePanelPropertys.iCurrentPage, Rcx
	Ret
PreviousPage EndP

ShowPage Proc idx:QWord
	;隐藏指定页

	Local result:QWord
	Local strNumber[10]:DB
	Mov idx, Rcx

	Mov result, 0

	Cmp idx, 0
	Jl @F
	Mov Rax, PagePanelPropertys.iMaxPage
	Dec Rax
	Cmp idx, Rax
	Jg @F

	ECInvoke GetPage, idx

	ECInvoke ShowWindow, Rax, SW_SHOW
	;设置页数

	; StrToIntExW
	Mov Rdx, idx
	Inc Edx
	ECInvoke NumberToString, Addr strNumber, Rdx
	Mov Rcx, PagePanelPropertys.hPageNumber
	ECInvoke SetWindowText, Rcx, Addr strNumber

	;隐藏之前显示的页
	Mov Rax, PagePanelPropertys.iCurrentPage
	Cmp idx, Rax
	Jz @F
		Mov Rax, PagePanelPropertys.iCurrentPage
		ECInvoke GetPage, Rax
		ECInvoke ShowWindow, Rax, SW_HIDE

		;更改当前页
		Mov Rax, idx
		Mov PagePanelPropertys.iCurrentPage, Rax
		Mov result, 1
@@:
	Mov Rax, result
	Ret
ShowPage EndP

;获取命令名
GetCmdName Proc hCmditem:QWord, pOutCmdName:QWord
;	Mov hCmditem, Rcx
	Mov pOutCmdName, Rdx
	ECInvoke GetDlgItem, Rcx, CMD_CTRL_LABEL
	ECInvoke GetWindowText, Rax, pOutCmdName, MAX_CMD_STR_LEN
	ECInvoke lstrlen, pOutCmdName
	Ret
GetCmdName EndP

;获取btn条目
GetCmditem Proc hPage:QWord, cmdItemIdx:QWord
	;Mov hPage, Rcx
	Mov cmdItemIdx, Rdx
	;Mov pOutCmdName, R8

	Add cmdItemIdx, CTRL_ITEM_ID_BASE
	ECInvoke GetDlgItem, Rcx, cmdItemIdx

	Ret
GetCmditem EndP

;获取btn中的命令
GetItemBtnCmd Proc hCmditem:QWord, btnIdx:QWord
	Mov hCmditem, Rcx
	Mov btnIdx, Rdx

	Add btnIdx, CMD_BTN_ID_BASE
	ECInvoke GetDlgItem, hCmditem, btnIdx
	ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA
	Ret
GetItemBtnCmd EndP

;获取命令条目上的命令行
GetCmditemCmdLine Proc pageIdx:QWord, cmdItemIdx:QWord, cmdIdx:QWord
	Local hPage:HWND
	Local hCmditem:HWND
	Local cmdItemCtrlId:QWord

	Mov pageIdx, Rcx
	Mov cmdItemIdx, Rdx
	Mov cmdIdx, R8

	ECInvoke GetPage, pageIdx
	Mov hPage, Rax

	ECInvoke GetCmditem, hPage, cmdItemIdx
	Mov hCmditem, Rax

	ECInvoke GetItemBtnCmd, hCmditem, 0



	Ret
GetCmditemCmdLine EndP

;获取命令条目命令名
GetCmditemCmdName Proc pageIdx:QWord, cmdItemIdx:QWord, cmdIdx:QWord, pOutCmdName:QWord
	Local hPage:HWND
	Local hCmditem:HWND
	Local cmdItemCtrlId:QWord

	Mov pageIdx, Rcx
	Mov cmdItemIdx, Rdx
	Mov cmdIdx, R8
	Mov pOutCmdName, R9

	ECInvoke GetPage, pageIdx
	Mov hPage, Rax

	ECInvoke GetCmditem, hPage, cmdItemIdx
	Mov hCmditem, Rax

	ECInvoke GetCmdName, hCmditem, pOutCmdName


	Mov Eax, 1
	Ret
GetCmditemCmdName EndP

;获取命中的命令条目
GetCommandForCmdbtn Proc pCmdname:QWord, maxPage:QWord, pOutCmdList:QWord, pOutCmdManualList:QWord
	Local loopPage:QWord
	Local loopItem:QWord
	Local loopBtn:QWord
	Local loopCount:QWord
	Local loopCountCmditem:QWord
	Local loopCountCmdname:QWord
	Local loopCountCmdBtn:QWord
	Local lenCmdname:QWord
	Local pBtnCmdInfo:QWord
	Local hPage:HWND
	Local hCmdItem:HWND
	Local cmdName[50]:Byte
	Local lenInCmdname:QWord
	Local isHit:BOOL
	Mov pCmdname, Rcx
	Mov maxPage, Rdx
	Mov pOutCmdList, R8
	Mov pOutCmdManualList, R9
	Mov loopCount, 0

	Mov isHit, 0
	ECInvoke lstrlen, pCmdname
	Mov lenInCmdname, Rax

_looppage:

	ECInvoke GetPage, loopCount
	Mov hPage, Rax
	Test Eax, Eax
	Je _nfp

		Mov loopCountCmditem, 0
		_loopitem:
			ECInvoke GetCmditem, hPage, loopCountCmditem

			Mov hCmdItem, Rax
			Test Eax, Eax
			Je _next_item

			Mov loopCountCmdname, 0
			Lea Rax, cmdName
			Mov QWord Ptr [Rax], 0

			ECInvoke GetCmdName, hCmdItem, Addr cmdName
			Mov lenCmdname, Rax
			Lea Rax, cmdName
			Mov Rax, [Rax]
			Test Al, Al
			Je _next_item
			;命中命令
			Mov Rax, lenCmdname
			Cmp lenInCmdname, Rax
			Jnz _next_item
			ECInvoke IsMemEqul, pCmdname, Addr cmdName, lenCmdname
			Test Al, Al
			Jz _next_item

				;返回命令列表
				Mov loopCountCmdBtn, 0
				Mov isHit, 1
_loopgetbtncmd:

				ECInvoke GetItemBtnCmd, hCmdItem, loopCountCmdBtn
				Mov pBtnCmdInfo, Rax

				Mov Rcx, [Rax].BTN_CMD_INFO.cmdbManual
				Test Ecx, Ecx
				Jz nmd
				Mov Rcx, QWord Ptr [Rax].BTN_CMD_INFO.cmdLine
				Test Ecx, Ecx
				Jz nmd

				Mov Rcx, pOutCmdManualList
				Add pOutCmdManualList, 8
				Jmp @F
nmd:
				Mov Rcx, pOutCmdList
				Add pOutCmdList, 8
@@:
				Mov Rax, pBtnCmdInfo
				Mov [Rcx], Rax

				Inc loopCountCmdBtn
				Mov Rax, loopCountCmdBtn
				Cmp Rax, MAX_CMD_ITEM_BTN
				Jb _loopgetbtncmd
				;ECInvoke RunCommand
				;Mov Eax, 1
				;Ret

	_next_item:
		Inc loopCountCmditem
		Mov Rax, loopCountCmditem
		Cmp Rax, MAX_CMD_ITEM
		Jb _loopitem

_nfp:
	Inc loopCount
	Mov Rax, loopCount
	Cmp Rax, maxPage
	Jb _looppage

	Mov Eax, isHit
	Ret
GetCommandForCmdbtn EndP

CreatePagePanel Proc parentHwnd:QWord, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, ctrlID:QWord, hFont:QWord, pageCount:QWord
	Local wc:WNDCLASSEX
	Local hwnd:QWord
    Local btnx:DWord
    Local btny:DWord

    Local count:QWord
    Local rcClient:RECT
	Local countBtn:QWord
	Local hwndMainPage:HWND
	Local pageCtrlID:QWord
	Mov parentHwnd, Rcx
	Mov xpos, Rdx
	Mov ypos, R8
	Mov iWidth, R9

	Mov PagePanelPropertys.iCurrentPage, 0
	Mov Rax, pageCount
	Mov PagePanelPropertys.iMaxPage, Rax

	Lea Rdx, PagePanelCtrlProc
	Lea R8, CPAGE_PANEL
	ECInvoke RegisterCtrlClass, _hInst, Rdx, R8

	ECInvoke CreateWindowEx, WS_EX_CONTROLPARENT, Addr CPAGE_PANEL, 0, (WS_CHILD OR WS_VISIBLE), xpos, ypos, iWidth, iHeight, parentHwnd, ctrlID, _hInst, 0
	Mov hwndMainPage, Rax


	;添加页数标签控件
	Mov R8, iHeight
	Mov Rdx, iWidth
	Shr Edx, 1
	Sub Edx, 9
	Mov xpos, Rdx

	Sub R8, 24
	Mov ypos, R8
	ECInvoke CreateLabel, hwndMainPage, 0, xpos, ypos, 20, 18, CTRL_PAGE_NUMBER, _hInst, hFont, 0
	Mov PagePanelPropertys.hPageNumber, Rax




	Mov Rax, iHeight
	Sub Rax, 26
	ECInvoke CreateIconButton, hwndMainPage, 5, Rax, 9, 18, CTRL_BTN_PREVIOUS_PAGE, _hInst, hFont, ID_ICON_TRIANGLE_LEFT, BUTTON_HILIGHT_COLOR, BUTTON_NORMAL_COLOR, BUTTON_CLICK_COLOR


	Mov Rax, iHeight
	Sub Rax, 26
	Mov Rcx, iWidth
	Sub Rcx, 16
	ECInvoke CreateIconButton, hwndMainPage, Rcx, Rax, 9, 18, CTRL_BTN_NEXT_PAGE, _hInst, hFont, ID_ICON_TRIANGLE_RIGHT, BUTTON_HILIGHT_COLOR, BUTTON_NORMAL_COLOR, BUTTON_CLICK_COLOR


	;创建页
	Sub iHeight, 28
	Mov count, 0
	Mov pageCtrlID, CTRL_PAGE_ID_BASE
createPage:
	ECInvoke CreatePanel, hwndMainPage, 0, 0, iWidth, iHeight, _hInst, pageCtrlID, Addr PagesCtrlProc
	Mov Rdx, count
	Lea Rcx, PagePanelPropertys.hPages
	Mov [Rcx + Rdx * 8], Rax
	Mov hwnd, Rax
	ECInvoke ShowWindow, hwnd, SW_HIDE
	Inc pageCtrlID
	Inc count

	;创建按钮条
		Mov countBtn, 0
		Mov ctrlID, CTRL_ITEM_ID_BASE
	createConti:
		Mov R9, iWidth
		Sub R9, 8
		Mov R8, countBtn
		Shl R8, 5
		Mov Rax, countBtn
		Shl Rax, 2
		Add Rax, 4
		Add R8, Rax
		ECInvoke CreateContiguousCmdCtrl, hwnd, 4, R8, R9, 34, _hInst, hFont, ctrlID
		Inc countBtn
		Inc ctrlID
		Cmp countBtn, MAX_CMD_ITEM
		Jnz createConti
	;创建按钮end


	Mov Rax, pageCount
	Cmp count, Rax
	Jnz createPage

	ECInvoke ShowPage, 0
	Mov Rax, hwndMainPage
	Ret
CreatePagePanel EndP


CreateUpgradeWindow Proc parentHwnd:QWord, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, ctrlID:QWord, hFont:QWord
	Local hwndMainPage:HWND
	Local aTop:QWord
	Local pVer:QWord
	Local pInfo:QWord

	Mov parentHwnd, Rcx
	Mov xpos, Rdx
	Mov ypos, R8
	Mov iWidth, R9



	Lea Rdx, UpgradeFrameProc
	Lea R8, UPGRADE_FRAME
	ECInvoke RegisterCtrlClass, _hInst, Rdx, R8

	ECInvoke CreateWindowEx, WS_EX_CONTROLPARENT, Addr UPGRADE_FRAME, 0, (WS_CHILD OR WS_VISIBLE), xpos, ypos, iWidth, iHeight, parentHwnd, ctrlID, _hInst, 0
	Mov hwndMainPage, Rax

	Mov aTop, 4
	ECInvoke CreateIconButton, hwndMainPage, 10, 4, 21, 15, CTRL_UPGRADE_CHKB_WAIT_EXIT, _hInst, hFont, ID_ICON_BACK_ARROR, BUTTON_HILIGHT_COLOR, BUTTON_NORMAL_COLOR, BUTTON_CLICK_COLOR


	Add aTop, 18
	ECInvoke NewStr, 0, 200
	Mov pInfo, Rax
	ECInvoke GetVersionString
	Mov pVer, Rax
	ECInvoke FormatStr, pInfo, Addr LABEL_INFO, pVer, 0, 0, 0, 0
	ECInvoke CreateLabel, hwndMainPage, pInfo, 30, aTop, 280, 300, 0, _hInst, hFont, SS_CENTER
	ECInvoke DelStr, pInfo
	ECInvoke DelStr, pVer

	Add aTop, 72
	ECInvoke CreateHLink, hwndMainPage, Addr LABEL_BILIBILI_PAGE, 112, aTop, 82 + 40, 16, 0, _hInst, 0, Addr G_BILIBILI_PAGE

	Add aTop, 18
	ECInvoke CreateHLink, hwndMainPage, Addr LABEL_YOUTUBE_PAGE, 112, aTop, 82 + 40, 16, 0, _hInst, 0, Addr G_YOUTUBE_PAGE

	Add aTop, 18
	ECInvoke CreateHLink, hwndMainPage, Addr LABEL_HOMEPAGE, 112, aTop, 82 + 40, 16, 0, _hInst, 0, Addr G_HOME_PAGE

	Add aTop, 62
	ECInvoke CreateHLink, hwndMainPage, Addr LABEL_UPGRADE, 112, aTop, 82 + 40, 16, CTRL_UPGRADE_GOTO_WEBSIT, _hInst, 0, Addr G_HOME_PAGE
	ECInvoke ShowWindow, Rax, SW_HIDE


	Mov Rax, hwndMainPage
	Ret
CreateUpgradeWindow EndP

ShowUpgradeHLink Proc pNewVer:QWord, bShow:QWord
	Local hlink:HWND
	Local pTitle:QWord
	Mov pNewVer, Rcx
	Mov bShow, Rdx

	ECInvoke GetDlgItem, G_HWND_UPGRADE_WINDOW, CTRL_UPGRADE_GOTO_WEBSIT
	Mov hlink, Rax

	Cmp bShow, TRUE
	Jne hide
	ECInvoke ShowWindow, hlink, SW_SHOW
	Jmp exit
hide:
	ECInvoke ShowWindow, hlink, SW_HIDE
exit:
	ECInvoke NewStr, 0, 100
	Mov pTitle, Rax
	ECInvoke FormatStr, pTitle, Addr LABEL_UPGRADE, pNewVer, 0, 0, 0, 0
	ECInvoke SetHLinkText, hlink, pTitle
	ECInvoke DelStr, pTitle
	Ret
ShowUpgradeHLink EndP


CreateConfigWindow Proc parentHwnd:QWord, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, ctrlID:QWord, hFont:QWord
	Local hwndMainPage:HWND
	Local aTop:QWord
	Mov parentHwnd, Rcx
	Mov xpos, Rdx
	Mov ypos, R8
	Mov iWidth, R9



	Lea Rdx, ConfigFrameProc
	Lea R8, CCONFIG_FRAME
	ECInvoke RegisterCtrlClass, _hInst, Rdx, R8

	ECInvoke CreateWindowEx, WS_EX_CONTROLPARENT, Addr CCONFIG_FRAME, 0, (WS_CHILD OR WS_VISIBLE), xpos, ypos, iWidth, iHeight, parentHwnd, ctrlID, _hInst, 0
	Mov hwndMainPage, Rax



	ECInvoke CreateIconButton, hwndMainPage, 10, 4, 21, 15, CTRL_CONFIG_BTN_EXIT_SETTING, _hInst, hFont, ID_ICON_BACK_ARROR, BUTTON_HILIGHT_COLOR, BUTTON_NORMAL_COLOR, BUTTON_CLICK_COLOR
	Mov aTop, 22
	ECInvoke CreateGroupBox, hwndMainPage, CTXT("执行方式"), 10 + 46, aTop, 240, 54, 0, _hInst, hFont
	Add aTop, 20
;	ECInvoke CreateCheckBox, hwndMainPage, CTXT("等待退出"), 10 + 46, 2 + 20, 66, 22, CTRL_CFG_CHKB_WAIT_EXIT, _hInst, hFont
	ECInvoke CreateCheckBox, hwndMainPage, CTXT("管理员运行"), 10 + 55, aTop, 80, 22, CTRL_CFG_CHKB_RUN_ADMIN, _hInst, hFont, FALSE
	ECInvoke CreateCheckBox, hwndMainPage, CTXT("选择执行"), 10 + 55 + 80 + 2, aTop, 66, 22, CTRL_CFG_CHKB_RUN_MANUAL, _hInst, hFont, TRUE

	Add aTop, 44
	ECInvoke CreateGroupBox, hwndMainPage, CTXT("内置命令"), 10 + 46, aTop, 240, 54, 0, _hInst, hFont
	Add aTop, 20
	ECInvoke CreateCheckBox, hwndMainPage, CTXT("关机"), 10 + 55, aTop, 60, 22, CTRL_CFG_CHKB_SHUTDOWN, _hInst, hFont, FALSE
	ECInvoke CreateCheckBox, hwndMainPage, CTXT("重启"), 10 + 55 + 60 + 2, aTop, 60, 22, CTRL_CFG_CHKB_RESTART, _hInst, hFont, FALSE

	Add aTop, 40
	ECInvoke CreateLabelEdit, hwndMainPage, CTXT("参数:"), 0, 10, aTop, 47, 280, 22, CTRL_CFG_EDIT_ARGS, _hInst, hFont
	Add aTop, 24
	ECInvoke CreateLabelEdit, hwndMainPage, CTXT("命令行:"), 0, 10, aTop, 47, 240, 22, CTRL_CFG_EDIT_CMDLINE, _hInst, hFont

	Add aTop, 2
	ECInvoke CreateIconButton, hwndMainPage, 298, aTop, 20, 20, CTRL_CONFIG_BTN_GUN_SIGHT, _hInst, hFont, ID_ICON_GUN_SIGHT, BUTTON_HILIGHT_COLOR, BUTTON_NORMAL_COLOR, BUTTON_CLICK_COLOR
	;ECInvoke CreateButton, hwndMainPage, CTXT("O"), 297, aTop, 22, 22, 0, _hInst, hFont
	ECInvoke CreateIconButton, hwndMainPage, 298 + 22, aTop, 20, 20, CTRL_CONFIG_BTN_OPENFILE, _hInst, hFont, ID_ICON_IMPORT, BUTTON_HILIGHT_COLOR, BUTTON_NORMAL_COLOR, BUTTON_CLICK_COLOR
	;ECInvoke CreateButton, hwndMainPage, CTXT("..."), 296 + 22, aTop, 22, 22, CTRL_CONFIG_BTN_OPENFILE, _hInst, hFont

;	Add aTop, 34

	Mov Rax, hwndMainPage
	Ret
CreateConfigWindow EndP


AddPageChild Proc pageHwnd:QWord, childHwnd:QWord, pageIndex:QWord
	Mov pageHwnd, Rcx
	Mov childHwnd, Rdx
	Mov pageIndex, R8
	ECInvoke SetParent, childHwnd, pageHwnd
	Ret
AddPageChild EndP


CreatePanel Proc parentHwnd:QWord, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, ctrlID:QWord, wndProc:QWord
	Local wc:WNDCLASSEX
	Local hwnd:QWord
	Mov parentHwnd, Rcx
	Mov xpos, Rdx
	Mov ypos, R8
	Mov iWidth, R9

	Mov Rdx, wndProc
	Lea R8, CPANEL_CTRL
	ECInvoke RegisterCtrlClass, _hInst, Rdx, R8


	ECInvoke CreateWindowEx, 0, Addr CPANEL_CTRL, 0, (WS_CHILD OR WS_VISIBLE), xpos, ypos, iWidth, iHeight, parentHwnd, ctrlID, _hInst, 0
	Mov hwnd, Rax
	ECInvoke SetWindowLongPtr, Rax, GWL_WNDPROC, wndProc
;	ECInvoke ShowWindow, Rax, SW_SHOW
;	ECInvoke UpdateWindow, hwnd
	Mov Rax, hwnd
	Ret
CreatePanel EndP

CreateContiguousCmdCtrl Proc parentHwnd:QWord, xpos:QWord, ypos:QWord, iWidth:QWord, iHeight:QWord, _hInst:QWord, hfont:QWord, ctrlID:QWord
	Local hwnd:QWord
	;Local hStatic:QWord
	Local itemHwnd:QWord
	Local oldWndproc:QWord
	Local wc:WNDCLASSEX
	Local cnt:QWord
	Local itemWide:QWord
	Local itemGap:QWord
	Local xOffset:QWord
	Mov parentHwnd, Rcx
	Mov xpos, Rdx
	Mov ypos, R8
	Mov iWidth, R9


	ECInvoke CreatePanel, parentHwnd, xpos, ypos, iWidth, iHeight, _hInst, ctrlID, Addr ContiguousCmdCtrlProc
	Mov hwnd, Rax
	Mov Rax, iHeight
	Sub Rax, 12
	Mov Rcx, iWidth
	Shr Rcx, 2
	Push Rcx
	Shr Rcx, 3
	Pop R8
	Lea R8, [R8 + Rcx * 4]
	ECInvoke CreateLabel, hwnd, Addr UnsetHotKey, 8, 10, R8, Rax, CMD_CTRL_LABEL, _hInst, hfont, 0
;	Mov hStatic, Rax

	ECInvoke SetWindowLongPtr, hwnd, GWL_EXSTYLE, NULL
	;ECInvoke DragAcceptFiles, hwnd, TRUE
	Mov itemGap, 2;左右留4像素
	Mov cnt, 0
	Mov Rax, iHeight
	Sub Rax, 4;上下留2 像素
	Dec Eax
	Mov itemWide, Rax
	Mov xOffset, 129
lc:
	Mov Rax, itemWide
	Mov Rcx, xOffset
	Mov R8, itemGap
	Lea Rax, [Rax + Rcx]
	Add Rax, R8
	Mov xOffset, Rax
	;Add xOffset, itemWide
	;Mov Rax, itemGap
	;Add xOffset, Rax
	Mov Rax, cnt
	Add Rax, CMD_BTN_ID_BASE

	ECInvoke CreateImgButton, hwnd, 0, xOffset, 2, itemWide, itemWide, Rax, _hInst, 0

	Mov itemHwnd, Rax
	;ECInvoke VirtualAlloc, 0, MAX_PATH, MEM_COMMIT, PAGE_EXECUTE_READWRITE


	Inc cnt
	Cmp cnt, MAX_CMD_ITEM_BTN
	Jl lc
	ECInvoke ShowWindow, hwnd, SW_SHOWNORMAL


;	ECInvoke DragAcceptFiles, hwnd, TRUE
	;注册子类化过程
   ; ECInvoke SetWindowSubclass, hwnd, Offset ContiguousCmdCtrlProc, 0, 0
	;ECInvoke SetWindowLong, hwnd, SWL_WNDPROC, ContiguousCmdCtrlProc
	Mov Rax, hwnd
	Ret
CreateContiguousCmdCtrl EndP

DestoryContiguousCmdCtrl Proc hwnd:QWord
	Local dCount:QWord
	Local pBtnCmdInfo:QWord
	Test Ecx, Ecx
	Jz exit
	Mov hwnd, Rcx
	Mov dCount, 0

loopDestory:
	Mov Rax, dCount
	Add Rax, CMD_BTN_ID_BASE

	ECInvoke GetDlgItem, hwnd, Rax
	ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA

	Mov pBtnCmdInfo, Rax
	;ECInvoke VirtualFree, pBtnCmdInfo, MAX_PATH, MEM_RELEASE
	ECInvoke GlobalFree, pBtnCmdInfo
	Inc dCount
	Cmp dCount, MAX_CMD_ITEM_BTN
	Jnz loopDestory
exit:
	Ret
DestoryContiguousCmdCtrl EndP

ContiguousCmdCtrlProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
	Local hParent:QWord
    Local rcClient:RECT
    Local ps:PAINTSTRUCT
	Local hRgn:HRGN
	Local pBtnCmdInfo:QWord
	Local hBrush:HBRUSH
	Local hItem:HWND
	Local hPage:HWND
	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F

        ECInvoke BeginPaint, hWnd, Addr ps
		ECInvoke GetClientRect, hWnd, Addr rcClient
        ; 创建具有圆角的区域
        ECInvoke CreateRoundRectRgn, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, 3, 3
        Mov hRgn, Rax

        ; 将绘图设备（DC）裁剪为具有圆角的区域
        ECInvoke SelectClipRgn, ps.hdc, hRgn
		ECInvoke CreateSolidBrush, BORDER_COLOR
		Mov hBrush, Rax
		;ECInvoke SelectObject, ps.hdc, hBrush
        ; 绘制矩形
        ;ECInvoke FillRect, ps.hdc, Addr ps.rcPaint, Rax
		ECInvoke FrameRgn, ps.hdc, hRgn, hBrush, 1, 1
        ; 清理资源
        ECInvoke DeleteObject, hRgn
		ECInvoke DeleteObject, hBrush
        ECInvoke EndPaint, hWnd, Addr ps
        ;ECInvoke ReleaseDC, ps.hdc
        ;ECInvoke DeleteDC, hWnd, ps.hdc

@@:Cmp uMsg, WM_LBUTTONDBLCLK
	Jnz @F
	;ECInvoke MessageBox, 0, 0, 0, 0
	;ECInvoke GetParent, hWnd
	ECInvoke GetRootWindow, hWnd
	Mov hParent, Rax
	ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
	ECInvoke GetParent, Rax
	Mov hItem, Rax
	;获得所在页句柄
	;ECInvoke GetParent, Rax
	ECInvoke GetParent, Rax
	Mov hPage, Rax
;	ECInvoke GetDlgCtrlID, hPage

	ECInvoke SendMessage, hParent, WM_CONTIGUOUS_LBDBCLCK, hPage, hItem
		;ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
		;ECInvoke SetWindowText, Rax, Addr CSTATIC
@@:Cmp uMsg, WM_COMMAND
	Jnz @F

Comment #
		ECInvoke GetDlgItem, hWnd, wParam
		ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA
		Mov pBtnCmdInfo, Rax
		;Cmp pBtnCmdInfo, 0
		;Jz notdrop
		Lea Rax, pBtnCmdInfo
		Lea Rax, [Rax + BTN_CMD_INFO.cmdLine]

		;ECInvoke MessageBox, 0, Rax, Rax, 0
;notdrop:
#
	Cmp wParam, CMD_BTN_ID_BASE
	Jb @F
	Cmp wParam, CMD_BTN_ID_BASE + 8
	Jg @F

		ECInvoke GetDlgItem, hWnd, wParam
		ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA
		Mov pBtnCmdInfo, Rax
	;	ECInvoke GetRootWindow, hWnd
		ECInvoke GetParent, hWnd
	;	ECInvoke GetParent, Rax
		ECInvoke GetParent, Rax
		ECInvoke SendMessage, Rax, WM_ITEM_BTN_CLCK, pBtnCmdInfo, 0
	;	ECInvoke SendDlgItemMessage, hWnd, wParam, WM_KILLFOCUS, 0, 0
		
	Xor Eax, Eax
	Ret
@@:Cmp uMsg, WM_IMAGE_CHANGE
	Jnz @F
		ECInvoke GetParent, hWnd
		;ECInvoke GetParent, Rax
		ECInvoke GetParent, Rax
		ECInvoke SendMessage, Rax, WM_IMAGE_CHANGE, 0, 0
@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
ContiguousCmdCtrlProc EndP

CmdInfoMatchConfigFrame Proc pBtnCmdInfo:QWord
	Local bWait:QWord
	Local bAdmin:QWord
	Local bManual:QWord
	Local bShutdown:QWord
	Local bRestart:QWord
	Local pCmdLine:QWord
	Mov pBtnCmdInfo, Rcx
	Cmp G_HWND_CONFIG_WINDOW, 0
	Je _exit

	ECInvoke IsBadReadPtr, pBtnCmdInfo, SizeOf BTN_CMD_INFO
	Test Al, Al
	Jnz _exit

	Mov Rcx, pBtnCmdInfo
	Lea Rax, [Rcx + BTN_CMD_INFO.cmdbWait]
	Mov Rax, [Rax]
	Mov bWait, Rax

	Lea Rax, [Rcx + BTN_CMD_INFO.cmdbAdmin]
	Mov Rax, [Rax]
	Mov bAdmin, Rax

	Lea Rax, [Rcx + BTN_CMD_INFO.cmdbManual]
	Mov Rax, [Rax]
	Mov bManual, Rax

	Lea Rax, [Rcx + BTN_CMD_INFO.cmdbShutdown]
	Mov Rax, [Rax]
	Mov bShutdown, Rax

	Lea Rax, [Rcx + BTN_CMD_INFO.cmdbRestart]
	Mov Rax, [Rax]
	Mov bRestart, Rax


	Lea R8, [Rcx + BTN_CMD_INFO.cmdLine]
	Mov pCmdLine, R8
	Push Rcx
	ECInvoke SetDlgItemText, G_HWND_CONFIG_WINDOW, CTRL_CFG_EDIT_CMDLINE, R8
	Pop Rcx
	Lea R8, [Rcx + BTN_CMD_INFO.cmdArg]
	ECInvoke SetDlgItemText, G_HWND_CONFIG_WINDOW, CTRL_CFG_EDIT_ARGS, R8

	ECInvoke CheckDlgButton, G_HWND_CONFIG_WINDOW, CTRL_CFG_CHKB_WAIT_EXIT, bWait
	ECInvoke CheckDlgButton, G_HWND_CONFIG_WINDOW, CTRL_CFG_CHKB_RUN_ADMIN, bAdmin
	ECInvoke CheckDlgButton, G_HWND_CONFIG_WINDOW, CTRL_CFG_CHKB_RUN_MANUAL, TRUE
	Mov Rax, pCmdLine
	Mov Rax, Rax
	Cmp QWord Ptr [Rax], 0
	Je @F
	ECInvoke CheckDlgButton, G_HWND_CONFIG_WINDOW, CTRL_CFG_CHKB_RUN_MANUAL, bManual
@@:
	ECInvoke CheckDlgButton, G_HWND_CONFIG_WINDOW, CTRL_CFG_CHKB_SHUTDOWN, bShutdown
	ECInvoke CheckDlgButton, G_HWND_CONFIG_WINDOW, CTRL_CFG_CHKB_RESTART, bRestart
_exit:
	Ret
CmdInfoMatchConfigFrame EndP
InserCmdInfoToCmdItem Proc hRoot:QWord
	Local hPage:HWND
	Local hItem:HWND
	Local hBtn:HWND
	Local pBtncmdInfo:QWord
	Local strKey[100]:Byte
	Local readVal[MAX_CMD_ITEM_BTN + 1]:BTN_CMD_INFO
	Local onValue:QWord
	Local pTmpStr[MAX_PATH]:Word
	Local loopPage:QWord
	Local loopItem:QWord
	Local loopBtn:QWord
	Mov hRoot, Rcx

	ECInvoke NewStr, 0, SizeOf BTN_CMD_INFO
	Mov onValue, Rax
	;搜索cmd item 是否存在
	;不存在创建一个item
	;如果存在保存item
	Mov loopPage, 0
_loop_page:
	Mov Rdx, CTRL_PAGE_ID_BASE
	Add Rdx, loopPage
	ECInvoke GetDlgItem, hRoot, Rdx
	Mov hPage, Rax

	Mov loopItem, 0
	_loop_item:
	
		Mov Rdx, loopItem
		Add Rdx, CTRL_ITEM_ID_BASE
		ECInvoke GetDlgItem, hPage, Rdx
		Mov hItem, Rax
	
			;Mov loopBtn, 0
			;Lea Rax, readVal
		;	Mov QWord Ptr [Rax], 0


			ECInvoke ZeroMemory, Addr readVal, SizeOf readVal
			ECInvoke FormatStr, Addr strKey, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0
			ECInvoke ReadCfgString, Addr CFG_BTN_ITEM_CMD_SECTION, Addr strKey, Addr readVal, SizeOf readVal

			;解析参数

			Mov loopBtn, 0
		_loop_btn:
			Mov Rdx, loopBtn
			Add Rdx, CMD_BTN_ID_BASE
			ECInvoke GetDlgItem, hItem, Rdx
			Mov hBtn, Rax

			ECInvoke GetWindowLongPtr, hBtn, GWL_USERDATA
			Mov pBtncmdInfo, Rax

			;格式化按钮命令
			;清空字符串

			;格式化参数
			;cmdArg
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_ARGS_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			Mov Rax, pBtncmdInfo
			Lea Rcx, [Rax + BTN_CMD_INFO.cmdArg]
			ECInvoke lstrcpy, Rcx, onValue

			;bWait
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BWAIT_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			ECInvoke StrToInt, onValue
			Mov Rcx, pBtncmdInfo
			Lea Rcx, [Rcx + BTN_CMD_INFO.cmdbWait]
			Mov QWord Ptr [Rcx], Rax

			;bAdmin
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BADMIN_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			ECInvoke StrToInt, onValue
			Mov Rcx, pBtncmdInfo
			Lea Rcx, [Rcx + BTN_CMD_INFO.cmdbAdmin]
			Mov QWord Ptr [Rcx], Rax

			;bManual
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BMANUAL_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			ECInvoke StrToInt, onValue
			Mov Rcx, pBtncmdInfo
			Lea Rcx, [Rcx + BTN_CMD_INFO.cmdbManual]
			Mov QWord Ptr [Rcx], Rax

			;bShutdown
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_SHUTDOWN_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			ECInvoke StrToInt, onValue
			Mov Rcx, pBtncmdInfo
			Lea Rcx, [Rcx + BTN_CMD_INFO.cmdbShutdown]
			Mov QWord Ptr [Rcx], Rax

			;bRestart
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_RESTART_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			ECInvoke StrToInt, onValue
			Mov Rcx, pBtncmdInfo
			Lea Rcx, [Rcx + BTN_CMD_INFO.cmdbRestart]
			Mov QWord Ptr [Rcx], Rax

			;格式化路径/命令
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			Mov Rax, pBtncmdInfo
			Lea Rcx, [Rax + BTN_CMD_INFO.cmdLine]
			ECInvoke lstrcpy, Rcx, onValue

			;读取命令类型
			ECInvoke ZeroMemory, onValue, SizeOf onValue
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_TYPE_READ_KEY, loopBtn, 0, 0, 0, 0
			ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
			ECInvoke StrToInt, onValue

			Mov R8, pBtncmdInfo
			Lea R8, [R8 + BTN_CMD_INFO.cmdType]
			Mov QWord Ptr [R8], Rax



			;ECInvoke FormatStr, Addr onValue, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0
			;合并到一条写入缓冲
			;ECInvoke lstrcat, Addr readVal, Addr onValue
			Inc loopBtn
			Mov Rax, loopBtn
			Cmp Rax, MAX_CMD_ITEM_BTN
			Jb _loop_btn

		;格式化热键命令名
		ECInvoke ZeroMemory, onValue, SizeOf onValue
		ECInvoke FormatStr, Addr pTmpStr, Addr ITEM_CMDNAME_READ_KEY, 0, 0, 0, 0, 0
		ECInvoke GetKeyValue, Addr readVal, Addr pTmpStr, onValue
		ECInvoke SetDlgItemText, hItem, CMD_CTRL_LABEL, onValue

		;保存到配置

	;	ECInvoke FormatStr, Addr strKey, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0

	;	ECInvoke WriteCfgValue, Addr CFG_BTN_ITEM_CMD_SECTION, Addr strKey, Addr readVal

		Inc loopItem
		Mov Rax, loopItem
		Cmp Rax, MAX_CMD_ITEM
		Jb _loop_item

	

	Inc loopPage
	Mov Rax, loopPage
	Cmp Rax, MAX_CMD_PAGE
	Jb _loop_page

	ECInvoke DelStr, onValue
	Ret

InserCmdInfoToCmdItem EndP
RunModeWndProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
    Local rrcClient:RECT
    Local ps:PAINTSTRUCT
	Local hRgn:HRGN
	Local pBtnCmdInfos:QWord
	Local hBrush:HBRUSH
	Local pManualInfo:QWord
	Local pIconRoundrect:QWord
	Local iW:DWord
	Local iH:DWord
	Local hDc:HDC
	Local hIcon:HICON
	Local loopIcon:DWord
	Local loopBkg:DWord
	Local iconX:DWord
	Local MAX_BTN:DWord

	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9



	Cmp uMsg, WM_PAINT
	Jnz @F


        ECInvoke BeginPaint, hWnd, Addr ps
        ECInvoke GetClientRect, hWnd, Addr rrcClient
		ECInvoke DrawWindowRoundBorder, ps.hdc, Addr rrcClient, MANUAL_BORDER_COLOR, 1

		ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
		Mov pManualInfo, Rax

		Mov Rcx, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos
		Mov pBtnCmdInfos, Rcx

		Mov Rcx, [Rax].CMDBAR_WINDOW_INFO.iBtnCount
		Mov MAX_BTN, Ecx

		Mov Rax, [Rax].CMDBAR_WINDOW_INFO.pIconRoundrect
		Mov pIconRoundrect, Rax


		Mov Rcx, [Rax].ICON_OBJECT.ICON_DC
		Mov hDc, Rcx

		Lea Rdx, [Rax].ICON_OBJECT.ICON_RECT
		ECInvoke memcpy, Addr rrcClient, Rdx, SizeOf (RECT)



		Mov loopBkg, 0

_loop_bkg:

		IMul Edx, loopBkg, RUNMODE_ICON_SIZE
		Mov Eax, loopBkg
		Inc Eax
		IMul R8d, Eax, 4
		Add Edx, R8d
		ECInvoke TransparentBlt, ps.hdc, Rdx, 4, rrcClient.right, rrcClient.bottom, hDc, 0, 0, rrcClient.right, rrcClient.bottom, TRANS_COLOR

		;绘制图标
		Mov Rax, pBtnCmdInfos
		Add pBtnCmdInfos, 8

		Mov Rcx, [Rax]
		Test Ecx, Ecx
		Jz noIcon

		Lea Rcx, [Rcx].BTN_CMD_INFO.cmdLine

        ECInvoke GetFileDefaultIcon, Rcx
		Mov hIcon, Rax
		Test Eax, Eax
		Jz noIcon

		Mov Eax, loopBkg
		IMul Eax, RUNMODE_ICON_SIZE
		Mov iconX, Eax
		Mov Eax, loopBkg
		IMul Eax, 4
		Add iconX, Eax
		Mov Edx, iconX
		Add Rdx, 6
		ECInvoke DrawIconEx, ps.hdc, Rdx, 6, hIcon, RUNMODE_ICON_SIZE - 4, RUNMODE_ICON_SIZE - 4, 0, 0, DI_NORMAL
		ECInvoke DestroyIcon, hIcon
noIcon:

		Inc loopBkg
		Mov Eax, loopBkg
		Cmp Eax, MAX_BTN
		Jb _loop_bkg
        ECInvoke EndPaint, hWnd, Addr ps



@@:Cmp uMsg, WM_LBUTTONDBLCLK
	Jnz @F
;	ECInvoke GetParent, hWnd
;;	Mov hParent, Rax
;	ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
;	ECInvoke SendMessage, hParent, WM_CONTIGUOUS_LBDBCLCK, hWnd, Rax
		;ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
		;ECInvoke SetWindowText, Rax, Addr CSTATIC
@@:Cmp uMsg, WM_COMMAND
	Jnz @F

;		ECInvoke GetDlgItem, hWnd, wParam
;		ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA
;		Mov pBtnCmdInfo, Rax
;		;Cmp pBtnCmdInfo, 0
		;Jz notdrop

;		ECInvoke MessageBox, 0, pBtnCmdInfo, pBtnCmdInfo, 0
;notdrop:
;	Xor Eax, Eax
;	Ret

@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
RunModeWndProc EndP

ManualRunWndProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
    Local rrcClient:RECT
    Local ps:PAINTSTRUCT
	Local hRgn:HRGN
	Local pBtnCmdInfos:QWord
	Local hBrush:HBRUSH
	Local pManualInfo:QWord
	Local pIconRoundrect:QWord
	Local iW:DWord
	Local iH:DWord
	Local hDc:HDC
	Local hIcon:HICON
	Local loopIcon:DWord
	Local loopBkg:DWord
	Local iconX:DWord
	Local currentPage:QWord
	Local pFlashItem:QWord
	Local flashIndex:DWord
	Local flashCount:DWord
	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9



	Cmp uMsg, WM_PAINT
	Jnz @F


        ECInvoke BeginPaint, hWnd, Addr ps
        ECInvoke GetClientRect, hWnd, Addr rrcClient
		ECInvoke DrawWindowRoundBorder, ps.hdc, Addr rrcClient, MANUAL_BORDER_COLOR, 1

		ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
		Mov pManualInfo, Rax

		Mov Rcx, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos
		Mov pBtnCmdInfos, Rcx

		Mov Rcx, [Rax].CMDBAR_WINDOW_INFO.iCurrentPage
		Mov currentPage, Rcx

		Mov Rax, [Rax].CMDBAR_WINDOW_INFO.pIconRoundrect
		Mov pIconRoundrect, Rax


		Mov Rcx, [Rax].ICON_OBJECT.ICON_DC
		Mov hDc, Rcx

		Lea Rdx, [Rax].ICON_OBJECT.ICON_RECT
		ECInvoke memcpy, Addr rrcClient, Rdx, SizeOf (RECT)
Comment #
		;get flash item
		Mov Rax, G_ITEM_CURRENT_FLASH_NODE
		Test Rax, Rax
		Jnz goFlash
		ECInvoke GetQueue, G_ITEM_FLASH_QUEUE
		Mov G_ITEM_CURRENT_FLASH_NODE, Rax
goFlash:
#
		Mov loopBkg, 0

_loop_bkg:
Comment #
		;check flash count
		Mov Rcx, G_ITEM_CURRENT_FLASH_NODE
		Test Rcx, Rcx
		Jz goflashNode
			Mov Rcx, [Rcx].NODE.Value
			Mov pFlashItem, Rcx
			Mov Eax, [Rcx].FLASH_ITEM_NODE.index
			Int 3
			Mov flashIndex, Eax
			Mov Eax, [Rcx].FLASH_ITEM_NODE.fCount
			Mov flashCount, Eax
			Cmp Eax, 0
			Jg goflashNode
				ECInvoke DestoryQueue, G_ITEM_CURRENT_FLASH_NODE
				Mov G_ITEM_CURRENT_FLASH_NODE, 0
goflashNode:
#
		IMul Edx, loopBkg, MANUAL_ICON_SIZE
		Mov Eax, loopBkg
		Inc Eax
		IMul R8d, Eax, 4
		Add Edx, R8d
		;Push Rdx
		ECInvoke TransparentBlt, ps.hdc, Rdx, 4, rrcClient.right, rrcClient.bottom, hDc, 0, 0, rrcClient.right, rrcClient.bottom, TRANS_COLOR
	;	Pop Rdx
Comment #
		Mov Eax, flashIndex

		Cmp loopBkg, Eax
		Jne _drico

			ECInvoke PatBlt, ps.hdc, Rdx, 4, rrcClient.right, rrcClient.bottom, DSTINVERT
			Mov Rcx, pFlashItem
			Mov Eax, flashCount
			Dec Eax
			Mov [Rcx].FLASH_ITEM_NODE.fCount, Eax
_drico:
#
		;绘制图标
		Mov Rax, pBtnCmdInfos
		Add pBtnCmdInfos, 8
		Mov R8, currentPage

		;增加页
		IMul R8, 6 * 8
		Add Rax, R8


		Mov Rcx, [Rax]
		Test Ecx, Ecx
		Jz noIcon

		Lea Rcx, [Rcx].BTN_CMD_INFO.cmdLine

        ECInvoke GetFileDefaultIcon, Rcx
		Mov hIcon, Rax
		Test Eax, Eax
		Jz noIcon

		Mov Eax, loopBkg
		IMul Eax, MANUAL_ICON_SIZE
		Mov iconX, Eax
		Mov Eax, loopBkg
		IMul Eax, 4
		Add iconX, Eax
		Mov Edx, iconX
		Add Rdx, 6
		ECInvoke DrawIconEx, ps.hdc, Rdx, 6, hIcon, MANUAL_ICON_SIZE - 4, MANUAL_ICON_SIZE - 4, 0, 0, DI_NORMAL
		ECInvoke DestroyIcon, hIcon
noIcon:

		Inc loopBkg
		Mov Eax, loopBkg
		Cmp Eax, MAX_CMD_ITEM_BTN
		Jb _loop_bkg
        ECInvoke EndPaint, hWnd, Addr ps



@@:Cmp uMsg, WM_LBUTTONDBLCLK
	Jnz @F
;	ECInvoke GetParent, hWnd
;;	Mov hParent, Rax
;	ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
;	ECInvoke SendMessage, hParent, WM_CONTIGUOUS_LBDBCLCK, hWnd, Rax
		;ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
		;ECInvoke SetWindowText, Rax, Addr CSTATIC
@@:Cmp uMsg, WM_COMMAND
	Jnz @F

;		ECInvoke GetDlgItem, hWnd, wParam
;		ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA
;		Mov pBtnCmdInfo, Rax
;		;Cmp pBtnCmdInfo, 0
		;Jz notdrop

;		ECInvoke MessageBox, 0, pBtnCmdInfo, pBtnCmdInfo, 0
;notdrop:
;	Xor Eax, Eax
;	Ret

@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
ManualRunWndProc EndP

ManualGetCurrentPage Proc hWnd:QWord
	Local pManualWindowInfo:QWord
	Mov hWnd, Rcx
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pManualWindowInfo, Rax
	Mov Rax, [Rax].CMDBAR_WINDOW_INFO.iCurrentPage

	Ret
ManualGetCurrentPage EndP



ManualGetCmdinfoCount Proc hWnd:QWord
	Local pManualWindowInfo:QWord
	Local count:QWord
	Local pItem:QWord

	Mov hWnd, Rcx
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pManualWindowInfo, Rax
	Mov Rax, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos
	Mov pItem, Rax

	Mov count, -1

_ccount:
	Inc count
	Mov Rax, pItem
	Add pItem, 8
	Mov Rax, [Rax]
	Cmp Rax, 0
	Jnz _ccount
	Mov Rax, count
	Ret
ManualGetCmdinfoCount EndP

ManualGetMaxPage Proc hWnd:QWord
	Local count:QWord
	Mov hWnd, Rcx
	ECInvoke ManualGetCmdinfoCount, hWnd
	Mov count, Rax
	Xor Edx, Edx
	Mov Ecx, MAX_CMD_ITEM_BTN
	Div Ecx
	Test Edx, Edx
	Jz @F
	Inc Eax
@@:
	Ret
ManualGetMaxPage EndP

ManualNextPage Proc hWnd:QWord
	Local count:QWord
	Local maxPage:QWord
	Mov hWnd, Rcx
Comment #
	ECInvoke ManualGetCmdinfoCount, hWnd
	Mov count, Rax
	Xor Edx, Edx
	Mov Ecx, MAX_CMD_ITEM_BTN
	Div Ecx
#
	ECInvoke ManualGetMaxPage, hWnd

	Dec Rax
	Mov maxPage, Rax

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov Rcx, Rax
	;Mov pManualWindowInfo, Rax
	Mov Rax, [Rcx].CMDBAR_WINDOW_INFO.iCurrentPage
	Cmp Rax, maxPage
	Jge @F
	Inc Rax
	Mov [Rcx].CMDBAR_WINDOW_INFO.iCurrentPage, Rax
@@:
	ECInvoke UpdateInWindow, hWnd
	Ret
ManualNextPage EndP

ManualPreviousPage Proc hWnd:QWord
	Local count:QWord
	Local maxPage:QWord
	Mov hWnd, Rcx
	ECInvoke ManualGetMaxPage, hWnd
	;Mov maxPage, Rax
	comment #
	ECInvoke ManualGetCmdinfoCount, hWnd
	Mov count, Rax
	Xor Edx, Edx
	Mov Ecx, MAX_CMD_ITEM_BTN
	Div Ecx
	Add Eax, Edx
	#
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov Rcx, Rax
	;Mov pManualWindowInfo, Rax
	Mov Rax, [Rcx].CMDBAR_WINDOW_INFO.iCurrentPage
	Test Al, Al
	Jz @F
		Dec Rax
		Mov [Rcx].CMDBAR_WINDOW_INFO.iCurrentPage, Rax
@@:
	ECInvoke UpdateInWindow, hWnd
	Ret
ManualPreviousPage EndP

ManualResetPage Proc hWnd:QWord
	Local pBtnCmdInfos:QWord
	Mov hWnd, Rcx
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pBtnCmdInfos, Rax
	Lea Rcx, [Rax].CMDBAR_WINDOW_INFO.iCurrentPage
	Mov QWord Ptr [Rcx], 0

	Mov Rcx, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos
	Mov Rdx, [Rax].CMDBAR_WINDOW_INFO.iBtnCmdInfoSize
	ECInvoke ZeroMemory, Rcx, Rdx
	
	Ret
ManualResetPage EndP

GetManualCmd Proc hWnd:QWord, index:QWord
	Local pManualWindowInfo:QWord
	Local curPage:QWord
	Mov hWnd, Rcx
	Mov index, Rdx

	ECInvoke ManualGetCurrentPage, hWnd
	Mov curPage, Rax

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pManualWindowInfo, Rax
;	Mov Rcx, [Rax + MANUAL_WINDOW_INFO.iCurrentPage]
;	Mov curPage, Rcx
	Mov Rax, [Rax].CMDBAR_WINDOW_INFO.pBtnCmdInfos

	Mov Rdx, index
	IMul Rdx, 8
	Mov R8, curPage
	;增加页
	IMul R8, 6 * 8
	;Mov Rax, [Rax]
	Add Rax, R8
	Add Rax, Rdx
	Mov Rax, [Rax]
	;Lea Rax, [Rax + BTN_CMD_INFO.cmdLine]
	;MANUAL_WINDOW_INFO
	Ret
GetManualCmd EndP

UpdateInWindow Proc hWnd:QWord
	Local rRect:RECT
	Mov hWnd, Rcx

	ECInvoke GetClientRect, hWnd, Addr rRect
	ECInvoke InvalidateRect, hWnd, Addr rRect, FALSE

	Ret
UpdateInWindow EndP

CleanManualInfo Proc

	Ret
CleanManualInfo EndP

AddCmdInfosToManualInfo Proc
	
	Ret
AddCmdInfosToManualInfo EndP


PagesCtrlProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
	Local hParent:QWord
    Local rcClient:RECT
    Local ps:PAINTSTRUCT
	Local hRgn:HRGN
	Local pBtnCmdInfo:QWord
	Local hBrush:HBRUSH
	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F
	Comment #
        ECInvoke BeginPaint, hWnd, Addr ps

		ECInvoke GetClientRect, hWnd, Addr rcClient

        ; 创建具有圆角的区域
        ECInvoke CreateRoundRectRgn, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, 3, 3
        Mov hRgn, Rax

        ; 将绘图设备（DC）裁剪为具有圆角的区域
        ECInvoke SelectClipRgn, ps.hdc, hRgn

		ECInvoke CreateSolidBrush, BORDER_COLOR
		Mov hBrush, Rax

		;ECInvoke SelectObject, ps.hdc, hBrush
        ; 绘制矩形
        ;ECInvoke FillRect, ps.hdc, Addr ps.rcPaint, Rax
		ECInvoke FrameRgn, ps.hdc, hRgn, hBrush, 1, 1
        ; 清理资源
        

		ECInvoke DeleteObject, hBrush
	
		ECInvoke DeleteObject, hRgn
        ECInvoke EndPaint, hWnd, Addr ps
	#


@@:Cmp uMsg, WM_LBUTTONDBLCLK
	Jnz @F
;	ECInvoke GetParent, hWnd
;;	Mov hParent, Rax
;	ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
;	ECInvoke SendMessage, hParent, WM_CONTIGUOUS_LBDBCLCK, hWnd, Rax
		;ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
		;ECInvoke SetWindowText, Rax, Addr CSTATIC
@@:Cmp uMsg, WM_COMMAND
	Jnz @F

;		ECInvoke GetDlgItem, hWnd, wParam
;		ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA
;		Mov pBtnCmdInfo, Rax
;		;Cmp pBtnCmdInfo, 0
		;Jz notdrop

;		ECInvoke MessageBox, 0, pBtnCmdInfo, pBtnCmdInfo, 0
;notdrop:
;	Xor Eax, Eax
;	Ret

@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
PagesCtrlProc EndP

UpgradeFrameProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
	Local hParent:QWord
    Local rcClient:RECT
    Local ps:PAINTSTRUCT
	Local hRgn:HRGN
	Local pBtnCmdInfo:QWord
	Local hBrush:HBRUSH
	Local x, y:DWord
	Local pt:POINT
	Local pid:QWord
	Local pStr:QWord

	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F

        ECInvoke BeginPaint, hWnd, Addr ps

        ECInvoke EndPaint, hWnd, Addr ps


@@:Cmp uMsg, WM_KEYDOWN
	Jnz @F

@@:Cmp uMsg, WM_LBUTTONDBLCLK
	Jnz @F

@@:Cmp uMsg, WM_COMMAND
	Jnz @F
	;G_P_CURRENT_BTN_CMD_INFO

	ECInvoke IsDlgButtonChecked, hWnd, wParam
	Mov Rcx, G_P_CURRENT_BTN_CMD_INFO
	Cmp wParam, CTRL_UPGRADE_CHKB_WAIT_EXIT
	Jne c_n0
	ECInvoke ShowWindow, G_HWND_PAGE_ROOT, SW_SHOW
	ECInvoke ShowWindow, G_HWND_CONFIG_WINDOW, SW_HIDE
	ECInvoke ShowWindow, hWnd, SW_HIDE
c_n0:

@@:Cmp uMsg, WM_ICON_BTN_MOVE
	Jnz @F

@@:Cmp uMsg, WM_ICON_BTN_DOWN
	Jnz @F

@@:Cmp uMsg, WM_ICON_BTN_UP
	Jnz @F
	
@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
UpgradeFrameProc EndP


ConfigFrameProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
	Local hParent:QWord
    Local rcClient:RECT
    Local ps:PAINTSTRUCT
	Local hRgn:HRGN
	Local pBtnCmdInfo:QWord
	Local hBrush:HBRUSH
	Local x, y:DWord
	Local pt:POINT
	Local pid:QWord
	Local pStr:QWord
	Local pArgs:QWord

	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F

        ECInvoke BeginPaint, hWnd, Addr ps
Comment #
		Lea Rax, rcClient
		Mov DWord Ptr [Rax + RECT.top], 2
		Mov DWord Ptr [Rax + RECT.bottom], 7 * 3 + 2
		Mov DWord Ptr [Rax + RECT.left], 6
		Mov DWord Ptr [Rax + RECT.right], 6 + 30

		ECInvoke Icon_back, Addr rcClient
		Mov hRgn, Rax

		ECInvoke GetClientRect, hWnd, Addr rcClient



        ; 创建具有圆角的区域
       ; ECInvoke CreateRoundRectRgn, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, 3, 3


        ; 将绘图设备（DC）裁剪为具有圆角的区域
        ECInvoke SelectClipRgn, ps.hdc, hRgn

		ECInvoke CreateSolidBrush, BORDER_COLOR
		Mov hBrush, Rax

		;ECInvoke SelectObject, ps.hdc, hBrush
        ; 绘制矩形
        ;ECInvoke FillRect, ps.hdc, Addr ps.rcPaint, Rax
		;ECInvoke FrameRgn, ps.hdc, hRgn, hBrush, 1, 1
		ECInvoke FillRgn, ps.hdc, hRgn, hBrush
        ; 清理资源
        

		ECInvoke DeleteObject, hBrush
	
		ECInvoke DeleteObject, hRgn
		#
        ECInvoke EndPaint, hWnd, Addr ps

;WM_CFG_CHANGE
@@:Cmp uMsg, WM_KEYDOWN
	Jnz @F

@@:Cmp uMsg, WM_LBUTTONDBLCLK
	Jnz @F
;	ECInvoke GetParent, hWnd
;;	Mov hParent, Rax
;	ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
;	ECInvoke SendMessage, hParent, WM_CONTIGUOUS_LBDBCLCK, hWnd, Rax
		;ECInvoke GetDlgItem, hWnd, CMD_CTRL_LABEL
		;ECInvoke SetWindowText, Rax, Addr CSTATIC
@@:Cmp uMsg, WM_COMMAND
	Jnz @F
	;G_P_CURRENT_BTN_CMD_INFO

	ECInvoke IsDlgButtonChecked, hWnd, wParam
	Mov Rcx, G_P_CURRENT_BTN_CMD_INFO
	Cmp wParam, CTRL_CFG_CHKB_WAIT_EXIT
	Jne c_n0
		Mov [Rcx + BTN_CMD_INFO.cmdbWait], Rax
c_n0:Cmp wParam, CTRL_CFG_CHKB_RUN_ADMIN
	Jne c_n1
		Mov [Rcx + BTN_CMD_INFO.cmdbAdmin], Rax
c_n1:Cmp wParam, CTRL_CFG_CHKB_RUN_MANUAL
	Jne c_n2
		Mov [Rcx + BTN_CMD_INFO.cmdbManual], Rax
c_n2:Cmp wParam, CTRL_CONFIG_BTN_EXIT_SETTING
	Jne c_n3

	ECInvoke ShowWindow, G_HWND_PAGE_ROOT, SW_SHOW
	ECInvoke ShowWindow, G_HWND_CONFIG_WINDOW, SW_HIDE
	ECInvoke IsDlgButtonChecked, hWnd, CTRL_CFG_CHKB_RUN_MANUAL
	Mov Rcx, G_P_CURRENT_BTN_CMD_INFO
	Mov [Rcx + BTN_CMD_INFO.cmdbManual], Rax

c_n3:Cmp wParam, CTRL_CONFIG_BTN_OPENFILE
	Jne c_n4
	ECInvoke OpenFileDialog
	Mov pStr, Rax
	Test Ecx, Ecx
	Jz nosel
	ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_CMDLINE, pStr
	Mov Rcx, G_P_CURRENT_BTN_CMD_INFO
	Lea Rax, [Rcx].BTN_CMD_INFO.cmdLine
	ECInvoke lstrcpy, Rax, pStr

nosel:
	ECInvoke DelStr, pStr
Comment #
	Cmp wParam, CTRL_CONFIG_BTN_GUN_SIGHT
	Jne c_n4

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov Rax, [Rax + ICON_BTN_INFO.PICON_OBJECT]
	Mov Rcx, [Rax + ICON_OBJECT.ICON_BITMAP]


	ECInvoke SetBitmapToCursor, Rcx
	Cmp G_OLD_CURSOR, 0
	Jne ongc
	Mov G_OLD_CURSOR, Rax
	#
ongc:
c_n4:Cmp wParam, CTRL_CFG_CHKB_SHUTDOWN
	Jne c_n5
		Mov [Rcx].BTN_CMD_INFO.cmdbShutdown, Rax
		Mov [Rcx].BTN_CMD_INFO.cmdbRestart, FALSE
		Mov [Rcx].BTN_CMD_INFO.cmdType, BTN_CMD_TYPE_APP
		Lea Rcx, [Rcx].BTN_CMD_INFO.cmdLine
		Cmp Rax, FALSE
		Jz clrreboot
			ECInvoke lstrcpy, Rcx, CTXT("SHUTDOWN")
			ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_CMDLINE, CTXT("SHUTDOWN")
			ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_ARGS, 0
		Jmp rsc
clrshut:
		ECInvoke lstrcpy, Rcx, 0
		ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_CMDLINE, 0
		ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_ARGS, 0
rsc:


		ECInvoke CheckDlgButton, hWnd, CTRL_CFG_CHKB_RESTART, FALSE


c_n5:Cmp wParam, CTRL_CFG_CHKB_RESTART
	Jne c_n6
		Mov [Rcx].BTN_CMD_INFO.cmdbShutdown, FALSE
		Mov [Rcx].BTN_CMD_INFO.cmdbRestart, Rax
		Mov [Rcx].BTN_CMD_INFO.cmdType, BTN_CMD_TYPE_APP
		Lea Rcx, [Rcx].BTN_CMD_INFO.cmdLine
		Cmp Rax, FALSE
		Jz clrreboot
			ECInvoke lstrcpy, Rcx, CTXT("REBOOT")
			ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_CMDLINE, CTXT("REBOOT")
			ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_ARGS, 0
		Jmp rbc
clrreboot:
		ECInvoke lstrcpy, Rcx, 0
		ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_CMDLINE, 0
		ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_ARGS, 0
rbc:

		ECInvoke CheckDlgButton, hWnd, CTRL_CFG_CHKB_SHUTDOWN, FALSE


c_n6:
	Mov Rcx, wParam
	_HIWORD Ecx
	Cmp Cx, EN_CHANGE
	Jnz notChange
		Mov Rcx, wParam
		_LOWORD Ecx
		Cmp Cx, CTRL_CFG_EDIT_CMDLINE
		Jne es_n1
		ECInvoke NewStr, 0, MAX_PATH
		Mov pStr, Rax
		ECInvoke GetDlgItemText, hWnd, CTRL_CFG_EDIT_CMDLINE, pStr, MAX_PATH
		Mov Rcx, G_P_CURRENT_BTN_CMD_INFO
		Lea Rax, [Rcx].BTN_CMD_INFO.cmdLine
		ECInvoke lstrcpy, Rax, pStr
		ECInvoke GetParent, hWnd
		ECInvoke SendMessage, Rax, WM_CONFIG_UPDATE
		ECInvoke DelStr, pStr
	es_n1:
		Mov Rcx, wParam
		_LOWORD Ecx
		Cmp Cx, CTRL_CFG_EDIT_ARGS
		Jne es_n2
		ECInvoke NewStr, 0, MAX_PATH
		Mov pStr, Rax
		ECInvoke GetDlgItemText, hWnd, CTRL_CFG_EDIT_ARGS, pStr, MAX_PATH
		Mov Rcx, G_P_CURRENT_BTN_CMD_INFO
		Lea Rax, [Rcx].BTN_CMD_INFO.cmdArg
		ECInvoke lstrcpy, Rax, pStr
		ECInvoke GetParent, hWnd
		ECInvoke SendMessage, Rax, WM_CONFIG_UPDATE
		ECInvoke DelStr, pStr
	es_n2:
notChange:

;		ECInvoke GetDlgItem, hWnd, wParam
;		ECInvoke GetWindowLongPtr, Rax, GWLP_USERDATA
;		Mov pBtnCmdInfo, Rax
;		;Cmp pBtnCmdInfo, 0
		;Jz notdrop

;		ECInvoke MessageBox, 0, pBtnCmdInfo, pBtnCmdInfo, 0
;notdrop:
	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_CONFIG_UPDATE
;	Xor Eax, Eax
;	Ret

@@:Cmp uMsg, WM_ICON_BTN_MOVE
	Jnz @F
	Cmp wParam, CTRL_CONFIG_BTN_GUN_SIGHT
	Jne c_m1

		ECInvoke GetCapture

		;Mov hWnd, Rax
		comment #
		GETX lParam
		Mov pt.x, Eax
		GETY lParam
		Mov pt.y, Eax
		#
		ECInvoke GetCursorPos, Addr pt
		;ECInvoke ClientToScreen, hWnd, Addr pt
		ECInvoke WindowFromPoint, pt
		Mov hWnd, Rax
		ECInvoke GetRootWindow, hWnd
		Cmp Rax, G_MAIN_WINDOW
		Jne c_def
		Mov hWnd, 0
		Mov G_CURRENT_CATCH_HWND, 0
c_def:
		;ECInvoke GetRootWindow, hWnd
		Mov Rax, hWnd
		Test Eax, Eax
		Jz @F
		;Cmp Rax, G_CURRENT_CATCH_HWND
	;	Jz hilited
		;ECInvoke GetRootWindow, Rax

		Mov G_CURRENT_CATCH_HWND, Rax
		ECInvoke FlashBorder, G_CURRENT_CATCH_HWND, 50, 2
hilited:
c_m1:

@@:Cmp uMsg, WM_ICON_BTN_DOWN
	Jnz @F
	Cmp wParam, CTRL_CONFIG_BTN_GUN_SIGHT
	Jne c_d1



	ECInvoke GetWindowLongPtr, lParam, GWLP_USERDATA
	Mov Rax, [Rax + ICON_BTN_INFO.PICON_OBJECT]
	Mov Rcx, [Rax + ICON_OBJECT.ICON_BITMAP]
	ECInvoke SetBitmapToCursor, hWnd, Rcx
	Mov G_OLD_CURSOR, Rax

	Mov G_IS_SELECT_DONE, FALSE
	Mov G_CURRENT_CATCH_HWND, 0
	;ECInvoke CreateThread, 0, 0, Addr ScanSelectWindow, 0, 0, 0
;ngc:
c_d1:
@@:Cmp uMsg, WM_ICON_BTN_UP
	Jnz @F
	Cmp wParam, CTRL_CONFIG_BTN_GUN_SIGHT
	Jne c_u1
	Mov G_IS_SELECT_DONE, TRUE

	ECInvoke GetWindowThreadProcessId, G_CURRENT_CATCH_HWND, Addr pid
	;ECInvoke GetProcessFilePath, pid
	ECInvoke GetProcessArgLine, pid
	Mov pArgs, Rcx
	Mov pStr, Rax
	ECInvoke lstrlen, Rax

	Test Eax, Eax
	Jz nostr
	ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_CMDLINE, pStr
	ECInvoke SetDlgItemText, hWnd, CTRL_CFG_EDIT_ARGS, pArgs
	Mov Rcx, G_P_CURRENT_BTN_CMD_INFO
	Lea Rax, [Rcx].BTN_CMD_INFO.cmdLine
	ECInvoke lstrcpy, Rax, pStr
	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_CONFIG_UPDATE
nostr:
	ECInvoke DelStr, pStr
	ECInvoke UnsetBitmapToCursor, hWnd, G_OLD_CURSOR
c_u1:
@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
ConfigFrameProc EndP
ScanSelectWindow Proc arg:QWord
	Local pt:POINT
	Local rcClient:RECT
	Local hdc:HDC
	Mov arg, Rcx
loop_catch:

	ECInvoke GetCursorPos, Addr pt
	ECInvoke WindowFromPoint, pt
	ECInvoke GetRootWindow, Rax
	Mov G_CURRENT_CATCH_HWND, Rax
	ECInvoke HilightWindowBorder, G_CURRENT_CATCH_HWND
	comment #
	ECInvoke GetDC, Rax
	Mov hdc, Rax
	ECInvoke GetClientRect, G_CURRENT_CATCH_HWND, Addr rcClient

	ECInvoke PatBlt, hdc, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, DSTINVERT
	ECInvoke DeleteDC, hdc
	ECInvoke ReleaseDC, G_CURRENT_CATCH_HWND, hdc
	#
	ECInvoke Sleep, 10
	Cmp G_IS_SELECT_DONE, TRUE
	Jne loop_catch

	Ret
ScanSelectWindow EndP

ImageBtnCtrlProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
	Local hdc:QWord
	Local hIcon:QWord
	Local linex:QWord
	Local liney:QWord
	Local lineOx:QWord
	Local lineOy:QWord
;	Local buffer[MAX_PATH]:DB
	Local ps:PAINTSTRUCT
	Local rcClient:RECT
	Local icoClient:RECT
	Local hRgn:HRGN
	Local hBrush:HBRUSH
	Local hPen:HPEN
	Local cmdName[50]:Byte
	Local pBtnCmdInfo:QWord
	Local bShutdown:QWord
	Local bRestart:QWord
	Local hMemDC:HDC
	Local hMemBitmap:HBITMAP
;	Local ondWndProc:QWord
	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pBtnCmdInfo, Rax


	Cmp uMsg, WM_PAINT
	Jnz @F

        ECInvoke BeginPaint, hWnd, Addr ps


       	ECInvoke GetClientRect, hWnd, Addr rcClient

       	ECInvoke CreateMemDC, ps.hdc, rcClient.right, rcClient.bottom
		Mov hMemDC, Rax
		Mov hMemBitmap, Rcx

        ; 创建具有圆角的区域
        ECInvoke CreateRoundRectRgn, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, 3, 3
        Mov hRgn, Rax

        ; 将绘图设备（DC）裁剪为具有圆角的区域
       ; ECInvoke SelectClipRgn, ps.hdc, hRgn
		ECInvoke CreateSolidBrush, BTN_BGK_COLOR
		Mov hBrush, Rax
		ECInvoke CreatePen, PS_SOLID, 1, 00441111H
		Mov hPen, Rax
		;ECInvoke SelectObject, ps.hdc, hBrush
		ECInvoke SelectObject, hMemDC, hPen
        ; 绘制矩形
        ;ECInvoke FillRect, ps.hdc, Addr rcClient, hBrush
        ECInvoke FillRgn, hMemDC, hRgn, hBrush
		;ECInvoke FrameRgn, ps.hdc, hRgn, hBrush, 1, 1
        ; 清理资源
        ECInvoke DeleteObject, hRgn

		Mov Eax, rcClient.right
		Mov lineOx, Rax
		Sub lineOx, 6
		Shr Rax, 1
		Sub Rax, 1
		Mov linex, Rax

		
		Mov Eax, rcClient.bottom
		Mov lineOy, Rax
		Sub lineOy, 6
		Shr Rax, 1
		Sub Rax, 1
		Mov liney, Rax


		; 设置起始点并绘制垂直线段
        ECInvoke MoveToEx, hMemDC, linex, 6, NULL
        ECInvoke LineTo, hMemDC, linex, lineOy

        ; 设置起始点并绘制水平线段
        ECInvoke MoveToEx, hMemDC, 6, liney, NULL
        ECInvoke LineTo, hMemDC, lineOx, liney
       
		ECInvoke DeleteObject, hBrush
		ECInvoke DeleteObject, hPen

		Mov Rax, pBtnCmdInfo
		Mov Rcx, [Rax + BTN_CMD_INFO.cmdbShutdown]
		Mov bShutdown, Rcx
		Mov Rcx, [Rax + BTN_CMD_INFO.cmdbRestart]
		Mov bRestart, Rcx
	;	Cmp pBtnCmdInfo, 0
	;	Jz notdrop
		Lea Rcx, [Rax + BTN_CMD_INFO.cmdLine]
		;check runmode
		comment #
		Push Rcx
		ECInvoke CheckRunMode, Rcx
		Pop Rcx
		#
        ECInvoke GetFileDefaultIcon, Rcx
		Mov hIcon, Rax
		Test Eax, Eax
		Jz noIcon

		Cmp bShutdown, TRUE
		Jne notStdown
			ECInvoke DestroyIcon, hIcon
			Mov Rax, G_ICON_SHUTDOWN
			Mov hIcon, Rax
			Mov Eax, rcClient.right
			Sub Rax, 4
			Dec Eax
			ECInvoke DrawIconEx, hMemDC, 2, 2, hIcon, Rax, Rax, 0, 0, DI_NORMAL
			comment #
			Mov Rax, G_ICON_SHUTDOWN
			Mov Rcx, [Rax].ICON_OBJECT.ICON_DC
			Mov hdc, Rcx
			Lea Rdx, [Rax].ICON_OBJECT.ICON_RECT
			ECInvoke memcpy, Addr icoClient, Rdx, SizeOf icoClient
			ECInvoke TransparentBlt, ps.hdc, 0, 0, rcClient.right, rcClient.bottom, hdc, 0, 0, icoClient.right, icoClient.bottom, TRANS_COLOR
			 #
			Jmp noIcon
notStdown:Cmp bRestart, TRUE
		Jne notRestart

			ECInvoke DestroyIcon, hIcon
			Mov Rax, G_ICON_RESTART
			Mov hIcon, Rax

			Mov Eax, rcClient.right
			Sub Rax, 4
			Dec Eax
			ECInvoke DrawIconEx, hMemDC, 2, 2, hIcon, Rax, Rax, 0, 0, DI_NORMAL
			comment #
			Mov Rax, G_ICON_RESTART
			Mov Rcx, [Rax].ICON_OBJECT.ICON_DC
			Mov hdc, Rcx
			Lea Rdx, [Rax].ICON_OBJECT.ICON_RECT
			ECInvoke memcpy, Addr icoClient, Rdx, SizeOf icoClient
			ECInvoke TransparentBlt, ps.hdc, 0, 0, rcClient.right, rcClient.bottom, hdc, 0, 0, icoClient.right, icoClient.bottom, TRANS_COLOR
			#
			Jmp noIcon
notRestart:
		Mov Eax, rcClient.right
		Sub Rax, 4
		Dec Eax
		ECInvoke DrawIconEx, hMemDC, 2, 2, hIcon, Rax, Rax, 0, 0, DI_NORMAL
	    ECInvoke DestroyIcon, hIcon
noIcon:

;notdrop:
		ECInvoke BitBlt, ps.hdc, 0, 0, ps.rcPaint.right, ps.rcPaint.bottom, hMemDC, 0, 0, SRCCOPY
        ECInvoke EndPaint, hWnd, Addr ps
        ECInvoke DeleteObject, hMemBitmap
        ECInvoke DeleteDC, hMemDC
        ;ECInvoke ReleaseDC, ps.hdc
        ;ECInvoke DeleteDC, hWnd, ps.hdc
	;Xor Eax, Eax
	;Ret
@@:Cmp uMsg, WM_RBUTTONDOWN
	Jne @F

		ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
		ECInvoke ZeroMemory, Rax, SizeOf BTN_CMD_INFO

		ECInvoke UpdateInWindow, hWnd
		ECInvoke GetParent, hWnd
		ECInvoke SendMessage, Rax, WM_IMAGE_CHANGE, 0, 0
@@:Cmp uMsg, WM_LBUTTONDOWN
	Jne @F

		;开启命令配置界面
		;ECInvoke GetCmditemCmdName, 0, 0, 0, Addr cmdName

		;ECInvoke MessageBox, 0, Addr g_drop_file, Addr g_drop_file, 0
		;Xor Eax, Eax
		;Ret
@@: Cmp uMsg, WM_DROPFILES
	Jne @F


		comment #
		Cmp pBtnCmdInfo, 0
		Jnz alloced
		ECInvoke VirtualAlloc, 0, MAX_PATH, MEM_COMMIT, PAGE_EXECUTE_READWRITE
		Mov pBtnCmdInfo, Rax
		ECInvoke SetWindowLongPtr, hWnd, GWLP_USERDATA, pBtnCmdInfo
alloced:
#
	    ; 获取拖放的文件路径
	    Mov Rax, pBtnCmdInfo
	    Mov QWord Ptr [Rax + BTN_CMD_INFO.cmdType], BTN_CMD_TYPE_APP
	    Lea R8, [Rax + BTN_CMD_INFO.cmdLine]
	    ECInvoke DragQueryFile, wParam, 0, R8, MAX_PATH
		ECInvoke UpdateInWindow, hWnd

      ; 释放拖放操作相关资源
	    ECInvoke DragFinish, wParam

		ECInvoke GetParent, hWnd
		ECInvoke SendMessage, Rax, WM_IMAGE_CHANGE, 0, 0
	Xor Eax, Eax
	Ret
@@:

	;Mov Rax, pBtnCmdInfo
;	Mov Rax, [Rax + BTN_CMD_INFO.oldWndProc]
	comment #
	Mov Rcx, hWnd
	Mov Rdx, uMsg
	Mov R8, wParam
	Mov R9, lParam
	Sub Rsp, 30H
	Call Rax
	Add Rsp, 30H
#
	;ECInvoke CallWindowProc, Rax, hWnd, uMsg, wParam, lParam
     ECInvoke DefSubclassProc, hWnd, uMsg, wParam, lParam
    ;ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam
     Ret
ImageBtnCtrlProc EndP

HLinkCtrlProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
	Local ps:PAINTSTRUCT
	Local rcClient:RECT
	Local pText:QWord
	Local pHlinkInfo:QWord
	Local hFont:HFONT
	Local oldObj:QWord
	Local oldFont:QWord
	Local curColor:DWord
	Local pUrl:QWord
	Local textSize:SIZE_EX
	Local tme:TRACKMOUSEEVENT
	Local strLen:DWord
	Local hMemDC:HDC
	Local hMemBitmap:HBITMAP

	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F
 		ECInvoke BeginPaint, hWnd, Addr ps

			ECInvoke GetClientRect, hWnd, Addr rcClient
			ECInvoke CreateMemDC, ps.hdc, rcClient.right, rcClient.bottom
			Mov hMemDC, Rax
			Mov hMemBitmap, Rcx

			ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
			Mov pHlinkInfo, Rax

			Mov Rcx, [Rax].HLINK_BTN_INFO.hFont
			Mov hFont, Rcx
			Mov Ecx, [Rax].HLINK_BTN_INFO.CUR_COLOR
			Mov curColor, Ecx
			Mov Rcx, [Rax].HLINK_BTN_INFO.pText
			Mov pText, Rcx

			ECInvoke SelectObject, hMemDC, hFont
			Mov oldFont, Rax
		;	ECInvoke CreateSolidBrush, 00FF0000H
		;	ECInvoke SelectObject, hMemDC, Rax
		;	Mov oldObj, Rax
			ECInvoke GetPixel, ps.hdc, 0, 0
			ECInvoke DrawBackground, hMemDC, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom, Rax
			comment #
			ECInvoke CreateSolidBrush, Rax
			Push Rax
			ECInvoke FillRect, ps.hdc, Addr ps.rcPaint, Rax
			Pop Rcx
			ECInvoke DeleteObject, Rcx
			#
			;ECInvoke PatBlt, ps.hdc, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom, DSTINVERT
			ECInvoke lstrlen, pText
			Mov strLen, Eax
			ECInvoke GetTextExtentPoint32, hMemDC, pText, strLen, Addr textSize


			ECInvoke SetBkMode, hMemDC, TRANSPARENT

			ECInvoke SetTextColor, hMemDC, curColor

			Mov Edx, ps.rcPaint.right
			Sub Edx, ps.rcPaint.left
			Mov Eax, textSize.icx
			Sub Edx, Eax
			Shr Edx, 1

			Mov R8d, ps.rcPaint.bottom
			Sub R8d, ps.rcPaint.top
			Mov Eax, textSize.icy
			Sub R8d, Eax
			Shr R8d, 1
            ECInvoke TextOut, hMemDC, Rdx, R8, pText, strLen

		;	ECInvoke SelectObject, hMemDC, oldObj
			ECInvoke SelectObject, hMemDC, oldFont
			
		ECInvoke BitBlt, ps.hdc, 0, 0, ps.rcPaint.right, ps.rcPaint.bottom, hMemDC, 0, 0, SRCCOPY
        ECInvoke EndPaint, hWnd, Addr ps
        ECInvoke DeleteObject, hMemBitmap
        ECInvoke DeleteDC, hMemDC

@@:Cmp uMsg, WM_MOUSEMOVE
	Jnz @F
	ECInvoke ZeroMemory, Addr tme, SizeOf tme
    Mov tme.cbSize, SizeOf TRACKMOUSEEVENT
    Mov tme.dwFlags, TME_LEAVE
    Mov Rax, hWnd
    Mov tme.hwndTrack, Rax
    ECInvoke TrackMouseEvent, Addr tme

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pHlinkInfo, Rax
	Mov [Rax].HLINK_BTN_INFO.CUR_COLOR, HLINK_HILIGHT_COLOR
	ECInvoke UpdateInWindow, hWnd
	ECInvoke LoadCursor, NULL, IDC_HAND
	ECInvoke SetCursor, Rax
@@:Cmp uMsg, WM_LBUTTONDOWN
	Jnz @F
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pHlinkInfo, Rax
	Mov [Rax].HLINK_BTN_INFO.CUR_COLOR, HLINK_CLICK_COLOR
	Mov Rcx, [Rax].HLINK_BTN_INFO.pUrl
	Mov pUrl, Rcx

	ECInvoke UpdateInWindow, hWnd
	ECInvoke LoadCursor, NULL, IDC_HAND
	ECInvoke SetCursor, Rax
	ECInvoke RunCommand, pUrl, 0, 0, FALSE, FALSE
@@:Cmp uMsg, WM_LBUTTONUP
	Jnz @F
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pHlinkInfo, Rax
	Mov [Rax].HLINK_BTN_INFO.CUR_COLOR, HLINK_HILIGHT_COLOR
	ECInvoke UpdateInWindow, hWnd

	ECInvoke LoadCursor, NULL, IDC_HAND
	ECInvoke SetCursor, Rax


@@:Cmp uMsg, WM_MOUSELEAVE
	Jnz @F

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pHlinkInfo, Rax
	Mov [Rax].HLINK_BTN_INFO.CUR_COLOR, HLINK_NORMAL_COLOR
	ECInvoke UpdateInWindow, hWnd
	ECInvoke LoadCursor, NULL, IDC_ARROW
	ECInvoke SetCursor, Rax
@@:ECInvoke DefSubclassProc, hWnd, uMsg, wParam, lParam
	Ret
HLinkCtrlProc EndP


FlatIconBtnProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
;	Local buffer[MAX_PATH]:DB
	Local pt:POINT
	Local ps:PAINTSTRUCT
	Local rcClient:RECT
	Local iconRect:RECT
	Local tme:TRACKMOUSEEVENT
	Local hRgn:HRGN
	Local hBrush:HBRUSH
	Local pBtnCmdInfo:QWord
	Local downColor:DWord
	Local hDC:QWord
	Local cColor:DWord
	Local oColor:DWord
	Local pIconObject:QWord
	Local ctrlId:QWord
	Local hMemDC:HDC
	Local hMemBitmap:HBITMAP

	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F

        ECInvoke BeginPaint, hWnd, Addr ps

		ECInvoke GetClientRect, hWnd, Addr rcClient
      	ECInvoke CreateMemDC, ps.hdc, rcClient.right, rcClient.bottom
		Mov hMemDC, Rax
		Mov hMemBitmap, Rcx
        ; 创建具有圆角的区域
        ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
		Mov pBtnCmdInfo, Rax

        Mov Rcx, [Rax].ICON_BTN_INFO.PICON_OBJECT
        Mov pIconObject, Rcx
        Mov Rcx, [Rcx].ICON_OBJECT.ICON_DC
        Mov hDC, Rcx

	;	Xor Edx, Edx


	;	Mov Edx, [Rax + ICON_BTN_INFO.OLD_COLOR]
	;	Mov oColor, Edx

		comment #
    ECInvoke GetStockObject, DC_BRUSH
    Mov hBrush, Rax

    ECInvoke SelectObject, ps.hdc, hBrush


		ECInvoke SetDCBrushColor, ps.hdc, cColor
		#
	;	ECInvoke SetDCBrushColor, ps.hdc, cColor
Comment #
		ECInvoke SetDCPenColor, hDC, Rdx

		ECInvoke SetDCBrushColor, ps.hdc, Rdx
		ECInvoke SetDCPenColor, ps.hdc, Rdx
		#
	;	ECInvoke CreatePen, PS_SOLID, 1, 00441111H
		;Mov hPen, Rax
		;ECInvoke SelectObject, ps.hdc, hBrush
	;	ECInvoke SelectObject, ps.hdc, hPen
    ;    ; 绘制矩形
        ;ECInvoke FillRect, ps.hdc, Addr rcClient, hBrush
       ; ECInvoke FillRgn, ps.hdc, hRgn, hBrush
		;ECInvoke FrameRgn, ps.hdc, hRgn, hBrush, 2, 2
        ; 清理资源
		Mov Rcx, [Rax].ICON_BTN_INFO.IS_PUSH_TYPE
		Cmp Rcx, TRUE
		Jnz notpush

			Mov Rax, pBtnCmdInfo
			Mov Rcx, [Rax].ICON_BTN_INFO.STATE
			Cmp Rcx, TRUE
			Jnz notpush

	        Mov Rax, pBtnCmdInfo
	       	Mov Edx, [Rax].ICON_BTN_INFO.IN_COLOR
			ECInvoke DrawBackground, hMemDC, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, Rdx
			Jmp draw_icon
notpush:
        Mov Rax, pBtnCmdInfo
       	Mov Edx, [Rax].ICON_BTN_INFO.CURR_COLOR
		ECInvoke DrawBackground, hMemDC, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, Rdx
       ; ECInvoke Rectangle, ps.hdc, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom
draw_icon:

        Mov Rcx, pIconObject
		Lea Rdx, [Rcx].ICON_OBJECT.ICON_RECT
		ECInvoke memcpy, Addr iconRect, Rdx, SizeOf RECT

		;Mov Rax, pBtnCmdInfo
       	;Mov Edx, [Rax].ICON_BTN_INFO.CURR_COLOR


		;ECInvoke Icon_ChangeColor, pIconObject, Rdx
		Mov Eax, iconRect.right
		Mov Edx, rcClient.right
		Sub Edx, Eax
		Shr Edx, 1

		Mov Eax, iconRect.bottom
		Mov R8d, rcClient.bottom
		Sub R8d, Eax
		Shr R8d, 1

		ECInvoke TransparentBlt, hMemDC, Rdx, R8, iconRect.right, iconRect.bottom, hDC, 0, 0, iconRect.right, iconRect.bottom, TRANS_COLOR
        ;ECInvoke BitBlt, ps.hdc, 0, 0, 16, 16, hDC, 0, 0, SRCCOPY
       ; ECInvoke DeleteObject, hBrush

;notdrop:
		ECInvoke BitBlt, ps.hdc, 0, 0, ps.rcPaint.right, ps.rcPaint.bottom, hMemDC, 0, 0, SRCCOPY
        ECInvoke EndPaint, hWnd, Addr ps
        ECInvoke DeleteObject, hMemBitmap
        ECInvoke DeleteDC, hMemDC

        ;ECInvoke ReleaseDC, ps.hdc
        ;ECInvoke DeleteDC, hWnd, ps.hdc
	;Xor Eax, Eax
	;Ret
@@:Cmp uMsg, WM_MOUSEMOVE
	Jnz @F


	ECInvoke ZeroMemory, Addr tme, SizeOf tme
    Mov tme.cbSize, SizeOf TRACKMOUSEEVENT
    Mov tme.dwFlags, TME_LEAVE
    Mov Rax, hWnd
    Mov tme.hwndTrack, Rax
    ECInvoke TrackMouseEvent, Addr tme

	;ECInvoke GetWMMousePos, lParam, Addr pt
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pBtnCmdInfo, Rax

	;ECInvoke GetClientRect, hWnd, Addr rcClient
	;获得鼠标移动的x,y

	Mov Ecx, [Rax + ICON_BTN_INFO.DOWN_COLOR]
	Mov downColor, Ecx

	;Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
;	Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx



	Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
	Cmp Ecx, downColor
	Jz m_n0
	ECInvoke UpdateInWindow, hWnd

	Mov Rax, pBtnCmdInfo
	Mov Ecx, [Rax + ICON_BTN_INFO.IN_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx
m_n0:
	ECInvoke GetDlgCtrlID, hWnd
	Mov ctrlId, Rax
	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_ICON_BTN_MOVE, ctrlId, lParam

;	ECInvoke PtInRegion, hRgn, pt.x, pt.y
;	Test Eax, Eax
;	Jz @F
	;	Mov Rax, pBtnCmdInfo
	;	Mov Rcx, [Rax + ICON_BTN_INFO.IN_COLOR]
	;	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Rcx


@@:Cmp uMsg, WM_LBUTTONUP
	Jnz @F
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pBtnCmdInfo, Rax
	comment #
	Mov Rcx, [Rax].ICON_BTN_INFO.IS_PUSH_TYPE
	Cmp Rcx, TRUE
	Jnz upnmd
		Mov Rcx, [Rax].ICON_BTN_INFO.STATE
		Not Rcx
		Mov [Rax].ICON_BTN_INFO.STATE, Rcx
upnmd:
#
;	Mov pBtnCmdInfo, Rax

;	Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
	;Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx

	Mov Ecx, [Rax + ICON_BTN_INFO.IN_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx

	ECInvoke UpdateInWindow, hWnd

	ECInvoke GetDlgCtrlID, hWnd
	Mov ctrlId, Rax

	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_ICON_BTN_UP, ctrlId, hWnd

@@:Cmp uMsg, WM_LBUTTONDOWN
	Jnz @F

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pBtnCmdInfo, Rax
	Mov Rcx, [Rax].ICON_BTN_INFO.IS_PUSH_TYPE
	Cmp Rcx, TRUE
	Jnz dwnmd

		Mov Rcx, [Rax].ICON_BTN_INFO.STATE
		Xor Cl, TRUE
		Mov [Rax].ICON_BTN_INFO.STATE, Rcx
dwnmd:
;	Mov pBtnCmdInfo, Rax

	;Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
	;Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx

	Mov Ecx, [Rax + ICON_BTN_INFO.DOWN_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx

	ECInvoke UpdateInWindow, hWnd

	ECInvoke GetDlgCtrlID, hWnd
	Mov ctrlId, Rax

	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_ICON_BTN_DOWN, ctrlId, hWnd

@@:Cmp uMsg, WM_MOUSELEAVE
	Jne @F

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
;	Mov pBtnCmdInfo, Rax
	;Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
;	Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx


	Mov Ecx, [Rax + ICON_BTN_INFO.NORMAL_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx

	ECInvoke UpdateInWindow, hWnd


@@:
     ECInvoke DefSubclassProc, hWnd, uMsg, wParam, lParam
     Ret
FlatIconBtnProc EndP

IconBtnProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
;	Local buffer[MAX_PATH]:DB
	Local pt:POINT
	Local ps:PAINTSTRUCT
	Local rcClient:RECT
	Local tme:TRACKMOUSEEVENT
	Local hRgn:HRGN
	Local hBrush:HBRUSH
	Local pBtnCmdInfo:QWord
	Local downColor:DWord
	Local hDC:QWord
	Local cColor:DWord
	Local oColor:DWord
	Local pIconObject:QWord
	Local ctrlId:QWord
	Local hMemDC:HDC
	Local hMemBitmap:HBITMAP

	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F

        ECInvoke BeginPaint, hWnd, Addr ps

        
       ECInvoke GetClientRect, hWnd, Addr rcClient
      	ECInvoke CreateMemDC, ps.hdc, rcClient.right, rcClient.bottom
		Mov hMemDC, Rax
		Mov hMemBitmap, Rcx
		ECInvoke BitBlt, hMemDC, 0, 0, ps.rcPaint.right, ps.rcPaint.bottom, ps.hdc, 0, 0, SRCCOPY
        ; 创建具有圆角的区域
        ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA


        Mov Rcx, [Rax].ICON_BTN_INFO.PICON_OBJECT
        Mov pIconObject, Rcx
        Mov Rcx, [Rcx].ICON_OBJECT.ICON_DC
        Mov hDC, Rcx

	;	Xor Edx, Edx


	;	Mov Edx, [Rax + ICON_BTN_INFO.OLD_COLOR]
	;	Mov oColor, Edx

		comment #
    ECInvoke GetStockObject, DC_BRUSH
    Mov hBrush, Rax

    ECInvoke SelectObject, ps.hdc, hBrush


		ECInvoke SetDCBrushColor, ps.hdc, cColor
		#
	;	ECInvoke SetDCBrushColor, ps.hdc, cColor
Comment #
		ECInvoke SetDCPenColor, hDC, Rdx

		ECInvoke SetDCBrushColor, ps.hdc, Rdx
		ECInvoke SetDCPenColor, ps.hdc, Rdx
		#
	;	ECInvoke CreatePen, PS_SOLID, 1, 00441111H
		;Mov hPen, Rax
		;ECInvoke SelectObject, ps.hdc, hBrush
	;	ECInvoke SelectObject, ps.hdc, hPen
    ;    ; 绘制矩形
        ;ECInvoke FillRect, ps.hdc, Addr rcClient, hBrush
       ; ECInvoke FillRgn, ps.hdc, hRgn, hBrush
		;ECInvoke FrameRgn, ps.hdc, hRgn, hBrush, 2, 2
        ; 清理资源

       	Mov Edx, [Rax].ICON_BTN_INFO.CURR_COLOR
		ECInvoke Icon_ChangeColor, pIconObject, Rdx
		ECInvoke TransparentBlt, hMemDC, 0, 0, rcClient.right, rcClient.bottom, hDC, 0, 0, rcClient.right, rcClient.bottom, TRANS_COLOR
        ;ECInvoke BitBlt, ps.hdc, 0, 0, 16, 16, hDC, 0, 0, SRCCOPY
       ; ECInvoke DeleteObject, hBrush

;notdrop:

		ECInvoke BitBlt, ps.hdc, 0, 0, ps.rcPaint.right, ps.rcPaint.bottom, hMemDC, 0, 0, SRCCOPY
        ECInvoke EndPaint, hWnd, Addr ps
        ECInvoke DeleteObject, hMemBitmap
        ECInvoke DeleteDC, hMemDC
        ;ECInvoke ReleaseDC, ps.hdc
        ;ECInvoke DeleteDC, hWnd, ps.hdc
	;Xor Eax, Eax
	;Ret
@@:Cmp uMsg, WM_MOUSEMOVE
	Jnz @F



    Mov tme.cbSize, SizeOf TRACKMOUSEEVENT
    Mov tme.dwFlags, TME_LEAVE
    Mov Rax, hWnd
    Mov tme.hwndTrack, Rax
    ECInvoke TrackMouseEvent, Addr tme

	;ECInvoke GetWMMousePos, lParam, Addr pt
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
	Mov pBtnCmdInfo, Rax

	;ECInvoke GetClientRect, hWnd, Addr rcClient
	;获得鼠标移动的x,y

	Mov Ecx, [Rax + ICON_BTN_INFO.DOWN_COLOR]
	Mov downColor, Ecx

	;Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
;	Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx



	Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
	Cmp Ecx, downColor
	Jz m_n0
	ECInvoke UpdateInWindow, hWnd

	Mov Rax, pBtnCmdInfo
	Mov Ecx, [Rax + ICON_BTN_INFO.IN_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx
m_n0:
	ECInvoke GetDlgCtrlID, hWnd
	Mov ctrlId, Rax
	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_ICON_BTN_MOVE, ctrlId, lParam
;	ECInvoke PtInRegion, hRgn, pt.x, pt.y
;	Test Eax, Eax
;	Jz @F
	;	Mov Rax, pBtnCmdInfo
	;	Mov Rcx, [Rax + ICON_BTN_INFO.IN_COLOR]
	;	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Rcx


@@:Cmp uMsg, WM_LBUTTONUP
	Jnz @F
	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
;	Mov pBtnCmdInfo, Rax

;	Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
	;Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx

	Mov Ecx, [Rax + ICON_BTN_INFO.IN_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx

	ECInvoke UpdateInWindow, hWnd

	ECInvoke GetDlgCtrlID, hWnd
	Mov ctrlId, Rax

	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_ICON_BTN_UP, ctrlId, hWnd

@@:Cmp uMsg, WM_LBUTTONDOWN
	Jnz @F

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
;	Mov pBtnCmdInfo, Rax

	;Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
	;Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx

	Mov Ecx, [Rax + ICON_BTN_INFO.DOWN_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx

	ECInvoke UpdateInWindow, hWnd

	ECInvoke GetDlgCtrlID, hWnd
	Mov ctrlId, Rax

	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_ICON_BTN_DOWN, ctrlId, hWnd

@@:Cmp uMsg, WM_MOUSELEAVE
	Jne @F

	ECInvoke GetWindowLongPtr, hWnd, GWLP_USERDATA
;	Mov pBtnCmdInfo, Rax
	;Mov Ecx, [Rax + ICON_BTN_INFO.CURR_COLOR]
;	Mov [Rax + ICON_BTN_INFO.OLD_COLOR], Ecx


	Mov Ecx, [Rax + ICON_BTN_INFO.NORMAL_COLOR]
	Mov [Rax + ICON_BTN_INFO.CURR_COLOR], Ecx

	ECInvoke UpdateInWindow, hWnd


@@:
     ECInvoke DefSubclassProc, hWnd, uMsg, wParam, lParam
     Ret
IconBtnProc EndP

ShowRunCmdTipProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
    Local ps:PAINTSTRUCT
    Local pText:QWord
    Local fWidth:DWord
    Local fHeight:DWord
    Local hdcMem:HDC
    Local hBitmap:HBITMAP
    Local hFont:QWord
    Local hFSize:DWord
    Local oldFont:QWord
   ; Local btnx:DWord
   ; Local btny:DWord
   ; Local hRgn:HRGN
   ; Local hBrush:HBRUSH
   ; Local pts[4]:POINT
    Local rcClient:RECT
   ; Local pt:POINT
	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F


        ECInvoke BeginPaint, hWnd, Addr ps
		ECInvoke NewStr, 0, MAX_PATH
		Mov pText, Rax
		ECInvoke GetWindowText, hWnd, pText, MAX_PATH

 		Mov hFSize, 32
    	ECInvoke CreateSystemFont, hFSize, FALSE, 0
    	Mov hFont, Rax



		ECInvoke SelectObject, ps.hdc, hFont
		Mov oldFont, Rax
		ECInvoke GetTextWide, ps.hdc, pText

		Mov fWidth, Eax
		Mov fHeight, Edx
	;	Shr Eax, 2
		Add fWidth, 16
		Add fHeight, 8
		ECInvoke SetWindowPos, hWnd, HWND_TOPMOST, 0, 0, fWidth, fHeight, SWP_NOMOVE
		ECInvoke CenterWindow, hWnd, 0, 52
		ECInvoke GetClientRect, hWnd, Addr rcClient
		Add rcClient.right, 1
		Add rcClient.bottom, 1
		ECInvoke CreateMemDC, ps.hdc, rcClient.right, rcClient.bottom
		Mov hdcMem, Rax
		Mov hBitmap, Rdx

		ECInvoke BitBlt, hdcMem, 0, 0, rcClient.right, rcClient.bottom, ps.hdc, 0, 0, SRCCOPY
		ECInvoke DrawWindowRoundBorder, hdcMem, Addr rcClient, 00996666H, 1

        ECInvoke DrawTextExt, hdcMem, Addr rcClient, pText, 00H, 8, 4, hFont
        ECInvoke DelStr, pText
		ECInvoke BitBlt, ps.hdc, 0, 0, rcClient.right, rcClient.bottom, hdcMem, 0, 0, SRCCOPY
        comment #
        ;ECInvoke GetClientRect, hWnd, Addr rcClient
        ;下页按钮

		Mov Rax, PagePanelPropertys.hRgn_right_btn
        Mov hRgn, Rax
        Mov Rax, PagePanelPropertys.hBrush_current_right
        Mov hBrush, Rax
		;ECInvoke SelectObject, ps.hdc, hRgn
		ECInvoke FillRgn, ps.hdc, hRgn, hBrush

        ;ECInvoke DeleteObject, hRgn
		;ECInvoke DeleteObject, hBrush



        ;上一页按钮
		Mov Rax, PagePanelPropertys.hRgn_left_btn
        Mov hRgn, Rax
        Mov Rax, PagePanelPropertys.hBrush_current_left
        Mov hBrush, Rax


		ECInvoke SelectObject, ps.hdc, hRgn
		ECInvoke FillRgn, ps.hdc, hRgn, hBrush
#
        ;ECInvoke DeleteObject, hRgn
		;ECInvoke DeleteObject, hBrush
		ECInvoke SelectObject, ps.hdc, oldFont
        ECInvoke EndPaint, hWnd, Addr ps
        ECInvoke ReleaseDC, hdcMem
        ECInvoke DeleteObject, hBitmap
        ECInvoke DeleteObject, hFont
 ;       ECInvoke DeleteDC, hWnd, ps.hdc


@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
ShowRunCmdTipProc EndP

PagePanelCtrlProc Proc Private hWnd:QWord, uMsg:QWord, wParam:QWord, lParam:QWord
    Local ps:PAINTSTRUCT
    Local btnx:DWord
    Local btny:DWord
    Local hRgn:HRGN
    Local hBrush:HBRUSH
    Local pts[4]:POINT
    Local rcClient:RECT
    Local pt:POINT
	Mov hWnd, Rcx
	Mov uMsg, Rdx
	Mov wParam, R8
	Mov lParam, R9
	Cmp uMsg, WM_PAINT
	Jnz @F


        ECInvoke BeginPaint, hWnd, Addr ps
        comment #
        ;ECInvoke GetClientRect, hWnd, Addr rcClient
        ;下页按钮

		Mov Rax, PagePanelPropertys.hRgn_right_btn
        Mov hRgn, Rax
        Mov Rax, PagePanelPropertys.hBrush_current_right
        Mov hBrush, Rax
		;ECInvoke SelectObject, ps.hdc, hRgn
		ECInvoke FillRgn, ps.hdc, hRgn, hBrush

        ;ECInvoke DeleteObject, hRgn
		;ECInvoke DeleteObject, hBrush



        ;上一页按钮
		Mov Rax, PagePanelPropertys.hRgn_left_btn
        Mov hRgn, Rax
        Mov Rax, PagePanelPropertys.hBrush_current_left
        Mov hBrush, Rax


		ECInvoke SelectObject, ps.hdc, hRgn
		ECInvoke FillRgn, ps.hdc, hRgn, hBrush
#
        ;ECInvoke DeleteObject, hRgn
		;ECInvoke DeleteObject, hBrush
        ECInvoke EndPaint, hWnd, Addr ps
 ;       ECInvoke ReleaseDC, ps.hdc
 ;       ECInvoke DeleteDC, hWnd, ps.hdc

@@:Cmp uMsg, WM_MOUSEMOVE
	Jnz @F
	comment #
	ECInvoke GetClientRect, hWnd, Addr rcClient
	;获得鼠标移动的x,y
	ECInvoke GetWMMousePos, lParam, Addr pt

	Mov Rcx, PagePanelPropertys.hRgn_right_btn
	ECInvoke InvalidateRgn, hWnd, Rcx, FALSE
	Mov Rcx, PagePanelPropertys.hRgn_left_btn
	ECInvoke InvalidateRgn, hWnd, Rcx, FALSE


	Mov Rcx, PagePanelPropertys.hRgn_right_btn
	ECInvoke PtInRegion, Rcx, pt.x, pt.y
	Test Eax, Eax
	Jz nextRgn
		Mov Rax, PagePanelPropertys.hBrush_hilight
		Mov PagePanelPropertys.hBrush_current_right, Rax

	Jmp @F
nextRgn:
	Mov Rcx, PagePanelPropertys.hRgn_left_btn
	ECInvoke PtInRegion, Rcx, pt.x, pt.y
	Test Eax, Eax
	Jz notHit
		Mov Rax, PagePanelPropertys.hBrush_hilight
		Mov PagePanelPropertys.hBrush_current_left, Rax
	Jmp @F
notHit:
		Mov Rax, PagePanelPropertys.hBrush_normal
		Mov PagePanelPropertys.hBrush_current_left, Rax
		Mov Rax, PagePanelPropertys.hBrush_normal
		Mov PagePanelPropertys.hBrush_current_right, Rax
#
		
@@:Cmp uMsg, WM_LBUTTONDOWN
	Jnz @F
	comment #
	ECInvoke GetClientRect, hWnd, Addr rcClient
	;获得鼠标移动的x,y
	ECInvoke GetWMMousePos, lParam, Addr pt

	Mov Rcx, PagePanelPropertys.hRgn_right_btn
	ECInvoke PtInRegion, Rcx, pt.x, pt.y
	Test Eax, Eax
	Jz blnextRgn
		ECInvoke NextPage
		;ECInvoke MessageBox, 0, 0, 0, 0
	Jmp @F
blnextRgn:
	Mov Rcx, PagePanelPropertys.hRgn_left_btn
	ECInvoke PtInRegion, Rcx, pt.x, pt.y
	Test Eax, Eax
	Jz @F
		ECInvoke PreviousPage
		;Mov Rax, PagePanelPropertys.hBrush_hilight
		;Mov PagePanelPropertys.hBrush_current_left, Rax
		;ECInvoke MessageBox, 0, 0, 0, 0
#


@@:Cmp uMsg, WM_IMAGE_CHANGE
	Jnz @F
	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, WM_PAGE_UPDATE, wParam, lParam
@@:Cmp uMsg, WM_ITEM_BTN_CLCK
	Jnz @F
	ECInvoke GetParent, hWnd
	ECInvoke SendMessage, Rax, uMsg, wParam, lParam
@@:Cmp uMsg, WM_COMMAND
	Jnz @F
	Cmp wParam, CTRL_BTN_PREVIOUS_PAGE
	Jnz n1
	ECInvoke PreviousPage
n1:	Cmp wParam, CTRL_BTN_NEXT_PAGE
	Jnz n2
	ECInvoke NextPage
n2:
	Xor Eax, Eax
	Ret

@@:	ECInvoke DefWindowProc, hWnd, uMsg, wParam, lParam

	Ret
PagePanelCtrlProc EndP
