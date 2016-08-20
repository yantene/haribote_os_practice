ipl10.bin: ipl10.nas
	nasm $< -o $@ -l ipl10.lst

haribote.sys: haribote.nas
	nasm $< -o $@ -l haribote.lst

haribote.img: ipl10.bin haribote.sys
	../z_tools/edimg.exe imgin:../z_tools/fdimg0at.tek\
		wbinimg src:$< len:512 from:0 to:0\
		copy from:$(word 2, $^) to:@: \
		imgout:$@

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
	rm haribote.sys haribote.lst ipl10.bin ipl10.lst
