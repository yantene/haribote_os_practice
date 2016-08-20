; haribote-ipl

  CYLS  EQU 10        ; どこまで読み込むか
  ORG   0x7c00        ; このプログラムがどこから読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

  JMP   SHORT entry
  DB    0x90
  DB    "HARIBOTE"    ; ブートセクタの名前を自由に書いてよい（8バイト）
  DW    512           ; 1セクタの大きさ（512にしなければいけない）
  DB    1             ; クラスタの大きさ（1セクタにしなければいけない）
  DW    1             ; FATがどこから始まるか（普通は1セクタ目からにする）
  DB    2             ; FATの個数（2にしなければいけない）
  DW    224           ; ルートディレクトリ領域の大きさ（普通は224エントリにする）
  DW    2880          ; このドライブの大きさ（2880セクタにしなければいけない）
  DB    0xf0          ; メディアのタイプ（0xf0にしなければいけない）
  DW    9             ; FAT領域の長さ（9セクタにしなければいけない）
  DW    18            ; 1トラックにいくつのセクタがあるか（18にしなければいけない）
  DW    2             ; ヘッドの数（2にしなければいけない）
  DD    0             ; パーティションを使ってないのでここは必ず0
  DD    2880          ; このドライブ大きさをもう一度書く
  DB    0, 0, 0x29    ; よくわからないけどこの値にしておくといいらしい
  DD    0xffffffff    ; たぶんボリュームシリアル番号
  DB    "HARIBOTEOS " ; ディスクの名前（11バイト）
  DB    "FAT12   "    ; フォーマットの名前（8バイト）
  RESB  18            ; とりあえず18バイトあけておく

; プログラム本体

entry:
  MOV   AX, 0         ; レジスタ初期化
  MOV   SS, AX
  MOV   SP, 0x7c00
  MOV   DS, AX

; ディスクを読む

  MOV   AX, 0x0820
  MOV   ES, AX
  MOV   CH, 0         ; シリンダ番号 (外周から80分割で0〜79)
  MOV   DH, 0         ; ヘッド番号 (表面: 0, 裏面: 1)
  MOV   CL, 2         ; セクタ番号 (360度を18分割で1〜18, 512B)

readloop:
  MOV   SI, 0         ; 失敗回数

retry:
  MOV   AH, 0x02      ; ディスク読み込み
  MOV   AL, 1         ; 読み込むセクタ数 (0x02以上にする場合制約あり)
  MOV   BX, 0         ; ES * 16 + BX が読まれる
  MOV   DL, 0x00      ; ドライブ番号 (A ドライブ)
  INT   0x13          ; ディスクBIOS呼び出し
  JNC   next          ; エラーが起きなければnext
  ADD   SI, 1         ; SI += 1
  CMP   SI, 5         ; SI <=> 5
  JAE   error         ; SI >= 5: error
  MOV   AH, 0x00
  MOV   DL, 0x00      ; A ドライブ
  INT   0x13          ; ドライブリセット
  JMP   retry

next:
  MOV   AX, ES        ; アドレスを0x200(=0x20*16)すすめる
  ADD   AX, 0x20
  MOV   ES, AX
  ADD   CL, 1         ; CL += 1, セクタ番号を加算
  CMP   CL, 18
  JBE   readloop      ; CL <= 18: readloop
  MOV   CL, 1         ; セクタ番号を1に戻す
  ADD   DH, 1         ; DH += 1, ヘッド番号を加算
  CMP   DH, 2
  JB    readloop      ; DH < 2: readloop
  MOV   DH, 0         ; ヘッド番号を0に戻す
  ADD   CH, 1         ; CH += 1, シリンダ番号を加算
  CMP   CH, CYLS
  JB    readloop      ; CH < CYLS: readloop

; 寝る

fin:
  HLT                 ; 何かあるまで寝る
  JMP   SHORT fin     ; ループ

error:
  MOV   SI, msg

putloop:
  MOV   AL, [SI]
  ADD   SI, 1         ; SIに1を足す
  CMP   AL, 0
  JE    fin
  MOV   AH, 0x0e      ; 1文字表示関数
  MOV   BX, 15        ; カラーコード
  INT   0x10          ; ビデオBIOS呼び出し
  JMP   SHORT putloop

msg:
  DB    0x0a, 0x0a    ; 改行を2つ
  DB    "load error"
  DB    0x0a          ; 改行
  DB    0

  RESB  0x1fe-($-$$) ; 0x7dfeまで0x00で埋める命令

  DB    0x55, 0xaa    ; ブートセクタの末尾2バイトを55aaに(ブートできるように)
