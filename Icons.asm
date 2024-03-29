;EasyCodeName=Icons,1
.Const
	ID_ICON_BACK_ARROR Equ 101H
	ID_ICON_GUN_SIGHT	Equ 102H
	ID_ICON_TRIANGLE_LEFT	Equ 103H
	ID_ICON_TRIANGLE_RIGHT	Equ 104H
	ID_ICON_POWER_ON	Equ 105H
	ID_ICON_X	Equ 106H
	ID_ICON_CROSS Equ 107H
	ID_ICON_UPGRADE Equ 108H
	ID_ICON_IMPORT Equ 109H
.Data?


.Data

.Code

Icon_Import Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local middleX:DWord
	Local iW:DWord
	Local iH:DWord
	Local pts[4]:POINT	;三角形4个点

	Local pIconObject:QWord
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Local hPenNormalBig:HPEN
	Local hPenNormalSml:HPEN
	Local hPenTransBig:HPEN
	Local hPenTransSml:HPEN
	Local hRgn:HRGN

	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;1/2 height
	Mov Eax, iW
	Sub Eax, x
	Shr Eax, 1
	Mov R8d, x
	Add Eax, R8d
	Mov middleX, Eax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax



	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

;	ECInvoke CreateSolidBrush, normalColor
;	Mov hBrush, Rax


	;创建画笔
	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax

	ECInvoke CreatePen, PS_SOLID, 4, normalColor
	Mov hPenNormalBig, Rax

	ECInvoke CreatePen, PS_SOLID, 1, normalColor
	Mov hPenNormalSml, Rax

	ECInvoke CreatePen, PS_SOLID, 12, TRANS_COLOR
	Mov hPenTransBig, Rax

	ECInvoke CreatePen, PS_SOLID, 1, TRANS_COLOR
	Mov hPenTransSml, Rax
	ECInvoke SelectObject, hMemDc, hPenNormalBig
	;画圆

	Mov R9d, iH
	Shr R9d, 1
	Mov R8d, iH
	Sub R8d, 2
	ECInvoke CreateEllipticRgn, x, R8, iW, R9
	Mov hRgn, Rax
	ECInvoke FrameRgn, hMemDc, hRgn, hBrush, 1, 1

	;擦除画直线|
	ECInvoke SelectObject, hMemDc, hPenTransBig
	Mov Edx, middleX
	Sub Edx, 1
	Mov R8d, y
	Add R8d, 4
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, middleX
	Sub Edx, 1
	Mov R8d, iH
	Sub R8d, 11
	ECInvoke LineTo, hMemDc, Rdx, R8

	;中间第一个点
	Lea Rax, pts
	Mov Ecx, middleX
	Sub Ecx, 1
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, iH
	Sub Ecx, 7
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第2个点左
	Add Rax, SizeOf POINT
	Mov Ecx, middleX
	Sub Ecx, 4
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Sub Ecx, 2
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第3个右
	Add Rax, SizeOf POINT
	Mov Ecx, middleX
	Add Ecx, 4
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Sub Ecx, 2
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第4个点重合第1个
	Add Rax, SizeOf POINT
	Mov Ecx, middleX
	Sub Ecx, 1
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, iH
	Sub Ecx, 7
	Mov DWord Ptr [Rax + POINT.y], Ecx

	ECInvoke CreatePolygonRgn, Addr pts, SizeOf pts / SizeOf POINT, ALTERNATE
	Mov hRgn, Rax
	ECInvoke FillRgn, hMemDc, hRgn, hBrush

	;画箭头柄|
	ECInvoke SelectObject, hMemDc, hPenNormalBig
	Mov Edx, middleX
	Mov R8d, y
	Add R8d, 2
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, middleX
	Mov R8d, iH
	Shr R8d, 1
	Sub R8d, 2
	ECInvoke LineTo, hMemDc, Rdx, R8

	ECInvoke DeleteObject, hPenNormalBig
	ECInvoke DeleteObject, hPenNormalSml
	ECInvoke DeleteObject, hPenTransSml
	ECInvoke DeleteObject, hPenTransBig
	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn

	Mov Rax, pIconObject
	Ret
Icon_Import EndP

Icon_Gunsight Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local middleX:DWord
	Local iW:DWord
	Local iH:DWord
	Local pts[4]:POINT	;三角形4个点

	Local pIconObject:QWord
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Local hPenNormalBig:HPEN
	Local hPenNormalSml:HPEN
	Local hPenTransBig:HPEN
	Local hPenTransSml:HPEN
	Local hRgn:HRGN

	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;1/2 height
	Mov Eax, iW
	Sub Eax, x
	Shr Eax, 1
	Mov R8d, x
	Add Eax, R8d
	Mov middleX, Eax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax



	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

;	ECInvoke CreateSolidBrush, normalColor
;	Mov hBrush, Rax


	;创建画笔
	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax

	ECInvoke CreatePen, PS_SOLID, 2, normalColor
	Mov hPenNormalBig, Rax

	ECInvoke CreatePen, PS_SOLID, 1, normalColor
	Mov hPenNormalSml, Rax

	ECInvoke CreatePen, PS_SOLID, 2, TRANS_COLOR
	Mov hPenTransBig, Rax

	ECInvoke CreatePen, PS_SOLID, 1, TRANS_COLOR
	Mov hPenTransSml, Rax
	ECInvoke SelectObject, hMemDc, hPenNormalBig
	;画圆


	ECInvoke CreateEllipticRgn, x, y, iW, iH
	Mov hRgn, Rax
	ECInvoke FrameRgn, hMemDc, hRgn, hBrush, 1, 1

	ECInvoke SelectObject, hMemDc, hPenNormalSml
	Mov Edx, x
	Add Edx, 3
	Mov R8d, y
	Add R8d, 3

	Mov R9d, iW
	Sub R9d, 4
	Mov Eax, iH
	Sub Eax, 4
	ECInvoke Ellipse, hMemDc, Rdx, R8, R9, Rax


	Mov Edx, x
	Add Edx, 6
	Mov R8d, y
	Add R8d, 6

	Mov R9d, iW
	Sub R9d, 7
	Mov Eax, iH
	Sub Eax, 7
	ECInvoke Ellipse, hMemDc, Rdx, R8, R9, Rax



	;擦除画直线\
	ECInvoke SelectObject, hMemDc, hPenTransBig
	Mov Edx, x
	Add Edx, 5
	Mov R8d, y
	Add R8d, 5
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, iW
	Sub Edx, 7
	Mov R8d, iH
	Sub R8d, 7
	ECInvoke LineTo, hMemDc, Rdx, R8

	;擦除画直线/
	Mov Edx, iW
	Sub Edx, 6
	Mov R8d, y
	Add R8d, 5
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, x
	Add Edx, 5
	Mov R8d, iH
	Sub R8d, 6
	ECInvoke LineTo, hMemDc, Rdx, R8


	;画直线|
	ECInvoke SelectObject, hMemDc, hPenNormalSml
	Mov Edx, middleX
	Sub Edx, 1
	Mov R8d, y
	Add R8d, 4
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, middleX
	Sub Edx, 1
	Mov R8d, iH
	Sub R8d, 4
	ECInvoke LineTo, hMemDc, Rdx, R8

	;画直线-
	Mov Edx, x
	Add Edx, 4
	Mov R8d, middleY
	Sub R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, iW
	Sub Edx, 4
	Mov R8d, middleY
	Sub R8d, 1
	ECInvoke LineTo, hMemDc, Rdx, R8

	ECInvoke DeleteObject, hPenNormalBig
	ECInvoke DeleteObject, hPenNormalSml
	ECInvoke DeleteObject, hPenTransSml
	ECInvoke DeleteObject, hPenTransBig
	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn

	Mov Rax, pIconObject
	Ret
Icon_Gunsight EndP

Icon_Upgrade Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local middleX:DWord
	Local iW:DWord
	Local iH:DWord
	Local pts[4]:POINT	;三角形4个点

	Local pIconObject:QWord
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Local hPenNormalBig:HPEN
	Local hPenNormalSml:HPEN
	Local hPenTransBig:HPEN
	Local hPenTransSml:HPEN
	Local hRgn:HRGN

	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;1/2 height
	Mov Eax, iW
	Sub Eax, x
	Shr Eax, 1
	Mov R8d, x
	Add Eax, R8d
	Mov middleX, Eax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax



	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

;	ECInvoke CreateSolidBrush, normalColor
;	Mov hBrush, Rax


	;创建画笔
	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax
	ECInvoke CreatePen, PS_SOLID, 3, normalColor
	Mov hPenNormalBig, Rax
	ECInvoke CreatePen, PS_SOLID, 1, normalColor
	Mov hPenNormalSml, Rax
	ECInvoke CreatePen, PS_SOLID, 4, TRANS_COLOR
	Mov hPenTransBig, Rax
	ECInvoke CreatePen, PS_SOLID, 1, TRANS_COLOR
	Mov hPenTransSml, Rax
	ECInvoke SelectObject, hMemDc, hPenNormalSml
	;画圆

	Mov Edx, middleX
	Sub Edx, 2
	Mov R8d, middleY
	Sub R8d, 2

	Mov R9d, middleX
	Add R9d, 3
	Mov Eax, middleY
	Add Eax, 3
	ECInvoke Ellipse, hMemDc, x, y, iW, iH

	ECInvoke SelectObject, hMemDc, hPenTransBig

	;擦除画直线\
	Mov Edx, x
	Mov R8d, y
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, iW
	Mov R8d, iH
	ECInvoke LineTo, hMemDc, Rdx, R8
Comment #
	ECInvoke SelectObject, hMemDc, hPenNormalBig

	;ECInvoke Rectangle, hMemDc, x, y, iW, iH

	;画直线-
	Mov Edx, x
	Add Edx, 4
	Mov R8d, middleY

	;Add Edx, 4
	;Add R8d, 4
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, iW
	Sub Edx, 4
	Mov R8d, middleY

	;Sub Edx, 4
	;Sub R8d, 4
	ECInvoke LineTo, hMemDc, Rdx, R8

	;画直线|

	Mov Edx, middleX
	Mov R8d, y
	Add R8d, 4
	;Add R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, middleX
	Mov R8d, iH
	Sub R8d, 4
	;Add R8d, 1
	ECInvoke LineTo, hMemDc, Rdx, R8


	;画直线\

	Mov Edx, x
	Add Edx, 2 + 2
	Mov R8d, y
	Add R8d, 2 + 2
	;Add R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, iW
	Sub Edx, 3 + 2
	Mov R8d, iH
	Sub R8d, 3 + 2
	ECInvoke LineTo, hMemDc, Rdx, R8


	;画直线/

	Mov Edx, iW
	Sub Edx, 3 + 2
	Mov R8d, y
	Add R8d, 2 + 2
	;Add R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, x
	Add Edx, 2 + 2
	Mov R8d, iH
	Sub R8d, 3 + 2
	;Add R8d, 1
	ECInvoke LineTo, hMemDc, Rdx, R8

	ECInvoke SelectObject, hMemDc, hPenTransSml
	Mov Edx, middleX
	Sub Edx, 2
	Mov R8d, middleY
	Sub R8d, 2

	Mov R9d, middleX
	Add R9d, 3
	Mov Eax, middleY
	Add Eax, 3
	ECInvoke Ellipse, hMemDc, Rdx, R8, R9, Rax
	#
	;中间第一个点
	Lea Rax, pts
	Mov Ecx, middleX
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, y
	Add Ecx, 1
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第2个点左
	Add Rax, SizeOf POINT
	Mov Ecx, x
	Add Ecx, 3
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	;Add Ecx, 2
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第3个右
	Add Rax, SizeOf POINT
	Mov Ecx, iW
	Sub Ecx, 4
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	;Add Ecx, 2
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第4个点重合第1个
	Add Rax, SizeOf POINT
	Mov Ecx, middleX
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, y
	Add Ecx, 1
	Mov DWord Ptr [Rax + POINT.y], Ecx

	ECInvoke CreatePolygonRgn, Addr pts, SizeOf pts / SizeOf POINT, ALTERNATE
	Mov hRgn, Rax
	ECInvoke FillRgn, hMemDc, hRgn, hBrush


	;画直线|
	ECInvoke SelectObject, hMemDc, hPenNormalBig
	Mov Edx, middleX
	Mov R8d, y
	Add R8d, 4
	;Add R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, middleX
	Mov R8d, iH
	Sub R8d, 4
	;Add R8d, 1
	ECInvoke LineTo, hMemDc, Rdx, R8



	ECInvoke DeleteObject, hPenNormalBig
	ECInvoke DeleteObject, hPenNormalSml
	ECInvoke DeleteObject, hPenTransSml
	ECInvoke DeleteObject, hPenTransBig
	ECInvoke DeleteObject, hBrush


	Mov Rax, pIconObject
	Ret
Icon_Upgrade EndP
Icon_Cross Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local middleX:DWord
	Local iW:DWord
	Local iH:DWord

	Local pIconObject:QWord
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Local hPenNormal:HPEN
	Local hPenTrans:HPEN

	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;1/2 height
	Mov Eax, iW
	Sub Eax, x
	Shr Eax, 1
	Mov R8d, x
	Add Eax, R8d
	Mov middleX, Eax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax



	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

;	ECInvoke CreateSolidBrush, normalColor
;	Mov hBrush, Rax


	;创建画笔
	ECInvoke CreatePen, PS_SOLID, 2, normalColor
	Mov hPenNormal, Rax
	ECInvoke SelectObject, hMemDc, Rax

	;ECInvoke Rectangle, hMemDc, x, y, iW, iH

	;画直线
	Mov Edx, x
	Mov R8d, middleY

	;Add Edx, 4
	;Add R8d, 4
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, iW
	Mov R8d, middleY
	;Sub Edx, 4
	;Sub R8d, 4
	ECInvoke LineTo, hMemDc, Rdx, R8

	;画直线

	Mov Edx, middleX
	Mov R8d, y
	;Add R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, middleX
	Mov R8d, iH
	;Add R8d, 1
	ECInvoke LineTo, hMemDc, Rdx, R8

	ECInvoke DeleteObject, hPenNormal
;	ECInvoke DeleteObject, hPenTrans
;	ECInvoke DeleteObject, hBrush


	Mov Rax, pIconObject
	Ret
Icon_Cross EndP

Icon_X Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local middleX:DWord
	Local iW:DWord
	Local iH:DWord

	Local pIconObject:QWord
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Local hPenNormal:HPEN
	Local hPenTrans:HPEN

	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;1/2 height
	Mov Eax, iW
	Sub Eax, x
	Shr Eax, 1
	Mov R8d, x
	Add Eax, R8d
	Mov middleX, Eax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax



	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

;	ECInvoke CreateSolidBrush, normalColor
;	Mov hBrush, Rax


	;创建画笔
	ECInvoke CreatePen, PS_SOLID, 1, normalColor
	Mov hPenNormal, Rax
	ECInvoke SelectObject, hMemDc, Rax

	;ECInvoke Rectangle, hMemDc, x, y, iW, iH

	;画直线
	Mov Edx, x
	Mov R8d, y

	;Add Edx, 4
	;Add R8d, 4
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, iW
	Mov R8d, iH
	;Sub Edx, 4
	;Sub R8d, 4
	ECInvoke LineTo, hMemDc, Rdx, R8

	;画直线

	Mov Edx, iW
	Sub Edx, 1
	Mov R8d, y
	;Add R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0

	Mov Edx, x
	Sub Edx, 1
	Mov R8d, iH
	;Add R8d, 1
	ECInvoke LineTo, hMemDc, Rdx, R8

	ECInvoke DeleteObject, hPenNormal
;	ECInvoke DeleteObject, hPenTrans
;	ECInvoke DeleteObject, hBrush


	Mov Rax, pIconObject
	Ret
Icon_X EndP

Icon_PowerOn Proc  rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local middleX:DWord
	Local iW:DWord
	Local iH:DWord

	Local pIconObject:QWord
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Local hPenNormal:HPEN
	Local hPenTrans:HPEN
	Local hRgn:HRGN

	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;1/2 height
	Mov Eax, iW
	Sub Eax, x
	Shr Eax, 1
	Mov R8d, x
	Add Eax, R8d
	Mov middleX, Eax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax



	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

Comment #
	ECInvoke CreateEllipticRgn, x, y, iW, iH
	Mov hRgn, Rax
	ECInvoke CreateSolidBrush, 000000FFH
	Push Rax
	ECInvoke FillRgn, hMemDc, hRgn, Rax
	Pop Rax
	ECInvoke DeleteObject, Rax
#

	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax


	;创建画笔
	ECInvoke CreatePen, PS_SOLID, 1, normalColor
	Mov hPenNormal, Rax
	;画圆
	ECInvoke SelectObject, hMemDc, Rax
	Mov Edx, x
	Inc Edx
	Mov R8d, y
	Inc R8d
	Mov R9d, iW
	Dec R9d
	Mov Eax, iH
	Dec Eax
	ECInvoke Ellipse, hMemDc, Rdx, R8, R9, Rax

	;擦出缺口
	ECInvoke CreatePen, PS_SOLID, 1, TRANS_COLOR
	Mov hPenTrans, Rax
	ECInvoke SelectObject, hMemDc, Rax
	Mov Edx, middleX
	Sub Edx, 4

	Mov R9d, middleX
	Add R9d, 4

	Mov Eax, y
	Add Eax, 8
	ECInvoke Rectangle, hMemDc, Rdx, y, R9, Rax

	;画直线
	ECInvoke SelectObject, hMemDc, hPenNormal
	Mov Edx, middleX
	Mov R8d, y
	Add R8d, 1
	ECInvoke MoveToEx, hMemDc, Rdx, R8, 0
	Mov R8d, y
	Mov Eax, iH
	Shr Eax, 1
	Add R8d, Eax

	Mov Edx, middleX
	ECInvoke LineTo, hMemDc, Rdx, R8

	ECInvoke DeleteObject, hPenNormal
	ECInvoke DeleteObject, hPenTrans
	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn

	Mov Rax, pIconObject
	Ret
Icon_PowerOn EndP

Icon_TriangleLeft Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local iW:DWord
	Local iH:DWord
	Local pts[4] :POINT	;三角形4个点

	
	Local pIconObject:QWord
	Local hDc:HDC
	Local hMemDc:HDC
	Local hRgn:HRGN
	Local hBrush:HBRUSH


	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;ECInvoke CreateRectRgn, x, y, iW, iH
;	Ret
	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;左侧中间第一个点
	Lea Rax, pts
	Mov Ecx, x
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第2个点右上角
	Add Rax, SizeOf POINT
	Mov Ecx, iW
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, y
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第3个点右下角
	Add Rax, SizeOf POINT
	Mov Ecx, iW
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, iH
	Mov DWord Ptr [Rax + POINT.y], Ecx
	;第4个点重合第1个
	Add Rax, SizeOf POINT
	Mov Ecx, x
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Mov DWord Ptr [Rax + POINT.y], Ecx

	ECInvoke CreatePolygonRgn, Addr pts, SizeOf pts / SizeOf POINT, ALTERNATE
	Mov hRgn, Rax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax



	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax

	ECInvoke FillRgn, hMemDc, hRgn, hBrush


	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn

	Mov Rax, pIconObject
	Ret
Icon_TriangleLeft EndP

Icon_TriangleRight Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local iW:DWord
	Local iH:DWord
	Local pts[4]:POINT	;三角形4个点
	

	Local pIconObject:QWord
	Local hRgn:HRGN
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Mov rRect, Rcx
	Mov normalColor, Edx

	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	
	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax

	;右侧中间第一个点
	Lea Rax, pts
	Mov Ecx, iW
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第2个点左上角
	Add Rax, SizeOf POINT
	Mov Ecx, x
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, y
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;第3个点左下角
	Add Rax, SizeOf POINT
	Mov Ecx, x
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, iH
	Mov DWord Ptr [Rax + POINT.y], Ecx
	;第4个点重合第1个
	Add Rax, SizeOf POINT
	Mov Ecx, iW
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Mov DWord Ptr [Rax + POINT.y], Ecx

	ECInvoke CreatePolygonRgn, Addr pts, SizeOf pts / SizeOf POINT, ALTERNATE
	Mov hRgn, Rax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax


	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax

	ECInvoke FillRgn, hMemDc, hRgn, hBrush


	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn

	Mov Rax, pIconObject
	Ret
Icon_TriangleRight EndP



Icon_Back Proc rRect:QWord, normalColor:DWord
	Local x:DWord
	Local y:DWord
	Local middleY:DWord
	Local o4fx:DWord
	Local o3fy:DWord
	Local iW:DWord
	Local iH:DWord
	Local pts[8]:POINT	;带尾巴的箭头需要8个点

	Local pIconObject:QWord
	Local hRgn:HRGN
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Mov rRect, Rcx
	Mov normalColor, Edx


	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]

	ECInvoke memcpy, Rcx, rRect, SizeOf RECT

	Mov Rax, rRect

	RECT_TO_XYWH Rax, x, y, iW, iH

	;1/2 height
	Mov Eax, iH
	Sub Eax, y
	Shr Eax, 1
	Mov R8d, y
	Add Eax, R8d
	Mov middleY, Eax
	;1/4 width
	comment #
	Mov Eax, iW
	Sub Eax, x
	Shr Eax, 2
	Mov R8d, x
	Add Eax, R8d
	Mov o4fx, Eax
	#
	;1/4 width
	Mov Eax, iW
	Sub Eax, x
	Xor Edx, Edx
	Mov Ecx, 3
	Div Ecx
	Add Eax, x
	Mov o4fx, Eax

	;1/3 height
	Mov Eax, iH
	Sub Eax, y
	Xor Edx, Edx
	Mov Ecx, 3
	Div Ecx
	Mov o3fy, Eax

	;箭头左边中心点
	Lea Rax, pts
	Mov Ecx, x
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Mov DWord Ptr [Rax + POINT.y], Ecx
	;下一个点1/4,top
	Add Rax,sizeof POINT
	Mov Ecx, o4fx
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, y
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;下一个点1/4 x ,1/3 y
	Add Rax,sizeof POINT
	Mov Ecx, o4fx
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, o3fy
	Add Ecx, y
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;下一个点width,1/3 y
	Add Rax,sizeof POINT
	Mov Ecx, iW
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, o3fy
	Add Ecx, y
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;下一个点width,1/3y x 2
	Add Rax,sizeof POINT
	Mov Ecx, iW
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, o3fy
	Shl Ecx, 1
	Add Ecx, y
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;下一个点width,1/3y x 2
	Add Rax,sizeof POINT
	Mov Ecx, o4fx
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, o3fy
	Shl Ecx, 1
	Add Ecx, y
	Mov DWord Ptr [Rax + POINT.y], Ecx

	;下一个点 o4fx,height
	Add Rax,sizeof POINT
	Mov Ecx, o4fx
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, iH
	Mov DWord Ptr [Rax + POINT.y], Ecx

	
	;下一个点 重合起点,x,middleY
	Add Rax,sizeof POINT
	Mov Ecx, x
	Mov DWord Ptr [Rax + POINT.x], Ecx
	Mov Ecx, middleY
	Mov DWord Ptr [Rax + POINT.y], Ecx
   
    ECInvoke CreatePolygonRgn, Addr pts, SizeOf pts / SizeOf POINT, ALTERNATE

    Mov hRgn, Rax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject
	Mov hMemDc, Rax


	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax

	ECInvoke FillRgn, hMemDc, hRgn, hBrush


	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn

	Mov Rax, pIconObject
	Ret
Icon_Back EndP



Icon_Roundrect Proc rRect:QWord, normalColor:DWord, iRound:DWord
	Local x:DWord
	Local y:DWord
	Local iH:DWord
	Local iW:DWord

	Local pIconObject:QWord
	Local hRgn:HRGN
	Local hMemDc:HDC
	Local hBrush:HBRUSH
	Mov rRect, Rcx
	Mov normalColor, Edx
	Mov iRound, R8d


	ECInvoke CreateIconObject
	Mov pIconObject, Rax
	Mov Ecx, normalColor
	Mov [Rax].ICON_OBJECT.ICON_COLOR, Ecx
	Lea Rcx, [Rax + ICON_OBJECT.ICON_RECT]
	ECInvoke memcpy, Rcx, rRect, SizeOf RECT


	Mov Rax, rRect
	RECT_TO_XYWH Rax, x, y, iW, iH

	ECInvoke CreateRoundRectRgn, x, y, iW, iH, iRound, iRound
	Mov hRgn, Rax

	ECInvoke icon_CreateMemDC, 0, iW, iH, pIconObject

	Mov hMemDc, Rax
	ECInvoke DrawBackground, hMemDc, x, y, iW, iH, TRANS_COLOR

	ECInvoke CreateSolidBrush, normalColor
	Mov hBrush, Rax

	ECInvoke FillRgn, hMemDc, hRgn, hBrush
	ECInvoke FrameRgn, hMemDc, hRgn, hBrush, 2, 2

	ECInvoke DeleteObject, hBrush
	ECInvoke DeleteObject, hRgn
	Mov Rax, pIconObject
	Ret
Icon_Roundrect EndP


icon_CreateMemDC Proc srcDC:HDC, iW:DWord, iH:DWord, pIconObject:QWord
	Local hDc:HDC
	Local hBitmap:HBITMAP
	Local hMemDc:HDC

	Mov srcDC, Rcx
	Mov iW, Edx
	Mov iH, R8d
	Mov pIconObject, R9
	Mov hDc, Rcx

	Cmp srcDC, 0
	Jnz hasDc
		ECInvoke GetDC, NULL
		Mov hDc, Rax
hasDc:
	ECInvoke CreateCompatibleBitmap, hDc, iW, iH
	Mov hBitmap, Rax
	Mov Rcx, pIconObject
	Mov QWord Ptr [Rcx + ICON_OBJECT.ICON_BITMAP], Rax

	ECInvoke CreateCompatibleDC, hDc
	Mov hMemDc, Rax
	Mov Rcx, pIconObject
	Mov QWord Ptr [Rcx + ICON_OBJECT.ICON_DC], Rax

	ECInvoke SelectObject, hMemDc, hBitmap
	ECInvoke DeleteDC, hDc
	Mov Rax, hMemDc
	Mov Rcx, hBitmap
	Ret
icon_CreateMemDC EndP

Icon_ChangeColor Proc pIconObject:QWord, newColor:DWord
	Local x:DWord
	Local y:DWord
	Local iy:DWord

	Local iw:DWord
	Local ih:DWord
	Local cColor:DWord

	Local pRect:QWord
	Local hDc:HDC
	Mov pIconObject, Rcx
	Mov newColor, Edx

	Mov Rax, [Rcx + ICON_OBJECT.ICON_DC]
	Mov hDc, Rax

	Lea Rax, [Rcx + ICON_OBJECT.ICON_RECT]

	RECT_TO_XYWH Rax, x, y, iw, ih
	Mov Eax, y
	Mov iy, Eax

_loop_x:

	Mov Eax, iy
	Mov y, Eax
_loop_y:

		ECInvoke GetPixel, hDc, x, y
		Mov cColor, Eax
		Cmp Eax, TRANS_COLOR
		Je @F
		ECInvoke SetPixelV, hDc, x, y, newColor
@@:
		Inc y
		Mov Eax, y
		Cmp Eax, ih
		Jb _loop_y


	Inc x
	Mov Eax, x
	Cmp Eax, iw
	Jb _loop_x

	Ret
Icon_ChangeColor EndP



CreateIconObject Proc
	Local result:QWord
	ECInvoke GlobalAlloc, GPTR, SizeOf ICON_OBJECT
	Mov result, Rax
	ECInvoke ZeroMemory, Rax, SizeOf ICON_OBJECT
	Mov Rax, result
	Ret
CreateIconObject EndP

CreateIconWithID Proc IconId:QWord, hRect:QWord, normalColor:QWord
	;Local pIconObj:QWord
	Mov IconId, Rcx
	Mov hRect, Rdx
	Mov normalColor, R8

	Cmp IconId, ID_ICON_BACK_ARROR
	Jnz @F
	ECInvoke Icon_Back, hRect, normalColor
@@:	Cmp IconId, ID_ICON_GUN_SIGHT
	Jnz @F
	ECInvoke Icon_Gunsight, hRect, normalColor
@@:Cmp IconId, ID_ICON_TRIANGLE_LEFT
	Jnz @F
	ECInvoke Icon_TriangleLeft, hRect, normalColor
@@:Cmp IconId, ID_ICON_TRIANGLE_RIGHT
	Jnz @F
	ECInvoke Icon_TriangleRight, hRect, normalColor
@@:Cmp IconId, ID_ICON_POWER_ON
	Jnz @F
	ECInvoke Icon_PowerOn, hRect, normalColor
@@:Cmp IconId, ID_ICON_X
	Jnz @F
	ECInvoke Icon_X, hRect, normalColor
@@:Cmp IconId, ID_ICON_CROSS
	Jnz @F
	ECInvoke Icon_Cross, hRect, normalColor
@@:Cmp IconId, ID_ICON_UPGRADE
	Jnz @F
	ECInvoke Icon_Upgrade, hRect, normalColor
@@:
Cmp IconId, ID_ICON_IMPORT
	Jnz @F
	ECInvoke Icon_Import, hRect, normalColor
@@:

	Ret
CreateIconWithID EndP

DestroyIconObject Proc pIconObject:QWord
	Mov pIconObject, Rcx
	Mov Rax, [Rcx].ICON_OBJECT.ICON_BITMAP
	Push Rax
	Mov Rax, [Rcx].ICON_OBJECT.ICON_DC
	ECInvoke DeleteDC, Rax
	Pop Rcx
	ECInvoke DeleteObject, Rcx
	ECInvoke GlobalFree, pIconObject
	Ret
DestroyIconObject EndP

