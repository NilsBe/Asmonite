# DOS and BIOS interrupts

The instruction info (F1) shows, for an `int`, the function it calls. Which function it is stands in `ah`
(with the mouse, `int 33h`, in `ax`); Dismonite and Asmonite look for it in the instructions before
(`mov ah, 0x09`, `mov ax, 0x4C00`, `xor ah, ah`). If it cannot be determined, the overview of the
interrupt is shown.

Each section starts with `## ` and its name: `int21:09` is `int 21h` with `ah` = 09h, `int21` the
overview. Parameters and results are in registers; almost all functions report an error with the carry
flag set (CF = 1) and the error code in `ax`.

## int20 – Int 20h: terminate the program (old)

**Input:** `cs` = segment of the PSP (program prefix)

**Output:** none, the program ends

Ends the program like `int 21h` with `ah` = 00h. Works only if `cs` is the PSP segment, that is, in `.COM`
programs. Better is `int 21h` with `ah` = 4Ch, which also gives a return value.

Related: `int21:4c`

## int21 – Int 21h: DOS functions (overview)

The DOS call. The function number is in `ah`, the parameters in other registers. Errors: CF = 1 and the
code in `ax`.

- Characters: `01h` read with echo, `02h` write, `06h` direct, `07h`/`08h` read without echo, `09h` text up
  to `$`, `0Ah` read a line, `0Bh` input status, `0Ch` flush the buffer
- Files: `3Ch` create, `3Dh` open, `3Eh` close, `3Fh` read, `40h` write, `41h` delete, `42h` set the position,
  `43h` attributes, `56h` rename, `57h` date and time, `45h`/`46h` copy a handle
- Directories: `39h` create, `3Ah` delete, `3Bh` change, `47h` read the current one, `4Eh`/`4Fh` search
- Drives: `0Eh` select, `19h` current, `36h` free space
- Memory: `48h` allocate, `49h` free, `4Ah` change the size
- Programs: `4Bh` start, `4Ch` end, `4Dh` return value, `31h` end and stay resident
- Interrupts: `25h` set a vector, `35h` read a vector
- System: `2Ah`/`2Bh` date, `2Ch`/`2Dh` time, `30h` version, `33h` Ctrl+C, `59h` extended error,
  `38h` country info, `2Fh`/`1Ah` DTA, `51h`/`62h` PSP
- old (FCB): `0Fh` to `17h`, `21h` to `24h`, `27h` to `29h`

The same names with a colon and the number show the details: `int21:3d`.

Related: `int`, `int20`

## int21:00 – Int 21h, AH=00h: terminate the program (old)

**Input:** `ah` = 00h, `cs` = segment of the PSP

**Output:** none

Like `int 20h`. Obsolete; `ah` = 4Ch is better and gives the return value.

Related: `int21:4c`, `int20`

## int21:01 – Int 21h, AH=01h: read a character with echo

**Input:** `ah` = 01h

**Output:** `al` = the character

Waits for a key, shows the character and checks for Ctrl+C. For a special key (arrows, F1 ...) `al` = 0;
a second call then gives the scan code.

```asm
mov ah, 0x01
int 0x21         ; al = key
```

Related: `int21:08`, `int21:02`

## int21:02 – Int 21h, AH=02h: write a character

**Input:** `ah` = 02h, `dl` = the character

**Output:** none (`al` is `dl` afterwards)

Writes one character to the screen. `0x0D` goes to the start of the line, `0x0A` one line down; for a line
break write both. Checks for Ctrl+C.

```asm
mov dl, 'A'
mov ah, 0x02
int 0x21
```

Related: `int21:09`, `int21:06`

## int21:03 – Int 21h, AH=03h: read a character from the serial port

**Input:** `ah` = 03h

**Output:** `al` = the character

Reads from COM1 (the auxiliary port, AUX) and waits until a character is there. For the port itself
`int 14h` is more exact.

Related: `int21:04`, `int14`

## int21:04 – Int 21h, AH=04h: send a character to the serial port

**Input:** `ah` = 04h, `dl` = the character

**Output:** none

Sends a character to COM1 (AUX).

Related: `int21:03`, `int14`

## int21:05 – Int 21h, AH=05h: send a character to the printer

**Input:** `ah` = 05h, `dl` = the character

**Output:** none

Writes a character to the printer LPT1.

Related: `int17`

## int21:06 – Int 21h, AH=06h: direct input and output

**Input:** `ah` = 06h, `dl` = the character, or `dl` = FFh for reading

**Output:** when reading: ZF = 1 if no key is there, else ZF = 0 and `al` = the character

With `dl` = FFh it reads without waiting, without echo and without checking for Ctrl+C. Any other value of
`dl` is written. Typical in games and loops that wait for a key while doing something else.

```asm
mov dl, 0xFF
mov ah, 0x06
int 0x21
jz no_key
```

Related: `int21:07`, `int21:0b`

## int21:07 – Int 21h, AH=07h: read a character without echo, without Ctrl+C

**Input:** `ah` = 07h

**Output:** `al` = the character

Waits for a key without showing it and without checking for Ctrl+C. For a special key `al` = 0 and the next
call gives the scan code.

Related: `int21:08`, `int16:00`

## int21:08 – Int 21h, AH=08h: read a character without echo

**Input:** `ah` = 08h

**Output:** `al` = the character

Like `ah` = 07h, but checks for Ctrl+C (then `int 23h` is called).

Related: `int21:07`, `int21:01`

## int21:09 – Int 21h, AH=09h: write text

**Input:** `ah` = 09h, `ds:dx` = address of the text, which ends with `$`

**Output:** none (`al` = 24h)

Writes the text up to the character `$` (which is not written). A `$` in the text itself is not possible.
Line break: `13, 10` in the text.

```asm
mov dx, text
mov ah, 0x09
int 0x21
...
text: db 'Hello!', 13, 10, '$'
```

Related: `int21:02`, `int21:40`

## int21:0a – Int 21h, AH=0Ah: read a line

**Input:** `ah` = 0Ah, `ds:dx` = buffer: byte 0 = size of the buffer (including the line end), the rest is filled

**Output:** byte 1 of the buffer = number of characters read (without the line end), from byte 2 the text, at the end `0x0D`

Reads a line with editing (backspace, Esc) up to the Enter key.

```asm
buffer: db 80, 0
        times 82 db 0
```

Related: `int21:01`, `int21:3f`

## int21:0b – Int 21h, AH=0Bh: input status

**Input:** `ah` = 0Bh

**Output:** `al` = 0FFh if a character is waiting, else 0

Checks whether a key was pressed, without waiting and without fetching the character.

Related: `int21:06`, `int16:01`

## int21:0c – Int 21h, AH=0Ch: flush the keyboard buffer and read

**Input:** `ah` = 0Ch, `al` = the function that is called afterwards (01h, 06h, 07h, 08h or 0Ah)

**Output:** as the function called

First discards what was typed, then executes the input function in `al`.

Related: `int21:01`, `int21:08`

## int21:0d – Int 21h, AH=0Dh: reset the drives

**Input:** `ah` = 0Dh

**Output:** none

Writes all file buffers to the media, but does not close the files.

Related: `int21:68`

## int21:0e – Int 21h, AH=0Eh: select a drive

**Input:** `ah` = 0Eh, `dl` = drive (0 = A, 1 = B, 2 = C)

**Output:** `al` = number of drives in the system

Makes the drive the current one.

Related: `int21:19`

## int21:0f, int21:10, int21:11, int21:12, int21:13, int21:14, int21:15, int21:16, int21:17, int21:21, int21:22, int21:23, int21:24, int21:27, int21:28, int21:29 – file functions with FCB (old)

**Input:** `ds:dx` = address of an FCB (file control block, 37 bytes)

**Output:** `al` = 0 on success, 0FFh on error

The file functions from the time of DOS 1 (CP/M): open `0Fh`, close `10h`, search `11h`/`12h`, delete `13h`,
read `14h`, write `15h`, create `16h`, rename `17h`, random access `21h` to `24h`, blocks `27h`/`28h`, split
a file name `29h`. Today the functions with handles (`3Ch` to `42h`) are used; they also handle paths and
large files.

Related: `int21:3d`, `int21:3f`

## int21:19 – Int 21h, AH=19h: current drive

**Input:** `ah` = 19h

**Output:** `al` = drive (0 = A, 1 = B, 2 = C)

Related: `int21:0e`

## int21:1a – Int 21h, AH=1Ah: set the DTA

**Input:** `ah` = 1Ah, `ds:dx` = address of the DTA (disk transfer area, 128 bytes)

**Output:** none

Sets the buffer in which the search functions `4Eh` and `4Fh` put their result. Without this call it is
`PSP:0080h` (the command line).

Related: `int21:2f`, `int21:4e`

## int21:1b, int21:1c, int21:1f, int21:32 – drive data (old)

**Input:** `ah` = 1Bh (current drive), 1Ch (drive in `dl`), 1Fh (current) or 32h (`dl`) for the parameter block

**Output:** with 1Bh and 1Ch: `al` = sectors per cluster, `cx` = bytes per sector, `dx` = number of clusters,
`ds:bx` = pointer to the media ID; with 1Fh and 32h: `ds:bx` = pointer to the drive parameter block

Gives data about the layout of a drive. For the free space use `ah` = 36h.

Related: `int21:36`

## int21:25 – Int 21h, AH=25h: set an interrupt vector

**Input:** `ah` = 25h, `al` = number of the interrupt, `ds:dx` = address of the new routine

**Output:** none

Writes the address into the interrupt table. Fetch the old one before with `ah` = 35h and restore it at
the end of the program.

```asm
push ds
mov dx, handler
push cs
pop ds
mov ax, 0x2508   ; int 8
int 0x21
pop ds
```

Related: `int21:35`, `int`

## int21:26 – Int 21h, AH=26h: create a new PSP

**Input:** `ah` = 26h, `dx` = segment of the new PSP

**Output:** none

Copies the PSP of the program to the address `dx:0`. Obsolete; to start programs use `ah` = 4Bh.

Related: `int21:4b`

## int21:2a – Int 21h, AH=2Ah: read the date

**Input:** `ah` = 2Ah

**Output:** `cx` = year (1980 to 2099), `dh` = month, `dl` = day, `al` = weekday (0 = Sunday)

Related: `int21:2c`, `int21:2b`

## int21:2b – Int 21h, AH=2Bh: set the date

**Input:** `ah` = 2Bh, `cx` = year, `dh` = month, `dl` = day

**Output:** `al` = 0 on success, 0FFh for an invalid date

Related: `int21:2a`

## int21:2c – Int 21h, AH=2Ch: read the time

**Input:** `ah` = 2Ch

**Output:** `ch` = hour, `cl` = minute, `dh` = second, `dl` = hundredths of a second

Related: `int21:2a`, `int21:2d`, `int1a:00`

## int21:2d – Int 21h, AH=2Dh: set the time

**Input:** `ah` = 2Dh, `ch` = hour, `cl` = minute, `dh` = second, `dl` = hundredths

**Output:** `al` = 0 on success, 0FFh for an invalid time

Related: `int21:2c`

## int21:2e – Int 21h, AH=2Eh: switch the check when writing on or off

**Input:** `ah` = 2Eh, `al` = 1 on, 0 off, `dl` = 0

**Output:** none

With the check on, DOS reads back every sector written for control. Without meaning today.

Related: `int21:54`

## int21:2f – Int 21h, AH=2Fh: read the DTA

**Input:** `ah` = 2Fh

**Output:** `es:bx` = address of the current DTA

Related: `int21:1a`

## int21:30 – Int 21h, AH=30h: DOS version

**Input:** `ah` = 30h

**Output:** `al` = major version, `ah` = minor version, `bh` = manufacturer, `bl:cx` = serial number

With DOS 5 and newer the function reports what is set with `SETVER`; the true version comes from
`ax` = 3306h. `al` = 0 means DOS 1.x.

```asm
mov ah, 0x30
int 0x21
cmp al, 5
jb too_old
```

Related: `int21:33`

## int21:31 – Int 21h, AH=31h: end the program and stay resident

**Input:** `ah` = 31h, `al` = return value, `dx` = size of the program that stays in memory (in 16-byte paragraphs)

**Output:** none, the program ends

The program stays in memory (TSR), for example with an interrupt of its own. Afterwards only runs what was
entered as a vector before.

Related: `int27`, `int21:25`

## int21:33 – Int 21h, AH=33h: Ctrl+Break and system data

**Input:** `ah` = 33h, `al` = 00h read, 01h set (`dl` = 0 off, 1 on), 05h boot drive (`dl` = 1 for A), 06h true DOS version

**Output:** `dl` = state (`al` = 00h); with `al` = 06h `bl` = major, `bh` = minor version, `dl` = revision,
`dh` = flags

Decides whether DOS checks for Ctrl+Break at every call or only with character functions.

Related: `int21:30`

## int21:34 – Int 21h, AH=34h: address of the InDOS flag

**Input:** `ah` = 34h

**Output:** `es:bx` = address of a byte that is not 0 while DOS executes a function

For programs that stay resident: only when the flag is 0 may a DOS function be called.

Related: `int28`

## int21:35 – Int 21h, AH=35h: read an interrupt vector

**Input:** `ah` = 35h, `al` = number of the interrupt

**Output:** `es:bx` = address of the routine

Preparation for `ah` = 25h: first remember the old vector, then enter your own and write it back at the end.

```asm
mov ax, 0x3508   ; int 8
int 0x21
mov [old_off], bx
mov [old_seg], es
```

Related: `int21:25`

## int21:36 – Int 21h, AH=36h: free space on a drive

**Input:** `ah` = 36h, `dl` = drive (0 = current, 1 = A, 2 = B, 3 = C)

**Output:** `ax` = sectors per cluster (0FFFFh for an invalid drive), `bx` = free clusters, `cx` = bytes per
sector, `dx` = clusters in total

Free space in bytes = `ax` * `bx` * `cx` (with large disks 16 bits are not enough).

Related: `int21:1b`

## int21:38 – Int 21h, AH=38h: country data

**Input:** `ah` = 38h, `al` = 0 (current country) or country number, `ds:dx` = buffer of 34 bytes

**Output:** CF = 0: `bx` = country number, the buffer with date format, currency sign, separators

Related: `int21:66`

## int21:39 – Int 21h, AH=39h: create a directory

**Input:** `ah` = 39h, `ds:dx` = path (text with a final 0)

**Output:** CF = 1: `ax` = 3 path not found, 5 access denied

Related: `int21:3a`, `int21:3b`

## int21:3a – Int 21h, AH=3Ah: delete a directory

**Input:** `ah` = 3Ah, `ds:dx` = path

**Output:** CF = 1: `ax` = 3 path not found, 5 access denied (also if not empty), 16 current directory

Related: `int21:39`

## int21:3b – Int 21h, AH=3Bh: change the directory

**Input:** `ah` = 3Bh, `ds:dx` = path

**Output:** CF = 1: `ax` = 3 path not found

Changes the directory, not the drive (for that `ah` = 0Eh).

Related: `int21:47`, `int21:0e`

## int21:3c – Int 21h, AH=3Ch: create a file

**Input:** `ah` = 3Ch, `cx` = attributes (0 normal, 1 read-only, 2 hidden, 4 system), `ds:dx` = name

**Output:** CF = 0: `ax` = handle; CF = 1: `ax` = 3 path not found, 4 too many open files, 5 access denied

Creates the file and opens it for writing. An existing file is emptied. `ah` = 5Bh fails instead if it exists
already.

```asm
mov dx, name
xor cx, cx
mov ah, 0x3C
int 0x21
jc error
mov [handle], ax
```

Related: `int21:3d`, `int21:40`, `int21:3e`, `int21:5b`

## int21:3d – Int 21h, AH=3Dh: open a file

**Input:** `ah` = 3Dh, `al` = access (0 read, 1 write, 2 both; bits 4 to 6 sharing), `ds:dx` = name

**Output:** CF = 0: `ax` = handle; CF = 1: `ax` = 2 file not found, 3 path not found, 4 too many open files,
5 access denied, 12 invalid access mode

The handle applies to `ah` = 3Fh, 40h, 42h and 3Eh. The handles 0 to 4 are already taken: 0 input, 1 output,
2 error output, 3 COM1, 4 printer.

```asm
mov dx, name
mov ax, 0x3D00   ; read
int 0x21
jc not_there
mov bx, ax
```

Related: `int21:3c`, `int21:3f`, `int21:3e`, `int21:6c`

## int21:3e – Int 21h, AH=3Eh: close a file

**Input:** `ah` = 3Eh, `bx` = handle

**Output:** CF = 1: `ax` = 6 invalid handle

Writes the file buffers and enters size, date and time. A file open at the end of the program is closed by
DOS, but not cleanly after a crash.

Related: `int21:3d`, `int21:68`

## int21:3f – Int 21h, AH=3Fh: read from a file

**Input:** `ah` = 3Fh, `bx` = handle, `cx` = number of bytes, `ds:dx` = buffer

**Output:** CF = 0: `ax` = bytes read (0 at the end of the file); CF = 1: `ax` = 5 access denied, 6 invalid
handle

Fewer bytes than asked for is no error, but the end of the file (or, with the keyboard: one line). With
handle 0 you read the input.

```asm
mov bx, [handle]
mov cx, 512
mov dx, buffer
mov ah, 0x3F
int 0x21
```

Related: `int21:40`, `int21:42`, `int21:3d`

## int21:40 – Int 21h, AH=40h: write to a file

**Input:** `ah` = 40h, `bx` = handle, `cx` = number of bytes, `ds:dx` = data

**Output:** CF = 0: `ax` = bytes written; CF = 1: `ax` = 5 access denied, 6 invalid handle

If `ax` is smaller than `cx`, the disk is full (no error!). `cx` = 0 cuts the file off at the current position.
Handle 1 is the screen output, 2 the error output.

```asm
mov bx, 1        ; screen
mov cx, length
mov dx, text
mov ah, 0x40
int 0x21
```

Related: `int21:3f`, `int21:09`, `int21:42`

## int21:41 – Int 21h, AH=41h: delete a file

**Input:** `ah` = 41h, `ds:dx` = name (without wildcards)

**Output:** CF = 1: `ax` = 2 file not found, 3 path not found, 5 access denied

Related: `int21:56`

## int21:42 – Int 21h, AH=42h: set the position in the file

**Input:** `ah` = 42h, `al` = 0 from the start, 1 from the current position, 2 from the end; `bx` = handle,
`cx:dx` = displacement (signed)

**Output:** CF = 0: `dx:ax` = new position from the start; CF = 1: `ax` = error code

The file size: `al` = 2 with `cx:dx` = 0.

```asm
mov ax, 0x4202   ; to the end
xor cx, cx
xor dx, dx
int 0x21         ; dx:ax = size
```

Related: `int21:3f`, `int21:40`

## int21:43 – Int 21h, AH=43h: read and set file attributes

**Input:** `ah` = 43h, `al` = 0 read, 1 set; `ds:dx` = name; `cx` = attributes (when setting)

**Output:** CF = 0: `cx` = attributes (when reading); CF = 1: `ax` = 2, 3 or 5

Attributes: 01h read-only, 02h hidden, 04h system, 10h directory, 20h archive.

Related: `int21:4e`

## int21:44 – Int 21h, AH=44h: IOCTL (control devices)

**Input:** `ah` = 44h, `al` = subfunction, `bx` = handle (or `bl` = drive)

**Output:** depending on the subfunction; CF = 1 on error

The most important subfunctions: 00h read device information (`dx`, bit 7 = 1: a device, no file), 01h set,
02h/03h read and write control data, 06h input status, 07h output status, 08h removable medium?, 09h drive on
the network?, 0Ah handle on the network?, 0Eh/0Fh logical drive. Typical use: finding out whether handle 1
points to the screen or to a file (`al` = 0, bit 7 of `dl`).

```asm
mov ax, 0x4400
mov bx, 1
int 0x21
test dl, 0x80    ; a device?
```

Related: `int21:3d`

## int21:45 – Int 21h, AH=45h: duplicate a handle

**Input:** `ah` = 45h, `bx` = handle

**Output:** CF = 0: `ax` = new handle for the same file; CF = 1: `ax` = 4 or 6

Related: `int21:46`

## int21:46 – Int 21h, AH=46h: redirect a handle to another

**Input:** `ah` = 46h, `bx` = handle, `cx` = handle that points to the same file afterwards

**Output:** CF = 1: `ax` = 4 or 6

This is how output is redirected: first open the file, then put handle 1 on it.

Related: `int21:45`

## int21:47 – Int 21h, AH=47h: read the current directory

**Input:** `ah` = 47h, `dl` = drive (0 current, 1 = A), `ds:si` = buffer of 64 bytes

**Output:** the path without drive and without a leading `\`, as text with a final 0; CF = 1: `ax` = 15 invalid
drive

Related: `int21:3b`

## int21:48 – Int 21h, AH=48h: allocate memory

**Input:** `ah` = 48h, `bx` = size in paragraphs (16 bytes)

**Output:** CF = 0: `ax` = segment of the block; CF = 1: `ax` = 7 memory blocks destroyed, 8 not enough memory,
`bx` = size of the largest free block

Programs (`.EXE` and `.COM`) get all the free memory at the start; they must first give memory back with
`ah` = 4Ah.

Related: `int21:49`, `int21:4a`

## int21:49 – Int 21h, AH=49h: free memory

**Input:** `ah` = 49h, `es` = segment of the block

**Output:** CF = 1: `ax` = 7 or 9 (invalid block)

Related: `int21:48`

## int21:4a – Int 21h, AH=4Ah: change a memory block

**Input:** `ah` = 4Ah, `es` = segment of the block, `bx` = new size in paragraphs

**Output:** CF = 1: `ax` = 7, 8 or 9; with 8 `bx` holds the largest possible size

First use it to give back the memory behind the own program (`es` = PSP segment) before you need memory with
`ah` = 48h or 4Bh.

Related: `int21:48`, `int21:4b`

## int21:4b – Int 21h, AH=4Bh: start a program

**Input:** `ah` = 4Bh, `al` = 0 load and execute, 1 load, 3 load an overlay; `ds:dx` = program name;
`es:bx` = parameter block (environment, command line, two FCBs)

**Output:** CF = 1: `ax` = 2 not found, 5 access denied, 8 not enough memory

Returns when the started program ends; the return value is fetched by `ah` = 4Dh. All registers except
`cs:ip` are changed afterwards, also `ss:sp` (save them before). Free memory with `ah` = 4Ah first.

Related: `int21:4d`, `int21:4c`, `int21:4a`

## int21:4c – Int 21h, AH=4Ch: end the program

**Input:** `ah` = 4Ch, `al` = return value (ERRORLEVEL)

**Output:** none, the program ends

The usual end of a DOS program. DOS closes the open files and frees the memory.

```asm
mov ax, 0x4C00 ; end, 0
int 0x21
```

Related: `int20`, `int21:31`, `int21:4d`

## int21:4d – Int 21h, AH=4Dh: return value of the last program

**Input:** `ah` = 4Dh

**Output:** `al` = return value, `ah` = kind of end (0 normal, 1 Ctrl+C, 2 critical error, 3 resident)

Related: `int21:4b`

## int21:4e – Int 21h, AH=4Eh: find the first file

**Input:** `ah` = 4Eh, `cx` = attributes that are searched too (0 only ordinary files), `ds:dx` = pattern with
`*` and `?`

**Output:** CF = 0: the DTA holds the file; CF = 1: `ax` = 2 or 3 (nothing found), 18 no more

Layout of the DTA: offset 15h attributes (1 byte), 16h time, 18h date, 1Ah size (4 bytes), 1Eh name (13 bytes
with a final 0). Set the DTA before with `ah` = 1Ah.

Related: `int21:4f`, `int21:1a`

## int21:4f – Int 21h, AH=4Fh: find the next file

**Input:** `ah` = 4Fh (the DTA of `ah` = 4Eh must not be changed)

**Output:** CF = 0: the DTA holds the next file; CF = 1: `ax` = 18 no more

Related: `int21:4e`

## int21:50, int21:51, int21:62 – read and set the PSP

**Input:** `ah` = 50h with `bx` = segment (set); 51h or 62h (read)

**Output:** `bx` = segment of the PSP of the running program (with 51h and 62h)

The PSP (program prefix, 256 bytes) holds the command line at offset 80h, the environment at offset 2Ch and
the memory limit at offset 02h.

Related: `int21:26`

## int21:54 – Int 21h, AH=54h: query the check when writing

**Input:** `ah` = 54h

**Output:** `al` = 0 off, 1 on

Related: `int21:2e`

## int21:56 – Int 21h, AH=56h: rename or move a file

**Input:** `ah` = 56h, `ds:dx` = old name, `es:di` = new name

**Output:** CF = 1: `ax` = 2, 3, 5 or 17 (not the same drive)

On the same drive you can also move to another directory.

Related: `int21:41`

## int21:57 – Int 21h, AH=57h: date and time of a file

**Input:** `ah` = 57h, `al` = 0 read, 1 set, `bx` = handle; when setting `cx` = time, `dx` = date

**Output:** when reading `cx` = time, `dx` = date; CF = 1: `ax` = 1 or 6

Time: bits 11 to 15 hour, 5 to 10 minute, 0 to 4 second / 2. Date: bits 9 to 15 year - 1980, 5 to 8 month,
0 to 4 day.

Related: `int21:43`

## int21:58 – Int 21h, AH=58h: strategy of memory allocation

**Input:** `ah` = 58h, `al` = 0 read, 1 set (`bx` = 0 first fit, 1 best fit, 2 last fit), 2/3 read/set the link to
the upper memory blocks

**Output:** `ax` = strategy (when reading)

Related: `int21:48`

## int21:59 – Int 21h, AH=59h: extended error information

**Input:** `ah` = 59h, `bx` = 0

**Output:** `ax` = extended error code, `bh` = class, `bl` = suggested action, `ch` = locus

After an error this gives more information than the code of the function, for example 32 for a sharing
violation (file locked by another program).

Related: `int24`

## int21:5a – Int 21h, AH=5Ah: create a temporary file

**Input:** `ah` = 5Ah, `cx` = attributes, `ds:dx` = path with `\` at the end and room for 13 more bytes

**Output:** CF = 0: `ax` = handle, the name is in the buffer; CF = 1: `ax` = error code

Creates a file with a unique name. Deleting it is up to the program.

Related: `int21:3c`

## int21:5b – Int 21h, AH=5Bh: create a new file

**Input:** `ah` = 5Bh, `cx` = attributes, `ds:dx` = name

**Output:** CF = 0: `ax` = handle; CF = 1: `ax` = 80 the file exists already

Like `ah` = 3Ch, but fails if the file exists.

Related: `int21:3c`

## int21:5c – Int 21h, AH=5Ch: lock a region of a file

**Input:** `ah` = 5Ch, `al` = 0 lock, 1 unlock, `bx` = handle, `cx:dx` = start, `si:di` = length

**Output:** CF = 1: `ax` = 1 (SHARE missing), 6 or 33 (lock violation)

For programs that use the same file together (with SHARE).

Related: `int21:3d`

## int21:66 – Int 21h, AH=66h: read and set the code page

**Input:** `ah` = 66h, `al` = 1 read, 2 set (`bx` = code page)

**Output:** when reading `bx` = active, `dx` = default code page (437 USA, 850 Western Europe)

Related: `int21:38`

## int21:67 – Int 21h, AH=67h: set the number of handles

**Input:** `ah` = 67h, `bx` = number (up to 255)

**Output:** CF = 1: `ax` = 8 not enough memory

Without the call a program has 20 handles (5 of them are taken).

Related: `int21:3d`

## int21:68 – Int 21h, AH=68h: write a file to the disk

**Input:** `ah` = 68h, `bx` = handle

**Output:** CF = 1: `ax` = 6 invalid handle

Writes the file buffers at once without closing the file (DOS 3.3 and newer).

Related: `int21:3e`, `int21:0d`

## int21:6c – Int 21h, AH=6Ch: extended open or create a file

**Input:** `ah` = 6Ch, `al` = 0, `bl` = access, `bh` = flags, `cx` = attributes, `dx` = action (bit 0 open if it
exists, bit 4 create if it does not exist, bit 1 overwrite), `ds:si` = name

**Output:** CF = 0: `ax` = handle, `cx` = what happened (1 opened, 2 created, 3 overwritten)

Combines `ah` = 3Dh and 3Ch (DOS 4 and newer).

Related: `int21:3d`, `int21:3c`

## int25 – Int 25h: read sectors absolutely

**Input:** `al` = drive (0 = A), `cx` = number of sectors, `dx` = first sector, `ds:bx` = buffer

**Output:** CF = 1: `ax` = error code (`al` = error of the device)

DOS leaves the flags **on the stack**: after the call you must remove them with `popf` or `add sp, 2`,
otherwise the program crashes. Obsolete; for large disks there is `int 21h` with `ax` = 7305h.

Related: `int26`, `int13:02`

## int26 – Int 26h: write sectors absolutely

**Input:** `al` = drive, `cx` = number, `dx` = first sector, `ds:bx` = buffer

**Output:** CF = 1: `ax` = error code

Like `int 25h`: the flags are on the stack afterwards. An error here can destroy the file system.

Related: `int25`, `int13:03`

## int27 – Int 27h: end and stay resident (old)

**Input:** `dx` = offset of the first byte behind the part that stays in memory; `cs` = PSP

**Output:** none, the program ends

Like `int 21h` with `ah` = 31h, but for programs up to 64 KB.

Related: `int21:31`

## int29 – Int 29h: fast character output

**Input:** `al` = the character

**Output:** none

Writes a character to the screen, without redirection and without a check for Ctrl+C. The shortest way to
write a character; undocumented up to DOS 5.

Related: `int21:02`, `int10:0e`

## int10 – Int 10h: screen (overview)

The video BIOS. The function is in `ah`.

- `00h` set the video mode, `0Fh` read the current one
- Cursor: `01h` shape, `02h` set, `03h` read
- `05h` select a page, `06h`/`07h` scroll a window
- Characters: `08h` read, `09h`/`0Ah` write, `0Eh` output (teletype), `13h` write text
- Graphics: `0Ch` set a pixel, `0Dh` read a pixel, `0Bh` palette and border
- `10h` color table (EGA/VGA), `11h` character set, `12h` EGA data, `1Ah` display type, `4Fh` VESA

With F1 on `int10:0e` and so on you get the details.

Related: `int`

## int10:00 – Int 10h, AH=00h: set the video mode

**Input:** `ah` = 00h, `al` = mode (bit 7 = 1: do not clear the screen)

**Output:** none

Important modes: 03h text 80 x 25 in 16 colors, 07h text monochrome, 13h graphics 320 x 200 in 256 colors,
12h graphics 640 x 480 in 16 colors, 04h graphics 320 x 200 in 4 colors.

```asm
mov ax, 0x0013 ; 256 colors
int 0x10
```

Related: `int10:0f`

## int10:01 – Int 10h, AH=01h: set the cursor shape

**Input:** `ah` = 01h, `ch` = first line (bits 0 to 4), `cl` = last line of the cursor

**Output:** none

A character has, depending on the card, 8, 14 or 16 lines (0 to 7, 13 or 15). `ch` = 20h hides the cursor.

Related: `int10:02`

## int10:02 – Int 10h, AH=02h: set the cursor

**Input:** `ah` = 02h, `bh` = page (usually 0), `dh` = row, `dl` = column (both from 0)

**Output:** none

```asm
xor bh, bh
mov dx, 0x0A28 ; row 10/40
mov ah, 0x02
int 0x10
```

Related: `int10:03`, `int10:0e`

## int10:03 – Int 10h, AH=03h: read the cursor

**Input:** `ah` = 03h, `bh` = page

**Output:** `dh` = row, `dl` = column, `ch` = first, `cl` = last line of the cursor shape

Related: `int10:02`

## int10:05 – Int 10h, AH=05h: select the screen page

**Input:** `ah` = 05h, `al` = page (0 to 7 in text mode)

**Output:** none

Related: `int10:00`

## int10:06 – Int 10h, AH=06h: scroll a window up

**Input:** `ah` = 06h, `al` = number of lines (0 = clear the window), `bh` = attribute of the new lines,
`ch:cl` = row and column at the upper left, `dh:dl` = row and column at the lower right

**Output:** none

With `al` = 0 and the whole window (0,0 to 24,79) you clear the screen.

```asm
mov ax, 0x0600
mov bh, 0x07 ; light gray
xor cx, cx
mov dx, 0x184F
int 0x10
```

Related: `int10:07`

## int10:07 – Int 10h, AH=07h: scroll a window down

**Input:** as `ah` = 06h

**Output:** none

Related: `int10:06`

## int10:08 – Int 10h, AH=08h: read character and attribute at the cursor

**Input:** `ah` = 08h, `bh` = page

**Output:** `al` = character, `ah` = attribute

Attribute: bits 0 to 3 foreground, 4 to 6 background, 7 blink.

Related: `int10:09`

## int10:09 – Int 10h, AH=09h: write a character with attribute

**Input:** `ah` = 09h, `al` = character, `bh` = page, `bl` = attribute (in graphics mode the color), `cx` =
number of repetitions

**Output:** none

The cursor does not move. Control characters are shown as pictures, not executed.

Related: `int10:0a`, `int10:0e`

## int10:0a – Int 10h, AH=0Ah: write a character

**Input:** `ah` = 0Ah, `al` = character, `bh` = page, `cx` = number of repetitions

**Output:** none

Like `ah` = 09h, but the attribute at the place stays.

Related: `int10:09`

## int10:0b – Int 10h, AH=0Bh: border and palette color

**Input:** `ah` = 0Bh, `bh` = 0 and `bl` = color of border and background; or `bh` = 1 and `bl` = palette
(0 or 1) in graphics mode 4

**Output:** none

Related: `int10:10`

## int10:0c – Int 10h, AH=0Ch: set a pixel

**Input:** `ah` = 0Ch, `al` = color, `bh` = page, `cx` = column, `dx` = row

**Output:** none

In graphics mode. Slow; fast programs write into the video memory themselves (`A000h:0`).

Related: `int10:0d`

## int10:0d – Int 10h, AH=0Dh: read a pixel

**Input:** `ah` = 0Dh, `bh` = page, `cx` = column, `dx` = row

**Output:** `al` = color

Related: `int10:0c`

## int10:0e – Int 10h, AH=0Eh: write a character (teletype)

**Input:** `ah` = 0Eh, `al` = character, `bh` = page, `bl` = color (only in graphics mode)

**Output:** none

Writes the character at the cursor and moves it; `0x07` (bell), `0x08` (backspace), `0x0A` and `0x0D` are
executed, at the end of the page it scrolls. The simplest output, also in a boot sector without DOS.

```asm
mov al, 'A'
mov ah, 0x0E
xor bh, bh
int 0x10
```

Related: `int10:13`, `int21:02`

## int10:0f – Int 10h, AH=0Fh: read the current video mode

**Input:** `ah` = 0Fh

**Output:** `al` = mode, `ah` = number of columns, `bh` = active page

Related: `int10:00`

## int10:10 – Int 10h, AH=10h: color palette (EGA and VGA)

**Input:** `ah` = 10h, `al` = subfunction: 00h set a palette register (`bl` = number, `bh` = value), 10h set a
color register (`bx` = number, `dh` = red, `ch` = green, `cl` = blue, each 0 to 63), 12h set a block (`es:dx`),
15h read a color register, 17h read a block

**Output:** depending on the subfunction

In mode 13h this changes the 256 colors.

Related: `int10:0b`

## int10:11 – Int 10h, AH=11h: load a character set (EGA and VGA)

**Input:** `ah` = 11h, `al` = subfunction (00h load an own set, 01h 8 x 14, 02h 8 x 8, 04h 8 x 16 built in,
30h read data)

**Output:** depending on the subfunction

Related: `int10:00`

## int10:12 – Int 10h, AH=12h: data of the video card (EGA and VGA)

**Input:** `ah` = 12h, `bl` = subfunction: 10h EGA data, 30h choose the number of lines, 36h video refresh on/off

**Output:** with `bl` = 10h: `bh` = 0 color / 1 monochrome, `bl` = memory (0 = 64 KB to 3 = 256 KB)

Also tests whether there is an EGA/VGA: if `bl` stays 10h, it is an older card.

Related: `int10:1a`

## int10:13 – Int 10h, AH=13h: write text

**Input:** `ah` = 13h, `al` = mode (bit 0: move the cursor, bit 1: the text has attributes), `bh` = page,
`bl` = attribute, `cx` = length, `dh:dl` = row and column, `es:bp` = text

**Output:** none

Writes a whole text at once (from the AT BIOS on).

```asm
mov ax, 0x1301
mov bx, 0x0007
mov cx, length
mov dx, 0x0000
mov bp, text     ; es:bp
int 0x10
```

Related: `int10:0e`

## int10:1a – Int 10h, AH=1Ah: display type (VGA)

**Input:** `ah` = 1Ah, `al` = 00h

**Output:** `al` = 1Ah if there is a VGA; `bl` = active type (7 VGA monochrome, 8 VGA color)

Related: `int10:12`

## int10:4f – Int 10h, AH=4Fh: VESA BIOS

**Input:** `ah` = 4Fh, `al` = 00h data of the card (`es:di` = buffer), 01h data of a mode, 02h set a mode
(`bx` = mode, bit 14 = linear storage)

**Output:** `ax` = 004Fh on success

For resolutions above 640 x 480 and more than 16 colors.

Related: `int10:00`

## int11 – Int 11h: equipment of the hardware

**Input:** none

**Output:** `ax` = equipment word: bit 0 floppy drive present, bit 1 coprocessor, bits 4 and 5 video mode at
the start, bits 6 and 7 number of floppy drives - 1, bits 9 to 11 number of serial ports, bits 14 and 15
number of printers

Related: `int12`

## int12 – Int 12h: size of the main memory

**Input:** none

**Output:** `ax` = size of the conventional memory in KB (at most 640)

Related: `int15:88`

## int13 – Int 13h: drives (overview)

The disk BIOS, without a file system: sectors on floppies and hard disks. The function is in `ah`, the drive
in `dl` (00h first floppy, 80h first hard disk).

- `00h` reset the drive, `01h` status
- `02h` read sectors, `03h` write, `04h` verify, `05h` format a track
- `08h` drive data, `15h` kind of drive
- `41h` extensions present?, `42h` read, `43h` write, `48h` data (LBA, for large disks)

Errors: CF = 1 and `ah` = code. Important codes: 01h invalid command, 02h address mark not found, 03h write
protected, 04h sector not found, 06h disk changed, 09h 64 KB boundary crossed, 10h read error (CRC), 20h
controller error, 40h track not found, 80h timeout (drive not ready).

Related: `int25`

## int13:00 – Int 13h, AH=00h: reset the drive

**Input:** `ah` = 00h, `dl` = drive

**Output:** CF = 1 on error, `ah` = code

Resets the controller and moves the heads to track 0. After a read error you repeat the access two or three
times with this call in between.

Related: `int13:02`

## int13:01 – Int 13h, AH=01h: status of the last access

**Input:** `ah` = 01h, `dl` = drive

**Output:** `al` = status code of the last access

Related: `int13`

## int13:02 – Int 13h, AH=02h: read sectors

**Input:** `ah` = 02h, `al` = number of sectors, `ch` = cylinder (lower 8 bits), `cl` = sector (bits 0 to 5,
from 1) and the upper 2 bits of the cylinder (bits 6 and 7), `dh` = head, `dl` = drive, `es:bx` = buffer

**Output:** CF = 0: `al` = number of sectors read; CF = 1: `ah` = error code

The buffer must not cross a 64 KB boundary. The boot sector is loaded this way: cylinder 0, head 0, sector 1.

```asm
mov ax, 0x0201   ; read 1 sector
mov cx, 0x0001 ; cyl. 0, sec. 1
mov dx, 0x0080 ; head 0, hd 1
mov bx, 0x7C00
int 0x13
```

Related: `int13:03`, `int13:00`, `int13:42`

## int13:03 – Int 13h, AH=03h: write sectors

**Input:** as `ah` = 02h

**Output:** CF = 0: `al` = number of sectors written; CF = 1: `ah` = error code

Related: `int13:02`

## int13:04 – Int 13h, AH=04h: verify sectors

**Input:** as `ah` = 02h (without buffer)

**Output:** CF = 1 on error

Related: `int13:02`

## int13:05 – Int 13h, AH=05h: format a track

**Input:** `ah` = 05h, `al` = sectors per track, `ch` = cylinder, `dh` = head, `dl` = drive, `es:bx` = table
with 4 bytes per sector (cylinder, head, sector, size)

**Output:** CF = 1 on error

Destroys the data of the track.

Related: `int13:02`

## int13:08 – Int 13h, AH=08h: read drive data

**Input:** `ah` = 08h, `dl` = drive

**Output:** `ch` = highest cylinder (lower 8 bits), `cl` = highest sector (bits 0 to 5) and upper bits of the
cylinder, `dh` = highest head, `dl` = number of drives, `bl` = type of a floppy

The number of cylinders, heads and sectors is in each case the highest value; cylinders and heads count from
0, sectors from 1.

Related: `int13:15`

## int13:15 – Int 13h, AH=15h: kind of drive

**Input:** `ah` = 15h, `dl` = drive

**Output:** `ah` = 0 no drive, 1 floppy without change line, 2 floppy with change line, 3 hard disk (`cx:dx` =
number of sectors)

Related: `int13:08`

## int13:41 – Int 13h, AH=41h: check the extensions

**Input:** `ah` = 41h, `bx` = 55AAh, `dl` = drive (80h or higher)

**Output:** CF = 0 and `bx` = AA55h if the extensions (LBA) are there; `cx` = bit 0: access through an address packet

Related: `int13:42`

## int13:42 – Int 13h, AH=42h: read sectors (LBA)

**Input:** `ah` = 42h, `dl` = drive, `ds:si` = address packet: byte 0 = size (10h), byte 1 = 0, word 2 = number of
sectors, double word 4 = buffer (offset:segment), quad word 8 = sector number

**Output:** CF = 1: `ah` = error code

Reads by sector number, without cylinders and heads; works beyond 8 GB.

```asm
packet: db 0x10, 0
        dw 1            ; sectors
        dw 0x7C00, 0    ; buffer
        dq 0            ; sector 0
```

Related: `int13:41`, `int13:43`

## int13:43 – Int 13h, AH=43h: write sectors (LBA)

**Input:** as `ah` = 42h; `al` = write mode (bit 0: verify)

**Output:** CF = 1: `ah` = error code

Related: `int13:42`

## int13:48 – Int 13h, AH=48h: read drive data (LBA)

**Input:** `ah` = 48h, `dl` = drive, `ds:si` = buffer (word 0 = size, set 1Ah before)

**Output:** CF = 0: the buffer holds cylinders, heads, sectors per track, number of sectors (quad word) and
bytes per sector

Related: `int13:08`

## int14 – Int 14h: serial port

**Input:** `ah` = function, `dx` = port (0 = COM1)

- `00h` set up: `al` = bits 5 to 7 speed (110 to 9600), 3 and 4 parity, 2 stop bits, 0 and 1 data bits (7 or 8)
- `01h` send: `al` = character
- `02h` receive: `al` = character
- `03h` read the status

**Output:** `ah` = line status (bit 7 timeout, bit 0 character there), `al` = modem status or the character

Related: `int21:03`

## int15 – Int 15h: system services (overview)

Services of the AT BIOS. The function is in `ah` (with the memory map in `ax` = E820h).

- `24h` control the A20 line, `4Fh` intercept the keyboard
- `86h` wait (microseconds), `87h` copy memory above 1 MB, `88h` size of the extended memory,
  `89h` switch to protected mode
- `C0h` system data, `E8h` memory map (`ax` = E820h)

Related: `int12`

## int15:86 – Int 15h, AH=86h: wait

**Input:** `ah` = 86h, `cx:dx` = time in microseconds

**Output:** CF = 1 if the service is missing

Waits the time (resolution about 976 µs). Gives no time to other programs in the background.

Related: `int1a:00`

## int15:87 – Int 15h, AH=87h: copy memory above 1 MB

**Input:** `ah` = 87h, `cx` = number of words, `es:si` = table with descriptors (source and destination)

**Output:** `ah` = 0 on success, CF = 1 on error

Switches briefly to protected mode to reach the memory above 1 MB.

Related: `int15:88`

## int15:88 – Int 15h, AH=88h: size of the extended memory

**Input:** `ah` = 88h

**Output:** `ax` = size of the memory above 1 MB in KB (at most 64 MB)

Related: `int12`, `int15:87`

## int16 – Int 16h: keyboard (overview)

The keyboard BIOS. The function is in `ah`.

- `00h` read a key (waits), `01h` key there?, `02h` shift state
- `05h` put a key in the buffer, `03h` repeat rate
- `10h`, `11h`, `12h` like `00h` to `02h` for the enhanced keyboard (F11, F12, separate arrow keys)

The key comes as a word: `al` = ASCII character (0 for special keys), `ah` = scan code.

Related: `int21:08`

## int16:00 – Int 16h, AH=00h: read a key

**Input:** `ah` = 00h

**Output:** `al` = ASCII character (0 for special keys), `ah` = scan code

Waits for a key and removes it from the buffer. Scan codes: 48h arrow up, 50h down, 4Bh left, 4Dh right,
3Bh F1, 01h Esc.

```asm
xor ah, ah
int 0x16
cmp al, 27       ; Esc?
```

Related: `int16:01`, `int21:08`

## int16:01 – Int 16h, AH=01h: key there?

**Input:** `ah` = 01h

**Output:** ZF = 1: no key there; ZF = 0: `ax` = key (stays in the buffer)

Related: `int16:00`, `int21:0b`

## int16:02 – Int 16h, AH=02h: shift state

**Input:** `ah` = 02h

**Output:** `al` = bits: 0 right shift, 1 left shift, 2 Ctrl, 3 Alt, 4 Scroll, 5 Num, 6 Caps, 7 Insert

Related: `int16:00`

## int16:03 – Int 16h, AH=03h: set the repeat rate

**Input:** `ah` = 03h, `al` = 05h, `bh` = delay (0 to 3), `bl` = rate (0 to 31, 0 fastest)

**Output:** none

Related: `int16:00`

## int16:05 – Int 16h, AH=05h: put a key in the buffer

**Input:** `ah` = 05h, `ch` = scan code, `cl` = ASCII character

**Output:** `al` = 0 on success, 1 buffer full

Related: `int16:00`

## int16:10, int16:11, int16:12 – keyboard (enhanced)

**Input:** `ah` = 10h (read), 11h (there?), 12h (shift state)

**Output:** as `ah` = 00h, 01h, 02h; with 12h `ax` also holds bits of the right and left Ctrl and Alt keys

They treat the keys F11, F12 and the second arrow keys correctly; `00h` gives wrong values for them.

Related: `int16:00`

## int17 – Int 17h: printer

**Input:** `ah` = 00h print a character (`al` = character), 01h initialize the printer, 02h status; `dx` = printer
(0 = LPT1)

**Output:** `ah` = status: bit 7 ready, 6 acknowledge, 5 out of paper, 4 selected, 3 error, 0 timeout

Related: `int21:05`

## int1a – Int 1Ah: clock (overview)

The time services of the BIOS. The function is in `ah`.

- `00h` read the counter (ticks since midnight, 18.2 per second), `01h` set it
- `02h` read the time of the real-time clock, `03h` set it
- `04h` read the date of the real-time clock, `05h` set it

The values of the real-time clock are BCD (two decimal digits per byte).

Related: `int21:2c`

## int1a:00 – Int 1Ah, AH=00h: read the counter

**Input:** `ah` = 00h

**Output:** `cx:dx` = ticks since midnight (about 18.2065 per second, 1,573,040 per day), `al` not 0 if
midnight has passed since the last call

The simplest time measurement: read twice and take the difference. The same value is at `0040h:006Ch`.

Related: `int1a:01`, `int15:86`

## int1a:01 – Int 1Ah, AH=01h: set the counter

**Input:** `ah` = 01h, `cx:dx` = new counter value

**Output:** none

Related: `int1a:00`

## int1a:02 – Int 1Ah, AH=02h: read the time

**Input:** `ah` = 02h

**Output:** `ch` = hour, `cl` = minute, `dh` = second (BCD), `dl` = daylight saving time (0 or 1); CF = 1 if the
clock is not running

Related: `int1a:04`, `int21:2c`

## int1a:03 – Int 1Ah, AH=03h: set the time

**Input:** `ah` = 03h, `ch` = hour, `cl` = minute, `dh` = second (BCD), `dl` = daylight saving time

**Output:** none

Related: `int1a:02`

## int1a:04 – Int 1Ah, AH=04h: read the date

**Input:** `ah` = 04h

**Output:** `ch` = century (19 or 20), `cl` = year, `dh` = month, `dl` = day (all BCD); CF = 1 if the clock is not
running

Related: `int1a:02`, `int21:2a`

## int1a:05 – Int 1Ah, AH=05h: set the date

**Input:** `ah` = 05h, `ch` = century, `cl` = year, `dh` = month, `dl` = day (BCD)

**Output:** none

Related: `int1a:04`

## int2f – Int 2Fh: multiplex (overview)

Serves as a common connection for programs that settle in memory: each has a number in `ah`. With
`al` = 00h you ask whether it is there (most answer `al` = FFh).

- `10h` SHARE, `16h` Windows and idle, `43h` XMS driver (HIMEM.SYS)
- others: `11h` network, `15h` MSCDEX (CD-ROM), `48h` DOSKEY, `AEh` command interpreter

Related: `int28`

## int2f:10 – Int 2Fh, AH=10h: SHARE

**Input:** `ax` = 1000h

**Output:** `al` = FFh if SHARE (file locking) is there

Related: `int21:5c`

## int2f:16 – Int 2Fh, AH=16h: Windows and idle

**Input:** `ax` = 1600h (is Windows running in enhanced mode?) or `ax` = 1680h (report idle)

**Output:** with 1600h: `al` = 00h or 80h: not there; else the major version in `al`, the minor version in `ah`;
with 1680h: `al` = 00h if the call is supported

A program that waits for something calls 1680h in the loop, so that Windows or a multitasker can give the time
to others.

Related: `int28`

## int2f:43 – Int 2Fh, AH=43h: XMS driver

**Input:** `ax` = 4300h (there?) or 4310h (get the entry point)

**Output:** with 4300h: `al` = 80h if the driver (HIMEM.SYS) is there; with 4310h: `es:bx` = address that you
call with `call far` for the XMS functions

Related: `int15:87`

## int33 – Int 33h: mouse (overview)

The mouse driver (Microsoft mouse interface). The function is in `ax`; first check with 0000h whether a driver
is there. Coordinates are virtual points; in text mode they are multiples of 8 (column = `cx` / 8).

- `0000h` reset and check, `0001h` show the pointer, `0002h` hide
- `0003h` position and buttons, `0004h` set the position
- `0005h` button press, `0006h` release (per button), `000Bh` motion since the last call
- `0007h`/`0008h` range of the motion, `000Ch` own routine for events, `000Fh` sensitivity

Related: `int`

## int33:0000 – Int 33h, AX=0000h: reset and check the mouse

**Input:** `ax` = 0000h

**Output:** `ax` = FFFFh if the driver is there, else 0; `bx` = number of buttons (2, 3 or FFFFh)

Resets the driver: the pointer is hidden, in the middle, and the range is the whole screen.

```asm
xor ax, ax
int 0x33
test ax, ax
jz no_mouse
```

Related: `int33:0001`

## int33:0001 – Int 33h, AX=0001h: show the mouse pointer

**Input:** `ax` = 0001h

**Output:** none

A counter: every hide (0002h) needs a show. In graphics mode you must hide the pointer near the spot before
drawing.

Related: `int33:0002`

## int33:0002 – Int 33h, AX=0002h: hide the mouse pointer

**Input:** `ax` = 0002h

**Output:** none

Related: `int33:0001`

## int33:0003 – Int 33h, AX=0003h: read position and buttons

**Input:** `ax` = 0003h

**Output:** `bx` = buttons (bit 0 left, bit 1 right, bit 2 middle), `cx` = column, `dx` = row

```asm
mov ax, 3
int 0x33
test bx, 1       ; left button?
```

Related: `int33:0005`

## int33:0004 – Int 33h, AX=0004h: set the mouse pointer

**Input:** `ax` = 0004h, `cx` = column, `dx` = row

**Output:** none

Related: `int33:0003`

## int33:0005 – Int 33h, AX=0005h: data about button presses

**Input:** `ax` = 0005h, `bx` = button (0 left, 1 right, 2 middle)

**Output:** `ax` = state of the buttons, `bx` = number of presses since the last call, `cx:dx` = position at the
last press

Related: `int33:0006`

## int33:0006 – Int 33h, AX=0006h: data about releases

**Input:** `ax` = 0006h, `bx` = button

**Output:** `ax` = state of the buttons, `bx` = number of releases, `cx:dx` = position at the last release

Related: `int33:0005`

## int33:0007 – Int 33h, AX=0007h: set the horizontal range

**Input:** `ax` = 0007h, `cx` = smallest column, `dx` = largest column

**Output:** none

Related: `int33:0008`

## int33:0008 – Int 33h, AX=0008h: set the vertical range

**Input:** `ax` = 0008h, `cx` = smallest row, `dx` = largest row

**Output:** none

Related: `int33:0007`

## int33:000b – Int 33h, AX=000Bh: motion since the last call

**Input:** `ax` = 000Bh

**Output:** `cx` = horizontal, `dx` = vertical motion in mickeys (signed)

A mickey is the smallest motion of the mouse (about 1/200 inch). For games that show no pointer.

Related: `int33:0003`

## int33:000c – Int 33h, AX=000Ch: own routine for events

**Input:** `ax` = 000Ch, `cx` = mask of the events (bit 0 motion, 1 left pressed, 2 left released, 3 right
pressed, 4 right released, 5 middle pressed, 6 middle released), `es:dx` = address of the routine

**Output:** none

The driver calls the routine with `call far`: `ax` = events, `bx` = buttons, `cx:dx` = position, `si:di` =
motion. The routine ends with `retf` and may hardly call DOS functions.

Related: `int33:0003`

## int33:000f – Int 33h, AX=000Fh: set the sensitivity

**Input:** `ax` = 000Fh, `cx` = mickeys per 8 points horizontally (default 8), `dx` = vertically (default 16)

**Output:** none

Related: `int33:000b`

## int28 – Int 28h: DOS is idle

**Input:** none (an interrupt that DOS raises itself)

**Output:** none

DOS calls it while it waits for an input. Programs that stay resident hook in there, because then DOS
functions are allowed (the InDOS flag is set, but DOS is not deep inside a function).

Related: `int21:34`, `int2f:16`

## int24 – Int 24h: critical error

**Input:** none (DOS calls the routine on a device error)

**Output:** `al` = 0 ignore, 1 retry, 2 abort, 3 end the function with an error

The routine that shows "Abort, Retry, Ignore?". A program hooks its own vector to handle the error itself.

Related: `int21:59`

## !label

**Label** (jump mark): a name for an address. Jumps, calls and data refer to it.

## !missing

There is no explanation for `{name}` yet.
