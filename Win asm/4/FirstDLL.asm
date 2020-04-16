.386
.model flat, stdcall
option casemap :none
include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc

includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib

  szText  macro _Name, _Text :VARARG
  local lbl
    jmp lbl
    _Name   db   _Text, 0
  lbl:
  endm

  m2m macro   _M1, _M2
    push  _M2
    pop   _M1
  endm

  return  macro _Arg
    mov eax, _Arg
    ret
  endm
;____________________________________________________________
  SomeProc1 PROTO :DWORD, :DWORD
;____________________________________________________________
.data
.code
LibMain proc hInstDLL: DWORD, reason: DWORD, unused: DWORD
  .if reason == DLL_PROCESS_ATTACH
   mov eax, TRUE
  .elseif reason == DLL_THREAD_ATTACH
  .elseif reason == DLL_THREAD_DETACH
  .elseif reason == DLL_PROCESS_DETACH
  .endif
  ret
LibMain endp
.data
LibTitle db 'Lib "FirstDLL.dll"', 0
LibText  db 'Running "Procedure from FirstDLL.dll"', 0
.code
;________________________________________________
SomeProc1 proc  hWnd: DWORD, nID: DWORD
local rcClient: RECT
  mov eax, hWnd
  mov ebx, nID
    invoke MessageBox, NULL, ADDR LibText, ADDR LibTitle, MB_OK or MB_ICONINFORMATION
;return
ret
SomeProc1 endp

End LibMain