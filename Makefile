ipl10.bin: ipl10.asm
	nasm $< -o $@

asmhead.bin: asmhead.asm
	nasm $< -o $@

func.o: func.asm
	nasm $< -felf32 -o $@

bootpack.hrb: func.o bootpack.c
	gcc -O3 -std=c11 -march=i486 -m32 -nostdlib -T hrb.ld -o $@ $^

haribote.sys: asmhead.bin bootpack.hrb
	cat $^ > $@

haribote.img: ipl10.bin haribote.sys
	cp $< $@
	dd count=$$(expr 1474560 - $$(du -b $< | cut -f 1)) bs=1 oflag=append conv=notrunc if=/dev/zero of=$@
	mkdir mnt
	fusefat -o fsname=FAT12,rw+ $@ mnt/
	cp $(word 2, $^) mnt/
	fusermount -u mnt/
	rmdir mnt

.PHONY: run
run: haribote.img
	qemu-system-i386\
    -cpu host\
    -m 64M\
    -enable-kvm\
    -boot order=a\
    -drive file=$<,format=raw,index=0,if=floppy

.PHONY: clean
clean:
	rm -f *.{bin,hrb,img,o,sys}
