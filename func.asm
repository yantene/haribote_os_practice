[BITS 32]
        GLOBAL  io_hlt

; オブジェクトファイルのための情報
[SECTION .text]
io_hlt:                           ; void io_hlt(void);
        HLT
        RET
