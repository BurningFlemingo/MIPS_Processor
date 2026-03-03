# switches input at 4092
# hex output at 4088
lw $t1, 4($zero)
addi $t2, $zero, 5
multu $t1, $t2
mflo $t1
sw $t1, 0($zero)