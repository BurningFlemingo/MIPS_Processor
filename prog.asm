	addi $2, $0, -100
second:
	add $2, $1, $3
	sll $3, $4, 4
	lw $2, 100($3)
	j second
