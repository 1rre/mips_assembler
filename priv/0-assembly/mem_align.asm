.data
.align 4
str: .asciiz "hello world"
a: .byte 0x2
b: .asciiz "hello world"
c: .byte 0x12
.text
.globl main
add $0, $1, $1
blez $3,
lw $0, str
lb $0, 5($zero)