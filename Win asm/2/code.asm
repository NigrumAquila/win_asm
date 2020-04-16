.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc

includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib

.data
ClassName       db "SimpleWinClass",0
AppName         db "Processes",0
MenuName        db "Menu",0
ButtonClassName db "button",0
ButtonText      db "Run process",0
ButtonText1     db "Kill process",0
EditClassName   db "Edit",0
s_i             STARTUPINFO <>
p_i             PROCESS_INFORMATION <>
buffer          db 260 dup(0)
buffer1         db " ", 259 dup(0)

.data?
hInstance   HINSTANCE ?
CommandLine LPSTR ?
hwndButton  HWND ?
hwndButton1 HWND ?
hwndEdit    HWND ?
hwndEdit1   HWND ?

.const
ButtonID    equ 1
ButtonID1   equ 11
EditID      equ 2
EditID1     equ 12
IDM_RUN     equ 1
IDM_KILL    equ 2
IDM_EXIT    equ 3

.code
start:
  invoke GetModuleHandle, NULL
  mov    hInstance, eax
  invoke GetCommandLine
  invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
  invoke ExitProcess, eax
;_________________________________________________________
WinMain proc hInst:HINSTANCE, hPrevInst: HINSTANCE, CmdLine: LPSTR, CmdShow: DWORD
  LOCAL wc:   WNDCLASSEX
  LOCAL msg:  MSG
  LOCAL hwnd: HWND
  mov   wc.cbSize, SIZEOF WNDCLASSEX
  mov   wc.style, CS_HREDRAW or CS_VREDRAW
  mov   wc.lpfnWndProc, OFFSET WndProc
  mov   wc.cbClsExtra, NULL
  mov   wc.cbWndExtra, NULL
  push  hInst
  pop   wc.hInstance
  mov   wc.hbrBackground, COLOR_BTNFACE+1
  mov   wc.lpszMenuName, OFFSET MenuName
  mov   wc.lpszClassName, OFFSET ClassName
  invoke LoadIcon, NULL, IDI_APPLICATION
  mov   wc.hIcon, eax
  mov   wc.hIconSm, eax
  invoke LoadCursor, NULL,IDC_ARROW
  mov   wc.hCursor, eax
  invoke RegisterClassEx, addr wc
  INVOKE CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ClassName, ADDR AppName,\
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,\
           CW_USEDEFAULT, 500, 350, NULL, NULL,\
           hInst, NULL
  mov   hwnd, eax
  INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
  INVOKE UpdateWindow, hwnd
  .WHILE TRUE
                INVOKE GetMessage, ADDR msg, NULL, 0, 0
                .BREAK .IF (!eax)
                INVOKE TranslateMessage, ADDR msg
                INVOKE DispatchMessage, ADDR msg
  .ENDW
  mov     eax, msg.wParam
  ret
WinMain endp
;_________________________________________________________
WndProc proc hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM
  .IF uMsg == WM_DESTROY
    invoke PostQuitMessage, NULL
  .ELSEIF uMsg == WM_CREATE
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR EditClassName, NULL,\
            WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
            ES_AUTOHSCROLL,\
            50, 35, 200, 25, hWnd, EditID, hInstance, NULL
    mov  hwndEdit, eax
    invoke SetFocus, hwndEdit
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR EditClassName, NULL,\
              WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
              ES_AUTOHSCROLL,\
              50, 65, 200, 25, hWnd, EditID1, hInstance, NULL
    mov  hwndEdit1, eax
    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText,\
              WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
              75, 110, 140, 25, hWnd, ButtonID, hInstance, NULL
    mov  hwndButton, eax
    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText1,\
              WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
              75, 140, 140, 25, hWnd, ButtonID1, hInstance, NULL
      mov  hwndButton1, eax
  .ELSEIF uMsg == WM_COMMAND
    mov eax, wParam
    .IF lParam == 0
      .IF ax == IDM_RUN
        invoke GetWindowText, hwndEdit, ADDR buffer, 512
        invoke GetWindowText, hwndEdit1, ADDR buffer1 +1, 512
        invoke GetStartupInfo, ADDR s_i
        invoke CreateProcess, addr buffer, addr buffer1,\
                    NULL, NULL, FALSE, 0,\
                    NULL, NULL, addr s_i, addr p_i
        invoke SetParent, p_i.hProcess, hWnd
        .if eax == 0
          invoke MessageBox, NULL, ADDR buffer, ADDR AppName, MB_OK
        .endif
      .ELSEIF ax == IDM_KILL
        invoke TerminateProcess, p_i.hProcess, NULL
        invoke CloseHandle, p_i.hThread 
        invoke CloseHandle, p_i.hProcess
      .ELSE
        invoke DestroyWindow, hWnd
      .ENDIF
    .ELSE
      .IF ax == ButtonID
        shr eax, 16
        .IF ax == BN_CLICKED
          invoke SendMessage, hWnd, WM_COMMAND, IDM_RUN, 0
        .ENDIF
      .ELSEIF ax == ButtonID1
        shr eax, 16
        .IF ax == BN_CLICKED
          invoke SendMessage, hWnd, WM_COMMAND, IDM_KILL, 0
        .ENDIF      
      .ENDIF
    .ENDIF
  .ELSE
    invoke DefWindowProc, hWnd, uMsg, wParam, lParam
    ret
  .ENDIF
  xor    eax, eax
  ret
WndProc endp
end start
