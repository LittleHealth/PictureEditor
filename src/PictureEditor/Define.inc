;�ļ�����Define.inc
;���������ֺ�����PROTO���壬���ֳ����Ķ���

;���ø���ͷ�ļ�
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

;����ԭ��

;����WndProc����������¼��ĺ�����λ��
IHandleModeChange PROTO :HWND,:WPARAM,:LPARAM ;����WM_COMMAND(�˵����)���µ�ģʽ�仯
IHandleMouseMove PROTO :HWND,:WPARAM,:LPARAM ;��������ƶ��¼�(������д��)
IHandleButtonDown PROTO :HWND,:WPARAM,:LPARAM ;������갴���¼�(������д��)
IHandleButtonUp PROTO :HWND,:WPARAM,:LPARAM	;��������������¼�(������д�룬����)
IHandleCursor PROTO :HWND,:WPARAM,:LPARAM ;��������¼�
IHandlePaint PROTO :HWND,:WPARAM,:LPARAM,:PAINTSTRUCT ;������ͼ�¼�

;���ֻ�ͼ����
IPaint PROTO :HDC
IErase PROTO :HDC
IText PROTO :HDC,:HWND
IPaintLine PROTO :HDC
IPaintRectangleFrame PROTO :HDC
IPaintTriangle0Frame PROTO :HDC
IPaintTriangle1Frame PROTO :HDC
IPaintPolygonFrame PROTO :HDC
IPaintRectangle PROTO :HDC
IPaintTriangle0 PROTO :HDC
IPaintTriangle1 PROTO :HDC
IPaintEllipse PROTO :HDC
IPaintPolygon PROTO :HDC

;��ͼ��������
IGetCurrentPoint PROTO :DWORD ;��õ�ǰ��
;�ж϶�����Ƿ�������--�Ѿ������������ϣ����һ����͵�һ����ӽ��غ�.
;�ӽ���eax = 1 ����eax = 0
IJudgePolygonEnd PROTO 
IAddGraphPoint PROTO ;����ǰ��洢������
IGetPolygonPointList PROTO ;���ݵ��еõ����ƶ���εĴ洢����
IGetTriangle0PointList PROTO ;���ݵ��еõ�����ֱ��������(�Ϸ�)�Ĵ洢����
IGetTriangle1PointList PROTO ;���ݵ��еõ�����ֱ��������(�·�)�Ĵ洢����
IGetRectanglePointList PROTO ;���ݵ��еõ����ƾ��εĴ洢����
IIncreasePolygonLine PROTO :HDC;�ڶ���λ���ʱ����һ����
IIncreasePolygonLastLine PROTO, :HDC;�ڶ���λ���ʱ�������һ���ߣ����ӿ�ʼ�ͽ���
ICallTextDialog PROTO :HWND,:UINT,:WPARAM,:LPARAM ;�����Ի�����������
IHandleTextDialog PROTO :HWND,:WPARAM,:LPARAM ;���Ի����������ִ洢�����ڻ���

;�˵������ƵȺ���
ICreateMenu PROTO ;�����˵�

;������ֳ���
.data

;��Ļ�͹�������Ϣ
ScreenLength WORD 541
ScreenWidth WORD 784
WorkRegion RECT <0, 0, 800, 600>

;�ַ�����
MAX_LENGTH WORD 100

;��Դ�ļ�
IDD_DIALOG1 WORD 104
IDC_EDIT1 WORD 1001
IDC_TEXTCURSOR DWORD 103
IDC_ERASERCURSOR DWORD 101
IDC_PAINTCURSOR DWORD 102

;�Ϸ��˵������ֱ��
IDM_FILE_MENU WORD 301
IDM_DRAW_MENU WORD 302
IDM_GRAPH_TOOL_MENU WORD 303
IDM_GRAPH_FRAME_MENU WORD 304
IDM_SETTINGS_MENU WORD 305

;�˵�������ѡ��ı��
IDM_DRAW WORD 400
IDM_ERASE WORD 401
IDM_TEXT WORD 402
IDM_LINE WORD 403
IDM_TRIANGLE0 WORD 4040
IDM_TRIANGLE1 WORD 4041
IDM_RECTANGLE WORD 405
IDM_ELLIPSE WORD 406
IDM_POLYGON WORD 407
IDM_RECTANGLE_FRAME WORD 408
IDM_TRIANGLE0_FRAME WORD 4090
IDM_TRIANGLE1_FRAME WORD 4091
IDM_POLYGON_FRAME WORD 410
IDM_SAVE WORD 411
IDM_LOAD WORD 412

;��ǰģʽ�ı��
IDM_MODE_DRAW DWORD 500
IDM_MODE_ERASE DWORD 501
IDM_MODE_TEXT DWORD 502
IDM_MODE_LINE DWORD 503
IDM_MODE_TRIANGLE0 DWORD 5040
IDM_MODE_TRIANGLE1 DWORD 5041
IDM_MODE_RECTANGLE DWORD 505
IDM_MODE_ELLIPSE DWORD 506
IDM_MODE_POLYGON DWORD 507
IDM_MODE_RECTANGLE_FRAME DWORD 508
IDM_MODE_TRIANGLE0_FRAME DWORD 5090
IDM_MODE_TRIANGLE1_FRAME DWORD 5091
IDM_MODE_POLYGON_FRAME DWORD 510

; �����Լ��������ַ���
ClassName db "DrawingWinClass", 0
AppName db "��ͼ", 0

; �˵��ַ���
FileMenuString BYTE "�ļ�", 0
LoadMenuString BYTE "��", 0
SaveMenuString BYTE "����", 0

DrawMenuString BYTE "��ͼ", 0
PaintMenuString BYTE "��ͼ", 0
EraseMenuString BYTE "����", 0
TextMenuString BYTE "����", 0

FrameMenuString BYTE "��ܻ��ƹ���", 0
LineMenuString BYTE "ֱ��", 0
RectangleFrameMenuString BYTE "���ο�", 0
Triangle0FrameMenuString BYTE "ֱ�������ο��Ϸ���", 0
Triangle1FrameMenuString BYTE "ֱ�������ο��·���", 0
PolygonFrameMenuString BYTE "����ο�", 0

ToolMenuString BYTE "ͼ�λ��ƹ���", 0
RectangleMenuString BYTE "����", 0
Triangle0MenuString BYTE "ֱ�������Σ��Ϸ���", 0
Triangle1MenuString BYTE "ֱ�������Σ��·���", 0
EllipseMenuString BYTE "��Բ", 0
PolygonMenuString BYTE "�����", 0

SettingsMenuString BYTE "����", 0

