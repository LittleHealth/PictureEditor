;文件名：WindowsManager.asm
;描述：Win32相关函数定义，包括鼠标，光标，对话框，绘图事件的处理

.386 
.model flat,stdcall 
option casemap:none

include Define.inc

.code
;处理WM_COMMAND(菜单点击)导致的模式变化
IHandleModeChange PROC USES ebx ecx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	push ebx
	push ecx
	extern CurrentMode:DWORD
	extern CurrentPointNum:DWORD
	mov ebx, wParam
	mov CurrentPointNum, 0
	mov ecx, CurrentMode
	.IF bx == IDM_DRAW  ; 画图
		mov ecx, IDM_MODE_DRAW
	.ELSEIF bx == IDM_ERASE ; 擦除
		mov ecx, IDM_MODE_ERASE
	.ELSEIF bx == IDM_TEXT ;文字
		mov ecx, IDM_MODE_TEXT
	.ELSEIF bx == IDM_LINE ;画线
		mov ecx, IDM_MODE_LINE
	.ELSEIF bx == IDM_TRIANGLE0_FRAME ;上三角形边框
		mov ecx, IDM_MODE_TRIANGLE0_FRAME
	.ELSEIF bx == IDM_TRIANGLE1_FRAME ;下三角形边框
		mov ecx, IDM_MODE_TRIANGLE1_FRAME
	.ELSEIF bx == IDM_RECTANGLE_FRAME ;矩形边框
		mov ecx, IDM_MODE_RECTANGLE_FRAME
	.ELSEIF bx == IDM_POLYGON_FRAME ;多边形边框
		mov ecx, IDM_MODE_POLYGON_FRAME
	.ELSEIF bx == IDM_TRIANGLE0 ;上三角形
		mov ecx, IDM_MODE_TRIANGLE0
	.ELSEIF bx == IDM_TRIANGLE1 ;下三角形
		mov ecx, IDM_MODE_TRIANGLE1
	.ELSEIF bx == IDM_RECTANGLE ;矩形
		mov ecx, IDM_MODE_RECTANGLE
	.ELSEIF bx == IDM_ELLIPSE ;椭圆
		mov ecx, IDM_MODE_ELLIPSE
	.ELSEIF bx == IDM_POLYGON ;多边形
		mov ecx, IDM_MODE_POLYGON
	.ELSEIF bx == IDM_BACKGROUND_COLOR
		mov ecx, IDM_MODE_BACKGROUBD_COLOR
		INVOKE IHandleColor, hWnd, 0
	.ELSEIF bx == IDM_FRAME_COLOR
		mov ecx, IDM_MODE_FRAME_COLOR
		INVOKE IHandleColor, hWnd, 1
	.ENDIF
	mov CurrentMode, ecx
	pop ecx
	pop ebx
	ret
IHandleModeChange ENDP 

;处理鼠标移动事件(擦除和写入)
IHandleMouseMove PROC USES ebx ecx edx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	push ebx
	push ecx
	push edx
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
	;获取当前位置
	mov ebx, lParam
	INVOKE IGetCurrentPoint, ebx
	mov edx, CurrentX
	mov ebx, CurrentY
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW    ;画线
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
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ELSEIF ecx == IDM_MODE_ERASE ;擦除
		.IF MouseStatus == 1
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ENDIF
	pop edx
	pop ecx
	pop ebx
	ret
IHandleMouseMove ENDP

;处理鼠标按下事件(擦除和写入)
IHandleButtonDown PROC USES ecx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	push ecx
	extern CurrentMode: DWORD
	extern MouseStatus:DWORD
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW || ecx == IDM_MODE_ERASE
		;画笔或者橡皮
		mov MouseStatus, 1
	.ENDIF
	pop ecx
	ret
IHandleButtonDown ENDP 

;处理鼠标收起来事件(擦除，写入，工具)
IHandleButtonUp PROC USES ebx ecx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	push ebx
	push ecx
	extern CurrentMode: DWORD
	extern MouseStatus: DWORD
	extern StartX: DWORD
	extern StartY: DWORD
	extern EndX: DWORD
	extern EndY: DWORD
	extern CurrentPointNum: DWORD
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW || ecx == IDM_MODE_ERASE
		;画笔或者橡皮
		mov MouseStatus, 0
		mov StartX, 0
		mov StartY, 0
		mov EndX, 0
		mov EndY, 0
	.ELSEIF ecx == IDM_MODE_TEXT
		;文字
		mov ebx, lParam
		INVOKE IGetCurrentPoint, ebx
		INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
	.ELSEIF ecx == IDM_MODE_POLYGON || ecx == IDM_MODE_POLYGON_FRAME
		;多边形或者边框
		mov ebx, lParam
		INVOKE IGetCurrentPoint, ebx
		INVOKE IJudgePolygonEnd
		.IF WhetherDrawPolygon == 0
			INVOKE IAddGraphPoint
		.ENDIF
		.IF CurrentPointNum >= 2
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
;这里添加不同的Mode的判断，从而调用Painter.asm中的函数
	
	.ELSE
		;画线，矩形，椭圆，三角形等多种情况
		mov ebx, lParam
		INVOKE IGetCurrentPoint, ebx
		INVOKE IAddGraphPoint
		.IF CurrentPointNum == 2
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ENDIF
	pop ecx
	pop ebx
	ret
IHandleButtonUp ENDP

;处理光标事件
IHandleCursor PROC USES eax ebx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	extern hInstance:HINSTANCE
	push eax
	push ebx
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
	pop ebx
	pop eax
    ret
IHandleCursor ENDP

;处理绘图事件
IHandlePaint PROC USES ecx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM,ps:PAINTSTRUCT		
	push ecx
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
	pop ecx
	ret
IHandlePaint ENDP

IHandleColor PROC hWnd:HWND, Command:DWORD
	local cc:CHOOSECOLOR
	extern hInstance:HINSTANCE

    mov cc.lStructSize,sizeof cc
    mov eax,hWnd
    mov cc.hwndOwner,eax
    mov eax,hInstance
    mov cc.hInstance,eax
    mov cc.rgbResult,0
    mov eax,offset ArrayCustom_Color
    mov cc.lpCustColors,eax
    mov cc.Flags,CC_FULLOPEN or CC_RGBINIT
    mov cc.lCustData,0
    mov cc.lpfnHook,0
    mov cc.lpTemplateName,0
    INVOKE ChooseColor,addr cc
    mov eax,cc.rgbResult
	mov ecx, Command
    .IF ecx == Command
        mov Background_Color, eax
    .ELSEIF ecx == Command
        mov Frame_Color, eax
    .ENDIF
    ret
IHandleColor ENDP

end