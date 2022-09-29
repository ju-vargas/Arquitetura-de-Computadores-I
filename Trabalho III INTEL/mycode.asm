
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here  

;abrindo o arquivo
  
mov ah, 3dh  ;indica que vou abrir o arquivo 
mov al, 00   
mov dx, 150h ;pos da memoria com nome do arquivo
int 21h      ;executar 
mov si, ax   ;retorna handle  (possivelmente aponta para arq)
             
             
;lendo o arquivo            

mov ah, 3fh
mov bx, si
mov cx, 0Ah  ;numero de bytes lidos 
mov dx, 200h ;o que eu leio cai nessa variavel
int 21h      ;executar

 
;escrevendo na tela

mov ah, 09h  ;eh um print, printo o que esta em dx
mov dx, 200h  
int 21h

int 20h      ;encerra               
                 
  
  
  
org 150h   
     
db 'arq.txt', 00  ;variavel com nome doq eu vou ler


org 200h
db 00,00,00,00,00,00,00,00,00,00,24 ;variavel com espaco p/ oq vou ler 

;


                             

