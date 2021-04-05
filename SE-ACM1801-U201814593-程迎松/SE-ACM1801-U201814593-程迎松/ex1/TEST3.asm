     INCLUDE IO_M.LIB
.386
STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS
DATA SEGMENT USE16
    BNAME DB 'CYINGSONG','$' ;老板的姓名
	BPASS DB 'test00',0  ;密码6个字节
	ATUH DB 0  ;当前登录状态
	GOOD DB '$',9 DUP(0) ;当前浏览商品名称
	N EQU 30 
	M EQU 21 ;每个商品占据字节数
	SNAME DB 'SHOP',0  ;网店名称
	GA1 DB 'PEN$',6 DUP(0),10 ;商品名称和折扣
	    DW 35,56,70,25,?
	GA2 DB 'BOOK$',5 DUP(0),9
	    DW 12,30,25,5,?
	GA3 DB 'BAG$',6 DUP(0),10
	    DW 35,56,70,25,?
	GAN DB N-3 DUP('TempValue$',8,15,0,20,0,30,0,2,0,?,?)
	OUTPUT1 DB '----------------------------',0AH,0DH
	        DB 'current user name:$'
	OUTPUT2 DB 'Currently browsing the product name:$'
	OUTPUT3 DB 'Please input the number 1... 9 to selection function:',0AH,0DH
	        DB '1.Login/login again',0AH,0DH
			DB '2.Finds the specified item and displays its information',0AH,0DH
			DB '3.place an order',0AH,0DH
			DB '4.Calculate the product recommendation',0AH,0DH
			DB '5.ranking',0AH,0DH
			DB '6.Modify product information',0AH,0DH
			DB '7.Migrate the store runtime environment',0AH,0DH
			DB '8.Displays the current code snippet header',0AH,0DH
			DB '9.Quit',0AH,0DH,"$"
	INPUTNAME DB 'Please input a user name:$'
    INPUTPW DB 'Please input password:$'	
	INPUTGOOD DB 'Please enter the product name:$' 
	NOTFIND DB 0AH,0DH,'NOT FIND!',0AH,0DH,'$'
	NOGOODS DB 0AH,0DH,'NOGOODS!',0AH,0DH,'$'
	in_name DB 10
	        DB 0
		    DB 10 DUP(0)
	in_pwd  DB 10
	        DB 0
		    DB 10 DUP(0)
	in_good DB 10
	        DB 0
		    DB 10 DUP(0)
	Temp DW 0
	T DB '0000H','$'
DATA ENDS

CODE SEGMENT USE16
     ASSUME CS:CODE,DS:DATA,SS:STACK
START: 
    ;显示主界面
    MOV  AX, DATA
    MOV  DS, AX
	CRLF ;换行
	WRITE OUTPUT1 ;输出用户名
    CMP ATUH,0    ;如果没有登录就直接换行
	JE CHANGELINE1
    WRITE  BNAME
CHANGELINE1:
    CRLF
	WRITE OUTPUT2  ;输出当前浏览商品名称
	WRITE  GOOD 
    CRLF	
	WRITE  OUTPUT3 ;输出界面提示信息
	
MAIN:	;接受用户输入一个字符
    MOV AH,1
    INT 21H  	
	CMP AL,'9'  ;检查是否是0-9的数字
	JA MAIN
	CMP AL,'1'
	JB MAIN
	;根据输入转移到各自的功能
	CMP AL,'1'
	JE Login
    CMP AL,'2'
	JE FindItem 
	CMP AL,'3'
	JE Order
    MOV SI,OFFSET MAIN	
	CMP AL,'4'
	JE Calculate	
    CMP AL,'5'
	JE Rank
	CMP AL,'6'
	JE Modify
	CMP AL,'7'
	JE Migrate
	CMP AL,'8'
	JE Display
	CMP AL,'9'
	JE Quit
	
Login: ;用户登录
	CRLF
    WRITE  INPUTNAME  ;提示用户输入名字
	READ in_name
	LEA SI,in_name+2 ;SI中存储用户输入的名字首址
	MOV AL,13      ;13是空格的ASCII码值
	CMP [SI],AL    ;如果输入的是回车直接返回主界面
    JNE A
BACK: ;匹配失败，回到主界面
    MOV ATUH,0
	JMP START
A:	
    MOV AL,'$'
	LEA DI,BNAME
LOOP1: ;检查用户名，可以改为使用串比较指令
    MOV BL,[DI]  
    CMP [SI],BL
	JNE BACK
	INC SI
	INC DI
    CMP [DI],AL
	JNE LOOP1
	;提示并输入密码
	CRLF	
	WRITE INPUTPW  
	READ in_pwd
    CRLF
	;检查密码
    LEA SI,in_pwd+2
    LEA DI,BPASS
	MOV CX,6 ;密码6个字节
LOOP2:
    MOV BL,[DI]
	CMP [SI],BL
	JNE BACK
	INC SI
	INC DI
    LOOP LOOP2
	MOV ATUH,1
	JMP START
	
	
FindItem:  ;查找指定商品并显示其信息
    ;提示用户输入商品名称
	CRLF
	WRITE INPUTGOOD   
	;用户输入商品名称
	READ in_good
	
	;在商店中寻找是否存在该商品
	LEA SI,in_good+2  ;SI中存储用户的输入
	LEA DI,GA1-M      ;DI存储商品信息首址
	;每个商品占21个字节，一共有N个商品
    MOV CX,N+1  ;循环次数
	MOV AL,'$'
LOOP3:
    DEC CX
	CMP CX,0
	JNE D ;没有找到商品，返回主界面
	WRITE NOTFIND   ;输出没有找到商品
	JMP START 
D:  ADD DI,M ;每次移动M个字节
	LEA BX,[DI]
LOOP4: ;检查用户名
    MOV DL,[BX]
    CMP [SI],DL
	JNE LOOP3 ;匹配失败，跳出内循环
	INC SI
	INC BX
    CMP [BX],AL
	JNE LOOP4
	;找到商品把信息记录到GOOD中
	MOV BX,0      
	MOV DX,'$' ;作为循环的计数器
COPY: ;把商品名复制进GOOD中
    MOV AL,[DI]
    MOV GOOD[BX],AL
    INC BX
    INC DI
    CMP [DI],DX
    JNE COPY
	MOV GOOD[BX],'$'
    JMP START 	
	
Order: ;下订单
    ;判断GOOD是否为空
	MOV AL,'$'
	CMP GOOD,AL  ;检查GOOD的第一位是不是'$'
	JNE E 
WRONG:    
    WRITE NOGOODS   
	JMP START
E:   ;寻找到当前浏览商品的地址
    LEA DI,GA1-M
    LEA SI,GOOD	
    MOV CX,N+1  ;循环次数
	MOV AL,'$'
OUTLOOP:
    ADD DI,M ;每次移动M个字节
	LEA BX,[DI]
INLOOP: ;检查用户名
    MOV DL,[BX]
    CMP [SI],DL
	JNE OUTLOOP ;匹配失败，跳出内循环
	INC SI
	INC BX
    CMP [BX],AL
	JNE INLOOP
    ;检查剩余数目是否为0
	MOV AX,15[DI]  ;取出进货总数
	MOV BX,17[DI]  ;取出已经销售的数量
	SUB AX,BX 
	JZ WRONG ;如果售完就返回
	INC WORD PTR 17[DI]
	LEA SI,OFFSET FUNC 
	JMP Calculate
FUNC:	
    JMP START
	
	
Calculate: ;计算商品推荐度
    ;推荐度=(（进货价/实际销售价格+已售数量/（2*进货数量）*128)
	;       = (进货价*1280/（销售价*折扣）+64*已售数量/进货数量
	LEA DI,GA1-M
	MOV CX,N
Cal_Re:
    ADD DI,M 
    MOV BX,10[DI] ;取出折扣
	MOV AX,13[DI] ;取出销售价格
	MUL BX
	MOV BX,AX ;BX中是(销售价*折扣）
    MOV AX,11[DI] ;取出进货价   
    MOV DX,1280
    MUL DX ;现在AX中是进货价*1280	
	MOV DX,0
	DIV BX  
	MOV Temp,AX ;把第一部分结果存入Temp
	
	MOV AX,17[DI]  ;取出已经销售的数量
	MOV DX,64
	MUL DX         ;AX中是64*已售数量
	MOV BX,15[DI]  ;取出进货总数
	MOV DX,0       ;要将DX清零再进行字除法，防止溢出
	DIV BX    ;AX中存储的是第二部分的值
	MOV BX,Temp
	ADD BX,AX
	MOV WORD PTR 19[DI],BX
    LOOP Cal_Re	
    JMP SI
	
	
Rank: 
    JMP START
Modify:
    JMP START
Migrate: 
    JMP START
	
	
	
Display: ;将当前代码段首址显示在屏幕上
    MOV AX,CS
	MOV SI,OFFSET T+3
	XOR CX,CX
	MOV CL,4
Dis:
    MOV DH,AL
	
	shr AX,1
	shr AX,1
	shr AX,1
	shr AX,1  ;让AX逻辑右移4位
	
	AND DH,0FH
	ADD DH,30H 
	CMP DH,':'
	JA isLetter
	JB NO
IsLetter:
    ADD DH,7H
No:
    MOV [SI],DH
	DEC SI
    LOOP Dis
	CRLF
	WRITE T 
    JMP START

Quit:
	MOV AH,4CH
	INT 21H
CODE ENDS;
     END START
