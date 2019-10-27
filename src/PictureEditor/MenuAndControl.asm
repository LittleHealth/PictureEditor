;文件名：MenuAndControl.asm
;描述：菜单和总体控制相关函数，包括菜单初始化，字体，颜色等修改

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
	LOCAL ToolMenu: HMENU
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
	mov ToolMenu, eax
	INVOKE CreatePopupMenu
	mov SettingsMenu, eax

	INVOKE AppendMenu, hMenu, MF_POPUP, FileMenu, ADDR FileMenuString
	INVOKE AppendMenu, FileMenu, MF_STRING, IDM_LOAD, ADDR LoadMenuString
	INVOKE AppendMenu, FileMenu, MF_STRING, IDM_SAVE, ADDR SaveMenuString
	INVOKE AppendMenu, hMenu, MF_POPUP, DrawMenu, ADDR DrawMenuString
	INVOKE AppendMenu, DrawMenu, MF_STRING, IDM_DRAW, ADDR PaintMenuString
	INVOKE AppendMenu, DrawMenu, MF_STRING, IDM_ERASE, ADDR EraseMenuString
	INVOKE AppendMenu, DrawMenu, MF_STRING, IDM_TEXT, ADDR TextMenuString
	INVOKE AppendMenu, hMenu, MF_POPUP, FrameMenu, ADDR FrameMenuString
	INVOKE AppendMenu, FrameMenu, MF_STRING, IDM_LINE, ADDR LineMenuString
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
	INVOKE AppendMenu, hMenu, MF_POPUP, SettingsMenu, ADDR SettingsMenuString
	ret
ICreateMenu ENDP
end