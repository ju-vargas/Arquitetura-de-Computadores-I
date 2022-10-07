
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt


;
;====================================================================

;====================================================================
;
	.model	small
	.stack

	.data  
	
bufferTec	db	064H dup (?) 
print dw 0, 24H 

	
	.code    
	.startup
      
    
                                                                            
		            
            
	mov		cx,064H           ;cx eh o numero de caracteres a serem lidos 
	lea		bx,BufferTec
	call	ReadString
	
	mov     ah, 9H            ;uso para printar quantos numeros peguei, em ASCII
    lea     dx, print
    int     21H	
                                                                 
		                                                                        
    
fim:                                                           		        
	.exit    
	
	
	
	
	
	
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

		   
		mov		byte ptr[bx],0 ;se sim, eh o fim da frase 
	
		ret                 ;saio da rotina
		

RDSTR_A:
		
		cmp		al,08H     ;vejo se eh backspace (APAGAR)
		jne		RDSTR_B    ;se nao eh, pulo pra RDSTR_B

		
		cmp		dx,0       ;se eh na posicao 1, eu ignoro e volto pra ler a prox entrada
		jz		RDSTR_1

		;		Print (BS, SPACE, BS)
		push	dx         ;boto dx na pilha (dx contem posicao da letra no input (?))    
		
		
		dec     print ;;;;;;
		
		
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
		
		cmp		cx,0       ;se eu posso aceitar 0 caracteres, volto para esperar um caracter,
		je		RDSTR_1

	
		cmp		al,' '     ;se a tecla q eu peguei eh menor q espaco, nao pego, volto pra ler
		jl		RDSTR_1

		
		mov		[bx],al    ;se nao eh menor, coloco na minha string 
		inc print  ;;;;;;;;;;;

		
		inc		bx         ;aumento meu ponteiro
				
		dec		cx         ;diminuo quantidade q caracteres q posso pegar
		
		inc		dx         ;aumento a pos na tela

		
		push	dx         ;colocando dx na pilha pra nao perder
		mov		dl,al
		mov		ah,2
		int		21H
		pop		dx         ;pegando de volta

		
		jmp		RDSTR_1    ;volto para ler

ReadString	endp




;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------



