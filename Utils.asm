;EasyCodeName=Utils,1
.Const


.Data?
	;TransparentBlt QWord ?
	pfMemSet QWord ?
	pfNtQueryInformationProcess QWord ?
	pfGetCommandLineW QWord ?
.Data

	float_m1 DWord 0BF800000H
	float_1 DWord 03F800000H
	STR_SPACE DB ' ', 0
	FORMAT_D DB '%d', 0
	Shlwapi_Dll DB 'Shlwapi.dll', 0
	ntdll_Dll DB 'ntdll.dll', 0
	kernelbase_dll DB 'kernelbase.dll', 0
	memset_fs DB 'memset', 0
	GetCommandLineW_fs DB 'GetCommandLineW', 0
	NtQueryInformationProcess_fs DB 'NtQueryInformationProcess', 0

	Msimg32_dll DB 'Msimg32.dll', 0
	TransparentBlt_fs DB 'TransparentBlt', 0
	pFileFilter DB 'All(*.*)', 0, '*.*', 0, 'Exe(*.exe)', 0, '*.exe', 0, 'Lnk(*.lnk)', 0, '*.lnk', 0, 'Bat(*.bat)', 0, '*.bat', 0, 'Hta(*.hta)', 0, '*.hta', 0, 'Js(*.js)', 0, '*.js', 0, 'Python(*.py)', 0, '*.py', 0, 0 ;
.Code


InitApi Proc
	Local pFunc:QWord

	ECInvoke GetFunction, Addr ntdll_Dll, Addr memset_fs
	Mov pfMemSet, Rax

	ECInvoke GetFunction, Addr ntdll_Dll, Addr NtQueryInformationProcess_fs
	Mov pfNtQueryInformationProcess, Rax

	ECInvoke GetFunction, Addr kernelbase_dll, Addr GetCommandLineW_fs
	Mov pfGetCommandLineW, Rax

	;ECInvoke GetFunction, Addr Msimg32_dll, Addr TransparentBlt_fs
;	Mov TransparentBlt, Rax

	Ret
InitApi EndP

GetCurrentDirEx Proc
	Local pExePath[MAX_PATH]:DB
	Local pPath:QWord
	ECInvoke ZeroMemory, Addr pExePath, SizeOf pExePath
	ECInvoke GetModuleHandle, 0
	ECInvoke GetModuleFileName, Rax, Addr pExePath, SizeOf pExePath
	ECInvoke NewStr, 0, MAX_PATH
	Mov pPath, Rax
;	ECInvoke MessageBox, 0, Addr pExePath, 0, 0

	ECInvoke GetPathFromFullPath, Addr pExePath, pPath
	Mov Rax, pPath
	Ret
GetCurrentDirEx EndP




  
CreateSystemFont Proc fontSize:QWord, bUnderline:DWord, angle:DWord
    ; 初始化字体结构体
    Local metrics:NONCLIENTMETRICS

    Mov fontSize, Rcx
	Mov bUnderline, Edx
	Mov angle, R8d

	ECInvoke ZeroMemory, Addr metrics, SizeOf metrics
 	;获取系统字体信息
    ECInvoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SizeOf (NONCLIENTMETRICS), Addr metrics, 0
 
    ;创建字体

    ;Mov lf.lfHeight, 12; 字体高度
    ;Mov lf.lfOrientation, 900; 旋转90度
    ;ECInvoke CreateFontIndirect, Addr lf
    Mov Rax, fontSize
    Mov metrics.lfMessageFont.lfHeight, Eax
    ;Mov metrics.lfMessageFont.lfWidth, 5
	Mov metrics.lfMessageFont.lfWeight, 12
	Mov Eax, bUnderline
	Mov metrics.lfMessageFont.lfUnderline, Al
	Mov Eax, angle
	Mov metrics.lfMessageFont.lfEscapement, Eax
    Lea Rcx, metrics.lfMessageFont
    ECInvoke CreateFontIndirect, Rcx

    ret
CreateSystemFont EndP

SetWindowFont Proc hwnd:QWord, hFont:QWord
	Mov hwnd, Rcx
	Mov hFont, Rdx
	ECInvoke SendMessage, hwnd, WM_SETFONT, hFont, TRUE
	Ret
SetWindowFont EndP


CenterWindow Proc hWnd:QWord, offsetX :QWord, offsetY:QWord
	Local scWidth:QWord, scHeight:QWord, destX:QWord, destY:QWord
	Local hwndOldParent:HANDLE
	Local rcParent:RECT
	Local rcChild:RECT

    Test Rcx, Rcx
    Jz exit
		Mov hWnd, Rcx
		Mov offsetX, Rdx
		Mov offsetY, R8
        ; 获取父窗口的矩形区域
    	ECInvoke GetWindowRect, hwndOldParent, Addr rcParent
    	Mov hwndOldParent, Rax
	Test Rax, Rax;是否为0
    Jnz hasParent

	 ; 获取屏幕的矩形区域
	    ECInvoke GetSystemMetrics, SM_CXSCREEN
	    Mov QWord Ptr rcParent.right, Rax
	    ECInvoke GetSystemMetrics, SM_CYSCREEN
	 	Mov QWord Ptr rcParent.bottom, Rax
	 	Mov rcParent.left, 0
	 	Mov rcParent.top, 0

hasParent:

Push Rdx;保护寄存器内容
	; 获取当前窗口的矩形区域 没有图标等于没有脸
	ECInvoke GetWindowRect, hWnd, Addr rcChild
    Xor Edx, Edx
    Xor Eax, Eax
    ; 计算窗口居中的位置

    Mov Eax, rcParent.right
    Sub Eax, rcParent.left
    Shr Rax, 1
    Mov Edx, rcChild.right
    Sub Edx, rcChild.left
    Shr Edx, 1
    Add Edx, rcParent.left
    Sub Eax, Edx
	Mov QWord Ptr destX, Rax
	Mov Rax, offsetX
	Add destX, Rax

    Mov Eax, rcParent.bottom
    Sub Eax, rcParent.top
    Shr Rax, 1
    Mov Edx, rcChild.bottom
    Sub Edx, rcChild.top
    Shr Edx, 1
    Add Edx, rcParent.top
    Sub Eax, Edx
	Mov QWord Ptr destY, Rax
	Mov Rax, offsetY
	Add destY, Rax
    ; 调整窗口位置
    ECInvoke SetWindowPos, hWnd, HWND_TOP, destX, destY, 0, 0, SWP_NOSIZE OR SWP_NOZORDER OR SWP_SHOWWINDOW
Pop Rdx;还原寄存器内容

exit:
    ret
CenterWindow EndP

StrToInt Proc pIntStr:QWord
	Local pOutI:DWord
	;Mov pIntStr, Rcx
	ECInvoke StrToIntEx, Rcx, STIF_DEFAULT, Addr pOutI

	Mov Eax, pOutI
	Ret
StrToInt EndP

StrHexToInt Proc pHexStr:QWord
	Local pOutI:DWord
	;Mov pHexStr, Rcx
	ECInvoke StrToIntEx, Rcx, STIF_SUPPORT_HEX, Addr pOutI
	Mov Eax, pOutI
	Ret
StrHexToInt EndP

NumberToString Proc  pOutStr:QWord, format:QWord
	;Mov number, Rdx
	;Mov pOutStr, Rcx
	Mov R8, Rdx
	ECInvoke wsprintf, Rcx, Addr FORMAT_D, R8
	Ret
NumberToString EndP

FormatStr Proc pOutStr:QWord, format:QWord, arg1:QWord, arg2:QWord, arg3:QWord, arg4:QWord, arg5:QWord
	;Mov pOutStr, Rcx
;	Mov number, Rdx
;	Mov arg1, R8
;	Mov arg2, R9

	ECInvoke wsprintf, Rcx, Rdx, R8, R9, arg3, arg4, arg5
	Ret
FormatStr EndP

GetSystemIcon Proc iconIndex:DWord
	Local hIcon:HICON
	Mov iconIndex, Ecx
    ECInvoke ExtractIconEx, CTXT("shell32.dll"), iconIndex, Addr hIcon, NULL, 1
    Mov Rax, hIcon
	Ret
GetSystemIcon EndP

LoadIconFromExe Proc exePath:QWord
    Local hIcon:QWord
    Local pTmpStr:QWord
    Mov exePath, Rcx
	Mov hIcon, 0

	ECInvoke NewStr, Rcx, 0
	Mov pTmpStr, Rax
    ECInvoke lstrlen, Rcx
    ECInvoke AnsiLowerBuff, pTmpStr, Rax
	ECInvoke StrStr, pTmpStr, CTXT(".exe")
	Test Eax, Eax
	Jz exit
        ;// 从EXE文件中提取第一个图标（编号为0的图标）
    ECInvoke ExtractIconEx, exePath, 0, Addr hIcon, 0, 1
exit:
    Mov Rax, hIcon
    ECInvoke DelStr, pTmpStr
	Ret
LoadIconFromExe EndP
Comment #

HICON hIcon = reinterpret_cast<HICON>(LoadImage(nullptr, L"path_to_your_exe_file", IMAGE_ICON, 0, 0, LR_DEFAULTSIZE | LR_LOADFROMFILE));

            if (hIcon) {
                // 使用GDI绘制图标
                DrawIcon(hdc, 100, 100, hIcon);
                
                // 释放图标资源
                DestroyIcon(hIcon);
            }
            
#
Malloc Proc pHandleMalloc:QWord, bufferSize:QWord
	Mov pHandleMalloc, Rcx
	Mov bufferSize, Rdx

	ECInvoke GlobalAlloc, GPTR, bufferSize
	Mov Rcx, pHandleMalloc
	Mov [Rcx + HANDLE_MALLOC.pMem], Rax
	comment #
	ECInvoke GetProcessHeap
	Mov Rcx, pHandleMalloc
    Mov [Rcx + HANDLE_MALLOC.Handle], Rax
    Push Rcx
	ECInvoke HeapAlloc, Rax, HEAP_ZERO_MEMORY, bufferSize
	Pop Rcx
	Mov [Rcx + HANDLE_MALLOC.pMem], Rax
	#
	Ret
Malloc EndP


Free Proc pHandleMalloc:QWord

	comment #
	Mov Rax, [Rcx + HANDLE_MALLOC.Handle]
	Mov Rdx, [Rcx + HANDLE_MALLOC.pMem]
	ECInvoke HeapFree, Rax, HEAP_ZERO_MEMORY, Rdx
	#
	ECInvoke GlobalFree, Rcx
	Ret
Free EndP

;返回1相等
IsMemEqul Proc src:QWord, dest:QWord, len:QWord
;	Mov src, Rcx
;	Mov dest, Rdx
;	Mov len, R8

	Push Rdi
	Push Rsi
	Mov Rdi, Rcx	;src
	Mov Rsi, Rdx;dest
	Mov Rcx, R8 ;len
	Repe Cmpsb

	Pop Rsi
	Pop Rdi
	;Xor Rax, Rax

	Setz Al ; 如果 ZF = 1，则将 al 设置为 1；否则将 al 设置为 0

	Ret
IsMemEqul EndP

CopyMaloocHandle Proc pDest:QWord, pSrc:QWord
	;采用128位mmx指令提速

	Mov Rax, [Rdx + HANDLE_MALLOC.pMem]
	Mov [Rcx + HANDLE_MALLOC.pMem], Rax
Comment #
	Movdqu Xmm0, XMMWord Ptr [Rdx + HANDLE_MALLOC.Handle]
	Movdqu XMMWord Ptr [Rcx + HANDLE_MALLOC.Handle], Xmm0
#
	Ret
CopyMaloocHandle EndP

HandleToPmem Proc hanleMalloc:QWord
	Mov Rax, [Rcx + HANDLE_MALLOC.pMem]
	Ret
HandleToPmem EndP

memcpy Proc destination:QWord, source:QWord, copySize:QWord
    Mov Rsi, Rdx
    Mov Rdi, Rcx
    Mov Rcx, R8 
    Cld
    Rep Movsb
    ;Std
    ret
memcpy EndP

ShowWindowEx Proc hWnd:QWord, bShow:QWord
	Mov hWnd, Rcx
	Mov bShow, Rdx
	Cmp bShow, TRUE
	Jnz @F
	ECInvoke SetWindowPos, hWnd, HWND_TOPMOST, 0, 0, 0, 0, (SWP_NOMOVE OR SWP_NOSIZE OR SWP_SHOWWINDOW)
	Ret
@@:
	ECInvoke SetWindowPos, hWnd, HWND_TOPMOST, 0, 0, 0, 0, (SWP_NOMOVE OR SWP_NOSIZE OR SWP_HIDEWINDOW)
	
	Ret
ShowWindowEx EndP

SetWindowRoundRect Proc hWnd:QWord
	Local rcClient:RECT
	;Local hRgn:HRGN
	Mov hWnd, Rcx
	ECInvoke GetClientRect, hWnd, Addr rcClient
    ; 创建具有圆角的区域
    ECInvoke CreateRoundRectRgn, rcClient.left, rcClient.top, rcClient.right, rcClient.bottom, 4, 4
     ;Mov g_wndRgn, Rax
	ECInvoke SetWindowRgn, hWnd, Rax, TRUE

	Ret
SetWindowRoundRect EndP

DrawWindowRoundBorder Proc hDc:QWord, pRect:QWord, cColor:DWord, iSize:DWord
	Local rcRect:RECT
	Local hRgn:HRGN
	Local hBrush:HBRUSH
	Mov hDc, Rcx
	Mov pRect, Rdx
	Mov cColor, R8d
	Mov iSize, R9d

	ECInvoke memcpy, Addr rcRect, pRect, SizeOf (RECT)

	; 创建具有圆角的区域
	ECInvoke CreateRoundRectRgn, rcRect.left, rcRect.top, rcRect.right, rcRect.bottom, 3, 3
	Mov hRgn, Rax
	
	; 将绘图设备（DC）裁剪为具有圆角的区域
	; ECInvoke SelectClipRgn, ps.hdc, hRgn
	ECInvoke CreateSolidBrush, cColor
	Mov hBrush, Rax
;	ECInvoke CreatePen, PS_SOLID, 1, 00441111H
;	Mov hPen, Rax
	;ECInvoke SelectObject, ps.hdc, hBrush
	;ECInvoke SelectObject, ps.hdc, hPen
	; 绘制矩形
	;ECInvoke FillRect, ps.hdc, Addr rcClient, hBrush
	;ECInvoke FillRgn, ps.hdc, hRgn, hBrush
	ECInvoke FrameRgn, hDc, hRgn, hBrush, iSize, iSize

	ECInvoke DeleteObject, hRgn
	ECInvoke DeleteObject, hBrush
	Ret
DrawWindowRoundBorder EndP


IsClassRegistered Proc pclassName:QWord
	Local wcex:WNDCLASSEX ;
	Mov pclassName, Rcx

    ECInvoke GetClassInfoEx, 0, pclassName, Addr wcex

	Ret
IsClassRegistered EndP

GetWMMousePos Proc lParam:QWord, outPoint:QWord
	Mov lParam, Rcx
	Mov outPoint, Rdx
	Mov Rcx, outPoint
	Mov Rax, lParam
	And Rax, 0FFFFH
	Mov [Rcx + POINT.x], Eax

	Mov Rax, lParam
	Shr Eax, 16
	And Rax, 0FFFFH
	Mov [Rcx + POINT.y], Eax
	Ret
GetWMMousePos EndP

GetFunction Proc pLibName:QWord, pFuncName:QWord
	Local hModule:QWord

	Mov pLibName, Rcx
	Mov pFuncName, Rdx

	ECInvoke GetModuleHandle, pLibName
	Mov hModule, Rax
	Test Eax, Eax
	Jnz _loaded
	ECInvoke LoadLibrary, pLibName
	Mov hModule, Rax
_loaded:
	ECInvoke GetProcAddress, hModule, pFuncName

	Ret
GetFunction EndP

ZeroMemory Proc pMem:QWord, dSize:QWord
	Mov pMem, Rcx
	Mov dSize, Rdx

	BEGIN_CALL 30H
	Mov Rcx, pMem
	Mov Rdx, 0
	Mov R8, dSize
	Call pfMemSet
	END_CALL 30H
	Ret
ZeroMemory EndP


;启动类型(设置参数）：exe,bat,js,url,控制面板，路径
RuncmdThreadProc Proc pRunArgs:QWord
	Local sei:SHELLEXECUTEINFO
	Local bWaitExit:QWord
	Local bAdmin:QWord
	Local pWorkDir:QWord
	Local pParams:QWord
	Local pExecPath:QWord
	Mov pRunArgs, Rcx




	ECInvoke ZeroMemory, Addr sei, SizeOf sei
	Mov sei.cbSize, SizeOf sei
	Mov Rcx, pRunArgs



	Mov Rax, [Rcx].RUN_CMD_THREAD_ARGS.bWaitExit
	Mov bWaitExit, Rax
	Mov Rax, [Rcx].RUN_CMD_THREAD_ARGS.bAdmin
	Mov bAdmin, Rax

	Mov Rax, [Rcx].RUN_CMD_THREAD_ARGS.pWorkPath
	Mov sei.lpDirectory, Rax

	Mov Rax, [Rcx].RUN_CMD_THREAD_ARGS.pAppPath
	Mov sei.lpFile, Rax

	Mov Rax, [Rcx].RUN_CMD_THREAD_ARGS.pCmdArg
	Mov sei.lpParameters, Rax

	Mov sei.fMask, SEE_MASK_DEFAULT
	Mov Rax, bWaitExit
	Test Eax, Eax
	Jz @F
	Mov sei.fMask, SEE_MASK_NOCLOSEPROCESS;
@@:

	;如果是快捷方式再次解析路径
	ECInvoke IsExtName, sei.lpFile, CTXT(".lnk")
	Cmp Rax, 0
	Je @F
	ECInvoke DelStr, sei.lpDirectory
	ECInvoke NewStr, 0, MAX_PATH
	Mov pWorkDir, Rax
	ECInvoke NewStr, 0, MAX_PATH
	Mov pParams, Rax
	ECInvoke NewStr, 0, MAX_PATH
	Mov pExecPath, Rax

	ECInvoke GetLnkPathInfo, sei.lpFile, pExecPath, pParams, pWorkDir

	Mov Rax, pWorkDir
	Mov sei.lpDirectory, Rax
	Mov Rax, pParams
	Mov sei.lpParameters, Rax
	Mov Rax, pExecPath
	Mov sei.lpFile, Rax
	
@@:

	Mov sei.nShow, SW_SHOWNORMAL

	Mov Rax, CTXT ("open")
	Mov sei.lpVerb, Rax

	Mov Rax, bAdmin
	Test Eax, Eax
	Jz @F
	Mov Rax, CTXT ("runas")
	Mov sei.lpVerb, Rax

@@:
Comment #
	ECInvoke WriteLog, CTXT("dir:"), 1
	Mov Rcx, sei.lpDirectory
	ECInvoke WriteLog, Rcx, 1
	ECInvoke WriteLog, CTXT("exe:"), 1
	Mov Rcx, sei.lpFile
	ECInvoke WriteLog, Rcx, 1
#
	ECInvoke ShellExecuteEx, Addr sei
	;;ECInvoke WaitForSingleObject, sei.hProcess, 1000
comment#
	Mov Rax, bWaitExit
	Test Eax, Eax
	Jz @F
	ECInvoke WaitForSingleObject, sei.hProcess, INFINITE
	ECInvoke CloseHandle, sei.hProcess
@@:
#

	ECInvoke DelStr, pParams
	ECInvoke DelStr, pExecPath
	ECInvoke DelStr, sei.lpDirectory
	ECInvoke GlobalFree, pRunArgs
	Ret
RuncmdThreadProc EndP
IsExtName Proc pPath:QWord, pExtName:QWord
	Mov pPath, Rcx
	Mov pExtName, Rdx
	ECInvoke StrRStr, pPath, 0, pExtName
	Cmp Rax, 0
	Je @F
	Cmp Byte Ptr [Rax + 4], 0
	Jne @F
		Mov Rax, TRUE
		Ret
@@:
	Xor Eax, Eax
	Ret
	Ret
IsExtName EndP

RunCommand Proc pAppPath:QWord, pCmdArg:QWord, pWorkPath:QWord, bAdmin:QWord, bWaitExit:QWord
	Local pRunArgs:QWord
	Mov pAppPath, Rcx
	Mov pCmdArg, Rdx
	Mov pWorkPath, R8
	Mov bAdmin, R9
	ECInvoke NewStr, pWorkPath, 0
	Mov pWorkPath, Rax

	ECInvoke GlobalAlloc, GPTR, SizeOf RUN_CMD_THREAD_ARGS
	Mov pRunArgs, Rax
	Mov Rcx, pAppPath
	Mov [Rax].RUN_CMD_THREAD_ARGS.pAppPath, Rcx
	Mov Rcx, pCmdArg
	Mov [Rax].RUN_CMD_THREAD_ARGS.pCmdArg, Rcx
	Mov Rcx, pWorkPath
	Mov [Rax].RUN_CMD_THREAD_ARGS.pWorkPath, Rcx
	Mov Rcx, bAdmin
	Mov [Rax].RUN_CMD_THREAD_ARGS.bAdmin, Rcx
	Mov Rcx, bWaitExit
	Mov [Rax].RUN_CMD_THREAD_ARGS.bWaitExit, Rcx

	ECInvoke CreateThread, 0, 0, RuncmdThreadProc, pRunArgs, 0, 0

	Ret
RunCommand EndP

RunBtnCmdInfoCommand Proc pBtnCmdInfo:QWord
	Local pAppPath:QWord
	Local appPath[MAX_PATH]:Byte
	Local pArgLine:QWord
	Local bWait:QWord
	Local bAdmin:QWord

	Mov pBtnCmdInfo, Rcx
	ECInvoke ZeroMemory, Addr appPath, SizeOf appPath

	Mov Rcx, pBtnCmdInfo
	Test Rcx, Rcx
	Jz @F

	Lea Rax, [Rcx + BTN_CMD_INFO.cmdLine]
	Mov pAppPath, Rax

	Lea Rax, [Rcx + BTN_CMD_INFO.cmdbWait]
	Mov Rax, [Rax]
	Mov bWait, Rax

	Lea Rax, [Rcx + BTN_CMD_INFO.cmdArg]
	Mov pArgLine, Rax


	Lea Rax, [Rcx + BTN_CMD_INFO.cmdbAdmin]
	Mov Rax, [Rax]
	Mov bAdmin, Rax

	ECInvoke GetPathFromFullPath, pAppPath, Addr appPath
	ECInvoke RunCommand, pAppPath, pArgLine, Addr appPath, bAdmin, bWait
@@:
	Ret
RunBtnCmdInfoCommand EndP


ReplaceChr Proc pSrc:QWord, bChar:QWord, rpcChar:QWord
	Local looprep:QWord
	Local keysLen:QWord
	Mov pSrc, Rcx
	Mov bChar, Rdx
	Mov rpcChar, R8

	ECInvoke lstrlen, pSrc
	Mov keysLen, Rax

	Mov looprep, 0
	Mov Rax, pSrc
	Push Rax
_replace:
	Pop Rcx
	Inc Rcx

	ECInvoke StrChr, Rcx, bChar
	Test Rax, Rax
	Jz _exit
	Push Rax
	Mov Rcx, rpcChar
	Mov Byte Ptr [Rax], Cl;所有;号覆盖成0
	Inc looprep
	Mov Rax, looprep
	Cmp Rax, keysLen
	Jb _replace
_exit:
	Ret
ReplaceChr EndP


GetPathFromFullPath Proc pAppPath:QWord, pOutPath:QWord
	Local pStr:QWord

	Mov pAppPath, Rcx
	Mov pOutPath, Rdx

;	ECInvoke StrRChr,
	ECInvoke StrRChr, pAppPath, 0, '\'
	Mov pStr, Rax
	Sub Rax, pAppPath
	Inc Rax
	Mov R8, Rax
	ECInvoke memcpy, pOutPath, pAppPath, R8

	Ret
GetPathFromFullPath EndP

NewStr Proc pSrc:QWord, sLen:QWord
	Local pStr:QWord
	Mov pSrc, Rcx
	Mov sLen, Rdx
	Cmp sLen, 0
	Jne @F
		ECInvoke lstrlen, pSrc
		Add Rax, 2
		Mov sLen, Rax
@@:
	ECInvoke GlobalAlloc, GPTR, sLen
	Mov pStr, Rax
	ECInvoke ZeroMemory, Rax, sLen
	Cmp pSrc, 0
	Je @F
		ECInvoke lstrcpy, Rax, pSrc
@@:
	Mov Rax, pStr
	Ret
NewStr EndP

DelStr Proc pStr:QWord

	Mov pStr, Rcx
	ECInvoke IsBadReadPtr, pStr, 1
	Test Rax, Rax
	Jnz @F
	ECInvoke GlobalFree, pStr
@@:
	Ret
DelStr EndP

GetRootWindow Proc hWnd:QWord
	;Mov hWnd, Rcx
	ECInvoke GetAncestor, Rcx, GA_ROOT
	Ret
GetRootWindow EndP

GetCurrentDatatime Proc pOutTime:QWord
	Local sysTime:SYSTEMTIME
	Local sysTimeWithMilliseconds:SYSTEMTIME
	Local milliseconds:QWord

	Mov pOutTime, Rcx

	ECInvoke ZeroMemory, Addr sysTime, SizeOf (SYSTEMTIME)
	ECInvoke ZeroMemory, Addr sysTimeWithMilliseconds, SizeOf (SYSTEMTIME)

	ECInvoke GetLocalTime, Addr sysTime

	;获取毫秒数
	ECInvoke GetSystemTime, Addr sysTimeWithMilliseconds

	Mov Ax, sysTimeWithMilliseconds.wMilliseconds
	Mov milliseconds, Rax

	;构建日期时间字符串
	ECInvoke wsprintf, pOutTime, CTXT("%d/%d/%d %d:%d:%d.%d"), sysTime.wYear, sysTime.wMonth, sysTime.wDay, sysTime.wHour, sysTime.wMinute, sysTime.wSecond, milliseconds
	Ret

GetCurrentDatatime EndP

WriteLog Proc pLogInfo:QWord, bBr:QWord
	Local logPath:QWord
	Local logTime:QWord
	Local rd:QWord
	Local hFile:HANDLE
	Local pFullInfo:QWord
	Local logSize:QWord
	Local br[2]:Byte
	Mov pLogInfo, Rcx
	Mov bBr, Rdx

	ECInvoke NewStr, 0, MAX_PATH
	Mov logPath, Rax
	ECInvoke NewStr, 0, 80
	Mov logTime, Rax
	ECInvoke GetCurrentLOGPath, logPath, MAX_PATH

	ECInvoke GetCurrentDatatime, logTime

	ECInvoke lstrlen, pLogInfo
	Mov logSize, Rax
	ECInvoke lstrlen, logTime
	Add Rax, 4
	Add logSize, Rax


	ECInvoke NewStr, 0, logSize
	Mov pFullInfo, Rax
	ECInvoke ZeroMemory, pFullInfo, logSize

	ECInvoke FormatStr, pFullInfo, CTXT("%s: %s"), logTime, pLogInfo, 0, 0, 0
	Cmp bBr, 1
	Jne @F
		Mov br, 000AH
		ECInvoke lstrcat, pFullInfo, Addr br
@@:

	ECInvoke CreateFile, logPath, GENERIC_READ OR GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
	Mov hFile, Rax
	Cmp Rax, INVALID_HANDLE_VALUE
	Jnz @F
		ECInvoke DelStr, pFullInfo
		ECInvoke DelStr, logPath
		ECInvoke DelStr, logTime
		Xor Eax, Eax
		Ret
@@:

	ECInvoke SetFilePointer, hFile, 0, 0, FILE_END

	ECInvoke lstrlen, pFullInfo
	Mov logSize, Rax

	ECInvoke WriteFile, hFile, pFullInfo, logSize, Addr rd, 0
	Test Rax, Rax
	Jnz @F
		ECInvoke DelStr, pFullInfo
		ECInvoke DelStr, logPath
		ECInvoke DelStr, logTime
		ECInvoke CloseHandle, hFile
		Xor Eax, Eax
		Ret
@@:
	ECInvoke DelStr, logPath
	ECInvoke DelStr, pFullInfo
	ECInvoke DelStr, logTime
	ECInvoke CloseHandle, hFile


			
;    ECInvoke WritePrivateProfileString, Addr log_section, key, Addr logTime, Addr logPath

    ret
WriteLog EndP

GetExtLunc Proc pFilePath:QWord
	Mov pFilePath, Rcx

	Ret
GetExtLunc EndP


CreateTransBkgBitmap Proc hBitmap:QWord, transColor:DWord
	Local bits:QWord
	Local bm:BITMAP
	Local bmi:BITMAPINFO
	Local idxColor:QWord
	Local totalDword:QWord

	Local hMaskBitmap:HBITMAP
	Local hdc:HDC

	Mov hBitmap, Rcx
	Mov transColor, Edx


	ECInvoke ZeroMemory, Addr bm, SizeOf bm
	ECInvoke ZeroMemory, Addr bmi, SizeOf bmi

	ECInvoke GetObject, hBitmap, SizeOf bm, Addr bm

	Mov Eax, bm.bmWidth
	Mov Ecx, bm.bmHeight
	Xor Edx, Edx
	IMul Eax, Ecx
	Mov totalDword, Rax
	Xor Edx, Edx
	IMul Eax, 4

 	ECInvoke GlobalAlloc, GPTR, Eax ;  // 4 bytes per pixel (32-bit)
	Mov bits, Rax

    Mov bmi.bmiHeader.biSize, SizeOf BITMAPINFOHEADER
    Mov Eax, bm.bmWidth
    Mov bmi.bmiHeader.biWidth, Eax
    Mov Eax, bm.bmHeight
;	Neg Eax ;-eax // Negative height to ensure a top-down DIB
    Mov bmi.bmiHeader.biHeight, Eax
    Mov bmi.bmiHeader.biPlanes, 1
    Mov bmi.bmiHeader.biBitCount, 32
    Mov bmi.bmiHeader.biCompression, BI_RGB
 	ECInvoke GetDC, NULL
 	Mov hdc, Rax
    ECInvoke GetDIBits, Rax, hBitmap, 0, bm.bmHeight, bits, Addr bmi, DIB_RGB_COLORS



    ; 将透明色替换为透明
    Mov idxColor, 0
_loopcolor:
	Mov Rax, idxColor
	Xor Edx, Edx
	Mov Ecx, 4
	IMul Eax, Ecx
	Mov R8, bits
	Add R8, Rax
	Mov Eax, DWord Ptr [R8]
	Cmp Eax, transColor
	Jne @F

	Mov DWord Ptr [R8], 0
	Jmp clp
@@:
	Mov Eax, DWord Ptr [R8]
	Or Eax, 0FF000000H
	Mov DWord Ptr [R8], Eax
clp:
	Inc idxColor
	Mov Rax, idxColor
    Cmp Rax, totalDword
    Jb _loopcolor



	Lea Rdx, bmi.bmiHeader
	ECInvoke CreateDIBitmap, hdc, Rdx, CBM_INIT, bits, Addr bmi, DIB_RGB_COLORS
	Mov hMaskBitmap, Rax
	ECInvoke ReleaseDC, NULL, hdc
	ECInvoke GlobalFree, bits
	Mov Rax, hMaskBitmap
	Ret
CreateTransBkgBitmap EndP


CreateIconFromBitmap Proc hBitmap:QWord, tranColor:DWord
	Local iconInfo:ICONINFO
	Local hTransparentBitmap:HBITMAP


	Mov hBitmap, Rcx
	Mov tranColor, Edx

	ECInvoke ZeroMemory, Addr iconInfo, SizeOf iconInfo


	ECInvoke CreateTransBkgBitmap, hBitmap, tranColor
	Mov hTransparentBitmap, Rax

	Mov iconInfo.fIcon, TRUE
	Mov Rax, hTransparentBitmap
    Mov iconInfo.hbmMask, Rax
    Mov Rax, hTransparentBitmap
    Mov iconInfo.hbmColor, Rax
    ECInvoke CreateIconIndirect, Addr iconInfo

	Ret
CreateIconFromBitmap EndP

GetCurrenthIcon Proc
	Local ci:CURSORINFO
	ECInvoke ZeroMemory, Addr ci, SizeOf ci
	Mov ci.cbSize, SizeOf ci
	ECInvoke GetCursorInfo, Addr ci
	Mov Rcx, ci.hCursor
	Ret
GetCurrenthIcon EndP

SetBitmapToCursor Proc hWnd:QWord, hBitmap:QWord
	Local hIcon:HICON
	Mov hWnd, Rcx
	Mov hBitmap, Rdx

	ECInvoke SetCapture, hWnd
	ECInvoke CreateIconFromBitmap, hBitmap, TRANS_COLOR
	Mov hIcon, Rax
	ECInvoke SetCursor, hIcon
	Mov Rax, hIcon
	Ret
SetBitmapToCursor EndP


UnsetBitmapToCursor Proc hWnd:QWord, hIcon:QWord
	Mov hWnd, Rcx
	Mov hIcon, Rdx

	ECInvoke ReleaseCapture, hWnd
	ECInvoke DeleteObject, hIcon

	ECInvoke LoadCursor, NULL, IDC_ARROW
	ECInvoke SetCursor, Rax

	Ret
UnsetBitmapToCursor EndP

GetLnkPathInfo Proc pLnkFile:QWord, pOutPath:QWord, pOutArgs:QWord, pOutWorkDir:QWord
	Local pIShellLink:QWord
	Local pIPersistFile:QWord
	Local hr:HRESULT
	Local pWstr:QWord
	Mov pLnkFile, Rcx
	Mov pOutPath, Rdx
	Mov pOutArgs, R8
	Mov pOutWorkDir, R9

	ECInvoke CoCreateInstance, Addr GUID_CLSID_ShellLinkD, NULL, CLSCTX_INPROC_SERVER, Addr GUID_IID_IShellLinkD, Addr pIShellLink
	Mov hr, Eax
	Cmp DWord Ptr hr, 0
	Jl cciError

	ECCOInvoke [pIShellLink].IShellLink.QueryInterface, Addr IID_IPersistFile, Addr pIPersistFile

	ECInvoke CharToWidechar, pLnkFile
	Mov pWstr, Rax
	ECCOInvoke [pIPersistFile].IPersistFile.Load, pWstr, STGM_READ

	Cmp pOutPath, 0
	Je @F
	ECCOInvoke [pIShellLink].IShellLink.GetPath, pOutPath, MAX_PATH, 0, SLGP_RAWPATH
@@:Cmp pOutArgs, 0
	Je @F
	ECCOInvoke [pIShellLink].IShellLink.GetArguments, pOutArgs, MAX_PATH
@@:Cmp pOutWorkDir, 0
	Je @F
	ECCOInvoke [pIShellLink].IShellLink.GetWorkingDirectory, pOutWorkDir, MAX_PATH
@@:

	ECInvoke DelStr, pWstr

cciError:

	Ret
GetLnkPathInfo EndP

CharToWidechar Proc pInChar:QWord
	
	Local pret:QWord
	Local dwNum:DWord
	Mov pInChar, Rcx
	ECInvoke lstrlen, pInChar
	Add Rax, 2
	Shl Rax, 2
	ECInvoke NewStr, 0, Rax
	Mov pret, Rax
	ECInvoke MultiByteToWideChar, CP_ACP, NULL, pInChar, -1, NULL, 0
	Inc Eax
	Mov dwNum, Eax
	ECInvoke MultiByteToWideChar, CP_ACP, NULL, pInChar, -1, pret, dwNum
	Mov Rax, pret
	Ret
CharToWidechar EndP

WideCharToPChar Proc pInWchar:QWord
	Local pret:QWord
	Local dwNum:DWord
	Mov pInWchar, Rcx

	ECInvoke WideCharToMultiByte, CP_OEMCP, NULL, pInWchar, -1, NULL, 0, NULL, FALSE
	Inc Eax
	Mov dwNum, Eax
	ECInvoke NewStr, 0, dwNum
	Mov pret, Rax
	ECInvoke WideCharToMultiByte, CP_OEMCP, NULL, pInWchar, -1, pret, dwNum, NULL, FALSE
	Mov Rax, pret
	Ret
WideCharToPChar EndP

OpenFileDialog Proc
	Local ofn:OPENFILENAME
	ECInvoke ZeroMemory, Addr ofn, SizeOf OPENFILENAME

    Mov ofn.lStructSize, SizeOf OPENFILENAME
    ECInvoke NewStr, 0, MAX_PATH
   ; Mov Rax, pOutPath
    Mov ofn.lpstrFile, Rax
    Mov ofn.nMaxFile, MAX_PATH
    Lea Rax, pFileFilter
    Mov ofn.lpstrFilter, Rax
    Mov ofn.nFilterIndex, 1
    Mov ofn.Flags, (OFN_PATHMUSTEXIST OR OFN_FILEMUSTEXIST)
    ECInvoke GetOpenFileName, Addr ofn

	ECInvoke lstrlen, ofn.lpstrFile
	Mov Rcx, Rax
    Mov Rax, ofn.lpstrFile
    ;ECInvoke DelStr, Rax
    ;ECInvoke CoUninitialize
	Ret
OpenFileDialog EndP


GetFileDefaultIcon Proc pFilePath:QWord
	Local shfi:SHFILEINFO
	Local hIcon:HICON
	Mov pFilePath, Rcx
	Mov Al, [Rcx]
	Test Al, Al
	Jz exit
    ECInvoke LoadIconFromExe, Rcx
	Mov hIcon, Rax
	Test Eax, Eax
	Jnz got

	ECInvoke ZeroMemory, Addr shfi, SizeOf shfi
    ECInvoke SHGetFileInfo, pFilePath, 0, Addr shfi, SizeOf shfi, (SHGFI_ICON OR SHGFI_USEFILEATTRIBUTES OR SHGFI_TYPENAME)
    ;将图标句 DestoryIcon
    Mov Rax, shfi.hIcon

    Mov hIcon, Rax
got:
	Mov Rax, hIcon
exit:
	Ret
GetFileDefaultIcon EndP

DrawBackground Proc hDc:QWord, x:DWord, y:DWord, iw:DWord, ih:DWord, bgColor:DWord
	Local hBrush:HBRUSH
	Mov hDc, Rcx
	Mov x, Edx
	Mov y, R8d
	Mov iw, R9d

	ECInvoke CreateSolidBrush, bgColor
	Mov hBrush, Rax
	ECInvoke SelectObject, hDc, Rax
	ECInvoke PatBlt, hDc, x, y, iw, ih, PATCOPY
	ECInvoke DeleteObject, hBrush
	Ret
DrawBackground EndP

AddToStartup Proc bTrue:QWord
	Local hKey:HKEY
	Local pExePath[MAX_PATH]:DB
	Mov bTrue, Rcx

	ECInvoke GetModuleHandle, 0
	ECInvoke GetModuleFileName, Rax, Addr pExePath, SizeOf pExePath
	ECInvoke RegOpenKeyEx, HKEY_CURRENT_USER, CTXT("Software\Microsoft\Windows\CurrentVersion\Run"), 0, KEY_SET_VALUE, Addr hKey

	Cmp bTrue, TRUE
	Je write
	ECInvoke RegDeleteValue, hKey, Addr APP_NAME
	Jmp close
write:
	ECInvoke lstrlen, Addr pExePath
	ECInvoke RegSetValueEx, hKey, Addr APP_NAME, 0, REG_SZ, Addr pExePath, Rax
close:
	ECInvoke RegCloseKey, hKey

	Ret
AddToStartup EndP

DrawWindowTitle Proc hDc:QWord, pRect:QWord, pText:QWord
	comment #
	Local memDC:HDC
	Local memBitmap:HBITMAP
	
	Local xForm:XFORM
	Local lRect:RECT
#
	Local hFont:HFONT
	Mov hDc, Rcx
	Mov pRect, Rdx
	Mov pText, R8
	comment #
	ECInvoke memcpy, Addr lRect, pRect, SizeOf RECT

    ; 创建内存DC以便后续绘制
    ECInvoke CreateCompatibleDC, hDc
    Mov memDC, Rax
    ECInvoke CreateCompatibleBitmap, hDc, lRect.right, lRect.bottom
    Mov memBitmap, Rax

    ECInvoke SelectObject, memDC, memBitmap

	ECInvoke BitBlt, memDC, lRect.left, lRect.top, lRect.right, lRect.bottom, hDc, 0, 0, SRCCOPY
    ;设置背景透明
    ECInvoke SetBkMode, memDC, TRANSPARENT

 


    ECInvoke SelectObject, memDC, hFont
    ECInvoke SetTextColor, memDC, 00FFFFFFH

    ECInvoke lstrlen, pText
    Mov R8d, lRect.bottom
    Sub R8d, 28
    ECInvoke TextOut, memDC, 5, R8, pText, Rax

    ; 复制到屏幕上
    ECInvoke BitBlt, hDc, lRect.left, lRect.top, lRect.right, lRect.bottom, memDC, 0, 0, SRCCOPY

    ;清理资源

    ECInvoke DeleteObject, hFont
    ECInvoke DeleteObject, memBitmap
    ECInvoke DeleteDC, memDC
	#

	ECInvoke CreateSystemFont, 12, FALSE, 900
    Mov hFont, Rax

	Mov Rdx, pRect
	Mov Eax, [Rdx].RECT.bottom
    Sub Eax, 28
    ECInvoke DrawTextExt, hDc, pRect, pText, 00FFFFFFH, 6, Rax, hFont
    ECInvoke DeleteObject, hFont
	Ret
DrawWindowTitle EndP

;eax=cx,edx=cy
GetTextWide Proc hdc:QWord, pText:QWord
	Local outSize:SIZE_EX
	Mov hdc, Rcx
	Mov pText, Rdx
	ECInvoke lstrlen, pText

	ECInvoke GetTextExtentPoint32, hdc, pText, Rax, Addr outSize
	Mov Eax, outSize.icx
	Mov Edx, outSize.icy
	Ret
GetTextWide EndP


BrushWindowThread Proc hWnd:QWord
	Local rcRect:RECT
	Local hdcMem:HDC
	Local hBitmap:HBITMAP
	Local hdc:HDC
	Local xTo:DWord
	Local stamp:DWord
	Mov hWnd, Rcx
	ECInvoke ShowWindowEx, hWnd, TRUE
Comment #
	ECInvoke UpdateInWindow, hWnd
	ECInvoke GetWindowDC, hWnd
	Mov hdc, Rax
	Mov xTo, 0
	Mov stamp, 30

	ECInvoke GetClientRect, hWnd, Addr rcRect
	ECInvoke CreateMemDC, hdc, rcRect.right, rcRect.bottom
	Mov hdcMem, Rax
	Mov hBitmap, Rdx
_loop_brush_to:
	ECInvoke BitBlt, hdcMem, 0, 0, rcRect.right, rcRect.bottom, hdc, 0, 0, SRCCOPY
	ECInvoke PatBlt, hdcMem, xTo, 0, stamp, rcRect.bottom, DSTINVERT
	ECInvoke BitBlt, hdc, 0, 0, rcRect.right, rcRect.bottom, hdcMem, 0, 0, SRCCOPY
	ECInvoke Sleep, 60 ;flash stamp
	ECInvoke PatBlt, hdcMem, xTo, 0, stamp, rcRect.bottom, DSTINVERT
	ECInvoke BitBlt, hdc, 0, 0, rcRect.right, rcRect.bottom, hdcMem, 0, 0, SRCCOPY
	;ECInvoke Sleep, 30 ;flash stamp
	ECInvoke UpdateInWindow, hWnd
	Mov Eax, stamp

	Add xTo, Eax
	Mov Eax, rcRect.right
	Cmp xTo, Eax
	Jb _loop_brush_to

	ECInvoke DeleteDC, hdc
	ECInvoke ReleaseDC, hWnd, hdc
	ECInvoke DeleteObject, hBitmap
	ECInvoke DeleteDC, hdcMem
	#
	ECInvoke Sleep, 1000
	ECInvoke PostMessage, hWnd, WM_SYSCOMMAND, SC_CLOSE, 0
	;ECInvoke PostMessage, hWnd, WM_SHOW_CMD_TIP_FINISH, 0, 0
	;ECInvoke DestroyWindow, hWnd
	Ret
BrushWindowThread EndP

BrushWindow Proc hWnd:QWord
	Mov hWnd, Rcx
	ECInvoke CreateThread, 0, 0, Addr BrushWindowThread, hWnd, 0, 0
	Ret
BrushWindow EndP

DrawTextExt Proc hDc:QWord, pRectDc:QWord, pText:QWord, fColor:DWord, xpos:DWord, ypos:DWord, hFont:QWord
	Local memDC:HDC
	Local memBitmap:HBITMAP
	Local xForm:XFORM
	Local lRect:RECT

	Mov hDc, Rcx
	Mov pRectDc, Rdx
	Mov pText, R8
	Mov fColor, R9d

	ECInvoke memcpy, Addr lRect, pRectDc, SizeOf RECT

    ; 创建内存DC以便后续绘制
    ECInvoke CreateCompatibleDC, hDc
    Mov memDC, Rax
    ECInvoke CreateCompatibleBitmap, hDc, lRect.right, lRect.bottom
    Mov memBitmap, Rax

    ECInvoke SelectObject, memDC, memBitmap

	ECInvoke BitBlt, memDC, lRect.left, lRect.top, lRect.right, lRect.bottom, hDc, 0, 0, SRCCOPY
    ;设置背景透明
    ECInvoke SetBkMode, memDC, TRANSPARENT


    ECInvoke SelectObject, memDC, hFont
    ECInvoke SetTextColor, memDC, fColor

    ECInvoke lstrlen, pText

    ECInvoke TextOut, memDC, xpos, ypos, pText, Rax

    ; 复制到屏幕上
    ECInvoke BitBlt, hDc, lRect.left, lRect.top, lRect.right, lRect.bottom, memDC, 0, 0, SRCCOPY

    ;清理资源
    ECInvoke DeleteObject, memBitmap
    ECInvoke DeleteDC, memDC
	Ret
DrawTextExt EndP


DrawResIcon Proc hDc:QWord, pRect:QWord, resId:QWord
	Local hIcon:HICON
	Local lRect:RECT
	Mov hDc, Rcx
	Mov pRect, Rdx
	Mov resId, R8
	ECInvoke memcpy, Addr lRect, pRect, SizeOf RECT

	ECInvoke GetModuleHandle, NULL
	ECInvoke LoadIcon, Rax, resId

	Mov hIcon, Rax
	ECInvoke DrawIconEx, hDc, lRect.left, lRect.top, hIcon, lRect.right, lRect.bottom, 0, 0, DI_NORMAL
	;ECInvoke DrawIcon, hDc, lRect.left, lRect.top, hIcon
	ECInvoke DestroyIcon, hIcon
	Ret
DrawResIcon EndP

GetVersionString Proc
	Local hResource:HRSRC
	Local hResourceData:HGLOBAL
	Local pResource:QWord
	Local pFileVersion:QWord
	Local dwLen:QWord
	Local hModule:HMODULE
	Local pStr:QWord
	Local va, vb, vc, vd:DWord
	ECInvoke GetModuleHandle, NULL
	Mov hModule, Rax
    ECInvoke FindResource, Rax, VS_VERSION_INFO, RT_VERSION
    Mov hResource, Rax
    Cmp hResource, 0
    Je exit
        ECInvoke LoadResource, hModule, hResource
        Mov hResourceData, Rax
        Cmp hResourceData, 0
        Je exit
            ECInvoke LockResource, hResourceData
            Mov pResource, Rax
            Cmp pResource, 0
            Je exit

                ;VS_FIXEDFILEINFO
                ECInvoke VerQueryValue, pResource, CTXT("\\"), Addr pFileVersion, Addr dwLen
                    Cmp dwLen, SizeOf VS_FIXEDFILEINFO
                    Jb exit
                    ECInvoke NewStr, 0, 150
                    Mov pStr, Rax
                    Mov Rax, pFileVersion

                    Mov Ecx, [Rax].VS_FIXEDFILEINFO.dwFileVersionMS
                    _HIWORD Ecx
                    Mov va, Ecx
                    Mov Ecx, [Rax].VS_FIXEDFILEINFO.dwFileVersionMS
                    _LOWORD Ecx
                    Mov vb, Ecx
                    Mov Ecx, [Rax].VS_FIXEDFILEINFO.dwFileVersionLS
                    _HIWORD Ecx
                    Mov vc, Ecx
                    Mov Ecx, [Rax].VS_FIXEDFILEINFO.dwFileVersionLS
                    _LOWORD Ecx
                    Mov vd, Ecx

					ECInvoke FormatStr, pStr, CTXT("%d.%d.%d.%d"), va, vb, vc, vd, 0
					Mov Rax, pStr
					Ret

exit:
	Xor Eax, Eax
	Ret
GetVersionString EndP

FlashBorder Proc hWnd:HWND, delay:QWord, flashCount:QWord
	Local count:QWord
	Mov hWnd, Rcx
	Mov delay, Rdx
	Mov flashCount, R8
	Mov count, 0
loop_flash:
	ECInvoke HilightWindowBorder, hWnd
	ECInvoke Sleep, delay
	ECInvoke HilightWindowBorder, hWnd
	ECInvoke Sleep, delay
	Inc count
	Mov Rax, count
	Cmp Rax, flashCount
	Jb loop_flash
	Ret
FlashBorder EndP


HilightWindowBorder Proc hWnd:QWord
	Local hRgn:HRGN
	Local hdc:HDC
	Local hBrush:HBRUSH
	Local sysColor:COLORREF
	Local wRect:RECT
	Local hZoom:HWND
	Local x, y, iW, iH:DWord
	Mov hWnd, Rcx
	ECInvoke GetWindowRect, hWnd, Addr wRect
	Lea Rax, wRect
	RECT_TO_XYWH Rax, x, y, iW, iH
	Mov x, 0
	Mov y, 0


;	ECInvoke GetRootWindow, hWnd
	ECInvoke GetWindowDC, hWnd
	Mov hdc, Rax
	ECInvoke SetROP2, hdc, R2_NOT

;	ECInvoke IsZoomed, hWnd
;	Test Eax, Eax
;	Jz zoom
	ECInvoke GetStockObject, NULL_BRUSH
	ECInvoke SelectObject, hdc, Rax
	ECInvoke GetSysColor, COLOR_HOTLIGHT
	ECInvoke CreateHatchBrush, HS_DIAGCROSS, Rax
	Mov hBrush, Rax
	ECInvoke CreateRectRgn, x, y, iW, iH
	;ECInvoke CreateRectRgn, 0, 0, 0, 0
	Mov hRgn, Rax
	;ECInvoke GetWindowRgn, hWnd, hRgn
	;ECInvoke FillRgn, hdc, hRgn, hBrush
    ECInvoke FrameRgn, hdc, hRgn, hBrush, 4, 4

	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn
	ECInvoke DeleteDC, hdc
	ECInvoke ReleaseDC, hWnd, hdc
	Ret
HilightWindowBorder EndP

GetProcessFilePath Proc pid:QWord
	Local hProcess:HANDLE
	Local exePathlen:QWord
	Local lpExePath:QWord

	Mov pid, Rcx


	ECInvoke OpenProcess, PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid
	Mov hProcess, Rax
	Test Eax, Eax
	Jz exit

	ECInvoke NewStr, 0, MAX_PATH
	Mov lpExePath, Rax
	Mov exePathlen, MAX_PATH
	ECInvoke QueryFullProcessImageName, hProcess, 0, lpExePath, Addr exePathlen, Addr exePathlen
	ECInvoke CloseHandle, hProcess
	Mov Rax, lpExePath
	Ret
exit:
	Xor Eax, Eax
	Ret
GetProcessFilePath EndP

;return rax 命令行,rcx 参数行
GetProcessArgLine Proc pid:QWord
	Local hProcess:HANDLE
	Local exePathlen:QWord
	Local pArgline:QWord
	Local pbi:PROCESS_BASIC_INFORMATION
	Local returnLength:DWord
	Local pPeb:QWord
	Local PebWin10:_PEBWin10
	Local PebWin7:_PEBWin7
	Local bytesRead:DWord
	Local params:_RTL_USER_PROCESS_PARAMETERS
	Local pSrcCmdLine:QWord
	Local pAarg:QWord
	Mov pid, Rcx

	Mov pAarg, 0

	ECInvoke OpenProcess, PROCESS_ALL_ACCESS, FALSE, pid

	Mov hProcess, Rax
	Test Eax, Eax
	Jz exit
	BEGIN_CALL 50H
	Lea Rax, returnLength
	Mov [Rsp + 8 * 4], Rax	;arg 5
	Mov R9, SizeOf pbi
	Lea R8, pbi
	Mov Rdx, ProcessBasicInformation
	Mov Rcx, hProcess
	Call pfNtQueryInformationProcess
	END_CALL 50H


	ECInvoke IsWin7
	Test Eax, Eax
	Jz notWin7
		ECInvoke ReadProcessMemory, hProcess, pbi.PebBaseAddress, Addr PebWin7, SizeOf PebWin7, Addr bytesRead
		Mov Rdx, PebWin7.pProcessParameters
	jmp readPath
notWin7:
		ECInvoke ReadProcessMemory, hProcess, pbi.PebBaseAddress, Addr PebWin10, SizeOf PebWin10, Addr bytesRead
		Mov Rdx, PebWin10.pProcessParameters
readPath:
	ECInvoke ReadProcessMemory, hProcess, Rdx, Addr params, SizeOf params, Addr bytesRead

	ECInvoke NewStr, 0, MAX_PATH * SizeOf DWord
	Mov pArgline, Rax

	Mov Rax, params.CommandLine.Buffer
	Mov pSrcCmdLine, Rax
	ECInvoke ReadProcessMemory, hProcess, pSrcCmdLine, pArgline, MAX_PATH * SizeOf DWord, Addr bytesRead
	ECInvoke WideCharToPChar, pArgline

	Push Rax
	Cmp Byte Ptr [Rax], '"'
	Jnz @F
	Inc Rax
@@:
	ECInvoke NewStr, Rax, 0
	Mov pSrcCmdLine, Rax
	Pop Rcx
	ECInvoke DelStr, Rcx
	ECInvoke StrStr, pSrcCmdLine, CTXT('" ')

	Test Rax, Rax
	Jz noSpec
		Mov Byte Ptr [Rax], 0
		Inc Rax
		Mov Byte Ptr [Rax], 0
		Inc Rax
		Mov pAarg, Rax
noSpec:

	Cmp pAarg, 0
	Jne l1
	ECInvoke StrRChr, pSrcCmdLine, 0, '"'
	Jmp l2
l1:
	ECInvoke StrRChr, pAarg, 0, '"'
l2:
	Test Rax, Rax
	Jz noArg
		Mov Byte Ptr [Rax], 0
		Inc Rax
		Mov Byte Ptr [Rax], 0
		Inc Rax
noArg:

	;ECInvoke MessageBox, 0, Rax, Rax, 0
	ECInvoke CloseHandle, hProcess
	Mov Rcx, pAarg
	Mov Rax, pSrcCmdLine

	Ret
	
exit:

	Xor Eax, Eax
	Ret
GetProcessArgLine EndP

GetProcessArgLine1 Proc pid:QWord
	Local hProcess:HANDLE
	Local pSrcArg:QWord
	Local dwAddr:QWord
	Mov pid, Rcx

	Mov dwAddr, 0
	ECInvoke OpenProcess, PROCESS_ALL_ACCESS, FALSE, pid
	Mov hProcess, Rax
	Test Eax, Eax
	Jz exit

	Mov Rdx, pfGetCommandLineW
	Add Rdx, 3
	ECInvoke ReadProcessMemory, hProcess, Rdx, Addr dwAddr, SizeOf DWord, 0


	ECInvoke NewStr, 0, MAX_PATH * 2
	Mov pSrcArg, Rax
	Mov Rdx, pfGetCommandLineW
	Mov Rax, dwAddr
	Add Rdx, Rax
	Add Rdx, 7;instrument lenght

	ECInvoke ReadProcessMemory, hProcess, Rdx, Addr dwAddr, SizeOf QWord, 0
	ECInvoke ReadProcessMemory, hProcess, dwAddr, pSrcArg, MAX_PATH * 2, 0
	ECInvoke WideCharToPChar, pSrcArg
	Push Rax
	ECInvoke MessageBox, 0, Rax, Rax, 0
	ECInvoke CloseHandle, hProcess
	ECInvoke DelStr, pSrcArg
	Pop Rax

	Ret

exit:
	Xor Eax, Eax
	
	Ret
GetProcessArgLine1 EndP

IsWin7 Proc

    Local bOSWin7OrAbove:BOOL
 	Local dwLevel:DWord
 	Local lpWkStaInfo100:QWord;_WKSTA_INFO_100
 	Local statusRet:DWord
	;下面要调用NetWkstaGetInfo
	Mov dwLevel, 100;

	ECInvoke NetWkstaGetInfo, NULL, dwLevel, Addr lpWkStaInfo100
	Mov statusRet, Eax

	Cmp statusRet, 0
	Jne exit
		;win8及以上版本
		Mov Rax, lpWkStaInfo100
		Mov Ecx, [Rax]._WKSTA_INFO_100.wki100_ver_major
		;Mov R8d, [Rax]._WKSTA_INFO_100.wki100_ver_minor
		Cmp Ecx, 6
		Jbe exit
		;Cmp R8d, 1
		;Jbe exit

		;Free the allocated memory
		Cmp lpWkStaInfo100, 0
		Je exit
		ECInvoke NetApiBufferFree, lpWkStaInfo100
			Xor Eax, Eax
			Ret
exit:
	Mov Eax, 1
	Ret
IsWin7 EndP


EnablePrivilege Proc privName:QWord
	Local token:HANDLE
	Local tkp:TOKEN_PRIVILEGES
	;提升权限
	Mov privName, Rcx

	ECInvoke GetCurrentProcess
	ECInvoke OpenProcessToken, Rax, TOKEN_ADJUST_PRIVILEGES, Addr token
	Test Eax, Eax
	Jz exit

	Mov tkp.PrivilegeCount, 1

	Lea R8, tkp.Privileges
	Lea R8, [R8].LUID_AND_ATTRIBUTES.Luid

	ECInvoke LookupPrivilegeValue, NULL, privName, R8

	Lea Rax, tkp.Privileges
	Mov [Rax].LUID_AND_ATTRIBUTES.Attributes, SE_PRIVILEGE_ENABLED
	ECInvoke AdjustTokenPrivileges, token, FALSE, Addr tkp, SizeOf tkp, NULL, NULL
	Test Eax, Eax
	Jz exit

	ECInvoke CloseHandle, token
	Mov Eax, 1
	Ret
exit:
	Xor Eax, Eax
	Ret
EnablePrivilege EndP

GetWebPageThread Proc pArgs:QWord
	Local pUrl:QWord
	Local pAgent:QWord
	Local pCallback:QWord
	Mov pArgs, Rcx

	Mov Rax, [Rcx]
	Mov pUrl, Rax
	Mov Rax, [Rcx + 8]
	Mov pAgent, Rax
	Mov Rax, [Rcx + 8 * 2]
	Mov pCallback, Rax
	ECInvoke GetWebPage, pUrl, pAgent

	Mov Rcx, Rax
	BEGIN_CALL 20H
	Call pCallback
	END_CALL 20H


	ECInvoke GlobalFree, pArgs

	Ret
GetWebPageThread EndP

GetWebPageAsync Proc pUrl:QWord, pAgent:QWord, pCallback:QWord

	Mov pUrl, Rcx
	Mov pAgent, Rdx
	Mov pCallback, R8
	ECInvoke GlobalAlloc, GPTR, 8 * 3
	Mov Rcx, pUrl
	Mov [Rax], Rcx
	Mov Rcx, pAgent
	Mov [Rax + 8], Rcx
	Mov Rcx, pCallback
	Mov [Rax + 8 * 2], Rcx
	ECInvoke CreateThread, 0, 0, Addr GetWebPageThread, Rax, 0, 0
	Ret
GetWebPageAsync EndP

GetWebPage Proc pUrl:QWord, pAgent:QWord
	Local hInternet:QWord
	Local hConnect:QWord
	Local bytesRead:QWord
	Local pReadBuff:QWord
	Local pTmp:QWord
	Local totalSize:QWord
	Mov pUrl, Rcx
	Mov pAgent, Rdx

	ECInvoke InternetOpen, pAgent, INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0
	Mov hInternet, Rax
	Test Eax, Eax
	Jz exit


	ECInvoke InternetOpenUrl, hInternet, pUrl, NULL, 0, INTERNET_FLAG_RELOAD, 0
	Mov hConnect, Rax
	Test Eax, Eax
	Jz exit


	Mov bytesRead, 0
	Mov totalSize, 0
	ECInvoke NewStr, 0, 4096
	Mov pReadBuff, Rax

	Mov Rax, pReadBuff
	Mov pTmp, Rax
loopRead:
	ECInvoke InternetReadFile, hConnect, pTmp, 4096 - 1, Addr bytesRead
	Mov Rax, pTmp
	Add Rax, bytesRead
	Mov pTmp, Rax
	Mov Rax, bytesRead
	Add totalSize, Rax
	Cmp bytesRead, 0
	Jg loopRead

exit:
	ECInvoke InternetCloseHandle, hConnect
	ECInvoke InternetCloseHandle, hInternet
	Mov Rax, pReadBuff
	Mov Rcx, totalSize
	Ret
GetWebPage EndP

ActivateWindow Proc pClass:QWord, pTitle:QWord
	Local hWnd:HWND
	Local foregroundThreadID:DWord
	Local currentThreadID:DWord
	Mov pClass, Rcx
	Mov pTitle, Rdx

	ECInvoke FindWindow, pClass, pTitle
	Mov hWnd, Rax
	Test Eax, Eax
	Jz exit

		ECInvoke ShowWindow, hWnd, SW_SHOW

		ECInvoke GetWindowThreadProcessId, hWnd, NULL
		Mov foregroundThreadID, Eax
		ECInvoke GetCurrentThreadId
		Mov currentThreadID, Eax
		;将当前线程附加到窗口线程，确保后续操作在窗口线程中执行
		ECInvoke AttachThreadInput, Rax, foregroundThreadID, TRUE

		;设置窗口为顶层
		ECInvoke SetWindowPos, hWnd, HWND_TOPMOST, 0, 0, 0, 0, (SWP_NOMOVE OR SWP_NOSIZE)
		ECInvoke SetWindowPos, hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, (SWP_NOMOVE OR SWP_NOSIZE)

		;激活窗口并将焦点设置到窗口
		ECInvoke SetForegroundWindow, hWnd
		ECInvoke SetFocus, hWnd
		ECInvoke SetActiveWindow, hWnd
		;解除线程附加
		ECInvoke AttachThreadInput, currentThreadID, foregroundThreadID, FALSE
exit:
	Ret
ActivateWindow EndP


IsAnotherInstanceRunning Proc pInstName:QWord
	Local hMutex:HANDLE
	Mov pInstName, Rcx

	ECInvoke CreateMutex, NULL, TRUE, pInstName
	Mov hMutex, Rax
	Test Eax, Eax
	Jz exit
	ECInvoke GetLastError
	Cmp Rax, ERROR_ALREADY_EXISTS
	Jne exit
	ECInvoke CloseHandle, hMutex
	Mov Eax, 1
	Ret
exit:
	Xor Eax, Eax
	Ret
IsAnotherInstanceRunning EndP


ShutdownComputer Proc
	ECInvoke EnablePrivilege, SE_SHUTDOWN_NAME
	ECInvoke ExitWindowsEx, (EWX_POWEROFF OR EWX_FORCE), 0
	Ret
ShutdownComputer EndP

RebootComputer Proc
	ECInvoke EnablePrivilege, SE_SHUTDOWN_NAME
	ECInvoke ExitWindowsEx, (EWX_REBOOT OR EWX_FORCE), 0
	Ret
RebootComputer EndP

;rax=dc,rdx=bitmap
CreateMemDC Proc srcDC:HDC, iW:DWord, iH:DWord
	Local hDc:HDC
	Local hBitmap:HBITMAP
	Local hMemDc:HDC

	Mov srcDC, Rcx
	Mov iW, Edx
	Mov iH, R8d

	Mov hDc, Rcx

	Cmp srcDC, 0
	Jnz hasDc
		ECInvoke GetDC, NULL
		Mov hDc, Rax
hasDc:
	ECInvoke CreateCompatibleBitmap, hDc, iW, iH
	Mov hBitmap, Rax


	ECInvoke CreateCompatibleDC, hDc
	Mov hMemDc, Rax


	ECInvoke SelectObject, hMemDc, hBitmap
	Cmp srcDC, 0
	Jnz @F
	ECInvoke DeleteDC, hDc
@@:
	Mov Rax, hMemDc
	Mov Rcx, hBitmap
	Ret
CreateMemDC EndP

CheckRunMode Proc pExePath:QWord
	Mov pExePath, Rcx
	Int 3
	ECInvoke StrStr, pExePath, CTXT("chrome.exe")
	Ret
CheckRunMode EndP

PopBox Proc pText:QWord
	Mov pText, Rcx
	ECInvoke MessageBox, 0, pText, 0, 0
	Ret
PopBox EndP

GetDesktopLnkList Proc pDbList:QWord
	Local findFileData:WIN32_FIND_DATA
	Local pDesktopPath:QWord
	Local pDesktopTmp:QWord
	Local hFind:QWord
	Local valLen:QWord
	Local pTmpPath:QWord
	Mov pDbList, Rcx

	ECInvoke NewStr, 0, MAX_PATH * 2
	Mov pDesktopPath, Rax
	ECInvoke NewStr, 0, MAX_PATH * 2
	Mov pTmpPath, Rax
	
	ECInvoke SHGetFolderPath, NULL, CSIDL_DESKTOP, NULL, 0, pDesktopPath
	ECInvoke NewStr, pDesktopPath, 0
	Mov pDesktopTmp, Rax

	ECInvoke lstrcat, pDesktopPath, CTXT("\*")
    ECInvoke FindFirstFile, pDesktopPath, Addr findFileData
    Cmp Rax, INVALID_HANDLE_VALUE
    Je @F
	Mov hFind, Rax
found:
	Mov Eax, findFileData.dwFileAttributes
	And Eax, FILE_ATTRIBUTE_DIRECTORY
	Test Eax, Eax
	Jne notfile	;不是文件

	Lea Rax, findFileData.cFileName

	ECInvoke IsExtName, Addr findFileData.cFileName, CTXT(".lnk")
	Cmp Rax, TRUE
	Je islink;是快捷方式
	ECInvoke IsExtName, Addr findFileData.cFileName, CTXT(".url")
	Cmp Rax, 0
	Je notfile;不是url快捷方式
islink:
		ECInvoke ZeroMemory, pTmpPath, MAX_PATH * 2
		ECInvoke FormatStr, pTmpPath, CTXT("%s\%s"), pDesktopTmp, Addr findFileData.cFileName, 0, 0, 0
		Mov valLen, Rax
		;ECInvoke WriteLog, pTmpPath, 1
		;插入链表
		ECInvoke InsertDLAtBegin, pDbList, pTmpPath, valLen
notfile:
	ECInvoke FindNextFile, hFind, Addr findFileData
	Test Rax, Rax
	Jnz found
	ECInvoke FindClose, hFind
@@:
	ECInvoke DelStr, pDesktopPath
	ECInvoke DelStr, pDesktopTmp
	ECInvoke DelStr, pTmpPath
	Ret
GetDesktopLnkList EndP


;rax 1=lnk,url , 2=exe ,0=not
IsLinkInCmdList Proc pLinkPath:QWord, pOutCmdn:QWord
	Local pOutSize:QWord
	Local dbLinkList:HANDLE_MALLOC
	Local pCmdskValue:QWord
	Local value[100]:DB
	Local kname[40]:DB
	Local keyIdx:QWord
	Local pCmdsNode:QWord
	Local pExcPath:QWord

	Mov pLinkPath, Rcx
	Mov pOutCmdn, Rdx

	ECInvoke ZeroMemory, Addr dbLinkList, SizeOf HANDLE_MALLOC

	ECInvoke NewStr, 0, MAX_PATH
	Mov pExcPath, Rax

	ECInvoke NewStr, 0, 1024
	Mov pCmdskValue, Rax

	ECInvoke ReadAutoCmdsList, Addr dbLinkList

	Lea Rax, dbLinkList
	Mov pCmdsNode, Rax

loopdl2:
	ECInvoke ZeroMemory, pCmdskValue, 1024
	ECInvoke GetDLNodeValue, pCmdsNode, pCmdskValue, Addr pOutSize

	;ECInvoke WriteLog, pCmdskValue, 1
	;解析每条命令的key=val
	Mov keyIdx, 0
	ECInvoke GetLnkPathInfo, pLinkPath, pExcPath, 0, 0

	;是否读取命令名
	Cmp pOutCmdn, 0
	Je @F
	ECInvoke GetKeyValue, pCmdskValue, CTXT("cmdn"), pOutCmdn
@@:


redKey:

	ECInvoke ZeroMemory, Addr kname, SizeOf kname
	ECInvoke ZeroMemory, Addr value, SizeOf value
	ECInvoke FormatStr, Addr kname, CTXT("key%d"), keyIdx, 0, 0, 0, 0
	ECInvoke GetKeyValue, pCmdskValue, Addr kname, Addr value


	;判断是否为空内容
	Lea Rax, value
	Cmp QWord Ptr [Rax], 0
	Je nextNode
	;判断是否在本条命令中
	ECInvoke StrRStr, pLinkPath, 0, Addr value
	Test Rax, Rax
	Jz notLnkUrl
	;搜索.lnk,.url,确认是不是字符串结尾
	Push Rax
	ECInvoke lstrlen, Rax
	Pop Rcx
	Cmp Byte Ptr [Rcx + Rax], 0
	Jnz notLnkUrl
	;找到.lnk,.url
	Mov Rax, 1
	Jmp exit
notLnkUrl:
	;搜索.exe
	ECInvoke StrRStr, pExcPath, 0, Addr value
	Test Rax, Rax
	Jz notOther
	;搜索.其他,确认是不是字符串结尾
	Push Rax
	ECInvoke lstrlen, Rax
	Pop Rcx
	Cmp Byte Ptr [Rcx + Rax], 0
	Jnz notOther
	;处理搜所到的exe
	Mov Rax, 2
	Jmp exit
notOther:
	Inc keyIdx
	Lea Rax, value
	Cmp Byte Ptr [Rax], 0
	Jnz redKey

nextNode:
	ECInvoke GetNextDLNode, pCmdsNode
	Mov pCmdsNode, Rax
	ECInvoke IsDLNodeEqual, pCmdsNode, Addr dbLinkList
	Cmp Rax, TRUE
	Jnz loopdl2
	Xor Eax, Eax
exit:
	Push Rax

	ECInvoke DelStr, pCmdskValue
	ECInvoke DelStr, pExcPath
	ECInvoke DestoryDLLink, Addr dbLinkList

	Pop Rax
	Ret
IsLinkInCmdList EndP

InitCrc32 Proc pTable:QWord
	Local polynomial:DWord
	Local i:DWord
	Local j:DWord
	Local crc:DWord
	Mov pTable, Rcx
	Mov polynomial, 0EDB88320H
	Mov i, 0
	Jmp @F
loopbuild:
	Inc i
@@:
	Cmp i, 100H
	Jae exit
	Mov Eax, i
	Mov crc, Eax
	Mov j, 8
	Jmp @F
loopcrc:
	Mov Eax, j
	Dec Eax
	Mov j, Eax
@@:
	Cmp j, 0
	Jbe savecrc
	Mov Eax, crc
	And Eax, 1
	Test Eax, Eax
	Je clc1
	Mov Eax, crc
	Shr Eax, 1
	Xor Eax, polynomial
	Mov crc, Eax
	Jmp @F
clc1:
	Mov Eax, crc
	Shr Eax, 1
	Mov crc, Eax
@@:Jmp loopcrc
savecrc:
	Mov Eax, i
	Mov Rcx, pTable
	Mov Edx, crc
	Mov DWord Ptr [Rcx + Rax * 4], Edx
	jmp         loopbuild
exit:
	Ret
InitCrc32 EndP

CalcCrc32 Proc pData:QWord, dLen:DWord, pTable:QWord
	Local i:DWord
	Local crc32val:DWord

	Mov pTable, R8
	Mov dLen, Edx
	Mov pData, Rcx
	Mov crc32val, 0
	Mov i, 0
	Jmp calc1
loopcalc:
	Inc i
calc1:
	Mov Eax, dLen
	Cmp i, Eax
	Jae exit
	Mov Eax, i
	Mov Rcx, pData
	Movzx Eax, Byte Ptr [Rcx + Rax]
	Mov Ecx, crc32val
	Xor Ecx, Eax
	Mov Eax, Ecx
	And Eax, 0FFH
	Mov Eax, Eax
	Mov Ecx, crc32val
	Shr Ecx, 8
	Mov Rdx, pTable
	Mov Eax, DWord Ptr [Rdx + Rax * 4]
	Xor Eax, Ecx
	Mov crc32val, Eax
	Jmp loopcalc
exit:
	Mov Eax, crc32val
	Ret
	comment #
	Local crc:DWord
	Local i:QWord
	Local index:Byte
	Mov pTable, R8
	Mov dLen, Rdx
	Mov pData, Rcx
	Mov crc, 0FFFFFFFFH
	Mov i, 0
	Mov index, 0
	Jmp getlen
loopcrc32:
	Inc i
getlen:
	Mov Rax, dLen
	Cmp i, Rax
	Jae exit
	Mov Eax, crc
	And Eax, 0FFH
	Mov Rcx, i
	Mov Rdx, pData
	Add Rdx, Rcx
	Mov Rcx, Rdx
	Movzx Ecx, Byte Ptr [Rcx]
	Xor Eax, Ecx
	Mov index, Al
	Mov Eax, crc
	Shr Eax, 8
	Movzx Ecx, index
	Mov Rdx, pTable
	Xor Eax, DWord Ptr [Rdx + Rcx * 4]
	Mov crc, Eax
	Jmp loopcrc32
exit:
	Mov Eax, crc
	Not Eax
	Ret
	#
CalcCrc32 EndP


;10,397
