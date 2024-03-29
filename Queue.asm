;EasyCodeName=Queue,1
.Const

.Data?

.Data

.Code

CreateQueueNode Proc pValue:QWord, iSize:DWord
	Local pNewNode:QWord
	Local pNewValue:QWord
	Mov pValue, Rcx
	Mov iSize, Edx
	ECInvoke GlobalAlloc, GPTR, SizeOf NODE
	Mov pNewNode, Rax

	ECInvoke ZeroMemory, Rax, SizeOf NODE

	ECInvoke GlobalAlloc, GPTR, iSize
	Mov pNewValue, Rax
	ECInvoke memcpy, Rax, pValue, iSize

	Mov Rcx, pNewNode
	Mov Rax, pNewValue

	Mov [Rcx].NODE.Value, Rax
	Mov Eax, iSize
	Mov [Rcx].NODE.vSize, Rax
	Mov Rax, pNewNode
	Ret
CreateQueueNode EndP

DestroyQueue Proc pRootNode:QWord
	Mov pRootNode, Rcx

	ECInvoke GlobalFree, pRootNode
	Ret
DestroyQueue EndP

InsertQueue Proc ppRootNode:QWord, pNode:QWord
	Local pRootNode:QWord
	Mov ppRootNode, Rcx
	Mov Rcx, [Rcx]
	Mov pRootNode, Rcx
	Xor Eax, Eax
	Cmp Rcx, Rdx
	Je exit
;	Mov pNode, Rdx

	;pRootNode
	Mov [Rcx].NODE.pPrev, Rdx
	;pNode
	Mov [Rdx].NODE.pNext, Rcx

	;pRootNode->
	Mov Rax, ppRootNode
	Mov [Rax], Rdx
	Mov Rax, Rdx
exit:
	Ret
InsertQueue EndP

DestroyNode Proc pNode:QWord
	Local pValue:QWord
	Local pcallDestroy:QWord
	;Local pPrev:QWord
	Mov pNode, Rcx
	Mov Rax, [Rcx].NODE.Value
	Mov pValue, Rax

	Mov Rax, [Rcx].NODE.pPrev
	Test Rax, Rax
	Jz @F
		Mov [Rax].NODE.pNext, 0
@@:
	Mov Rax, [Rcx].NODE.callDestroy
	Mov pcallDestroy, Rax
	Test Rax, Rax
	Jz exit
		BEGIN_CALL 20H
		Mov Rcx, pValue
		ECInvoke pcallDestroy
		END_CALL 20H
exit:

	ECInvoke GlobalFree, pValue
	ECInvoke GlobalFree, pNode
	Ret
DestroyNode EndP

GetQueue Proc ppRootNode:QWord
	Local pRootNode:QWord
	Local count:DWord
	Local pEnd:QWord
	Mov ppRootNode, Rcx
	Mov Rcx, [Rcx]
	Mov pRootNode, Rcx

	ECInvoke QueueSize, pRootNode;ret rax,rdx
	Mov count, Eax
	Test Eax, Eax
	Jz exit
		Mov pEnd, Rdx
		;unlink
		Mov Rax, [Rdx].NODE.pPrev
		Test Rax, Rax
		Jz @F
		Mov [Rax].NODE.pNext, 0
@@:
		;ret pEnd
		Mov Rax, Rdx
exit:
	Ret
GetQueue EndP

QueueSize Proc pRootNode:QWord
	Local pNext:QWord
	Local count:DWord
	Local pEnd:QWord
	Mov count, 0
	Mov pRootNode, Rcx
	Mov pNext, Rcx
	Test Rcx, Rcx
	Jnz @F
		Xor Eax, Eax
		Ret
	Test Rdx, Rdx
	Jnz @F
		Xor Eax, Eax
		Ret
@@:
_loop:
	Mov Rcx, pNext
	Mov pEnd, Rcx
	Mov Rax, [Rcx].NODE.pNext
	;Test Rax, Rax
	;Jz @F
	Inc count
	Mov pNext, Rax
;@@:
	Test Rax, Rax
	Jnz _loop
	Mov Eax, count
	Mov Rdx, pEnd
	Ret
QueueSize EndP