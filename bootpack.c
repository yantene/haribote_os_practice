void io_hlt(void);

void HariMain(void) {
  for(char *p = (char *)0xa0000; p <= (char *)0xaffff; ++p){
    *p = (int)p & 0xf;
  }
  while(1){
    io_hlt();
  }
}
