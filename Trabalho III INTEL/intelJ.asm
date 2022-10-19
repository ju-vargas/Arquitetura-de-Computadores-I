
;====================================================================
; Juliana Rodrigues de Vargas - RP INTEL 
;====================================================================

	.model	small
	.stack

	.data  
    
    ;variaveis gerais
    
    CR equ 0dh
    LF equ 0ah
    
    MsgCRLF             db CR, LF, 00                 
                                
    print               dw ?, 24H  
                                  
	;variaveis para ler input  frase
	printFrase          db "Insira a frase:", 00, '$'
	bufferTecFrase	    db 065H dup (?)  ;adicionar o zero quando terminar de ler 
    countFrase          dw ?  

	;variaveis para ler nome do arquivo
	printNomeArquivo    db "Insira o nome do arquivo:", 00, '$' 
	bufferTecTitulo	    db 0AH dup (?),'$'   ;adicionar o zero quando terminar de ler
	 
	countTitulo         dw ?      
	bufferTecSaida      db 0AH dup (?),00, '$'  
	
	handleTxt           dw 0h
	handleKrp           dw 0h 
	
	
	;variaveis para ler arquivo 
	bufferLeitura       db 0,'$'            ;variavel com espaco p/ oq vou ler do arquivo 
    bufferChar          db 0,'$'            ;variavel com espaco p/ oq vou ler do arquivo 

	
	;variveis para contar bytes arquivo 
	msg_excedeu         db "Arquivo excedeu o limite de 65536 bits", 00, '$' 
	
	nro_bytes           dw 0                ;aqui precisam caber 2 bytes, ate 65535
    nro_exc             dw ?                ;vou usar para contar em quantos bytes excedeu o tamanho     
    excedeu             dw 0                ;uso como flag para saber se excedeu o tamanho                                                            

    primeiro_b          dw ?                ;uso como flag para saber se eh o primeiro byte
	 
	 
	;variaveis para contar bytes mensagem
	nro_bytes_input     dw ?             
	
	;variaveis para verificacao de caracteres
	nao_processaveis    dw ?                ;uso como flag para saber se existem caracteres nao processaveis
	lendoTitulo         dw 1                ;uso para saber se eh o titulo que estou lendo 
     
    ;variaveis para procura de posicoes no texto
    vetorPosicoes       dw 064H dup (?),00,'$'     ;aqui vou guardar as posicoes onde foi encontrado 
    countLoop           dw 0 
    
    auxProcura          dw ?                ;variavel para auxiliar na procura, vai armazenar o caractere
    auxPosicao          dw 0                ;variavel para auxiliar na procura, vai armazenar posicao    
    
    
    naoEncontrado       dw ?                ;variavel q vai sinalizar se algum item nao foi encontrado
    naoEncontradoGlobal dw ? 
    ; se nao for encontrado, so pulo pro aviso de erro 
    
    ;variaveis para escrever
    bufferEscritaKpr    db 0,'$' 
    zero                dw 00,00,'$'                                                                            
                                                                                                            
    ;variaveis para printar inteiro
    d1                  dw ?       
    
  
    ;variaveis para tela de saida
    erroLeitura         db "Erro na leitura do arquivo de entrada", 00, '$' 
    printTamanho        db "Tamanho do arquivo de entrada: ", 00, '$'
    printTamanhoFrase   db "Tamanho da frase:", 00, '$'
    printNomeSaida      db "Nome do arquivo de saida gerado: ", 00, '$'
    resultadoSemErro    db "Processamento realizado sem erro.", 00, '$'
    tamFraseMaior       db "Tamanho da frase maior que o limite.", 00, '$'
    fraseVazia          db "Programa encerrado. Frase vazia", 00, '$'
    caracteresNaoProc   db "Programa encerrado. Existem caracteres na frase que nao podem ser processados!", 00, '$'
    simboloNaoEncontra  db "Nao foi possivel encontrar um dos simbolos", 00, '$'
    erroArqSaida        db "Erro na criacao do arquivo de saida", 00, '$'
    bytesTexto          db " bytes.",00, '$' 
   ; erro na criacao do arquivo de saida: carry nao eh zero  
   
        
	.code    
	.startup 
	
	
;--------------------------------tratando arquivos------------------------------------------------------
	
                                      
;====================================================================
;printar "Insira o nome do arquivo: "
;====================================================================                                      

    lea     bx, printNomeArquivo
    call    print_s   
      
                                    
                                      
;====================================================================
; ler input de usuario (nome do arquivo)
; variaveis usadas: 
;   - entrada:
;   - saida:string em BufferTecTitulo
;   - registradores alterados: dx, ax, bx, cx   
;
; tambem cria o arquivo
; talvez eu precise verificar se ela tem erros so no final, passando por todo buffer
;====================================================================             
    mov		cx,0AH              ;cx eh o numero max de caracteres a serem lidos 
	lea		bx,bufferTecTitulo 
	call	ReadString 

    mov     print, 0
    mov     ax, print
    mov     countTitulo, ax 
    
    call    duplicaNome      
    call    adicionaKrp	               
                                                    
    lea     dx, bufferTecSaida   ;criei o arquivo e salvei o handle 
    call    criaArquivo          
    mov     handleKrp, si 
                              
    call    adicionaTxt            
    mov     lendoTitulo, 0
    	
;====================================================================
;printar "Insira a frase: "
;====================================================================                                        
    lea     bx, MsgCRLF  
    call    print_s
    
    lea     bx, printFrase
    call    print_s                                                     
;====================================================================
; ler input de usuario (frase)
; variaveis usadas: 
;   - entrada:
;   - saida:string em BufferTecFrase
;   - registradores alterados: dx, ax, bx, cx 
;
;====================================================================
    
    mov     countFrase, 0
     
    mov     print, 0 
	mov		cx,064H           ;cx eh o numero max de caracteres a serem lidos 
	lea		bx,bufferTecFrase 
	call	ReadString 
	
	mov     byte ptr [bx], 00 ;eh so um testeTESTE    
		
    mov     ax, print
    mov     countFrase, ax    
    cmp     countFrase, 100
    jg      frase_maior       ;frase maior q 100 caracteres da problema      
    cmp     countFrase, 0
    je      frase_vazia       ;frase com 0  caracteres da problema                                                            
    lea     bx, MsgCRLF       ;espaco em branco antes da proxima etapa  
    call    print_s                                                         
         
;====================================================================
; abrir o arquivo dado pelo usuario (frase)
; variaveis usadas: 
;   - entrada: bufferTecTitulo (nome do arquivo)
;   - saida:  
;   - registradores alterados:            
;
; coisas feitas aqui dentro:
;   - conto os bits do arquivo
;
; lembrando que quero que si guarde o handle da saida 
;
;====================================================================
           
;abrindo o arquivo                             
    mov     al, 00   
    lea     dx, bufferTecTitulo     ;pos da memoria com nome do arquivo
    mov     ah, 3dH                 ;indica que vou abrir o arquivo 
    int     21H                     ;executar  
    
    mov     si, ax                  ;retorna handle  (possivelmente aponta para arq) 
    mov     handleTxt, si
    
    jc      erro_leitura   
                                     
    mov     nro_bytes, 0            ;acredito que seja aqui
    mov     excedeu, 0


again:    
           
    ;lendo o arquivo
    cmp     nro_bytes, 0FFFFH
    je      arq_excedeu             ;testar no MASM 
    
    mov     ah, 3fH
    mov     bx, si                  ;bx recebe handle
    mov     cx, 1H                  ;numero de bytes lidos
                      
    lea     dx, bufferLeitura       ;o que eu leio cai nessa variavel
    int     21H                     ;executar
                        
               
    cmp     ax, 0                   ;conferi se nao acabou o arquivo
    je      criptografia            ;SE O ARQUIVO ACABOU DE SER LIDO VOU PARA... CRIPTOGRAFIA (ja sei tamanho)   
    
    ;escrevendo na tela   
    
    inc     nro_bytes      
    
    ;mov     ah, 9H                  ;eh um print, printo o que esta em dx
    ;lea     dx, bufferLeitura  
    ;int     21H     
          
        
pulo_again:                                 
    jmp     again                  
  
;====================================================================  
;Tratamento para quando o arquivo lido excede o numero de bytes 
;   - Escrever no arquivo de saida que deu esse erro        
;====================================================================

arq_excedeu:
    mov     excedeu, 1  
    jmp     arquivo_grande  
  
;--------------------------------criptografia---------------------------------------------------------
criptografia:        
                       
    lea     di, vetorPosicoes
    
again_frase_cripto:    

    mov     auxPosicao, 0
; fechar o arquivo com o texto e abrir de novo
    push     bx   
    push     si
    mov      bx, handleTxt
    call     fechaArquivo
    pop      si  
    pop      bx   

;abrir arquivo com texto de novo 
    mov     al, 0
    lea     dx, bufferTecTitulo   ;quero abrir arquivo TXT       
    call    abreArquivo
    mov     handleTxt, si

    ;pra desconsiderar primeiro char  
    call    getChar
    cmp     ax, 0
    je      cripto_fim 
    
    
                     
    push    di                     
     
    lea     di, bufferTecFrase
    add     di, countLoop
    
    push    dx
    mov     dx,[di]
    mov     dh, 0h
        
    
    push    ax
    mov     ax, dx
	call    toLower    ;ja transforma o caracter em minusculo
	mov     dl, al 
	pop     ax
    
        
    mov     auxProcura, dx ;(dx eh quem to procurado) 
    
    
    
    
            
    pop     dx 
    pop     di 
              
    push    dx 
    mov     dx,countFrase          
    cmp     countLoop, dx ;vendo se eu ja procurei pelo tamanho da frase
    
    je      escrevendoNoArquivo          
  
cripto_le:
                                 
                                 
    mov     ax, nro_bytes 
    dec     ax                            
    cmp     auxPosicao, ax
    je      simbolo_nao  
    
    
    
    inc     auxPosicao              ;tem a posicao de cada char
    
     
    
                                        
    call    getChar
    cmp     ax, 0
    je      cripto_fim     

    
    push    ax
    mov     ax, auxProcura
    cmp     bufferChar, al
    je      encontro_letra
                           
    pop     ax                       
    
jmp cripto_le

procura_vetor:
    push    di
    mov     dx, auxPosicao 
    lea     di, vetorPosicoes       ;endereco do vetor posicoes    
procura_vetor_loop:
    cmp     [di], 0                 ;ve se o conteudo de di eh zero
    je      encontro_letra          ;terminei de passar por ele e nao encontrei
        
    cmp     [di], dx                ;vendo se conteudo do vetor nesse end eh igual o de auxPosicao      
    je      vetor_igual             ;se for igual... 
    inc     di                      ;se nao eh igual, vou procurar na prox pos do vetor
    jmp     procura_vetor_loop         
              
vetor_igual:              
    pop     di
    jmp     cripto_le               ;vou la procurar em outro endereco
                  
encontro_letra:  
   ; pop     di 
                
    inc     di            
    mov     dx, auxPosicao    
    mov     [di], dx                ;conteudo do endereco di recebe valor de auxPosicao
 
    add di, 1     

cripto_fim:
    inc     countLoop
    jmp     again_frase_cripto    
            
;--------------------------------escrevendo no arquivo------------------------------------------------                          
escrevendoNoArquivo:            
    pop     dx 
    
    ;abri o arquivo  
    mov     al, 00   
    mov     ah, 3cH  ;checar isso aqui
    mov     cx, 0H 
    lea     dx, bufferTecSaida  ;nome do arquivo que eu quero abrir
    int 21h
    mov     si, ax 
    mov     handleKrp, si 
    
    
    ;vou escrever                                    
    push    ax
    mov     ax,countLoop
    add     countLoop, ax    
    pop     ax                 
        
    mov     ah, 40H             ;diz que esta escrevendo        
    mov     bx, handleKrp 
    mov     cx, countLoop 
    
    lea     dx, vetorPosicoes
    inc     dx    
    int 21H   
      
    ;zeros no final                                    
    push    ax
    mov     ax,countLoop
    add     countLoop, ax    
    pop     ax                 
           
    mov     ah, 40H             ;diz que esta escrevendo        
    mov     bx, handleKrp 
    mov     cx, 2 
    
    lea     dx, zero
    inc     dx    
    int 21H         
    
                                                                                     
;--------------------------------escrevendo dados de processamento na tela ----------------------------                                            
 fim_escrita:                                            
                                             
;=============================================================================    
;ARRUMAR ESSE PEDACO MAIS TARDE!!
;Escrever dados de processamento na tela          
;=============================================================================    

;Sem erros - sera chamado no final se nada de ruim acontecer
;-----------------------------------------------------------------------------
sem_erros:
        lea     bx, printTamanho
        call    print_s        

        MOV     ax,@DATA ;verificar esse @ depois
        MOV     ds,ax   
        mov     ax, nro_bytes
        mov     d1, ax
        mov     ax,d1      
        CALL    printi       
        
        lea     bx, bytesTexto
        call    print_s
         
        lea     bx, MsgCRLF  
        call    print_s  
    
        
        lea     bx, printTamanhoFrase
        call    print_s  
    
        MOV     ax,@DATA
        MOV     ds,ax   
        mov     ax, countFrase
        mov     d1, ax
        mov     ax,d1      
        CALL    printi      
                      
        lea     bx, bytesTexto
        call    print_s              
                      
        lea     bx, MsgCRLF  
        call    print_s      
                 
                   
        lea     bx, printNomeSaida
        call    print_s    
        lea     bx, bufferTecSaida
        call    print_s       
        lea     bx, MsgCRLF  
        call    print_s               
                
        lea     bx, resultadoSemErro
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s            
         
        jmp     fim
         
;Com erros - arrumar essa parte para ser printada so no final, e quando der o erro         
;-----------------------------------------------------------------------------          
erro_leitura:
        lea     bx, MsgCRLF  
        call    print_s
        lea     bx, erroLeitura ;quando nao eh gerado handle
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s  
        
        jmp     fim

arquivo_grande: 
        lea     bx, MsgCRLF  
        call    print_s
        lea     bx, msg_excedeu
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s
        
        jmp     fim    
        
frase_maior: 
        lea     bx, MsgCRLF  
        call    print_s
        lea     bx, tamFraseMaior
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s  
        
        jmp     fim
    
frase_vazia:
        lea     bx, MsgCRLF  
        call    print_s 
        lea     bx, fraseVazia
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s 
        
        jmp     fim
        
caracteres_np: 
        lea     bx, MsgCRLF  
        call    print_s
        lea     bx, caracteresNaoProc
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s   
        
        jmp     fim
    
simbolo_nao:
        lea     bx, MsgCRLF  
        call    print_s    
        lea     bx, simboloNaoEncontra
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s 
        
        jmp     fim
              
erro_saida:
        lea     bx, MsgCRLF  
        call    print_s 
        lea     bx, erroArqSaida
        call    print_s          
        lea     bx, MsgCRLF  
        call    print_s 
        
        jmp     fim
    

pre_fim:
        jmp     sem_erros


fim:   
       ;aqui supostamente funciona esse fechar
       mov      bx, handleKrp
       call     fechaArquivo
       
       ;mov      bx, handleTxt
       ;call     fechaArquivo         
                                             		        
	.exit 
		         
		         
		         
		         
		         
		         
		         
		         
		         
		         
		         
		         
                                                                   
;---------------------------------------funcoes----------------------------------------------------		         
		         	         	
;--------------------------------------------------------------------
; funcao que le do teclado
;--------------------------------------------------------------------
	

ReadString	proc	near

		;Pos = 0
		mov		dx,0

RDSTR_1:		
		mov		ah,7       ;espera pelo teclado
		int		21H                 
		cmp		al,0DH     ;vejo se recebi o CR (final da entrada)      
		jne		RDSTR_A    ;caso nao, vou para RDSTR_A    
		mov		byte ptr[bx],00 ;se sim, eh o fim da frase 	
		ret                    ;saio da rotina		

RDSTR_A:       
		cmp		al,08H     ;vejo se eh backspace (APAGAR)
		jne		RDSTR_B    ;se nao eh, pulo pra RDSTR_B
		cmp		dx,0       ;se eh na posicao 1, eu ignoro e volto pra ler a prox entrada
		jz		RDSTR_1
		dec     print      ;se nao e, diminuo o contador de letras e continuo
				                   ;Print (BS, SPACE, BS)
		push	dx         ;boto dx na pilha (dx contem posicao da letra no input (?))    
		mov		dl,08H          
		mov		ah,2
		int		21H	
		mov		dl,' '
		mov		ah,2
		int		21H	
		mov		dl,08H
		mov		ah,2
		int		21H	
		pop		dx         ;pego dx de volta

		;		--s
		dec		bx         ;diminuo o ponteiro da string
		;		++M
		inc		cx         ;aumento o numero de caracteres q podem ser aceitos, pois abri um espaco
		;		--Pos
		dec		dx         ;diminuo a pos no input (?)
		
		;	}
		jmp		RDSTR_1

RDSTR_B:         
        cmp     lendoTitulo, 1  ;serve pra eu nao ficar verificando caracteres quando for titulo
        je      continuaTitulo		       
;--------------------------------------------------------------------
;verificar se tem caracteres nao processaveis		
;   - verifico se esta no intervalo correto     
;   - se nao estiver, ligo a flag "nao processaveis"   
;--------------------------------------------------------------------                                                         
        cmp     al,20H      ;pula se menor que 21H e espaco
        jb      nao_process       
        
        cmp     al, 7EH     ;pula se maior q 7EH
        ja      nao_process              
        
        jmp     processavel 
;--------------------------------------------------------------------
nao_process:
        mov     nao_processaveis, 1H  
        jmp     caracteres_np

processavel:
        	

continuaTitulo:		
		cmp		cx,0       ;se eu posso aceitar 0 caracteres, volto para esperar um caracter,
		je		RDSTR_1
	
		cmp		al,' '     ;se a tecla q eu peguei eh menor q espaco, nao pego, volto pra ler
		jl		RDSTR_1

		cmp     al, ' '
		je      teclaEspaco ;se a tecla q eu peguei e espaco, eu nao coloco na string
		

		
		mov		[bx],al    ;se nao eh menor, coloco na minha string
		   
		
		inc     print  ;;;;;;;;;;;
		
		inc		bx         ;aumento meu ponteiro				
		dec		cx         ;diminuo quantidade q caracteres q posso pegar
		
teclaEspaco:
		inc		dx         ;aumento a pos na tela
		
		push	dx         ;colocando dx na pilha pra nao perder
		mov		dl,al
		mov		ah,2
		int		21H
		pop		dx         ;pegando de volta
		
		jmp		RDSTR_1    ;volto para ler

ReadString	endp
	                  
;--------------------------------------------------------------------
; funcao TO_LOWER, para deixar maiusculas e minusculas iguais
; recebe:
;       - letra em al
; devolve: 
;       - letra em al
;
;
;
;
; maiusculas: 41H/65(A) ate 5AH/90(Z)
; minusculas: 61H/97(a) ate 7AH/122(z)   
; maiusculo -> minuscula = somar 32/20H
;--------------------------------------------------------------------     
toLower proc near      
        
        cmp     al,41H          ;se eh menor q maiuscula sai
        jb      fim_toLower     ;se eh maior q maiuscula sai
                                
        cmp     al, 5AH
        ja      fim_toLower
        
              
        add     al, 20H         ;se eh maiuscula, vira seu correspondente em maiuscula           
        
        
fim_toLower:
    	ret
toLower endp  
;--------------------------------------------------------------------
; funcao que CRIA ARQUIVO
; devolve:
;       - handle em si 
;--------------------------------------------------------------------
criaArquivo proc near
    	 
        mov     ah, 3CH
	    mov     cx, 0  
	    mov     si, ax
	    int     21h 
	    
        jc      erro_saida   ; VERIFICAR AQUI DEPOIS
    	
    	ret
criaArquivo	endp  
           
 
;--------------------------------------------------------------------
; funcao que ABRE ARQUIVO      
; devolve:
;       - handle em si  
;--------------------------------------------------------------------
abreArquivo proc near  
        mov al, 00
     
        mov ah, 3dH  ;checar isso aqui
        mov cx, 0H 
        int 21h
        mov si, ax
    	
    	ret     
    	
abreArquivo endp   
           
           
;--------------------------------------------------------------------
; funcao que ESCREVE EM ARQUIVO   
; recebe:
;      - handle em si
;      - endereco do texto em dx
;--------------------------------------------------------------------
escreveArquivo proc near      
          
        mov ah,     40H             ;diz que esta escrevendo        
        mov cx,     065H 
        int 21H 

    	ret
escreveArquivo endp    

  
;--------------------------------------------------------------------
; funcao que LE CHAR DE ARQUIVO
; le UM char de cada vez  
; recebe:
;       - handle do arquivo em SI  
; devolve: 
;       - char em bufferChar
;--------------------------------------------------------------------
getChar proc near         
        
        mov     al, 0H
        mov     ah, 3FH 
        mov     bx, si   
    
        mov     cx, 1H              ;leio 1 byte
        lea     dx, bufferChar      ;sei que to guardando o char lido aqui 
        int 21H 
  
    	ret
getChar endp   
 
;--------------------------------------------------------------------
; funcao que FECHA O ARQUIVO      
;     recebe: handle em bx
;--------------------------------------------------------------------
fechaArquivo proc near  
     
       ; close
       ;MOV AH, 3EH
       ;MOV BX, handle
       ;INT 21H
       
        mov		al,0
	    mov		ah,3eH
    	int		21h
    	
    	ret     
    	
fechaArquivo endp  
                   
;--------------------------------------------------------------------
; funcao que printa uma string
;--------------------------------------------------------------------
                   
print_s proc near
       
       mov dl, [bx]
       cmp dl, 0h
       je rt_print_s
       
       mov ah, 02H
       int 21H
       
       inc bx
       
       jmp print_s
       
rt_print_s:

       ret
        
print_s endp     

 

;--------------------------------------------------------------------
; funcao q imprime inteiro 
; funcao com referencia da internet        
; https://www.geeksforgeeks.org/8086-program-to-print-a-16-bit-decimal-number/
;--------------------------------------------------------------------    

printi proc near          
     
        ;initialize count
        mov cx,0
        mov dx,0

label1:
        ; if ax is zero
        cmp ax,0
        je print1     
         
        ;initialize bx to 10
        mov bx,10       
         
        ; extract the last digit
        div bx                 
         
        ;push it in the stack
        push dx             
         
        ;increment the count
        inc cx             
         
        ;set dx to 0
        xor dx,dx
        jmp label1
print1:
        ;check if count
        ;is greater than zero
        cmp cx,0
        je exit
         
        ;pop the top of stack
        pop dx
         
        ;add 48 so that it
        ;represents the ASCII
        ;value of digits
        add dx,48
         
        ;interrupt to print a
        ;character
        mov ah,02h
        int 21h
         
        ;decrease the count
        dec cx
        jmp print1
exit:
        ret
        
printi endp

                                          


;--------------------------------------------------------------------
; funcao para duplicar nome
;--------------------------------------------------------------------------------
 duplicaNome    proc    near
        mov     al,0
        lea     di,bufferTecSaida
        lea     bx,bufferTecTitulo
loopSaida:
        cmp     [bx], al
        je      return
        mov     cx,[bx]
        mov     [di],cx
        inc     bx
        inc     di
        jmp     loopSaida
        
return: 
        ret      
            
duplicaNome    endp
 
;--------------------------------------------------------------------
; funcao para add kpr
;--------------------------------------------------------------------------------   

adicionaKrp   proc    near 
    
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecSaida
         
laco5:  
    mov     al,[si]
    cmp     al,0
    je      inserep2
    inc     si
    jmp     laco5 
         
inserep2:
    mov     al,'.'
    mov     [si],al    
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecSaida

laco6:  
    mov     al,[si]
    cmp     al,0
    je      insereK
    inc     si
    jmp     laco6
   
insereK:
    mov     al,'k'
    mov     [si],al        
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecSaida  
    
laco7:  
    mov     al,[si]
    cmp     al,0
    je      insertR
    inc     si
    jmp     laco7

insertR:
    mov     al,'r'
    mov     [si],al
        
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecSaida

laco8:
    mov     al,[si]
    cmp     al,0
    je      insereP
    inc     si
    jmp     laco8 
    
insereP:
    mov     al,'p'
    mov     [si],al     
    inc     si 
    mov     al,0
    mov     [si],al   
         
    ret       
    
adicionaKrp       endp     
 
 

   
;--------------------------------------------------------------------
; funcao para add txt
;--------------------------------------------------------------------------------   

adicionaTxt proc    near
           
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecTitulo 
    
laco5t:  
    mov     al,[si]
    cmp     al,0
    je      inseret2
    inc     si
    jmp     laco5t

inseret2:
    mov     al,'.'
    mov     [si],al
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecTitulo 
    
laco6t: 
    mov     al,[si]
    cmp     al,0
    je      insereT
    inc     si
    jmp     laco6t
    
insereT:
    mov     al,'t'
    mov     [si],al    
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecTitulo
    
laco7t:  
    mov     al,[si]
    cmp     al,0
    je      insereX
    inc     si
    jmp     laco7t

insereX:
    mov     al,'x'
    mov     [si],al
       
    mov     ax,@data
    mov     ds,ax
    mov     si,offset bufferTecTitulo

laco8t:  
    mov     al,[si]
    cmp     al,0
    je      insereTt
    inc     si
    jmp     laco8t      
    
insereTt:
    mov     al,'t'
    mov     [si],al
         
    inc     si 
    mov     al,0
    mov     [si],al
           
    ret       
    
adicionaTxt       endp     
                                       
;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------
                                                   
                                                                       