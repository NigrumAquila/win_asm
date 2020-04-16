.386
.model flat, stdcall
option casemap: none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
include C:\masm32\include\windows.inc

include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\user32.lib

Proc1 Proto :DWORD, :DWORD

.data
LibName          db "FirstDLL.dll", 0
FunctionName     db "SomeProc1",0
DllNotFound      db "Cannot load library", 0
AppName          db "DLL", 0
ClassName       db "SimpleWinClass",0
FunctionNotFound db "Procefure not found", 0
MenuName        db "Menu",0
ButtonClassName db "button",0
ButtonText      db "Lib procedure",0
EditClassName   db "edit",0

.data?
hLib             dd ?
TestAddr         dd ?
hInstance   HINSTANCE ?
CommandLine LPSTR ?
hwndButton  HWND ?
hwndEdit    HWND ?
buffer db 512 dup(?)

.const
ButtonID    equ 1

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
           CW_USEDEFAULT, 300, 200, NULL, NULL,\
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

WndProc proc hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM
  .IF uMsg == WM_DESTROY
    invoke PostQuitMessage, NULL
  .ELSEIF uMsg == WM_CREATE
    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText,\
            WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
            75, 70, 140, 25, hWnd, ButtonID, hInstance, NULL
    mov  hwndButton, eax
  .ELSEIF uMsg == WM_COMMAND
    mov eax, wParam
    .IF lParam == 0
        invoke DestroyWindow, hWnd
    .ELSE
      .IF ax == ButtonID
        shr eax, 16
        .IF ax == BN_CLICKED
            invoke LoadLibrary, addr LibName
  			.if eax==NULL
    			invoke MessageBox, NULL, addr DllNotFound, addr AppName, MB_OK
  			.else
    			mov hLib,eax
    			invoke GetProcAddress, hLib, addr FunctionName
    			.if eax == NULL
      			invoke MessageBox, NULL, addr FunctionNotFound, addr AppName, MB_OK
    			.else
      				mov TestAddr, eax
      				push DWORD PTR 1000   
      				push DWORD PTR 100    
      				call [TestAddr]
    			.endif
  			invoke FreeLibrary, hLib
  			.endif
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



  invoke ExitProcess, NULL
end start