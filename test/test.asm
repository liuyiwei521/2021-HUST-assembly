.386     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf PROTO C :VARARG
 scanf  PROTO C:VARARG
 includelib  ucrt.lib
 includelib  legacy_stdio_definitions.lib

.DATA
x dw 10,20


.STACK 200
.CODE
main proc c
	mov ax,0
	add ax,7fffh
	xchg ah,al
	dec ax
	add ax,0ah
	not ax
	sub ax,0ffffh
	or ax,0abcdh
	and ax,0dcbah
	sal ax,1
	rcl ax,1
	mov ax,0
main endp
END