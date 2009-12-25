KERNEL_OBJS = boot.o gdt.o idt.o 
FORTH_OBJS = forth_core.o forth_words.o kernel_words.o kernel_video.o kernel_kbd.o test.o kernel.o 
FORTH_INC = forth_core.h forth_words.h kernel_words.h kernel_video.h 
LDFLAGS = -Tlink.ld  -melf_i386
ASFLAGS = -g -felf32
asm = nasm
naturaldocs = /usr/bin/naturaldocs

.PHONY: docs
.SUFFIXES: .fth

.fth.s:
	./forth2s.py -i $< -o $@

.s.h:
	grep '^defvar' $< | cut -d ',' -f 2 | sed -e 's/ */var_/' > $@.tmp
	grep '^def' $< | cut -d ',' -f 2 | sed -e 's/ *//' >> $@.tmp
	grep '^def' $< | cut -d ' ' -f 2 | cut -d ',' -f 1  >> $@.tmp
	sort -u $@.tmp | awk  '/^[A-Za-z_][A-Za-Z_0-9]*$$/ {print "extern " $$0}' > $@ 
	rm $@.tmp

.s.o:
	$(asm) $(ASFLAGS) $<

kernel: $(FORTH_INC) $(KERNEL_OBJS) $(FORTH_OBJS)
	ld $(LDFLAGS) -o kernel $(KERNEL_OBJS) $(FORTH_OBJS)

image: kernel
	cp -f floppy.orig.img floppy.img
	sudo losetup /dev/loop0 floppy.img
	sudo mount /dev/loop0 /mnt
	sudo cp kernel /mnt/kernel
	-sudo umount /dev/loop0
	-sudo losetup -d /dev/loop0 

run: image
	qemu  -fda floppy.img  

# Generating documentation.
# Be sure to add "s" to "Extensions:" in "Language: Assembly"
# in /usr/share/perl5/naturaldocs/Config/Languages.txt
docs: 
	$(naturaldocs) -i . -p docs -o HTML docs 

clean:
	rm -f *.o core kernel test



