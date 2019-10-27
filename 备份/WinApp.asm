TITLE DrawingTool Application

.386 
.model flat,stdcall 
option casemap:none

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD

include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
include comdlg32.inc
include comctl32.inc
include msvcrt.inc

includelib user32.lib 
includelib kernel32.lib 
includelib gdi32.lib
includelib msvcrt.lib
includelib comdlg32.lib
includelib comctl32.lib
includelib msvcrt.lib



;======================== DATA ========================
.data

; 长宽
screenLength dw 541
screenWidth dw 784

; 各种编号
IDM_OPT1  dw 301
IDM_OPT2  dw 302
IDM_OPT3  dw 303
IDM_OPT4  dw 304

IDM_DRAW  dw 401
IDM_ERASE dw 402
IDM_LINE  dw 403
IDM_CIRCLE dw 404
IDM_RECTANGLE dw 405
IDM_ELLIPSE dw 406
IDM_POLYGON dw 407
IDM_TEXT dw 408

IDB_ONE   dw 3301
IDB_TWO   dw 3302
IDB_THREE dw 3303

;资源文件
IDD_DIALOG1                 equ         101
IDC_EDIT1                   equ         1001
IDC_TEXTCURSOR      EQU            106
IDC_ERASERCURSOR EQU 65535
IDC_PAINTCURSOR EQU 104


; 菜单字符串
fileMenuStr db "文件", 0
; newMenuStr db "新建", 0
loadMenuStr db "打开", 0
saveMenuStr db "保存", 0
; saveAsMenuStr db "另存为", 0

fileMenuStr1 db "绘图", 0
drawMenuStr db "画图", 0
eraseMenuStr db "擦除", 0
LineMenuStr db "直线", 0
RectangleMenuStr db "矩形", 0
EllipseMenuStr db "椭圆", 0
PolygonMenuStr db "多边形", 0
TextMenuStr db "文字", 0

; 按钮字符串
lineButtonStr db "直线", 0

ShowString byte 100 dup(?)


; 类名以及程序名
className db "DrawingWinClass", 0
appName db "画图", 0

; 句柄等变量
hInstance HINSTANCE ?
hMenu HMENU ?
commandLine LPSTR ?

; 杂项
buttonStr db "Button", 0

;画线和擦除
;坐标
CurrentX DWORD 0
CurrentY DWORD 0
StartX DWORD 0
StartY DWORD 0
EndX DWORD 0
EndY DWORD 0
;鼠标状态
MouseStatus DWORD 0


pointX dd 0
pointY dd 0


; 模式
CurrentMode DWORD 0
;画多边形是否已经结束
WhetherDrawPolygon DWORD 0

;当前使用的点数目
CurrentPointNum DWORD 0
CurrentPointListX DWORD 100 DUP(?)
CurrentPointListY DWORD 100 DUP(?)
CurrentPointList DWORD 200 DUP(?)
;判断两点是否接近的Threshold
SameThreshold DWORD 2

; 工作区域
workRegion RECT <0, 0, 800, 600>

; 结构体定义
PAINTDATA STRUCT
	ptBeginX dd ?
	ptBeginY dd ?
	ptEndX   dd ?
	ptEndY   dd ?
	penStyle dd ?
PAINTDATA ENDS

; 保存有关
filetype1 byte "BMP(*.bmp)", 0 ,"*.bmp", 0, 0
filetype2 byte "BMP(*.bmp)", 0, 0
finalname byte "bmp", 0
fileHandle DWORD ?
; szFileName BYTE "painting.bmp", 0
szFileName	db	MAX_PATH DUP (?)
szTitleName	db	MAX_PATH DUP (?)
ofn OPENFILENAME <>
;======================== CODE ========================
.code

main:
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	INVOKE GetCommandLine
	mov commandLine, eax
	INVOKE WinMain, hInstance, NULL, commandLine, SW_SHOWDEFAULT
	INVOKE ExitProcess, eax

; 创建菜单
createMenu PROC
	LOCAL popFile: HMENU
	LOCAL popFile1: HMENU

	INVOKE CreateMenu
	.IF eax == 0
		ret
	.ENDIF
	mov hMenu, eax

	INVOKE CreatePopupMenu
	mov popFile, eax

	INVOKE CreatePopupMenu
	mov popFile1, eax
	
	INVOKE AppendMenu, hMenu, MF_POPUP, popFile, ADDR fileMenuStr

	; INVOKE AppendMenu, popFile, MF_STRING, IDM_OPT1, ADDR newMenuStr
	INVOKE AppendMenu, popFile, MF_STRING, IDM_OPT2, ADDR loadMenuStr
	INVOKE AppendMenu, popFile, MF_STRING, IDM_OPT3, ADDR saveMenuStr
	; INVOKE AppendMenu, popFile, MF_STRING, IDM_OPT4, ADDR saveAsMenuStr

	INVOKE AppendMenu, hMenu, MF_POPUP, popFile1, ADDR fileMenuStr1
	
	INVOKE AppendMenu, popFile1, MF_STRING, IDM_DRAW, ADDR drawMenuStr
	INVOKE AppendMenu, popFile1, MF_STRING, IDM_ERASE, ADDR eraseMenuStr
	INVOKE AppendMenu, popFile1, MF_STRING, IDM_LINE, ADDR LineMenuStr
	INVOKE AppendMenu, popFile1, MF_STRING, IDM_RECTANGLE, ADDR RectangleMenuStr
	INVOKE AppendMenu, popFile1, MF_STRING, IDM_ELLIPSE, ADDR EllipseMenuStr
	INVOKE AppendMenu, popFile1, MF_STRING, IDM_POLYGON, ADDR PolygonMenuStr
	INVOKE AppendMenu, popFile1, MF_STRING, IDM_TEXT, ADDR TextMenuStr

	ret

createMenu ENDP

GetCurrentPoint PROC, Place:DWORD
;获得当前点信息
	push ebx
	push edx
	mov ebx, Place
	mov edx, 0
	mov dx, bx
	sar ebx, 16
	mov CurrentX, edx
	mov CurrentY, ebx
	pop edx
	pop ebx
	ret
GetCurrentPoint ENDP

JudgeWhetherSame PROC
	;判断多边形初始点和当前点是否足够接近
	;接近：eax = 1 否则eax = 0
	push edx
	push ebx
	push ecx
	push esi
	.IF CurrentPointNum < 3
		mov eax, 0
	jmp EndJudge
	.ENDIF

	mov edx, OFFSET CurrentPointListX
	mov ecx, [edx]
	.IF ecx > CurrentX
		mov esi, ecx
		sub esi, CurrentX
	.ELSE
		mov esi, CurrentX
		sub esi, ecx
	.ENDIF
	.IF esi > SameThreshold
		mov eax, 0
		jmp EndJudge
	.ENDIF

	mov edx, OFFSET CurrentPointListY
	mov ecx, [edx]
	.IF ecx > CurrentY
		mov esi, ecx
		sub esi, CurrentY
	.ELSE
		mov esi, CurrentY
		sub esi, ecx
	.ENDIF
	.IF esi > SameThreshold
		mov eax, 0
		jmp EndJudge
	.ENDIF
	mov eax, 1
EndJudge:
	mov WhetherDrawPolygon, eax
	pop esi
	pop ecx
	pop ebx
	pop edx
	ret
JudgeWhetherSame ENDP


AddGraphPoint PROC
	;存储点
	LOCAL PointerX:DWORD
	LOCAL PointerY:DWORD
	push edx
	push ebx
	mov edx, OFFSET CurrentPointListX
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	mov PointerX, edx
	mov edx, OFFSET CurrentPointListY
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	mov PointerY, edx

	mov ebx, CurrentX
	mov edx, PointerX
	mov [edx], ebx
	mov ebx, CurrentY
	mov edx, PointerY
	mov [edx], ebx
	inc CurrentPointNum
	pop ebx
	pop edx
	ret
AddGraphPoint ENDP

SwitchGraphPoint PROC
;将x，y两个数组转化为连续x，y的数组
	push esi
	push edx
	push ecx
	push ebx
	push edi

	mov esi, 0
	.WHILE esi < CurrentPointNum
		mov edx, OFFSET CurrentPointListX
		add edx, esi
		add edx, esi
		add edx, esi
		add edx, esi

		mov ecx, OFFSET CurrentPointListY
		add ecx, esi
		add ecx, esi
		add ecx, esi
		add ecx, esi
		
		mov ebx, OFFSET CurrentPointList
		add ebx, esi
		add ebx, esi
		add ebx, esi
		add ebx, esi
		add ebx, esi
		add ebx, esi
		add ebx, esi
		add ebx, esi

		mov edi, [edx]
		mov [ebx], edi
		add ebx, 4
		mov edi, [ecx]
		mov [ebx], edi
		inc esi
	.ENDW
	pop edi
	pop ebx
	pop ecx
	pop edx
	pop esi
	ret
SwitchGraphPoint ENDP


DLGHandleCommand proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov ebx,wParam
    and ebx,0ffffh
    .IF ebx==IDOK
        invoke GetDlgItemText,hWnd,IDC_EDIT1,addr ShowString, 100
        invoke EndDialog,hWnd,wParam
    .ELSEIF ebx==IDCANCEL
        invoke EndDialog,hWnd,wParam
        mov eax,TRUE
    .ENDIF
    ret
DLGHandleCommand endp

DialogProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx==WM_COMMAND
        invoke DLGHandleCommand,hWnd,wParam,lParam
    .ELSE 
		;默认处理
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret
DialogProc endp

CVSSetCursor proc hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov eax,lParam
    and eax,0ffffh
    .IF eax!=HTCLIENT
        ret
    .ENDIF

    mov eax,CurrentMode
    .IF eax==1
        mov ebx,IDC_ERASERCURSOR
    .ELSEIF eax==6
        mov ebx,IDC_TEXTCURSOR
    .ELSE
        mov ebx,IDC_PAINTCURSOR
    .ENDIF
    invoke LoadCursor,hInstance,ebx
    invoke SetCursor,eax
    ret
CVSSetCursor endp


WinMain PROC,
	hInst: HINSTANCE, hPrevInst: HINSTANCE, CmdLine: LPSTR, CmdShow: DWORD
	LOCAL wc: WNDCLASSEX
	LOCAL msg: MSG
	LOCAL hwnd: HWND

	INVOKE createMenu
	mov wc.cbSize, SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra, NULL
	mov wc.cbWndExtra, NULL
	push hInst
	pop wc.hInstance
	mov wc.hbrBackground, COLOR_WINDOW+1
	mov wc.lpszMenuName, NULL
	mov wc.lpszClassName, OFFSET className
	INVOKE LoadIcon, NULL, IDI_APPLICATION
	mov wc.hIcon, eax
	mov wc.hIconSm, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov wc.hCursor, eax
	INVOKE RegisterClassEx, ADDR wc
	INVOKE CreateWindowEx, NULL, ADDR className, ADDR appName, \
		WS_OVERLAPPEDWINDOW AND (NOT WS_SIZEBOX) AND (NOT WS_MAXIMIZEBOX) AND (NOT WS_MINIMIZEBOX), CW_USEDEFAULT, \
		CW_USEDEFAULT, 800, 600, NULL, hMenu, \
		hInst, NULL
	mov hwnd, eax
	INVOKE ShowWindow, hwnd, SW_SHOWNORMAL
	INVOKE UpdateWindow, hwnd
	.WHILE TRUE
		INVOKE GetMessage, ADDR msg, NULL, 0, 0
		.BREAK .IF (!eax)
			INVOKE TranslateMessage, ADDR msg
		INVOKE DispatchMessage, ADDR msg
	.ENDW
	mov eax, msg.wParam
	ret
WinMain ENDP



WndProc PROC USES ebx ecx edx,
	hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM

	LOCAL hdc: HDC
	LOCAL hbuf: HDC
	LOCAL hdcMem: HDC
	LOCAL hBitmap: HBITMAP
	LOCAL ps: PAINTSTRUCT
	LOCAL rect: RECT
	LOCAL lowordWParam: WORD
	LOCAL p: POINT
	LOCAL bmfh: BITMAPFILEHEADER
	LOCAL bmih: BITMAPINFOHEADER
	LOCAL nColorLen: DWORD
    LOCAL dwRgbQuadSize: DWORD
    LOCAL dwBmSize: DWORD
    LOCAL hMem: HGLOBAL
    LOCAL lpbi: DWORD   
    LOCAL bm: BITMAP
    LOCAL hFile: HANDLE
    LOCAL dwWritten: DWORD
	LOCAL RawMousePlace: DWORD

	.IF uMsg == WM_DESTROY
		INVOKE PostQuitMessage, NULL
	.ELSEIF uMsg == WM_COMMAND	; 响应事件
		mov ebx, wParam
		.IF bx == IDM_DRAW  ; 画图模式
			mov CurrentMode,0
		.ELSEIF bx == IDM_ERASE ; 擦除模式
			mov CurrentMode,1
		.ELSEIF bx == IDM_LINE ;画线
			mov CurrentMode,2
		.ELSEIF bx == IDM_RECTANGLE ;矩形
			mov CurrentMode,3
		.ELSEIF bx == IDM_ELLIPSE ;椭圆
			mov CurrentMode,4
		.ELSEIF bx == IDM_POLYGON ;多边形
			mov CurrentMode,5
		.ELSEIF bx == IDM_TEXT ;多边形
			mov CurrentMode,6
		.ENDIF
	.ELSEIF uMsg == WM_MOUSEMOVE
		;获取当前位置
		mov ebx, lParam
		mov RawMousePlace, ebx
		INVOKE GetCurrentPoint, RawMousePlace
		mov edx, CurrentX
		mov ebx, CurrentY
		.IF CurrentMode == 0    ;drawing mode
			.IF MouseStatus == 1
				;更新画线位置 
				.IF EndX == 0  ;第一次画线
					mov StartX, edx
				.ELSE
					mov eax, EndX
					mov StartX, eax
				.ENDIF

				.IF EndY == 0 ;第一次画线
					mov StartY, ebx
				.ELSE
					mov eax, EndY
					mov StartY, eax
				.ENDIF

				mov EndX, edx
				mov EndY, ebx
				INVOKE InvalidateRect, hWnd, ADDR workRegion, 0
			.ENDIF
		.ENDIF

		.IF CurrentMode == 1 ; Erasing mode
			.IF MouseStatus == 1
				INVOKE InvalidateRect, hWnd, ADDR workRegion, 0
			.ENDIF
		.ENDIF
		
	.ELSEIF uMsg == WM_LBUTTONDOWN
		;.IF mode == 0 || mode == 1
			mov MouseStatus, 1
		;.ENDIF
	.ELSEIF uMsg == WM_LBUTTONUP
		.IF CurrentMode == 0 || CurrentMode == 1
			mov MouseStatus, 0
			mov StartX, 0
			mov StartY, 0
			mov EndX, 0
			mov EndY, 0
		.ELSEIF CurrentMode == 2 || CurrentMode == 3 || CurrentMode == 4 
			;获取当前位置
			mov ebx, lParam
			mov RawMousePlace, ebx
			INVOKE GetCurrentPoint, RawMousePlace
			INVOKE AddGraphPoint
			.IF CurrentPointNum == 2
				INVOKE InvalidateRect, hWnd, ADDR workRegion, 0
			.ENDIF
		.ELSEIF CurrentMode == 5
			;获取当前位置
			mov ebx, lParam
			mov RawMousePlace, ebx
			INVOKE GetCurrentPoint, RawMousePlace
			INVOKE JudgeWhetherSame
			.IF WhetherDrawPolygon == 0
				INVOKE AddGraphPoint
			.ENDIF
			.IF CurrentPointNum >= 2
				INVOKE InvalidateRect, hWnd, ADDR workRegion, 0
			.ENDIF
		.ELSEIF CurrentMode == 6
			;获取当前位置
			mov ebx, lParam
			mov RawMousePlace, ebx
			INVOKE GetCurrentPoint, RawMousePlace
			INVOKE InvalidateRect, hWnd, ADDR workRegion, 0
		.ENDIF
	.ELSEIF uMsg == WM_SETCURSOR
		invoke CVSSetCursor,hWnd,wParam,lParam
	.ELSEIF uMsg == WM_PAINT
		INVOKE BeginPaint, hWnd, ADDR ps
		.IF CurrentMode == 0
			; ebx = pen
			;INVOKE CreatePen, PS_SOLID, 1, 0
			;mov ebx, eax
			INVOKE MoveToEx, ps.hdc, StartX, StartY, NULL
			INVOKE LineTo, ps.hdc, EndX, EndY
			;INVOKE DeleteObject, ebx
		.ELSEIF CurrentMode == 1
				;INVOKE RGB,0,0,0
				;INVOKE SetDCBrushColor, ps.hdc, 0
				INVOKE GetStockObject, NULL_PEN
				INVOKE SelectObject, ps.hdc, eax
				sub CurrentX, 10
				sub CurrentY, 10
				mov ebx, CurrentX
				mov edx, CurrentY
				add ebx, 20
				add edx, 20
				INVOKE Rectangle, ps.hdc, CurrentX, CurrentY, ebx, edx
				add CurrentX, 10
				add CurrentY, 10
		.ELSEIF CurrentMode == 2
			mov edx, DWORD PTR [CurrentPointListX]
			mov ecx, DWORD PTR [CurrentPointListY]
			INVOKE MoveToEx, ps.hdc, edx, ecx, NULL
			mov edx, DWORD PTR [CurrentPointListX + 4]
			mov ecx, DWORD PTR [CurrentPointListY + 4]
			INVOKE LineTo, ps.hdc, edx, ecx
			mov CurrentPointNum, 0
		.ELSEIF CurrentMode == 3
			mov edx, DWORD PTR [CurrentPointListX]
			mov ecx, DWORD PTR [CurrentPointListY]
			mov ebx, DWORD PTR [CurrentPointListX + 4]
			mov eax, DWORD PTR [CurrentPointListY + 4]
			INVOKE Rectangle, ps.hdc, edx, ecx, ebx, eax
			mov CurrentPointNum, 0
		.ELSEIF CurrentMode == 4
			mov edx, DWORD PTR [CurrentPointListX]
			mov ecx, DWORD PTR [CurrentPointListY]
			mov ebx, DWORD PTR [CurrentPointListX + 4]
			mov eax, DWORD PTR [CurrentPointListY + 4]
			INVOKE Ellipse, ps.hdc, edx, ecx, ebx, eax
			mov CurrentPointNum, 0
		.ELSEIF CurrentMode == 5
			.IF WhetherDrawPolygon == 0
				;只画线
				push esi
				mov esi, OFFSET CurrentPointListX
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				sub esi, 4
				mov ebx, DWORD PTR [esi]
				sub esi, 4
				mov edx, DWORD PTR [esi]

				mov esi, OFFSET CurrentPointListY
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				sub esi, 4
				mov edi, DWORD PTR [esi]
				sub esi, 4
				mov ecx, DWORD PTR [esi]
				INVOKE MoveToEx, ps.hdc, edx, ecx, NULL
				INVOKE LineTo, ps.hdc, ebx, edi
			.ELSE
				;画多边形

				push esi
				mov esi, OFFSET CurrentPointListX
				mov edx, DWORD PTR [esi]
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				sub esi, 4
				mov ebx, DWORD PTR [esi]

				mov esi, OFFSET CurrentPointListY
				mov ecx, DWORD PTR [esi]
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				add esi, CurrentPointNum
				sub esi, 4
				mov edi, DWORD PTR [esi]

				INVOKE MoveToEx, ps.hdc, edx, ecx, NULL
				INVOKE LineTo, ps.hdc, ebx, edi
				INVOKE MoveToEx, ps.hdc, 0, 0, NULL
				INVOKE SwitchGraphPoint
				INVOKE Polygon, ps.hdc, ADDR CurrentPointList, CurrentPointNum
				mov CurrentPointNum, 0
			.ENDIF

		.ELSEIF CurrentMode == 6
			mov edx, CurrentX
			mov ecx, CurrentY
			push edx
			push ecx
			invoke DialogBoxParam,hInstance,IDD_DIALOG1,hWnd,offset DialogProc,0
			invoke crt_strlen,offset ShowString
			pop ecx
			pop edx
			INVOKE TextOutA, ps.hdc, edx, ecx, ADDR ShowString, eax

		.ENDIF


		INVOKE EndPaint, hWnd, ADDR ps
	.ELSE
		INVOKE DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.ENDIF

	xor eax, eax
	ret
WndProc ENDP

end main