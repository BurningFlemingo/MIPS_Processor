# hex output at 0
# switches input at 4
lw $t1, 4($zero)
nop 
nop
nop
nop
addi $t2, $zero, 5
nop 
nop
nop
nop
multu $t1, $t2
nop 
nop
nop
nop
mflo $t1
nop 
nop
nop
nop
sw $t1, 0($zero)
nop 
nop
nop
nop
