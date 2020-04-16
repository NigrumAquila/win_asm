.386
.model flat,stdcall
option casemap:none
WinMain   proto :DWORD, :DWORD, :DWORD, :DWORD
EditProc1 proto :DWORD, :DWORD, :DWORD, :DWORD
EditProc2 proto :DWORD, :DWORD, :DWORD, :DWORD
EditProc3 proto :DWORD, :DWORD, :DWORD, :DWORD

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\masm32.inc

includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\masm32.lib

.data
ClassName       db "SimpleWinClass", 0
AppName         db "Subclasses", 0
MenuName        db "Menu", 0
ButtonClassName db "Button", 0
LabelClass      db "Static", 0
LabelText1      db "Hex", 0
LabelText2      db "Arab", 0
LabelText3      db "Decimal", 0

ButtonText      db "Get dec from hex", 0
EditClass       db "Edit", 0

.data?
hInstance       HINSTANCE ?
CommandLine     LPSTR ?
hwndButton      HWND ?
hwndEdit1       HWND ?
hwndEdit2       HWND ?
hwndEdit3       HWND ?
OldWndProc      DD ?
buffer          db 512 dup(?)
buffer1         db 512 dup(?)

.const
ButtonID        equ 1
EditID1         equ 2
LabelID1        equ 20
IDM_CLEAR       equ 2
IDM_GETTEXT     equ 3
IDM_EXIT        equ 4
IDI_ICON        equ 500

.code
start:
  invoke GetModuleHandle, NULL
  mov    hInstance, eax
  invoke GetCommandLine
  invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
  invoke ExitProcess, eax
;________________________________________________________
WinMain proc hInst: HINSTANCE, hPrevInst: HINSTANCE, CmdLine: LPSTR,CmdShow: DWORD
  LOCAL wc: WNDCLASSEX
  LOCAL msg: MSG
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
  invoke LoadIcon, hInst, IDI_ICON
  mov   wc.hIcon, eax
  mov   wc.hIconSm, eax
  invoke LoadCursor,NULL, IDC_ARROW
  mov   wc.hCursor, eax
  invoke RegisterClassEx, addr wc
  INVOKE CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ClassName, ADDR AppName,\
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,\
           CW_USEDEFAULT, 480, 200, NULL, NULL,\
           hInst, NULL
  mov   hwnd, eax
  INVOKE ShowWindow, hwnd, SW_SHOWNORMAL
  INVOKE UpdateWindow, hwnd
  .WHILE TRUE
                INVOKE GetMessage, ADDR msg, NULL, 0, 0
                .BREAK .IF (!eax)
                INVOKE TranslateMessage, ADDR msg
                INVOKE DispatchMessage, ADDR msg
  .ENDW
  mov     eax,msg.wParam
  ret
WinMain endp
;_____________________________________________________
WndProc proc hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM
  .IF uMsg==WM_DESTROY
    invoke PostQuitMessage, NULL
  .ELSEIF uMsg == WM_CREATE
    invoke CreateWindowEx, NULL, ADDR LabelClass, addr LabelText1,\
                        WS_CHILD or WS_VISIBLE or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        20, 10, 200, 25, hWnd, LabelID1, hInstance, NULL
    invoke CreateWindowEx, NULL, ADDR LabelClass, addr LabelText2,\
                        WS_CHILD or WS_VISIBLE or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        20, 65, 200, 25, hWnd, LabelID1, hInstance, NULL
    invoke CreateWindowEx, NULL, ADDR LabelClass, addr LabelText3,\
                        WS_CHILD or WS_VISIBLE or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        235, 10, 200, 25, hWnd, LabelID1, hInstance, NULL

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR EditClass, NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        20, 35, 200, 25, hWnd, EditID1, hInstance, NULL
    mov  hwndEdit1, eax
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR EditClass, NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        20, 85, 200, 25, hWnd, EditID1, hInstance, NULL
    mov  hwndEdit2, eax
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR EditClass, NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        235, 35, 200, 25, hWnd, EditID1, hInstance, NULL
    mov  hwndEdit3, eax
    invoke SetFocus, hwndEdit1
    invoke SendMessage, hwndEdit1, EM_LIMITTEXT, 8, NULL
    invoke SendMessage, hwndEdit3, EM_LIMITTEXT, 8, NULL


    invoke SetWindowLong, hwndEdit1, GWL_WNDPROC, addr EditProc1
    mov OldWndProc, eax

    invoke SetWindowLong, hwndEdit2, GWL_WNDPROC, addr EditProc2
    mov OldWndProc, eax

    invoke SetWindowLong, hwndEdit3, GWL_WNDPROC, addr EditProc3
    mov OldWndProc, eax

    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        280, 65, 160, 25, hWnd, ButtonID, hInstance, NULL
    mov  hwndButton, eax

  .ELSEIF uMsg == WM_COMMAND
    mov eax, wParam
    .IF lParam == 0
      .IF ax == IDM_CLEAR
        invoke SetWindowText, hwndEdit1, NULL
      .ELSEIF  ax==IDM_GETTEXT
        invoke GetWindowText, hwndEdit1, ADDR buffer, 512
        invoke htodw, addr buffer
        invoke dwtoa, eax, addr buffer1
        invoke SetWindowText, hwndEdit3, ADDR buffer1
        invoke GetWindowText, hwndEdit3, ADDR buffer, 512
        invoke MessageBox, NULL, ADDR buffer, ADDR AppName, MB_OK
      .ELSE
        invoke DestroyWindow, hWnd
      .ENDIF
    .ELSE
      .IF ax==ButtonID
        shr eax,16
        .IF ax==BN_CLICKED
          invoke SendMessage, hWnd, WM_COMMAND,IDM_GETTEXT, 0
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

;_______________________________________________________
EditProc1 proc hEdit: DWORD, uMsg: DWORD, wParam: DWORD, lParam: DWORD
  .if uMsg==WM_CHAR
    mov eax, wParam
    .if (al>="0" && al<="9") || (al>="A" && al<="F") ||\
        (al>="a" && al<="f") || al==VK_BACK
      .if al>="a" && al<="f"
        sub al, 20h
      .endif
      invoke CallWindowProc, OldWndProc, hEdit, uMsg, eax, lParam
      ret
    .endif
  .else 
    invoke CallWindowProc, OldWndProc, hEdit, uMsg, wParam, lParam
    ret
  .endif
  xor eax, eax
  ret
EditProc1 endp
;_______________________________________________________

EditProc2 proc hEdit: DWORD, uMsg: DWORD, wParam: DWORD, lParam: DWORD
  .if uMsg==WM_CHAR
    mov eax, wParam
    .if (al=="I" || al=="V" || al=="X" || al=="L" || al=="M") || (al=="i" || al=="v" || al=="x" || al=="l" || al=="m") || (al==VK_BACK)
      .if al=="i" || al=="v" || al=="x" || al=="l" || al=="m"
        sub al, 20h
      .endif
      invoke CallWindowProc, OldWndProc, hEdit, uMsg, eax, lParam
      ret
    .endif
  .else 
    invoke CallWindowProc, OldWndProc, hEdit, uMsg, wParam, lParam
    ret
  .endif
  xor eax, eax
  ret
EditProc2 endp
;_______________________________________________________

EditProc3 proc hEdit: DWORD, uMsg: DWORD, wParam: DWORD, lParam: DWORD
  .if uMsg==WM_CHAR
    mov eax, wParam
    .if (al>="0" && al<="9") || al==VK_BACK
      invoke CallWindowProc, OldWndProc, hEdit, uMsg, eax, lParam
      ret
    .endif
  .else 
    invoke CallWindowProc, OldWndProc, hEdit, uMsg, wParam, lParam
    ret
  .endif
  xor eax, eax
  ret
EditProc3 endp
;_______________________________________________________

end start
