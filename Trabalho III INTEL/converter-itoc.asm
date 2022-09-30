
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt


;
;====================================================================

;====================================================================
;
	.model	small
	.stack

	.data  
	
less    db 0H
more    db 0H 
printar db 0H, 24H
	
	.code    
	.startup
                                              
     ;CONTEXTO:                                         
                                   
     ; recebemos posicao da letra em inteiro, em 2 bytes 
     ; se o inteiro ja fosse colocado no arquivo, seria o ASCII de algo aleatorio
     ; queremos escrever o ASCII desse inteiro
     
     
     ;COMO?
                                  
     ; temos o inteiro em 2 bytes 0000 0000 0000 0000
     
     ; primeiro, queremos separar nos registradores 
             
     mov ax,22FDH  
     
     ; ah = 0010 0010  
     ;         2    2
     ; al = 1111 1101   
     ;         F    D
     
     
     ;hora de converter!
     
     ;vou ter o al salvo em less
     ;vou ter o ah salvo em more
     ;passo pra variavel 
     
     mov less, al  ;LESS eh FD
     mov more, ah  ;MORE eh 22
    
     ;imprimindo MENOS significativo  
       
     and al, 0F0H  ;aqui, pego o F de 22FDH, como F0  
                                           
                   ; dividimos por 10h, q equivale a fazer 4 shifts right
                   ; assim, peguei o F  
    
     mov ah, 0H
     
     mov bl, 10H
                   
     div bl        ;aqui transformei F0 em 0F    al <- al/bl 
     call printi   ;aqui eu printo o f

     
     mov al, less  ;passei FD de novo 
     
     and al, 0FH   ;peguei o D como 0D 
     call printi   ;aqui eu printo o d
            
     
     ;imprimindo MAIS significativo  
     mov al, more
     
     and al, 0F0H  ;aqui, pego o F de 22FDH, como F0  
                                           
                   ; dividimos por 10h, q equivale a fazer 4 shifts right
                   ; assim, peguei o F 
    
                   
     div bl       ;aqui transformei F0 em 0F
     call printi   ;aqui eu printo o f

     
     mov al, more  ;passei FD de novo 
     
     and al, 0FH   ;peguei o D como 0D 
     call printi   ;aqui eu printo o d 
      

    
    
    
    
fim:   
               
                                             		        
	.exit


;--------------------------------------------------------------------
; funcao q faz conta e imprime na tela
;--------------------------------------------------------------------
      
     
     ; no arquivo, vamos escrever al e depois ah
     
  
printi proc near   ;al vai estar com meu valor a ser impresso

      
     cmp al, 9H       ;se for positivo eh letra  
     
     jl  teste
           
     
     add al, 37H       ;pego o numero, e somo 55 p/ obter seu codigo ASCII 
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






