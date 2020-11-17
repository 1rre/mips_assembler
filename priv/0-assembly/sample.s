.data                            #// Demark this section as data which will be assembled after the text section
str:  .asciiz "this is a string" #// An example string
byt:  .byte 0x3                  #// Takes up 1 byte of memory
      .align 2                   #// Fill memory with 0s until we get to a multiple of 2² (4)
wrd:  .word 1000                 #// Takes up 4 bytes of memory
.text                            #// Demark this section of text which will be assembled before the data declaration
main:                            #// Label this instruction as the start of "main". As .globl directives are ignored the name is irrelevant.
li  $v0, 10                      #// Load the exit syscall into register 2
la  $t0, byt                     #// Load the address of "byt" into register 8
lw  $t1, wrd                     #// Load the address of "wrd" into register 9
lw  $t2, 4($t0)                  #// Load the address stored in register 9 offset by 4 into register 10
beq $t1, $t2, 8                  #// Skip the next instruction if registers 9 and 10 have equal contents
j main                           #// Jump to "main" (line 7)
syscall                          #// Call to the system, as we loaded 10 into register 2 this will be exit