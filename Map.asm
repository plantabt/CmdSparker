;EasyCodeName=Map,1
.Const
	defaultHashMapSize Equ 100
.Data?

.Data

.Code


SetIndexMap Proc pMap:QWord, index:QWord, pInValue:QWord, sizeValue:QWord
	Local newItem:HANDLE_MALLOC
	Local pValue:QWord
	Local pItem:QWord
	Mov pMap, Rcx
	Mov index, Rdx
	Mov pInValue, R8
	Mov sizeValue, R9

	ECInvoke HandleToPmem, Rcx
	Mov Rcx, pMap
	Mov Rdx, index
;	Mov R8, pInValue
	;index * 8 + index *8 =index * 16
	;Lea R8, [Rdx * 8]
	Lea Rdx, [Rdx * 8]
	;Add Rdx, R8
	Lea Rax, [Rax + Rdx]

	Mov pItem, Rax		;算出index对应的pMap中偏移地址
	ECInvoke IsBadWritePtr, Rax, 8
	Cmp Rax, 0
	Je @F
		Xor Eax, Eax
		Ret
@@:

	Mov Rdx, sizeValue
	Add Rdx, SizeOf (MAP_ITEM)
	ECInvoke Malloc, pItem, Rdx
	Lea Rcx, [Rax + MAP_ITEM.offset_value]
	Mov pValue, Rcx
	Mov Rcx, sizeValue
	Mov DWord Ptr [Rax + MAP_ITEM.value_size], Ecx
	ECInvoke memcpy, pValue, pInValue, sizeValue

	Ret
SetIndexMap EndP

GetIndexMap Proc pMap:QWord, index:QWord
	Mov pMap, Rcx
	Mov index, Rdx
	Cmp QWord Ptr [Rcx], 0
	Jne @F
		Xor Eax, Eax
		Ret
@@:
	Push Rdx
	ECInvoke HandleToPmem, pMap
	Pop Rdx
	;index * 8 + index *8 =index * 16
	;Lea R8, [Rdx * 8]
	Lea Rdx, [Rdx * 8]
	;Add Rdx, R8
	Lea Rax, [Rax + Rdx]


	Ret
GetIndexMap EndP

GetIndexMapValue Proc pMap:QWord, index:QWord, pOutValue:QWord, pOutSize:QWord
	Mov pMap, Rcx
	Mov index, Rdx
	Mov pOutValue, R8
	Mov pOutSize, R9
	ECInvoke GetIndexMap, Rcx, Rdx
	Cmp QWord Ptr [Rax], 0
	Je exit

		ECInvoke HandleToPmem, Rax
		;get size
		Mov R8d, DWord Ptr [Rax + MAP_ITEM.value_size]
		Cmp pOutSize, 0;指针为空则不复制size
		Je @F
			Mov Rcx, pOutSize
			Mov [Rcx], R8

@@:
		;copy value
		Cmp pOutValue, 0;指针为空则不复制value
		Je exit
			Lea Rdx, [Rax + MAP_ITEM.offset_value]
			ECInvoke memcpy, pOutValue, Rdx, R8

exit:
	Xor Eax, Eax
	Ret
GetIndexMapValue EndP


GetIndexMapKeyFromVal Proc pMap:QWord, value:QWord, valueSize:QWord, sizeMap:QWord
	Local pOutValue:HANDLE_MALLOC
	Local pOutSize:QWord
	Local count:QWord
	Local pMem:QWord
	Mov pMap, Rcx
	Mov value, Rdx
	Mov valueSize, R8
	Mov sizeMap, R9

	Cmp QWord Ptr [Rcx], 0
	Je exit

	Mov count, 0
goNext:
	;先获取大小
	ECInvoke GetIndexMapValue, pMap, count, 0, Addr pOutSize

	Mov Rax, pOutSize
	Cmp Rax, valueSize
	Jne @F	;大小不相等不进行比较
		ECInvoke Malloc, Addr pOutValue, pOutSize
		Mov pMem, Rax
		ECInvoke GetIndexMapValue, pMap, count, Rax, 0
		;比较数据
		ECInvoke IsMemEqul, pMem, value, valueSize
		Push Rax
		ECInvoke Free, Addr pOutValue
		Pop Rax
		Test Al, Al
		Jnz found;不等于0就是找到了
@@:
	Mov pOutSize, 0
	Inc count
	Mov Rdx, count
	Cmp Rdx, sizeMap
	Jne goNext
exit:
		;等于最大值没找到
		Mov Rax, -1
		Ret
found:
	Mov Rax, count
	Ret
GetIndexMapKeyFromVal EndP


IsIndexMapHasKey Proc pMap:QWord, index:QWord

	Mov pMap, Rcx
	Mov index, Rdx
	Cmp QWord Ptr [Rcx], 0
	Je exit
	ECInvoke GetIndexMap, Rcx, Rdx
	Cmp QWord Ptr [Rax], 0
	Je exit
		;已经有值
		Mov Eax, 1
		Ret
exit:
	Xor Eax, Eax
	Ret
IsIndexMapHasKey EndP


ClearIndexgMap Proc pMap:QWord, sizeMap:QWord
	Local pMapMem:QWord
	Mov pMap, Rcx
	Mov sizeMap, Rdx
	ECInvoke HandleToPmem, pMap
	Mov pMapMem, Rax
	Dec sizeMap ;索引从0开始
next:
	ECInvoke IsIndexMapHasKey, pMap, sizeMap
	Test Al, Al
	Jz @F
		;清理map item
		Mov Rdx, sizeMap
		Mov Rax, pMapMem
		;Lea R8, [Rdx * 8]
		Lea Rdx, [Rdx * 8]
		;Add Rdx, R8
		Lea Rax, [Rax + Rdx]
		Push Rax
		ECInvoke Free, Rax
		Pop Rax
		Mov QWord Ptr [Rax], 0
		;Mov QWord Ptr [Rax + 8], 0
@@:
	Dec sizeMap
	Cmp sizeMap, 0
	Jg next
	Ret
ClearIndexgMap EndP

;二进制哈希表实现
GetQuickHash Proc pBuff:QWord, HashTableSize:QWord
	Local table[256]:DB
	Local Crc :DWord
	Mov pBuff, Rcx
	Mov HashTableSize, Rdx

	ECInvoke InitCrc32, Addr table
	ECInvoke lstrlen, pBuff
	ECInvoke CalcCrc32, pBuff, Rax, Addr table
	Mov Crc, Eax

    Xor Rax, Rax ; 清零rax，用于存储总和
    Mov R8, pBuff
hash_loop:
    Movzx Rcx, Byte Ptr [R8] ; 加载当前字符
    Test Rcx, Rcx ; 检查字符串结束
    Jz hash_done
    Add Rax, Rcx ; 累加ASCII值
	Xor Rdx, Rdx
    Mul Rcx		;加入乘法防止对撞
    Xor Rdx, Rdx
    Mul Rax		;加入乘法防止对撞
    Add Eax, Crc
    Inc R8
    Jmp hash_loop
hash_done:
	Xor Edx, Edx
    Mov Rcx, HashTableSize
    Div Rcx ; 对哈希表大小取模
    Mov Rax, Rdx ; 将结果存储在rax中
    ;跳过第一项,第一项为表大小
	Inc Rax

	Ret
GetQuickHash EndP
GetQuickHash2 Proc pKeyString:QWord, tableSize:DWord
	Local key:DWord
	Local table[256]:DB
	mov tableSize,edx  
	Mov pKeyString, Rcx

	ECInvoke InitCrc32, Addr table
	ECInvoke lstrlen, pKeyString
	ECInvoke CalcCrc32, pKeyString, Rax, Addr table
	Mov key, Eax
	comment #
	00007FF7A8F41432 48 8B 4C 24 40       mov         rcx,qword ptr [keystring]  
	00007FF7A8F41437 FF 15 43 2E 00 00    call        qword ptr [__imp_strlen (07FF7A8F44280h)]  
	00007FF7A8F4143D 4C 8B 44 24 50       mov         r8,qword ptr [pTable]  
	00007FF7A8F41442 48 8B D0             mov         rdx,rax  
	00007FF7A8F41445 48 8B 4C 24 40       mov         rcx,qword ptr [keystring]  
	00007FF7A8F4144A E8 41 FF FF FF       call        CalculateCRC32 (07FF7A8F41390h)  
	#

	Mov Eax, key
	Shl Eax, 0CH
	Mov Ecx, key
	Add Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shr Eax, 16H
	Mov Ecx, key
	Xor Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shl Eax, 4
	Mov Ecx, key
	Add Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shr Eax, 9
	Mov Ecx, key
	Xor Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shl Eax, 0AH
	Mov Ecx, key
	Add Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shr Eax, 2
	Mov Ecx, key
	Xor Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shl Eax, 7
	Mov Ecx, key
	Add Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shr Eax, 0CH
	Mov Ecx, key
	Xor Ecx, Eax
	Mov Eax, Ecx
	Mov key, Eax
	Mov Eax, key
	Shr Eax, 3
	Mov Eax, Eax
	Mov Ecx, 9E3779B1H
	IMul Rax, Rcx
	Mov key, Eax
	Xor Edx, Edx
	Mov Eax, key
	Mov Ecx, tableSize
	Div Rcx
	Mov Eax, Edx
	Inc Rax
	Ret
GetQuickHash2 EndP


CreateMap Proc
	;第一项为当前表大小
	ECInvoke GlobalAlloc, GPTR, (SizeOf (QWord)) *(defaultHashMapSize + 1)
	Mov QWord Ptr [Rax], defaultHashMapSize
	Ret
CreateMap EndP

GetMapOffset Proc  pMap:QWord, hash:QWord
	Mov pMap, Rcx
	Mov hash, Rdx
	Xor Edx, Edx
	Mov Rcx, hash
	Mov Eax, SizeOf (QWord)
	Mul Rcx
	Mov Rcx, pMap
	Lea Rax, [Rax + Rcx]
	Ret
GetMapOffset EndP

PutMapValue Proc pMap:QWord, pKey:QWord, pValue:QWord, vSize:QWord
	Local keySize:QWord
	Local hash:QWord
	Local pPtr:QWord
	Local value[100]:DB
	Local valueSize:QWord
	Mov pMap, Rcx
	Mov pKey, Rdx
	Mov pValue, R8
	Mov vSize, R9

	Mov Rdx, [Rcx];mapSize
	ECInvoke GetQuickHash, pKey, Rdx
	Mov hash, Rax
	ECInvoke GetMapOffset, pMap, hash
	comment #
	Xor Edx, Edx
	Mov Rcx, hash
	Mov Eax, SizeOf (QWord)
	Mul Rcx

	Mov Rcx, pMap
	Lea Rcx, [Rax + Rcx]
	#
	Mov pPtr, Rax
	Mov Rax, [Rax]
	Test Rax, Rax
	Jnz has
	;如果没有内容则创建内存
	ECInvoke GlobalAlloc, GPTR, SizeOf (MAP_K_V)
	Mov Rcx, pPtr
	Mov [Rcx], Rax
has:
	;设置key 和value
	ECInvoke NewStr, pKey, 0
	Mov Rcx, pPtr
	Mov Rcx, [Rcx]
	;pkey
	Mov [Rcx].MAP_K_V.first, Rax

	ECInvoke GlobalAlloc, GPTR, vSize
	Mov Rcx, pPtr
	Mov Rcx, [Rcx]
	;pval
	Mov [Rcx].MAP_K_V.second, Rax
	ECInvoke memcpy, Rax, pValue, vSize
	Ret
PutMapValue EndP

GetMapValue Proc pMap:QWord, pKey:QWord, pOutValue:QWord, vSize:QWord
	Local hash:QWord
	Local pPtr:QWord

	Mov pMap, Rcx
	Mov pKey, Rdx
	Mov pOutValue, R8
	Mov vSize, R9

	Mov Rdx, [Rcx];mapSize
	ECInvoke GetQuickHash, pKey, Rdx
	Mov hash, Rax

	ECInvoke GetMapOffset, pMap, hash

	Mov pPtr, Rax
	Mov Rax, [Rax]
	Test Rax, Rax
	Jz exit
	Mov Rcx, pPtr

	;val
	Mov Rcx, [Rcx]
	Mov Rdx, [Rcx].MAP_K_V.second
	ECInvoke memcpy, pOutValue, Rdx, vSize
	Mov Rax, 1
	Ret
exit:
	Xor Eax, Eax

	Ret

GetMapValue EndP

GetMapKey Proc pMap:QWord, hash:QWord
	Local pOffset:QWord
	Local pVal:QWord
	Mov pMap, Rcx
	Mov hash, Rdx

	ECInvoke GetMapOffset, pMap, hash
	Mov Rax, [Rax]
	Test Rax, Rax
	Jz @F
	Mov Rcx, [Rax].MAP_K_V.first
	ECInvoke NewStr, Rcx, 0
@@:
	Ret
GetMapKey EndP

RemoveMapVaule Proc pMap:QWord, pKey:QWord
	Local pOffset:QWord
	Local ptrKey:QWord
	Local ptrVal:QWord
	Mov pMap, Rcx
	Mov pKey, Rdx

	Mov Rdx, [Rcx];mapSize
	ECInvoke GetQuickHash, pKey, Rdx
	ECInvoke GetMapOffset, pMap, Rax
	Mov pOffset, Rax
	Mov Rcx, [Rax]
	Test Rcx, Rcx
	Jz exit
	Mov Rax, [Rcx].MAP_K_V.first
	Mov ptrKey, Rax
	Mov Rax, [Rcx].MAP_K_V.second
	Mov ptrVal, Rax
	ECInvoke GlobalFree, ptrKey
	ECInvoke GlobalFree, ptrVal
	Mov Rax, pOffset
	Mov Rcx, [Rax]
	Mov QWord Ptr [Rax], 0 ;null map item
	ECInvoke GlobalFree, Rcx
exit:
	Ret
RemoveMapVaule EndP

DestroyMap Proc pMap:QWord
	Local mapCount:QWord
	Local pKey:QWord
	Mov pMap, Rcx
	Mov Rax, [Rcx]
	Mov mapCount, Rax
loopMap:
	ECInvoke GetMapOffset, pMap, mapCount
	ECInvoke GetMapKey, pMap, mapCount
	Test Rax, Rax
	Jz @F
	Mov pKey, Rax
	ECInvoke RemoveMapVaule, pMap, pKey
	ECInvoke DelStr, pKey
@@:
	Dec mapCount
	Cmp mapCount, 1
	Jge loopMap
	Ret
DestroyMap EndP

