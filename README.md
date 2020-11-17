# Mips Assembler

This program assembles MIPS Assembly code to MIPS machine code.  


<details>
<summary> Supported Base Instructions </summary>
<br>

```asm
SLL     $r, $r, im
SRL     $r, $r, im
SRA     $r, $r, im
SLLV    $r, $r, $r
JR      $r
SYSCALL 
BREAK 
MFHI    $r
MTHI    $r
MFLO    $r
MTLO    $r
MULT    $r, $r
MULTU   $r, $r
DIV     $r, $r
DIVU    $r, $r
ADD     $r, $r, $r
ADDU    $r, $r, $r
SUB     $r, $r, $r
SUBU    $r, $r, $r
AND     $r, $r, $r
OR      $r, $r, $r
XOR     $r, $r, $r
NOR     $r, $r, $r
SLT     $r, $r, $r
SLTU    $r, $r, $r
BGEZ    $r, im
BGEZ    $r, <label>   # I'm not sure if this should be in here
BGEZAL  $r, im
BGEZAL  $r, <label>   # I'm not sure if this should be in here
BLTZ    $r, im
BLTZ    $r, <label>   # I'm not sure if this should be in here
BLTZAL  $r, im
BLTZAL  $r, <label>   # I'm not sure if this should be in here
J       <label>
JAL     <label>
BEQ     $r, $r, im
BEQ     $r, $r, <label>   # I'm not sure if this should be in here
BNE     $r, $r, im
BNE     $r, $r, <label>   # I'm not sure if this should be in here
BLEZ    $r, $r, im
BLEZ    $r, $r, <label>   # I'm not sure if this should be in here
BGTZ    $r, $r, im
BGTZ    $r, $r, <label>   # I'm not sure if this should be in here
ADDI    $r, $r, im
ADDIU   $r, $r, im
SLTI    $r, $r, im
SLTIU   $r, $r, im
ANDI    $r, $r, im
ORI     $r, $r, im
XORI    $r, $r, im
LUI     $r, im
MFC0    $r, $r
MTC0    $r, $r
LB      $r, offset($r)
LB      $r, <label>
LH      $r, offset($r)
LH      $r, <label>
LW      $r, offset($r)
LW      $r, <label>
LBU     $r, offset($r)
LBU     $r, <label>
LHU     $r, offset($r)
LHU     $r, <label>
SB      $r, offset($r)
SB      $r, <label>
SH      $r, offset($r)
SH      $r, <label>
SW      $r, offset($r)
SW      $r, <label>
```

<summary> Supported Pseudo Instructions </summary>
<br>

```asm
ABS     $r, $r
BLT     $r, $r, im
BLT     $r, $r, <label>   # I'm not sure if this should be in here
LI      $r, im
LA      $r, <label>
```
</details>
<details>

<summary> Supported Data Directives </summary>
<br>

```asm
.byte     im
.byte     im, ...
.half     im
.half     im, ...
.word     im
.word     im, ...
.ascii    "string" # Including escape characters
.asciiz   "null-terminated string" # Including escape characters

```
</details>
<details>
<summary> Syntax </summary>
<br>
* Data and text blocks can optionally be demarked with `.data` and `.text`, these ensure that all text comes before all data.
* `.globl` directives are currently ignored
* Labels must currently be on the same line as or line immediately before the position they are pointing to (I hope to fix this soon)
* Integers can be in decimal (0-9) form, or hex (0x(0-f), case insensitive) form.
* Accepted escape characters are the same as C, excluding \uhhhh and \Uhhhhhhhh as these require more than 8 bits to store (I could easily add these if necessary)
* Files to be assembled should be placed in [0-assembly](/priv/0-assembly/) and end in `.s` or `.asm`
* Labels can contain any alphabetic chars or underscores and are case sensitive.
</details>