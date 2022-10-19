
; CONTANDO BYTES DE UM ARQUIVO

;
;====================================================================
;como fazer? 
;   - usar variavel para somar 1 a cada caractere lido
;   (cada caractere tem 1 byte)                                                                      
;   - preciso pular o primeiro caractere                       
;              
;   - comparar com 65535                  
;   - nesse momento, quando for igual a 65536, uso uma variavel para avisar
;   - se voltar para o loop, eu aumento essa variavel
;   - se a variavel estiver em 1, paro de ler 
;   
;   - essa variavel vai ser guardada e conferida na hora da rotina q ira escrever os erros                                                                                         
;====================================================================
;
	.model	small
	.stack

	.data  

;"strings"	
arqnome     db "Arquivo-teste.txt", 00    ;variavel com nome doq eu vou ler
buffer      db 00,00,24H        ;variavel com espaco p/ oq vou ler  

msg_excedeu db "Arquivo excedeu o limite de 65536 bits", 00
          
          
;"int"
nro_bytes   dw 00               ;aqui precisam caber 2 bytes, ate 65535
nro_exc     dw 00               ;vou usar para contar em quantos bytes excedeu o tamanho     
excedeu     db 0                ;uso como flag para saber se excedeu o tamanho                                                            

primeiro_b  db 0                ;uso como flag para saber se eh o primeiro byte
    

;"variaveis pra printar na tela"

less    db 0H
more    db 0H 
printar db 0H, 24H
	                                                             
	                                                             
	.code    
	.startup

	;abrindo o arquivo    
	
  
    
    mov al, 00   
    lea dx, arqnome ;pos da memoria com nome do arquivo
    mov ah, 3dH     ;indica que vou abrir o arquivo 
    int 21H         ;executar 
    
    
    mov si, ax      ;retorna handle  (possivelmente aponta para arq)
                 
         
         
again:
              
    ;lendo o arquivo       
    cmp nro_bytes, 0FFFFH
    je  arq_excedeu 
    
    mov ah, 3fH
    mov bx, si          ;bx recebe handle
    mov cx, 1H          ;numero de bytes lidos  ;por algum motivo, preciso colocar 2 pra ler 1 char sem ' '. 
    inc nro_bytes
    
    lea dx, buffer      ;o que eu leio cai nessa variavel
    int 21H             ;executar
                       
               
    cmp ax, 0H          ;conferi se nao acabou o arquivo
    je  printo_valor    ; ou FIM, mudei aqui
    
    cmp primeiro_b, 0H   ;se for o primeiro byte, nao vou printar, mas eh preciso le-lo 
    je  pulo_pbyte 
     
     
    ;escrevendo o que li na tela 
    ;mov ah, 9H           ;eh um print, printo o que esta em dx
    ;lea dx, buffer  
    ;int 21H  
    
    jmp pulo_again   
                             
    ;
                             
pulo_pbyte: 
    mov primeiro_b, 1H
    dec nro_bytes
    
    
pulo_again:                                 
    jmp again       
   
                
 
;==============================================================================================
;escrevendo na tela valor em bytes do tamanho, em HEXA no formato big-endian   
printo_valor:      

    mov ax, nro_bytes 
                        
    
    mov less, al  
    mov more, ah  
                               
    mov bl, 10H 
    
    
    ;imprimindo MAIS significativo  
    mov al, more
     
    and al, 0F0H  ;aqui, pego o F de 22FDH, como F0  
                                           
                  ; dividimos por 10h, q equivale a fazer 4 shifts right
                  ; assim, peguei o F 
    
                   
    div bl        ;aqui transformei F0 em 0F
    call printi   ;aqui eu printo o f

     
    mov al, more  ;passei FD de novo 
     
    and al, 0FH   ;peguei o D como 0D 
    call printi   ;aqui eu printo o d 
       
   
     
    mov ax, nro_bytes                          
    ;imprimindo MENOS significativo  
       
    and al, 0F0H  ;aqui, pego o F de 22FDH, como F0  
                                          
                  ; dividimos por 10h, q equivale a fazer 4 shifts right
                  ; assim, peguei o F  
    
    mov ah, 0H
     
    ;mov bl, 10H
                   
    div bl        ;aqui transformei F0 em 0F    al <- al/bl 
    call printi   ;aqui eu printo o f

     
    mov al, less  ;passei FD de novo 
     
    and al, 0FH   ;peguei o D como 0D 
    call printi   ;aqui eu printo o d 
    
    jmp fim
            
;==============================================================================================                       
                      
arq_excedeu:
    mov excedeu, 1  
    mov ah, 9H           ;eh um print, printo o que esta em dx
    lea dx, msg_excedeu  
    int 21H 
    
    jmp printo_valor
        
    
fim:                 
                                             		        
	.exit



;--------------------------------------------------------------------
; funcao q faz conta e imprime na tela
;--------------------------------------------------------------------
      
     
; no arquivo, vamos escrever ah e depois al
     
  
printi proc near     ;al vai estar com meu valor a ser impresso

      
    cmp al, 9H       ;se for positivo eh letra   
    jl  teste
           
     
    add al, 37H      ;pego o numero, e somo 55 p/ obter seu codigo ASCII 
    jmp printarq    
    

teste:   

    add al, 30H 
         
    
     
         
printarq:
      
    ;aq eu printo na tela 
     
    mov printar, al 
      
    mov ah, 09h  ;eh um print, printo o que esta em dx  
    lea dx, printar 
    int 21h
     
    mov ah, 0H                      
    ret
        

    

printi endp 



;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------






