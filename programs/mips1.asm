# hex output at 0
# switches input at 4
lw $t1, 4($zero)
addi $t2, $zero, 5
multu $t1, $t2
mflo $t1
sw $t1, 0($zero)
