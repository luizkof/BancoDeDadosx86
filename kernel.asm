;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ALunos: Luiz Antonio
;ALunos: Thiago Augusto
;ALunos: Rafael
;ALunos: José Brandão
;ALunos: Marco
;
;
;
;									Projeto de um Banco de dados
;Funcionamento:
;	É alocado uma regiao de memoria (label: memoria) que contem todas as informações sobre o banco
;		O primeito byte índica quais posições na memoria está com cliente ou nao
;	Exemplo: 
;		configuração do primeiro byte: 1|0|1|0|0|0|0|0
;		logo existe cliente na posição 1 e 3 
;	Como achar o cliente?
;		Suponha que queiremos acessar o cliente 3, para isso basta multiplicar 46*(3-1)		
;		e somar 1.
;			46 pois cada cliente contem 46 byte de memoria e somar 1 devido ao primeiro byte ser o 
;			byte do mapa de clientes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Tamanho Estrutura dados
; Nome = 20 char
; Conta = 13 Char
; CPF = 11 Char
;



org 0x7e00
jmp main


;funções importantes porem não vale a pena ficar chaando(call) pois diminui a eficiencia do codigo
printaCaracter:
mov ah, 0Eh
mov bh,0
int 0x10
ret
;;;;;
go_to_ag: db 33
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pularLinha: db '', 10,13,0
msgInserirCliente: db 'Inserir Cliente', 10,13,0
msgAlterarCliente: db 'Alterar Cliente', 10,13,0
msgConsultarCliente: db 'Consultar Cliente', 10,13,0
msgDesvincularCliente: db 'Desvincular Cliente', 10,13,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Mensagems do menu
msgBemVindo: db '#### Bem vindo ao BancoKOF ###', 10,13,0
msgMenu0: db 'Escolha uma opcao:',10,13,0
msgMenu1: db '  1)Inserir Cliente',10,13,0
msgMenu2: db '  2)Alterar Cliente',10,13,0
msgMenu3: db '  3)Consultar Cliente',10,13,0
msgMenu4: db '  4)Desvincular Cliente',10,13,0
msgMenu5: db '  5)Listar Agencias',10,13,0
msgMenu6: db '  6)Listar Contas de uma Agencia',10,13,0
msgMenu7: db '#############################',10,13,0

;Mensagens do ValidaOpçao
msgOpcaoError: db 'Por favor insira uma das opcoes citadas acima',10,13,0

;;;;;;;;;;;;;;Mensgens usadas na inserção
;MEnsagens para capturar nome, CPF, conta e agência
msgInserirNome: db 'Insira o nome do cliente',10,13,0
msgInserirCPF: db 'Insira o cpf do cliente',10,13,0
msgInserirAgencia: db 'Insira a agencia do cliente',10,13,0
msgInserirConta: db 'Insira a conta do cliente',10,13,0
msgInseridoSucesso: db 'Insercao concluida com sucesso!',10,13,0
msgInserirCheio: db 'O BancoKOF esta lotado, procure o banco de Valgueiro XD!',10,13,0

;;;;;;;;;;;;;;;;Mensagens usadas na consultarCliente
msgConsultarCliente1: db 'Nome: ', 0
msgConsultarCliente2: db 'CPF: ', 0
msgConsultarCliente3: db 'Agencia: ', 0
msgConsultarCliente4: db 'Conta: ',0

;; 6. Strings para Lista conta
msgListaConta: db 'Insira o numero da Agencia para saber as contas relacionadas:', 10, 13, 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

msgNomeNaoEncontrado: db 'Nome nao encontrado',10,13,0
msgNomeEncontrado: db 'Nome encontrado',10,13,0

msgNumeroConta: db '00000', 13

;46 * 8 + 1
memoria TIMES   369    DB   0; declaro um vetor de 46*8 elemento e cada um contem 1 Byte e valor zero
nomeTemporario TIMES   21   DB   0; espaço para guardar temporariamente o nome durante consulta (o nome só pode ter 20 bytes)
;8 devido ao banco conter 8 clientes
;46 devido a
	;(20 bytes pro nome 1byte fim do nome)
	; (11 por cpf + 1 byte pro fim do cpf)
	; (5 pra agencia + 1 pro fim da agencoa )
	; (6 pra conta + 1 pro fim da agencoa


;função de delay
delay: 
;; Função que aplica um delay(improvisado) baseado no valor de dx
	push bp
	push dx

	mov dx,2000

	mov bp, dx
	back:
	dec bp
	nop
	jnz back
	dec dx
	cmp dx,0    
	jnz back
	pop dx
	pop bp
ret



;enttrada:nome do cliente
;saida:0 caso nao encotrou nada
		;'1':caso esteja na pos 1
		;'2' caso esteja na pos 2 e assim por diante
		;OBS:     retorna o numero em asc

		;|1|2|3|4|5|6|7|8
		;|0|0|0|0|0|0|0|0
identificaCliente:
	call limpaTela

;;;;;;captura nome e coloca na posição nomeTemporario
		mov cx,20;20 caracteres
		
	
		;printa msg para inseir nome
		mov si,msgInserirNome
		call printString
		

		
		mov si,nomeTemporario
		capturandoNome1:
		
		;captura caracter e coloca em al
		mov ah,0
		int 16h
		mov byte[si],al
		
		cmp al,13
		je verificaNome0;se o usuario apertar enter sai do laço

		;printa caracter q está em al
		mov ah, 0Eh
		mov bh,0
		int 0x10

		
		add si,1
		
		loop capturandoNome1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;varifica se no banco existe algum nome igual

		
		verificaNome0:
		call limpaTela
		mov si, nomeTemporario
		call printString



		mov cl,0
		mov si,memoria;move para si a base do vetor nome
		mov al,byte[si];pega o mapa de bits
		;mov al ,10111110b
		
		
		
		;procura posição ocupada
			;|0|1|2|3|4|5|6|7|
			;|0|0|0|0|0|0|0|0|

		;cl indica onde o numero da posicao ocupada

		procuraPos:
			;mov al ,10111110b
			cmp cl,8
			je naoEncontrado;só é permitido 8 pessoas no banco

			shl al,1;shift para esquerda e o bit "perdido é colocado na flag do carry"
			jc verificaNome
			inc cl
			jnc procuraPos

		verificaNome:
			call limpaTela
			mov dx,cx;dx apartir de agora guarda o valor da posiçao d cliente

			;NAo apagar essas tres linhas seguintes
			add dl,'0'
			mov al,'l'
			mov ah, 0Eh
			
			
				
			mov dx,cx
			

			push ax
			push cx
			mov cx,0




			verificaNome2:
				;al contem caracter de nometemporarop 
				;ah contem caracter de memoria

				;captura caracter de nomeTemporario
				mov si,nomeTemporario
				add si, cx
				mov al,byte[si]
				;

				;catura caracter de memoria

				mov dh,al;salva o valor de al em dh para usar posteriormente

				mov ax,46;(20 bytes pro nome 1byte fim do nome)
				; (11 por cpf + 1 byte pro fim do cpf)
				; (5 pra agencia + 1 pro fim da agencoa )
				; (6 pra conta + 1 pro fim da agencoa
				;mov dl,0
				mul dl;dl contem o valor da posição do cliente





				

				mov si,memoria
				inc si;pula byte do mapa
				add si,ax;posiciona si para o cliente
				add si,cx;acrescenta si para percorrer todo o vetor nome
				
				mov ah,byte[si]

				mov al,dh;recupera o valor de al(do nome temporario)

				cmp al,ah

				;mov al,ah
				;mov ah, 0Eh
				;mov bh,0
				;int 0x10
				




				jne procuraEmOutroCliente

				cmp al,0
				je nomeEncontrado

				

				inc cx
				jmp verificaNome2




		procuraEmOutroCliente:
			pop cx
			pop ax
			jmp procuraPos



		nomeEncontrado:
			;mov si, msgNomeEncontrado
			;call printString
			;call delay

			pop ax
			pop ax;coloca em al a posição do cliente encotrado
			mov ah,0
			inc al

			mov al,dl
			inc al
			add al,'0'

			;mov ah, 0Eh
			;mov bh,0
			;int 0x10
			;call delay
			ret

		naoEncontrado:

			mov si, msgNomeNaoEncontrado
			call printString
			call delay
			mov ax,0
			ret






;funções do codigo assembler
InserirCliente:
	

	call limpaTela
	mov si,msgInserirCliente
	call printString

	;procura posição livre
			;1|2|3|4|5|6|7|8
			;0|0|0|1|0|0|0|0
	;zero: significa vazio 
	;1 significa ocupado
	inserir:
	
	mov cl,0
	mov si,memoria;move para si a base do vetor nome
	mov al,byte[si]
	;mov al ,10111110b
	
	procuraPosLivre:
		;mov al ,10111110b
		cmp cl,8
		je cheio;só é permitido 8 pessoas no banco

		shl al,1;shift para esquerda e o bit "perdido é colocado na flag do carry"
		inc cl
		jc procuraPosLivre

	
	

	;printa a posição q o cliente está sendo inserido
	add cl,'0';
	;print oq ta em al
	mov al,cl
	mov ah, 0Eh
	mov bh,0
	int 0x10
	sub cl,'0'

	

	

	cmp cl,1
	je um
	cmp cl,2
	je dois
	cmp cl,3
	je tres
	cmp cl,4
	je quatro
	cmp cl,5
	je cinco
	cmp cl,6
	je seis
	cmp cl,7
	je seti
	cmp cl,8
	je oito

	jmp getname

	; Ocupar a o posição a ser inserida
	um:
	or byte[si],10000000b
	jmp getname
	dois:
	or byte[si],01000000b
	jmp getname
	tres:
	or byte[si],00100000b
	jmp getname
	quatro:
	or byte[si],00010000b
	jmp getname
	cinco:
	or byte[si],00001000b
	jmp getname
	seis:
	or byte[si],00000100b
	jmp getname
	seti:
	or byte[si],00000010b
	jmp getname
	oito:
	or byte[si],00000001b
	jmp getname
	;mov byte[si],al


	getname:

	;jmp inserir
	;cl indica onde estáa posiçao de memoria que será inserido o novo cliente

	sub cl,1;pra ele ocupar o segundo byte qnd a posiçao de memoria for igual 1
	mov ax,46;(20 bytes pro nome 1byte fim do nome)
	; (11 por cpf + 1 byte pro fim do cpf)
	; (5 pra agencia + 1 pro fim da agencoa )
	; (6 pra conta + 1 pro fim da agencoa
	mul cl

	inc ax;pula o primeiro byte q é o byte do mapa
	push ax

	;mov si,ax

	;;;;;;captura nome
		mov cx,20;20 caracteres
		
	
		;printa msg para inseir nome
		mov si,msgInserirNome
		call printString
		

		
		mov si,memoria
		add si,ax
		capturandoNome:
		
		;captura caracter e coloca em al
		mov ah,0
		int 16h
		mov byte[si],al
		
		cmp al,13
		je getCPF;se o usuario apertar enter sai do laço
		;printa caracter q está em al
		mov ah, 0Eh
		mov bh,0
		int 0x10

		
		add si,1
		
		loop capturandoNome

		getCPF:

;;;;;;captura cpf
		

		call limpaTela
		pop ax
		
		
		mov cx,11;
		
	
		;printa msg para inseir cpf
		mov si,msgInserirCPF
		call printString
		

		add ax,21;pula 20byte do nome + 1 byte do caracter vazio
		push ax;coloca na pilha para ser consultado qnd for get agencia
		mov si,memoria
		;captura letra e coloca em al
		add si,ax;pula 20bytes do nome
		capturandoCPF:
		
		mov ah,0
		int 16h
		mov byte[si],al
		
		cmp al,13
		je getAgencia;se o usuario apertar enter sai do laço
		;printa caracter q está em al
		mov ah, 0Eh
		mov bh,0
		int 0x10

		
		add si,1
		
		loop capturandoCPF
		

;;;;;;captura agencia
		getAgencia:

		call limpaTela
		pop ax
		;
		
		mov cx,5;
		
	
		;printa msg para inseir agencia
		mov si,msgInserirAgencia
		call printString
		
		add ax,12;configurando para pular os 11 bytes do cpf + 1 byte do fim do cpf
		push ax

		mov si,memoria
		;captura letra e coloca em al
		add si,ax;;pula os 11 bytes do cpf + 1 byte do fim do cpf
		capturandoAgencia:
		
		
		mov ah,0
		int 16h
		mov byte[si],al
		
		cmp al,13
		je getConta;se o usuario apertar enter sai do laço
		;printa caracter q está em al
		mov ah, 0Eh
		mov bh,0
		int 0x10

		
		add si,1
		
		loop capturandoAgencia


;;captura conta		

getConta:

		call limpaTela
		pop ax


		mov cx,6;o usuario só pode digitar 6 vezes
		
	
		;printa msg para inseir agencia
		mov si,msgInserirConta
		call printString
		
		add ax,6;configurando para pular os 6 bytes da agencia + 1 byte do fim da agencia
		
		mov si,memoria
		;captura letra e coloca em al
		add si,ax;pula os 6 bytes da agencia + 1 byte do fim da agencia
		capturandoConta:
		
		
		mov ah,0
		int 16h
		mov byte[si],al
		
		cmp al,13
		je fimInsercao;se o usuario apertar enter sai do laço
		;printa caracter q está em al
		mov ah, 0Eh
		mov bh,0
		int 0x10

		
		add si,1
		
		loop capturandoConta








fimInsercao:;printa msg de insrido com sucesso e dá um delay
	call limpaTela
	mov si,msgInseridoSucesso
	call printString
	call delay
	ret
cheio:;printa msg do banco está cheio dá um delay
	call limpaTela
	mov si,msgInserirCheio
	call printString
	call delay
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;AS funções que falta fazer;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alterarCliente:
	call limpaTela
	mov si,msgAlterarCliente
	call printString
	ret

consultarCliente:


	call identificaCliente
	cmp al,0
	je menu


	call limpaTela
	mov si,msgConsultarCliente
	call printString
	
	
	;captura caracter e coloca em al
		;mov ah,0
		;int 16h
		


	;printa caracter q está em al
		;mov ah, 0Eh
		;mov bh,0
		;int 0x10
	
	;



	sub al,'0'
	mov cl,al

	;mov cl,1

	sub cl,1;pra ele ocupar o segundo byte qnd a posiçao de memoria for igual 1
	mov ax,46;(20 bytes pro nome 1byte fim do nome)
	; (11 por cpf + 1 byte pro fim do cpf)
	; (5 pra agencia + 1 pro fim da agencoa )
	; (6 pra conta + 1 pro fim da agencoa
	mul cl

	inc ax;pula o primeiro byte q é o byte do mapa
	push ax
	call limpaTela

	mov si,msgConsultarCliente1
	call printString

	;printa nome do cliente
	mov si,memoria
	add si, ax
	call printString
	;call delay	
	
	;
	mov si, pularLinha
	call printString


	;printa cpf do cliente
	mov si,msgConsultarCliente2
	call printString

	mov si,memoria
	pop ax
	add ax,21
	add si,ax
	push ax
	call printString

	mov si, pularLinha
	call printString

	;printa agencia do cliente
	mov si,msgConsultarCliente3
	call printString

	mov si,memoria
	pop ax
	add ax,12
	push ax
	add si, ax
	
	call printString

	mov si, pularLinha
	call printString
	

	;printa conta do cliente
	mov si,msgConsultarCliente4
	call printString

	mov si,memoria
	pop ax
	add ax,6
	add si, ax
	
	call printString
	

	;mov si,msgConsultarCliente1
	;call printString


	;printa nome
	


	call delay
	call delay
	


	ret

desvincularCliente:; 
	call limpaTela
	mov si,msgDesvincularCliente
	call printString
<<<<<<< HEAD

	mov ax, agAuxMemo ;coloca o endereço da memória auxiliar em AX

	mov si, memoria 
	add si, 1 ;Pula o mapa de bits

	add si, 33 ;Soma 33 em si para ir para a base da primeira agencia

	push ax ;Coloca Ax e SI na pilha
	push si

	call memToAux_in ;Até aqui, nós transferimos o primeiro valor

    mov bx, 0 ;Utilizaremos bx como contador de loop pois estaremos utilizando cx

	consultAgLoop:  ; bl controla o loop interno, bh controla o loop externo
		cmp bh, 7    
		je consultEnd

		pop si
		add si, 41 ; 41 = 8 (para ir até a base do próximo nome) + 33 (para ir até a agencia a partir da base)
		push si ;Coloca o valor de si na pilha (pilha = [base próximo nome na memória, espaço vazio mem auxiliar])
		
		mov ax, agAuxMemo ;Coloca a base do auxiliar em AX
		add bh, 1
		mov bl, 0
		cmpLoop:
			cmp bl, 5
			je cmpLoopTrue
			cmp byte[si], byte[ax] ;Compara os valores para saber se a agência já foi lida
			add bl, 1 ;Soma um em BX (já executei n comparações)
			add si, 1
			add ax, 1
			je cmpLoop
			jmp consultAgLoop

	cmpLoopTrue:
			call memToAux_in ;Utilizando call pois memToAux_in tem ret no final
			jmp consultAgLoop

	memToAux_in:
		pop si
		pop ax
		mov cx, 5
		memToAux_inLoop: ;Executa um loop para inserir os dados
			mov byte[ax], byte[si] ;Coloca o que está em si para AX
			add ax, 1
			add si, 1
			loop memToAux_inLoop ;Como executamos o loop 5 vezes (executamos 5 somas)
							;AX já está apontando para a próxima posição livre

		mov byte[ax], 0x10  ;Coloca 0x10 na posição livre
		add ax, 1    		;Pula para a próxima posição livre
		mov byte[ax], 0x13	;Move 0x13 para a posição livre
		add ax, 1			;Pula para a próxima posição livre

		push ax; Coloca a posição atual de ax na pilha
		push si; Coloca o final da agencia registrada em Si

		ret  ;Retorna o controle
	consultEnd:
		call limpaTela
		mov si, agAuxMemo ;Coloca a base do vetor de agencias em si
		call printString ;Já vai printar com o /n por causa do 10,13



desvincularCliente:
	call limpaTela
	mov si, msgDesvincularCliente
	call printString	
					;para esta função, a posição do cliente deve estar no topo da pilha (pode ser alterado)
	
	pop ax 			;Coloca a posição do cliente em ax
				
	mov bx, 46
	mul ax, bx ;multiplica 46 pela posição do cliente e salva em AX

	add ax, 1 ;Soma um em ax para contar o mapa de bits

	mov si, memoria
	add si, ax  ;Soma a base da memória com ax, para posicionar SI no inicio do cliente a ser deletado

	mov cx, 46 ;Coloca 46 em cx para fazer o loop

	deletion:
		mov byte[si], 0 ;Zera o byte de ax
		add si, 1 ;si + 1 para zerar o próximo espaço
		loop deletion

	ret ;Retorna o controle para a parte de onde a função de deletar foi chamada

    
	

=======
	ret
>>>>>>> 589b96ed27761417b1b09c6554491bbb2cc85f23
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

listarAgencia:

	ret

; Busca em todos em uma agencia as contas relativas a ela
; @param numeroAgencia
listarConta:

	call limpaTela

	mov si, msgListaConta
	call printString
	
	mov di, msgNumeroConta; Para usar DI no stosb
	;stosb: salva em DI o que tem em AL

	;Tamanho máximo da conta = 6 (5 Numero +Enter)
	mov cx, 6
	getContaLista:
	
		mov ah,0
		int 16h	
		stosb
		cmp al, 13 ; compara se teclou enter
		je contaLida
		
		; Imprimi char lido na tela
		mov ah, 0Eh
		mov bh,0
		int 0x10
		
		loop getContaLista
	
	; Alterar ultimo valor para Retorno de Carro
	ajustCheck:
		dec di
		mov al, 13
		stosb

	contaLida:
		mov cl,0
		mov si,memoria;move para si a base do vetor nome
		mov al,byte[si]
		procuraPosLivreConta:
		;mov al ,10111110b
			cmp cl,8
			je semConta;só é permitido 8 pessoas no banco

			shl al,1;shift para esquerda e o bit "perdido é colocado na flag do carry"
			inc cl
			jc procuraPosLivreConta	
	
	semConta:

	ret

;printa o menu de opçoes
printMenu:

	mov si, msgBemVindo
	call printString

	mov si, msgMenu0
	call printString

	mov si, msgMenu1
	call printString

	mov si, msgMenu2
	call printString

	mov si, msgMenu3
	call printString

	mov si, msgMenu4
	call printString

	mov si, msgMenu5
	call printString

	mov si, msgMenu6
	call printString

	mov si, msgMenu7
	call printString
	ret




;Retorna apenas um dos valores 1 2, 3 ou 4
validaOpcao:
	;printaPulaLinha
	mov si, pularLinha
	call printString
	
	;captura letra e coloca em al
	mov ah,0
	int 16h
	
	;verifica a opçao desejada
	cmp al,'1'
	je opcao1
	
	cmp al,'2'
	je opcao2

	cmp al,'3'
	je opcao3

	cmp al,'4'
	je opcao4

	cmp al,'5'
	je opcao5

	cmp al,'6'
	je opcao6

	jmp error

	;direciona para a opçao desejada
	opcao1:
		pop ax
		jmp callOpcao1
	
	opcao2:
		pop ax
		jmp callOpcao2

	opcao3:
		pop ax
		jmp callOpcao3

	opcao4:
		pop ax
		jmp callOpcao4
	
	opcao5:
		pop ax
		jmp callOpcao5

	opcao6:
		pop ax
		jmp callOpcao6
	
	;printa msg de error
	error:
	mov si,msgOpcaoError
	call printString
	jmp validaOpcao



;printa a string aponda por si
;nao printa acentos
printString:
	;empilha os registradores q serão utilizados
	push ax;
	push ds
	push cx

	mov ax, 0
	mov ds,ax

	mov cl,0
	loop:
		lodsb
		cmp cl,al;como para pra ver se se zero
		je exit;se for zero fim da string
		;printa caracter q está em al
		mov ah, 0xE
		mov bh,0
		int 0x10
		jmp loop
	exit:
	;desempilha os registradores q foram utilizados
	pop cx
	pop ds
	pop ax
	ret



limpaMem:
	push cx
	mov si,nomeTemporario
	
	mov cx,0
	limpando:
	
		

		mov byte[si] ,0 
		inc si
		add cx,1
		cmp cx,20
		;inc cx
		jne limpando

	
	pop cx
	ret

;atualmente estou limpando configurando um novo tipo de video
;Há jeito melhor, mas nao sei fazer...
;Mas funciona!!
limpaTela:
	push ax
	mov ah,00h
	mov al ,03h
	int 10h
	pop ax
	
	ret

main:
	xor ax, ax
	mov es, ax
	;Zera os byte do mapa de clientes
	mov si,memoria;move para si a base do vetor nome
	mov word[si] ,0

	;Printa nome do segundo cliente
	menu:
	call limpaMem
		
		call limpaTela
		
		call printMenu
		call validaOpcao;fica na subrotina até retorna uma das opções 1,2,3,4 no registrador al
		jmp fim

	;Direciona para a opção desejada
	callOpcao1:
		call InserirCliente
		jmp menu

	callOpcao2:
		call alterarCliente
		jmp fim
	
	callOpcao3:
		call consultarCliente
		
		jmp menu

	callOpcao4:
		call desvincularCliente
		jmp fim

	callOpcao5:
		call listarAgencia
		jmp fim

	callOpcao6:
		call listarConta
		jmp fim
	
	fim:



