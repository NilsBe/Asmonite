# Instruction info (F1)

The instruction info explains what a line does: the instruction, the Windows function it calls, the DOS
interrupt, the directive of the assembler, and also error messages. It is in both programs, with the
same texts.

## Opening it

- **Asmonite:** press **F1** in the editor. The help appears in the column on the right, beside the
  register list (tab **Help**). It shows what the line with the cursor needs. It changes only when you press
  F1 again; **x** in its title bar closes it.
- **Dismonite:** press **F1** on a row. The tab **Info** appears on the right. It follows the cursor
  (*Help > Info follows the cursor* switches that off); **x** closes it.

## What it explains

| On the line | The help shows |
| --- | --- |
| an instruction (`mov`, `push`, `add r0, r1, #1`) | syntax, allowed operands, flags, an example; for x86 and x64, ARM (Thumb-2, `.arch thumb`), ARM64, RISC-V (32 and 64 bits) and Xtensa, after the `.arch` of the source. An instruction without an explanation of its own shows its short section from the instruction reference (syntax, operation, flags); after an x87 or SSE instruction comes the overview `x87` or `sse` |
| a call of an imported function (`call [ExitProcess]`, `ldr r3, =CloseHandle`) | the DLL, the calling convention, every parameter with type and meaning, the result, a short explanation |
| `int 21h`, `int 10h`, `int 13h` ... | the function (its number is in `ah`; the info looks for it in the lines before), input and output registers, error codes |
| a directive (`.arch`, `.format`, `.import`, `section` ...) | what it does and an example |
| an error message | what it means, what usually causes it, how to fix it |

The imported functions come from `help\<language>\winapi.md` (kernel32, user32, gdi32, advapi32,
shell32, msvcrt and the universal C runtime, over 230 functions). A function that is not described is
shown with its name and DLL.

## Error messages

- **In the editor:** after a failed assembly the line with the first error is marked red. F1 on that line
  explains the message.
- **In the output window:** click a line of the message and press F1. This works for the messages of the
  assembler and for the lines of the PE check ("DLL not found", "function not found in ...").

## Language

*Help > Help language* switches between Deutsch and English at once; the choice is saved
(`Asmonite.ini` or `Dismonite.ini`). Without a choice the language of the Windows user interface counts:
German for a German Windows, English for every other one.

## Limits

- The function of a DOS interrupt is found only when `ah` (or `ax`) is set by a `mov` or `xor` in the
  lines directly before; if it is not clear, the overview of the interrupt is shown.
- The texts are written for learning: they leave out rare details. The system documentation of the
  function remains the reference.
