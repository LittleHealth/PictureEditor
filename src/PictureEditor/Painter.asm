;�ļ�����Painter.asm
;���������ֻ�ͼ�����Ķ���

.386 
.model flat,stdcall 
option casemap:none

include Define.inc

public CurrentMode
public CurrentX
public CurrentY
public StartX
public StartY
public EndX
public EndY
public MouseStatus
public ShowString
public WhetherDrawPolygon
public CurrentPointNum
public CurrentPointListX
public CurrentPointListY
public CurrentPointList
public SameThreshold

.data
; ģʽ
CurrentMode DWORD IDM_MODE_DRAW

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

;������ε�
;��������Ƿ��Ѿ�����
WhetherDrawPolygon DWORD 0

;��ǰʹ�õĵ���Ϣ
CurrentPointNum DWORD 0
CurrentPointListX DWORD 100 DUP(?)
CurrentPointListY DWORD 100 DUP(?)

;ʵ�ʻ�����εĲ���
CurrentPointList DWORD 200 DUP(?)
;�ж������Ƿ�ӽ���Threshold
SameThreshold DWORD 2

;��ʾ������
ShowString BYTE 100 dup(?)


.code
;���ʻ��ƺ���
IPaint PROC, hdc:HDC
	INVOKE MoveToEx, hdc, StartX, StartY, NULL
	INVOKE LineTo, hdc, EndX, EndY
	INVOKE MoveToEx, hdc, 0, 0, NULL
	ret
IPaint ENDP

;��Ƥ��������
IErase PROC, hdc:HDC
	extern EraserRadius:DWORD
	INVOKE GetStockObject, NULL_PEN
	INVOKE SelectObject, hdc, eax
	mov ecx, EraserRadius
	sub CurrentX, ecx
	sub CurrentY, ecx
	mov ebx, CurrentX
	mov edx, CurrentY
	add ebx, ecx
	add ebx, ecx
	add edx, ecx
	add edx, ecx
	INVOKE Rectangle, hdc, CurrentX, CurrentY, ebx, edx
	add CurrentX, ecx
	add CurrentY, ecx
	ret
IErase ENDP

;�������뺯��
IText PROC, hdc:HDC,hWnd:HWND
	extern hInstance:HINSTANCE
	mov edx, CurrentX
	mov ecx, CurrentY
	push edx
	push ecx
	invoke DialogBoxParam, hInstance, IDD_DIALOG1 ,hWnd, OFFSET ICallTextDialog, 0
	invoke crt_strlen, OFFSET ShowString
	pop ecx
	pop edx
	INVOKE TextOutA, hdc, edx, ecx, ADDR ShowString, eax
	ret
IText ENDP

;���ߺ���
IPaintLine PROC, hdc:HDC
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	INVOKE MoveToEx, hdc, 0, 0, NULL
	mov CurrentPointNum, 0
	ret
IPaintLine ENDP

;�����ο���
IPaintRectangleFrame PROC hdc:HDC
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE LineTo, hdc, edx, ecx
	INVOKE MoveToEx, hdc, 0, 0, NULL
	mov CurrentPointNum, 0
	ret
IPaintRectangleFrame ENDP

;��ֱ��������(�Ϸ�)����
IPaintTriangle0Frame PROC hdc:HDC
	LOCAL MiddleX:DWORD, MiddleY:DWORD
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	mov esi, DWORD PTR [CurrentPointListX + 4]
	mov edi, DWORD PTR [CurrentPointListY + 4]
	.IF ecx < edi
		mov MiddleY, ecx
		mov MiddleX, esi
	.ELSE
		mov MiddleY, edi
		mov MiddleX, edx
	.ENDIF
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, MiddleX
	mov ecx, MiddleY
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, MiddleX
	mov ecx, MiddleY
	INVOKE LineTo, hdc, edx, ecx
	INVOKE MoveToEx, hdc, 0, 0, NULL
	mov CurrentPointNum, 0
	ret
IPaintTriangle0Frame ENDP

;��ֱ��������(�·�)����
IPaintTriangle1Frame PROC hdc:HDC
LOCAL MiddleX:DWORD, MiddleY:DWORD
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	mov esi, DWORD PTR [CurrentPointListX + 4]
	mov edi, DWORD PTR [CurrentPointListY + 4]
	.IF ecx > edi
		mov MiddleY, ecx
		mov MiddleX, esi
	.ELSE
		mov MiddleY, edi
		mov MiddleX, edx
	.ENDIF
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, MiddleX
	mov ecx, MiddleY
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, MiddleX
	mov ecx, MiddleY
	INVOKE LineTo, hdc, edx, ecx
	INVOKE MoveToEx, hdc, 0, 0, NULL
	mov CurrentPointNum, 0
	ret
IPaintTriangle1Frame ENDP

;������ο���
IPaintPolygonFrame PROC, hdc:HDC
	.IF WhetherDrawPolygon == 0
		INVOKE IIncreasePolygonLine, hdc
	.ELSEIF WhetherDrawPolygon == 1
		INVOKE IIncreasePolygonLastLine, hdc
		mov CurrentPointNum, 0
	.ENDIF
	ret
IPaintPolygonFrame ENDP

;�����κ���
IPaintRectangle PROC, hdc:HDC
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	mov ebx, DWORD PTR [CurrentPointListX + 4]
	mov eax, DWORD PTR [CurrentPointListY + 4]
	INVOKE Rectangle, hdc, edx, ecx, ebx, eax
	mov CurrentPointNum, 0
	ret
IPaintRectangle ENDP

;��ֱ��������(�Ϸ�)����
IPaintTriangle0 PROC hdc:HDC
	LOCAL MiddleX:DWORD, MiddleY:DWORD
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	mov esi, DWORD PTR [CurrentPointListX + 4]
	mov edi, DWORD PTR [CurrentPointListY + 4]
	.IF ecx < edi
		mov MiddleY, ecx
		mov MiddleX, esi
	.ELSE
		mov MiddleY, edi
		mov MiddleX, edx
	.ENDIF
	mov ebx, OFFSET CurrentPointList
	mov [ebx], edx
	add ebx, 4
	mov [ebx], ecx
	add ebx, 4
	mov [ebx], esi
	add ebx, 4
	mov [ebx], edi
	add ebx, 4
	mov eax, MiddleX
	mov [ebx], eax
	add ebx, 4
	mov eax, MiddleY
	mov [ebx], eax
	INVOKE Polygon, hdc, ADDR CurrentPointList, 3
	mov CurrentPointNum, 0
	ret
IPaintTriangle0 ENDP

;��ֱ��������(�·�)����
IPaintTriangle1 PROC hdc:HDC
	LOCAL MiddleX:DWORD, MiddleY:DWORD
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	mov esi, DWORD PTR [CurrentPointListX + 4]
	mov edi, DWORD PTR [CurrentPointListY + 4]
	.IF ecx > edi
		mov MiddleY, ecx
		mov MiddleX, esi
	.ELSE
		mov MiddleY, edi
		mov MiddleX, edx
	.ENDIF
	mov ebx, OFFSET CurrentPointList
	mov [ebx], edx
	add ebx, 4
	mov [ebx], ecx
	add ebx, 4
	mov [ebx], esi
	add ebx, 4
	mov [ebx], edi
	add ebx, 4
	mov eax, MiddleX
	mov [ebx], eax
	add ebx, 4
	mov eax, MiddleY
	mov [ebx], eax
	INVOKE Polygon, hdc, ADDR CurrentPointList, 3
	mov CurrentPointNum, 0
	ret
IPaintTriangle1 ENDP

;����Բ����
IPaintEllipse PROC, hdc:HDC
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	mov ebx, DWORD PTR [CurrentPointListX + 4]
	mov eax, DWORD PTR [CurrentPointListY + 4]
	INVOKE Ellipse, hdc, edx, ecx, ebx, eax
	mov CurrentPointNum, 0
	ret
IPaintEllipse ENDP

;������κ���
IPaintPolygon PROC, hdc:HDC
	.IF WhetherDrawPolygon == 0
		INVOKE IIncreasePolygonLine, hdc
	.ELSEIF WhetherDrawPolygon == 1
		INVOKE IIncreasePolygonLastLine, hdc
		INVOKE IGetPolygonPointList
		INVOKE Polygon, hdc, ADDR CurrentPointList, CurrentPointNum
		mov CurrentPointNum, 0
	.ENDIF
	ret
IPaintPolygon ENDP

;�ڶ���λ���ʱ����һ����
IIncreasePolygonLine PROC, hdc:HDC
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
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	INVOKE LineTo, hdc, ebx, edi
	INVOKE MoveToEx, hdc, 0, 0, NULL
	ret
IIncreasePolygonLine ENDP

;�ڶ���λ���ʱ�������һ���ߣ����ӿ�ʼ�ͽ���
IIncreasePolygonLastLine PROC, hdc:HDC
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

	INVOKE MoveToEx, hdc, edx, ecx, NULL
	INVOKE LineTo, hdc, ebx, edi
	INVOKE MoveToEx, hdc, 0, 0, NULL
	ret
IIncreasePolygonLastLine ENDP 

;��õ�ǰ����Ϣ
IGetCurrentPoint PROC, Place:DWORD
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
IGetCurrentPoint ENDP

;�ж϶�����Ƿ�������--�Ѿ������������ϣ����һ����͵�һ����ӽ��غ�.
;�ӽ���eax = 1 ����eax = 0
IJudgePolygonEnd PROC
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
IJudgePolygonEnd ENDP

;����ǰ��洢������
IAddGraphPoint PROC
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
IAddGraphPoint ENDP

;���ݵ��еõ����ƶ���εĴ洢����
;��x��y��������ת��Ϊ����x��y������
IGetPolygonPointList PROC
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
IGetPolygonPointList ENDP

;�����Ի�����������
ICallTextDialog PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx == WM_COMMAND
        invoke IHandleTextDialog,hWnd,wParam,lParam
    .ELSE 
		;Ĭ�ϴ���
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret
ICallTextDialog endp

;���Ի����������ִ洢�����ڻ���
IHandleTextDialog PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov ebx,wParam
    and ebx,0ffffh
    .IF ebx == IDOK
        invoke GetDlgItemText,hWnd,IDC_EDIT1,addr ShowString, MAX_LENGTH
        invoke EndDialog,hWnd,wParam
    .ELSEIF ebx == IDCANCEL
        invoke EndDialog,hWnd,wParam
        mov eax,TRUE
    .ENDIF
    ret
IHandleTextDialog ENDP
end

