
; ESCREVE EM ARQUIVO A VARIÁVEL 


;
;====================================================================

;====================================================================
;
	.model	small
	.stack

	.data  
	
nomeArq db "file.txt", 00 

texto   db 4Dh, 61h,72h, 63h, 75h, 73h
	
	.code    
	.startup
   
   
   
    ;abrir arquivo
    
    mov ah, 3cH
    mov cx, 0H
    lea dx, nomeArq 
    int 21h
    mov si, ax 
    
    ;escrever no arquivo
    mov ah, 40H     ;diz que esta escrevendo  
    mov bx, si      ;
    mov cx, 7H
    lea dx, texto
    int 21H
    
             
    
    
    
fim:   
               
                                             		        
	.exit





;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------






