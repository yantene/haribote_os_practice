ipl10.bin: ipl10.nas
	nasm $< -o $@ -l ipl10.lst

haribote.sys: haribote.nas
	nasm $< -o $@ -l haribote.lst

haribote.img: ipl10.bin haribote.sys
	mkdir mnt
	cp $< $@
	dd count=$$(expr 1474560 - $$(du -b $< | cut -f 1)) bs=1 oflag=append conv=notrunc if=/dev/zero of=$@
	sudo mount -o loop,fat=12,rw,sync -t msdos $@ mnt/
	sudo cp $(word 2, $^) mnt/
	sudo umount mnt/
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
	rm -f haribote.img haribote.sys haribote.lst ipl10.bin ipl10.lst
