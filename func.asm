[BITS 32]
        GLOBAL  io_hlt, write_mem8

; オブジェクトファイルのための情報
[SECTION .text]
io_hlt:                           ; void io_hlt(void);
        HLT
        RET

write_mem8:                       ; void write_mem8(int addr, int data);
        ; C言語と連携する場合には，EAX，ECX，EDXのみ書き込みを含めて自由に使える．
        MOV     ECX, [ESP + 4]    ; [ESP + 4] に addr が入っている
        MOV     AL, [ESP + 8]     ; [ESP + 8] に data が入っている
        MOV     [ECX], AL
        RET
