
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt


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
                 
                 
    ;lendo o arquivo            
    
    mov ah, 3fH
    mov bx, si      ;bx recebe handle
    mov cx, 1H      ;numero de bytes lidos 
    lea dx, buffer  ;o que eu leio cai nessa variavel
    int 21H         ;executar
    
 
    ;escrevendo na tela
    
    mov ah, 9H      ;eh um print, printo o que esta em dx
    lea dx, buffer  
    int 21H     
            
            
            
            
            
            
    
    ;===============================
   
    ;lendo o arquivo            
    
    mov ah, 3fH
    mov bx, si      ;bx recebe handle
    mov cx, 2H      ;numero de bytes lidos 
    lea dx, buffer  ;o que eu leio cai nessa variavel
    int 21H         ;executar
    
 
    ;escrevendo na tela
    
    mov ah, 9H      ;eh um print, printo o que esta em dx
    lea dx, buffer  
    int 21H    
    
    
    ;=====================
    
    
    
    
    
    int 20H      ;encerra               
                     
      
		        
		                                     
		        
	.exit





;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------





