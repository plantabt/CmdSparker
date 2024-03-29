;EasyCodeName=List,1
.Const

.Data?

.Data

.Code


;pSrcNode始终保持传进来的是前一个node
SwapLink Proc pInstNode:QWord, pSrcNode:QWord
	Local tmpMalloc:HANDLE_MALLOC
	Local pPrevHandle:QWord
	Local pNextHandle:QWord
	Local pSelfPrev:QWord
	Local pSelfNext:QWord
	Mov pInstNode, Rcx
	Mov pSrcNode, Rdx

	ECInvoke HandleToPmem, Rdx

	;找到源节点的前后节点指针存放地址
	Lea R8, QWord Ptr [Rax + DOUBLE_LINKED_NODE.next]
	Mov pNextHandle, R8
	Lea R8, QWord Ptr [Rax + DOUBLE_LINKED_NODE.prev]
	Mov pPrevHandle, R8

	;获取插入节点的前后节点指针存放地址
	ECInvoke HandleToPmem, pInstNode
	Lea R8, QWord Ptr [Rax + DOUBLE_LINKED_NODE.next]
	Mov pSelfNext, R8
	Lea R8, QWord Ptr [Rax + DOUBLE_LINKED_NODE.prev]
	Mov pSelfPrev, R8

	;把源节点的前后地址写入到插入节点
	Mov Rcx, pSelfPrev
	Mov Rdx, pSrcNode
	ECInvoke CopyMaloocHandle, Rcx, Rdx


	Mov Rcx, pSelfNext
	Mov Rdx, pNextHandle
	ECInvoke CopyMaloocHandle, Rcx, Rdx


	;取得下个节点地址指针,找到下节点的prev地址，写入新节点地址
	ECInvoke HandleToPmem, pNextHandle
	Lea Rcx, [Rax + DOUBLE_LINKED_NODE.prev]
	Mov Rdx, pInstNode
	ECInvoke CopyMaloocHandle, Rcx, Rdx


	;把插入节点指针写入到上节点的next
	Mov Rcx, pNextHandle
	Mov Rdx, pInstNode
	ECInvoke CopyMaloocHandle, Rcx, Rdx

	Ret
SwapLink EndP

CreateDLNode Proc pOutNode:QWord, valuePtr:QWord, valueSize:QWord
	Local pValue:QWord
	Mov pOutNode, Rcx
	Mov valuePtr, Rdx
	Mov valueSize, R8
	Xor Eax, Eax
	Cmp pOutNode, 0
	Je exit
	;申请link node
	ECInvoke Malloc, Rcx, SizeOf DOUBLE_LINKED_NODE

	;申请value
	ECInvoke Malloc, Rax, valueSize
	Mov pValue, Rax

	Cmp valuePtr, 0
	Je @F
		ECInvoke HandleToPmem, pOutNode
		Mov Rcx, valueSize
		Mov [Rax + DOUBLE_LINKED_NODE.value_size], Ecx

		ECInvoke memcpy, pValue, valuePtr, valueSize
@@:
	Mov Rax, pValue
exit:
	Ret
CreateDLNode EndP

GetLastDLNode Proc pNode:QWord, pOutNode:QWord
	;Mov pNode, Rcx
	Mov pOutNode, Rdx

	ECInvoke HandleToPmem, Rcx
	Lea Rdx, [Rax + DOUBLE_LINKED_NODE.prev]
	ECInvoke CopyMaloocHandle, pOutNode, Rdx
	Ret
GetLastDLNode EndP


GetNextDLNode Proc pNode:QWord
	ECInvoke HandleToPmem, Rcx
	Lea Rax, [Rax + DOUBLE_LINKED_NODE.next]
	Ret
GetNextDLNode EndP

GetPrevDLNode Proc pNode:QWord
	ECInvoke HandleToPmem, Rcx
	Lea Rax, [Rax + DOUBLE_LINKED_NODE.prev]
	Ret
GetPrevDLNode EndP

IsDLNodeEqual Proc pNode1:QWord, pNode2:QWord
	Mov pNode1, Rcx
	Mov pNode2, Rdx
	ECInvoke HandleToPmem, Rcx
	Push Rax
	ECInvoke HandleToPmem, pNode2
	Pop Rcx
	Cmp Rax, Rcx
	Jnz @F
		Mov Eax, 1
	Ret
@@:
		Xor Eax, Eax
	Ret
IsDLNodeEqual EndP

GetDLNodeValue Proc pNode:QWord, outValue:QWord, outSize:QWord
	Mov outValue, Rdx
	Mov outSize, R8
	ECInvoke HandleToPmem, Rcx
	Mov Ecx, [Rax + DOUBLE_LINKED_NODE.value_size]
	Mov Rdx, outSize
	Mov [Rdx], Rcx
	Lea Rcx, [Rax + DOUBLE_LINKED_NODE.value]
	ECInvoke HandleToPmem, Rcx
	Mov Rdx, outSize
	Mov R8, [Rdx]

	ECInvoke memcpy, outValue, Rax, R8
	Ret
GetDLNodeValue EndP

;rax=handle,rcx=pMem 返回被删除节点下一个节点
DeleteDLNode Proc pNode:QWord
	Local pPrev:HANDLE_MALLOC
	Local pNext:HANDLE_MALLOC
	Local tRemove:HANDLE_MALLOC
	Mov pNode, Rcx

	;保存pNode的信息
	ECInvoke CopyMaloocHandle, Addr tRemove, pNode
	;拷贝pNode的prev到变量
	ECInvoke HandleToPmem, pNode
	Push Rax
	Lea Rdx, [Rax + DOUBLE_LINKED_NODE.prev]
	ECInvoke CopyMaloocHandle, Addr pPrev, Rdx
	;拷贝pNode的next到变量
	Pop Rax
	Lea Rdx, [Rax + DOUBLE_LINKED_NODE.next]
	ECInvoke CopyMaloocHandle, Addr pNext, Rdx

	;;;;;摘除pNode，链接上下两个节点;;;;;;
	;定位 prve node 把next node 地址 写入 next node 存储位置
	ECInvoke HandleToPmem, Addr pPrev
	Lea Rcx, [Rax + DOUBLE_LINKED_NODE.next]
	ECInvoke CopyMaloocHandle, Rcx, Addr pNext

	;定位 next node 把prev node 地址 写入 prev node 存储位置
	ECInvoke HandleToPmem, Addr pNext
	Lea Rcx, [Rax + DOUBLE_LINKED_NODE.prev]
	ECInvoke CopyMaloocHandle, Rcx, Addr pPrev


	;;;;;删除pNode操作;;;;;;
	ECInvoke HandleToPmem, Addr tRemove
	;释放value
	ECInvoke Free, Rax
	;释放pnode的存储空间
	ECInvoke Free, Addr tRemove

	;返回被清理的下一个节点堆指针信息
	Lea R8, pNext
	Mov Rcx, [R8 + HANDLE_MALLOC.pMem]
	Ret
DeleteDLNode EndP


FindDLNode Proc pNode:QWord, valuePtr:QWord, valueSize:QWord
	Local ptmpNode:QWord
	Mov pNode, Rcx
	Mov valuePtr, Rdx
	Mov valueSize, R8
	Mov ptmpNode, Rcx
	;找到第一项
	ECInvoke HandleToPmem, Rcx

cmpmem:
	Mov Ecx, DWord Ptr [Rax + DOUBLE_LINKED_NODE.value_size]
	Cmp Ecx, DWord Ptr valueSize	;value长度不相等直接跳过
	Jnz @F
		ECInvoke HandleToPmem, Rax	;获得value pMem
		ECInvoke IsMemEqul, valuePtr, Rax, valueSize	;内存比较
	Test Al, Al
	Jnz find
@@:

		ECInvoke GetNextDLNode, ptmpNode

		Mov ptmpNode, Rax

		ECInvoke IsDLNodeEqual, pNode, ptmpNode
		comment #
		ECInvoke HandleToPmem, pNode
		Push Rax	;直接保存结果到栈 省去申明变量了
		ECInvoke HandleToPmem, ptmpNode
		Pop Rcx		;把rax弹出到pop指令
		Cmp Rax, Rcx;比较是否查找了一遍,回到了第一个node
		#
		Cmp Rax, 1
		Jz exit
	Jmp cmpmem
find:
	Mov Rax, ptmpNode
	Ret
exit:
	Xor Eax, Eax
	Ret
FindDLNode EndP

SizeOfDLLink Proc pNode:QWord
	Local count:QWord
	Local pNext:HANDLE_MALLOC
	Mov pNode, Rcx
	Mov count, 0
	ECInvoke CopyMaloocHandle, Addr pNext, pNode
loop_node:
		ECInvoke GetNextDLNode, Addr pNext
		ECInvoke CopyMaloocHandle, Addr pNext, Rax
		Inc count
		ECInvoke IsMemEqul, pNode, Addr pNext, SizeOf HANDLE_MALLOC
	Test Al, Al;=0不相等1相等
	Jz loop_node;如果找到开始的pNode则退出

	Mov Rax, count
	Ret
SizeOfDLLink EndP

;return rax=handle,rdx=pMem
InsertDLAtEnd Proc pNode:QWord, value:QWord, valueSize:QWord
	Local pOutNode:HANDLE_MALLOC
	Local pLastNode:HANDLE_MALLOC
	Mov pNode, Rcx
	Mov value, Rdx
	Mov valueSize, R8

	ECInvoke CreateDLNode, Addr pOutNode, value, valueSize
	;是否创建过node没有就作为第一个插入并填入node指针给节点基地址

	Mov Rax, pNode
	Cmp QWord Ptr [Rax], 0
	Jne @F
		ECInvoke CopyMaloocHandle, pNode, Addr pOutNode
		;初始化链
		ECInvoke HandleToPmem, pNode
		Push Rax
		Lea Rcx, [Rax + DOUBLE_LINKED_NODE.prev]
		ECInvoke CopyMaloocHandle, Rcx, pNode

		Pop Rax
		Lea Rcx, [Rax + DOUBLE_LINKED_NODE.next]
		ECInvoke CopyMaloocHandle, Rcx, pNode
	Jmp exit
@@:
	ECInvoke GetLastDLNode, pNode, Addr pLastNode
	ECInvoke SwapLink, Addr pOutNode, Addr pLastNode

	Lea R8, pOutNode
	;双返回值
	Mov Rcx, [R8 + HANDLE_MALLOC.pMem]
exit:

	Ret
InsertDLAtEnd EndP

InsertDLAtBegin Proc pNode:QWord, value:QWord, valueSize:QWord
	Local pOutNode:HANDLE_MALLOC
	Local pLastNode:HANDLE_MALLOC
	Mov pNode, Rcx
	Mov value, Rdx
	Mov valueSize, R8

	ECInvoke CreateDLNode, Addr pOutNode, value, valueSize
	;是否创建过node没有就作为第一个插入并填入node指针给节点基地址

	Mov Rax, pNode
	Cmp QWord Ptr [Rax], 0
	Jne @F
		ECInvoke CopyMaloocHandle, pNode, Addr pOutNode
		;初始化链
		ECInvoke HandleToPmem, pNode
		Push Rax
		Lea Rcx, [Rax + DOUBLE_LINKED_NODE.prev]
		ECInvoke CopyMaloocHandle, Rcx, pNode

		Pop Rax
		Lea Rcx, [Rax + DOUBLE_LINKED_NODE.next]
		ECInvoke CopyMaloocHandle, Rcx, pNode
	Jmp exit
@@:

	ECInvoke SwapLink, Addr pOutNode, pNode
	ECInvoke CopyMaloocHandle, pNode, Addr pOutNode

	Lea R8, pOutNode
	;双返回值
	Mov Rcx, [R8 + HANDLE_MALLOC.pMem]
exit:
	Ret
InsertDLAtBegin EndP


InsertDLAtPos Proc pNode:QWord, value:QWord, valueSize:QWord, iPos:QWord
	Local pOutNode:HANDLE_MALLOC
	Local pLastNode:HANDLE_MALLOC
	Local pINode:HANDLE_MALLOC
	Mov pNode, Rcx
	Mov value, Rdx
	Mov valueSize, R8
	Mov iPos, R9

	ECInvoke CopyMaloocHandle, Addr pINode, Rcx

	Mov Rcx, R9
	Test Rcx, Rcx	;rcx=0则不循环
	Jz @F
seek:
	Push Rcx
	ECInvoke GetNextDLNode, Addr pINode
	ECInvoke CopyMaloocHandle, Addr pINode, Rax
	Pop Rcx
	Loop seek

@@:
	ECInvoke CreateDLNode, Addr pOutNode, value, valueSize
	;是否创建过node没有就作为第一个插入并填入node指针给节点基地址

	ECInvoke SwapLink, Addr pOutNode, Addr pINode
	;ECInvoke CopyMaloocHandle, pINode, Addr pOutNode

	Lea R8, pOutNode
	;双返回值
	Mov Rcx, [R8 + HANDLE_MALLOC.pMem]
exit:
	Ret
InsertDLAtPos EndP

DestoryDLLink Proc pNode:QWord
	Local pNext:HANDLE_MALLOC
	Local tmpNext:HANDLE_MALLOC
	Mov pNode, Rcx
	ECInvoke CopyMaloocHandle, Addr pNext, pNode
	ECInvoke GetNextDLNode, Addr pNext
	ECInvoke CopyMaloocHandle, Addr tmpNext, Rax
next:
		ECInvoke IsMemEqul, Addr tmpNext, pNode, SizeOf HANDLE_MALLOC
	Test Al, Al;如果只有一项直跳走
	Jnz @F

		ECInvoke CopyMaloocHandle, Addr pNext, Addr tmpNext

		;提前取出next指针防止free
		ECInvoke GetNextDLNode, Addr pNext
		ECInvoke CopyMaloocHandle, Addr tmpNext, Rax

		
		;;;;;删除pNode操作;;;;;;
		ECInvoke HandleToPmem, Addr pNext
		;释放value
		ECInvoke Free, Rax
		;释放pnode的存储空间
		ECInvoke Free, Addr pNext


	Jmp next
@@:

	;;;;;删除基址针操作;;;;;;
	ECInvoke HandleToPmem, Addr tmpNext
	;释放value
	ECInvoke Free, Rax
	;释放pnode的存储空间
	ECInvoke Free, Addr pNext
	Ret
DestoryDLLink EndP


