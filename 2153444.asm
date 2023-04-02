.data
firstPlayerData: .space 28		# allocate space data of 1st player
secondPlayerData: .space 28	# allocate space data of 2nd player
temp: .space 8
piecesUsed: .space 4
columnIsFull: .space 4
firstPlayer: .space 256    	# allocate space for the input string
secondPlayer: .space 256    	# allocate space for the input string
gameboard: .space 42  		# allocate 42 bytes of memory for a 6x7 game board
copyGameboard: .space 42  		# allocate 42 bytes of memory for a 6x7 game board
oldGameboard: .space 42  	# allocate 42 bytes of memory for a 6x7 game board
###### Game state
promptDash: .asciiz 	"\n==================================================================================================================\n"
promptDashNoNewline: .asciiz 	"=================================================================================================================="
promptWelcome: .asciiz 	"\n                                        Welcome to FOUR IN A ROW game\n"
promptProceed: .asciiz 	"\nProceed\n"
promptPlayer: .asciiz 	"                                             Player "
promptBigSpc: .asciiz "                                      "
promptWin: .asciiz 	"You have won!\n"
promptSomeSpace: .asciiz 	"     "
promptPep: .asciiz 	"|"
promptDLine: .asciiz 	"_"
promptTie: .asciiz 	"Tie game!\n"
promptBoth: .asciiz 	"Both players have chance to win!\n"
promptChanceToWin: .asciiz 	"There is a chance to win from player "
promptChanceToWinState: .asciiz "Chance-to-win state: "
promptWinState: .asciiz "win state: "
promptPiece: .asciiz 	"Piece: "
promptRem: .asciiz 	"Remove: "
promptUn: .asciiz 	"Undo: "
promptNumBlock: .asciiz 	"Block: "
promptVio: .asciiz 	"Violations made: "
promptNoViolations: .asciiz 	"You has already made A TOTAL OF 3 violations! Please be careful!\nPlease CAREFULLY re-input a correct one\n\n"
promptViolations: .asciiz 	"\nYou has just made a violations! (Either invalid input or your requested column is full)\nPlease be careful!\nPlease re-input a correct one\n\n"
promptAssign: .asciiz 	"is assigned piece"
promptUndo: .asciiz 	"\nYour number of remaining undo "
promptDropPiece: .asciiz 	"You want to drop piece at column number: "
promptIs: .asciiz 	"is "
promptRemove: .asciiz 	"You can remove one opponent's piece."
promptBlock: .asciiz 	"\nYou still have 1 time to block the opponent's turn."
promptCantBlock: .asciiz 	"\nYou can not block the opponent's turn!\nThere is a chance to win from your opponent!\n"
promptNoBlock: .asciiz 	"\nYou have used your ability to block the opponent's turn.\n"
promptTurn: .asciiz "\nNow is your turn again.\n"
promptNotToUse: .asciiz 	"\nSo you decided not to use your ability to remove.\n"
promptWrongPiece: .asciiz 	"\nThis is an invalid piece to remove.\n"
promptC: .asciiz 	"\nColumn: "
promptR: .asciiz 	"\nRow: "
promptAskToUse: .asciiz "Do you want to use it? (1 : YES / 0 : NO)"
promptNoRemove: .asciiz 	"You cannot remove opponent's piece from now!\n"
promptSuccessfullyRemove: .asciiz 	"\nYou successfully remove opponent's piece!\n"
promptSuccessfullyUndo: .asciiz 	"\nYou successfully undo your move!\n"
promptNoRemoveLeft: .asciiz 	"You dont have any removes left since you have already used it!\n"
promptNoUndoLeft: .asciiz 	"You dont have any undos left since you have already used all 3 of them!\n"
promptWrongInput: .asciiz 	"\nInvalid input! Please re-input: "
promptCongrats: .asciiz 	"Congrats to player "
promptColumnFull: .asciiz 	"The column you have chosen is full. Select a different column\n"

###### Game noti
prompt16: .asciiz 	"What is the name of the first player? "
prompt17: .asciiz 	"What is the name of the second player? "

###### Game items
X: .asciiz 		" X "
O: .asciiz  		" O "
empty: .asciiz 		" - "
newline: .asciiz 	"\n"
spc: .asciiz 		" "

.text
main: 	# Load Welcome Prompt
	li $v0, 4
	la $a0, promptDash	
	syscall
	la $a0, promptWelcome	
	syscall
	la $a0, promptDash
	syscall
	
	jal init_board
	jal input
	jal pre_process
	jal game
	j exit
	
return:	jr $ra
	
pre_process:
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
    	la $s1, firstPlayerData
    	li $t1, 3
    	sw $t1, 4($s1)		# violations of 1st player
    	li $t1, 3
    	sw $t1, 8($s1)		# undos of 1st player
    	li $t1, 1
    	sw $t1, 12($s1)		# remove of 1st player
    	li $t1, 0
    	sw $t1, 16($s1)		# chance-to-win state of 1st player
    	li $t1, 0
    	sw $t1, 20($s1)		# winning state of 1st player
    	li $t1, 1
    	sw $t1, 24($s1)		# block
    	
    	la $s2, secondPlayerData
    	li $t2, 3
    	sw $t2, 4($s2)		# violations of 2nd player
    	li $t2, 3
    	sw $t2, 8($s2)		# undos of 2nd player
    	li $t2, 1
    	sw $t2, 12($s2)		# remove of 2nd player
    	li $t2, 0
    	sw $t2, 16($s2)		# chance-to-win state of 2nd player
    	li $t2, 0
    	sw $t2, 20($s2)		# winning state of 2nd player
    	li $t2, 1
    	sw $t2, 24($s2)		# block
    	
	lw   $ra, ($sp)
    	addi $sp, $sp, 4     	# adjust stack
    	
    	jr $ra
game:
	# first move
	li $s7, 1
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
    	la $s0, piecesUsed
    	sw $zero, ($s0)
    	jal pre_game
    	jal print_first_player_state
    	jal print_second_player_state
	jal print_game_board
	
	game_continue:
		j player1
	make_undo1:
		jal first_player_check
		la $s0, temp
    		lw $s6, 4($s0)
		beq $s6, 0, player1	# did not remove in prev state
		la $s0, firstPlayerData
		li $t9, 1
		sw $t9, 12($s0)		# restore remove
		li $s6, 0
	player1:	
		li $s6, 0	# game state
		# saving old state
		jal save_old_state
		jal print_first_player_state
    		# 1st player move
    		jal first_player_remove
    		la $s0, temp
    		sw $s6, 4($s0)
    		beq $s6, 1, continue6	# use remove
    	player1_drop:
    		la $t2, columnIsFull
		sw $zero, ($t2)		# columnIsFull = false
    		jal first_player_drop
    		la $t2, columnIsFull
		lw $t9, ($t2)		
		beq $t9, 0, continue6	# if (columnIsFull = false) continue
		j player1_drop		# else drop again
	continue6:
		li $s7, 1
		jal first_player_check
		
	continue31:
		jal print_first_player_state
		jal print_game_board
		
		la $s1, firstPlayerData
		la $s2, secondPlayerData
		la $s0, firstPlayer
		la $s3, secondPlayer
		jal big_check
		
		li $t1, 0
		jal first_player_undo
		bne $t1, 0, make_undo1
		
		la $s1, firstPlayerData
		la $s2, secondPlayerData
		la $s0, temp
		sw $zero, ($s0)
		jal block_opponent
		lw $v0, ($s0)
		beq $v0, 1, player1
	
		j player2
	make_undo2:
		jal second_player_check
		la $s0, temp
    		lw $s6, 4($s0)
		beq $s6, 0, player2	# did not remove in prev state
		la $s0, secondPlayerData
		li $t9, 1
		sw $t9, 12($s0)		# restore remove
		li $s6, 0
	player2:
		li $s6, 0	# game state
		# saving old state
		jal save_old_state
		jal print_second_player_state
    		# 2nd player move
    		jal second_player_remove
    		la $s0, temp
    		sw $s6, 4($s0)
    		beq $s6, 1, continue7	# use remove
    	player2_drop:
    		la $t2, columnIsFull
		sw $zero, ($t2)		# columnIsFull = false
    		jal second_player_drop
    		la $t2, columnIsFull
		lw $t9, ($t2)		
		beq $t9, 0, continue7	# if (columnIsFull = false) continue
		j player2_drop		# else drop again
	continue7:
		li $s7, 1
		jal second_player_check
		
	continue33:
		
		jal print_second_player_state
		jal print_game_board
		
		la $s1, secondPlayerData
		la $s2, firstPlayerData
		la $s0,	secondPlayer 
		la $s3, firstPlayer
		jal big_check
		
		li $t1, 0
		jal second_player_undo
		bne $t1, 0, make_undo2
		
		la $s1, secondPlayerData
		la $s2, firstPlayerData
		la $s0, temp
		sw $zero, ($s0)
		jal block_opponent
		lw $v0, ($s0)
		beq $v0, 1, player2

	next2:
	
		lw   $ra, ($sp)
    		addi $sp, $sp, 4     	# adjust stack
    	
    		j game_continue
    		jr $ra
INVALID_INPUT:
	la $a0, promptWrongInput
	li $v0, 4
	syscall
	j ask
block_opponent:
	lw $t1, 24($s1)
	beq $t1, 0, no_block_to_use
	
	lw $t1, 16($s2)
	beq $t1, 1, cant_block
	
	la $a0, promptBlock
	li $v0, 4
	syscall
    
	la $a0, promptAskToUse
	li $v0, 4
	syscall
    ask:
	li $v0, 12
	syscall 
	addi $v0, $v0, -48
	
	beq $v0, 0, return		# dont use block
	beq $v0, 1, use_block		# use block
	
	j INVALID_INPUT
no_block_to_use:
	la $a0, promptNoBlock
	li $v0, 4
	syscall
	j return
cant_block:
	la $a0, promptCantBlock
	li $v0, 4
	syscall
	j return
use_block:
	la $t1, temp
	sw $v0, ($t1)
	sw $zero, 24($s1)
	la $a0, promptTurn
	li $v0, 4
	syscall
	j return
	
print_first_player_state:
	la $s0, firstPlayerData
	li $v0, 4
	la $a0, newline	
	syscall
	la $a0, promptDashNoNewline	
	syscall
	la $a0, newline
	syscall
	la $a0, promptPlayer	
	syscall
	la $a0, firstPlayer	
	syscall
	la $a0, promptDashNoNewline
	syscall
	la $a0, newline
	syscall
	j print
print_second_player_state:
	la $s0, secondPlayerData
	li $v0, 4
	la $a0, newline
	syscall	
	la $a0, promptDashNoNewline	
	syscall
	la $a0, newline
	syscall
	la $a0, promptPlayer	
	syscall
	la $a0, secondPlayer	
	syscall
	la $a0, promptDashNoNewline
	syscall
	la $a0, newline
	syscall
print:
	la $a0, promptPiece	
	li $v0, 4
	syscall
	
	lw $a0, ($s0)
	beq $a0, 1, GETO
	li $a0, 88
	j next
GETO:	li $a0, 79
next:	
	li $v0, 11
	syscall
	
	la $a0, promptSomeSpace	
	li $v0, 4
	syscall
	
	la $a0, promptRem	
	li $v0, 4
	syscall
	
	lw $a0, 12($s0)	
	li $v0, 1
	syscall
	
	la $a0, promptSomeSpace	
	li $v0, 4
	syscall
	
	la $a0, promptUn	
	li $v0, 4
	syscall
	
	lw $a0, 8($s0)	
	li $v0, 1
	syscall
	
	la $a0, promptSomeSpace	
	li $v0, 4
	syscall
	
	la $a0, promptVio	
	li $v0, 4
	syscall
	
	lw $a0, 4($s0)
	li $t4, 3
	sub $a0, $t4, $a0	
	li $v0, 1
	syscall
	
	la $a0, promptSomeSpace	
	li $v0, 4
	syscall
	
	la $a0, promptNumBlock
	li $v0, 4
	syscall
	
	lw $a0, 24($s0)	
	li $v0, 1
	syscall
	
	la $a0, promptSomeSpace	
	li $v0, 4
	syscall
	
	la $a0, promptChanceToWinState	
	li $v0, 4
	syscall
	
	lw $a0, 16($s0)	
	li $v0, 1
	syscall
	
	la $a0, promptSomeSpace	
	li $v0, 4
	syscall
	
	la $a0, promptWinState	
	li $v0, 4
	syscall
	
	lw $a0, 20($s0)	
	li $v0, 1
	syscall
	
	la $a0, newline	
	li $v0, 4
	syscall
	syscall
	
	j return
	
first_player_remove:
	la $s1, firstPlayerData
	lw $t0, 12($s1)		# number of removes left
	
	bne $t0, 1, continue2
	la $a0, promptRemove
    	li $v0, 4
    	syscall
    	
    	la $a0, promptAskToUse
    	li $v0, 4
    	syscall
    	
    	la $s2, secondPlayerData
	lw $t0, ($s2)		# piece of the opponent
	j process_remove

second_player_remove:
	la $s1, secondPlayerData
	lw $t0, 12($s1)		# number of removes left
	
	bne $t0, 1, continue2
	la $a0, promptRemove
    	li $v0, 4
    	syscall
    	
    	la $a0, promptAskToUse
    	li $v0, 4
    	syscall
    	
    	la $s2, firstPlayerData
	lw $t0, ($s2)		# piece of the opponent
	j process_remove

process_remove:    	
    	li $v0, 12
    	syscall
    	
    	addi $v0, $v0, -48
    	beq $v0, 0, correct_input
    	beq $v0, 1, correct_input
    	
    	la $a0, promptWrongInput
    	li $v0, 4
    	syscall
    	
    	j process_remove
correct_input:    	
    	bne $v0, 1, continue3
    	
    	la $t2, piecesUsed
	lw $t3, ($t2)
	addi $t3, $t3, -1
	sw $t3, ($t2)
	
    	li $t7, 0
    	sw $t7, 12($s1)		# set remove to 0
restart:	
	# if the player get the wrong piece, need to restart this step   	
    	# ask for the coord of the piece you want to remove
    input_row:
    	la $a0, promptR
    	li $v0, 4
    	syscall
    	li $v0, 12
    	syscall
    	
    	blt $v0, 48, input_row
    	bgt $v0, 53, input_row
    	
    	addi $t1, $v0, -48
    
    input_column:
    	la $a0, promptC
    	li $v0, 4
    	syscall
    	li $v0, 12
    	syscall
    	
    	blt $v0, 48, input_column
    	bgt $v0, 54, input_column
    	
    	addi $t2, $v0,-48
    	
    	bge $t1, 6, restart	# row
    	blt $t1, 0, restart
    	bge $t2, 7, restart	# column
    	blt $t2, 0, restart
    	
    	# get to the coord = x + column x 6 + row
    	la $s0, gameboard
    	mul $t3, $t2, 6
    	add $t4, $t3, $t1
    	add $s0, $s0, $t4
    	
    	# extract the piece of this cell
    	lb $t5, ($s0)
    	beq $t5, 45, continue4	# contain '-'
    	beq $t0, 1, getO	# else getX
    	beq $t5, 79, continue4
    	j continue5
getO: 	beq $t5, 88, continue4
continue5:	
	la $a0, promptProceed
    	li $v0, 4
    	syscall
    	
	li $t5, 45
	sb $t5, ($s0)
	
	li $s6, 1	# player choose to remove
	
	beq $t1, 0, exit_remove	# remove at row 0, no pieces need to fall down
    	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
	
	jal pieces_falling_down
	
	lw   $ra, ($sp)
    	addi $sp, $sp, 4     	# adjust stack
    	
    	j exit_remove
    	
pieces_falling_down:
	addi $t4, $t4, -1
	addi $s1, $s0, -1
	lb $t7, ($s1)
	sb $t7, ($s0)
	addi $s0, $s0, -1
	
	bne $t4, $t3, pieces_falling_down
	li $t7, 45
	sb $t7, ($s0)
	jr $ra
continue4:
	la $a0, promptWrongPiece
    	li $v0, 4
    	syscall
	j restart
continue3:
	la $a0, promptNotToUse
    	li $v0, 4
    	syscall
	j exit_remove
continue2:
	la $a0, promptNoRemoveLeft
    	li $v0, 4
    	syscall
	j exit_remove
	
exit_remove:
	jr $ra

	
    	
first_player_undo:
	la $s0, firstPlayerData
	lw $t8, 8($s0)	
	beq $t8, 0, cant_undo
	
	la $a0, promptUndo
    	li $v0, 4
    	syscall
	
	la $a0, promptIs	
	li $v0, 4
	syscall
	
	move $a0, $t8
	li $v0, 1
	syscall
	
	la $a0, newline	
	li $v0, 4
	syscall
    	
    	la $a0, promptAskToUse
    	li $v0, 4
    	syscall
    	
    	j re_input
    	
second_player_undo:
	la $s0, secondPlayerData
	lw $t8, 8($s0)	
	beq $t8, 0, cant_undo
	
	la $a0, promptUndo
    	li $v0, 4
    	syscall
	
	la $a0, promptIs	
	li $v0, 4
	syscall
	
	move $a0, $t8
	li $v0, 1
	syscall
	
	la $a0, newline	
	li $v0, 4
	syscall
    	
    	la $a0, promptAskToUse
    	li $v0, 4
    	syscall
    	
    	j re_input
    	
re_input:  
    	li $v0, 12
	syscall
	
	addi $v0, $v0, -48
    	
    	beq $v0, 0, correct_input1
    	beq $v0, 1, correct_input1
    	
    	la $a0, promptWrongInput
    	li $v0, 4
    	syscall
    	
    	j re_input
correct_input1:  
	bne $v0, 1, not_to_undo	# player choose not to use undo
	
	la $t2, piecesUsed
	lw $t3, ($t2)
	addi $t3, $t3, -1
	sw $t3, ($t2)
	
	addi $t8, $t8, -1 	# decrement number of undos
	sw $t8, 8($s0)		# store it back to playerData
	la $a0, promptSuccessfullyUndo
    	li $v0, 4
    	syscall
    	
	li $t0, 0
	la $s0, gameboard
	la $s1, oldGameboard
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal process_undo
	jal print_game_board
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j exit_undo
	
process_undo:
	lb $t8, ($s1)
	sb $t8, ($s0)
	addi, $s0, $s0, 1
	addi, $s1, $s1, 1
	addi, $t0, $t0, 1
	bne $t0, 42, process_undo
	jr $ra
cant_undo:
	la $a0, promptNoUndoLeft
    	li $v0, 4
    	syscall
    	la $a0, newline
	li $v0, 4 
	syscall
	syscall
    	jr $ra
exit_undo:
	li $t1, 1 	# undo is true
	la $a0, newline
	li $v0, 4 
	syscall
	syscall
	jr $ra
	
not_to_undo:
	la $a0, newline
	li $v0, 4 
	syscall
	syscall
	jr $ra
	

make_a_copy:
	la $s1, copyGameboard
	j duplicate
save_old_state:
	la $s1, oldGameboard
	
	duplicate:
		li $t0, 0
		la $s0, gameboard
	
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal process_duplicate
	
		lw $ra, ($sp)
		addi $sp, $sp, 4
	
		jr $ra
	
	process_duplicate:
		lb $t8, ($s0)
		sb $t8, ($s1)
		addi, $s0, $s0, 1
		addi, $s1, $s1, 1
		addi, $t0, $t0, 1
		bne $t0, 42, process_duplicate
		jr $ra

pre_game:
	# 2 players place their pieces in the middle column (number 3)
	li $t8, 3		# middle column
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
    	la $s1, firstPlayerData
    	lw $t0, ($s1)
    	jal drop_piece
    	
    	la $s1, secondPlayerData
    	lw $t0, ($s1)
    	jal drop_piece
    	
	lw   $ra, ($sp)
    	addi $sp, $sp, 4     	# adjust stack
    	
    	jr $ra

first_player_drop:
	la $a0, promptDropPiece	
	li $v0, 4
	syscall
	
	la $s1, firstPlayerData
    	la $s2, secondPlayerData
    	la $s0,	firstPlayer
	la $s3, secondPlayer
	
	li $v0, 12
	syscall			# column number
	move $t8, $v0
	blt $t8, 48, out_of_bound
	bgt $t8, 54, out_of_bound
	
	addi $t8, $t8, -48
	
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
    	lw $t0, ($s1)
    	jal drop_piece
    	
	lw   $ra, ($sp)
    	addi $sp, $sp, 4     	# adjust stack
    	
    	jr $ra 
    	
second_player_drop:
	la $a0, promptDropPiece	
	li $v0, 4
	syscall
	
	la $s1, secondPlayerData
    	la $s2, firstPlayerData
	la $s0,	secondPlayer 
	la $s3, firstPlayer
	
	li $v0, 12
	syscall			# column number
	move $t8, $v0
	blt $t8, 48, out_of_bound
	bgt $t8, 54, out_of_bound
	
	addi $t8, $t8, -48
	
	
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
    	lw $t0, ($s1)
    	jal drop_piece
    	
	lw   $ra, ($sp)
    	addi $sp, $sp, 4     	# adjust stack
    	
    	jr $ra 
    	
drop_piece:
	li $t3, 0
	la $s5, gameboard
	
	li $t4, 6		# index
	mul $t5, $t4, $t8
	addi $t5, $t5, 5
	add $s5, $s5, $t5
	
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
 
    	jal process_drop_piece
    	
	lw   $ra, ($sp)
    	addi $sp, $sp, 4     	# adjust stack
    	
    	jr $ra 
	
process_drop_piece:
	lb $t6, ($s5)
	
	beq $t4, 0, out_of_bound
	
	addi $s5, $s5, -1
	addi $t4, $t4, -1	# decrement
	bne $t6, 45, process_drop_piece
	addi $s5, $s5, 1
	beq $t0, 1, setO # else setX	
setX:	li $t7, 88
	j continue
setO:	li $t7, 79
continue:	
	sb $t7, ($s5)
	la $s0, piecesUsed
	lw $t7, ($s0)
	addi $t7, $t7, 1
	sw $t7, ($s0)
	j return
	
out_of_bound:
	la $t2, columnIsFull
	li $t9, 1
	sw $t9, ($t2)		# columnIsFull = true
	
	la $a0, promptViolations
	li $v0, 4
	syscall
	
	lw $t9, 4($s1)
	beq $t9, 0, exceed_violations
	addi $t9, $t9, -1
	sw $t9, 4($s1)
	bgt $t9, 0, return
	
	la $a0, promptNoViolations
	li $v0, 4
	syscall
	
	j return
exceed_violations:
	li $t9, 1
	sw $t9, 20($s2)
	jal big_check

# preprocessing data
init_board:
	# initialize the game board to '-'
    	la $s0, gameboard     	# load the address of gameboard into $t0
    	li $t1, 45         	# load the ASCII code for '-' into $t1
    	li $t2, 42           	# load the number of cells in the game board into $t2
	j process_init_board
	
process_init_board:
    	sb $t1, ($s0)        	# store '-' in the current cell
    	addi $s0, $s0, 1     	# move to the next cell
    	addi $t2, $t2, -1     	# decrement the counter
    	bne $t2, 0, process_init_board  # repeat until all cells are initialized
    	jr $ra			# back to main
    	
input:	# Ask for the name of 1st player
	la $a0, prompt16	
	li $v0, 4
	syscall
	
	# move the name of the 1st player to t1
	li $v0, 8
	la $a0, firstPlayer     # load address of input_str into $a0
    	li $a1, 256           # maximum length of input string
	syscall
	
	# Ask for the name of 2nd player
	la $a0, prompt17	
	li $v0, 4
	syscall
	
	# move the name of the 2nd player to t2
	li $v0, 8
	la $a0, secondPlayer     # load address of input_str into $a0
    	li $a1, 256           # maximum length of input string
	syscall
	
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
    	j first_player

first_player:
	
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
	jal random_input
	la $s0, firstPlayerData
	sw $t0, ($s0)
	
	lw   $ra, ($sp)
    	addi $sp, $sp, 4     	# adjust stack
	
second_player:
	xor $t0, $t0, 1
	la $s0, secondPlayerData
	sw $t0, ($s0)
		
end_of_input:
	lw   $ra, ($sp)   	
    	addi $sp, $sp, 4

	jr $ra

random_input:
	li $a1, 2
	li $v0, 42
	syscall
	move $t0, $a0
	
	jr $ra
	
print_game_board:
	li $t8, 0	# index i 
	li $t9, 0	# index j
	la $s0, gameboard
	li $t3, 88	# ASCII code for 'X'
	li $t4, 79	# ASCII code for 'O'
	li $t5, 45	# ASCII code for '-'
	
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
	jal outer_loop
	
	lw   $ra, ($sp)   	
    	addi $sp, $sp, 4
    	jr   $ra

printX:
	la $a0, X	
	li $v0, 4
	syscall
	beq $s7, 1, inner_loop
	beq $s7, 2, second_player
	beq $s7, 3, end_of_input
	
printO:
	la $a0, O	
	li $v0, 4
	syscall
	beq $s7, 1, inner_loop
	beq $s7, 2, second_player
	beq $s7, 3, end_of_input
	
printEmpty:
	la $a0, empty	
	li $v0, 4
	syscall
	beq $s7, 1, inner_loop

inner_loop:
	beq $t9, 7, outer_loop
	lb $t6, ($s1)
	addi $s1, $s1, 6     	# move to the next cell
    	addi $t9, $t9, 1     	# increment j
	
	beq $t6, $t3, printX
	beq $t6, $t4, printO
	beq $t6, $t5, printEmpty
	
outer_loop:
	li $v0, 4
	la $a0, promptBigSpc
	syscall
	add $s1, $s0, $zero	# s1 = s0
	bne $t9, 0, continue1
	move $a0, $t8	
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, spc
	syscall
	la $a0, promptPep	
	syscall
	la $a0, spc
	syscall
	
continue1:	
    	bne $t9, 7, inner_loop
    	li $t9, 0		# index j
    	
	addi $s0, $s0, 1     	# move to the next cell
    	addi $t8, $t8, 1     	# increment i
    	
    	la $a0, newline	
	li $v0, 4
	syscall

	bne $t8, 6, outer_loop
	
	addi $sp, $sp, -4     	# adjust stack
    	sw   $ra, ($sp)
    	
    	li $v0, 4
    	la $a0, spc
	syscall
	syscall
	la $a0, promptBigSpc
	syscall
	la $a0, promptPep
	syscall
	la $a0, promptDLine
	syscall
	syscall
	syscall
	syscall
	syscall
	syscall
	syscall
	la $a0, promptDLine
	syscall
	syscall
	syscall
	la $a0, promptDLine
	syscall
	syscall
	syscall
	la $a0, promptDLine
	syscall
	syscall
	syscall
	la $a0, promptDLine
	syscall
	syscall
	syscall
	la $a0, promptDLine
	syscall
	syscall
	syscall
	la $a0, promptDLine
	syscall
	la $a0, newline
	syscall
	la $a0, promptBigSpc
	syscall
	la $a0, spc
	syscall
	syscall
	syscall
	syscall
	syscall
	li $t0, 0
	jal print_column_number
	
	lw   $ra, ($sp)   	
    	addi $sp, $sp, 4
    	
	jr $ra

print_column_number:
	move $a0, $t0	
	li $v0, 1
	syscall
	
	la $a0, spc	
	li $v0, 4
	syscall
	
	la $a0, spc	
	li $v0, 4
	syscall
	
	addi $t0, $t0, 1
	
	bne $t0, 7, print_column_number
	
	la $a0, newline	
	li $v0, 4
	syscall
	
	jr $ra

perform_checking_row:
	# t0 save piece of player
	# s6 save playerData
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $s4, 0
	
	jal make_a_copy
	lw $t0, ($s6)
	jal check_row	# check on a copy
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 1, return	# already find a chance to win
	beq $s4, 2, return	# player win
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal check_row1	# swap each a single empty cell to players'cell and check for chance to win
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 1, return	# already find a chance to win
	beq $s4, 2, return	# player win
	
	# removal lead to a chance to win
	lw $t9, 12($s6)
	beq $t9, 0, return	# no removals left to use
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal check_row2
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j return
check_row1:
	li $s5, 45
	j continue13
check_row2:
	move $s5, $t8
continue13:
	li $t9, 0
	la $s0, copyGameboard
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal do_check_row1
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j return
	
	do_check_row1:
		lb $t4, ($s0)
		bne $t4, $s5, continue12
	optimize:
		# case last row
		beq $t9, 5, checkLeftRight
		beq $t9, 11, checkLeftRight
		beq $t9, 17, checkLeftRight
		beq $t9, 23, checkLeftRight
		beq $t9, 29, checkLeftRight
		beq $t9, 35, checkLeftRight
		beq $t9, 41, checkLeftRight
		
		addi $s0, $s0, 1
		lb $t4, ($s0)
		beq $t4, 45, increment1	# CHANGE HERE
		addi $s0, $s0, -1
	checkLeftRight:
		addi $s0, $s0, -6
		addi $t9, $t9, -6
		blt $t9, 0, increment2
		lb $t4, ($s0)
		beq $t4, $t0, increment2
		
		addi $s0, $s0, 12
		addi $t9, $t9, 12
		bge $t9, 42, increment3
		lb $t4, ($s0)
		bne $t4, $t0, increment3
		addi $s0, $s0, -6
		addi $t9, $t9, -6
		j continue_perform
	increment1:
		addi $s0, $s0, -1
		j continue12
	increment2:
		addi $s0, $s0, 6
		addi $t9, $t9, 6
		j continue_perform
	increment3:
		addi $s0, $s0, -6
		addi $t9, $t9, -6
		j continue12
	continue_perform:
		lb $t4, ($s0)
		
		bne $t4, 45, continue14			
		# case equal '-'
		move $t4, $t0
		sb $t4, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal add_check_row1
	
		lw $ra, ($sp)
		addi $sp, $sp, 4 
		
		li $t4, 45
		sb $t4, ($s0)
		
		j continue12
		
		# case equal opponent's move
	continue14:
		beq $t9, 0, continue12
		beq $t9, 6, continue12
		beq $t9, 12, continue12
		beq $t9, 18, continue12
		beq $t9, 24, continue12
		beq $t9, 30, continue12
		beq $t9, 36, continue12
		
		addi $s0, $s0, -1
		lb $t4, ($s0)
		addi $s0, $s0, 1
		sb $t4, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal add_check_row1
	
		lw $ra, ($sp)
		addi $sp, $sp, 4 
		
		sb $t8, ($s0)
		
	continue12:
		addi $s0, $s0, 1
		addi $t9, $t9, 1
		bne $t9, 42, do_check_row1
		j return
		
	add_check_row1:
		li $t6, 0	# curMax
		li $t7, 0	# max
	
		li $t3, 0	# counting
		li $t1, 0	# index i
		la $s1, copyGameboard
	
	increment_row1:
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		jal do_do_check_row1
		
		lw $ra, ($sp)
		addi $sp, $sp, 4
	
		beq $s4, 1, return	# already find a chance to win	
	
		addi $t1, $t1, 1
		la $s1, copyGameboard
		add $s1, $s1, $t1	# gameboard[i]
		li $t3, 0		# reset counting
	
		bne $t1, 6, increment_row1
	
		j return
	
		do_do_check_row1:
			lb $t5, ($s1)
		
			addi $sp, $sp, -4
			sw $ra, ($sp)
		
			jal compute_row1
		
			lw $ra, ($sp)
			addi $sp, $sp, 4
		
		
			addi $t3, $t3, 1	# increment count
			addi $s1, $s1, 6
		
			bne $t3, 7, do_do_check_row1
		
			j return
		
	compute_row1:
		bne $t5, $t0, reset_row1
		addi $t6, $t6, 1	# update curMax
		beq $t3, 6, reset_row1	# last index
		j return
	reset_row1:
		bge $t6, 4, cout_chance_to_win_row
		li $t6, 0 	# reset curMax
		j return
		
	
max:	# max between t6, t7
	bgt $t6, $t7, setNewMax
	jr $ra
setNewMax:
	move $t7, $t6	# set new max
	jr $ra

check_row:
	# t0 save piece of player
	li $s4, 0		# did not find chance to win
	beq $t0, 1, getO2	# else getX
    	li $t0, 88
    	li $t8, 79
    	j continue11
getO2: 	li $t0, 79
	li $t8, 88
continue11:
	li $t6, 0	# curMax
	li $t7, 0	# max
	
	li $t3, 0	# counting
	li $t1, 0	# index i
	la $s0, copyGameboard
	
increment_row:
	addi $sp, $sp, -4
	sw $ra, ($sp)
		
	jal do_check_row
		
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 2, return	# player win	
	
	addi $t1, $t1, 1
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	li $t3, 0		# reset counting
	
	bne $t1, 6, increment_row
	
	j return
	
	do_check_row:
		lb $t5, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		jal compute_row
		
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		
		addi $t3, $t3, 1	# increment count
		addi $s0, $s0, 6
		
		bne $t3, 7, do_check_row
		
		j return
		
	compute_row:
		bne $t5, $t0, reset_row
		addi $t6, $t6, 1	# update curMax
		beq $t3, 6, reset_row	# last index
		j return
	reset_row:
		bge $t6, 4, win_state
		beq $t6, 3, check_win_state_row
		li $t6, 0 	# reset curMax
		j return
		
	check_win_state_row:
		beq $t3, 6, continue9		# last index case
		beq $t5, 45, cout_chance_to_win_row
		beq $t3, 3, reset_row_curMax	# first index case
		li $t7, 4
		j continue10
	continue9:
		li $t7, 3
		beq $t5, $t0, continue10
		li $t7, 4
	continue10:
		mul $t7, $t7, 6 	# 4 x 6 = 24 bytes
		sub $s3, $s0, $t7	# move back 24 bytes or gameboard[i][j-4]
		lb $t7, ($s3)
		beq $t7, 45, cout_chance_to_win_row
		j reset_row_curMax		# 3 consecutive pieces but not a chance to win
	
		cout_chance_to_win_row:
			
			# find a chance to win
			li $s4, 1
			sw $s4, 16($s6)
			addi $sp, $sp, -4
			sw $ra, ($sp)
			jal max
			lw $ra, ($sp)
			addi $sp, $sp, 4
			j reset_row_curMax
	win_state:
		li $s4, 1
		sw $s4, 20($s6)
		li $s4, 2
		j return
	reset_row_curMax:
		li $t6, 0 	# reset curMax
		j return
perform_checking_column:
	# t0 save piece of player
	# s6 save playerDat
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $s4, 0
	
	jal make_a_copy
	lw $t0, ($s6)
	jal check_column	# check on a copy
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 1, return	# already find a chance to win
	beq $s4, 2, return	# player win
	lw $zero, 16($s6)
	# removal lead to a chance to win
	lw $t9, 12($s6)
	beq $t9, 0, return	# no removals left to use
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal check_column2
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	lw $zero, 16($s6)
	
	j return
check_column2:
	move $s5, $t8
continue18:
	li $t9, 0
	la $s0, copyGameboard
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal do_check_column2
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j return
	
	do_check_column2:
		lb $t4, ($s0)
		bne $t4, $s5, continue19
	optimize1:
		# case last row and first row will be eliminated
		beq $t9, 5, continue19
		beq $t9, 11, continue19
		beq $t9, 17, continue19
		beq $t9, 23, continue19
		beq $t9, 29, continue19
		beq $t9, 35, continue19
		beq $t9, 41, continue19
		
		beq $t9, 0, continue19
		beq $t9, 6, continue19
		beq $t9, 12, continue19
		beq $t9, 18, continue19
		beq $t9, 24, continue19
		beq $t9, 30, continue19
		beq $t9, 36, continue19
		
		addi $s0, $s0, 1
		lb $t4, ($s0)
		bne $t4, $t0, increment4
		
		addi $s0, $s0, -2
		lb $t4, ($s0)
		bne $t4, $t0, increment5
		addi $s0, $s0, 1
		j continue_perform_column
	increment4:
		addi $s0, $s0, -1
		j continue19
	increment5:
		addi $s0, $s0, 1
		j continue19
		
	continue_perform_column:	
		move $t2, $t9
	loop_column:
		addi $s0, $s0, -1
		lb $t4, ($s0)
		addi $s0, $s0, 1
		sb $t4, ($s0)
		
		addi $s0, $s0, -1
		addi $t2, $t2, -1
		beq $t2, 0, continue21
		beq $t2, 6, continue21
		beq $t2, 12, continue21
		beq $t2, 18, continue21
		beq $t2, 24, continue21
		beq $t2, 30, continue21
		beq $t2, 36, continue21 
		j loop_column
	continue21:
		li $t4, 45
		sb $t4, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal add_check_column2
	
		lw $ra, ($sp)
		addi $sp, $sp, 4 
		
	loop_column2:
		addi $s0, $s0, 1
		lb $t4, ($s0)
		addi $s0, $s0, -1
		sb $t4, ($s0)
		
		addi $s0, $s0, 1
		addi $t2, $t2, 1
		beq $t2, $t9, continue22
		j loop_column2
		
	continue22:
		lb $s5, ($s0)
		
	continue19:
		addi $s0, $s0, 1
		addi $t9, $t9, 1
		bne $t9, 42, do_check_column2
		j return
		
	add_check_column2:
		li $t6, 0	# curMax
		li $t7, 0	# max
	
		li $t3, 0	# counting
		li $t1, 0	# index i
		la $s1, copyGameboard
	
	increment_column2:
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		jal do_do_check_column2
		
		lw $ra, ($sp)
		addi $sp, $sp, 4
	
		beq $s4, 1, return	# already find a chance to win	
	
		addi $t1, $t1, 6
		la $s1, copyGameboard
		add $s1, $s1, $t1	# gameboard[i]
		li $t3, 0		# reset counting
	
		bne $t1, 42, increment_column2
	
		j return
	
		do_do_check_column2:
			lb $t5, ($s1)
		
			addi $sp, $sp, -4
			sw $ra, ($sp)
		
			jal compute_column2
		
			lw $ra, ($sp)
			addi $sp, $sp, 4
		
		
			addi $t3, $t3, 1	# increment count
			addi $s1, $s1, 1
		
			bne $t3, 6, do_do_check_column2
		
			j return
		
	compute_column2:
		bne $t5, $t0, reset_column2
		addi $t6, $t6, 1	# update curMax
		beq $t3, 5, reset_column2	# last index
		j return
	reset_column2:
		bge $t6, 4, cout_chance_to_win_column
		li $t6, 0 	# reset curMax
		j return
		
check_column:
	# t0 save piece of player
	li $s4, 0		# did not find chance to win
	beq $t0, 1, getO4	# else getX
    	li $t0, 88
    	li $t8, 79
    	j continue15
getO4: 	li $t0, 79
	li $t8, 88
continue15:
	li $t6, 0	# curMax
	li $t7, 0	# max
	
	li $t3, 0	# counting
	li $t1, 0	# index i
	la $s0, copyGameboard
	
increment_column:
	addi $sp, $sp, -4
	sw $ra, ($sp)
		
	jal do_check_column
		
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 2, return	# player win	
	
	addi $t1, $t1, 6
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	li $t3, 0		# reset counting
	
	bne $t1, 42, increment_column
	
	j return
	
	do_check_column:
		lb $t5, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		jal compute_column
		
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		
		addi $t3, $t3, 1	# increment count
		addi $s0, $s0, 1
		
		bne $t3, 6, do_check_column
		
		j return
		
	compute_column:
		bne $t5, $t0, reset_column
		addi $t6, $t6, 1		# update curMax
		beq $t3, 5, reset_column	# last index
		j return
	reset_column:
		bge $t6, 4, win_state
		beq $t6, 3, check_win_state_column
		li $t6, 0 	# reset curMax
		j return
		
	check_win_state_column:
		beq $t3, 5, continue16		# last index case
		beq $t5, 45, cout_chance_to_win_column
		beq $t3, 3, reset_column_curMax	# first index case
		li $t7, 4
		j continue17
	continue16:
		li $t7, 3
		beq $t5, $t0, continue17
		li $t7, 4
	continue17:
		sub $s3, $s0, $t7	# move back 24 bytes or gameboard[i][j-4]
		lb $t7, ($s3)
		beq $t7, 45, cout_chance_to_win_column
		j reset_column_curMax		# 3 consecutive pieces but not a chance to win
	
		cout_chance_to_win_column:
			# find a chance to win
			li $s4, 1
			sw $s4, 16($s6)
			addi $sp, $sp, -4
			sw $ra, ($sp)
			jal max
			lw $ra, ($sp)
			addi $sp, $sp, 4
			j reset_column_curMax
	reset_column_curMax:
		li $t6, 0 	# reset curMax
		j return

perform_sub_diagonal:
	# t0 save piece of player
	# s6 save playerData
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $s4, 0
	
	jal make_a_copy
	lw $t0, ($s6)
	jal check_sub_diagonal	# check on a copy
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 1, return	# already find a chance to win
	beq $s4, 2, return	# player win
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal check_sub_diagonal1	# swap each a single empty cell to players'cell and check for chance to win
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 1, return	# already find a chance to win
	beq $s4, 2, return	# player win
	
	# removal lead to a chance to win
	lw $t9, 12($s6)
	beq $t9, 0, return	# no removals left to use
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal check_sub_diagonal2
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j return
check_sub_diagonal1:
	li $s5, 45
	j continue46
check_sub_diagonal2:
	move $s5, $t8
continue46:
	li $t9, 0
	la $s0, copyGameboard
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal do_check_sub_diagonal1
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j return
	
	do_check_sub_diagonal1:
		lb $t4, ($s0)
		bne $t4, $s5, continue42
	optimize4:
		# case first row will be eliminated
		beq $t9, 0, continue42
		beq $t9, 6, continue42
		beq $t9, 12, continue42
		beq $t9, 18, continue42
		beq $t9, 24, continue42
		beq $t9, 30, continue42
		beq $t9, 36, continue42
		beq $t4, 45, checkDown	
	checkUp:
		addi $s0, $s0, -1
		lb $t4, ($s0)
		bne $t4, $t0, caseX45
		addi $s0, $s0, 1
		j continue_perform_sub_diagonal
	checkDown:
		addi $s0, $s0, 1
		lb $t4, ($s0)
		bne $t4, $t0, caseXopponent
		addi $s0, $s0, -1
	continue_perform_sub_diagonal:
		lb $t4, ($s0)
		bne $t4, 45, continue43			
		# case equal '-'
		move $t4, $t0
		sb $t4, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal add_check_sub_diagonal1
	
		lw $ra, ($sp)
		addi $sp, $sp, 4 
		
		li $t4, 45
		sb $t4, ($s0)
		
		j continue42
		
		# case equal opponent's move
	continue43:
		addi $s0, $s0, -1
		lb $t4, ($s0)
		addi $s0, $s0, 1
		sb $t4, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal add_check_sub_diagonal1
	
		lw $ra, ($sp)
		addi $sp, $sp, 4 
		
		sb $t8, ($s0)
		j continue42
	caseXopponent:
		addi $s0, $s0, -1
		j continue42
	caseX45:
		addi $s0, $s0, 1	
	continue42:
		addi $s0, $s0, 1
		addi $t9, $t9, 1
		bne $t9, 42, do_check_sub_diagonal1
		j return
		
	add_check_sub_diagonal1:
		li $t6, 0	# curMax
		li $t7, 0	# max
		case1_1:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 35		# counting
			li $t1, 0		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_sub_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		case1_2:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 29		# counting
			li $t1, 1		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_sub_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		case1_3:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 23		# counting
			li $t1, 2		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_sub_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		case1_4:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 41		# counting
			li $t1, 6		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_sub_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		case1_5:
			addi $sp, $sp, -4
			sw $ra, ($sp)
				
			li $t3, 40		# counting
			li $t1, 12		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_sub_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		case1_6:
			addi $sp, $sp, -4
			sw $ra, ($sp)
				
			li $t3, 39		# counting
			li $t1, 18		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_sub_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		
		j return
	
		do_do_check_sub_diagonal1:
			lb $t5, ($s1)
		
			addi $sp, $sp, -4
			sw $ra, ($sp)
		
			jal compute_sub_diagonal1
		
			lw $ra, ($sp)
			addi $sp, $sp, 4
		
			addi $t3, $t3, -7	# increment count
			addi $s1, $s1, 7
			addi $s2, $s2, 1
			
			bge $t3, $t1, do_do_check_sub_diagonal1
		
			j return
		
	compute_sub_diagonal1:
		bne $t5, $t0, reset_sub_diagonal1
		addi $t6, $t6, 1			# update curMax
		beq $t3, $t1, reset_sub_diagonal1	# last index
		j return
	reset_sub_diagonal1:
		bge $t6, 4, cout_chance_to_win_sub_diagonal
		li $t6, 0 	# reset curMax
		j return
		
check_sub_diagonal:
	# t0 save piece of player
	li $s4, 0		# did not find chance to win
	beq $t0, 1, getO6	# else getX
    	li $t0, 88
    	li $t8, 79
    	j continue45
getO6: 	li $t0, 79
	li $t8, 88
continue45:
	li $t6, 0	# curMax
	li $t7, 0	# max
case1:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 35		# counting
	li $t1, 0		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]	
	jal do_check_sub_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
case2:		
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 29		# counting
	li $t1, 1		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_sub_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
case3:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 23		# counting
	li $t1, 2		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_sub_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
case4:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 41		# counting
	li $t1, 6		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_sub_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
case5:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 40		# counting
	li $t1, 12		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_sub_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
case6:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 39		# counting
	li $t1, 18		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_sub_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
	
	j return
	
	do_check_sub_diagonal:
		lb $t5, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		jal compute_sub_diagonal
		
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		
		addi $t3, $t3, -7	# increment count
		addi $s0, $s0, 7
		addi $s2, $s2, 1
		
		bge $t3, $t1, do_check_sub_diagonal
		
		j return
		
	compute_sub_diagonal:
		bne $t5, $t0, reset_sub_diagonal
		addi $t6, $t6, 1			# update curMax
		beq $t3, $t1, reset_sub_diagonal	# last index
		j return
	reset_sub_diagonal:
		bge $t6, 4, win_state
		beq $t6, 3, check_win_state_sub_diagonal
		li $t6, 0 	# reset curMax
		j return
		
	check_win_state_sub_diagonal:
		beq $t3, $t1, continue40			# last index case
		beq $t5, 45, cout_chance_to_win_sub_diagonal
		beq $s2, 3, reset_sub_diagonal_curMax	# first index case
		li $t7, 4
		j continue41
	continue40:
		li $t7, 3
		beq $t5, $t0, continue41
		li $t7, 4
	continue41:
		mul $t7, $t7, 7 	# 4 x 7 = 28 bytes
		sub $s3, $s0, $t7	# move back 28 bytes or gameboard[i-4][j-4]
		lb $t7, ($s3)
		beq $t7, 45, cout_chance_to_win_sub_diagonal
		j reset_sub_diagonal_curMax		# 3 consecutive pieces but not a chance to win
	
		cout_chance_to_win_sub_diagonal:
			
			# find a chance to win
			li $s4, 1
			sw $s4, 16($s6)
			addi $sp, $sp, -4
			sw $ra, ($sp)
			jal max
			lw $ra, ($sp)
			addi $sp, $sp, 4
			j reset_sub_diagonal_curMax
	reset_sub_diagonal_curMax:
		li $t6, 0 	# reset curMax
		j return
	
perform_main_diagonal:
	# t0 save piece of player
	# s6 save playerData
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $s4, 0
	
	jal make_a_copy
	lw $t0, ($s6)
	jal check_main_diagonal	# check on a copy
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 1, return	# already find a chance to win
	beq $s4, 2, return	# player win
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal check_main_diagonal1	# swap each a single empty cell to players'cell and check for chance to win
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $s4, 1, return	# already find a chance to win
	beq $s4, 2, return	# player win
	
	# removal lead to a chance to win
	lw $t9, 12($s6)
	beq $t9, 0, return	# no removals left to use
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal check_main_diagonal2
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j return
check_main_diagonal1:
	li $s5, 45
	j continue56
check_main_diagonal2:
	move $s5, $t8
continue56:
	li $t9, 0
	la $s0, copyGameboard
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	jal do_check_main_diagonal1
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j return
	
	do_check_main_diagonal1:
		lb $t4, ($s0)
		bne $t4, $s5, continue52
	optimize5:
		# caseMain first row will be eliminated
		beq $t9, 0, continue52
		beq $t9, 6, continue52
		beq $t9, 12, continue52
		beq $t9, 18, continue52
		beq $t9, 24, continue52
		beq $t9, 30, continue52
		beq $t9, 36, continue52
		beq $t4, 45, checkDown_main	
		
		addi $s0, $s0, -1
		lb $t4, ($s0)
		bne $t4, $t0, caseMainX45
		addi $s0, $s0, 1
		j continue_perform_main_diagonal
	checkDown_main:
		addi $s0, $s0, 1
		lb $t4, ($s0)
		bne $t4, $t0, caseMainXopponent
		addi $s0, $s0, -1
	continue_perform_main_diagonal:
		lb $t4, ($s0)
		bne $t4, 45, continue53			
		# caseMain equal '-'
		move $t4, $t0
		sb $t4, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal add_check_main_diagonal1
	
		lw $ra, ($sp)
		addi $sp, $sp, 4 
		
		li $t4, 45
		sb $t4, ($s0)
		
		j continue52
		
		# caseMain equal opponent's move
	continue53:
		addi $s0, $s0, -1
		lb $t4, ($s0)
		addi $s0, $s0, 1
		sb $t4, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
	
		jal add_check_main_diagonal1
	
		lw $ra, ($sp)
		addi $sp, $sp, 4 
		
		sb $t8, ($s0)
		j continue52
	caseMainXopponent:
		addi $s0, $s0, -1
		j continue52
	caseMainX45:
		addi $s0, $s0, 1	
	continue52:
		addi $s0, $s0, 1
		addi $t9, $t9, 1
		bne $t9, 42, do_check_main_diagonal1
		j return
		
	add_check_main_diagonal1:
		li $t6, 0	# curMax
		li $t7, 0	# max
		caseMain1_1:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 30		# counting
			li $t1, 5		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_main_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		caseMain1_2:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 24		# counting
			li $t1, 4		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_main_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		caseMain1_3:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 18		# counting
			li $t1, 3		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_main_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		caseMain1_4:	
			addi $sp, $sp, -4
			sw $ra, ($sp)
			
			li $t3, 36		# counting
			li $t1, 11		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_main_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		caseMain1_5:
			addi $sp, $sp, -4
			sw $ra, ($sp)
				
			li $t3, 37		# counting
			li $t1, 17		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_main_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		caseMain1_6:
			addi $sp, $sp, -4
			sw $ra, ($sp)
				
			li $t3, 38		# counting
			li $t1, 23		# index i
			li $s2, 0		# another counting
			la $s1, copyGameboard
			add $s1, $s1, $t1	# gameboard[i]	
			jal do_do_check_main_diagonal1
			
			lw $ra, ($sp)
			addi $sp, $sp, 4
			beq $s4, 1, return	# already find a chance to win	
		
		j return
	
		do_do_check_main_diagonal1:
			lb $t5, ($s1)
		
			addi $sp, $sp, -4
			sw $ra, ($sp)
		
			jal compute_main_diagonal1
		
			lw $ra, ($sp)
			addi $sp, $sp, 4
		
			addi $t3, $t3, -5	# increment count
			addi $s1, $s1, 5
			addi $s2, $s2, 1
			
			bge $t3, $t1, do_do_check_main_diagonal1
		
			j return
		
	compute_main_diagonal1:
		bne $t5, $t0, reset_main_diagonal1
		addi $t6, $t6, 1			# update curMax
		beq $t3, $t1, reset_main_diagonal1	# last index
		j return
	reset_main_diagonal1:
		bge $t6, 4, cout_chance_to_win_main_diagonal
		li $t6, 0 	# reset curMax
		j return
		
check_main_diagonal:
	# t0 save piece of player
	li $s4, 0		# did not find chance to win
	beq $t0, 1, getO7	# else getX
    	li $t0, 88
    	li $t8, 79
    	j continue55
getO7: 	li $t0, 79
	li $t8, 88
continue55:
	li $t6, 0	# curMax
	li $t7, 0	# max
caseMain1:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 30		# counting
	li $t1, 5		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]	
	jal do_check_main_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
caseMain2:		
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 24		# counting
	li $t1, 4		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_main_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
caseMain3:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 18		# counting
	li $t1, 3		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_main_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
caseMain4:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 36		# counting
	li $t1, 11		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_main_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
caseMain5:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 37		# counting
	li $t1, 17		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_main_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
caseMain6:	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t3, 38		# counting
	li $t1, 23		# index i
	li $s2, 0		# another counting
	la $s0, copyGameboard
	add $s0, $s0, $t1	# gameboard[i]
	jal do_check_main_diagonal
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	beq $s4, 2, return	# player win
	j return
	
	do_check_main_diagonal:
		lb $t5, ($s0)
		
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		jal compute_main_diagonal
		
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		
		addi $t3, $t3, -5	# increment count
		addi $s0, $s0, 5
		addi $s2, $s2, 1
		
		bge $t3, $t1, do_check_main_diagonal
		
		j return
		
	compute_main_diagonal:
		bne $t5, $t0, reset_main_diagonal
		addi $t6, $t6, 1			# update curMax
		beq $t3, $t1, reset_main_diagonal	# last index
		j return
	reset_main_diagonal:
		bge $t6, 4, win_state
		beq $t6, 3, check_win_state_main_diagonal
		li $t6, 0 	# reset curMax
		j return
		
	check_win_state_main_diagonal:
		beq $t3, $t1, continue50			# last index caseMain
		beq $t5, 45, cout_chance_to_win_main_diagonal
		beq $s2, 3, reset_main_diagonal_curMax	# first index caseMain
		li $t7, 4
		j continue51
	continue50:
		li $t7, 3
		beq $t5, $t0, continue51
		li $t7, 4
	continue51:
		mul $t7, $t7, 5 	# 4 x 5 = 20 bytes
		sub $s3, $s0, $t7	# move back 28 bytes or gameboard[i-4][j-4]
		lb $t7, ($s3)
		beq $t7, 45, cout_chance_to_win_main_diagonal
		j reset_main_diagonal_curMax		# 3 consecutive pieces but not a chance to win
	
		cout_chance_to_win_main_diagonal:
			
			# find a chance to win
			li $s4, 1
			sw $s4, 16($s6)
			addi $sp, $sp, -4
			sw $ra, ($sp)
			jal max
			lw $ra, ($sp)
			addi $sp, $sp, 4
			j reset_main_diagonal_curMax
	reset_main_diagonal_curMax:
		li $t6, 0 	# reset curMax
		j return

	
big_check:
	# s1, s2, s0, s3
	lw $t1, 20($s1)
	lw $t2, 20($s2)
	add $t3, $t1, $t2
	ble $t3, 0, check_chance_to_win_state
	
	beq $t1, $t2, print_tie_game
	move $s5, $s0
	beq $t1, 1, print_you_win
	move $s5, $s3
	beq $t2, 1, print_you_win
	
check_chance_to_win_state:
	lw $t1, 16($s1)
	lw $t2, 16($s2)
	add $t3, $t1, $t2
	ble $t3, 0, maybe_tie_game
	
	beq $t1, $t2, print_both
	move $s5, $s0
	beq $t1, 1, print_chance_to_win
	move $s5, $s3
	beq $t2, 1, print_chance_to_win
maybe_tie_game:
	la $t3, piecesUsed
	lw $t4, ($t3)
	
	bge $t4, 41, print_tie_game
	j return
print_you_win:
	la $a0, promptCongrats	
	li $v0, 4
	syscall
	move $a0, $s5
	syscall
	la $a0, promptWin
	syscall
	j exit
print_tie_game:
	la $a0, promptTie	
	li $v0, 4
	syscall
	j exit
print_both:
	la $a0, promptBoth	
	li $v0, 4
	syscall
	j return
print_chance_to_win:
	la $a0, promptChanceToWin	
	li $v0, 4
	syscall
	move $a0, $s5
	syscall
	j return
first_player_check:
		# check 
	addi $sp, $sp, -4
	sw $ra, ($sp)
		la $s0, temp 	
		sw $zero, ($s0)
		la $s6, firstPlayerData
		jal perform_checking_row
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, firstPlayerData
		jal perform_checking_column
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, firstPlayerData
		jal perform_sub_diagonal
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, firstPlayerData
		jal perform_main_diagonal
		
		la $s0, temp 		
		lw $t9, ($s0)
		add $t9, $t9, $s4
		bne $t9, 0, continue30
		sw $t9, 16($s6)
	continue30:
		la $s0, temp 	
		sw $zero, ($s0)
		
		la $s6, secondPlayerData
		jal perform_checking_row
		
		la $s0, temp 		
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, secondPlayerData
		jal perform_checking_column
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, secondPlayerData
		jal perform_sub_diagonal
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, secondPlayerData
		jal perform_main_diagonal
	
		la $s0, temp 		
		lw $t9, ($s0)
		add $t9, $t9, $s4
	lw $ra, ($sp)
	addi $sp, $sp, 4
		bne $t9, 0, return
		sw $t9, 16($s6)
		j return	
second_player_check:
	# check 
	addi $sp, $sp, -4
	sw $ra, ($sp)
		la $s0, temp 	
		sw $zero, ($s0)
		la $s6, secondPlayerData
		jal perform_checking_row
		
		la $s0, temp 		
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, secondPlayerData
		jal perform_checking_column
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, secondPlayerData
		jal perform_sub_diagonal
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, secondPlayerData
		jal perform_main_diagonal
		
		la $s0, temp 		
		lw $t9, ($s0)
		add $t9, $t9, $s4
		bne $t9, 0, continue32
		sw $t9, 16($s6)
	continue32:	
		la $s0, temp 	
		sw $zero, ($s0)
		la $s6, firstPlayerData
		jal perform_checking_row
		
		la $s0, temp 		
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, firstPlayerData
		jal perform_checking_column
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, firstPlayerData
		jal perform_sub_diagonal
		
		la $s0, temp
		lw $t9, ($s0)
		add $t9, $t9, $s4
		sw $t9, ($s0)
		la $s6, firstPlayerData
		jal perform_main_diagonal
		
		la $s0, temp 		
		lw $t9, ($s0)
		add $t9, $t9, $s4
		
	lw $ra, ($sp)
	addi $sp, $sp, 4
		bne $t9, 0, return
		sw $t9, 16($s6)	
		j return
exit:
	li $v0, 10
	syscall
	
	
	
	
	
	
	
	
