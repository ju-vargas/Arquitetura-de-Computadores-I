
; LENDO ARQUIVO DE TEXTO E PRINTANDO CHAR A CHAR NA TELA


;
;====================================================================

;====================================================================
;
	.model	small
	.stack

	.data  
	
arqnome     db "arq.txt", 00  ;variavel com nome doq eu vou ler
buffer      db 00,00,24H ;variavel com espaco p/ oq vou ler 
	
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
    
    mov ah, 3fH
    mov bx, si      ;bx recebe handle
    mov cx, 2H      ;numero de bytes lidos 
    lea dx, buffer  ;o que eu leio cai nessa variavel
    int 21H         ;executar
               
               
    cmp ax, 0       ; conferi se nao acabou o arquivo
    je  fim
    
    ;escrevendo na tela
    
    mov ah, 9H      ;eh um print, printo o que esta em dx
    lea dx, buffer  
    int 21H     
            
    jmp again       
            
            
    
    
    
    
fim:   
    
    ;int 20H      ;encerra               
                                             		        
	.exit





;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------






