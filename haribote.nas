; BOOT_INFO 関係
CYLS  EQU   0x0ff0            ; ブートセクタが設定
LEDS  EQU   0x0ff1
VMODE EQU   0x0ff2            ; 色数情報
SCRNX EQU   0x0ff4            ; screen x
SCRNY EQU   0x0ff6            ; screen y
VRAM  EQU   0x0ff8            ; グラフィックバッファの開始番地

      ORG   0xc200            ; このプログラムの読み込まれる番地

      MOV   AL, 0x13          ; VGAグラフィックス，320x200x8bitカラー
      MOV   AH, 0x00
      INT   0x10
      MOV   BYTE [VMODE], 8   ; 画面モードの記録
      MOV   WORD [SCRNX], 320
      MOV   WORD [SCRNY], 200
      MOV   DWORD [VRAM], 0x000a0000

; キーボードのLED状態をBIOSより取得
      MOV   AH, 0x02
      INT   0x16              ; keyboard BIOS
      MOV   [LEDS], AL

fin:
      HLT
      JMP fin
