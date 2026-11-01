# Asmonite

[Deutsch](README.de.md) | English

**Asmonite** is an assembler with an editor and a debugger for Windows. **Dismonite** is a disassembler
and debugger that reads existing programs. Both are free, run on Windows without an installer, and
work with 32-bit and 64-bit Intel code and with ARM.

Current version: **0.7.6** | Website: [asmonite.com](https://asmonite.com) and
[dismonite.com](https://dismonite.com) | Chat: [Discord](https://discord.gg/Sj8kvqEkc)

![The Asmonite editor](assets/editor.png)

## What it does

**Asmonite** (editor, assembler, debugger)
- Writes real programs from `.asm` files: Windows PE (x86, x64, ARM64, ARM32/Thumb-2) and DOS (`.com`, `.exe`).
- Syntax like NASM/MASM in Intel notation, plus `func`, `call Name(args)`, `if` / `else` and `do ... while`
  for readable code. Differences to NASM: [docs/en/nasm-differences.md](docs/en/nasm-differences.md).
- **F1 explains the line under the cursor:** syntax, flags, example, the imported Windows function with its
  parameters, DOS and BIOS interrupts. In English and German.
- Debugger: breakpoints, step over / into, run to cursor, registers (changes in red), stack, memory,
  watch window, program output. Windows programs run on this computer, x64 through a helper process,
  ARM programs on a Windows-on-ARM computer, DOS programs in QEMU with FreeDOS.
- Also compiles a small C subset (`asmonite_cc`, derived from OTCC) and debugs it line by line.

**Dismonite** (disassembler, debugger)
- Opens Windows (PE: x86, x64, ARM, ARM64), DOS (MZ) and ARM Linux (ELF) programs.
- Follows the code from the entry point, lets you mark code and data, add comments, and saves them next to the program.
- **Exports the result as `.asm`** that Asmonite assembles back to the same file, byte for byte.
- Debugs the program, with the same instruction help.

![Dismonite debugging a Windows program](assets/dismonite-debug-pe.png)

## Download

Get the ZIP from the [Releases](../../releases) page or from [asmonite.com](https://asmonite.com).
Unpack it anywhere and start `Asmonite.exe` or `Dismonite.exe`; there is nothing to install.
The ZIP file has a SHA-256 sum next to it.

Small unsigned programs are sometimes flagged by virus scanners because of their heuristics.
The sums let you check that the file is the one that was published.

## What is in this repository

| Folder | Content |
|--------|---------|
| [`docs/`](docs) | Guides and the differences to NASM, in English and German |
| [`reference/`](reference) | The instruction help of the programs (F1) as text: x86, x64, ARM, ARM64, Windows API, DOS |
| [`examples/`](examples) | Example programs: Windows (Intel, ARM), DOS, `func` / `if` / loops, a C and a Pascal sample |
| [`CHANGELOG.md`](CHANGELOG.md) | What changed in each version |

The programs themselves are in the release ZIP, not in this repository.

## Example

```
.format pe console
.arch i386
.import msvcrt.dll cdecl printf
.import kernel32.dll ExitProcess

.code
start:
    call [printf](text)
    call [ExitProcess](0)

.data
text db 'Hello from Asmonite', 10, 0
```

Open it in Asmonite, press **F9**: the program is built next to the source and started in the debugger.

## License

Free to use, privately and commercially; see [LICENSE.txt](LICENSE.txt). Your own programs belong to you.

Copyright (c) 2026 Nils Belde
