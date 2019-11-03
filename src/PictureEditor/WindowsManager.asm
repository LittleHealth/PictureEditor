;�ļ�����WindowsManager.asm
;������Win32��غ������壬������꣬��꣬�Ի��򣬻�ͼ�¼��Ĵ���

.386 
.model flat,stdcall 
option casemap:none

include Define.inc

public PenWidth

.data
PenWidth DWORD 1		   ;If PenStyle != PS_SOLID, PenWidth <= 1

.code
;����WM_COMMAND(�˵����)���µ�ģʽ�仯
IHandleModeChange PROC USES ebx ecx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	LOCAL hdc: HDC
	LOCAL hdcBM: HDC
	LOCAL hbm: HBITMAP
	LOCAL bm: BITMAP
	LOCAL bmInfo: BITMAPINFOHEADER;λͼ�ļ���Ϣͷ
	LOCAL bmFile: BITMAPFILEHEADER;λͼ�ļ�ͷ
	LOCAL numColor: DWORD;��ɫ����ɫ����
	LOCAL rgbSize:DWORD;��ɫ���С
	LOCAL bitmapSize:DWORD;λͼ��С
	LOCAL hg:HGLOBAL;����ռ���
	LOCAL spacePtr:DWORD;����ռ���׵�ַָ��
	LOCAL numByte:DWORD;д���ֽ���
	LOCAL fileHandle:DWORD;�ļ����
	push ebx
	push ecx
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
	.ELSEIF bx == IDM_SOLID_LINE || bx == IDM_DASH_LINE || bx == IDM_DOT_LINE || bx == IDM_DASHDOT_LINE || bx == IDM_DASHDOT2_LINE || bx == IDM_INSIDEFRAME_LINE;����
		.IF bx == IDM_SOLID_LINE
			mov ecx, IDM_MODE_LINE
			push PS_SOLID
		.ELSEIF bx == IDM_DASH_LINE ;����
			mov ecx, IDM_MODE_LINE
			push PS_DASH
		.ELSEIF bx == IDM_DOT_LINE ;����
			mov ecx, IDM_MODE_LINE
			push PS_DOT
		.ELSEIF bx == IDM_DASHDOT_LINE ;����
			mov ecx, IDM_MODE_LINE
			push PS_DASHDOT
		.ELSEIF bx == IDM_DASHDOT2_LINE ;����
			mov ecx, IDM_MODE_LINE
			push PS_DASHDOTDOT
		.ELSEIF bx == IDM_INSIDEFRAME_LINE ;����
			mov ecx, IDM_MODE_LINE
			push PS_INSIDEFRAME
		.ENDIF
		pop PenStyle
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
	.ELSEIF bx == IDM_LINE_SIZE
		INVOKE IHandlePainterSize, hWnd
	.ELSEIF bx == IDM_ERASER_SIZE
		INVOKE IHandleEraserSize, hWnd

	.ELSEIF bx == IDM_LOAD
		push edx
		mov rsFile.hwndOwner, NULL
		mov rsFile.nFilterIndex, 1
		mov rsFile.lpstrFileTitle, NULL
		mov rsFile.nMaxFileTitle, 0
		mov rsFile.lpstrInitialDir, NULL ;
		mov rsFile.Flags,  OFN_PATHMUSTEXIST AND OFN_FILEMUSTEXIST

		mov edx, sizeof rsFile
		mov rsFile.lStructSize, edx
		mov rsFile.lpstrFile, OFFSET rsFileName;			
		mov edx, sizeof rsFileName
		mov rsFile.nMaxFile, edx
		mov rsFile.lpstrFilter, OFFSET fileType2
		pop edx
		INVOKE GetOpenFileName, ADDR rsFile
		INVOKE GetDC, hWnd
		mov hdc, eax
		invoke CreateCompatibleDC, hdc
		mov hdcBM, eax
		invoke LoadImage, NULL, ADDR rsFileName, IMAGE_BITMAP, ScreenWidth, ScreenLength, LR_LOADFROMFILE
		mov hbm, eax
		invoke SelectObject, hdcBM, eax
		invoke BitBlt, hdc, 0, 0,  ScreenWidth, ScreenLength, hdcBM, 0, 0, SRCCOPY
		invoke DeleteObject, hbm
		invoke DeleteDC, hdcBM

	.ELSEIF bx == IDM_SAVE
		pushad
		mov edx, sizeof rsFile
		mov rsFile.lStructSize, edx ;�ļ���С
		mov rsFile.lpstrFile, OFFSET rsFileName ;�ļ���,������������·��
		mov rsFile.lpstrFileTitle, OFFSET rsTitleName ;�������ļ�������չ��
		mov edx, sizeof rsFileName
		mov rsFile.nMaxFile, edx;�ļ�����󳤶�
		mov rsFile.lpstrFilter, OFFSET fileType ;����������չ����
		mov rsFile.lpstrDefExt, OFFSET extenName ;Ĭ����չ��
		mov rsFile.Flags, OFN_OVERWRITEPROMPT
		popad
		
		pushad
		INVOKE GetSaveFileName, ADDR rsFile;��ȡ�ļ�·������Ϣ���ļ����Բ�����
		INVOKE GetDC, hWnd ;��ȡ��ǰ���ھ��
		mov hdc, eax

		INVOKE CreateCompatibleBitmap, hdc, ScreenWidth, ScreenLength;����λͼ
		mov hbm, eax
		INVOKE CreateCompatibleDC, hdc;���������Ļ���
		mov hdcBM, eax

		INVOKE SelectObject, hdcBM, hbm ;��λͼ�Ƶ��������Ļ�����
		INVOKE BitBlt, hdcBM, 0, 0, ScreenWidth, ScreenLength, hdc, 0, 0, SRCCOPY;��ԭ���ڻ����е����ؿ����忽�����½����Ļ�����
	
		INVOKE GetObject, hbm, (sizeof BITMAP), ADDR bm ;��ȡλͼ��Ϣ

		
		popad

		;λͼ��Ϣͷ�ĳ�ʼ��
		pushad
		mov bmInfo.biSize, (sizeof bmInfo);�ṹ��С
		mov edx, bm.bmWidth
		mov bmInfo.biWidth, edx;λͼ�ļ��Ŀ��
		mov edx, bm.bmHeight
		mov bmInfo.biHeight, edx;λͼ�ļ��ĸ߶�
		mov bmInfo.biPlanes, 1;λͼ��������Ϊ1
		mov dx, bm.bmBitsPixel
		mov bmInfo.biBitCount, dx;λͼɫ��
		mov bmInfo.biCompression, BI_RGB;ѹ����ʽ
		mov bmInfo.biSizeImage, 0;λͼ��С
		mov bmInfo.biXPelsPerMeter, 0;ˮƽ�ֱ���
		mov bmInfo.biYPelsPerMeter, 0;��ֱ�ֱ���
		mov bmInfo.biClrUsed, 0 ;ʹ��������ɫ
		mov bmInfo.biClrImportant, 0 ;������ɫ��Ҫ
		popad

		;λͼ�ļ���λͼ�ļ�ͷ��λͼ��Ϣͷ����ɫ���λͼ�������

		;����λͼ���ݴ�С
		pushad
		mov eax, bm.bmWidth
		mov edx, 0
		mov dx, bmInfo.biBitCount
		imul eax, edx
		;��֤�����ֽڵ�������
		mov ebx, 32
		mov edx, 0
		add eax, 31
		idiv ebx
		imul eax, bm.bmHeight
		imul eax, 4
		mov bitmapSize, eax
		popad

		;�����ɫ���С
		;ɫ��С�ڵ���8λ����ɫ����ɫ����2��ɫ��η�������8λ�޵�ɫ��
		pushad
		.IF bm.bmBitsPixel > 8
			push edx
			mov edx, 0
			mov numColor, edx
			pop edx
		.ELSE
			pushad
			mov edx, 1
			mov ecx, 0
			mov cx, bm.bmBitsPixel
			shl edx, cl
			mov numColor, edx
			popad
		.ENDIF
		mov edx, numColor
		imul edx, sizeof RGBQUAD
		mov rgbSize, edx
		popad

		;�洢�ռ����������ת��
		pushad

		mov edx, bitmapSize
		add edx, sizeof bmInfo
		add edx, rgbSize
		;����edx��С�Ķ�̬�ռ�
		INVOKE GlobalAlloc, GHND, edx
		mov hg, eax
		;������̬�ռ䣬�����׵�ַ
		INVOKE GlobalLock, hg
		mov spacePtr, eax

		mov eax, sizeof bmInfo
		lea ebx, bmInfo
		mov edx, spacePtr

	copydata:
		mov eax, [ebx]
		mov [edx], eax
		add ebx, TYPE DWORD
		add edx, TYPE DWORD
		sub eax, TYPE DWORD
		cmp eax, 0
		jne copydata

		popad
	
		pushad
		mov edx, spacePtr
		add edx, sizeof bmInfo
		add edx, rgbSize
		INVOKE GetDIBits, hdc, hbm, 0, bmInfo.biHeight, edx, spacePtr, DIB_RGB_COLORS
		popad

		;����λͼ�ļ�ͷ����Ϣ
		pushad
		mov bmFile.bfType, 4D42h
		mov edx, sizeof bmFile
		add edx, sizeof bmInfo
		add edx, rgbSize
		mov bmFile.bfOffBits, edx
		add edx, bitmapSize
		mov bmFile.bfSize, edx
		mov bmFile.bfReserved1, 0
		mov bmFile.bfReserved2, 0

		;���������ļ�
		INVOKE CreateFile,
			ADDR rsFileName,
			GENERIC_WRITE,
			0,
			NULL,
			CREATE_ALWAYS,
			FILE_ATTRIBUTE_NORMAL,
			NULL
		mov fileHandle, eax
		popad


		pushad
		
		;������д���ļ�
		INVOKE WriteFile, fileHandle, ADDR bmFile, sizeof bmFile, ADDR numByte, NULL
		popad
		pushad
		mov edx, bmFile.bfSize
		sub edx, sizeof bmFile
		INVOKE WriteFile, fileHandle, spacePtr, edx, ADDR numByte, NULL
		popad
		pushad
		INVOKE GlobalFree, hg
		INVOKE CloseHandle, fileHandle
		popad
	.ENDIF
	mov CurrentMode, ecx
	pop ecx
	pop ebx
	ret
IHandleModeChange ENDP 

;��������ƶ��¼�(������д��)
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
	;��ȡ��ǰλ��
	mov ebx, lParam
	INVOKE IGetCurrentPoint, ebx
	mov edx, CurrentX
	mov ebx, CurrentY
	mov ecx, CurrentMode
	.IF MouseStatus == 1
		.IF ecx == IDM_MODE_DRAW    ;����
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
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion,0
		.ELSEIF ecx == IDM_MODE_ERASE ;����
			INVOKE InvalidateRect, hWnd, ADDR WorkRegion, 0
		.ENDIF
	.ENDIF
	pop edx
	pop ecx
	pop ebx
	ret
IHandleMouseMove ENDP

;������갴���¼�(������д��)
IHandleButtonDown PROC USES ecx,
	hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	push ecx
	extern CurrentMode: DWORD
	extern MouseStatus:DWORD
	mov ecx, CurrentMode
	.IF ecx == IDM_MODE_DRAW || ecx == IDM_MODE_ERASE
		;���ʻ�����Ƥ
		mov MouseStatus, 1
	.ENDIF
	pop ecx
	ret
IHandleButtonDown ENDP 


;��������������¼�(������д�룬����)
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
;������Ӳ�ͬ��Mode���жϣ��Ӷ�����Painter.asm�еĺ���
	
	.ELSE
		;���ߣ����Σ���Բ�������εȶ������
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

;�������¼�
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

;�����ͼ�¼�
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
		;mov edi, PenWidth
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