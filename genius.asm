.data

		
lista:	.space 80


.text

.macro setPixel($x, $y, $cor)		#procedimento para setar um pixel no display onde $x é coluna e $y é a linha 
	sll	$t4, $y, 6		#multiplica o $y por 64 e setar em $t4 para percorrer as linhas
	addu	$t4, $t4, $x		#adiciona em $t4 a soma de $t4 com $x
	sll	$t4, $t4, 2		# multiplica por 4 para setar na memoria  
	addi	$t4, $t4, 0x10000000	# soma o $t4 com o endereÃ§o do primeiro pixel
	sw	$cor, 0($t4)		# grava a $cor em $t4
.end_macro

.macro linhaH(%x, $y, %n, $cor)		#procedimento para criar linha horizontal a partir de uma posição %x é a coluna e $y é a linhan %n é o número de pixel
	addi	$t6, $zero, %x		#$t6 recebe o valor passado a %x	
	addi	$t8, $t6, %n		#$t8 recebe o valor da soma de $t6 com %n, neste caso $t8 terá o valor da soma da posição da coluna  com o número de pixel
loop:	beq	$t6, $t8, sair		#esse loop pinta n pixel na horizontal a partir de apartir de uma posição(x,y), enquanto $t6 for igual a $t8 então sai do loop  
	setPixel($t6, $y, $cor)		#setPixel é chamada para para pintar os pixel, neste caso só o eixo x(coluna) é incrementado em 1 para pintar o próximo pixel
	addi	$t6, $t6, 1		#incrementa $t6 em 1 até ser igual $t8
	j	loop			#dá um salta para loop
sair:
.end_macro

.macro pintarTudo(%cor)			#procedimento para preencher todo o display com uma cor
	addi	$t5, $zero, %cor	#$t5 recebe um cor passado em %cor
	move	$t6, $zero 		#$t6 recebe zero prara iniciar o contado
loop:	beq	$t6, 4096, sair		#Desvia para sair se o contador($t6) for igual a 4096(numero total de pixel 256/4 x 256/4 ) 
	sll	$t4, $t6, 2		#multiplica $t6 por 4 para saltar de uma posição de mémoria para outra 
	addi	$t4, $t4, 0x10000000	#somar o valor do endereço da primeira posição do pixel ao $t4
	sw	$t5, 0($t4)		#grava na posição passada em $t4 a cor guardada em $t5
	addi	$t6, $t6, 1		#incrementa $t6 em 1
	j	loop			
sair:
.end_macro

.macro quadrado($cor)			#procedimento para criar o quadrado 8x8 pixel para as jogadas onde %x � a coluna %y a linha	
	addi	$t7, $zero, 40		#seta em $t7 que � um contador o valor de %y
	addi	$t9, $t7, 14		#seta em $t9 o valor do produto de $t7 por 256 que o n�mero de pixel por linha
loop:	beq	$t9, $t7, exit		#se $t9 for igual a $t7 encerra o loop
	linhaH(25, $t7, 14, $cor)	#chama a fun��o linhaH e cria v�rias linhas como o mesmo n�mero de pixel s� alterando o valor de linha
	addi	$t7, $t7, 1		#incrementa em 1 $t7
	j	loop
exit:	
.end_macro

.macro sorteia_int()
	li $a1, 4				# Seta semente	
	li $v0, 42      			# Argumento 42, random int a partir de uma semente    
    	syscall         			# Gera random int retornando em $a0
.end_macro

.macro pausar(%y)
	ori $v0, $zero, 32				# Seta parametro do syscall
	ori $a0, $zero, %y				# %time miliseconds
	syscall
.end_macro

.macro mostrar($x)
	
	beq 	$x, 0x00000000, case0
	beq 	$x, 0x00000001, case1
	beq 	$x, 0x00000002, case2
	beq 	$x, 0x00000003, case3
case0:		
	
	quadrado($s0)
	j sair_case_mostrar
case1:		
	quadrado($s1)
	j sair_case_mostrar
case2:		
	quadrado($s2)
	j sair_case_mostrar
case3:		
	quadrado($s3)
	j sair_case_mostrar		
sair_case_mostrar:		
	pausar(600)
	pintarTudo(0x00FFFFFF)
	pausar(600)
.end_macro

.macro print($x)
	li  $v0, 1           # service 1 is print integer
    	add $a0, $x, $zero  # load desired value into argument register $a0, using pseudo-op
    	syscall
.end_macro

.macro sorteia_tudo()
	la $t1, lista # $t1 recebe o endere�o de lista
loop_sorteia_tudo:
        bgt $t0,19,exit_sorteia_tudo
    	addi $t0,$t0,1  
    	sorteia_int()
    	sw $a0, ($t1)
    	addi $t1, $t1, 4	   	
    	j loop_sorteia_tudo
exit_sorteia_tudo:
.end_macro

.macro ler_teclado()	
	li  $v0, 12         
   	add $a0, $t0, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall	
.end_macro

.globl main
main:	
	addi	$s0, $zero, 0x00FF0000 	#vermelho
	addi	$s1, $zero, 0x000000FF 	#azul
	addi	$s2, $zero, 0x00FFFF00	#amarelo
	addi	$s3, $zero, 0x0000FF00	#verde
	pintarTudo(0x00FFFFFF)
	sorteia_tudo()
	
	move $t0,$zero
loop_main:
	
	bgt $t0,19,exit_main
	la $t1, lista # $t1 recebe o endere�o de lista
	move $t3, $zero
loop_sec:
	bgt $t3, $t0, exit_sec     	
    	lw   $t2, ($t1)
    	print($t2)
    	mostrar($t2)   	
    	addi $t1, $t1, 4
    	addi $t3,$t3,1
    	j loop_sec
exit_sec:
	la $t1, lista # $t1 recebe o endere�o de lista
	move $t3, $zero	
loop_verificar:
	bgt $t3, $t0, sair_case
	ler_teclado()
case:
	beq  $v0, 0x00000061, tecla_a
	beq  $v0, 0x00000073, tecla_s
	beq  $v0, 0x00000064, tecla_d
	beq  $v0, 0x00000066, tecla_f
	j case
tecla_a:
	lw   $t2, ($t1)
	bne $t2, 0x00000000, perdeu
	j fim_case
tecla_s:
	lw   $t2, ($t1)
	bne $t2, 0x00000001, perdeu
	j fim_case
tecla_d:
	lw   $t2, ($t1)
	bne $t2, 0x00000002, perdeu
	j fim_case
tecla_f:
	lw   $t2, ($t1)
	bne $t2, 0x00000003, perdeu
	j fim_case
fim_case:	  	
    	
    	addi $t1, $t1, 4
    	addi $t3,$t3,1
    	j loop_verificar
sair_case:    	
    	addi $t0,$t0,1	
    	pintarTudo(0x00006400)
    	pausar(3000)
    	pintarTudo(0x00FFFFFF)
    	j loop_main
    	
perdeu:
	pintarTudo(0x00FF0000)
exit_main:
	
