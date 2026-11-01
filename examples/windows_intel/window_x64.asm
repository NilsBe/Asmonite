; A window, Windows, Intel 64 bit (.arch x64, PE32+, .format pe gui).
; Assemble: asmoc window_x64.asm
;
; The same program as window_i386.asm: a main window with a menu bar (File > Exit), an
; input line, a button "Show" and a label. Pressing the button copies the text of the
; input line to the label; the menu entry Exit ends the program.
;
; What is different from the 32 bit version:
;   - the first four arguments are in rcx, rdx, r8 and r9, the others on the stack
;     above 32 bytes of "shadow space" that the caller always reserves; no push/pop
;     of arguments, no "ret 16": the callee returns with a plain ret
;   - rsp must be a multiple of 16 at every call; at the entry of a procedure it is 8
;     off (the return address), so every procedure first subtracts 8 + n * 16
;   - WndProc gets hwnd in rcx, message in rdx, wParam in r8, lParam in r9
;   - rbx, rsi, rdi, rbp and r12 to r15 are kept by the Windows functions; rax, rcx,
;     rdx and r8 to r11 are not
;   - handles are 8 bytes: the WNDCLASS is 72 bytes, its pointers are filled at the start
;
; There are no expressions and no structures in the assembler: the numbers (styles,
; IDs, offsets in the WNDCLASS) are written out.

.format pe gui
.arch x64
.import kernel32.dll GetModuleHandleA, ExitProcess
.import user32.dll RegisterClassA, CreateWindowExA, DefWindowProcA, GetMessageA, TranslateMessage, DispatchMessageA, PostQuitMessage, LoadCursorA, CreateMenu, CreatePopupMenu, AppendMenuA, GetWindowTextA, SetWindowTextA, DestroyWindow, SetFocus

.code
start:
  sub rsp, 104                  ; 32 shadow + 8 arguments of CreateWindowExA (64) + spare
  xor ecx, ecx
  call [GetModuleHandleA]       ; our own module: the instance handle
  mov [hInstance], rax
  mov [wc_instance], rax        ; into the window class

  xor ecx, ecx
  mov edx, 32512                ; IDC_ARROW
  call [LoadCursorA]
  mov [wc_cursor], rax

  lea rax, [WndProc]
  mov [wc_proc], rax            ; lpfnWndProc
  lea rax, [cls_main]
  mov [wc_class], rax           ; lpszClassName
  lea rcx, [wc]
  call [RegisterClassA]

  ; the menu: File > Exit (ID 1)
  call [CreateMenu]             ; the menu bar
  mov rsi, rax                  ; rsi and rdi are kept by the Windows functions
  call [CreatePopupMenu]        ; the File menu
  mov rdi, rax
  mov rcx, rdi
  xor edx, edx                  ; MF_STRING
  mov r8d, 1                    ; ID of the entry: ID_EXIT
  lea r9, [txt_exit]
  call [AppendMenuA]
  mov rcx, rsi
  mov edx, 16                   ; MF_POPUP
  mov r8, rdi                   ; for MF_POPUP the "ID" is the handle of the menu
  lea r9, [txt_file]
  call [AppendMenuA]

  xor ecx, ecx                  ; no extended style
  lea rdx, [cls_main]
  lea r8, [txt_title]
  mov r9d, 0x10CF0000           ; WS_OVERLAPPEDWINDOW | WS_VISIBLE
  mov qword [rsp+32], 100       ; x
  mov qword [rsp+40], 100       ; y
  mov qword [rsp+48], 400       ; width
  mov qword [rsp+56], 200       ; height
  mov qword [rsp+64], 0         ; no parent
  mov [rsp+72], rsi             ; the menu bar
  mov rax, [hInstance]
  mov [rsp+80], rax
  mov qword [rsp+88], 0         ; lpParam
  call [CreateWindowExA]

next_message:
  lea rcx, [msg]
  xor edx, edx
  xor r8d, r8d
  xor r9d, r9d
  call [GetMessageA]            ; 0 after WM_QUIT
  test eax, eax
  jz done
  lea rcx, [msg]
  call [TranslateMessage]
  lea rcx, [msg]
  call [DispatchMessageA]       ; calls WndProc
  jmp next_message

done:
  xor ecx, ecx
  call [ExitProcess]

; LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
;                          rcx        edx           r8             r9
WndProc:
  push rbx                      ; rbx must be kept; it holds hwnd
  sub rsp, 96                   ; 8 (rbx) + 8 (return address) + 96 = 112: aligned
  mov rbx, rcx                  ; hwnd
  cmp edx, 1                    ; WM_CREATE
  jz on_create
  cmp edx, 0x111                ; WM_COMMAND
  jz on_command
  cmp edx, 2                    ; WM_DESTROY
  jz on_destroy
default:
  ; rcx is hwnd still; rdx, r8 and r9 are as WndProc got them
  call [DefWindowProcA]
leave_proc:
  add rsp, 96
  pop rbx
  ret

on_create:
  ; the input line (ID 102)
  xor ecx, ecx
  lea rdx, [cls_edit]
  xor r8d, r8d
  mov r9d, 0x50800000           ; WS_CHILD | WS_VISIBLE | WS_BORDER
  mov qword [rsp+32], 10        ; x
  mov qword [rsp+40], 10        ; y
  mov qword [rsp+48], 240       ; width
  mov qword [rsp+56], 24        ; height
  mov [rsp+64], rbx             ; parent: this window
  mov qword [rsp+72], 102       ; ID
  mov rax, [hInstance]
  mov [rsp+80], rax
  mov qword [rsp+88], 0
  call [CreateWindowExA]
  mov [hEdit], rax
  ; the button (ID 101)
  xor ecx, ecx
  lea rdx, [cls_button]
  lea r8, [txt_show]
  mov r9d, 0x50000000           ; WS_CHILD | WS_VISIBLE (BS_PUSHBUTTON is 0)
  mov qword [rsp+32], 260
  mov qword [rsp+40], 10
  mov qword [rsp+48], 90
  mov qword [rsp+56], 24
  mov [rsp+64], rbx
  mov qword [rsp+72], 101
  mov rax, [hInstance]
  mov [rsp+80], rax
  mov qword [rsp+88], 0
  call [CreateWindowExA]
  ; the label (ID 103), with a sunken border
  xor ecx, ecx
  lea rdx, [cls_static]
  lea r8, [txt_label]
  mov r9d, 0x50001000           ; WS_CHILD | WS_VISIBLE | SS_SUNKEN
  mov qword [rsp+32], 10
  mov qword [rsp+40], 50
  mov qword [rsp+48], 370
  mov qword [rsp+56], 24
  mov [rsp+64], rbx
  mov qword [rsp+72], 103
  mov rax, [hInstance]
  mov [rsp+80], rax
  mov qword [rsp+88], 0
  call [CreateWindowExA]
  mov [hLabel], rax
  mov rcx, [hEdit]
  call [SetFocus]               ; the cursor is in the input line
  xor eax, eax                  ; 0: the window is created
  jmp leave_proc

on_command:
  movzx eax, r8w                ; the ID is the low word of wParam
  cmp eax, 1                    ; File > Exit
  jz on_exit
  cmp eax, 101                  ; the button
  jnz default
  mov rcx, [hEdit]
  lea rdx, [buffer]
  mov r8d, 64                   ; size of the buffer
  call [GetWindowTextA]         ; the text of the input line
  mov rcx, [hLabel]
  lea rdx, [buffer]
  call [SetWindowTextA]         ; ... on the label
  xor eax, eax
  jmp leave_proc

on_exit:
  mov rcx, rbx
  call [DestroyWindow]          ; sends WM_DESTROY
  xor eax, eax
  jmp leave_proc

on_destroy:
  xor ecx, ecx
  call [PostQuitMessage]        ; WM_QUIT ends the message loop
  xor eax, eax
  jmp leave_proc

.data
hInstance:  dq 0
hEdit:      dq 0
hLabel:     dq 0

; WNDCLASSA: 72 bytes, the pointers are filled at the start
wc:
  dd 0                          ; style
  dd 0                          ; (padding)
wc_proc:
  dq 0                          ; lpfnWndProc
  dd 0                          ; cbClsExtra
  dd 0                          ; cbWndExtra
wc_instance:
  dq 0                          ; hInstance
  dq 0                          ; hIcon
wc_cursor:
  dq 0                          ; hCursor
  dq 6                          ; hbrBackground: COLOR_WINDOW + 1
  dq 0                          ; lpszMenuName
wc_class:
  dq 0                          ; lpszClassName

; MSG: 48 bytes
msg:
  dq 0
  dq 0
  dq 0
  dq 0
  dq 0
  dq 0

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
txt_title:  db 'Asmonite window (x64)', 0
txt_file:   db '&File', 0
txt_exit:   db 'E&xit', 0
txt_show:   db 'Show', 0
txt_label:  db 'Type a text and press Show', 0
