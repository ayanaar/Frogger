#####################################################################
#
# Frogger Assembly Final Project
#
 # Bitmap Display Configuration:
 # - Unit width in pixels: 8
 # - Unit height in pixels: 8
 # - Display width in pixels: 256
 # - Display height in pixels: 256
 # - Base Address for Display: 0x10008000 ($gp)
 #
#
# Features that have been implemented:
# 
# 1. Make a second level that starts after the
#	player completes the first level.
# 2. Add sound effects for movement, collisions, game end and reaching the goal area.

# 3. Display a death/respawn animation each time the player loses a frog.

# 4. After final player death, display game over/retry screen. Restart the game if the “retry” option is chose

#5. Display the number of lives remaining

#6. Add a third row in each of the water and road sections.

#
#####################################################################
.data
displayAddress: .word 0x10008000
# Below are the colours I will use:
alive_frog: .word 0xff3c8b
dead_frog: .word 0x000000
winningning_frog: .word 0xe0004f
turtle_colour: .word 0x0b7c00
green: .word 0x2ef414
purple: .word 0x780090
grey: .word 0x858585
yellow: .word 0xffe53c
blue: .word 0x285dff
red: .word 0x996600
diecolour: .word 0x000000
square_lives: .word 0x0d0d0d

# Below are the positions and areas of objects that I will use:
log_3_x_coord: .word 96 
log_3_y_coord: .word 8 
log_first_x_coord: .word 16 
log_first_y_coord: .word 16 
log_second_x_coord: .word 96 
log_second_y_coord: .word 24 

# Multiples of 4
frog_x_coord: .word 64 
frog_y_coord: .word 56 
h: .word 64

car_first_x_coord: .word 0  
car_first_y_coord: .word 40 
car_second_x_coord: .word 96 
car_second_y_coord: .word 48 

number_of_deaths: .word 0 
winning: .word 0 
game_speed: .word 1500

retry_screen_text: .asciiz "Press 'r' to Restart, Press 'e' to Exit \n"

.text
lw $s0, displayAddress # $s0 stores the base address for display

main_game_loop:

checker_for_input:
lw $t8, 0xffff0000
beq $t8, 1, keyboard_input

checker_for_collisions: 
	j check_for_collisions

redrawing_screen: 
	j drawing

Wait: 
	li $v0, 32
	lw $a0, game_speed
	syscall

	lw $t6, number_of_deaths
	li $t3, 3
	beq $t6, $t3, Retry_Screen

return_to_loop: j main_game_loop

drawing:
# This is the winning area
	lw $t3, winning
	beqz $t3, last_safe_zone
	lw $t0 frog_x_coord
	li $t1 0
	lw $t6 h
	mult $t1, $t6
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	lw $a0, winningning_frog
	jal Froggy_Function

# Drawing the last safe zone
last_safe_zone: 
	addi $a1, $s0, 0  
	addi $a2, $a1, 512 
	lw $a0, green
	jal Rectangle_Function

	# Drawing lives on the top right corner
	lw $a0, square_lives
	lw $a1, number_of_deaths

	beqz $a1, three_lives_left
	li $t1, 1
	beq $a1, $t1, two_lives_left
	li $t1, 2
	beq $a1, $t1, last_life
	li $t1, 3
	beq $a1, $t1, water

last_life: 
	sw $a0, 124($s0)
	j water
two_lives_left: 
	sw $a0, 116($s0)
	sw $a0, 124($s0)
	j water
three_lives_left: 
	sw $a0, 108($s0)
	sw $a0, 116($s0)
	sw $a0, 124($s0)

# Drawing the logs and water
water: 
	addi $a1, $s0, 512 
	addi $a2, $a1, 512  
	lw $a0, red
	jal Rectangle_Function

	addi $a1, $s0, 1024 
	addi $a2, $a1, 512  
	lw $a0, turtle_colour
	jal Rectangle_Function

	addi $a1, $s0, 1536 
	addi $a2, $a1, 512  
	lw $a0, red
	jal Rectangle_Function

# The first row of logs
log_5: 
	lw $t0 log_3_x_coord
	lw $t1 log_3_y_coord
	lw $t2 h
	mult $t1, $t2
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $a3, 32
	li $v0, 96
	lw $a0, blue
	jal Other_Rectangle_Function

log_6: 
	sub $t3, $t3, 64
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $s1, 32
	li $v0, 128
	sub $s2, $t0, $s1
	slti $s3, $s2, 32 
x_coord_start: 
	bnez $s3, wrapping_5
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function
	j log_1
wrapping_5: 
	sub $a3, $t0, $s1  
	sub $v0, $v0, $a3  
	add $a1, $s0, 512
	addi $a2, $a1, 512
	jal Other_Rectangle_Function
	sub $a3, $s1, $a3 
	li $v0, 128
	sub $v0, $v0, $a3 
	li $s3, 512
	add $s3, $s3, $v0
	add $a1, $s0, $s3 
	addi $a2, $a1, 512
	jal Other_Rectangle_Function

log_1: 
	lw $t0 log_first_x_coord
	lw $t1 log_first_y_coord
	lw $t6 h
	mult $t1, $t6
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	lw $a0, blue
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function

log_2: 
	add $t3, $t3, 64
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $s1, 32
	li $v0, 128
	sub $s2, $t0, $s1
	slti $s3, $s2, 0
beginning_of_it: 
	beqz $s3, wrapping_1
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function
	j log_3
wrapping_1: 
	sub $a3, $s1, $s2  
	sub $v0, $v0, $a3  
	jal Other_Rectangle_Function
	add $a1, $s0, 1024
	addi $a2, $a1, 512
	add $a3, $zero, $s2  
	li $v0, 128
	sub $v0, $v0, $s2 
	jal Other_Rectangle_Function

log_3: 
	lw $t0 log_second_x_coord
	lw $t1 log_second_y_coord
	lw $t6 h
	mult $t1, $t6
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function

log_4: 
	sub $t3, $t3, 64
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $s1, 32
	li $v0, 128
	sub $s2, $t0, $s1
	slti $s3, $s2, 32 
beginning_2: 
	bnez $s3, wrapping_2
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function
	j middle_safe_zone
wrapping_2: 
	sub $a3, $t0, $s1  
	sub $v0, $v0, $a3 
	add $a1, $s0, 1536
	addi $a2, $a1, 512
	jal Other_Rectangle_Function
	sub $a3, $s1, $a3 
	li $v0, 128
	sub $v0, $v0, $a3
	li $s3, 1536
	add $s3, $s3, $v0
	add $a1, $s0, $s3 
	addi $a2, $a1, 512
	jal Other_Rectangle_Function

# Middle Safe Zone
middle_safe_zone: 
	addi $a1, $s0, 2048 
	addi $a2, $a1, 512 
	lw $a0, purple
	jal Rectangle_Function

# Vehicles
road_zone: 
	addi $a1, $s0, 2560
	addi $a2, $a1, 1024 
	lw $a0, grey
	jal Rectangle_Function

car_1: 
	lw $t0 car_first_x_coord
	lw $t1 car_first_y_coord
	lw $t6 h
	mult $t1, $t6
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	lw $a0, yellow
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function

car_2: 
	add $t3, $t3, 64
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $s1, 32
	li $v0, 128
	sub $s2, $t0, $s1
	slti $s3, $s2, 0
beginning_3: 
	beqz $s3, wrapping_3
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function
	j car_3
wrapping_3: 
	sub $a3, $s1, $s2 
	sub $v0, $v0, $a3  
	jal Other_Rectangle_Function
	add $a1, $s0, 2560 
	addi $a2, $a1, 512
	add $a3, $zero, $s2  
	li $v0, 128
	sub $v0, $v0, $s2 
	jal Other_Rectangle_Function

car_3: 
	lw $t0 car_second_x_coord
	lw $t1 car_second_y_coord
	lw $t6 h
	mult $t1, $t6
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function

car_4: 
	sub $t3, $t3, 64
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $s1, 32
	li $v0, 128
	sub $s2, $t0, $s1
	slti $s3, $s2, 32
beginning_4: 
	bnez $s3, wrapping_4
	li $a3, 32
	li $v0, 96
	jal Other_Rectangle_Function
	j first_safe_zone
wrapping_4: 
	sub $a3, $t0, $s1
	sub $v0, $v0, $a3  
	add $a1, $s0, 3072
	addi $a2, $a1, 512
	jal Other_Rectangle_Function
	sub $a3, $s1, $a3 
	li $v0, 128
	sub $v0, $v0, $a3
	li $s3, 3072
	add $s3, $s3, $v0
	add $a1, $s0, $s3 
	addi $a2, $a1, 512
	jal Other_Rectangle_Function

# First Safe Zone
first_safe_zone: 
	addi $a1, $s0, 3584 
	addi $a2, $a1, 512 
	lw $a0, green
	jal Rectangle_Function

# Drawing the frog
drawing_frog: 
	lw $t0 frog_x_coord
	lw $t1 frog_y_coord
	lw $t6 h
	mult $t1, $t6
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	li $t3, 8
	lw $a0, alive_frog
	jal Froggy_Function

# Updating the vehicle and log positions
vehicle_row_1:
	lw $t0 log_first_x_coord
	la $t7 car_first_x_coord
	la $t8 log_first_x_coord
	li $t9 60
	beq $t0, $t9, return_back
	addi $t0, $t0, 4
	sw $t0, 0($t8)
	sw $t0, 0($t7)
	j vehicle_row_2
return_back: 
	sw $zero, 0($t8)
	sw $zero, 0($t7)
	j vehicle_row_2

vehicle_row_2:
	lw $t0 log_second_x_coord
	la $t7 car_second_x_coord
	la $t8 log_second_x_coord
	la $t2 log_3_x_coord
	li $t9 36
	beq $t0, $t9, shift_up
	subi $t0, $t0, 4
	sw $t0, 0($t8)
	sw $t0, 0($t7)
	sw $t0, 0($t2)
	j winning_zone
shift_up: 
	li $t0, 96
	sw $t0, 0($t8)
	sw $t0, 0($t7)
	sw $t0, 0($t2)
	j winning_zone

# Drawing final goal area
winning_zone: 
	lw $t3, winning
	beq $t3, $zero, w
	lw $t0 frog_x_coord
	li $t1 0
	lw $t6 h
	mult $t1, $t6
	mfhi $t4
	mflo $t5
	add $t3, $t4, $t0 
	add $t3, $t3, $t5
	add $a1, $s0, $t3
	addi $a2, $a1, 512
	lw $a0, winningning_frog
	jal Froggy_Function
	la $t3, winning
	sw $zero, 0($t3)

w: j Wait

keyboard_input: 
	addi $t8, $zero, 0
	lw $t2, 0xffff0004
	beq $t2, 0x77, respond_to_w
	beq $t2, 0x73, respond_to_s
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x64, respond_to_d
	j check_for_collisions

respond_to_w:
	lw $t0 frog_y_coord 
	la $t8 frog_y_coord
	beqz $t0, colouring
	subi $t0, $t0, 8
	sw $t0, 0($t8)
	li $t2, 0

	li $a0, 25 # sound
	li $a1, 4000 #time
	li $a2, 90 #instrument
	li $a3, 120 #volume
	li $v0, 31     
	syscall
	j check_for_collisions
colouring: 
	li $t0, 56
	sw $t0, 0($t8)
	la $t3, winning
	li $t0, 1
	sw $t0, 0($t3)
	la $t3, number_of_deaths
	sw $zero, 0($t3)
	li $a0, 33  # sound
	li $a1, 5000
	li $a2, 85
	li $a3, 127
	li $v0, 31     
	syscall

	lw $a0, game_speed
	la $t0, game_speed
	subi $a0, $a0, 500
	beq $a0, 500, re
	sw $a0, 0($t0)
	j redrawing_screen

re:
	li $a0, 500
	sw $a0, 0($t0)
	j redrawing_screen


respond_to_s:
	lw $t0 frog_y_coord
	la $t8 frog_y_coord
	li $t3, 56
	beq $t0, $t3, redo2
	addi $t0, $t0, 8
	sw $t0, 0($t8)
	li $t2, 0

	li $a0, 44  # sound
	li $a1, 1000 #time
	li $a2, 97 #instrument
	li $a3, 120 #volume
	li $v0, 31      
	syscall
redo2: j check_for_collisions

respond_to_a:
	lw $t0 frog_x_coord
	la $t8 frog_x_coord
	beq $t0, $zero, redo3
	subi $t0, $t0, 16
	sw $t0, 0($t8)
	li $t2, 0

	li $a0, 44  # sound
	li $a1, 1000 #time
	li $a2, 97 #instrument
	li $a3, 120 #volume
	li $v0, 31      
	syscall
redo3: j check_for_collisions


respond_to_d:
	lw $t0 frog_x_coord
	la $t8 frog_x_coord
	li $t3, 112
	beq $t0, $t3, redo4
	addi $t0, $t0, 16
	sw $t0, 0($t8)
	li $t2, 0

	li $a0, 44  # sound
	li $a1, 1000
	li $a2, 97
	li $a3, 120
	li $v0, 31    
	syscall
redo4: j check_for_collisions


# Checking for collisions
check_for_collisions:
	la $t8 frog_y_coord
	lw $t0, frog_y_coord
	lw $t1, car_first_y_coord
	lw $t2, log_first_y_coord 
	lw $t3, car_second_y_coord 
	lw $t4, log_second_y_coord 
	lw $t9, log_3_y_coord
	beq $t0, $t1, car_1_collision
	beq $t0, $t2, top_row_log
	beq $t0, $t3, bottom_row_of_car
	beq $t0, $t4, last_row_logs
	beq $t0, $t9, last_row_of_logs
	j redrawing_screen


# The first row of cars:
car_1_collision: 
	lw $t0, frog_x_coord 
	lw $t1, car_first_x_coord 
	addi $t2, $t1, 32 
	addi $t4, $t1, 96 

	slti $s1, $t1, 32 
	bnez $s1, double_check 

	addi $t3, $t2, 16 
	addi $t5, $t4, 16 

	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0 
	beqz $s1, helper_1
	bnez $s2, helper_1
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	
	li $a0, 100  # sound
	li $a1, 1000
	li $a2, 90
	li $a3, 120
	li $v0, 31     
	syscall
	j redrawing_screen


helper_1: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0 
	beqz $s1, helper_2
	bnez $s2, helper_2
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 120  # sound
	li $a1, 1000
	li $a2, 95
	li $a3, 127
	li $v0, 31     
	syscall
	helper_2: j redrawing_screen 


double_check: 
	addi $t3, $t2, 16 
	sub $t5, $t1, $t1  
	subi $t6, $t1, 16 

	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0 
	beqz $s1, helper_3
	bnez $s2, helper_3
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31     
	syscall
	j redrawing_screen


helper_3: 
	slt $s1, $t0, $t5 
	slt $s2, $t6, $t0 
	beqz $s1, l
	bnez $s2, l
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31      
	syscall
	l: j redrawing_screen 


# top log row:
top_row_log: 
	lw $t0, frog_x_coord
	lw $t1, log_first_x_coord 
	addi $t2, $t1, 32 
	addi $t4, $t1, 96 

	slti $s1, $t1, 32
	bnez $s1, third_verify 

	addi $t3, $t2, 16 
	addi $t5, $t4, 16 

	
	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0 
	beqz $s1, helper_5
	bnez $s2, helper_5
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31     
	syscall
	j redrawing_screen

helper_5: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0 
	beqz $s1, helper_6
	bnez $s2, helper_6
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31      
	syscall
helper_6: j redrawing_screen

third_verify: 
	addi $t3, $t2, 16 
	sub $t5, $t1, $t1  
	subi $t6, $t1, 16 

	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0 
	beqz $s1, helper_7
	bnez $s2, helper_7
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31     
	syscall
	j redrawing_screen

helper_7: 
	slt $s1, $t0, $t5 
	slt $s2, $t6, $t0 
	beqz $s1, helper_8
	bnez $s2, helper_8
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31      
	syscall
	helper_8: j redrawing_screen

# bottom car row:
bottom_row_of_car: 
	lw $t0, frog_x_coord 
	lw $t1, car_second_x_coord 
	subi $t2, $t1, 32
	subi $t3, $t1, 16 

	slti $s1, $t1, 80 
	bnez $s1, verify_5 

	sub $t4, $t1, $t1  
	subi $t5, $t1, 80 

	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0
	beqz $s1, helper_9
	bnez $s2, helper_9
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31     
	syscall
	j redrawing_screen

helper_9: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0 
	beqz $s1, helper_10
	bnez $s2, helper_10
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31      
	syscall
helper_10: j redrawing_screen

verify_5:
	addi $t3, $t1, 32 
	addi $t4, $t1, 48 

	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0 
	beqz $s1, helper_11
	bnez $s2, helper_11
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31 
    
	syscall
	j redrawing_screen

helper_11: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0 
	beqz $s1, helper_12
	bnez $s2, helper_12
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31    
	syscall
helper_12: j redrawing_screen

# bottom log row:
last_row_logs: 
	lw $t0, frog_x_coord 
	lw $t1, log_second_x_coord 
	subi $t2, $t1, 32 
	subi $t3, $t1, 16 

	slti $s1, $t1, 80 
	bnez $s1, verify_6 

	sub $t4, $t1, $t1  
	subi $t5, $t1, 80 

	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0 
	beqz $s1, helper_13
	bnez $s2, helper_13
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31   
	syscall
	j redrawing_screen

helper_13: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0 
	beqz $s1, helper_14
	bnez $s2, helper_14
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31      
	syscall
helper_14: j redrawing_screen

verify_6: 
	addi $t3, $t1, 32 
	addi $t4, $t1, 48 

	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0
	beqz $s1, helper_15
	bnez $s2, helper_15
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31     
	syscall
	j redrawing_screen

helper_15: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0 
	beqz $s1, helper_16
	bnez $s2, helper_16
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31   
	syscall
helper_16: j redrawing_screen

# The last row of logs
last_row_of_logs: 
	lw $t0, frog_x_coord 
	lw $t1, log_3_x_coord 
	subi $t2, $t1, 32
	subi $t3, $t1, 16 

	slti $s1, $t1, 80 
	bnez $s1, verify_7 

	sub $t4, $t1, $t1  
	subi $t5, $t1, 80 

	
	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0 
	beqz $s1, operation
	bnez $s2, operation
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31       
	syscall
j redrawing_screen

operation: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0
	beqz $s1, arrange
	bnez $s2, arrange
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31      
	syscall
arrange: j redrawing_screen

verify_7: 
	addi $t3, $t1, 32 
	addi $t4, $t1, 48 

	
	slt $s1, $t0, $t2 
	slt $s2, $t3, $t0
	beqz $s1, after
	bnez $s2, after
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31     
	syscall
	j redrawing_screen
	
after: 
	slt $s1, $t0, $t4 
	slt $s2, $t5, $t0 
	beqz $s1, helper_method
	bnez $s2, helper_method
	li $t0, 56
	sw $t0, 0($t8)
	lw $t1, number_of_deaths
	la $s7, number_of_deaths
	addi $t1, $t1, 1
	sw $t1, 0($s7)
	li $a0, 115  # sound
	li $a1, 1000
	li $a2, 92
	li $a3, 120
	li $v0, 31         
	syscall
helper_method: j redrawing_screen



Retry_Screen:
lw $t0, displayAddress
	lw $t2, grey
	
			# D
	addi $t1, $zero, 584
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 552
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 520
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 488
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 456
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	
	addi $t1, $zero, 585
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 554
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 522
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 490
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 457
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	# I
	addi $t1, $zero, 592
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 560
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 528
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 496
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 464
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
			
	# E
	addi $t1, $zero, 598
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 599
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 600
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 566
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 534
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 535
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 536
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 502
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 470
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 471
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	addi $t1, $zero, 472
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $t2, 0($t1)
	
	li $v0, 32
	li $a0, 4000
	syscall

	li $v0, 4       
	la $a0, retry_screen_text  
	syscall
	li $a0, 50  # sound
	li $a1, 3000
	li $a2, 55
	li $a3, 127
	li $v0, 31     
	syscall
#This is the display screen

Retry_Display:
	addi $a1, $s0, 0  
	addi $a2, $a1, 512 
	lw $a0, alive_frog
	jal Rectangle_Function
	addi $a1, $s0, 512  
	addi $a2, $a1, 512 
	lw $a0, blue
	jal Rectangle_Function
	addi $a1, $s0, 1024  
	addi $a2, $a1, 512 
	lw $a0, green
	jal Rectangle_Function
	addi $a1, $s0, 1536  
	addi $a2, $a1, 512 
	lw $a0, purple
	jal Rectangle_Function
	addi $a1, $s0, 2048  
	addi $a2, $a1, 512 
	lw $a0, yellow
	jal Rectangle_Function
	addi $a1, $s0, 2560  
	addi $a2, $a1, 512 
	lw $a0, red
	jal Rectangle_Function
	addi $a1, $s0, 3072  
	addi $a2, $a1, 512 
	lw $a0, winningning_frog
	jal Rectangle_Function
	addi $a1, $s0, 3072  
	addi $a2, $a1, 512 
	lw $a0, turtle_colour
	jal Rectangle_Function
	addi $a1, $s0, 3584 
	addi $a2, $a1, 512 
	lw $a0, alive_frog
	jal Rectangle_Function

	lw $t8, 0xffff0000
	beq $t8, 1, check_in

	li $v0, 32
	li $a0, 500
	syscall

	j Retry_Display
	check_in: addi $t8, $zero, 0
	lw $t2, 0xffff0004
	beq $t2, 0x65, Exit
	beq $t2, 0x72, respond_to_r

respond_to_r:
	la $t8 frog_y_coord
	li $t0, 56
	sw $t0, 0($t8)
	la $t3, winning
	sw $zero, 0($t3)
	la $t3, number_of_deaths
	sw $zero, 0($t3)
	li $a0, 45  # sound
	li $a1, 5000
	li $a2, 48
	li $a3, 120
	li $v0, 31     
	syscall
	j main_game_loop

	Exit: li $v0, 10        # terminate the program gracefully
	syscall
#Below are many functions:

# Various Functions:
Rectangle_Function:
	Loop_Function: beq $a1, $a2, Return_It
	sw $a0, 0($a1)
	addi $a1, $a1, 4
	j Loop_Function
	Return_It: jr $ra

Froggy_Function:
	Four_Loop: beq $a1, $a2, Return_Frog
	addi $t1, $a1, 16
	Five_Loop: beq $a1, $t1, y
	sw $a0, 0($a1)
	addi $a1, $a1, 4
	j Five_Loop
	y: addi $a1, $a1, 112
	j Four_Loop
	Return_Frog: jr $ra

Other_Rectangle_Function:
	Second_Loop: beq $a1, $a2, Return_Froggy
	add $t1, $a1, $a3 
	Third_Loop: beq $a1, $t1, x
	sw $a0, 0($a1)
	addi $a1, $a1, 4
	j Third_Loop
	x: add $a1, $a1, $v0
	j Second_Loop
	Return_Froggy: jr $ra
