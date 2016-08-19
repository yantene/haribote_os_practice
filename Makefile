ipl.bin: ipl.nas
	nasm $< -o $@ -l ipl.lst

helloos.img: ipl.bin
	../z_tools/edimg.exe imgin:../z_tools/fdimg0at.tek\
    wbinimg src:$< len:512 from:0 to:0 imgout:$@

.PHONY: run
run: helloos.img
	qemu-system-i386\
    -cpu host\
    -m 64M\
    -enable-kvm\
    -boot order=a\
    -drive file=$<,format=raw,index=0,if=floppy

.PHONY: clean
clean:
	rm helloos.img ipl.bin ipl.lst
