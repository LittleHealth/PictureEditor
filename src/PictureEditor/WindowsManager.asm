;�ļ�����WindowsManager.asm
;������Win32��غ������壬������꣬��꣬�Ի��򣬻�ͼ�¼��Ĵ���

.386 
.model flat,stdcall 
option casemap:none

include Define.inc


.code
;����WM_COMMAND(�˵����)���µ�ģʽ�仯
IHandleModeChange PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	extern CurrentMode:DWORD
	extern CurrentPointNum:DWORD
	mov ebx, wParam
	mov CurrentPointNum, 0
	mov ecx, CurrentMode
	.IF bx == IDM_DRAW  ; ��ͼ
		mov ecx, IDM_MODE_DRAW
	.ELSEIF bx == IDM_ERASE ; ����
		mov ecx, IDM_MODE_ERASE
	.ELSEIF bx == IDM_TEXT ;����
		mov ecx, IDM_MODE_TEXT
	.ELSEIF bx == IDM_LINE ;����
		mov ecx, IDM_MODE_LINE
	.ELSEIF bx == IDM_TRIANGLE0_FRAME ;�������α߿�
		mov ecx, IDM_MODE_TRIANGLE0_FRAME
	.ELSEIF bx == IDM_TRIANGLE1_FRAME ;�������α߿�
		mov ecx, IDM_MODE_TRIANGLE1_FRAME
	.ELSEIF bx == IDM_RECTANGLE_FRAME ;���α߿�
		mov ecx, IDM_MODE_RECTANGLE_FRAME
	.ELSEIF bx == IDM_POLYGON_FRAME ;����α߿�
		mov ecx, IDM_MODE_POLYGON_FRAME
	.ELSEIF bx == IDM_TRIANGLE0 ;��������
		mov ecx, IDM_MODE_TRIANGLE0
	.ELSEIF bx == IDM_TRIANGLE1 ;��������
		mov ecx, IDM_MODE_TRIANGLE1
	.ELSEIF bx == IDM_RECTANGLE ;����
		mov ecx, IDM_MODE_RECTANGLE
	.ELSEIF bx == IDM_ELLIPSE ;��Բ
		mov ecx, IDM_MODE_ELLIPSE
	.ELSEIF bx == IDM_POLYGON ;�����
		mov ecx, IDM_MODE_POLYGON
	.ENDIF
	mov CurrentMode, ecx
	ret
IHandleModeChange ENDP 

;��������ƶ��¼�(������д��)
IHandleMouseMove PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	extern CurrentMode: DWORD
	extern MouseStatus: DWORD
	extern StartX: DWORD
	extern StartY: DWORD
	extern EndX: DWORD
	extern EndY: DWORD
	extern CurrentX: DWORD
	extern CurrentY: DWORD
	extern CurrentPointNum: DWORD
	extern WhetherDrawPolygon: DWORD
	;��ȡ��ǰλ��
	mov ebx, lParam
	INVOKE IGetCurrentPoint, ebx
	mov edx, CurrentX
	mov ebx, CurrentY
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW    ;����
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
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ELSEIF ecx == IDM_MODE_ERASE ;����
		.IF MouseStatus == 1
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ENDIF
	ret
IHandleMouseMove ENDP

;������갴���¼�(������д��)
IHandleButtonDown PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	extern CurrentMode: DWORD
	extern MouseStatus:DWORD
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW || ecx == IDM_MODE_ERASE
		;���ʻ�����Ƥ
		mov MouseStatus, 1
	.ENDIF
	ret
IHandleButtonDown ENDP 

;��������������¼�(������д�룬����)
IHandleButtonUp PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	extern CurrentMode: DWORD
	extern MouseStatus: DWORD
	extern StartX: DWORD
	extern StartY: DWORD
	extern EndX: DWORD
	extern EndY: DWORD
	extern CurrentPointNum: DWORD
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW || ecx == IDM_MODE_ERASE
		;���ʻ�����Ƥ
		mov MouseStatus, 0
		mov StartX, 0
		mov StartY, 0
		mov EndX, 0
		mov EndY, 0
	.ELSEIF ecx == IDM_MODE_TEXT
		;����
		mov ebx, lParam
		INVOKE IGetCurrentPoint, ebx
		INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
	.ELSEIF ecx == IDM_MODE_POLYGON || ecx == IDM_MODE_POLYGON_FRAME
		;����λ��߱߿�
		mov ebx, lParam
		INVOKE IGetCurrentPoint, ebx
		INVOKE IJudgePolygonEnd
		.IF WhetherDrawPolygon == 0
			INVOKE IAddGraphPoint
		.ENDIF
		.IF CurrentPointNum >= 2
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ELSE
		;���ߣ����Σ���Բ�������εȶ������
		mov ebx, lParam
		INVOKE IGetCurrentPoint, ebx
		INVOKE IAddGraphPoint
		.IF CurrentPointNum == 2
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ENDIF
	ret
IHandleButtonUp ENDP

;�������¼�
IHandleCursor PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	extern hInstance:HINSTANCE
	mov eax,lParam
    and eax,0ffffh
    .IF eax!=HTCLIENT
        ret
    .ENDIF

    mov eax,CurrentMode
    .IF eax == IDM_MODE_ERASE
        mov ebx,IDC_ERASERCURSOR
    .ELSEIF eax == IDM_MODE_TEXT
        mov ebx,IDC_TEXTCURSOR
    .ELSE
        mov ebx,IDC_PAINTCURSOR
    .ENDIF
    invoke LoadCursor,hInstance,ebx
    invoke SetCursor,eax
    ret
IHandleCursor ENDP

;�����ͼ�¼�
IHandlePaint PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM,ps:PAINTSTRUCT		
	extern CurrentMode:DWORD
	INVOKE BeginPaint, hWnd, ADDR ps
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW
		INVOKE IPaint, ps.hdc
	.ELSEIF ecx == IDM_MODE_ERASE
		INVOKE IErase, ps.hdc
	.ELSEIF ecx == IDM_MODE_TEXT
		INVOKE IText, ps.hdc, hWnd
	.ELSEIF ecx == IDM_MODE_LINE
		INVOKE IPaintLine, ps.hdc
	.ELSEIF ecx == IDM_MODE_RECTANGLE_FRAME
		INVOKE IPaintRectangleFrame, ps.hdc
	.ELSEIF ecx == IDM_MODE_TRIANGLE0_FRAME
		INVOKE IPaintTriangle0Frame, ps.hdc
	.ELSEIF ecx == IDM_MODE_TRIANGLE1_FRAME
		INVOKE IPaintTriangle1Frame, ps.hdc
	.ELSEIF ecx == IDM_MODE_POLYGON_FRAME
		INVOKE IPaintPolygonFrame, ps.hdc
	.ELSEIF ecx == IDM_MODE_RECTANGLE
		INVOKE IPaintRectangle, ps.hdc
	.ELSEIF ecx == IDM_MODE_TRIANGLE0
		INVOKE IPaintTriangle0, ps.hdc
	.ELSEIF ecx == IDM_MODE_TRIANGLE1
		INVOKE IPaintTriangle1, ps.hdc
	.ELSEIF ecx == IDM_MODE_ELLIPSE
		INVOKE IPaintEllipse, ps.hdc
	.ELSEIF ecx == IDM_MODE_POLYGON
		INVOKE IPaintPolygon, ps.hdc
	.ENDIF
	INVOKE EndPaint, hWnd, ADDR ps
	ret
IHandlePaint ENDP
end