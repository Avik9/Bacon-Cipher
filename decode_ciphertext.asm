.data
ciphertext: .asciiz "RaNDOM NUmBERs ShOUld nOT bE generatED wIth a METHoD cHOseN AT rANDOM. -DOnaLd KNuth"
ab_text: .ascii "AABBBAAABAABBBBBAAABAABABABABBBABBBAABAABAAABBABBBABAABBAABABBBBBAABABABAB"
null: .byte 0
.align 2
ab_text_length: .word 74

.text
.globl main
main:
la $a0, ciphertext
la $a1, ab_text
lw $a2, ab_text_length
la $a3, bacon_codes
jal decode_ciphertext

move $t0, $v0

la $a0, ab_text
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

move $a0, $t0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall


li $v0, 10
syscall

.include "proj2.asm"
.include "bacon_codes.asm"
