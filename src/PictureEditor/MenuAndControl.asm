;文件名：MenuAndControl.asm
;描述：菜单和总体控制相关函数，包括菜单初始化，字体，颜色等修改
;功能：只是设置菜单栏显示，并不负责鼠标点击的实现等其他操作
;需要调用Define.inc中对于各类MenuString

.386 
.model flat,stdcall 
option casemap:none

include Define.inc

public EraserRadius

.data
EraserRadius DWORD 10

.code
;创立菜单
ICreateMenu PROC
	extern hMenu: HMENU
	
	LOCAL FileMenu: HMENU
	
	LOCAL DrawMenu: HMENU
	
	LOCAL FrameMenu: HMENU
	LOCAL LineMenu: HMENU
	LOCAL BrushMenu: HMENU

	LOCAL ToolMenu: HMENU
	
	LOCAL ColorMenu: HMENU
	
	LOCAL FontMenu: HMENU
	
	LOCAL SettingsMenu: HMENU

	INVOKE CreateMenu
	.IF eax == 0
		ret
	.ENDIF
	mov hMenu, eax
	
	INVOKE CreatePopupMenu
	mov FileMenu, eax
	
	INVOKE CreatePopupMenu
	mov DrawMenu, eax
	
	INVOKE CreatePopupMenu
	mov FrameMenu, eax
	INVOKE CreatePopupMenu
	mov LineMenu, eax
	INVOKE CreatePopupMenu
	mov BrushMenu, eax
	INVOKE CreatePopupMenu
	mov ToolMenu, eax
	
	INVOKE CreatePopupMenu
	mov ColorMenu, eax
	
	INVOKE CreatePopupMenu
	mov FontMenu, eax
	
	INVOKE CreatePopupMenu
	mov SettingsMenu, eax

	;AppendMenu是追加新菜单项的函数
	;FileMenu 文件创建等选项
	INVOKE AppendMenu, hMenu, MF_POPUP, FileMenu, ADDR FileMenuString
	INVOKE AppendMenu, FileMenu, MF_STRING, IDM_LOAD, ADDR LoadMenuString
	INVOKE AppendMenu, FileMenu, MF_STRING, IDM_SAVE, ADDR SaveMenuString
	
	INVOKE AppendMenu, hMenu, MF_POPUP, DrawMenu, ADDR DrawMenuString
	INVOKE AppendMenu, DrawMenu, MF_STRING, IDM_DRAW, ADDR PaintMenuString
	INVOKE AppendMenu, DrawMenu, MF_STRING, IDM_ERASE, ADDR EraseMenuString
	INVOKE AppendMenu, DrawMenu, MF_STRING, IDM_TEXT, ADDR TextMenuString
	
	INVOKE AppendMenu, hMenu, MF_POPUP, FrameMenu, ADDR FrameMenuString
	INVOKE AppendMenu, FrameMenu, MF_POPUP, LineMenu, ADDR LineMenuString
	
	INVOKE AppendMenu, LineMenu, MF_STRING, IDM_SOLID_LINE, ADDR SolidLineMenuString
	INVOKE AppendMenu, LineMenu, MF_STRING, IDM_DASH_LINE, ADDR  DashLineMenuString
	INVOKE AppendMenu, LineMenu, MF_STRING, IDM_DOT_LINE, ADDR  DotLineMenuString
	INVOKE AppendMenu, LineMenu, MF_STRING, IDM_DASHDOT_LINE, ADDR  DashDotLineMenuString
	INVOKE AppendMenu, LineMenu, MF_STRING, IDM_DASHDOT2_LINE, ADDR  DashDot2LineMenuString
	INVOKE AppendMenu, LineMenu, MF_STRING, IDM_INSIDEFRAME_LINE, ADDR  InsideFrameLineMenuString

	INVOKE AppendMenu, FrameMenu, MF_STRING, IDM_RECTANGLE_FRAME, ADDR RectangleFrameMenuString
	INVOKE AppendMenu, FrameMenu, MF_STRING, IDM_TRIANGLE0_FRAME, ADDR Triangle0FrameMenuString
	INVOKE AppendMenu, FrameMenu, MF_STRING, IDM_TRIANGLE1_FRAME, ADDR Triangle1FrameMenuString
	INVOKE AppendMenu, FrameMenu, MF_STRING, IDM_POLYGON_FRAME, ADDR PolygonFrameMenuString
	
	
	INVOKE AppendMenu, hMenu, MF_POPUP, ToolMenu, ADDR ToolMenuString
	INVOKE AppendMenu, ToolMenu, MF_STRING, IDM_RECTANGLE, ADDR RectangleMenuString
	INVOKE AppendMenu, ToolMenu, MF_STRING, IDM_TRIANGLE0, ADDR Triangle0MenuString
	INVOKE AppendMenu, ToolMenu, MF_STRING, IDM_TRIANGLE1, ADDR Triangle1MenuString
	INVOKE AppendMenu, ToolMenu, MF_STRING, IDM_ELLIPSE, ADDR EllipseMenuString
	INVOKE AppendMenu, ToolMenu, MF_STRING, IDM_POLYGON, ADDR PolygonMenuString
	INVOKE AppendMenu, ToolMenu, MF_POPUP, BrushMenu, ADDR BrushMenuString

	INVOKE AppendMenu, BrushMenu, MF_STRING,IDM_SOLID_BRUSH, ADDR SolidBrushMenuString
	INVOKE AppendMenu, BrushMenu, MF_STRING,IDM_BDIAG_BRUSH, ADDR BDiagonalBrushMenuString
	INVOKE AppendMenu, BrushMenu, MF_STRING,IDM_FDIAG_BRUSH, ADDR FDiagonalBrushMenuString
	INVOKE AppendMenu, BrushMenu, MF_STRING,IDM_DCROSS_BRUSH, ADDR DiagCrossBrushMenuString
	INVOKE AppendMenu, BrushMenu, MF_STRING,IDM_CROSS_BRUSH, ADDR CrossBrushMenuString
	INVOKE AppendMenu, BrushMenu, MF_STRING,IDM_HORIZ_BRUSH, ADDR HorizontalBrushMenuString
	INVOKE AppendMenu, BrushMenu, MF_STRING,IDM_VERTI_BRUSH, ADDR VerticalBrushMenuString
	
	INVOKE AppendMenu, hMenu, MF_POPUP, ColorMenu, ADDR ColorMenuString
	INVOKE AppendMenu, ColorMenu, MF_STRING, IDM_BRUSH_COLOR, ADDR ColorBrushMenuString
	INVOKE AppendMenu, ColorMenu, MF_STRING, IDM_PEN_COLOR, ADDR ColorPenMenuString
	
	INVOKE AppendMenu, hMenu, MF_POPUP, FontMenu, ADDR FontMenuString
	INVOKE AppendMenu, FontMenu, MF_STRING, IDM_FONT, ADDR FontChooseMenuString

	INVOKE AppendMenu, hMenu, MF_POPUP, SettingsMenu, ADDR SettingsMenuString
	ret  
ICreateMenu ENDP
end
