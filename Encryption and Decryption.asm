# @author: akadakia
# @email: avik.kadakia@stonybrook.edu

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

##################################### PART I #######################################
	#																			#
	#	$t0 - Holds individual characters from the arguments					#
	#	$t1 - Holds the value that $t0 is compared to							#
	#	$t2 - Number of uppercase letters										#
	#																			#
####################################################################################

to_lowercase:
	li $t1, 0 # $t1 = 0
	li $t2, 0 # $t2 = 0, counter

to_lowercase_loop:
	lb $t0, 0($a0) # 0th offset of the String being passed
	beq $t0, $0, Done # If we reach the null-terminating charater, the parsing ends

	li $t1, 'A' # $t1 = 'A'
	blt $t0, $t1, to_lowercase_next_char
 	# If the current character is less than 'A', it goes to the next character

	li $t1, 'Z' # $t1 = 'Z'
	blt $t0, $t1 add_to_lowercase_one # If the character is lesser than 'Z', counter++
	j to_lowercase_next_char

add_to_lowercase_one:

	addi $t2, $t2, 1 # Counter
	addi $t0, $t0, 32 #	Making the character lower case
	sb $t0, 0($a0) # storing the new character in the same string

to_lowercase_next_char:
	addi $a0, $a0, 1 # Go to the next character in the string
	j to_lowercase_loop

##################################### PART II ######################################
	#																			#
	#	$t0 - Holds individual characters from the string						#
	#	$t1 - Holds the value that $t0 is compared to							#
	#	$t2 - Length of the String												#
	#																			#
####################################################################################

strlen:
	lb $t0, 0($a0) # 0th offset of the string
	li $t2, 0 # Counter = 0

strlen_loop:

	beq $t0, $0, Done # If the character in the string is equal to null terminating string, end the loop
	addi $t2, $t2, 1 # Counter++

	addi $a0, $a0, 1 # Next character in the string
	lb $t0, 0($a0) # Holds the individual character from $a0
	j strlen_loop

##################################### PART III #####################################
	#																			#
	#	$t0 - Holds individual characters from the arguments					#
	#	$t1 - Holds the value that $t0 is compared to							#
	#	$t2 - Number of letters													#
	#																			#
####################################################################################

count_letters:

	lb $t0, 0($a0) # Holds the individual character from $a0
	li $t1, 0 # Character $t0 is compared to
	li $t2, 0 # Counter

count_letters_loop:

	beq $t0, $0, Done

	li $t1, 'A' # $t1 = 'A'
	blt $t0, $t1, count_letters_next_char
 	# If the current character is less than 'A', it goes to the next character

	li $t1, 'Z' # $t1 = 'Z'
	blt $t0, $t1 add_count_letters_one # if $t2 is less than Z, it jumps to add_digit

	li $t1, 'a' # $t1 = 'a'
	blt $t0, $t1, count_letters_next_char
 	# If the current character is less than 'a', it goes to the next character

	li $t1, 'z' # $t1 = 'z'
	blt $t0, $t1 add_count_letters_one # if $t2 is less than z, it jumps to add_digit

add_count_letters_one:

	addi $t2, $t2, 1 # Counter++
	
count_letters_next_char:

	addi $a0, $a0, 1
	lb $t0, 0($a0) # Holds the individual character from $t0
	j count_letters_loop

Done:

	move $v0, $t2
    jr $ra

##################################### PART IV ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - plaintext														#
	#		$a1 - ab_text														#
	#		$a2 - ab_text_length												#
	#		$a3 - bacon_codes													#
	#																			#
	#	Returns:																#
	#		$v0 - Characters from the plaintext that were encoded 				#
	#				as 5-letter codes in ab text								#
	#																			#
	#		$v1 - Boolean stating if the entire plaintest was entirely			#
	#				encoded in the A/B String									#
	#																			#
	#	$t0 - Length of the plaintext string									#
	#	$t1 - ab_text_length to do calculations									#
	#	$t2 - 5																	#
	#	$t3 - Quotient of ab_text_length / 5									#
	#	$s0 - Bacon Codes														#
	#																			#
####################################################################################

encode_plaintext:

	addi $sp, $sp, -16 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s2, 4($sp) # Stored the address of the plaintext
	sw $s0, 8($sp) # Stored the address of the bacon codes
	sw $s1, 12($sp)
	move $s0, $a3 # Stored the address of the bacon codes
	move $s1, $a2 # s1 = ab_text_length
	move $s2, $a0 # Address of the plaintext

	jal strlen
	
	move $a0, $s2 #4($sp)
	
	move $t0, $v0 # $v0 is the length of the plaintext string

	move $a2, $s1
	move $t1, $a2 # $t1: ab_text_length
	addi $t1, $t1, -5 # Subtracted 5 to count for the null terminating A/B Text (BBBBB)

	li $t2, 5

	div $t1, $t2 # ab_text_length / 5
	mflo $t3 # Quotient of ab_text_length / 5
	
	li $t6, -1 # Counter for the plaintext length

	blt $s1, 5, v1_equals_0
	ble $t0, $t3, v1_equals_1 
	# If the length of the plaintext is less than or equal to the available space 
	# quotient of ab_text_length / 5, it means that the entire plaintext WILL FIT 
	# as A/B Text, therefore $v1 returns 1
	
	bgt $t0, $t3, v1_equals_0
	# If the length of the plaintext is more than the available space quotient of 
	# ab_text_length / 5, it means that the entire plaintext WILL NOT FIT as A/B Text, 
	# therefore $v1 returns 0

v1_equals_1:

	li $v1, 1
	move $v0, $t0 # Since the entire plaintext string will be converted, $v0 will contain it's length
	addi $a0, $a0, -1
	beqz $t0, add_null_character
	
	j encode_plaintext_continue

v1_equals_0:
	li $v1, 0
	move $v0, $t3 
	# Since the entire plaintext string will be converted, $v0 will contain quotient of ab_text_length / 5 
	# which will be amount of letters that could be converted.
	move $t0, $t3
	
	addi $a0, $a0, -1
	beqz $t0, add_null_character
	bltz $t1, Part_IV_Done
	
	j encode_plaintext_continue
	
encode_plaintext_continue:
	addi $a0, $a0, 1
	addi $t6, $t6, 1
	beq $t0, $t6, add_null_character # $t0 contains the length of the plaintext, if it equals 0, we reached the end.
	
	lb $t3, 0($a0)

	li $t2, 5

	li $t4, ' ' # Character is a space.
	beq $t3, $t4, add_space

	li $t4, '!' # Character is an exclamation mark.
	beq $t3, $t4, add_exclamation_mark

	li $t4, 39 # Character is a quotation mark.
	beq $t3, $t4, add_quotation_mark

	li $t4, ',' # Character is a comma.
	beq $t3, $t4, add_comma

	li $t4, '.' # Character is a period.
	beq $t3, $t4, add_period
	 
	# Subtracting the ASCII value of the number from 'a'. This tells you how many positions you need to go forward in memory / 5.
	# a = 0, b = 1, c = 2, ..., z = 25
	addi $t3, $t3, -97

	li $t2, 5
	mul $t3, $t3, $t2 # a = 0, b = 5, c = 10, d = 15, ... z = 120
 
	add $t3, $a3, $t3
	
	li $t2, 5
	 
replace_byte_loop: 
	 
	beqz $t2, encode_plaintext_continue # If you loaded 5 bits, $t5 should equal 0, therefore, you are done.
	lbu $t4, 0($t3)
	sb $t4, 0($a1)
	 
	addi $a1, $a1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t3, $t3, 1 # Subtracting 1 to load only 5 bytes
	
	j replace_byte_loop

add_space:

	move $s0, $a3
	addi $t4, $s0, 130

add_space_loop:

	beqz $t2, encode_plaintext_continue
	
	lb $t5, 0($t4)
	sb $t5, 0($a1)
	 
	addi $a1, $a1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t4, $t4, 1 # Moving to the next character in the Array

	j add_space_loop

add_exclamation_mark:

	move $s0, $a3
	addi $t4, $s0, 135

add_exclamation_mark_loop:

	beqz $t2, encode_plaintext_continue
	
	lb $t5, 0($t4)
	sb $t5, 0($a1)
	 
	addi $a1, $a1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t4, $t4, 1 # Moving to the next character in the Array

	j add_exclamation_mark_loop

add_quotation_mark:

	move $s0, $a3
	addi $t4, $s0, 140

add_quotation_mark_loop:

	beqz $t2, encode_plaintext_continue
	
	lb $t5, 0($t4)
	sb $t5, 0($a1)
	 
	addi $a1, $a1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t4, $t4, 1 # Moving to the next character in the Array

	j add_quotation_mark_loop

add_comma:

	move $s0, $a3
	addi $t4, $s0, 145
	
add_comma_loop:

	beqz $t2, encode_plaintext_continue
	
	lb $t5, 0($t4)
	sb $t5, 0($a1)
	 
	addi $a1, $a1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t4, $t4, 1 # Moving to the next character in the Array

	j add_comma_loop
	
add_period:

	move $s0, $a3
	addi $t4, $s0, 150
	
add_period_loop:

	beqz $t2, encode_plaintext_continue
	
	lb $t5, 0($t4)
	sb $t5, 0($a1)
	 
	addi $a1, $a1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t4, $t4, 1 # Moving to the next character in the Array

	j add_period_loop

add_null_character:

	li $t2, 5
	blt $a2, $t2, Part_IV_Done # plaintext is empty and ab text is not large enough to encode the end-of-message marker
	
	move $s0, $a3
	addi $t4, $s0, 155

add_null_character_loop:

	beqz $t2, Part_IV_Done
	
	lb $t5, 0($t4)
	sb $t5, 0($a1)
	 
	addi $a1, $a1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t4, $t4, 1 # Moving to the next character in the Array
	
	j add_null_character_loop

Part_IV_Done:
	lw $ra, 0($sp) # Stored the return address on the stack
	lw $s2, 4($sp) # Stored the address of the plaintext
	lw $s0, 8($sp) # Stored the address of the bacon codes
	lw $s1, 12($sp)
	
	addi $sp, $sp, 16 # Deallocated the stack space
    jr $ra
	
##################################### PART V #######################################
	#																			#
	#	Parameters:																#
	#		$a0 - plaintext														#
	#		$a1 - ciphertext													#
	#		$a2 - ab_text														#
	#		$a3 - ab_text_length												#
	#		Stack - bacon_codes													#
	#																			#
	#	Returns:																#
	#		$v0 - Characters from the plaintext that were encoded 				#
	#				as 5-letter codes in ab text								#
	#																			#
	#		$v1 - Boolean stating if the entire plaintest was entirely			#
	#				encoded in the A/B String									#
	#																			#
	#	$t0 - Length of the plaintext string									#
	#	$t1 - ab_text_length to do calculations									#
	#	$t2 - 5																	#
	#	$t3 - Quotient of ab_text_length / 5									#
	#																		#
####################################################################################

encrypt:

	addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored the address of the plaintext
	sw $s1, 8($sp) # Stored the address of the ciphertext
	sw $s2, 12($sp)# Stored the address of the ab_text
	sw $s3, 16($sp)# Stored the address of the ab_text_length
	lw $s4, 20($sp)#######

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	move $a0, $s0
	jal to_lowercase

	move $a0, $s0
	# move $a1, $s1 #### Comment if doesn't do anything

	jal strlen
	
	move $t0, $v0 # $t0 is the length of the plaintext string
	
	move $a0, $s0 # To use for the loop thats below
	
	move $t1, $s3 ## $a3 # $t1: ab_text_length
	addi $t1, $t1, -5 # Subtracted 5 to count for the null terminating A/B Text (BBBBB)

	li $t2, 5

	div $t1, $t2 # ab_text_length / 5
	mflo $t3 # Quotient of ab_text_length / 5
	
	ble $t3, $t0, v1_equals_0_encrypt # If ab_text_length <= length of the plaintext
	# If the length of the plaintext is less than or equal to the available space 
	# quotient of ab_text_length / 5, it means that the entire plaintext WILL FIT 
	# as A/B Text, therefore $v1 returns 1
	
	bgt $t3, $t0, v1_equals_1_encrypt # If ab_text_length > length of the plaintext
	# If the length of the plaintext is more than the available space quotient of 
	# ab_text_length / 5, it means that the entire plaintext WILL NOT FIT as A/B Text, 
	# therefore $v1 returns 0

v1_equals_0_encrypt:

	li $v1, 0
	
	mult $t3, $t2 # Quotient of ab_text_length * 5
	mflo $t3
	move $v0, $t3 # $v0 will contain ab_text's length that will contain the plaintext
	blt $s3, $t2, encrypt_continue
	addi $v0, $v0, 5
	addi $a0, $a0, -1
	j encrypt_continue

v1_equals_1_encrypt:
	
	li $v1, 1

	mult $t0, $t2
	mflo $v0
	addi $v0, $v0, 5
	
	# Since the entire plaintext string will be converted, $v0 will contain quotient of ab_text_length / 5 
	
	addi $a0, $a0, -1
	
	j encrypt_continue

encrypt_continue:

	move $a0, $s0#4($sp) # Loaded the address of the plaintext
	move $a1, $s2#12($sp)# Loaded the address of the ab_text
	move $a2, $s3#16($sp)# Loaded the address of the ab_text_length
	move $a3, $s4#20($sp)# Loaded the address of bacon codes
	
	addi $sp, $sp, -8 # Allocated space on the stack
	
	sw $s2, 0($sp)
	sw $s3, 4($sp)
	
	move $s2, $v0
	move $s3, $v1
	
	jal encode_plaintext
	
	move $v0, $s2
	move $v1, $s3
	
	lw $s2, 0($sp)
	lw $s3, 4($sp)
	
	addi $sp, $sp, 8 # Dellocated space on the stack
		
	move $t8, $s1 #8($sp)
	move $t9, $s2 # 12($sp)  ######
	move $a3, $s2 # Gets the length of the ab_text to run the loop
	li $t2, 0
	
encrypt_loop:

	beq $t2, $a3, Part_V_Done
	
	lb $t0, 0($t8) # Address of ciphertext
	lb $t1, 0($t9) # Address of ab_text
	
	blt $t1, 65, Part_V_Done
	bgt $t1, 66, Part_V_Done
	
	blt $t0, 65, encrypt_next_ciphertext
	bgt $t0, 122, encrypt_next_ciphertext
	
	blt $t0, 91, valid_character_upper
	bgt $t0, 96, valid_character_lower
	
	j encrypt_next_ciphertext
	
valid_character_upper:
	beq $t1, 66, encrypt_next
	
	addi $t5, $t0, 32
	sb $t5, 0($t8)
	j encrypt_next

valid_character_lower:
	beq $t1, 65, encrypt_next
	
	addi $t5, $t0, -32
	sb $t5, 0($t8)
	j encrypt_next	
	
encrypt_next_ciphertext:

	addi $t8, $t8, 1
	j encrypt_loop
	
encrypt_next:

	addi $t9, $t9, 1
	addi $t8, $t8, 1
	addi $t2, $t2, 1
	j encrypt_loop

Part_V_Done:
	lw $ra, 0($sp) # Stored the return address on the stack
	lw $s0, 4($sp) # Stored the address of the plaintext
	lw $s1, 8($sp)# Stored the address of the ciphertext
	lw $s2, 12($sp)# Stored the address of the ab_text
	lw $s3, 16($sp)# Returned the address of the ab_text_length
	lw $s4, 20($sp)
	
	addi $sp, $sp, 24 # Deallocated the stack space
    jr $ra
	
##################################### PART VI ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - ciphertext													#
	#		$a1 - ab_text														#
	#		$a2 - ab_text_length												#
	#		$a3 - bacon_codes													#
	#																			#
	#	Returns:																#
	#		$v0 - The number of characters written to ab text by the 			#
	#				function, or -1 on error									#
	#																			#
	#	$t0 - Length of the plaintext string									#
	#	$t1 - ab_text_length to do calculations									#
	#	$t2 - 5																	#
	#	$t3 - Quotient of ab_text_length / 5									#
	#																		#
####################################################################################
	
decode_ciphertext:

	addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored the address of the plaintext
	sw $s1, 8($sp) # Stored the address of the ciphertext
	sw $s2, 12($sp)# Stored the address of the ab_text
	sw $s3, 16($sp)# Stored the address of the ab_text_length
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	li $t5, 0 # Number of B's in a row
	li $t6, 0 # Counter of the character in the word in the array
	move $t8, $s0
	move $t9, $s1

	jal count_letters

	move $t7, $v0 # $t0 = length of the ciphertext
	
	# The length of the cipher text > the length of the A/B Text
	bgt $t7, $s2, return_neg_1

decode_ciphertext_continue:
	
	li $t0, 65
	li $t1, 66
	
	lb $t2, 0($t8)
	
	beqz $t2, choose_v0
	
	blt $t2, 65, decode_next_ciphertext
	bgt $t2, 122, decode_next_ciphertext
	
	blt $t2, 91, add_B
	bgt $t2, 96, add_A
	
decode_next_ciphertext:

	addi $t8, $t8, 1
	
	#bgt $t6, 5, reset
	bne $t6, 5, decode_ciphertext_continue
	bne $t5, 5, reset

	j choose_v0

reset:
	li $t5, 0
	li $t6, 0
	j decode_ciphertext_continue

add_A:

	sb $t0, 0($t9)
	addi $t8, $t8, 1
	addi $t9, $t9, 1
	addi $t6, $t6, 1
	
	#bgt $t6, 5, reset
	bne $t6, 5, decode_ciphertext_continue
	
	bne $t5, 5, reset
	
	j choose_v0
	
add_B:
	
	sb $t1, 0($t9)
	addi $t8, $t8, 1
	addi $t9, $t9, 1
	addi $t5, $t5, 1
	addi $t6, $t6, 1
	
	#bgt $t6, 5, reset
	blt $t6, 5, decode_ciphertext_continue
	beq $t5, 5, choose_v0
	
	j reset

add_null_character_VI:

	li $t2, 5
	blt $s2, $t2, choose_v0 # plaintext is empty and ab text is not large enough to encode the end-of-message marker
	
	move $s0, $s3
	addi $t4, $s0, 155

add_null_character_VI_loop:

	beqz $t2, choose_v0
	
	lb $t5, 0($t4)
	sb $t5, 0($s1)
	 
	addi $s1, $s1, 1 # Go to the next character in the A/B Text.
	addi $t2, $t2, -1 # Subtracting 1 to load only 5 bytes
	addi $t4, $t4, 1 # Moving to the next character in the Array

	j add_null_character_VI_loop

choose_v0:

	# If the length of cipher text <= the length of A/B Text
	blt $t7, $s2, case1

case1:
	move $a0, $s1
	
	jal count_letters
	
	j Part_VI_Done

return_neg_1:
	li $v0, -1
	j Part_VI_Done

Part_VI_Done:

	lw $ra, 0($sp) # Stored the return address on the stack
	lw $s0, 4($sp) # Stored the address of the plaintext
	lw $s1, 8($sp)# Stored the address of the ciphertext
	lw $s2, 12($sp)# Stored the address of the ab_text
	lw $s3, 16($sp)# Returned the address of the ab_text_length
	
	addi $sp, $sp, 20 # Deallocate space on the stack
	
    jr $ra
	
##################################### PART VII #####################################
	#																			#
	#	Parameters:																#
	#		$a0 - ciphertext													#
	#		$a1 - plaintext														#
	#		$a2 - ab_text														#
	#		$a3 - ab_text_length												#
	#		Stack - bacon_codes													#
	#																			#
	#	Returns:																#
	#		$v0 - Characters from the plaintext that were encoded 				#
	#				as 5-letter codes in ab text								#
	#																			#
	#	$t0 - Length of the plaintext string									#
	#	$t1 - ab_text_length to do calculations									#
	#	$t2 - 5																	#
	#	$t3 - Quotient of ab_text_length / 5									#
	#																			#
####################################################################################

decrypt:

	addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Return Address
	sw $s0, 4($sp) # Ciphertext
	sw $s1, 8($sp) # Plaintext
	sw $s2, 12($sp)# ab_text
	sw $s3, 16($sp)# ab_text_length
	lw $s4, 20($sp)# Bacon Codes
	
	move $s0, $a0 # cipher
	move $s1, $a1 # plaintext
	move $s2, $a2 # ab_text
	move $s3, $a3 # ab_text leng
	
	# In order to convert the ciphertext to ab_text
	
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	move $a3, $s4
	
	jal decode_ciphertext
	
	beq $v0, -1, Part_VII_Done
	
	li $t5, 0 # $v0 counter
	li $t6, 0 # Counter
	li $t7, 0 # final answer
	move $t8, $s1 # plaintext
	move $t9, $s2 # ab_text
	
decrypt_loop:
	
	lb $t2, 0($t9) # $t2 = 0th offset of ab_text
	beq $t2, 65, it_is_A # If $t2 = A
	beq $t2, 66, it_is_B # If $t2 = B
	j Part_VII_Done # If $t2 != A || $t2 != B, end the message

it_is_A:
	
	sll $t7, $t7, 1 # Shift left by 1
	
	addi $t6, $t6, 1 # Counter++ till Counter == 5
	addi $t9, $t9, 1 # Offset of ab_text++
	
	beq $t6, 5, next_in_plaintext # If counter == 5, get the next character in plain text
	
	j decrypt_loop
	
it_is_B:

	sll $t7, $t7, 1 # Shift left by 1
	addi $t7, $t7, 1 # Add the answer by 1
	
	addi $t6, $t6, 1 # Counter++ till Counter == 5
	addi $t9, $t9, 1 # Offset of ab_text++
	
	beq $t6, 5, next_in_plaintext # If counter == 5, get the next character in plain text
	
	j decrypt_loop
	
next_in_plaintext:

	blt $t7, 26, set_to_letter # If $t7 < Z, it is a letter

	j set_to_special_character # If $t7 >= Z, it is a special character

set_to_letter:

	addi $t7, $t7, 65 # Make it an ASCHII Alphabet
	addi $t5, $t5, 1 # $v0 counter++
	
	sb $t7, 0($t8) # Store the alphabet from $t7 to the current position in plainstring
	
	addi $t8, $t8, 1 # Add one to get the next character in plainstring
	li $t6, 0 # Counter = 0
	li $t7, 0 # Total answer = 0
	j decrypt_loop

set_to_special_character:

	beq $t7, 26, jump_to_space
	beq $t7, 27, jump_to_exclamation
	beq $t7, 28, jump_to_quotation
	beq $t7, 29, jump_to_comma
	beq $t7, 30, jump_to_period
	j jump_to_eom

jump_to_space:

	li $t7, 32

	sb $t7, 0($t8)
	
	addi $t5, $t5, 1 # $v0 counter++
	addi $t8, $t8, 1
	li $t6, 0
	li $t7, 0
	j decrypt_loop

jump_to_exclamation:

	li $t7, 33

	sb $t7, 0($t8)
	
	addi $t5, $t5, 1 # $v0 counter++
	addi $t8, $t8, 1
	li $t6, 0
	li $t7, 0
	j decrypt_loop

jump_to_quotation:

	li $t7, 39

	sb $t7, 0($t8)
	
	addi $t5, $t5, 1 # $v0 counter++
	addi $t8, $t8, 1
	li $t6, 0
	li $t7, 0
	j decrypt_loop

jump_to_comma:

	li $t7, 44

	sb $t7, 0($t8)
	
	addi $t5, $t5, 1 # $v0 counter++	
	addi $t8, $t8, 1
	li $t6, 0
	li $t7, 0
	j decrypt_loop

jump_to_period:

	li $t7, 46

	sb $t7, 0($t8)

	addi $t5, $t5, 1 # $v0 counter++	
	addi $t8, $t8, 1
	li $t6, 0
	li $t7, 0
	j decrypt_loop

jump_to_eom:

	li $t7, 0

	sb $t7, 0($t8)

	move $v0, $t5	
	addi $t8, $t8, 1
	li $t6, 0
	li $t7, 0

Part_VII_Done:

	lw $ra, 0($sp) # Stored the return address on the stack
	lw $s0, 4($sp) # Stored the address of the ciphertext
	lw $s1, 8($sp) # Stored the address of the plaintext
	lw $s2, 12($sp)# Stored the address of the ab_text
	lw $s3, 16($sp)# Returned the address of the ab_text_length
	sw $s4, 20($sp)# Bacon Codes
	
	addi $sp, $sp, 20 # Deallocate space on the stack

	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################