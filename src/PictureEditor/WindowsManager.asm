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
	.ELSEIF bx == IDM_SOLID_LINE || bx == IDM_DASH_LINE || bx == IDM_DOT_LINE || bx == IDM_DASHDOT_LINE || bx == IDM_DASHDOT2_LINE || bx == IDM_INSIDEFRAME_LINE;画线
		.IF bx == IDM_SOLID_LINE
			mov ecx, IDM_MODE_LINE
			push PS_SOLID
		.ELSEIF bx == IDM_DASH_LINE ;画线
			mov ecx, IDM_MODE_LINE
			push PS_DASH
		.ELSEIF bx == IDM_DOT_LINE ;画线
			mov ecx, IDM_MODE_LINE
			push PS_DOT
		.ELSEIF bx == IDM_DASHDOT_LINE ;画线
			mov ecx, IDM_MODE_LINE
			push PS_DASHDOT
		.ELSEIF bx == IDM_DASHDOT2_LINE ;画线
			mov ecx, IDM_MODE_LINE
			push PS_DASHDOTDOT
		.ELSEIF bx == IDM_INSIDEFRAME_LINE ;画线
			mov ecx, IDM_MODE_LINE
			push PS_INSIDEFRAME
		.ENDIF
		pop PenStyle
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
	.ELSEIF bx == IDM_BRUSH_COLOR
		INVOKE IHandleColor, hWnd, 0
	.ELSEIF bx == IDM_PEN_COLOR
		INVOKE IHandleColor, hWnd, 1
	.ELSEIF bx == IDM_FONT
		INVOKE IHandleFont, hWnd
	.ELSEIF bx == IDM_SOLID_BRUSH
		push SOLID_BRUSH
		pop BrushMode
	.ELSEIF bx == IDM_BDIAG_BRUSH || bx == IDM_FDIAG_BRUSH || bx == IDM_DCROSS_BRUSH || bx == IDM_CROSS_BRUSH || bx == IDM_HORIZ_BRUSH || bx == IDM_VERTI_BRUSH
		push HATCH_BRUSH
		pop BrushMode
		.IF bx == IDM_BDIAG_BRUSH
			push HS_BDIAGONAL
		.ELSEIF bx == IDM_FDIAG_BRUSH
			push HS_FDIAGONAL
		.ELSEIF bx == IDM_DCROSS_BRUSH
			push HS_DIAGCROSS
		.ELSEIF bx == IDM_CROSS_BRUSH
			push HS_CROSS
		.ELSEIF bx == IDM_HORIZ_BRUSH
			push HS_HORIZONTAL
		.ELSEIF bx == IDM_VERTI_BRUSH
			push HS_VERTICAL
		.ENDIF
		pop HatchStyle
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
	.IF MouseStatus == 1
		.IF ecx == IDM_MODE_DRAW    ;画线
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
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion,0
		.ELSEIF ecx == IDM_MODE_ERASE ;擦除
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
    local hdc:HDC
    local tempDC:HDC
    local tempBitmap:HBITMAP
	extern hInstance:HINSTANCE
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
	local hPen: HPEN
	local hBrush: HBRUSH
	extern CurrentMode:DWORD
	push ecx
	INVOKE BeginPaint, hWnd, ADDR ps
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW || ecx==IDM_MODE_LINE || ecx==IDM_MODE_RECTANGLE_FRAME || ecx==IDM_MODE_POLYGON_FRAME || ecx==IDM_MODE_TRIANGLE0_FRAME || ecx==IDM_MODE_TRIANGLE1_FRAME
		push ecx
		INVOKE CreatePen, PenStyle, PenWidth, PenColor
		mov hPen, eax
		INVOKE SelectObject, ps.hdc, hPen
		pop ecx
		.IF ecx == IDM_MODE_DRAW
			INVOKE IPaint, ps.hdc
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
		.ENDIF
		INVOKE DeleteObject, hPen
	.ELSEIF ecx == IDM_MODE_RECTANGLE || ecx==IDM_MODE_POLYGON || ecx==IDM_MODE_TRIANGLE0 || ecx==IDM_MODE_TRIANGLE1 || ecx==IDM_MODE_ELLIPSE
		push ecx
		mov ecx, BrushMode
		.IF ecx == SOLID_BRUSH
			INVOKE CreateSolidBrush, BrushColor
		;.ELSE
		.ELSEIF ecx == HATCH_BRUSH
			INVOKE CreateHatchBrush, HatchStyle, BrushColor
		.ENDIF
		mov hBrush, eax
		INVOKE SelectObject, ps.hdc, hBrush
		INVOKE CreatePen, PenStyle, PenWidth, PenColor
		mov hPen, eax
		INVOKE SelectObject, ps.hdc, hPen
		pop ecx
		.IF ecx == IDM_MODE_RECTANGLE
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
		INVOKE DeleteObject, hBrush
		INVOKE DeleteObject, hPen
	.ELSEIF ecx == IDM_MODE_ERASE
		INVOKE IErase, ps.hdc
	.ELSEIF ecx == IDM_MODE_TEXT
		push ecx		
		INVOKE SelectObject,ps.hdc, CurrentFont
		pop ecx
		INVOKE IText, ps.hdc, hWnd
	.ENDIF
	INVOKE EndPaint, hWnd, ADDR ps
	pop ecx
	ret
IHandlePaint ENDP

IHandleColor PROC hWnd:HWND, Command:DWORD
	local cc:CHOOSECOLOR
	extern hInstance:HINSTANCE
	push eax
	push ecx
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
    .IF Command == 0
        mov BrushColor, eax
    .ELSEIF Command == 1
        mov PenColor, eax
    .ENDIF
	pop ecx
	pop eax
    ret
IHandleColor ENDP


IHandleFont PROC hWnd:HWND
    local cc:CHOOSEFONT
    extern hInstance:HINSTANCE

    mov cc.lStructSize,sizeof cc
    mov eax,hWnd
    mov cc.hwndOwner,eax
    mov cc.hDC, 0
    push offset LogicFont
    pop cc.lpLogFont
    mov cc.Flags, 0
    mov cc.rgbColors, 0
    mov cc.lCustData, 0
    mov cc.lpfnHook, 0
    mov cc.lpTemplateName, 0
    mov eax,hInstance
    mov cc.hInstance,eax
    mov cc.lpszStyle, 0
    mov cc.nFontType, 0
    mov cc.nSizeMin, 0
    mov cc.nSizeMax, 0
    
    invoke ChooseFont,addr cc
    invoke CreateFontIndirect, offset LogicFont
    mov CurrentFont, eax
    ret
IHandleFont endp

end