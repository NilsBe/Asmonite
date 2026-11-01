; A window, Windows, Intel 32 bit (.arch i386, .format pe gui).
; Assemble: asmoc window_i386.asm
;
; A main window with a menu bar (File > Exit), an input line, a button "Show" and a
; label. Pressing the button copies the text of the input line to the label. The menu
; entry Exit closes the window and ends the program.
;
; The program in outline:
;   start       registers the window class, builds the menu, creates the window and
;               runs the message loop (GetMessage / TranslateMessage / DispatchMessage)
;   WndProc     the window procedure, stdcall with four arguments (hwnd, message,
;               wParam, lParam at [ebp+8] .. [ebp+20]); it handles
;                 WM_CREATE   (1)      creates the three controls as child windows
;                 WM_COMMAND  (0x111)  the low word of wParam is the ID of the menu entry
;                                      or of the control
;                 WM_DESTROY  (2)      ends the message loop
;               and gives everything else to DefWindowProc
;
; There are no expressions and no structures in the assembler: the window class is
; ten dwords in the data section, the numbers (styles, IDs) are written out.
; A number from 128 to 255 gets "dword" in front: otherwise it would be a signed byte.

.format pe gui
.arch i386
.import kernel32.dll GetModuleHandleA, ExitProcess
.import user32.dll RegisterClassA, CreateWindowExA, DefWindowProcA, GetMessageA, TranslateMessage, DispatchMessageA, PostQuitMessage, LoadCursorA, CreateMenu, CreatePopupMenu, AppendMenuA, GetWindowTextA, SetWindowTextA, DestroyWindow, SetFocus

.code
start:
  push 0
  call [GetModuleHandleA]       ; our own module: the instance handle
  mov [hInstance], eax
  mov [wc_instance], eax        ; into the window class

  push 32512                    ; IDC_ARROW
  push 0
  call [LoadCursorA]
  mov [wc_cursor], eax

  push dword wc
  call [RegisterClassA]

  ; the menu: File > Exit (ID 1)
  call [CreateMenu]             ; the menu bar
  mov esi, eax                  ; esi and edi are kept by the Windows functions
  call [CreatePopupMenu]        ; the File menu
  mov edi, eax
  push dword txt_exit
  push 1                        ; ID of the entry: ID_EXIT
  push 0                        ; MF_STRING
  push edi
  call [AppendMenuA]
  push dword txt_file
  push edi                      ; for MF_POPUP the "ID" is the handle of the menu
  push 16                       ; MF_POPUP
  push esi
  call [AppendMenuA]

  push 0                        ; lpParam
  push dword [hInstance]
  push esi                      ; the menu bar
  push 0                        ; no parent
  push dword 200                ; height
  push dword 400                ; width
  push 100                      ; y
  push 100                      ; x
  push 0x10CF0000               ; WS_OVERLAPPEDWINDOW | WS_VISIBLE
  push dword txt_title
  push dword cls_main
  push 0                        ; no extended style
  call [CreateWindowExA]

next_message:
  push 0
  push 0
  push 0
  push dword msg
  call [GetMessageA]            ; 0 after WM_QUIT
  test eax, eax
  jz done
  push dword msg
  call [TranslateMessage]
  push dword msg
  call [DispatchMessageA]       ; calls WndProc
  jmp next_message

done:
  push 0
  call [ExitProcess]

; LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
WndProc:
  push ebp
  mov ebp, esp
  mov eax, [ebp+12]             ; message
  cmp eax, 1                    ; WM_CREATE
  jz on_create
  cmp eax, 0x111                ; WM_COMMAND
  jz on_command
  cmp eax, 2                    ; WM_DESTROY
  jz on_destroy
default:
  push dword [ebp+20]
  push dword [ebp+16]
  push dword [ebp+12]
  push dword [ebp+8]
  call [DefWindowProcA]
  pop ebp
  ret 16                        ; stdcall: the procedure removes the four arguments

on_create:
  ; the input line (ID 102)
  push 0
  push dword [hInstance]
  push 102
  push dword [ebp+8]            ; parent: this window
  push 24                       ; height
  push dword 240                ; width
  push 10                       ; y
  push 10                       ; x
  push 0x50800000               ; WS_CHILD | WS_VISIBLE | WS_BORDER
  push 0
  push dword cls_edit
  push 0
  call [CreateWindowExA]
  mov [hEdit], eax
  ; the button (ID 101)
  push 0
  push dword [hInstance]
  push 101
  push dword [ebp+8]
  push 24
  push 90
  push 10
  push dword 260
  push 0x50000000               ; WS_CHILD | WS_VISIBLE (BS_PUSHBUTTON is 0)
  push dword txt_show
  push dword cls_button
  push 0
  call [CreateWindowExA]
  ; the label (ID 103), with a sunken border
  push 0
  push dword [hInstance]
  push 103
  push dword [ebp+8]
  push 24
  push dword 370
  push 50
  push 10
  push 0x50001000               ; WS_CHILD | WS_VISIBLE | SS_SUNKEN
  push dword txt_label
  push dword cls_static
  push 0
  call [CreateWindowExA]
  mov [hLabel], eax
  push dword [hEdit]
  call [SetFocus]               ; the cursor is in the input line
  xor eax, eax                  ; 0: the window is created
  pop ebp
  ret 16

on_command:
  mov eax, [ebp+16]             ; wParam
  movzx eax, ax                 ; the ID is the low word
  cmp eax, 1                    ; File > Exit
  jz on_exit
  cmp eax, 101                  ; the button
  jnz default
  push 64                       ; size of the buffer
  push dword buffer
  push dword [hEdit]
  call [GetWindowTextA]         ; the text of the input line
  push dword buffer
  push dword [hLabel]
  call [SetWindowTextA]         ; ... on the label
  xor eax, eax
  pop ebp
  ret 16

on_exit:
  push dword [ebp+8]
  call [DestroyWindow]          ; sends WM_DESTROY
  xor eax, eax
  pop ebp
  ret 16

on_destroy:
  push 0
  call [PostQuitMessage]        ; WM_QUIT ends the message loop
  xor eax, eax
  pop ebp
  ret 16

.data
hInstance:  dd 0
hEdit:      dd 0
hLabel:     dd 0

; WNDCLASS: ten dwords
wc:
  dd 0                          ; style
  dd WndProc                    ; lpfnWndProc: the address of the procedure
  dd 0                          ; cbClsExtra
  dd 0                          ; cbWndExtra
wc_instance:
  dd 0                          ; hInstance (set at the start)
  dd 0                          ; hIcon
wc_cursor:
  dd 0                          ; hCursor (set at the start)
  dd 6                          ; hbrBackground: COLOR_WINDOW + 1
  dd 0                          ; lpszMenuName
  dd cls_main                   ; lpszClassName

; MSG: seven dwords
msg:
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0

; the text of the input line is copied here (64 bytes)
buffer:
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

cls_main:   db 'AsmoWindow', 0
cls_edit:   db 'EDIT', 0
cls_button: db 'BUTTON', 0
cls_static: db 'STATIC', 0
txt_title:  db 'Asmonite window', 0
txt_file:   db '&File', 0
txt_exit:   db 'E&xit', 0
txt_show:   db 'Show', 0
txt_label:  db 'Type a text and press Show', 0
