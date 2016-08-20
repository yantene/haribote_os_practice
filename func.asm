[BITS 32]
        GLOBAL  io_hlt, write_mem8

; オブジェクトファイルのための情報
[SECTION .text]
io_hlt:                           ; void io_hlt(void);
        HLT
        RET
