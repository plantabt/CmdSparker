;EasyCodeName=Config,1
.Const

.Data?

.Data
	slash DB '\', 0
	cfg_filename    DB  "Config.ini", 0  ; INI文件名
	log_filename    DB  "log.txt", 0  ; INI文件名

	CFG_CMD_PAIR DB 'CMD_PAIR', 0
	CFG_CMD_PAIR_ITEM DB 'CMD_PAIR_%d', 0
	CMD_PAIR_EXT_READ_KEY DB 'exn', 0
	CMD_PAIR_LUN_READ_KEY DB 'lun', 0

	CFG_BTN_ITEM_CMD_SECTION DB 'ITEM_CMDS', 0
	CFG_BTN_ITEM_CMDINFO DB 'ITEM_CMD_INFO_P_%d_%d', 0
	;CFG_ITEM_VALUE_FORMAT DB 'hk=%s;bt%dag1=%s;bt%dag2=%s;bt%dag3=%s;bt%dag4=%s;bt%dtp=%d;bt%dcmd0=%s;', 0
	BTN_ARGS_FORMAT DB 'bt%darg=%s;', 0
	;BTN_ARGS_FORMAT DB 'bt%darg%d=%s;', 0
	BTN_CMDLINE_FORMAT DB 'bt%dcmdl=%s;', 0

	BTN_CMDLINE_BWAIT_FORMAT DB 'bt%dbwait=%d;', 0
	BTN_CMDLINE_BADMIN_FORMAT DB 'bt%dbadmin=%d;', 0
	BTN_CMDLINE_BMANUAL_FORMAT DB 'bt%dbmanual=%d;', 0
	BTN_CMDLINE_SHUTDOWN_FORMAT DB 'bt%dstdown=%d', 0
	BTN_CMDLINE_RESTART_FORMAT DB 'bt%drert=%d', 0

	BTN_CMDLINE_TYPE_FORMAT DB 'bt%dcmdt=%d;', 0
	ITEM_CMDNAME_FORMAT DB 'cmdn=%s;', 0

	;BTN_ARGS_READ_KEY DB 'bt%darg%d', 0
	BTN_ARGS_READ_KEY DB 'bt%darg', 0
	BTN_CMDLINE_READ_KEY DB 'bt%dcmdl', 0
	ITEM_CMDNAME_READ_KEY DB 'cmdn', 0

	BTN_CMDLINE_BWAIT_READ_KEY DB 'bt%dbwait', 0
	BTN_CMDLINE_BADMIN_READ_KEY DB 'bt%dbadmin', 0
	BTN_CMDLINE_BMANUAL_READ_KEY DB 'bt%dbmanual', 0
	BTN_CMDLINE_SHUTDOWN_READ_KEY DB 'bt%dstdown', 0
	BTN_CMDLINE_RESTART_READ_KEY DB 'bt%drert', 0

	KEY_FIRST_RUN DB 'FIRST_RUN', 0
	KEY_RUNON_STARTUP DB 'RUNON_STARTUP', 0
	SECTION_SYSTEM DB 'SYSTEM', 0

	BTN_CMDLINE_TYPE_READ_KEY DB 'bt%dcmdt', 0
	log_section DB 'LOGS', 0
.Code

GetCurrentCFGPath Proc outPath:QWord, outSize:QWord
	Local pCurrentDir:QWord
	Mov outPath, Rcx
	Mov outSize, Rdx

	ECInvoke GetCurrentDirEx
	Mov pCurrentDir, Rax
	ECInvoke lstrcat, outPath, pCurrentDir
	ECInvoke lstrcat, outPath, Addr cfg_filename
	ECInvoke DelStr, pCurrentDir
	Ret
GetCurrentCFGPath EndP
GetCurrentLOGPath Proc outPath:QWord, outSize:QWord
	Local pCurrentDir:QWord
	Mov outPath, Rcx
	Mov outSize, Rdx
	ECInvoke GetCurrentDirEx
	Mov pCurrentDir, Rax
	ECInvoke lstrcat, outPath, pCurrentDir
	ECInvoke lstrcat, outPath, Addr log_filename
	ECInvoke DelStr, pCurrentDir
	Ret
GetCurrentLOGPath EndP

GetPofValue Proc pKeys:QWord, keysLen:QWord, pKeyName:QWord, keyNameLen:QWord
	Local pTmp:QWord
	Local looprep:QWord

	Mov pKeys, Rcx
	Mov keysLen, Rdx
	Mov pKeyName, R8
	Mov keyNameLen, R9

	Mov pTmp, Rcx

	Mov looprep, 0
_findkey:
	Mov Rcx, pTmp
	Cmp Word Ptr [Rcx], 0;结尾是00
	Je exit
	;找key

	ECInvoke StrStr, Rcx, pKeyName
	Test Eax, Eax
	Jnz _found
	;跳到下一个
	ECInvoke lstrlen, pTmp
	Inc Rax
	Add Rax, pTmp
	Mov pTmp, Rax
	Cmp Word Ptr [Rax], 0
	Je exit
	Jmp _findkey
_found:

	Mov pTmp, Rax
	Add Rax, keyNameLen
	Cmp Byte Ptr [Rax], '='
	Jnz @F
	Inc Rax
	Cmp Byte Ptr [Rax], 0
	Jne _is_val
	;如果是空值rax=0
	Xor Eax, Eax

_is_val:


	Ret
@@:
	Inc looprep
	Mov Rax, looprep
	Cmp Rax, keysLen
	Jb _findkey
exit:

	Xor Eax, Eax
	Ret
GetPofValue EndP


GetPofKey Proc pKeys:QWord, keysLen:QWord, pKeyName:QWord, keyNameLen:QWord
	Local pTmp:QWord
	Local looprep:QWord

	Mov pKeys, Rcx
	Mov keysLen, Rdx
	Mov pKeyName, R8
	Mov keyNameLen, R9

	Mov pTmp, Rcx

	Mov looprep, 0
_findkey:
	Mov Rcx, pTmp
	Cmp Word Ptr [Rcx], 0;结尾是00
	Je exit
	;找key

	ECInvoke StrStr, Rcx, pKeyName
	Test Eax, Eax
	Jnz _found
	;跳到下一个
	ECInvoke lstrlen, pTmp
	Inc Rax
	Add Rax, pTmp
	Mov pTmp, Rax
	Cmp Word Ptr [Rax], 0
	Je exit
	Jmp _findkey
_found:

	Mov pTmp, Rax
	Ret
@@:
	Inc looprep
	Mov Rax, looprep
	Cmp Rax, keysLen
	Jb _findkey
exit:

	Xor Eax, Eax
	Ret
GetPofKey EndP
;k=v; 基本格式所有k=v最后必须;结束
GetKeyValue Proc pKeys:QWord, pKeyName:QWord, pOutBuff:QWord
	Local pStr:QWord
	Local pTmp:QWord
	Local keysLen:QWord
	Local keyNameLen:QWord
	Local looprep:QWord
	Mov pKeys, Rcx
	Mov pKeyName, Rdx
	Mov pOutBuff, R8
	ECInvoke lstrlen, pKeyName
	Mov keyNameLen, Rax

	ECInvoke lstrlen, pKeys
	Add Eax, 4
	Mov keysLen, Rax
	Mov Rdx, Rax

	ECInvoke GlobalAlloc, GPTR, Rdx
	Mov pStr, Rax
	Mov pTmp, Rax
	ECInvoke ZeroMemory, pStr, keysLen
	ECInvoke lstrcpy, pStr, pKeys

	ECInvoke ReplaceChr, pStr, ';', 0
	ECInvoke GetPofValue, pStr, keysLen, pKeyName, keyNameLen

	Test Eax, Eax
	Jz _exit
	ECInvoke lstrcpy, pOutBuff, Rax

_exit:
	ECInvoke GlobalFree, pStr
	Ret
GetKeyValue EndP

SetKeyValue Proc pKeys:QWord, pKeyName:QWord, pValue:QWord
	Local pStr:QWord
	Local pTmp:QWord
	Local pNewstr:QWord
	Local pVal:QWord
	Local keysLen:QWord
	Local keyNameLen:QWord
	Local valueLen:QWord
	Local oldvalLen:QWord
	Local looprep:QWord
	Mov pKeys, Rcx
	Mov pKeyName, Rdx
	Mov pValue, R8

	ECInvoke lstrlen, pValue
	Mov valueLen, Rax

	ECInvoke lstrlen, pKeyName
	Mov keyNameLen, Rax

	Mov Rcx, pKeys

	ECInvoke lstrlen, [Rcx]
	Add Eax, 4
	Add Rax, valueLen
	Mov keysLen, Rax
	Mov Rdx, Rax


	Mov Rcx, pKeys
	ECInvoke NewStr, [Rcx], keysLen
	Mov pStr, Rax
	Mov pTmp, Rax

	ECInvoke NewStr, 0, keysLen
	Mov pNewstr, Rax



	ECInvoke ReplaceChr, pStr, ';', 0
	ECInvoke GetPofValue, pStr, keysLen, pKeyName, keyNameLen

	Test Eax, Eax
	Jz _exit
		Mov pTmp, Rax
		Sub Rax, pStr

		Mov Rcx, pNewstr
		Add Rax, Rcx
		Mov pVal, Rax

		ECInvoke lstrlen, pTmp
		Mov oldvalLen, Rax
		;指向当前value之后的字符串
		Mov Rcx, pTmp
		Add Rcx, Rax
		Mov pTmp, Rcx

		;拷贝前半部分
		Mov R8, pVal
		Sub R8, pNewstr

		ECInvoke memcpy, pNewstr, pStr, R8
		;拷贝value
		ECInvoke memcpy, pVal, pValue, valueLen
		;拷贝后半部分

		Mov Rcx, pVal
		Add Rcx, valueLen

		Mov Rax, pTmp
		Sub Rax, pStr
		Mov R8, keysLen
		Sub R8, Rax
		ECInvoke memcpy, Rcx, pTmp, R8
		;把0填成;号
		Mov Rax, pNewstr
_rep0:
		Cmp Byte Ptr [Rax], 0
		Jne @F
			Mov Byte Ptr [Rax], ';'
@@:
		Inc Rax
		Cmp Word Ptr [Rax], 0
		Jne _rep0
		Mov Byte Ptr [Rax], ';'
		Mov Rcx, pKeys

		ECInvoke DelStr, [Rcx]
		ECInvoke DelStr, pStr
		Mov Rax, pKeys
		Mov Rcx, pNewstr
		Mov QWord Ptr [Rax], Rcx
		Mov Rax, 1
		Ret
_exit:
	Xor Eax, Eax
	Ret
SetKeyValue EndP


ReadCfgString Proc section:QWord, key:QWord, outBuffer:QWord, szofBuff:QWord
	Local cfgPath[MAX_PATH]:Byte
	Mov section, Rcx
	Mov key, Rdx
	Mov outBuffer, R8
	Mov szofBuff, R9
	ECInvoke ZeroMemory, Addr cfgPath, SizeOf cfgPath
	ECInvoke GetCurrentCFGPath, Addr cfgPath, SizeOf cfgPath
    ECInvoke GetPrivateProfileString, section, key, NULL, outBuffer, szofBuff, Addr cfgPath
    Ret
ReadCfgString EndP

ReadCfgInteger Proc section:QWord, key:QWord
	Local outBuffer[MAX_PATH]:Byte
	Mov section, Rcx
	Mov key, Rdx
	ECInvoke ZeroMemory, Addr outBuffer, SizeOf outBuffer
	ECInvoke ReadCfgString, section, key, Addr outBuffer, SizeOf outBuffer
	ECInvoke StrToInt, outBuffer
    Ret
ReadCfgInteger EndP


WriteCfgValue Proc section:QWord, key:QWord, inBuffer:QWord
	Local cfgPath[MAX_PATH]:Byte
	Mov section, Rcx
	Mov key, Rdx
	Mov inBuffer, R8
	ECInvoke ZeroMemory, Addr cfgPath, SizeOf cfgPath
	ECInvoke GetCurrentCFGPath, Addr cfgPath, SizeOf cfgPath
    ; 向 INI 文件中写入值
    ECInvoke WritePrivateProfileString, section, key, inBuffer, Addr cfgPath

    Ret
WriteCfgValue EndP


ReadAllCmdItemCfg Proc hRoot:QWord
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

ReadAllCmdItemCfg EndP

ReadAutoCmdsList Proc pDbList:QWord
	Local strKey[50]:DB
	Local pReadVal:QWord
	Local lSize:QWord
	Local loopItem:QWord
	Mov pDbList, Rcx

	ECInvoke NewStr, 0, 1024
	Mov pReadVal, Rax
	Mov loopItem, 0
loopRed:

	ECInvoke ZeroMemory, Addr strKey, 50
	ECInvoke FormatStr, Addr strKey, CTXT("AUTO_CMD%d"), loopItem, 0, 0, 0, 0
	ECInvoke ReadCfgString, CTXT("AUTO_CMDS"), Addr strKey, pReadVal, 1024
	ECInvoke lstrlen, pReadVal
	Cmp Rax, 0
	Je exit
	Mov lSize, Rax
	ECInvoke InsertDLAtBegin, pDbList, pReadVal, lSize
	Inc loopItem
	Jmp loopRed
exit:
	ECInvoke DelStr, pReadVal
	Ret
ReadAutoCmdsList EndP


SaveAllCmdItemInfo Proc hRoot:QWord
	Local hPage:HWND
	Local hItem:HWND
	Local hBtn:HWND
	Local pBtncmdInfo:QWord
	Local strKey[100]:Byte
	Local writeVal[MAX_CMD_ITEM_BTN * 2]:BTN_CMD_INFO
	Local onValue[2]:BTN_CMD_INFO
	Local pTmpStr[MAX_PATH]:Word
	Local loopPage:QWord
	Local loopItem:QWord
	Local loopBtn:QWord
	Mov hRoot, Rcx


	Mov loopPage, 0
_loop_page:
	Mov Rdx, CTRL_PAGE_ID_BASE
	Add Rdx, loopPage
	ECInvoke GetDlgItem, hRoot, Rdx
	Mov hPage, Rax

	ECInvoke ZeroMemory, Addr writeVal, SizeOf writeVal
	Mov loopItem, 0
	_loop_item:
	
		Mov Rdx, loopItem
		Add Rdx, CTRL_ITEM_ID_BASE
		ECInvoke GetDlgItem, hPage, Rdx
		Mov hItem, Rax
	
			Mov loopBtn, 0
			Lea Rax, writeVal
			Mov QWord Ptr [Rax], 0
		_loop_btn:
			Mov Rdx, loopBtn
			Add Rdx, CMD_BTN_ID_BASE
			ECInvoke GetDlgItem, hItem, Rdx
			Mov hBtn, Rax

			ECInvoke GetWindowLongPtr, hBtn, GWL_USERDATA
			Mov pBtncmdInfo, Rax

			;格式化按钮命令
			;清空字符串
			ECInvoke ZeroMemory, Addr onValue, SizeOf onValue

			;格式化参数
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdArg]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_ARGS_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bWait
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbWait]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BWAIT_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bAdmin
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbAdmin]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BADMIN_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bManual
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbManual]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BMANUAL_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bShutdown
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbShutdown]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_SHUTDOWN_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bManual
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbRestart]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_RESTART_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr
Comment #
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdArg1]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_ARGS_FORMAT, loopBtn, 1, Rax, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdArg2]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_ARGS_FORMAT, loopBtn, 2, Rax, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdArg3]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_ARGS_FORMAT, loopBtn, 3, Rax, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr
#

			;格式化命令类型
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdType]
			Mov Rax, [Rax]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_TYPE_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;格式化路径/命令
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdLine]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr



			;ECInvoke FormatStr, Addr onValue, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0
			;合并到一条写入缓冲
			ECInvoke lstrcat, Addr writeVal, Addr onValue
			Inc loopBtn
			Mov Rax, loopBtn
			Cmp Rax, MAX_CMD_ITEM_BTN
			Jb _loop_btn

		;格式化热键命令名

		ECInvoke GetDlgItemText, hItem, CMD_CTRL_LABEL, Addr strKey, SizeOf strKey
		ECInvoke FormatStr, Addr pTmpStr, Addr ITEM_CMDNAME_FORMAT, Addr strKey, 0, 0, 0, 0
		ECInvoke lstrcat, Addr writeVal, Addr pTmpStr

		;保存到配置

		ECInvoke FormatStr, Addr strKey, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0

		ECInvoke WriteCfgValue, Addr CFG_BTN_ITEM_CMD_SECTION, Addr strKey, Addr writeVal

		Inc loopItem
		Mov Rax, loopItem
		Cmp Rax, MAX_CMD_ITEM
		Jb _loop_item

	

	Inc loopPage
	Mov Rax, loopPage
	Cmp Rax, MAX_CMD_PAGE
	Jb _loop_page

	Ret
SaveAllCmdItemInfo EndP

ReadAutoCmds Proc
	Local pBtncmdInfo:QWord
	Local strKey[100]:Byte
	Local pWriteVal:QWord ;[MAX_CMD_ITEM_BTN * 2]:BTN_CMD_INFO
	Local onValue[2]:BTN_CMD_INFO
	Local pTmpStr[MAX_PATH]:Word
	Local loopItem:QWord
	Local loopBtn:QWord
	Local loopPage:QWord


	Local dbList:HANDLE_MALLOC
	Local ptmpLink:QWord;HANDLE_MALLOC
	Local tmpLink:HANDLE_MALLOC
	Local dbLinkList:HANDLE_MALLOC
	Local isStartup:QWord
	Local rcClient:RECT

	Local cmdinfo:BTN_CMD_INFO
	Local pOutValue:QWord
	Local pCmdskValue:QWord
	Local pOutSize:QWord
	Local pNextNode:QWord
	Local pExcPath:QWord
	Local pArgs:QWord
	Local pWorkDir:QWord
	Local pValue:QWord
	Local kname[40]:DB
	Local keyIdx:QWord
	Local pCmdsNode:QWord
	Local cmdName[40]:DB
	Local oldcmdName[40]:DB
	Local hMap:QWord
	Local bWrite:QWord
	Local pDesktopPath:QWord
	Local destinationPath:QWord

	ECInvoke ZeroMemory, Addr oldcmdName, SizeOf oldcmdName
	ECInvoke ZeroMemory, Addr cmdName, SizeOf cmdName
	ECInvoke ZeroMemory, Addr kname, SizeOf kname
Comment #
	ECInvoke NewStr, 0, 1024
	Mov destinationPath, Rax
	ECInvoke ZeroMemory, destinationPath, 1024

	ECInvoke NewStr, 0, 1024
	Mov pDesktopPath, Rax
	ECInvoke ZeroMemory, pDesktopPath, 1024

	ECInvoke SHGetFolderPath, NULL, CSIDL_DESKTOP, NULL, 0, pDesktopPath
	ECInvoke lstrcat, pDesktopPath, CTXT("\bk")
	ECInvoke CreateDirectory, pDesktopPath, NULL
#
	ECInvoke GlobalAlloc, GPTR, MAX_CMD_ITEM_BTN * 2 * SizeOf (BTN_CMD_INFO)
	Mov pWriteVal, Rax
	ECInvoke ZeroMemory, pWriteVal, MAX_CMD_ITEM_BTN * 2 * SizeOf (BTN_CMD_INFO)

	
	ECInvoke GlobalAlloc, GPTR, 1024* 4
	Mov pValue, Rax
	ECInvoke ZeroMemory, pValue, 1024* 4

	ECInvoke CreateMap

	Mov hMap, Rax

	Mov bWrite, FALSE
	ECInvoke ZeroMemory, Addr dbList, SizeOf HANDLE_MALLOC
	ECInvoke ZeroMemory, Addr tmpLink, SizeOf HANDLE_MALLOC


	ECInvoke NewStr, 0, MAX_PATH * 2
	Mov pOutValue, Rax

	ECInvoke NewStr, 0, MAX_PATH
	Mov pExcPath, Rax
	ECInvoke NewStr, 0, MAX_PATH
	Mov pArgs, Rax
	ECInvoke NewStr, 0, MAX_PATH
	Mov pWorkDir, Rax

;ECInvoke WriteLog, CTXT("aaa2"), 1
	ECInvoke GetDesktopLnkList, Addr dbList
	;没有列表则退出
	Lea Rax, dbList
	Mov Rcx, [Rax]
	Test Rcx, Rcx
	Jnz @F
	Ret
@@:

	Mov pNextNode, Rax
loopdl:
	ECInvoke ZeroMemory, pOutValue, MAX_PATH * 2

	ECInvoke GetDLNodeValue, pNextNode, pOutValue, Addr pOutSize
Comment #
    ; 文件的原始路径和目标路径
    ECInvoke ZeroMemory, destinationPath, 1024
	ECInvoke StrRStr, pOutValue, 0, Addr slash
	ECInvoke FormatStr, destinationPath, CTXT("%s%s"), pDesktopPath, Rax, 0, 0, 0
     ;移动文件
    ECInvoke MoveFile, pOutValue, destinationPath
    ;ECInvoke CopyFile, pOutValue, destinationPath, FALSE
#

	ECInvoke ZeroMemory, Addr cmdName, SizeOf cmdName
	ECInvoke IsLinkInCmdList, pOutValue, Addr cmdName

	Test Rax, Rax
	Jz nextNode
	Push Rax

;	ECInvoke lstrlen, pOutValue
	ECInvoke GetMapValue, hMap, Addr cmdName, Addr tmpLink, SizeOf HANDLE_MALLOC
	Test Eax, Eax
	Jnz hasmap
		ECInvoke GlobalAlloc, GPTR, SizeOf HANDLE_MALLOC
		Push Rax
		ECInvoke InsertDLAtBegin, Rax, pOutValue, pOutSize
		Pop R8
		Push R8
		ECInvoke PutMapValue, hMap, Addr cmdName, R8, SizeOf HANDLE_MALLOC
		Pop Rdx
		ECInvoke memcpy, Addr tmpLink, Rdx, SizeOf HANDLE_MALLOC

		;Mov ptmpLink, Rdx
hasmap:


;	ECInvoke WriteLog, pOutValue, 1
	Pop Rax
	Cmp Rax, 1;lnk,url
	Jnz @F


	ECInvoke ZeroMemory, Addr cmdinfo, SizeOf BTN_CMD_INFO
	Mov cmdinfo.cmdbManual, TRUE
	Mov Rcx, pOutValue
;	Test Rcx, Rcx
;	Jz @F
	;ECInvoke GetLnkPathInfo,

;	ECInvoke GetLnkPathInfo, pOutValue, pExcPath, pArgs, 0
	ECInvoke memcpy, Addr cmdinfo.cmdArg, pArgs, MAX_PATH
	ECInvoke memcpy, Addr cmdinfo.cmdLine, pOutValue, MAX_PATH

	ECInvoke InsertDLAtBegin, Addr tmpLink, Addr cmdinfo, SizeOf BTN_CMD_INFO

@@:	Cmp Rax, 2;exe
	Jnz @F


	ECInvoke ZeroMemory, pArgs, MAX_PATH
	ECInvoke ZeroMemory, pExcPath, MAX_PATH
	ECInvoke ZeroMemory, Addr cmdinfo, SizeOf BTN_CMD_INFO
	Mov cmdinfo.cmdbManual, TRUE

	ECInvoke GetLnkPathInfo, pOutValue, pExcPath, pArgs, 0

	ECInvoke memcpy, Addr cmdinfo.cmdArg, pArgs, MAX_PATH
	ECInvoke memcpy, Addr cmdinfo.cmdLine, pExcPath, MAX_PATH

	ECInvoke InsertDLAtBegin, Addr tmpLink, Addr cmdinfo, SizeOf BTN_CMD_INFO


	;ECInvoke lstrlen, pOutValue
	;ECInvoke GetMapValue, hMap, Addr cmdName, Addr value, SizeOf value
	;ECInvoke PutMapValue, hMap, Addr cmdName, pOutValue, Rax



Comment #
	ECInvoke WriteLog, pOutValue, 1

	ECInvoke GetLnkPathInfo, pOutValue, pExcPath, pArgs, pWorkDir

	ECInvoke WriteLog, pExcPath, 1
	ECInvoke WriteLog, pWorkDir, 1
	ECInvoke WriteLog, pArgs, 1
#
@@:

nextNode:
Comment #
	Mov Rax, tmpLink
	Test Rax, Rax
	Jz @F
	ECInvoke SizeOfDLLink, Addr tmpLink
	Push Rax
	ECInvoke NewStr, 0, 1024
	Pop R9
	Push Rax
	ECInvoke FormatStr, Rax, CTXT("cmd:%s,count:%d,line:%s"), Addr cmdName, R9, pOutValue, 0, 0
	Pop Rcx
	Push Rcx
	ECInvoke WriteLog, Rcx, 1
	Pop Rcx
	ECInvoke DelStr, Rcx
@@:
	#

	ECInvoke GetNextDLNode, pNextNode
	Mov pNextNode, Rax
	ECInvoke IsDLNodeEqual, pNextNode, Addr dbList
	Cmp Rax, TRUE
	Jnz loopdl


	ECInvoke DelStr, pExcPath
	ECInvoke DelStr, pArgs
	ECInvoke DelStr, pWorkDir
	ECInvoke DestoryDLLink, Addr dbList

Comment #
	
	ECInvoke GetMapValue, hMap, CTXT("mod"), Addr tmpLink, SizeOf HANDLE_MALLOC
	ECInvoke SizeOfDLLink, Addr tmpLink
	Int 3
Ret
#

	;读出整理好的map
	ECInvoke NewStr, 0, 1024
	Mov pCmdskValue, Rax

	ECInvoke ZeroMemory, Addr dbLinkList, SizeOf HANDLE_MALLOC
	ECInvoke ReadAutoCmdsList, Addr dbLinkList

	Lea Rax, dbLinkList
	Mov pCmdsNode, Rax

	Mov loopPage, 0
	Mov loopBtn, 0
	Mov loopItem, 0

loopdl2:
	ECInvoke ZeroMemory, pOutValue, MAX_PATH * 2
	ECInvoke ZeroMemory, pCmdskValue, 1024
	ECInvoke GetDLNodeValue, pCmdsNode, pCmdskValue, Addr pOutSize

	;ECInvoke WriteLog, pCmdskValue, 1
	;解析每条命令的key=val
	Mov keyIdx, 0
;redKey:
	ECInvoke ZeroMemory, Addr kname, SizeOf kname
	ECInvoke ZeroMemory, Addr tmpLink, SizeOf tmpLink
	ECInvoke ZeroMemory, pValue, 1024 * 4
	ECInvoke FormatStr, Addr kname, CTXT("cmdn"), 0, 0, 0, 0, 0

	ECInvoke GetKeyValue, pCmdskValue, Addr kname, pValue
;	ECInvoke WriteLog, pValue, 0
;	Local pcmdsList:HANDLE_MALLOC

	ECInvoke GetMapValue, hMap, pValue, Addr tmpLink, SizeOf HANDLE_MALLOC
	Lea Rax, tmpLink
	Mov pNextNode, Rax

Comment #
	ECInvoke SizeOfDLLink, Addr tmpLink
	Push Rax
	ECInvoke NewStr, 0, 50
	Pop R9
	Push Rax
	ECInvoke FormatStr, Rax, CTXT("cmd:%s,count:%d"), pValue, R9, 0, 0, 0
	Pop Rcx
	Push Rcx
	ECInvoke WriteLog, Rcx, 1
	Pop Rcx
	ECInvoke DelStr, Rcx
#
	;Mov Rax, pValue

looplnks:


	ECInvoke ZeroMemory, Addr cmdinfo, SizeOf BTN_CMD_INFO
	ECInvoke GetDLNodeValue, pNextNode, Addr cmdinfo, Addr pOutSize
	Lea Rax, cmdinfo.cmdLine
	Mov Rax, [Rax]
	Test Rax, Rax
	Jz nullnode
	Mov cmdinfo.cmdbManual, TRUE
	;Lea Rax, cmdinfo.cmdArg;arg
	;Lea Rcx, cmdinfo.cmdLine;exe
	;Lea R8, value;kname
	ECInvoke lstrcpy, Addr strKey, pValue
	comment #
	ECInvoke WriteLog, Addr strKey, 0
	Lea Rcx, cmdinfo
	Lea Rcx, [Rcx + BTN_CMD_INFO.cmdLine]
	ECInvoke WriteLog, Rcx, 1
#

		Lea Rax, oldcmdName
		Mov Ax, Word Ptr [Rax]
		Test Al, Al
		Jnz @F

		ECInvoke lstrcpy, Addr oldcmdName, Addr strKey
@@:
	;start 写入配置文件

			Lea Rax, cmdinfo
			Mov pBtncmdInfo, Rax

			;格式化按钮命令
			;清空字符串
			ECInvoke ZeroMemory, Addr onValue, SizeOf onValue

Comment #
	ECInvoke WriteLog, Addr strKey, 0
	Mov Rcx, pBtncmdInfo
	Lea Rcx, [Rcx + BTN_CMD_INFO.cmdLine]
	ECInvoke WriteLog, Rcx, 1
#
			;格式化参数
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdArg]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_ARGS_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bWait
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbWait]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BWAIT_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bAdmin
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbAdmin]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BADMIN_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bManual
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbManual]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_BMANUAL_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bShutdown
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbShutdown]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_SHUTDOWN_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;bManual
			Mov Rax, pBtncmdInfo
			Mov Rax, [Rax + BTN_CMD_INFO.cmdbRestart]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_RESTART_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;格式化命令类型
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdType]
			Mov Rax, [Rax]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_TYPE_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			;格式化路径/命令
			Mov Rax, pBtncmdInfo
			Lea Rax, [Rax + BTN_CMD_INFO.cmdLine]
			ECInvoke FormatStr, Addr pTmpStr, Addr BTN_CMDLINE_FORMAT, loopBtn, Rax, 0, 0, 0
			ECInvoke lstrcat, Addr onValue, Addr pTmpStr

			ECInvoke lstrcat, pWriteVal, Addr onValue

Comment #
		ECInvoke lstrlen, Addr strKey
		ECInvoke IsMemEqul, Addr oldcmdName, Addr strKey, Rax
		Cmp Al, TRUE;0not equal
		Je @F

	;	Mov Rax, loopBtn

		;格式化热键命令名
		ECInvoke lstrlen, Addr oldcmdName
		ECInvoke CharUpperBuff, Addr oldcmdName, Rax

		ECInvoke FormatStr, Addr pTmpStr, Addr ITEM_CMDNAME_FORMAT, Addr oldcmdName, 0, 0, 0, 0
		ECInvoke lstrcat, pWriteVal, Addr pTmpStr

		;保存到配置
		ECInvoke FormatStr, Addr pTmpStr, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0

		ECInvoke WriteCfgValue, Addr CFG_BTN_ITEM_CMD_SECTION, Addr pTmpStr, pWriteVal
		ECInvoke ZeroMemory, pWriteVal, MAX_CMD_ITEM_BTN * 2 * SizeOf (BTN_CMD_INFO)

		Mov loopBtn, 0
		Lea Rax, oldcmdName
		Mov DWord Ptr [Rax], 0
		;ECInvoke lstrcpy, Addr oldcmdName, Addr strKey
		Jmp nextitem
#


;@@:
			;ECInvoke FormatStr, Addr onValue, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0
			;合并到一条写入缓冲
		Mov bWrite, 0
		Inc loopBtn
		Cmp loopBtn, MAX_CMD_ITEM_BTN
		Jb _loop_btn1

		Mov loopBtn, 0
		Mov bWrite, 1

		;格式化热键命令名
		ECInvoke lstrlen, Addr oldcmdName
		ECInvoke CharUpperBuff, Addr oldcmdName, Rax

		ECInvoke FormatStr, Addr pTmpStr, Addr ITEM_CMDNAME_FORMAT, Addr oldcmdName, 0, 0, 0, 0
		ECInvoke lstrcat, pWriteVal, Addr pTmpStr

		;保存到配置

		ECInvoke FormatStr, Addr pTmpStr, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0

		ECInvoke WriteCfgValue, Addr CFG_BTN_ITEM_CMD_SECTION, Addr pTmpStr, pWriteVal
		ECInvoke ZeroMemory, pWriteVal, MAX_CMD_ITEM_BTN * 2 * SizeOf (BTN_CMD_INFO)
		Lea Rax, oldcmdName
		Mov DWord Ptr [Rax], 0
nextitem:
		Inc loopItem
		Cmp loopItem, MAX_CMD_ITEM
		Jb _loop_item1
		Mov loopItem, 0
	;	ECInvoke ZeroMemory, pWriteVal, MAX_CMD_ITEM_BTN * 2 * SizeOf (BTN_CMD_INFO)
		Inc loopPage
		Cmp loopPage, MAX_CMD_PAGE
		Jb _loop_page11

		Mov loopPage, 0
		Mov loopItem, 0
		Mov loopBtn, 0

_loop_btn1:
_loop_item1:
_loop_page11:

nullnode:
	;end
	ECInvoke GetNextDLNode, pNextNode
	Mov pNextNode, Rax
	ECInvoke IsDLNodeEqual, pNextNode, Addr tmpLink
	Cmp Rax, TRUE
	Jnz looplnks


	Cmp bWrite, 1
	Je @F

	ECInvoke lstrlen, Addr oldcmdName
	ECInvoke CharUpperBuff, Addr oldcmdName, Rax

	ECInvoke FormatStr, Addr pTmpStr, Addr ITEM_CMDNAME_FORMAT, Addr oldcmdName, 0, 0, 0, 0
	ECInvoke lstrcat, pWriteVal, Addr pTmpStr

	;保存到配置
	ECInvoke FormatStr, Addr pTmpStr, Addr CFG_BTN_ITEM_CMDINFO, loopPage, loopItem, 0, 0, 0

	ECInvoke WriteCfgValue, Addr CFG_BTN_ITEM_CMD_SECTION, Addr pTmpStr, pWriteVal
	ECInvoke ZeroMemory, pWriteVal, MAX_CMD_ITEM_BTN * 2 * SizeOf (BTN_CMD_INFO)

	Inc loopItem
	Cmp loopItem, MAX_CMD_ITEM
	Jb nocrease
	Mov loopItem, 0
	Inc loopPage
nocrease:


	Lea Rax, oldcmdName
	Mov DWord Ptr [Rax], 0

@@:
	Mov loopBtn, 0
	Mov bWrite, 0

	ECInvoke DestoryDLLink, Addr tmpLink
;@@:
Comment #
	Mov loopBtn, 0
	Inc loopItem
	Lea Rax, oldcmdName
	Mov DWord Ptr [Rax], 0
	#
;	Inc keyIdx
;	Lea Rax, value
;	Cmp Byte Ptr [Rax], 0
;	Jnz redKey

	ECInvoke GetNextDLNode, pCmdsNode
	Mov pCmdsNode, Rax
	ECInvoke IsDLNodeEqual, pCmdsNode, Addr dbLinkList
	Cmp Rax, TRUE
	Jnz loopdl2


	ECInvoke GlobalFree, pValue
	ECInvoke DelStr, pCmdskValue
	ECInvoke DestoryDLLink, Addr dbLinkList
	ECInvoke GlobalFree, pWriteVal

	ECInvoke DestroyMap, hMap
;	ECInvoke GlobalFree, pDesktopPath
;	ECInvoke GlobalFree, destinationPath
	Ret
ReadAutoCmds EndP

Comment #
ReadCfgPair Proc pOutPair:QWord
	Local pairValue[MAX_PATH]:Word
	Local pKey[50]:Byte
	Local loopItem:QWord
	Local outCmd[MAX_PATH]:Word
	Local outExt[20]:Word
	Local pTemp:QWord
	Mov pOutPair, Rcx
	Mov pTemp, Rcx

	Mov loopItem, 0
_loop_item:
	ECInvoke ZeroMemory, Addr pairValue, SizeOf pairValue
	ECInvoke ZeroMemory, Addr pKey, SizeOf pKey
	ECInvoke ZeroMemory, Addr outCmd, SizeOf outCmd
	ECInvoke ZeroMemory, Addr outExt, SizeOf outExt


	ECInvoke FormatStr, Addr pKey, Addr CFG_CMD_PAIR_ITEM, loopItem, 0, 0, 0, 0
	ECInvoke ReadCfgString, Addr CFG_CMD_PAIR, Addr pKey, Addr pairValue, SizeOf pairValue

	ECInvoke GetKeyValue, Addr pairValue, Addr CMD_PAIR_LUN_READ_KEY, Addr outCmd
	ECInvoke GetKeyValue, Addr pairValue, Addr CMD_PAIR_EXT_READ_KEY, Addr outExt


	Mov Rax, pTemp
	Lea Rcx, [Rax + CMD_PAIR_STRUCT.pExtName]
	ECInvoke lstrcpy, Rcx, Addr outExt
	Mov Rax, pTemp
	Lea Rcx, [Rax + CMD_PAIR_STRUCT.pCmdLine]
	ECInvoke lstrcpy, Rcx, Addr outCmd

	Add pTemp, SizeOf (CMD_PAIR_STRUCT)

	
	Inc loopItem
	Mov Rax, loopItem
	Cmp Rax, MAX_CMD_PAIR
	Jb _loop_item
	Ret
ReadCfgPair EndP
#
ChangeFirstRun Proc bPush:QWord
	Local pKey[50]:Byte
	Local val[10]:Byte
	Mov bPush, Rcx
	ECInvoke FormatStr, Addr val, CTXT("%d"), bPush, 0, 0, 0, 0
	ECInvoke WriteCfgValue, Addr SECTION_SYSTEM, Addr KEY_FIRST_RUN, Addr val
	Ret
ChangeFirstRun EndP

IsFirstRun Proc
	Local val[10]:Byte
	ECInvoke ReadCfgString, Addr SECTION_SYSTEM, Addr KEY_FIRST_RUN, Addr val, SizeOf val
	ECInvoke StrToInt, Addr val

	Ret
IsFirstRun EndP

SaveRunonStartup Proc bPush:QWord
	Local pKey[50]:Byte
	Local val[10]:Byte
	Mov bPush, Rcx
	ECInvoke FormatStr, Addr val, CTXT("%d"), bPush, 0, 0, 0, 0
	ECInvoke WriteCfgValue, Addr SECTION_SYSTEM, Addr KEY_RUNON_STARTUP, Addr val
	Ret
SaveRunonStartup EndP

ReadRunonStartup Proc
	Local val[10]:Byte
	ECInvoke ReadCfgString, Addr SECTION_SYSTEM, Addr KEY_RUNON_STARTUP, Addr val, SizeOf val
	ECInvoke StrToInt, Addr val

	Ret
ReadRunonStartup EndP


