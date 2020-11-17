# Mips Assembler

This program assembles MIPS Assembly code to MIPS machine code.  


<details>
<summary> Supported Base Instructions </summary>
<br>

```mips
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
</details>
<details>
<summary> Supported Pseudo Instructions </summary>
<br>

```mips
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

```mips
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
* Integers can be in decimal (0-9) form, or hex (0x(0-f), case insensitive) form.
* Accepted escape characters are the same as C, excluding \uhhhh and \Uhhhhhhhh as these require more than 8 bits to store (I could easily add these if necessary)
* Files to be assembled should be placed in `resources/0-assembly/` and end in `.s` or `.asm`
* Labels can contain any alphabetic chars or underscores and are case sensitive.

</details>

## Dependencies

This assembler is written in Elixir and runs on the Erlang runtime system. That means that to compile this program you must have "Elixir" installed and to run the compiled binary you must have "Erlang" installed.

* These can both be installed with the command `apt-get install elixir`  
* If you only wish to run the compiled escript, you can just install Erlang with `apt-get install erlang`

## Downloading

You can either clone this repository or download the [latest release](https://github.com/tjm1518/mips_assembler/releases).

## Compiling

An escript (runable with `./`) can be compiled with running `mix escript.build` in the root directory of the project with Elixir installed on your system.

## Running

The escript can be run with `./mips` provided you have the Erlang runtime system installed. Running the script for the first time in a clean environment will set up the directory structure, alternatively if `resources/0-assembly/` is present, it will assemble each assembly file ending with `.s` or `.asm`

Alternatively, the program can be run directly through the Mix build tool by using the command `mix` in the root directory of the project.