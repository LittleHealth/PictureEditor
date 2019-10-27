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

; ����
screenLength dw 541
screenWidth dw 784

; ���ֱ��
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

;��Դ�ļ�
IDD_DIALOG1                 equ         101
IDC_EDIT1                   equ         1001
IDC_TEXTCURSOR      EQU            106
IDC_ERASERCURSOR EQU 65535
IDC_PAINTCURSOR EQU 104


; �˵��ַ���
fileMenuStr db "�ļ�", 0
; newMenuStr db "�½�", 0
loadMenuStr db "��", 0
saveMenuStr db "����", 0
; saveAsMenuStr db "���Ϊ", 0

fileMenuStr1 db "��ͼ", 0
drawMenuStr db "��ͼ", 0
eraseMenuStr db "����", 0
LineMenuStr db "ֱ��", 0
RectangleMenuStr db "����", 0
EllipseMenuStr db "��Բ", 0
PolygonMenuStr db "�����", 0
TextMenuStr db "����", 0

; ��ť�ַ���
lineButtonStr db "ֱ��", 0

ShowString byte 100 dup(?)


; �����Լ�������
className db "DrawingWinClass", 0
appName db "��ͼ", 0

; ����ȱ���
hInstance HINSTANCE ?
hMenu HMENU ?
commandLine LPSTR ?

; ����
buttonStr db "Button", 0

;���ߺͲ���
;����
CurrentX DWORD 0
CurrentY DWORD 0
StartX DWORD 0
StartY DWORD 0
EndX DWORD 0
EndY DWORD 0
;���״̬
MouseStatus DWORD 0


pointX dd 0
pointY dd 0


; ģʽ
CurrentMode DWORD 0
;��������Ƿ��Ѿ�����
WhetherDrawPolygon DWORD 0

;��ǰʹ�õĵ���Ŀ
CurrentPointNum DWORD 0
CurrentPointListX DWORD 100 DUP(?)
CurrentPointListY DWORD 100 DUP(?)
CurrentPointList DWORD 200 DUP(?)
;�ж������Ƿ�ӽ���Threshold
SameThreshold DWORD 2

; ��������
workRegion RECT <0, 0, 800, 600>

; �ṹ�嶨��
PAINTDATA STRUCT
	ptBeginX dd ?
	ptBeginY dd ?
	ptEndX   dd ?
	ptEndY   dd ?
	penStyle dd ?
PAINTDATA ENDS

; �����й�
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

; �����˵�
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
;��õ�ǰ����Ϣ
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
	;�ж϶���γ�ʼ��͵�ǰ���Ƿ��㹻�ӽ�
	;�ӽ���eax = 1 ����eax = 0
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
	;�洢��
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
;��x��y��������ת��Ϊ����x��y������
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
		;Ĭ�ϴ���
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
	.ELSEIF uMsg == WM_COMMAND	; ��Ӧ�¼�
		mov ebx, wParam
		.IF bx == IDM_DRAW  ; ��ͼģʽ
			mov CurrentMode,0
		.ELSEIF bx == IDM_ERASE ; ����ģʽ
			mov CurrentMode,1
		.ELSEIF bx == IDM_LINE ;����
			mov CurrentMode,2
		.ELSEIF bx == IDM_RECTANGLE ;����
			mov CurrentMode,3
		.ELSEIF bx == IDM_ELLIPSE ;��Բ
			mov CurrentMode,4
		.ELSEIF bx == IDM_POLYGON ;�����
			mov CurrentMode,5
		.ELSEIF bx == IDM_TEXT ;�����
			mov CurrentMode,6
		.ENDIF
	.ELSEIF uMsg == WM_MOUSEMOVE
		;��ȡ��ǰλ��
		mov ebx, lParam
		mov RawMousePlace, ebx
		INVOKE GetCurrentPoint, RawMousePlace
		mov edx, CurrentX
		mov ebx, CurrentY
		.IF CurrentMode == 0    ;drawing mode
			.IF MouseStatus == 1
				;���»���λ�� 
				.IF EndX == 0  ;��һ�λ���
					mov StartX, edx
				.ELSE
					mov eax, EndX
					mov StartX, eax
				.ENDIF

				.IF EndY == 0 ;��һ�λ���
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
			;��ȡ��ǰλ��
			mov ebx, lParam
			mov RawMousePlace, ebx
			INVOKE GetCurrentPoint, RawMousePlace
			INVOKE AddGraphPoint
			.IF CurrentPointNum == 2
				INVOKE InvalidateRect, hWnd, ADDR workRegion, 0
			.ENDIF
		.ELSEIF CurrentMode == 5
			;��ȡ��ǰλ��
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
			;��ȡ��ǰλ��
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
				;ֻ����
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
				;�������

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