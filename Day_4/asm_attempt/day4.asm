BITS 32

SECTION        .text         
global         _start

_start:
  mov eax, 3 ; read
  mov ebx, 0 ; stdin
  mov ecx, data
  mov edx, 2
  int 0x80

  cmp byte [data], 49 ; 1 in ascii
  je _part1
  mov byte [p], 2
  jmp _read_input
_part1:
  mov byte [p], 1

_read_input:
  mov edi, data
_read_loop:
  mov eax, 3 ; read
  mov ebx, 0 ; stdin
  mov ecx, edi
  mov edx, 32
  int 0x80

  add edi, eax
  cmp eax, 32
  je _read_loop

_find_dims:
  ; count along until newline
  mov edi, data
_find_cols:
  inc edi
  cmp byte [edi], 0xa
  jne _find_cols
  mov eax, edi
  sub eax, data
  mov byte [c], al
  inc byte [r]
_find_rows:
  inc edi
  cmp byte [edi], 0x0
  je _got_dims
  cmp byte [edi], 0xa
  jne _find_rows
  inc byte [r]
  jmp _find_rows
_got_dims:
  mov esi, input_msg
  call _print_text

  mov esi, data
  call _print_text

  ; for each char: is a neighbour



_finally:
  mov edi, result
  mov byte [edi], 0x0a
  inc edi
  mov edx, 1024
  call _print_number
  mov byte [edi], 0x0a
  inc edi

  mov esi, result
  call _print_text

_exit:
  mov eax, 1
  mov ebx, 0
  int 0x80


_print_number: ; edx is the integer ; edi is destination
  xor ecx, ecx
  mov eax, edx
_get_digits:
  xor edx, edx
  mov ebx, 10
  idiv ebx; divide edx:eax by 10; result in eax, remainder in edx
  push edx
  inc ecx
  cmp eax, 0
  jne _get_digits

_print_digits:
  ;; stack contains digits of the number, ready for printing
  pop eax
  add eax, 48
  mov byte [edi], al
  inc edi
  dec ecx
  cmp ecx, 0
  jne _print_digits
  
_print_done:
  ret


_print_text: ; print string at $esi until null
  cmp byte [esi], 0
  jz _print_text_done
  mov eax, 4 ; write
  mov ebx, 1 ; stdout
  mov ecx, esi 
  mov edx, 1
  int 0x80

  inc esi
  jmp _print_text

_print_text_done:
  ret



  
  


SECTION .data
    input_msg db "Input text:", 0xa, 0x0
    data times 32000 db 0
    result times 1024 db 0
    p db 0
    r db 0
    c db 0
