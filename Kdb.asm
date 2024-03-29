;EasyCodeName=Kdb,1
;EasyCodeName=Kdb,1
.Const
	WM_LLKBD_MSG Equ WM_USER + 100H + 121H
	MAX_KEYS Equ 256
	MAX_HOTKEYS Equ 50
	MAX_CMD_LINE Equ 50 ;最多定义25条命令行
	KBD_CMD_LEN Equ 24
	CMD_START_KEY Equ 55h
	CMD_START_KEY_CTRL Equ 68H
	CMD_TIMEOUT Equ 5000 ;5000毫秒（5）秒
	LLKEY_DOWN Equ 1
	LLKEY_UP Equ 2
.Data?
	hKdbHotHook QWord ?
	g_KeyMAP HANDLE_MALLOC <?>
	g_KeyStatusMap HANDLE_MALLOC <?>

	KBD_STATUS_MAP DB 130 Dup(?)	;只要大于键盘最大键数就行
	KBD_CMD_BUFFER DB KBD_CMD_LEN Dup(?)	;接受指令缓冲区
	KBD_HOT_KEY_LIST	HANDLE_MALLOC	<> ;注册的热键列表
	KBD_CMD_LIST	HANDLE_MALLOC	<>	;保存链表第一项地址的变量
.Data

	KBD_CMD_IS_START DB 1 Dup(0) ;是否开启命令接受模式 当ctrl + :时开启命令接受模式5秒后关闭。
	KBD_CUR_KEY_POINT DB 1 Dup(0);当前输入的键在KBD_CMD_BUFFER的索引


	apostrophe_222 DB "'", 0

	rsquare_bracket_221 DB ']', 0
	vertical_bar_220 DB '|', 0
	lsquare_bracket_219 DB '[', 0
	
	backtick_192 DB '`', 0
	slash_191 DB '/', 0
	dot_190 DB '.', 0
	dash_189 DB '-', 0
	comma_188 DB ',', 0
	equl_187 DB '=', 0
	semicolon_186 DB ';', 0
	RALT_165 DB 'RALT',0
	LALT_164 DB 'LALT', 0
	RCTR_163 DB 'RCTR',0
	LCTR_162 DB 'LCTR',0
	RSHIFT_161 DB 'RSHIFT',0
	LSHIFT_160 DB 'LSHIFT',0
	SCROLL_145 DB 'SCROLL',0
	NLOCK_144 DB 'NLOCK',0
	F12_123 DB 'F12',0
	F11_122 DB 'F11',0
	F10_121 DB 'F10',0
	F9_120 DB 'F9',0
	F8_119 DB 'F8',0
	F7_118 DB 'F7',0
	F6_117 DB 'F6',0
	F5_116 DB 'F5',0
	F4_115 DB 'F4',0
	F3_114 DB 'F3',0
	F2_113 DB 'F2',0
	F1_112 DB 'F1',0
	DIV_111 DB 'N/', 0
	DECIMAL_110 DB 'DECIMAL',0
	N_dash_109 DB 'N-', 0
	SEPARATOR_108 DB 'SEPARATOR',0
	ADD_107 DB 'ADD',0
	N_mul_106 DB 'N*', 0
	NUMPAD9_105 DB 'NUMPAD9',0
	NUMPAD8_104 DB 'NUMPAD8',0
	NUMPAD7_103 DB 'NUMPAD7',0
	NUMPAD6_102 DB 'NUMPAD6',0
	NUMPAD5_101 DB 'NUMPAD5', 0
	NUMPAD4_100 DB 'NUMPAD4',0
	NUMPAD3_99 DB 'NUMPAD3',0
	NUMPAD2_98 DB 'NUMPAD2',0
	NUMPAD1_97 DB 'NUMPAD1',0
	NUMPAD0_96 DB 'NUMPAD0',0
	SLEEP_95 DB 'SLEEP',0
	APPS_93 DB 'APPS',0
	RWIN_92 DB 'RWIN',0
	LWIN_91 DB 'LWIN',0
		
	Z_90 DB 'Z',0
	Y_89 DB 'Y',0
	X_88 DB 'X',0
	W_87 DB 'W',0
	V_86 DB 'V',0
	U_85 DB 'U',0
	T_84 DB 'T',0
	S_83 DB 'S',0
	R_82 DB 'R',0
	Q_81 DB 'Q',0
	P_80 DB 'P',0
	O_79 DB 'O',0
	N_78 DB 'N',0
	M_77 DB 'M',0
	L_76 DB 'L',0
	K_75 DB 'K',0
	J_74 DB 'J',0
	I_73 DB 'I',0
	H_72 DB 'H',0
	G_71 DB 'G',0
	F_70 DB 'F',0
	E_69 DB 'E',0
	D_68 DB 'D',0
	C_67 DB 'C',0
	B_66 DB 'B',0
	A_65 DB 'A',0
	N9_57 DB '9',0
	N8_56 DB '8',0
	N7_55 DB '7',0
	N6_54 DB '6',0
	N5_53 DB '5',0
	N4_52 DB '4',0
	N3_51 DB '3',0
	N2_50 DB '2',0
	N1_49 DB '1',0
	N0_48 DB '0', 0

	HELP_47 DB 'HELP',0
	DELETE_46 DB 'DELETE',0
	INSERT_45 DB 'INSERT',0
	SNAPSHOT_44 DB 'SNAPSHOT',0
	EXECUTE_43 DB 'EXECUTE',0
	PRINT_42 DB 'PRINT',0
	SELECT_41 DB 'SELECT',0
	DOWN_40 DB 'DOWN',0
	RIGHT_39 DB 'RIGHT',0
	UP_38 DB 'UP',0
	LEFT_37 DB 'LEFT',0
	HOME_36 DB 'HOME',0
	END_35 DB 'END',0
	PDW_34 DB 'PDW',0
	PUP_33 DB 'PUP',0
	SPACE_32 DB ' ', 0
	ESC_27 DB 'ESC',0
	CAP_20 DB 'CAP',0
	PAUSE_19 DB 'PAUSE',0
	MENU_18 DB 'MENU',0
	CONTROL_17 DB 'CONTROL',0
	SHIFT_16 DB 'SHIFT',0
	RETURN_13 DB 'RETURN',0
	TAB_9 DB 'TAB', 0
	BACKSPACE_8 DB 'BKSPEC', 0


.Code
InitKbd Proc _hinst:QWord
	Mov _hinst, Rcx

	ECInvoke Malloc, Addr g_KeyStatusMap, MAX_KEYS * SizeOf (HANDLE_MALLOC)
	ECInvoke Malloc, Addr g_KeyMAP, MAX_KEYS * SizeOf (HANDLE_MALLOC)


	ECInvoke SetIndexMap, Addr g_KeyMAP, 192, Addr backtick_192, SizeOf backtick_192
	ECInvoke SetIndexMap, Addr g_KeyMAP, 221, Addr rsquare_bracket_221, SizeOf rsquare_bracket_221

	ECInvoke SetIndexMap, Addr g_KeyMAP, 220, Addr vertical_bar_220, SizeOf vertical_bar_220

;	ECInvoke GetMapValue, Addr g_KeyMAP, 221, Addr value, Addr valueSize
;	Lea Rax, value
;	Mov QWord Ptr [Rax], 0FFFFH
;	ECInvoke GetMapKeyFromVal, Addr g_KeyMAP, Addr value, valueSize, MAX_KEYS
;	ECInvoke ClearIndexgMap, Addr g_KeyMAP, MAX_KEYS


	ECInvoke SetIndexMap, Addr g_KeyMAP, 219, Addr lsquare_bracket_219, SizeOf lsquare_bracket_219

	ECInvoke SetIndexMap, Addr g_KeyMAP, 191, Addr slash_191, SizeOf slash_191
	ECInvoke SetIndexMap, Addr g_KeyMAP, 190, Addr dot_190, SizeOf dot_190
	ECInvoke SetIndexMap, Addr g_KeyMAP, 189, Addr dash_189, SizeOf dash_189
	ECInvoke SetIndexMap, Addr g_KeyMAP, 188, Addr comma_188, SizeOf comma_188
	ECInvoke SetIndexMap, Addr g_KeyMAP, 187, Addr equl_187, SizeOf equl_187
	ECInvoke SetIndexMap, Addr g_KeyMAP, 186, Addr semicolon_186, SizeOf semicolon_186
	ECInvoke SetIndexMap, Addr g_KeyMAP, 165, Addr RALT_165, SizeOf RALT_165
	ECInvoke SetIndexMap, Addr g_KeyMAP, 164, Addr LALT_164, SizeOf LALT_164
	ECInvoke SetIndexMap, Addr g_KeyMAP, 163, Addr RCTR_163, SizeOf RCTR_163
	ECInvoke SetIndexMap, Addr g_KeyMAP, 162, Addr LCTR_162, SizeOf LCTR_162
	ECInvoke SetIndexMap, Addr g_KeyMAP, 161, Addr RSHIFT_161, SizeOf RSHIFT_161
	ECInvoke SetIndexMap, Addr g_KeyMAP, 160, Addr LSHIFT_160, SizeOf LSHIFT_160
	ECInvoke SetIndexMap, Addr g_KeyMAP, 145, Addr SCROLL_145, SizeOf SCROLL_145
	ECInvoke SetIndexMap, Addr g_KeyMAP, 144, Addr NLOCK_144, SizeOf NLOCK_144
	ECInvoke SetIndexMap, Addr g_KeyMAP, 123, Addr F12_123, SizeOf F12_123
	ECInvoke SetIndexMap, Addr g_KeyMAP, 122, Addr F11_122, SizeOf F11_122
	ECInvoke SetIndexMap, Addr g_KeyMAP, 121, Addr F10_121, SizeOf F10_121
	ECInvoke SetIndexMap, Addr g_KeyMAP, 120, Addr F9_120, SizeOf F9_120
	ECInvoke SetIndexMap, Addr g_KeyMAP, 119, Addr F8_119, SizeOf F8_119
	ECInvoke SetIndexMap, Addr g_KeyMAP, 118, Addr F7_118, SizeOf F7_118
	ECInvoke SetIndexMap, Addr g_KeyMAP, 117, Addr F6_117, SizeOf F6_117
	ECInvoke SetIndexMap, Addr g_KeyMAP, 116, Addr F5_116, SizeOf F5_116
	ECInvoke SetIndexMap, Addr g_KeyMAP, 115, Addr F4_115, SizeOf F4_115
	ECInvoke SetIndexMap, Addr g_KeyMAP, 114, Addr F3_114, SizeOf F3_114
	ECInvoke SetIndexMap, Addr g_KeyMAP, 113, Addr F2_113, SizeOf F2_113
	ECInvoke SetIndexMap, Addr g_KeyMAP, 112, Addr F1_112, SizeOf F1_112
	ECInvoke SetIndexMap, Addr g_KeyMAP, 111, Addr DIV_111, SizeOf DIV_111
	ECInvoke SetIndexMap, Addr g_KeyMAP, 110, Addr DECIMAL_110, SizeOf DECIMAL_110
	ECInvoke SetIndexMap, Addr g_KeyMAP, 109, Addr N_dash_109, SizeOf N_dash_109
	ECInvoke SetIndexMap, Addr g_KeyMAP, 108, Addr SEPARATOR_108, SizeOf SEPARATOR_108
	ECInvoke SetIndexMap, Addr g_KeyMAP, 107, Addr ADD_107, SizeOf ADD_107
	ECInvoke SetIndexMap, Addr g_KeyMAP, 106, Addr N_mul_106, SizeOf N_mul_106
	ECInvoke SetIndexMap, Addr g_KeyMAP, 105, Addr NUMPAD9_105, SizeOf NUMPAD9_105
	ECInvoke SetIndexMap, Addr g_KeyMAP, 104, Addr NUMPAD8_104, SizeOf NUMPAD8_104


	
	ECInvoke SetIndexMap, Addr g_KeyMAP, 103, Addr NUMPAD7_103, SizeOf NUMPAD7_103
	ECInvoke SetIndexMap, Addr g_KeyMAP, 102, Addr NUMPAD6_102, SizeOf NUMPAD6_102
	ECInvoke SetIndexMap, Addr g_KeyMAP, 101, Addr NUMPAD5_101, SizeOf NUMPAD5_101
	ECInvoke SetIndexMap, Addr g_KeyMAP, 100, Addr NUMPAD4_100, SizeOf NUMPAD4_100
	ECInvoke SetIndexMap, Addr g_KeyMAP, 99, Addr NUMPAD3_99, SizeOf NUMPAD3_99
	ECInvoke SetIndexMap, Addr g_KeyMAP, 98, Addr NUMPAD2_98, SizeOf NUMPAD2_98
	ECInvoke SetIndexMap, Addr g_KeyMAP, 97, Addr NUMPAD1_97, SizeOf NUMPAD1_97
	ECInvoke SetIndexMap, Addr g_KeyMAP, 96, Addr NUMPAD0_96, SizeOf NUMPAD0_96
	ECInvoke SetIndexMap, Addr g_KeyMAP, 95, Addr SLEEP_95, SizeOf SLEEP_95
	ECInvoke SetIndexMap, Addr g_KeyMAP, 93, Addr APPS_93, SizeOf APPS_93
	ECInvoke SetIndexMap, Addr g_KeyMAP, 92, Addr RWIN_92, SizeOf RWIN_92
	ECInvoke SetIndexMap, Addr g_KeyMAP, 91, Addr LWIN_91, SizeOf LWIN_91
	ECInvoke SetIndexMap, Addr g_KeyMAP, 90, Addr Z_90, SizeOf Z_90
	ECInvoke SetIndexMap, Addr g_KeyMAP, 89, Addr Y_89, SizeOf Y_89
	ECInvoke SetIndexMap, Addr g_KeyMAP, 88, Addr X_88, SizeOf X_88
	ECInvoke SetIndexMap, Addr g_KeyMAP, 87, Addr W_87, SizeOf W_87
	ECInvoke SetIndexMap, Addr g_KeyMAP, 86, Addr V_86, SizeOf V_86
	ECInvoke SetIndexMap, Addr g_KeyMAP, 85, Addr U_85, SizeOf U_85
	ECInvoke SetIndexMap, Addr g_KeyMAP, 84, Addr T_84, SizeOf T_84
	ECInvoke SetIndexMap, Addr g_KeyMAP, 83, Addr S_83, SizeOf S_83
	ECInvoke SetIndexMap, Addr g_KeyMAP, 82, Addr R_82, SizeOf R_82
	ECInvoke SetIndexMap, Addr g_KeyMAP, 81, Addr Q_81, SizeOf Q_81
	ECInvoke SetIndexMap, Addr g_KeyMAP, 80, Addr P_80, SizeOf P_80
	ECInvoke SetIndexMap, Addr g_KeyMAP, 79, Addr O_79, SizeOf O_79
	ECInvoke SetIndexMap, Addr g_KeyMAP, 78, Addr N_78, SizeOf N_78
	ECInvoke SetIndexMap, Addr g_KeyMAP, 77, Addr M_77, SizeOf M_77
	ECInvoke SetIndexMap, Addr g_KeyMAP, 76, Addr L_76, SizeOf L_76
	ECInvoke SetIndexMap, Addr g_KeyMAP, 75, Addr K_75, SizeOf K_75
	ECInvoke SetIndexMap, Addr g_KeyMAP, 74, Addr J_74, SizeOf J_74
	ECInvoke SetIndexMap, Addr g_KeyMAP, 73, Addr I_73, SizeOf I_73
	ECInvoke SetIndexMap, Addr g_KeyMAP, 72, Addr H_72, SizeOf H_72
	ECInvoke SetIndexMap, Addr g_KeyMAP, 71, Addr G_71, SizeOf G_71
	ECInvoke SetIndexMap, Addr g_KeyMAP, 70, Addr F_70, SizeOf F_70
	ECInvoke SetIndexMap, Addr g_KeyMAP, 69, Addr E_69, SizeOf E_69
	ECInvoke SetIndexMap, Addr g_KeyMAP, 68, Addr D_68, SizeOf D_68
	ECInvoke SetIndexMap, Addr g_KeyMAP, 67, Addr C_67, SizeOf C_67
	ECInvoke SetIndexMap, Addr g_KeyMAP, 66, Addr B_66, SizeOf B_66
	ECInvoke SetIndexMap, Addr g_KeyMAP, 65, Addr A_65, SizeOf A_65
	ECInvoke SetIndexMap, Addr g_KeyMAP, 57, Addr N9_57, SizeOf N9_57
	ECInvoke SetIndexMap, Addr g_KeyMAP, 56, Addr N8_56, SizeOf N8_56
	ECInvoke SetIndexMap, Addr g_KeyMAP, 55, Addr N7_55, SizeOf N7_55
	ECInvoke SetIndexMap, Addr g_KeyMAP, 54, Addr N6_54, SizeOf N6_54
	ECInvoke SetIndexMap, Addr g_KeyMAP, 53, Addr N5_53, SizeOf N5_53
	ECInvoke SetIndexMap, Addr g_KeyMAP, 52, Addr N4_52, SizeOf N4_52
	ECInvoke SetIndexMap, Addr g_KeyMAP, 51, Addr N3_51, SizeOf N3_51
	ECInvoke SetIndexMap, Addr g_KeyMAP, 50, Addr N2_50, SizeOf N2_50
	ECInvoke SetIndexMap, Addr g_KeyMAP, 49, Addr N1_49, SizeOf N1_49
	ECInvoke SetIndexMap, Addr g_KeyMAP, 48, Addr N0_48, SizeOf N0_48
	ECInvoke SetIndexMap, Addr g_KeyMAP, 47, Addr HELP_47, SizeOf HELP_47
	ECInvoke SetIndexMap, Addr g_KeyMAP, 46, Addr DELETE_46, SizeOf DELETE_46
	ECInvoke SetIndexMap, Addr g_KeyMAP, 45, Addr INSERT_45, SizeOf INSERT_45
	ECInvoke SetIndexMap, Addr g_KeyMAP, 44, Addr SNAPSHOT_44, SizeOf SNAPSHOT_44
	ECInvoke SetIndexMap, Addr g_KeyMAP, 43, Addr EXECUTE_43, SizeOf EXECUTE_43
	ECInvoke SetIndexMap, Addr g_KeyMAP, 42, Addr PRINT_42, SizeOf PRINT_42
	ECInvoke SetIndexMap, Addr g_KeyMAP, 41, Addr SELECT_41, SizeOf SELECT_41
	ECInvoke SetIndexMap, Addr g_KeyMAP, 40, Addr DOWN_40, SizeOf DOWN_40
	ECInvoke SetIndexMap, Addr g_KeyMAP, 39, Addr RIGHT_39, SizeOf RIGHT_39
	ECInvoke SetIndexMap, Addr g_KeyMAP, 38, Addr UP_38, SizeOf UP_38
	ECInvoke SetIndexMap, Addr g_KeyMAP, 37, Addr LEFT_37, SizeOf LEFT_37
	ECInvoke SetIndexMap, Addr g_KeyMAP, 36, Addr HOME_36, SizeOf HOME_36
	ECInvoke SetIndexMap, Addr g_KeyMAP, 35, Addr END_35, SizeOf END_35
	ECInvoke SetIndexMap, Addr g_KeyMAP, 34, Addr PDW_34, SizeOf PDW_34
	ECInvoke SetIndexMap, Addr g_KeyMAP, 33, Addr PUP_33, SizeOf PUP_33
	ECInvoke SetIndexMap, Addr g_KeyMAP, 32, Addr SPACE_32, SizeOf SPACE_32
	ECInvoke SetIndexMap, Addr g_KeyMAP, 27, Addr ESC_27, SizeOf ESC_27
	ECInvoke SetIndexMap, Addr g_KeyMAP, 20, Addr CAP_20, SizeOf CAP_20
	ECInvoke SetIndexMap, Addr g_KeyMAP, 19, Addr PAUSE_19, SizeOf PAUSE_19
	ECInvoke SetIndexMap, Addr g_KeyMAP, 18, Addr MENU_18, SizeOf MENU_18
	ECInvoke SetIndexMap, Addr g_KeyMAP, 17, Addr CONTROL_17, SizeOf CONTROL_17
	ECInvoke SetIndexMap, Addr g_KeyMAP, 16, Addr SHIFT_16, SizeOf SHIFT_16
	ECInvoke SetIndexMap, Addr g_KeyMAP, 13, Addr RETURN_13, SizeOf RETURN_13
	ECInvoke SetIndexMap, Addr g_KeyMAP, 9, Addr TAB_9, SizeOf TAB_9
	ECInvoke SetIndexMap, Addr g_KeyMAP, 8, Addr BACKSPACE_8, SizeOf BACKSPACE_8

	;ECInvoke InsertDLAtEnd, Addr KBD_CMD_LIST, Addr txta, 2
Comment #
	ECInvoke InsertDLAtEnd, Addr KBD_CMD_LIST, Addr txtb, 2

	ECInvoke InsertDLAtBegin, Addr KBD_CMD_LIST, Addr txtc, 2

	ECInvoke InsertDLAtBegin, Addr KBD_CMD_LIST, Addr txtd, 2


	ECInvoke SizeOfDLLink, Addr KBD_CMD_LIST
	ECInvoke FindDLNode, Addr KBD_CMD_LIST, Addr txtb, 2

	ECInvoke InsertDLAtPos, Addr KBD_CMD_LIST, Addr txte, 2, 2
	#

;	ECInvoke DestoryDLLink, Addr KBD_CMD_LIST
;	Lea Rax, KBD_CMD_LIST
	;设置hook，启动hook脱钩保护

	ECInvoke SetWindowsHookEx, WH_KEYBOARD_LL, KdbHotHookProcdu, _hinst, NULL
	Mov hKdbHotHook, Rax
	Ret
InitKbd EndP

UninitKbd Proc

	ECInvoke ClearIndexgMap, Addr g_KeyMAP, MAX_KEYS
	ECInvoke Free, Addr g_KeyMAP
	ECInvoke UnhookWindowsHookEx, hKdbHotHook
	Ret
UninitKbd EndP

;LCTRL + ;->semicolon_186,id
SetHotKeys Proc pKeys:QWord, valLen:QWord

	Test Rcx, Rcx
	Jz exit
		Mov pKeys, Rcx
		Mov valLen, Rdx
		;ECInvoke lstrlen, Rcx
	;	Mov keysLen, Rax
		;Inc keysLen
Comment #
		Lea Rax, KBD_HOT_KEY_LIST
		Mov Rax, [Rax]
		Test Rax, Rax	;是否第一次使用
		Jne @F
			ECInvoke CreateDLNode, Addr KBD_HOT_KEY_LIST, pKeys, keysLen
		Jmp exit
@@:#

			ECInvoke InsertDLAtBegin, Addr KBD_HOT_KEY_LIST, pKeys, valLen


exit:
	Ret
SetHotKeys EndP

GetKeyText Proc keyCode:QWord, pOutValue:QWord, pOutSize:QWord
	Mov keyCode, Rcx
	Mov pOutValue, Rdx
	Mov pOutSize, R8
	ECInvoke GetIndexMapValue, Addr g_KeyMAP, keyCode, pOutValue, pOutSize
	Ret
GetKeyText EndP


;返回热键链表的pnext节点
GetNextKeys Proc pNode:QWord, pOutKeys:QWord, pOutCount:QWord
	Local pNextNode:QWord
	Local pOutValue[80]:DB
	Local keys[10]:DB
	Local sendmsgId:DB
	Local pOutSize:QWord
	Local splitPointers[10]:QWord
	Local splitCount:QWord
	Mov pNode, Rcx
	Mov pOutKeys, Rdx
	Mov pOutCount, R8
	Mov splitCount, 0


	ECInvoke GetDLNodeValue, pNode, Addr pOutValue, Addr pOutSize
;按键字符串解析成键盘键码
	;找到所有的+号
	Lea Rax, splitPointers
	Lea Rcx, pOutValue
	Mov QWord Ptr [Rax], Rcx



	Xor Ecx, Ecx
find:;先把+号 填充 0 ，计算有多少个分割
	Lea Rax, pOutValue
	Mov Dl, [Rax + Rcx]
	Cmp Dl, '+'
	Jnz @F
		Inc splitCount
		Push Rcx
		Lea Rax, [Rax + Rcx]
		Mov Byte Ptr [Rax], 0;+ 号填0
		Inc Rax
		Lea Rdx, splitPointers
		Mov R8, splitCount
		Mov [Rdx + R8 * 8], Rax


@@:
	Inc Ecx
	Cmp pOutSize, Rcx
	Jne find

;长度给外部变量
	Mov Rax, splitCount
	Mov Rcx, pOutCount;
	Inc Rax
	Mov [Rcx], Rax
	Xor Eax, Eax

	
;根据分割个数解析成键盘扫描码
loopplus:

	Push Rax
	Lea Rdx, splitPointers
	Mov Rcx, [Rdx + Rax * 8]
	Push Rcx
	ECInvoke lstrlen, Rcx
	Inc Rax;根据字节来算字符串最后有0.所以+1
	Pop Rcx

	ECInvoke GetIndexMapKeyFromVal, Addr g_KeyMAP, Rcx, Rax, MAX_KEYS

	Cmp Rax, -1;-1等于没找到
	Pop R8
	Jz @F
		Mov Rcx, pOutKeys
		Mov [Rcx + R8], Al
@@:
	Mov Rax, R8
	Inc Rax
Cmp splitCount, Rax
Jge loopplus
	;eCInvoke strstr
	ECInvoke GetNextDLNode, pNode
	Mov pNextNode, Rax

	Lea Rcx, pOutValue
	Mov Rax, pOutSize
	Dec Rax
	Mov Cl, [Rcx + Rax];llkeyid
	And Ecx, 0FFH
	Mov Rax, pNextNode

	Ret
GetNextKeys EndP


KdbHotHookProcdu Proc nCode:QWord, wParam:QWord, lParam:QWord
	Local key:QWord
	Local llkID:QWord
	Local txt:DWord
	Local val:QWord
	Local hotKeys[10]:DB
	Local hotKeyCount:QWord
	Local indexKey:QWord
	Local hitKeys:QWord
	Local pNextNode:QWord
	Local pOutValue[10]:DB
	Local pOutSize:QWord
	Local result:QWord
	Mov nCode, Rcx
	Mov wParam, Rdx
	Mov lParam, R8
	Mov indexKey, 0


	Mov Rcx, lParam
	Mov Eax, [Rcx + KBDLLHOOKSTRUCT.vkCode]
	And Eax, 0FFH
	Mov key, Rax

	Cmp nCode, HC_ACTION
	Jne @F
		Xor  Eax,Eax
		Mov Ax, Word Ptr wParam
		Cmp Ax, WM_KEYDOWN
		Je kdown
		Cmp Ax, WM_SYSKEYDOWN
		Jne @F
kdown:
		Mov val, LLKEY_DOWN
		ECInvoke SetIndexMap, Addr g_KeyStatusMap, key, Addr val, 2
		;通知主窗口按了什么键
		ECInvoke SendMessage, G_MAIN_WINDOW, WM_LLKBD_MSG, -1, key
		Mov result, Rax
		Test Al, Al
		Jz cmpk
		Ret
cmpk:

			Lea Rax, KBD_HOT_KEY_LIST
			Mov pNextNode, Rax
loopdl:

			ECInvoke GetNextKeys, pNextNode, Addr hotKeys, Addr hotKeyCount
			Mov llkID, Rcx
			Mov pNextNode, Rax
			;比较热键,命中
			Mov hitKeys, 1
cmpkey:
				Mov pOutValue, 0
				Lea Rax, hotKeys
				Mov Rcx, indexKey

				Mov Cl, [Rax + Rcx]
				And Ecx, 0FFH
				Mov val, Rcx
				ECInvoke GetIndexMapValue, Addr g_KeyStatusMap, val, Addr pOutValue, Addr pOutSize
				Lea Rax, pOutValue
				Mov Rax, [Rax]
				Cmp Al, LLKEY_DOWN
				Jz hit
				Mov hitKeys, 0
				Jmp unhit
hit:

				Inc indexKey
				Mov Rax, hotKeyCount
			Cmp indexKey, Rax
			Jb cmpkey

			ECInvoke SendMessage, G_MAIN_WINDOW, WM_LLKBD_MSG, llkID, 0

			Mov Rax, 1
			Ret
unhit:
			ECInvoke IsDLNodeEqual, pNextNode, Addr KBD_HOT_KEY_LIST
			Cmp Rax, 1
			Jnz loopdl
			;发送按键给窗口



@@:
	Mov Ax, Word Ptr wParam
	Cmp Ax, WM_KEYUP
	Jne @F
		Mov val, LLKEY_UP
		ECInvoke SetIndexMap, Addr g_KeyStatusMap, key, Addr val, 2

@@:ECInvoke CallNextHookEx, hKdbHotHook, nCode, wParam, lParam

	Ret
KdbHotHookProcdu EndP

