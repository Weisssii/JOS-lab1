
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 a0 19 10 f0       	push   $0xf01019a0
f0100050:	e8 24 09 00 00       	call   f0100979 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7f 27                	jg     f0100083 <test_backtrace+0x43>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010005c:	83 ec 04             	sub    $0x4,%esp
f010005f:	6a 00                	push   $0x0
f0100061:	6a 00                	push   $0x0
f0100063:	6a 00                	push   $0x0
f0100065:	e8 03 07 00 00       	call   f010076d <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 bc 19 10 f0       	push   $0xf01019bc
f0100076:	e8 fe 08 00 00       	call   f0100979 <cprintf>
}
f010007b:	83 c4 10             	add    $0x10,%esp
f010007e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100081:	c9                   	leave  
f0100082:	c3                   	ret    
		test_backtrace(x-1);
f0100083:	83 ec 0c             	sub    $0xc,%esp
f0100086:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100089:	50                   	push   %eax
f010008a:	e8 b1 ff ff ff       	call   f0100040 <test_backtrace>
f010008f:	83 c4 10             	add    $0x10,%esp
f0100092:	eb d9                	jmp    f010006d <test_backtrace+0x2d>

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 99 14 00 00       	call   f010154a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 a6 04 00 00       	call   f010055c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 d7 19 10 f0       	push   $0xf01019d7
f01000c3:	e8 b1 08 00 00       	call   f0100979 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 22 07 00 00       	call   f0100803 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	74 0f                	je     f0100106 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 02 07 00 00       	call   f0100803 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <_panic+0x11>
	panicstr = fmt;
f0100106:	89 35 40 29 11 f0    	mov    %esi,0xf0112940
	__asm __volatile("cli; cld");
f010010c:	fa                   	cli    
f010010d:	fc                   	cld    
	va_start(ap, fmt);
f010010e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100111:	83 ec 04             	sub    $0x4,%esp
f0100114:	ff 75 0c             	pushl  0xc(%ebp)
f0100117:	ff 75 08             	pushl  0x8(%ebp)
f010011a:	68 f2 19 10 f0       	push   $0xf01019f2
f010011f:	e8 55 08 00 00       	call   f0100979 <cprintf>
	vcprintf(fmt, ap);
f0100124:	83 c4 08             	add    $0x8,%esp
f0100127:	53                   	push   %ebx
f0100128:	56                   	push   %esi
f0100129:	e8 25 08 00 00       	call   f0100953 <vcprintf>
	cprintf("\n");
f010012e:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f0100135:	e8 3f 08 00 00       	call   f0100979 <cprintf>
f010013a:	83 c4 10             	add    $0x10,%esp
f010013d:	eb b8                	jmp    f01000f7 <_panic+0x11>

f010013f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013f:	55                   	push   %ebp
f0100140:	89 e5                	mov    %esp,%ebp
f0100142:	53                   	push   %ebx
f0100143:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100146:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100149:	ff 75 0c             	pushl  0xc(%ebp)
f010014c:	ff 75 08             	pushl  0x8(%ebp)
f010014f:	68 0a 1a 10 f0       	push   $0xf0101a0a
f0100154:	e8 20 08 00 00       	call   f0100979 <cprintf>
	vcprintf(fmt, ap);
f0100159:	83 c4 08             	add    $0x8,%esp
f010015c:	53                   	push   %ebx
f010015d:	ff 75 10             	pushl  0x10(%ebp)
f0100160:	e8 ee 07 00 00       	call   f0100953 <vcprintf>
	cprintf("\n");
f0100165:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f010016c:	e8 08 08 00 00       	call   f0100979 <cprintf>
	va_end(ap);
}
f0100171:	83 c4 10             	add    $0x10,%esp
f0100174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100177:	c9                   	leave  
f0100178:	c3                   	ret    

f0100179 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100179:	55                   	push   %ebp
f010017a:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100181:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100182:	a8 01                	test   $0x1,%al
f0100184:	74 0b                	je     f0100191 <serial_proc_data+0x18>
f0100186:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010018b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018c:	0f b6 c0             	movzbl %al,%eax
}
f010018f:	5d                   	pop    %ebp
f0100190:	c3                   	ret    
		return -1;
f0100191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100196:	eb f7                	jmp    f010018f <serial_proc_data+0x16>

f0100198 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100198:	55                   	push   %ebp
f0100199:	89 e5                	mov    %esp,%ebp
f010019b:	53                   	push   %ebx
f010019c:	83 ec 04             	sub    $0x4,%esp
f010019f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a1:	ff d3                	call   *%ebx
f01001a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a6:	74 2d                	je     f01001d5 <cons_intr+0x3d>
		if (c == 0)
f01001a8:	85 c0                	test   %eax,%eax
f01001aa:	74 f5                	je     f01001a1 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01001ac:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001b2:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b5:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001bb:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001c1:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c7:	75 d8                	jne    f01001a1 <cons_intr+0x9>
			cons.wpos = 0;
f01001c9:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001d0:	00 00 00 
f01001d3:	eb cc                	jmp    f01001a1 <cons_intr+0x9>
	}
}
f01001d5:	83 c4 04             	add    $0x4,%esp
f01001d8:	5b                   	pop    %ebx
f01001d9:	5d                   	pop    %ebp
f01001da:	c3                   	ret    

f01001db <kbd_proc_data>:
{
f01001db:	55                   	push   %ebp
f01001dc:	89 e5                	mov    %esp,%ebp
f01001de:	53                   	push   %ebx
f01001df:	83 ec 04             	sub    $0x4,%esp
f01001e2:	ba 64 00 00 00       	mov    $0x64,%edx
f01001e7:	ec                   	in     (%dx),%al
	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001e8:	a8 01                	test   $0x1,%al
f01001ea:	0f 84 f2 00 00 00    	je     f01002e2 <kbd_proc_data+0x107>
f01001f0:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f5:	ec                   	in     (%dx),%al
f01001f6:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01001f8:	3c e0                	cmp    $0xe0,%al
f01001fa:	0f 84 8e 00 00 00    	je     f010028e <kbd_proc_data+0xb3>
	} else if (data & 0x80) {
f0100200:	84 c0                	test   %al,%al
f0100202:	0f 88 99 00 00 00    	js     f01002a1 <kbd_proc_data+0xc6>
	} else if (shift & E0ESC) {
f0100208:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010020e:	f6 c1 40             	test   $0x40,%cl
f0100211:	74 0e                	je     f0100221 <kbd_proc_data+0x46>
		data |= 0x80;
f0100213:	83 c8 80             	or     $0xffffff80,%eax
f0100216:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100218:	83 e1 bf             	and    $0xffffffbf,%ecx
f010021b:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	shift |= shiftcode[data];
f0100221:	0f b6 d2             	movzbl %dl,%edx
f0100224:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f010022b:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100231:	0f b6 8a 80 1a 10 f0 	movzbl -0xfefe580(%edx),%ecx
f0100238:	31 c8                	xor    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f010023f:	89 c1                	mov    %eax,%ecx
f0100241:	83 e1 03             	and    $0x3,%ecx
f0100244:	8b 0c 8d 60 1a 10 f0 	mov    -0xfefe5a0(,%ecx,4),%ecx
f010024b:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010024f:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100252:	a8 08                	test   $0x8,%al
f0100254:	74 0d                	je     f0100263 <kbd_proc_data+0x88>
		if ('a' <= c && c <= 'z')
f0100256:	89 da                	mov    %ebx,%edx
f0100258:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010025b:	83 f9 19             	cmp    $0x19,%ecx
f010025e:	77 74                	ja     f01002d4 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100260:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100263:	f7 d0                	not    %eax
f0100265:	a8 06                	test   $0x6,%al
f0100267:	75 31                	jne    f010029a <kbd_proc_data+0xbf>
f0100269:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010026f:	75 29                	jne    f010029a <kbd_proc_data+0xbf>
		cprintf("Rebooting!\n");
f0100271:	83 ec 0c             	sub    $0xc,%esp
f0100274:	68 24 1a 10 f0       	push   $0xf0101a24
f0100279:	e8 fb 06 00 00       	call   f0100979 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100283:	ba 92 00 00 00       	mov    $0x92,%edx
f0100288:	ee                   	out    %al,(%dx)
f0100289:	83 c4 10             	add    $0x10,%esp
f010028c:	eb 0c                	jmp    f010029a <kbd_proc_data+0xbf>
		shift |= E0ESC;
f010028e:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100295:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010029a:	89 d8                	mov    %ebx,%eax
f010029c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010029f:	c9                   	leave  
f01002a0:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002a1:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01002a7:	89 cb                	mov    %ecx,%ebx
f01002a9:	83 e3 40             	and    $0x40,%ebx
f01002ac:	83 e0 7f             	and    $0x7f,%eax
f01002af:	85 db                	test   %ebx,%ebx
f01002b1:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002b4:	0f b6 d2             	movzbl %dl,%edx
f01002b7:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f01002be:	83 c8 40             	or     $0x40,%eax
f01002c1:	0f b6 c0             	movzbl %al,%eax
f01002c4:	f7 d0                	not    %eax
f01002c6:	21 c8                	and    %ecx,%eax
f01002c8:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01002cd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002d2:	eb c6                	jmp    f010029a <kbd_proc_data+0xbf>
		else if ('A' <= c && c <= 'Z')
f01002d4:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002d7:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002da:	83 fa 1a             	cmp    $0x1a,%edx
f01002dd:	0f 42 d9             	cmovb  %ecx,%ebx
f01002e0:	eb 81                	jmp    f0100263 <kbd_proc_data+0x88>
		return -1;
f01002e2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002e7:	eb b1                	jmp    f010029a <kbd_proc_data+0xbf>

f01002e9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e9:	55                   	push   %ebp
f01002ea:	89 e5                	mov    %esp,%ebp
f01002ec:	57                   	push   %edi
f01002ed:	56                   	push   %esi
f01002ee:	53                   	push   %ebx
f01002ef:	83 ec 1c             	sub    $0x1c,%esp
f01002f2:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01002f4:	bb 00 00 00 00       	mov    $0x0,%ebx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f9:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002fe:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100303:	eb 09                	jmp    f010030e <cons_putc+0x25>
f0100305:	89 ca                	mov    %ecx,%edx
f0100307:	ec                   	in     (%dx),%al
f0100308:	ec                   	in     (%dx),%al
f0100309:	ec                   	in     (%dx),%al
f010030a:	ec                   	in     (%dx),%al
	     i++)
f010030b:	83 c3 01             	add    $0x1,%ebx
f010030e:	89 f2                	mov    %esi,%edx
f0100310:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100311:	a8 20                	test   $0x20,%al
f0100313:	75 08                	jne    f010031d <cons_putc+0x34>
f0100315:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010031b:	7e e8                	jle    f0100305 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f010031d:	89 f8                	mov    %edi,%eax
f010031f:	88 45 e7             	mov    %al,-0x19(%ebp)
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100322:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100327:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100328:	bb 00 00 00 00       	mov    $0x0,%ebx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032d:	be 79 03 00 00       	mov    $0x379,%esi
f0100332:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100337:	eb 09                	jmp    f0100342 <cons_putc+0x59>
f0100339:	89 ca                	mov    %ecx,%edx
f010033b:	ec                   	in     (%dx),%al
f010033c:	ec                   	in     (%dx),%al
f010033d:	ec                   	in     (%dx),%al
f010033e:	ec                   	in     (%dx),%al
f010033f:	83 c3 01             	add    $0x1,%ebx
f0100342:	89 f2                	mov    %esi,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010034b:	7f 04                	jg     f0100351 <cons_putc+0x68>
f010034d:	84 c0                	test   %al,%al
f010034f:	79 e8                	jns    f0100339 <cons_putc+0x50>
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100351:	ba 78 03 00 00       	mov    $0x378,%edx
f0100356:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010035a:	ee                   	out    %al,(%dx)
f010035b:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100360:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100365:	ee                   	out    %al,(%dx)
f0100366:	b8 08 00 00 00       	mov    $0x8,%eax
f010036b:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f010036c:	89 fa                	mov    %edi,%edx
f010036e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100374:	89 f8                	mov    %edi,%eax
f0100376:	80 cc 07             	or     $0x7,%ah
f0100379:	85 d2                	test   %edx,%edx
f010037b:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010037e:	89 f8                	mov    %edi,%eax
f0100380:	0f b6 c0             	movzbl %al,%eax
f0100383:	83 f8 09             	cmp    $0x9,%eax
f0100386:	0f 84 b6 00 00 00    	je     f0100442 <cons_putc+0x159>
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	7e 73                	jle    f0100404 <cons_putc+0x11b>
f0100391:	83 f8 0a             	cmp    $0xa,%eax
f0100394:	0f 84 9b 00 00 00    	je     f0100435 <cons_putc+0x14c>
f010039a:	83 f8 0d             	cmp    $0xd,%eax
f010039d:	0f 85 d6 00 00 00    	jne    f0100479 <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f01003a3:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003aa:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003b0:	c1 e8 16             	shr    $0x16,%eax
f01003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003b6:	c1 e0 04             	shl    $0x4,%eax
f01003b9:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	if (crt_pos >= CRT_SIZE) {
f01003bf:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f01003c6:	cf 07 
f01003c8:	0f 87 ce 00 00 00    	ja     f010049c <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01003ce:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01003d4:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003d9:	89 ca                	mov    %ecx,%edx
f01003db:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003dc:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01003e3:	8d 71 01             	lea    0x1(%ecx),%esi
f01003e6:	89 d8                	mov    %ebx,%eax
f01003e8:	66 c1 e8 08          	shr    $0x8,%ax
f01003ec:	89 f2                	mov    %esi,%edx
f01003ee:	ee                   	out    %al,(%dx)
f01003ef:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003f4:	89 ca                	mov    %ecx,%edx
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	89 d8                	mov    %ebx,%eax
f01003f9:	89 f2                	mov    %esi,%edx
f01003fb:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003ff:	5b                   	pop    %ebx
f0100400:	5e                   	pop    %esi
f0100401:	5f                   	pop    %edi
f0100402:	5d                   	pop    %ebp
f0100403:	c3                   	ret    
	switch (c & 0xff) {
f0100404:	83 f8 08             	cmp    $0x8,%eax
f0100407:	75 70                	jne    f0100479 <cons_putc+0x190>
		if (crt_pos > 0) {
f0100409:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100410:	66 85 c0             	test   %ax,%ax
f0100413:	74 b9                	je     f01003ce <cons_putc+0xe5>
			crt_pos--;
f0100415:	83 e8 01             	sub    $0x1,%eax
f0100418:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010041e:	0f b7 c0             	movzwl %ax,%eax
f0100421:	66 81 e7 00 ff       	and    $0xff00,%di
f0100426:	83 cf 20             	or     $0x20,%edi
f0100429:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010042f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100433:	eb 8a                	jmp    f01003bf <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f0100435:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f010043c:	50 
f010043d:	e9 61 ff ff ff       	jmp    f01003a3 <cons_putc+0xba>
		cons_putc(' ');
f0100442:	b8 20 00 00 00       	mov    $0x20,%eax
f0100447:	e8 9d fe ff ff       	call   f01002e9 <cons_putc>
		cons_putc(' ');
f010044c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100451:	e8 93 fe ff ff       	call   f01002e9 <cons_putc>
		cons_putc(' ');
f0100456:	b8 20 00 00 00       	mov    $0x20,%eax
f010045b:	e8 89 fe ff ff       	call   f01002e9 <cons_putc>
		cons_putc(' ');
f0100460:	b8 20 00 00 00       	mov    $0x20,%eax
f0100465:	e8 7f fe ff ff       	call   f01002e9 <cons_putc>
		cons_putc(' ');
f010046a:	b8 20 00 00 00       	mov    $0x20,%eax
f010046f:	e8 75 fe ff ff       	call   f01002e9 <cons_putc>
f0100474:	e9 46 ff ff ff       	jmp    f01003bf <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100479:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100480:	8d 50 01             	lea    0x1(%eax),%edx
f0100483:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010048a:	0f b7 c0             	movzwl %ax,%eax
f010048d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100493:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100497:	e9 23 ff ff ff       	jmp    f01003bf <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010049c:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f01004a1:	83 ec 04             	sub    $0x4,%esp
f01004a4:	68 00 0f 00 00       	push   $0xf00
f01004a9:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004af:	52                   	push   %edx
f01004b0:	50                   	push   %eax
f01004b1:	e8 e1 10 00 00       	call   f0101597 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004b6:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004bc:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004c2:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004c8:	83 c4 10             	add    $0x10,%esp
f01004cb:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004d0:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d3:	39 d0                	cmp    %edx,%eax
f01004d5:	75 f4                	jne    f01004cb <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01004d7:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004de:	50 
f01004df:	e9 ea fe ff ff       	jmp    f01003ce <cons_putc+0xe5>

f01004e4 <serial_intr>:
	if (serial_exists)
f01004e4:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004eb:	75 02                	jne    f01004ef <serial_intr+0xb>
f01004ed:	f3 c3                	repz ret 
{
f01004ef:	55                   	push   %ebp
f01004f0:	89 e5                	mov    %esp,%ebp
f01004f2:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01004f5:	b8 79 01 10 f0       	mov    $0xf0100179,%eax
f01004fa:	e8 99 fc ff ff       	call   f0100198 <cons_intr>
}
f01004ff:	c9                   	leave  
f0100500:	c3                   	ret    

f0100501 <kbd_intr>:
{
f0100501:	55                   	push   %ebp
f0100502:	89 e5                	mov    %esp,%ebp
f0100504:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100507:	b8 db 01 10 f0       	mov    $0xf01001db,%eax
f010050c:	e8 87 fc ff ff       	call   f0100198 <cons_intr>
}
f0100511:	c9                   	leave  
f0100512:	c3                   	ret    

f0100513 <cons_getc>:
{
f0100513:	55                   	push   %ebp
f0100514:	89 e5                	mov    %esp,%ebp
f0100516:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100519:	e8 c6 ff ff ff       	call   f01004e4 <serial_intr>
	kbd_intr();
f010051e:	e8 de ff ff ff       	call   f0100501 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100523:	8b 15 20 25 11 f0    	mov    0xf0112520,%edx
	return 0;
f0100529:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f010052e:	3b 15 24 25 11 f0    	cmp    0xf0112524,%edx
f0100534:	74 18                	je     f010054e <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f0100536:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100539:	89 0d 20 25 11 f0    	mov    %ecx,0xf0112520
f010053f:	0f b6 82 20 23 11 f0 	movzbl -0xfeedce0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100546:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010054c:	74 02                	je     f0100550 <cons_getc+0x3d>
}
f010054e:	c9                   	leave  
f010054f:	c3                   	ret    
			cons.rpos = 0;
f0100550:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100557:	00 00 00 
f010055a:	eb f2                	jmp    f010054e <cons_getc+0x3b>

f010055c <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010055c:	55                   	push   %ebp
f010055d:	89 e5                	mov    %esp,%ebp
f010055f:	57                   	push   %edi
f0100560:	56                   	push   %esi
f0100561:	53                   	push   %ebx
f0100562:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100565:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010056c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100573:	5a a5 
	if (*cp != 0xA55A) {
f0100575:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010057c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100580:	0f 84 b7 00 00 00    	je     f010063d <cons_init+0xe1>
		addr_6845 = MONO_BASE;
f0100586:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f010058d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100590:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100595:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f010059b:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a0:	89 fa                	mov    %edi,%edx
f01005a2:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005a3:	8d 4f 01             	lea    0x1(%edi),%ecx
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a6:	89 ca                	mov    %ecx,%edx
f01005a8:	ec                   	in     (%dx),%al
f01005a9:	0f b6 c0             	movzbl %al,%eax
f01005ac:	c1 e0 08             	shl    $0x8,%eax
f01005af:	89 c3                	mov    %eax,%ebx
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005b1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b6:	89 fa                	mov    %edi,%edx
f01005b8:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b9:	89 ca                	mov    %ecx,%edx
f01005bb:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005bc:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	pos |= inb(addr_6845 + 1);
f01005c2:	0f b6 c0             	movzbl %al,%eax
f01005c5:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005c7:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005cd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005d2:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01005d7:	89 d8                	mov    %ebx,%eax
f01005d9:	89 ca                	mov    %ecx,%edx
f01005db:	ee                   	out    %al,(%dx)
f01005dc:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01005e1:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005e6:	89 fa                	mov    %edi,%edx
f01005e8:	ee                   	out    %al,(%dx)
f01005e9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005f3:	ee                   	out    %al,(%dx)
f01005f4:	be f9 03 00 00       	mov    $0x3f9,%esi
f01005f9:	89 d8                	mov    %ebx,%eax
f01005fb:	89 f2                	mov    %esi,%edx
f01005fd:	ee                   	out    %al,(%dx)
f01005fe:	b8 03 00 00 00       	mov    $0x3,%eax
f0100603:	89 fa                	mov    %edi,%edx
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010060b:	89 d8                	mov    %ebx,%eax
f010060d:	ee                   	out    %al,(%dx)
f010060e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100613:	89 f2                	mov    %esi,%edx
f0100615:	ee                   	out    %al,(%dx)
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100616:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010061b:	ec                   	in     (%dx),%al
f010061c:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010061e:	3c ff                	cmp    $0xff,%al
f0100620:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100627:	89 ca                	mov    %ecx,%edx
f0100629:	ec                   	in     (%dx),%al
f010062a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010062f:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100630:	80 fb ff             	cmp    $0xff,%bl
f0100633:	74 23                	je     f0100658 <cons_init+0xfc>
		cprintf("Serial port does not exist!\n");
}
f0100635:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100638:	5b                   	pop    %ebx
f0100639:	5e                   	pop    %esi
f010063a:	5f                   	pop    %edi
f010063b:	5d                   	pop    %ebp
f010063c:	c3                   	ret    
		*cp = was;
f010063d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100644:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010064b:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010064e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100653:	e9 3d ff ff ff       	jmp    f0100595 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f0100658:	83 ec 0c             	sub    $0xc,%esp
f010065b:	68 30 1a 10 f0       	push   $0xf0101a30
f0100660:	e8 14 03 00 00       	call   f0100979 <cprintf>
f0100665:	83 c4 10             	add    $0x10,%esp
}
f0100668:	eb cb                	jmp    f0100635 <cons_init+0xd9>

f010066a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010066a:	55                   	push   %ebp
f010066b:	89 e5                	mov    %esp,%ebp
f010066d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100670:	8b 45 08             	mov    0x8(%ebp),%eax
f0100673:	e8 71 fc ff ff       	call   f01002e9 <cons_putc>
}
f0100678:	c9                   	leave  
f0100679:	c3                   	ret    

f010067a <getchar>:

int
getchar(void)
{
f010067a:	55                   	push   %ebp
f010067b:	89 e5                	mov    %esp,%ebp
f010067d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100680:	e8 8e fe ff ff       	call   f0100513 <cons_getc>
f0100685:	85 c0                	test   %eax,%eax
f0100687:	74 f7                	je     f0100680 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100689:	c9                   	leave  
f010068a:	c3                   	ret    

f010068b <iscons>:

int
iscons(int fdnum)
{
f010068b:	55                   	push   %ebp
f010068c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010068e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100693:	5d                   	pop    %ebp
f0100694:	c3                   	ret    

f0100695 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100695:	55                   	push   %ebp
f0100696:	89 e5                	mov    %esp,%ebp
f0100698:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010069b:	68 80 1c 10 f0       	push   $0xf0101c80
f01006a0:	68 9e 1c 10 f0       	push   $0xf0101c9e
f01006a5:	68 a3 1c 10 f0       	push   $0xf0101ca3
f01006aa:	e8 ca 02 00 00       	call   f0100979 <cprintf>
f01006af:	83 c4 0c             	add    $0xc,%esp
f01006b2:	68 38 1d 10 f0       	push   $0xf0101d38
f01006b7:	68 ac 1c 10 f0       	push   $0xf0101cac
f01006bc:	68 a3 1c 10 f0       	push   $0xf0101ca3
f01006c1:	e8 b3 02 00 00       	call   f0100979 <cprintf>
	return 0;
}
f01006c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006cb:	c9                   	leave  
f01006cc:	c3                   	ret    

f01006cd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006cd:	55                   	push   %ebp
f01006ce:	89 e5                	mov    %esp,%ebp
f01006d0:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006d3:	68 b5 1c 10 f0       	push   $0xf0101cb5
f01006d8:	e8 9c 02 00 00       	call   f0100979 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006dd:	83 c4 08             	add    $0x8,%esp
f01006e0:	68 0c 00 10 00       	push   $0x10000c
f01006e5:	68 60 1d 10 f0       	push   $0xf0101d60
f01006ea:	e8 8a 02 00 00       	call   f0100979 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ef:	83 c4 0c             	add    $0xc,%esp
f01006f2:	68 0c 00 10 00       	push   $0x10000c
f01006f7:	68 0c 00 10 f0       	push   $0xf010000c
f01006fc:	68 88 1d 10 f0       	push   $0xf0101d88
f0100701:	e8 73 02 00 00       	call   f0100979 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100706:	83 c4 0c             	add    $0xc,%esp
f0100709:	68 89 19 10 00       	push   $0x101989
f010070e:	68 89 19 10 f0       	push   $0xf0101989
f0100713:	68 ac 1d 10 f0       	push   $0xf0101dac
f0100718:	e8 5c 02 00 00       	call   f0100979 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010071d:	83 c4 0c             	add    $0xc,%esp
f0100720:	68 00 23 11 00       	push   $0x112300
f0100725:	68 00 23 11 f0       	push   $0xf0112300
f010072a:	68 d0 1d 10 f0       	push   $0xf0101dd0
f010072f:	e8 45 02 00 00       	call   f0100979 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100734:	83 c4 0c             	add    $0xc,%esp
f0100737:	68 44 29 11 00       	push   $0x112944
f010073c:	68 44 29 11 f0       	push   $0xf0112944
f0100741:	68 f4 1d 10 f0       	push   $0xf0101df4
f0100746:	e8 2e 02 00 00       	call   f0100979 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010074b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010074e:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100753:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100758:	c1 f8 0a             	sar    $0xa,%eax
f010075b:	50                   	push   %eax
f010075c:	68 18 1e 10 f0       	push   $0xf0101e18
f0100761:	e8 13 02 00 00       	call   f0100979 <cprintf>
	return 0;
}
f0100766:	b8 00 00 00 00       	mov    $0x0,%eax
f010076b:	c9                   	leave  
f010076c:	c3                   	ret    

f010076d <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076d:	55                   	push   %ebp
f010076e:	89 e5                	mov    %esp,%ebp
f0100770:	57                   	push   %edi
f0100771:	56                   	push   %esi
f0100772:	53                   	push   %ebx
f0100773:	83 ec 3c             	sub    $0x3c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100776:	89 ee                	mov    %ebp,%esi
	// Your code here.********** !!!!

        int ebp, esp, eip;
        ebp = read_ebp();
        while(ebp != 0){
f0100778:	eb 78                	jmp    f01007f2 <mon_backtrace+0x85>
            eip = *((int*)(ebp + 4));
f010077a:	8d 5e 04             	lea    0x4(%esi),%ebx
f010077d:	8b 46 04             	mov    0x4(%esi),%eax
f0100780:	89 c7                	mov    %eax,%edi
f0100782:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            esp = ebp + 4;
            
            struct Eipdebuginfo info;
            debuginfo_eip(eip, &info);
f0100785:	83 ec 08             	sub    $0x8,%esp
f0100788:	8d 55 d0             	lea    -0x30(%ebp),%edx
f010078b:	52                   	push   %edx
f010078c:	50                   	push   %eax
f010078d:	e8 eb 02 00 00       	call   f0100a7d <debuginfo_eip>

            cprintf("ebp %08x eip %08x args",ebp,eip);// ebp & eip
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	57                   	push   %edi
f0100796:	56                   	push   %esi
f0100797:	68 ce 1c 10 f0       	push   $0xf0101cce
f010079c:	e8 d8 01 00 00       	call   f0100979 <cprintf>
f01007a1:	8d 7e 18             	lea    0x18(%esi),%edi
f01007a4:	83 c4 10             	add    $0x10,%esp
            for(int i=0 ; i<5 ; i++){ //args * 5
                esp += 4;
f01007a7:	83 c3 04             	add    $0x4,%ebx
                cprintf(" %08x", *(int*)esp);
f01007aa:	83 ec 08             	sub    $0x8,%esp
f01007ad:	ff 33                	pushl  (%ebx)
f01007af:	68 e5 1c 10 f0       	push   $0xf0101ce5
f01007b4:	e8 c0 01 00 00       	call   f0100979 <cprintf>
            for(int i=0 ; i<5 ; i++){ //args * 5
f01007b9:	83 c4 10             	add    $0x10,%esp
f01007bc:	39 fb                	cmp    %edi,%ebx
f01007be:	75 e7                	jne    f01007a7 <mon_backtrace+0x3a>
            }
            ebp = *((int*)ebp);// read outer layer ebp
f01007c0:	8b 36                	mov    (%esi),%esi
            cprintf("\t%s:%d: %.*s+%d",info.eip_file
f01007c2:	83 ec 08             	sub    $0x8,%esp
f01007c5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01007c8:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007cb:	50                   	push   %eax
f01007cc:	ff 75 d8             	pushl  -0x28(%ebp)
f01007cf:	ff 75 dc             	pushl  -0x24(%ebp)
f01007d2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007d5:	ff 75 d0             	pushl  -0x30(%ebp)
f01007d8:	68 eb 1c 10 f0       	push   $0xf0101ceb
f01007dd:	e8 97 01 00 00       	call   f0100979 <cprintf>
                                      ,info.eip_line
                                      ,info.eip_fn_namelen
                                      ,info.eip_fn_name
                                      ,eip-info.eip_fn_addr);
            cprintf("\n");
f01007e2:	83 c4 14             	add    $0x14,%esp
f01007e5:	68 2e 1a 10 f0       	push   $0xf0101a2e
f01007ea:	e8 8a 01 00 00       	call   f0100979 <cprintf>
f01007ef:	83 c4 10             	add    $0x10,%esp
        while(ebp != 0){
f01007f2:	85 f6                	test   %esi,%esi
f01007f4:	75 84                	jne    f010077a <mon_backtrace+0xd>
        }
	return 0;
}
f01007f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007fe:	5b                   	pop    %ebx
f01007ff:	5e                   	pop    %esi
f0100800:	5f                   	pop    %edi
f0100801:	5d                   	pop    %ebp
f0100802:	c3                   	ret    

f0100803 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100803:	55                   	push   %ebp
f0100804:	89 e5                	mov    %esp,%ebp
f0100806:	57                   	push   %edi
f0100807:	56                   	push   %esi
f0100808:	53                   	push   %ebx
f0100809:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010080c:	68 44 1e 10 f0       	push   $0xf0101e44
f0100811:	e8 63 01 00 00       	call   f0100979 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100816:	c7 04 24 68 1e 10 f0 	movl   $0xf0101e68,(%esp)
f010081d:	e8 57 01 00 00       	call   f0100979 <cprintf>
f0100822:	83 c4 10             	add    $0x10,%esp
f0100825:	eb 47                	jmp    f010086e <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100827:	83 ec 08             	sub    $0x8,%esp
f010082a:	0f be c0             	movsbl %al,%eax
f010082d:	50                   	push   %eax
f010082e:	68 ff 1c 10 f0       	push   $0xf0101cff
f0100833:	e8 d5 0c 00 00       	call   f010150d <strchr>
f0100838:	83 c4 10             	add    $0x10,%esp
f010083b:	85 c0                	test   %eax,%eax
f010083d:	74 0a                	je     f0100849 <monitor+0x46>
			*buf++ = 0;
f010083f:	c6 03 00             	movb   $0x0,(%ebx)
f0100842:	89 f7                	mov    %esi,%edi
f0100844:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100847:	eb 6b                	jmp    f01008b4 <monitor+0xb1>
		if (*buf == 0)
f0100849:	80 3b 00             	cmpb   $0x0,(%ebx)
f010084c:	74 73                	je     f01008c1 <monitor+0xbe>
		if (argc == MAXARGS-1) {
f010084e:	83 fe 0f             	cmp    $0xf,%esi
f0100851:	74 09                	je     f010085c <monitor+0x59>
		argv[argc++] = buf;
f0100853:	8d 7e 01             	lea    0x1(%esi),%edi
f0100856:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010085a:	eb 39                	jmp    f0100895 <monitor+0x92>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010085c:	83 ec 08             	sub    $0x8,%esp
f010085f:	6a 10                	push   $0x10
f0100861:	68 04 1d 10 f0       	push   $0xf0101d04
f0100866:	e8 0e 01 00 00       	call   f0100979 <cprintf>
f010086b:	83 c4 10             	add    $0x10,%esp

        
	while (1) {
		buf = readline("K> ");
f010086e:	83 ec 0c             	sub    $0xc,%esp
f0100871:	68 fb 1c 10 f0       	push   $0xf0101cfb
f0100876:	e8 75 0a 00 00       	call   f01012f0 <readline>
f010087b:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010087d:	83 c4 10             	add    $0x10,%esp
f0100880:	85 c0                	test   %eax,%eax
f0100882:	74 ea                	je     f010086e <monitor+0x6b>
	argv[argc] = 0;
f0100884:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f010088b:	be 00 00 00 00       	mov    $0x0,%esi
f0100890:	eb 24                	jmp    f01008b6 <monitor+0xb3>
			buf++;
f0100892:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100895:	0f b6 03             	movzbl (%ebx),%eax
f0100898:	84 c0                	test   %al,%al
f010089a:	74 18                	je     f01008b4 <monitor+0xb1>
f010089c:	83 ec 08             	sub    $0x8,%esp
f010089f:	0f be c0             	movsbl %al,%eax
f01008a2:	50                   	push   %eax
f01008a3:	68 ff 1c 10 f0       	push   $0xf0101cff
f01008a8:	e8 60 0c 00 00       	call   f010150d <strchr>
f01008ad:	83 c4 10             	add    $0x10,%esp
f01008b0:	85 c0                	test   %eax,%eax
f01008b2:	74 de                	je     f0100892 <monitor+0x8f>
			*buf++ = 0;
f01008b4:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01008b6:	0f b6 03             	movzbl (%ebx),%eax
f01008b9:	84 c0                	test   %al,%al
f01008bb:	0f 85 66 ff ff ff    	jne    f0100827 <monitor+0x24>
	argv[argc] = 0;
f01008c1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008c8:	00 
	if (argc == 0)
f01008c9:	85 f6                	test   %esi,%esi
f01008cb:	74 a1                	je     f010086e <monitor+0x6b>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008cd:	83 ec 08             	sub    $0x8,%esp
f01008d0:	68 9e 1c 10 f0       	push   $0xf0101c9e
f01008d5:	ff 75 a8             	pushl  -0x58(%ebp)
f01008d8:	e8 d2 0b 00 00       	call   f01014af <strcmp>
f01008dd:	83 c4 10             	add    $0x10,%esp
f01008e0:	85 c0                	test   %eax,%eax
f01008e2:	74 34                	je     f0100918 <monitor+0x115>
f01008e4:	83 ec 08             	sub    $0x8,%esp
f01008e7:	68 ac 1c 10 f0       	push   $0xf0101cac
f01008ec:	ff 75 a8             	pushl  -0x58(%ebp)
f01008ef:	e8 bb 0b 00 00       	call   f01014af <strcmp>
f01008f4:	83 c4 10             	add    $0x10,%esp
f01008f7:	85 c0                	test   %eax,%eax
f01008f9:	74 18                	je     f0100913 <monitor+0x110>
	cprintf("Unknown command '%s'\n", argv[0]);
f01008fb:	83 ec 08             	sub    $0x8,%esp
f01008fe:	ff 75 a8             	pushl  -0x58(%ebp)
f0100901:	68 21 1d 10 f0       	push   $0xf0101d21
f0100906:	e8 6e 00 00 00       	call   f0100979 <cprintf>
f010090b:	83 c4 10             	add    $0x10,%esp
f010090e:	e9 5b ff ff ff       	jmp    f010086e <monitor+0x6b>
	for (i = 0; i < NCOMMANDS; i++) {
f0100913:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100918:	83 ec 04             	sub    $0x4,%esp
f010091b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010091e:	ff 75 08             	pushl  0x8(%ebp)
f0100921:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100924:	52                   	push   %edx
f0100925:	56                   	push   %esi
f0100926:	ff 14 85 98 1e 10 f0 	call   *-0xfefe168(,%eax,4)
			if (runcmd(buf, tf) < 0)
f010092d:	83 c4 10             	add    $0x10,%esp
f0100930:	85 c0                	test   %eax,%eax
f0100932:	0f 89 36 ff ff ff    	jns    f010086e <monitor+0x6b>
				break;
	}
}
f0100938:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010093b:	5b                   	pop    %ebx
f010093c:	5e                   	pop    %esi
f010093d:	5f                   	pop    %edi
f010093e:	5d                   	pop    %ebp
f010093f:	c3                   	ret    

f0100940 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100940:	55                   	push   %ebp
f0100941:	89 e5                	mov    %esp,%ebp
f0100943:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100946:	ff 75 08             	pushl  0x8(%ebp)
f0100949:	e8 1c fd ff ff       	call   f010066a <cputchar>
	*cnt++;
}
f010094e:	83 c4 10             	add    $0x10,%esp
f0100951:	c9                   	leave  
f0100952:	c3                   	ret    

f0100953 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100953:	55                   	push   %ebp
f0100954:	89 e5                	mov    %esp,%ebp
f0100956:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100959:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100960:	ff 75 0c             	pushl  0xc(%ebp)
f0100963:	ff 75 08             	pushl  0x8(%ebp)
f0100966:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100969:	50                   	push   %eax
f010096a:	68 40 09 10 f0       	push   $0xf0100940
f010096f:	e8 91 04 00 00       	call   f0100e05 <vprintfmt>
	return cnt;
}
f0100974:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100977:	c9                   	leave  
f0100978:	c3                   	ret    

f0100979 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100979:	55                   	push   %ebp
f010097a:	89 e5                	mov    %esp,%ebp
f010097c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010097f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100982:	50                   	push   %eax
f0100983:	ff 75 08             	pushl  0x8(%ebp)
f0100986:	e8 c8 ff ff ff       	call   f0100953 <vcprintf>
	va_end(ap);

	return cnt;
}
f010098b:	c9                   	leave  
f010098c:	c3                   	ret    

f010098d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010098d:	55                   	push   %ebp
f010098e:	89 e5                	mov    %esp,%ebp
f0100990:	57                   	push   %edi
f0100991:	56                   	push   %esi
f0100992:	53                   	push   %ebx
f0100993:	83 ec 14             	sub    $0x14,%esp
f0100996:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100999:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010099c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010099f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009a2:	8b 32                	mov    (%edx),%esi
f01009a4:	8b 01                	mov    (%ecx),%eax
f01009a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009a9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009b0:	eb 2f                	jmp    f01009e1 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01009b2:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01009b5:	39 c6                	cmp    %eax,%esi
f01009b7:	7f 49                	jg     f0100a02 <stab_binsearch+0x75>
f01009b9:	0f b6 0a             	movzbl (%edx),%ecx
f01009bc:	83 ea 0c             	sub    $0xc,%edx
f01009bf:	39 f9                	cmp    %edi,%ecx
f01009c1:	75 ef                	jne    f01009b2 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009c3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009c6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009c9:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009cd:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009d0:	73 35                	jae    f0100a07 <stab_binsearch+0x7a>
			*region_left = m;
f01009d2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009d5:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01009d7:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01009da:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01009e1:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01009e4:	7f 4e                	jg     f0100a34 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01009e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009e9:	01 f0                	add    %esi,%eax
f01009eb:	89 c3                	mov    %eax,%ebx
f01009ed:	c1 eb 1f             	shr    $0x1f,%ebx
f01009f0:	01 c3                	add    %eax,%ebx
f01009f2:	d1 fb                	sar    %ebx
f01009f4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009f7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009fa:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01009fe:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100a00:	eb b3                	jmp    f01009b5 <stab_binsearch+0x28>
			l = true_m + 1;
f0100a02:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100a05:	eb da                	jmp    f01009e1 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100a07:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a0a:	76 14                	jbe    f0100a20 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100a0c:	83 e8 01             	sub    $0x1,%eax
f0100a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a12:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100a15:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100a17:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a1e:	eb c1                	jmp    f01009e1 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a20:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a23:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a25:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a29:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100a2b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a32:	eb ad                	jmp    f01009e1 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100a34:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a38:	74 16                	je     f0100a50 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a3d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a3f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a42:	8b 0e                	mov    (%esi),%ecx
f0100a44:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a47:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a4a:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100a4e:	eb 12                	jmp    f0100a62 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100a50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a53:	8b 00                	mov    (%eax),%eax
f0100a55:	83 e8 01             	sub    $0x1,%eax
f0100a58:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100a5b:	89 07                	mov    %eax,(%edi)
f0100a5d:	eb 16                	jmp    f0100a75 <stab_binsearch+0xe8>
		     l--)
f0100a5f:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100a62:	39 c1                	cmp    %eax,%ecx
f0100a64:	7d 0a                	jge    f0100a70 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100a66:	0f b6 1a             	movzbl (%edx),%ebx
f0100a69:	83 ea 0c             	sub    $0xc,%edx
f0100a6c:	39 fb                	cmp    %edi,%ebx
f0100a6e:	75 ef                	jne    f0100a5f <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100a70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a73:	89 07                	mov    %eax,(%edi)
	}
}
f0100a75:	83 c4 14             	add    $0x14,%esp
f0100a78:	5b                   	pop    %ebx
f0100a79:	5e                   	pop    %esi
f0100a7a:	5f                   	pop    %edi
f0100a7b:	5d                   	pop    %ebp
f0100a7c:	c3                   	ret    

f0100a7d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a7d:	55                   	push   %ebp
f0100a7e:	89 e5                	mov    %esp,%ebp
f0100a80:	57                   	push   %edi
f0100a81:	56                   	push   %esi
f0100a82:	53                   	push   %ebx
f0100a83:	83 ec 3c             	sub    $0x3c,%esp
f0100a86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a89:	c7 03 a8 1e 10 f0    	movl   $0xf0101ea8,(%ebx)
	info->eip_line = 0;
f0100a8f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a96:	c7 43 08 a8 1e 10 f0 	movl   $0xf0101ea8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a9d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100aa4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100aa7:	89 43 10             	mov    %eax,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100aaa:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)


	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ab1:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0100ab6:	0f 86 02 01 00 00    	jbe    f0100bbe <debuginfo_eip+0x141>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100abc:	b8 05 78 10 f0       	mov    $0xf0107805,%eax
f0100ac1:	3d 4d 5e 10 f0       	cmp    $0xf0105e4d,%eax
f0100ac6:	0f 86 34 02 00 00    	jbe    f0100d00 <debuginfo_eip+0x283>
f0100acc:	80 3d 04 78 10 f0 00 	cmpb   $0x0,0xf0107804
f0100ad3:	0f 85 2e 02 00 00    	jne    f0100d07 <debuginfo_eip+0x28a>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ad9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ae0:	b8 4c 5e 10 f0       	mov    $0xf0105e4c,%eax
f0100ae5:	2d f0 20 10 f0       	sub    $0xf01020f0,%eax
f0100aea:	c1 f8 02             	sar    $0x2,%eax
f0100aed:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100af3:	83 e8 01             	sub    $0x1,%eax
f0100af6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100af9:	83 ec 08             	sub    $0x8,%esp
f0100afc:	ff 75 08             	pushl  0x8(%ebp)
f0100aff:	6a 64                	push   $0x64
f0100b01:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b04:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b07:	b8 f0 20 10 f0       	mov    $0xf01020f0,%eax
f0100b0c:	e8 7c fe ff ff       	call   f010098d <stab_binsearch>
	if (lfile == 0)
f0100b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b14:	83 c4 10             	add    $0x10,%esp
f0100b17:	85 c0                	test   %eax,%eax
f0100b19:	0f 84 ef 01 00 00    	je     f0100d0e <debuginfo_eip+0x291>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b1f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b22:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b25:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b28:	83 ec 08             	sub    $0x8,%esp
f0100b2b:	ff 75 08             	pushl  0x8(%ebp)
f0100b2e:	6a 24                	push   $0x24
f0100b30:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b33:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b36:	b8 f0 20 10 f0       	mov    $0xf01020f0,%eax
f0100b3b:	e8 4d fe ff ff       	call   f010098d <stab_binsearch>

	if (lfun <= rfun) {
f0100b40:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b43:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b46:	83 c4 10             	add    $0x10,%esp
f0100b49:	39 d0                	cmp    %edx,%eax
f0100b4b:	0f 8f 84 00 00 00    	jg     f0100bd5 <debuginfo_eip+0x158>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b51:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b54:	c1 e1 02             	shl    $0x2,%ecx
f0100b57:	8d b9 f0 20 10 f0    	lea    -0xfefdf10(%ecx),%edi
f0100b5d:	8b b1 f0 20 10 f0    	mov    -0xfefdf10(%ecx),%esi
f0100b63:	b9 05 78 10 f0       	mov    $0xf0107805,%ecx
f0100b68:	81 e9 4d 5e 10 f0    	sub    $0xf0105e4d,%ecx
f0100b6e:	39 ce                	cmp    %ecx,%esi
f0100b70:	73 09                	jae    f0100b7b <debuginfo_eip+0xfe>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b72:	81 c6 4d 5e 10 f0    	add    $0xf0105e4d,%esi
f0100b78:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b7b:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b7e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100b81:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0100b84:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100b87:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b8a:	83 ec 08             	sub    $0x8,%esp
f0100b8d:	6a 3a                	push   $0x3a
f0100b8f:	ff 73 08             	pushl  0x8(%ebx)
f0100b92:	e8 97 09 00 00       	call   f010152e <strfind>
f0100b97:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b9a:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ba0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ba3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ba6:	8d 14 95 f4 20 10 f0 	lea    -0xfefdf0c(,%edx,4),%edx
f0100bad:	83 c4 10             	add    $0x10,%esp
f0100bb0:	c6 45 c7 00          	movb   $0x0,-0x39(%ebp)
f0100bb4:	be 01 00 00 00       	mov    $0x1,%esi
f0100bb9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100bbc:	eb 36                	jmp    f0100bf4 <debuginfo_eip+0x177>
  	        panic("User address");
f0100bbe:	83 ec 04             	sub    $0x4,%esp
f0100bc1:	68 b2 1e 10 f0       	push   $0xf0101eb2
f0100bc6:	68 81 00 00 00       	push   $0x81
f0100bcb:	68 bf 1e 10 f0       	push   $0xf0101ebf
f0100bd0:	e8 11 f5 ff ff       	call   f01000e6 <_panic>
		info->eip_fn_addr = addr;
f0100bd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bd8:	89 43 10             	mov    %eax,0x10(%ebx)
		lline = lfile;
f0100bdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bde:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100be1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100be7:	eb a1                	jmp    f0100b8a <debuginfo_eip+0x10d>
f0100be9:	83 e8 01             	sub    $0x1,%eax
f0100bec:	83 ea 0c             	sub    $0xc,%edx
f0100bef:	89 f3                	mov    %esi,%ebx
f0100bf1:	88 5d c7             	mov    %bl,-0x39(%ebp)
f0100bf4:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100bf7:	39 c7                	cmp    %eax,%edi
f0100bf9:	7f 24                	jg     f0100c1f <debuginfo_eip+0x1a2>
	       && stabs[lline].n_type != N_SOL
f0100bfb:	0f b6 0a             	movzbl (%edx),%ecx
f0100bfe:	80 f9 84             	cmp    $0x84,%cl
f0100c01:	74 55                	je     f0100c58 <debuginfo_eip+0x1db>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c03:	80 f9 64             	cmp    $0x64,%cl
f0100c06:	75 e1                	jne    f0100be9 <debuginfo_eip+0x16c>
f0100c08:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100c0c:	74 db                	je     f0100be9 <debuginfo_eip+0x16c>
f0100c0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100c11:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0100c15:	74 4a                	je     f0100c61 <debuginfo_eip+0x1e4>
f0100c17:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100c1a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100c1d:	eb 42                	jmp    f0100c61 <debuginfo_eip+0x1e4>
f0100c1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100c22:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0100c26:	75 2b                	jne    f0100c53 <debuginfo_eip+0x1d6>
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c28:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c2b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100c2e:	39 f2                	cmp    %esi,%edx
f0100c30:	0f 8d 87 00 00 00    	jge    f0100cbd <debuginfo_eip+0x240>
		for (lline = lfun + 1;
f0100c36:	83 c2 01             	add    $0x1,%edx
f0100c39:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0100c3c:	89 d0                	mov    %edx,%eax
f0100c3e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c41:	8d 14 95 f4 20 10 f0 	lea    -0xfefdf0c(,%edx,4),%edx
f0100c48:	c6 45 c7 00          	movb   $0x0,-0x39(%ebp)
f0100c4c:	bf 01 00 00 00       	mov    $0x1,%edi
f0100c51:	eb 41                	jmp    f0100c94 <debuginfo_eip+0x217>
f0100c53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100c56:	eb d0                	jmp    f0100c28 <debuginfo_eip+0x1ab>
f0100c58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100c5b:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0100c5f:	75 22                	jne    f0100c83 <debuginfo_eip+0x206>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c61:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c64:	8b 14 85 f0 20 10 f0 	mov    -0xfefdf10(,%eax,4),%edx
f0100c6b:	b8 05 78 10 f0       	mov    $0xf0107805,%eax
f0100c70:	2d 4d 5e 10 f0       	sub    $0xf0105e4d,%eax
f0100c75:	39 c2                	cmp    %eax,%edx
f0100c77:	73 af                	jae    f0100c28 <debuginfo_eip+0x1ab>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c79:	81 c2 4d 5e 10 f0    	add    $0xf0105e4d,%edx
f0100c7f:	89 13                	mov    %edx,(%ebx)
f0100c81:	eb a5                	jmp    f0100c28 <debuginfo_eip+0x1ab>
f0100c83:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100c86:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100c89:	eb d6                	jmp    f0100c61 <debuginfo_eip+0x1e4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c8b:	83 43 14 01          	addl   $0x1,0x14(%ebx)
f0100c8f:	89 f9                	mov    %edi,%ecx
f0100c91:	88 4d c7             	mov    %cl,-0x39(%ebp)
f0100c94:	89 45 c0             	mov    %eax,-0x40(%ebp)
		for (lline = lfun + 1;
f0100c97:	39 c6                	cmp    %eax,%esi
f0100c99:	7e 1c                	jle    f0100cb7 <debuginfo_eip+0x23a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c9b:	0f b6 0a             	movzbl (%edx),%ecx
f0100c9e:	83 c0 01             	add    $0x1,%eax
f0100ca1:	83 c2 0c             	add    $0xc,%edx
f0100ca4:	80 f9 a0             	cmp    $0xa0,%cl
f0100ca7:	74 e2                	je     f0100c8b <debuginfo_eip+0x20e>
f0100ca9:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0100cad:	74 0e                	je     f0100cbd <debuginfo_eip+0x240>
f0100caf:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100cb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100cb5:	eb 06                	jmp    f0100cbd <debuginfo_eip+0x240>
f0100cb7:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0100cbb:	75 3e                	jne    f0100cfb <debuginfo_eip+0x27e>
        
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100cbd:	83 ec 08             	sub    $0x8,%esp
f0100cc0:	ff 75 08             	pushl  0x8(%ebp)
f0100cc3:	6a 44                	push   $0x44
f0100cc5:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100cc8:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100ccb:	b8 f0 20 10 f0       	mov    $0xf01020f0,%eax
f0100cd0:	e8 b8 fc ff ff       	call   f010098d <stab_binsearch>
        if (lline > rline)
f0100cd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cd8:	83 c4 10             	add    $0x10,%esp
f0100cdb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100cde:	7f 35                	jg     f0100d15 <debuginfo_eip+0x298>
            return -1;
 
        info->eip_line = stabs[lline].n_desc;
f0100ce0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ce3:	0f b7 04 85 f6 20 10 	movzwl -0xfefdf0a(,%eax,4),%eax
f0100cea:	f0 
f0100ceb:	89 43 04             	mov    %eax,0x4(%ebx)

	return 0;
f0100cee:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cf6:	5b                   	pop    %ebx
f0100cf7:	5e                   	pop    %esi
f0100cf8:	5f                   	pop    %edi
f0100cf9:	5d                   	pop    %ebp
f0100cfa:	c3                   	ret    
f0100cfb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100cfe:	eb bd                	jmp    f0100cbd <debuginfo_eip+0x240>
		return -1;
f0100d00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d05:	eb ec                	jmp    f0100cf3 <debuginfo_eip+0x276>
f0100d07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d0c:	eb e5                	jmp    f0100cf3 <debuginfo_eip+0x276>
		return -1;
f0100d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d13:	eb de                	jmp    f0100cf3 <debuginfo_eip+0x276>
            return -1;
f0100d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d1a:	eb d7                	jmp    f0100cf3 <debuginfo_eip+0x276>

f0100d1c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d1c:	55                   	push   %ebp
f0100d1d:	89 e5                	mov    %esp,%ebp
f0100d1f:	57                   	push   %edi
f0100d20:	56                   	push   %esi
f0100d21:	53                   	push   %ebx
f0100d22:	83 ec 1c             	sub    $0x1c,%esp
f0100d25:	89 c7                	mov    %eax,%edi
f0100d27:	89 d6                	mov    %edx,%esi
f0100d29:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d2c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d32:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d35:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100d38:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d3d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d40:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100d43:	39 d3                	cmp    %edx,%ebx
f0100d45:	72 05                	jb     f0100d4c <printnum+0x30>
f0100d47:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d4a:	77 7a                	ja     f0100dc6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d4c:	83 ec 0c             	sub    $0xc,%esp
f0100d4f:	ff 75 18             	pushl  0x18(%ebp)
f0100d52:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d55:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d58:	53                   	push   %ebx
f0100d59:	ff 75 10             	pushl  0x10(%ebp)
f0100d5c:	83 ec 08             	sub    $0x8,%esp
f0100d5f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d62:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d65:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d68:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d6b:	e8 e0 09 00 00       	call   f0101750 <__udivdi3>
f0100d70:	83 c4 18             	add    $0x18,%esp
f0100d73:	52                   	push   %edx
f0100d74:	50                   	push   %eax
f0100d75:	89 f2                	mov    %esi,%edx
f0100d77:	89 f8                	mov    %edi,%eax
f0100d79:	e8 9e ff ff ff       	call   f0100d1c <printnum>
f0100d7e:	83 c4 20             	add    $0x20,%esp
f0100d81:	eb 13                	jmp    f0100d96 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d83:	83 ec 08             	sub    $0x8,%esp
f0100d86:	56                   	push   %esi
f0100d87:	ff 75 18             	pushl  0x18(%ebp)
f0100d8a:	ff d7                	call   *%edi
f0100d8c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100d8f:	83 eb 01             	sub    $0x1,%ebx
f0100d92:	85 db                	test   %ebx,%ebx
f0100d94:	7f ed                	jg     f0100d83 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d96:	83 ec 08             	sub    $0x8,%esp
f0100d99:	56                   	push   %esi
f0100d9a:	83 ec 04             	sub    $0x4,%esp
f0100d9d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100da0:	ff 75 e0             	pushl  -0x20(%ebp)
f0100da3:	ff 75 dc             	pushl  -0x24(%ebp)
f0100da6:	ff 75 d8             	pushl  -0x28(%ebp)
f0100da9:	e8 c2 0a 00 00       	call   f0101870 <__umoddi3>
f0100dae:	83 c4 14             	add    $0x14,%esp
f0100db1:	0f be 80 cd 1e 10 f0 	movsbl -0xfefe133(%eax),%eax
f0100db8:	50                   	push   %eax
f0100db9:	ff d7                	call   *%edi
}
f0100dbb:	83 c4 10             	add    $0x10,%esp
f0100dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dc1:	5b                   	pop    %ebx
f0100dc2:	5e                   	pop    %esi
f0100dc3:	5f                   	pop    %edi
f0100dc4:	5d                   	pop    %ebp
f0100dc5:	c3                   	ret    
f0100dc6:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100dc9:	eb c4                	jmp    f0100d8f <printnum+0x73>

f0100dcb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100dcb:	55                   	push   %ebp
f0100dcc:	89 e5                	mov    %esp,%ebp
f0100dce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100dd1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dd5:	8b 10                	mov    (%eax),%edx
f0100dd7:	3b 50 04             	cmp    0x4(%eax),%edx
f0100dda:	73 0a                	jae    f0100de6 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ddc:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100ddf:	89 08                	mov    %ecx,(%eax)
f0100de1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100de4:	88 02                	mov    %al,(%edx)
}
f0100de6:	5d                   	pop    %ebp
f0100de7:	c3                   	ret    

f0100de8 <printfmt>:
{
f0100de8:	55                   	push   %ebp
f0100de9:	89 e5                	mov    %esp,%ebp
f0100deb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100dee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100df1:	50                   	push   %eax
f0100df2:	ff 75 10             	pushl  0x10(%ebp)
f0100df5:	ff 75 0c             	pushl  0xc(%ebp)
f0100df8:	ff 75 08             	pushl  0x8(%ebp)
f0100dfb:	e8 05 00 00 00       	call   f0100e05 <vprintfmt>
}
f0100e00:	83 c4 10             	add    $0x10,%esp
f0100e03:	c9                   	leave  
f0100e04:	c3                   	ret    

f0100e05 <vprintfmt>:
{
f0100e05:	55                   	push   %ebp
f0100e06:	89 e5                	mov    %esp,%ebp
f0100e08:	57                   	push   %edi
f0100e09:	56                   	push   %esi
f0100e0a:	53                   	push   %ebx
f0100e0b:	83 ec 2c             	sub    $0x2c,%esp
f0100e0e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e14:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e17:	e9 c1 03 00 00       	jmp    f01011dd <vprintfmt+0x3d8>
		padc = ' ';
f0100e1c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100e20:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100e27:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100e2e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100e35:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100e3a:	8d 47 01             	lea    0x1(%edi),%eax
f0100e3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e40:	0f b6 17             	movzbl (%edi),%edx
f0100e43:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100e46:	3c 55                	cmp    $0x55,%al
f0100e48:	0f 87 12 04 00 00    	ja     f0101260 <vprintfmt+0x45b>
f0100e4e:	0f b6 c0             	movzbl %al,%eax
f0100e51:	ff 24 85 60 1f 10 f0 	jmp    *-0xfefe0a0(,%eax,4)
f0100e58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100e5b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100e5f:	eb d9                	jmp    f0100e3a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100e61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100e64:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e68:	eb d0                	jmp    f0100e3a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100e6a:	0f b6 d2             	movzbl %dl,%edx
f0100e6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100e70:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e75:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100e78:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e7b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100e7f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100e82:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100e85:	83 f9 09             	cmp    $0x9,%ecx
f0100e88:	77 55                	ja     f0100edf <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0100e8a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0100e8d:	eb e9                	jmp    f0100e78 <vprintfmt+0x73>
			precision = va_arg(ap, int);
f0100e8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e92:	8b 00                	mov    (%eax),%eax
f0100e94:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e97:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e9a:	8d 40 04             	lea    0x4(%eax),%eax
f0100e9d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100ea0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100ea3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ea7:	79 91                	jns    f0100e3a <vprintfmt+0x35>
				width = precision, precision = -1;
f0100ea9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100eac:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100eaf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100eb6:	eb 82                	jmp    f0100e3a <vprintfmt+0x35>
f0100eb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ebb:	85 c0                	test   %eax,%eax
f0100ebd:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ec2:	0f 49 d0             	cmovns %eax,%edx
f0100ec5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100ec8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ecb:	e9 6a ff ff ff       	jmp    f0100e3a <vprintfmt+0x35>
f0100ed0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100ed3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100eda:	e9 5b ff ff ff       	jmp    f0100e3a <vprintfmt+0x35>
f0100edf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100ee2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ee5:	eb bc                	jmp    f0100ea3 <vprintfmt+0x9e>
			lflag++;
f0100ee7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100eea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100eed:	e9 48 ff ff ff       	jmp    f0100e3a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0100ef2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef5:	8d 78 04             	lea    0x4(%eax),%edi
f0100ef8:	83 ec 08             	sub    $0x8,%esp
f0100efb:	53                   	push   %ebx
f0100efc:	ff 30                	pushl  (%eax)
f0100efe:	ff d6                	call   *%esi
			break;
f0100f00:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100f03:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100f06:	e9 cf 02 00 00       	jmp    f01011da <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f0100f0b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f0e:	8d 78 04             	lea    0x4(%eax),%edi
f0100f11:	8b 00                	mov    (%eax),%eax
f0100f13:	99                   	cltd   
f0100f14:	31 d0                	xor    %edx,%eax
f0100f16:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f18:	83 f8 07             	cmp    $0x7,%eax
f0100f1b:	7f 23                	jg     f0100f40 <vprintfmt+0x13b>
f0100f1d:	8b 14 85 c0 20 10 f0 	mov    -0xfefdf40(,%eax,4),%edx
f0100f24:	85 d2                	test   %edx,%edx
f0100f26:	74 18                	je     f0100f40 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f0100f28:	52                   	push   %edx
f0100f29:	68 ee 1e 10 f0       	push   $0xf0101eee
f0100f2e:	53                   	push   %ebx
f0100f2f:	56                   	push   %esi
f0100f30:	e8 b3 fe ff ff       	call   f0100de8 <printfmt>
f0100f35:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100f38:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100f3b:	e9 9a 02 00 00       	jmp    f01011da <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f0100f40:	50                   	push   %eax
f0100f41:	68 e5 1e 10 f0       	push   $0xf0101ee5
f0100f46:	53                   	push   %ebx
f0100f47:	56                   	push   %esi
f0100f48:	e8 9b fe ff ff       	call   f0100de8 <printfmt>
f0100f4d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100f50:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100f53:	e9 82 02 00 00       	jmp    f01011da <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f0100f58:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f5b:	83 c0 04             	add    $0x4,%eax
f0100f5e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f61:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f64:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f66:	85 ff                	test   %edi,%edi
f0100f68:	b8 de 1e 10 f0       	mov    $0xf0101ede,%eax
f0100f6d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f70:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f74:	0f 8e bd 00 00 00    	jle    f0101037 <vprintfmt+0x232>
f0100f7a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f7e:	75 0e                	jne    f0100f8e <vprintfmt+0x189>
f0100f80:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f83:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f86:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f89:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100f8c:	eb 6d                	jmp    f0100ffb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f8e:	83 ec 08             	sub    $0x8,%esp
f0100f91:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f94:	57                   	push   %edi
f0100f95:	e8 50 04 00 00       	call   f01013ea <strnlen>
f0100f9a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f9d:	29 c1                	sub    %eax,%ecx
f0100f9f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100fa2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100fa5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100fa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fac:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100faf:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fb1:	eb 0f                	jmp    f0100fc2 <vprintfmt+0x1bd>
					putch(padc, putdat);
f0100fb3:	83 ec 08             	sub    $0x8,%esp
f0100fb6:	53                   	push   %ebx
f0100fb7:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fbc:	83 ef 01             	sub    $0x1,%edi
f0100fbf:	83 c4 10             	add    $0x10,%esp
f0100fc2:	85 ff                	test   %edi,%edi
f0100fc4:	7f ed                	jg     f0100fb3 <vprintfmt+0x1ae>
f0100fc6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fc9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100fcc:	85 c9                	test   %ecx,%ecx
f0100fce:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd3:	0f 49 c1             	cmovns %ecx,%eax
f0100fd6:	29 c1                	sub    %eax,%ecx
f0100fd8:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fdb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fde:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fe1:	89 cb                	mov    %ecx,%ebx
f0100fe3:	eb 16                	jmp    f0100ffb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f0100fe5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fe9:	75 31                	jne    f010101c <vprintfmt+0x217>
					putch(ch, putdat);
f0100feb:	83 ec 08             	sub    $0x8,%esp
f0100fee:	ff 75 0c             	pushl  0xc(%ebp)
f0100ff1:	50                   	push   %eax
f0100ff2:	ff 55 08             	call   *0x8(%ebp)
f0100ff5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ff8:	83 eb 01             	sub    $0x1,%ebx
f0100ffb:	83 c7 01             	add    $0x1,%edi
f0100ffe:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0101002:	0f be c2             	movsbl %dl,%eax
f0101005:	85 c0                	test   %eax,%eax
f0101007:	74 59                	je     f0101062 <vprintfmt+0x25d>
f0101009:	85 f6                	test   %esi,%esi
f010100b:	78 d8                	js     f0100fe5 <vprintfmt+0x1e0>
f010100d:	83 ee 01             	sub    $0x1,%esi
f0101010:	79 d3                	jns    f0100fe5 <vprintfmt+0x1e0>
f0101012:	89 df                	mov    %ebx,%edi
f0101014:	8b 75 08             	mov    0x8(%ebp),%esi
f0101017:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010101a:	eb 37                	jmp    f0101053 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f010101c:	0f be d2             	movsbl %dl,%edx
f010101f:	83 ea 20             	sub    $0x20,%edx
f0101022:	83 fa 5e             	cmp    $0x5e,%edx
f0101025:	76 c4                	jbe    f0100feb <vprintfmt+0x1e6>
					putch('?', putdat);
f0101027:	83 ec 08             	sub    $0x8,%esp
f010102a:	ff 75 0c             	pushl  0xc(%ebp)
f010102d:	6a 3f                	push   $0x3f
f010102f:	ff 55 08             	call   *0x8(%ebp)
f0101032:	83 c4 10             	add    $0x10,%esp
f0101035:	eb c1                	jmp    f0100ff8 <vprintfmt+0x1f3>
f0101037:	89 75 08             	mov    %esi,0x8(%ebp)
f010103a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010103d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101040:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101043:	eb b6                	jmp    f0100ffb <vprintfmt+0x1f6>
				putch(' ', putdat);
f0101045:	83 ec 08             	sub    $0x8,%esp
f0101048:	53                   	push   %ebx
f0101049:	6a 20                	push   $0x20
f010104b:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010104d:	83 ef 01             	sub    $0x1,%edi
f0101050:	83 c4 10             	add    $0x10,%esp
f0101053:	85 ff                	test   %edi,%edi
f0101055:	7f ee                	jg     f0101045 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f0101057:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010105a:	89 45 14             	mov    %eax,0x14(%ebp)
f010105d:	e9 78 01 00 00       	jmp    f01011da <vprintfmt+0x3d5>
f0101062:	89 df                	mov    %ebx,%edi
f0101064:	8b 75 08             	mov    0x8(%ebp),%esi
f0101067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010106a:	eb e7                	jmp    f0101053 <vprintfmt+0x24e>
	if (lflag >= 2)
f010106c:	83 f9 01             	cmp    $0x1,%ecx
f010106f:	7e 3f                	jle    f01010b0 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f0101071:	8b 45 14             	mov    0x14(%ebp),%eax
f0101074:	8b 50 04             	mov    0x4(%eax),%edx
f0101077:	8b 00                	mov    (%eax),%eax
f0101079:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010107c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010107f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101082:	8d 40 08             	lea    0x8(%eax),%eax
f0101085:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101088:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010108c:	79 5c                	jns    f01010ea <vprintfmt+0x2e5>
				putch('-', putdat);
f010108e:	83 ec 08             	sub    $0x8,%esp
f0101091:	53                   	push   %ebx
f0101092:	6a 2d                	push   $0x2d
f0101094:	ff d6                	call   *%esi
				num = -(long long) num;
f0101096:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101099:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010109c:	f7 da                	neg    %edx
f010109e:	83 d1 00             	adc    $0x0,%ecx
f01010a1:	f7 d9                	neg    %ecx
f01010a3:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01010a6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010ab:	e9 10 01 00 00       	jmp    f01011c0 <vprintfmt+0x3bb>
	else if (lflag)
f01010b0:	85 c9                	test   %ecx,%ecx
f01010b2:	75 1b                	jne    f01010cf <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f01010b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b7:	8b 00                	mov    (%eax),%eax
f01010b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010bc:	89 c1                	mov    %eax,%ecx
f01010be:	c1 f9 1f             	sar    $0x1f,%ecx
f01010c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c7:	8d 40 04             	lea    0x4(%eax),%eax
f01010ca:	89 45 14             	mov    %eax,0x14(%ebp)
f01010cd:	eb b9                	jmp    f0101088 <vprintfmt+0x283>
		return va_arg(*ap, long);
f01010cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d2:	8b 00                	mov    (%eax),%eax
f01010d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010d7:	89 c1                	mov    %eax,%ecx
f01010d9:	c1 f9 1f             	sar    $0x1f,%ecx
f01010dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010df:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e2:	8d 40 04             	lea    0x4(%eax),%eax
f01010e5:	89 45 14             	mov    %eax,0x14(%ebp)
f01010e8:	eb 9e                	jmp    f0101088 <vprintfmt+0x283>
			num = getint(&ap, lflag);
f01010ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01010ed:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01010f0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010f5:	e9 c6 00 00 00       	jmp    f01011c0 <vprintfmt+0x3bb>
	if (lflag >= 2)
f01010fa:	83 f9 01             	cmp    $0x1,%ecx
f01010fd:	7e 18                	jle    f0101117 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f01010ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0101102:	8b 10                	mov    (%eax),%edx
f0101104:	8b 48 04             	mov    0x4(%eax),%ecx
f0101107:	8d 40 08             	lea    0x8(%eax),%eax
f010110a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010110d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101112:	e9 a9 00 00 00       	jmp    f01011c0 <vprintfmt+0x3bb>
	else if (lflag)
f0101117:	85 c9                	test   %ecx,%ecx
f0101119:	75 1a                	jne    f0101135 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f010111b:	8b 45 14             	mov    0x14(%ebp),%eax
f010111e:	8b 10                	mov    (%eax),%edx
f0101120:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101125:	8d 40 04             	lea    0x4(%eax),%eax
f0101128:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010112b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101130:	e9 8b 00 00 00       	jmp    f01011c0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0101135:	8b 45 14             	mov    0x14(%ebp),%eax
f0101138:	8b 10                	mov    (%eax),%edx
f010113a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010113f:	8d 40 04             	lea    0x4(%eax),%eax
f0101142:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101145:	b8 0a 00 00 00       	mov    $0xa,%eax
f010114a:	eb 74                	jmp    f01011c0 <vprintfmt+0x3bb>
	if (lflag >= 2)
f010114c:	83 f9 01             	cmp    $0x1,%ecx
f010114f:	7e 15                	jle    f0101166 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f0101151:	8b 45 14             	mov    0x14(%ebp),%eax
f0101154:	8b 10                	mov    (%eax),%edx
f0101156:	8b 48 04             	mov    0x4(%eax),%ecx
f0101159:	8d 40 08             	lea    0x8(%eax),%eax
f010115c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010115f:	b8 08 00 00 00       	mov    $0x8,%eax
f0101164:	eb 5a                	jmp    f01011c0 <vprintfmt+0x3bb>
	else if (lflag)
f0101166:	85 c9                	test   %ecx,%ecx
f0101168:	75 17                	jne    f0101181 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f010116a:	8b 45 14             	mov    0x14(%ebp),%eax
f010116d:	8b 10                	mov    (%eax),%edx
f010116f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101174:	8d 40 04             	lea    0x4(%eax),%eax
f0101177:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010117a:	b8 08 00 00 00       	mov    $0x8,%eax
f010117f:	eb 3f                	jmp    f01011c0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0101181:	8b 45 14             	mov    0x14(%ebp),%eax
f0101184:	8b 10                	mov    (%eax),%edx
f0101186:	b9 00 00 00 00       	mov    $0x0,%ecx
f010118b:	8d 40 04             	lea    0x4(%eax),%eax
f010118e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101191:	b8 08 00 00 00       	mov    $0x8,%eax
f0101196:	eb 28                	jmp    f01011c0 <vprintfmt+0x3bb>
			putch('0', putdat);
f0101198:	83 ec 08             	sub    $0x8,%esp
f010119b:	53                   	push   %ebx
f010119c:	6a 30                	push   $0x30
f010119e:	ff d6                	call   *%esi
			putch('x', putdat);
f01011a0:	83 c4 08             	add    $0x8,%esp
f01011a3:	53                   	push   %ebx
f01011a4:	6a 78                	push   $0x78
f01011a6:	ff d6                	call   *%esi
			num = (unsigned long long)
f01011a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ab:	8b 10                	mov    (%eax),%edx
f01011ad:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01011b2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01011b5:	8d 40 04             	lea    0x4(%eax),%eax
f01011b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011bb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01011c0:	83 ec 0c             	sub    $0xc,%esp
f01011c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01011c7:	57                   	push   %edi
f01011c8:	ff 75 e0             	pushl  -0x20(%ebp)
f01011cb:	50                   	push   %eax
f01011cc:	51                   	push   %ecx
f01011cd:	52                   	push   %edx
f01011ce:	89 da                	mov    %ebx,%edx
f01011d0:	89 f0                	mov    %esi,%eax
f01011d2:	e8 45 fb ff ff       	call   f0100d1c <printnum>
			break;
f01011d7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01011da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01011dd:	83 c7 01             	add    $0x1,%edi
f01011e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01011e4:	83 f8 25             	cmp    $0x25,%eax
f01011e7:	0f 84 2f fc ff ff    	je     f0100e1c <vprintfmt+0x17>
			if (ch == '\0')
f01011ed:	85 c0                	test   %eax,%eax
f01011ef:	0f 84 8b 00 00 00    	je     f0101280 <vprintfmt+0x47b>
			putch(ch, putdat);
f01011f5:	83 ec 08             	sub    $0x8,%esp
f01011f8:	53                   	push   %ebx
f01011f9:	50                   	push   %eax
f01011fa:	ff d6                	call   *%esi
f01011fc:	83 c4 10             	add    $0x10,%esp
f01011ff:	eb dc                	jmp    f01011dd <vprintfmt+0x3d8>
	if (lflag >= 2)
f0101201:	83 f9 01             	cmp    $0x1,%ecx
f0101204:	7e 15                	jle    f010121b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f0101206:	8b 45 14             	mov    0x14(%ebp),%eax
f0101209:	8b 10                	mov    (%eax),%edx
f010120b:	8b 48 04             	mov    0x4(%eax),%ecx
f010120e:	8d 40 08             	lea    0x8(%eax),%eax
f0101211:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101214:	b8 10 00 00 00       	mov    $0x10,%eax
f0101219:	eb a5                	jmp    f01011c0 <vprintfmt+0x3bb>
	else if (lflag)
f010121b:	85 c9                	test   %ecx,%ecx
f010121d:	75 17                	jne    f0101236 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f010121f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101222:	8b 10                	mov    (%eax),%edx
f0101224:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101229:	8d 40 04             	lea    0x4(%eax),%eax
f010122c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010122f:	b8 10 00 00 00       	mov    $0x10,%eax
f0101234:	eb 8a                	jmp    f01011c0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0101236:	8b 45 14             	mov    0x14(%ebp),%eax
f0101239:	8b 10                	mov    (%eax),%edx
f010123b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101240:	8d 40 04             	lea    0x4(%eax),%eax
f0101243:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101246:	b8 10 00 00 00       	mov    $0x10,%eax
f010124b:	e9 70 ff ff ff       	jmp    f01011c0 <vprintfmt+0x3bb>
			putch(ch, putdat);
f0101250:	83 ec 08             	sub    $0x8,%esp
f0101253:	53                   	push   %ebx
f0101254:	6a 25                	push   $0x25
f0101256:	ff d6                	call   *%esi
			break;
f0101258:	83 c4 10             	add    $0x10,%esp
f010125b:	e9 7a ff ff ff       	jmp    f01011da <vprintfmt+0x3d5>
			putch('%', putdat);
f0101260:	83 ec 08             	sub    $0x8,%esp
f0101263:	53                   	push   %ebx
f0101264:	6a 25                	push   $0x25
f0101266:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101268:	83 c4 10             	add    $0x10,%esp
f010126b:	89 f8                	mov    %edi,%eax
f010126d:	eb 03                	jmp    f0101272 <vprintfmt+0x46d>
f010126f:	83 e8 01             	sub    $0x1,%eax
f0101272:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101276:	75 f7                	jne    f010126f <vprintfmt+0x46a>
f0101278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010127b:	e9 5a ff ff ff       	jmp    f01011da <vprintfmt+0x3d5>
}
f0101280:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101283:	5b                   	pop    %ebx
f0101284:	5e                   	pop    %esi
f0101285:	5f                   	pop    %edi
f0101286:	5d                   	pop    %ebp
f0101287:	c3                   	ret    

f0101288 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101288:	55                   	push   %ebp
f0101289:	89 e5                	mov    %esp,%ebp
f010128b:	83 ec 18             	sub    $0x18,%esp
f010128e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101291:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101294:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101297:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010129b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010129e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01012a5:	85 c0                	test   %eax,%eax
f01012a7:	74 26                	je     f01012cf <vsnprintf+0x47>
f01012a9:	85 d2                	test   %edx,%edx
f01012ab:	7e 22                	jle    f01012cf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01012ad:	ff 75 14             	pushl  0x14(%ebp)
f01012b0:	ff 75 10             	pushl  0x10(%ebp)
f01012b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01012b6:	50                   	push   %eax
f01012b7:	68 cb 0d 10 f0       	push   $0xf0100dcb
f01012bc:	e8 44 fb ff ff       	call   f0100e05 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01012c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01012c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012ca:	83 c4 10             	add    $0x10,%esp
}
f01012cd:	c9                   	leave  
f01012ce:	c3                   	ret    
		return -E_INVAL;
f01012cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01012d4:	eb f7                	jmp    f01012cd <vsnprintf+0x45>

f01012d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01012d6:	55                   	push   %ebp
f01012d7:	89 e5                	mov    %esp,%ebp
f01012d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01012dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01012df:	50                   	push   %eax
f01012e0:	ff 75 10             	pushl  0x10(%ebp)
f01012e3:	ff 75 0c             	pushl  0xc(%ebp)
f01012e6:	ff 75 08             	pushl  0x8(%ebp)
f01012e9:	e8 9a ff ff ff       	call   f0101288 <vsnprintf>
	va_end(ap);

	return rc;
}
f01012ee:	c9                   	leave  
f01012ef:	c3                   	ret    

f01012f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01012f0:	55                   	push   %ebp
f01012f1:	89 e5                	mov    %esp,%ebp
f01012f3:	57                   	push   %edi
f01012f4:	56                   	push   %esi
f01012f5:	53                   	push   %ebx
f01012f6:	83 ec 0c             	sub    $0xc,%esp
f01012f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012fc:	85 c0                	test   %eax,%eax
f01012fe:	74 11                	je     f0101311 <readline+0x21>
		cprintf("%s", prompt);
f0101300:	83 ec 08             	sub    $0x8,%esp
f0101303:	50                   	push   %eax
f0101304:	68 ee 1e 10 f0       	push   $0xf0101eee
f0101309:	e8 6b f6 ff ff       	call   f0100979 <cprintf>
f010130e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101311:	83 ec 0c             	sub    $0xc,%esp
f0101314:	6a 00                	push   $0x0
f0101316:	e8 70 f3 ff ff       	call   f010068b <iscons>
f010131b:	89 c7                	mov    %eax,%edi
f010131d:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101320:	be 00 00 00 00       	mov    $0x0,%esi
f0101325:	eb 3f                	jmp    f0101366 <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101327:	83 ec 08             	sub    $0x8,%esp
f010132a:	50                   	push   %eax
f010132b:	68 e0 20 10 f0       	push   $0xf01020e0
f0101330:	e8 44 f6 ff ff       	call   f0100979 <cprintf>
			return NULL;
f0101335:	83 c4 10             	add    $0x10,%esp
f0101338:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010133d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101340:	5b                   	pop    %ebx
f0101341:	5e                   	pop    %esi
f0101342:	5f                   	pop    %edi
f0101343:	5d                   	pop    %ebp
f0101344:	c3                   	ret    
			if (echoing)
f0101345:	85 ff                	test   %edi,%edi
f0101347:	75 05                	jne    f010134e <readline+0x5e>
			i--;
f0101349:	83 ee 01             	sub    $0x1,%esi
f010134c:	eb 18                	jmp    f0101366 <readline+0x76>
				cputchar('\b');
f010134e:	83 ec 0c             	sub    $0xc,%esp
f0101351:	6a 08                	push   $0x8
f0101353:	e8 12 f3 ff ff       	call   f010066a <cputchar>
f0101358:	83 c4 10             	add    $0x10,%esp
f010135b:	eb ec                	jmp    f0101349 <readline+0x59>
			buf[i++] = c;
f010135d:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101363:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0101366:	e8 0f f3 ff ff       	call   f010067a <getchar>
f010136b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010136d:	85 c0                	test   %eax,%eax
f010136f:	78 b6                	js     f0101327 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101371:	83 f8 08             	cmp    $0x8,%eax
f0101374:	0f 94 c2             	sete   %dl
f0101377:	83 f8 7f             	cmp    $0x7f,%eax
f010137a:	0f 94 c0             	sete   %al
f010137d:	08 c2                	or     %al,%dl
f010137f:	74 04                	je     f0101385 <readline+0x95>
f0101381:	85 f6                	test   %esi,%esi
f0101383:	7f c0                	jg     f0101345 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101385:	83 fb 1f             	cmp    $0x1f,%ebx
f0101388:	7e 1a                	jle    f01013a4 <readline+0xb4>
f010138a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101390:	7f 12                	jg     f01013a4 <readline+0xb4>
			if (echoing)
f0101392:	85 ff                	test   %edi,%edi
f0101394:	74 c7                	je     f010135d <readline+0x6d>
				cputchar(c);
f0101396:	83 ec 0c             	sub    $0xc,%esp
f0101399:	53                   	push   %ebx
f010139a:	e8 cb f2 ff ff       	call   f010066a <cputchar>
f010139f:	83 c4 10             	add    $0x10,%esp
f01013a2:	eb b9                	jmp    f010135d <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01013a4:	83 fb 0a             	cmp    $0xa,%ebx
f01013a7:	74 05                	je     f01013ae <readline+0xbe>
f01013a9:	83 fb 0d             	cmp    $0xd,%ebx
f01013ac:	75 b8                	jne    f0101366 <readline+0x76>
			if (echoing)
f01013ae:	85 ff                	test   %edi,%edi
f01013b0:	75 11                	jne    f01013c3 <readline+0xd3>
			buf[i] = 0;
f01013b2:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01013b9:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f01013be:	e9 7a ff ff ff       	jmp    f010133d <readline+0x4d>
				cputchar('\n');
f01013c3:	83 ec 0c             	sub    $0xc,%esp
f01013c6:	6a 0a                	push   $0xa
f01013c8:	e8 9d f2 ff ff       	call   f010066a <cputchar>
f01013cd:	83 c4 10             	add    $0x10,%esp
f01013d0:	eb e0                	jmp    f01013b2 <readline+0xc2>

f01013d2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01013d2:	55                   	push   %ebp
f01013d3:	89 e5                	mov    %esp,%ebp
f01013d5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01013d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01013dd:	eb 03                	jmp    f01013e2 <strlen+0x10>
		n++;
f01013df:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01013e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01013e6:	75 f7                	jne    f01013df <strlen+0xd>
	return n;
}
f01013e8:	5d                   	pop    %ebp
f01013e9:	c3                   	ret    

f01013ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01013ea:	55                   	push   %ebp
f01013eb:	89 e5                	mov    %esp,%ebp
f01013ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01013f8:	eb 03                	jmp    f01013fd <strnlen+0x13>
		n++;
f01013fa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013fd:	39 d0                	cmp    %edx,%eax
f01013ff:	74 06                	je     f0101407 <strnlen+0x1d>
f0101401:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101405:	75 f3                	jne    f01013fa <strnlen+0x10>
	return n;
}
f0101407:	5d                   	pop    %ebp
f0101408:	c3                   	ret    

f0101409 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101409:	55                   	push   %ebp
f010140a:	89 e5                	mov    %esp,%ebp
f010140c:	53                   	push   %ebx
f010140d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101410:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101413:	89 c2                	mov    %eax,%edx
f0101415:	83 c1 01             	add    $0x1,%ecx
f0101418:	83 c2 01             	add    $0x1,%edx
f010141b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010141f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101422:	84 db                	test   %bl,%bl
f0101424:	75 ef                	jne    f0101415 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101426:	5b                   	pop    %ebx
f0101427:	5d                   	pop    %ebp
f0101428:	c3                   	ret    

f0101429 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101429:	55                   	push   %ebp
f010142a:	89 e5                	mov    %esp,%ebp
f010142c:	53                   	push   %ebx
f010142d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101430:	53                   	push   %ebx
f0101431:	e8 9c ff ff ff       	call   f01013d2 <strlen>
f0101436:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101439:	ff 75 0c             	pushl  0xc(%ebp)
f010143c:	01 d8                	add    %ebx,%eax
f010143e:	50                   	push   %eax
f010143f:	e8 c5 ff ff ff       	call   f0101409 <strcpy>
	return dst;
}
f0101444:	89 d8                	mov    %ebx,%eax
f0101446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101449:	c9                   	leave  
f010144a:	c3                   	ret    

f010144b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010144b:	55                   	push   %ebp
f010144c:	89 e5                	mov    %esp,%ebp
f010144e:	56                   	push   %esi
f010144f:	53                   	push   %ebx
f0101450:	8b 75 08             	mov    0x8(%ebp),%esi
f0101453:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101456:	89 f3                	mov    %esi,%ebx
f0101458:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010145b:	89 f2                	mov    %esi,%edx
f010145d:	eb 0f                	jmp    f010146e <strncpy+0x23>
		*dst++ = *src;
f010145f:	83 c2 01             	add    $0x1,%edx
f0101462:	0f b6 01             	movzbl (%ecx),%eax
f0101465:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101468:	80 39 01             	cmpb   $0x1,(%ecx)
f010146b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010146e:	39 da                	cmp    %ebx,%edx
f0101470:	75 ed                	jne    f010145f <strncpy+0x14>
	}
	return ret;
}
f0101472:	89 f0                	mov    %esi,%eax
f0101474:	5b                   	pop    %ebx
f0101475:	5e                   	pop    %esi
f0101476:	5d                   	pop    %ebp
f0101477:	c3                   	ret    

f0101478 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101478:	55                   	push   %ebp
f0101479:	89 e5                	mov    %esp,%ebp
f010147b:	56                   	push   %esi
f010147c:	53                   	push   %ebx
f010147d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101480:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101483:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101486:	89 f0                	mov    %esi,%eax
f0101488:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010148c:	85 c9                	test   %ecx,%ecx
f010148e:	75 0b                	jne    f010149b <strlcpy+0x23>
f0101490:	eb 17                	jmp    f01014a9 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101492:	83 c2 01             	add    $0x1,%edx
f0101495:	83 c0 01             	add    $0x1,%eax
f0101498:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010149b:	39 d8                	cmp    %ebx,%eax
f010149d:	74 07                	je     f01014a6 <strlcpy+0x2e>
f010149f:	0f b6 0a             	movzbl (%edx),%ecx
f01014a2:	84 c9                	test   %cl,%cl
f01014a4:	75 ec                	jne    f0101492 <strlcpy+0x1a>
		*dst = '\0';
f01014a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01014a9:	29 f0                	sub    %esi,%eax
}
f01014ab:	5b                   	pop    %ebx
f01014ac:	5e                   	pop    %esi
f01014ad:	5d                   	pop    %ebp
f01014ae:	c3                   	ret    

f01014af <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01014af:	55                   	push   %ebp
f01014b0:	89 e5                	mov    %esp,%ebp
f01014b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01014b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01014b8:	eb 06                	jmp    f01014c0 <strcmp+0x11>
		p++, q++;
f01014ba:	83 c1 01             	add    $0x1,%ecx
f01014bd:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01014c0:	0f b6 01             	movzbl (%ecx),%eax
f01014c3:	84 c0                	test   %al,%al
f01014c5:	74 04                	je     f01014cb <strcmp+0x1c>
f01014c7:	3a 02                	cmp    (%edx),%al
f01014c9:	74 ef                	je     f01014ba <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01014cb:	0f b6 c0             	movzbl %al,%eax
f01014ce:	0f b6 12             	movzbl (%edx),%edx
f01014d1:	29 d0                	sub    %edx,%eax
}
f01014d3:	5d                   	pop    %ebp
f01014d4:	c3                   	ret    

f01014d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01014d5:	55                   	push   %ebp
f01014d6:	89 e5                	mov    %esp,%ebp
f01014d8:	53                   	push   %ebx
f01014d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014dc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014df:	89 c3                	mov    %eax,%ebx
f01014e1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01014e4:	eb 06                	jmp    f01014ec <strncmp+0x17>
		n--, p++, q++;
f01014e6:	83 c0 01             	add    $0x1,%eax
f01014e9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01014ec:	39 d8                	cmp    %ebx,%eax
f01014ee:	74 16                	je     f0101506 <strncmp+0x31>
f01014f0:	0f b6 08             	movzbl (%eax),%ecx
f01014f3:	84 c9                	test   %cl,%cl
f01014f5:	74 04                	je     f01014fb <strncmp+0x26>
f01014f7:	3a 0a                	cmp    (%edx),%cl
f01014f9:	74 eb                	je     f01014e6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01014fb:	0f b6 00             	movzbl (%eax),%eax
f01014fe:	0f b6 12             	movzbl (%edx),%edx
f0101501:	29 d0                	sub    %edx,%eax
}
f0101503:	5b                   	pop    %ebx
f0101504:	5d                   	pop    %ebp
f0101505:	c3                   	ret    
		return 0;
f0101506:	b8 00 00 00 00       	mov    $0x0,%eax
f010150b:	eb f6                	jmp    f0101503 <strncmp+0x2e>

f010150d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010150d:	55                   	push   %ebp
f010150e:	89 e5                	mov    %esp,%ebp
f0101510:	8b 45 08             	mov    0x8(%ebp),%eax
f0101513:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101517:	0f b6 10             	movzbl (%eax),%edx
f010151a:	84 d2                	test   %dl,%dl
f010151c:	74 09                	je     f0101527 <strchr+0x1a>
		if (*s == c)
f010151e:	38 ca                	cmp    %cl,%dl
f0101520:	74 0a                	je     f010152c <strchr+0x1f>
	for (; *s; s++)
f0101522:	83 c0 01             	add    $0x1,%eax
f0101525:	eb f0                	jmp    f0101517 <strchr+0xa>
			return (char *) s;
	return 0;
f0101527:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010152c:	5d                   	pop    %ebp
f010152d:	c3                   	ret    

f010152e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010152e:	55                   	push   %ebp
f010152f:	89 e5                	mov    %esp,%ebp
f0101531:	8b 45 08             	mov    0x8(%ebp),%eax
f0101534:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101538:	eb 03                	jmp    f010153d <strfind+0xf>
f010153a:	83 c0 01             	add    $0x1,%eax
f010153d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101540:	38 ca                	cmp    %cl,%dl
f0101542:	74 04                	je     f0101548 <strfind+0x1a>
f0101544:	84 d2                	test   %dl,%dl
f0101546:	75 f2                	jne    f010153a <strfind+0xc>
			break;
	return (char *) s;
}
f0101548:	5d                   	pop    %ebp
f0101549:	c3                   	ret    

f010154a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010154a:	55                   	push   %ebp
f010154b:	89 e5                	mov    %esp,%ebp
f010154d:	57                   	push   %edi
f010154e:	56                   	push   %esi
f010154f:	53                   	push   %ebx
f0101550:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101553:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101556:	85 c9                	test   %ecx,%ecx
f0101558:	74 13                	je     f010156d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010155a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101560:	75 05                	jne    f0101567 <memset+0x1d>
f0101562:	f6 c1 03             	test   $0x3,%cl
f0101565:	74 0d                	je     f0101574 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101567:	8b 45 0c             	mov    0xc(%ebp),%eax
f010156a:	fc                   	cld    
f010156b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010156d:	89 f8                	mov    %edi,%eax
f010156f:	5b                   	pop    %ebx
f0101570:	5e                   	pop    %esi
f0101571:	5f                   	pop    %edi
f0101572:	5d                   	pop    %ebp
f0101573:	c3                   	ret    
		c &= 0xFF;
f0101574:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101578:	89 d3                	mov    %edx,%ebx
f010157a:	c1 e3 08             	shl    $0x8,%ebx
f010157d:	89 d0                	mov    %edx,%eax
f010157f:	c1 e0 18             	shl    $0x18,%eax
f0101582:	89 d6                	mov    %edx,%esi
f0101584:	c1 e6 10             	shl    $0x10,%esi
f0101587:	09 f0                	or     %esi,%eax
f0101589:	09 c2                	or     %eax,%edx
f010158b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010158d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101590:	89 d0                	mov    %edx,%eax
f0101592:	fc                   	cld    
f0101593:	f3 ab                	rep stos %eax,%es:(%edi)
f0101595:	eb d6                	jmp    f010156d <memset+0x23>

f0101597 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101597:	55                   	push   %ebp
f0101598:	89 e5                	mov    %esp,%ebp
f010159a:	57                   	push   %edi
f010159b:	56                   	push   %esi
f010159c:	8b 45 08             	mov    0x8(%ebp),%eax
f010159f:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01015a5:	39 c6                	cmp    %eax,%esi
f01015a7:	73 35                	jae    f01015de <memmove+0x47>
f01015a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01015ac:	39 c2                	cmp    %eax,%edx
f01015ae:	76 2e                	jbe    f01015de <memmove+0x47>
		s += n;
		d += n;
f01015b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015b3:	89 d6                	mov    %edx,%esi
f01015b5:	09 fe                	or     %edi,%esi
f01015b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01015bd:	74 0c                	je     f01015cb <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01015bf:	83 ef 01             	sub    $0x1,%edi
f01015c2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01015c5:	fd                   	std    
f01015c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01015c8:	fc                   	cld    
f01015c9:	eb 21                	jmp    f01015ec <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015cb:	f6 c1 03             	test   $0x3,%cl
f01015ce:	75 ef                	jne    f01015bf <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01015d0:	83 ef 04             	sub    $0x4,%edi
f01015d3:	8d 72 fc             	lea    -0x4(%edx),%esi
f01015d6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01015d9:	fd                   	std    
f01015da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015dc:	eb ea                	jmp    f01015c8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015de:	89 f2                	mov    %esi,%edx
f01015e0:	09 c2                	or     %eax,%edx
f01015e2:	f6 c2 03             	test   $0x3,%dl
f01015e5:	74 09                	je     f01015f0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01015e7:	89 c7                	mov    %eax,%edi
f01015e9:	fc                   	cld    
f01015ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01015ec:	5e                   	pop    %esi
f01015ed:	5f                   	pop    %edi
f01015ee:	5d                   	pop    %ebp
f01015ef:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015f0:	f6 c1 03             	test   $0x3,%cl
f01015f3:	75 f2                	jne    f01015e7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01015f5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01015f8:	89 c7                	mov    %eax,%edi
f01015fa:	fc                   	cld    
f01015fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015fd:	eb ed                	jmp    f01015ec <memmove+0x55>

f01015ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01015ff:	55                   	push   %ebp
f0101600:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101602:	ff 75 10             	pushl  0x10(%ebp)
f0101605:	ff 75 0c             	pushl  0xc(%ebp)
f0101608:	ff 75 08             	pushl  0x8(%ebp)
f010160b:	e8 87 ff ff ff       	call   f0101597 <memmove>
}
f0101610:	c9                   	leave  
f0101611:	c3                   	ret    

f0101612 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101612:	55                   	push   %ebp
f0101613:	89 e5                	mov    %esp,%ebp
f0101615:	56                   	push   %esi
f0101616:	53                   	push   %ebx
f0101617:	8b 45 08             	mov    0x8(%ebp),%eax
f010161a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010161d:	89 c6                	mov    %eax,%esi
f010161f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101622:	39 f0                	cmp    %esi,%eax
f0101624:	74 1c                	je     f0101642 <memcmp+0x30>
		if (*s1 != *s2)
f0101626:	0f b6 08             	movzbl (%eax),%ecx
f0101629:	0f b6 1a             	movzbl (%edx),%ebx
f010162c:	38 d9                	cmp    %bl,%cl
f010162e:	75 08                	jne    f0101638 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101630:	83 c0 01             	add    $0x1,%eax
f0101633:	83 c2 01             	add    $0x1,%edx
f0101636:	eb ea                	jmp    f0101622 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101638:	0f b6 c1             	movzbl %cl,%eax
f010163b:	0f b6 db             	movzbl %bl,%ebx
f010163e:	29 d8                	sub    %ebx,%eax
f0101640:	eb 05                	jmp    f0101647 <memcmp+0x35>
	}

	return 0;
f0101642:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101647:	5b                   	pop    %ebx
f0101648:	5e                   	pop    %esi
f0101649:	5d                   	pop    %ebp
f010164a:	c3                   	ret    

f010164b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010164b:	55                   	push   %ebp
f010164c:	89 e5                	mov    %esp,%ebp
f010164e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101651:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101654:	89 c2                	mov    %eax,%edx
f0101656:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101659:	39 d0                	cmp    %edx,%eax
f010165b:	73 09                	jae    f0101666 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010165d:	38 08                	cmp    %cl,(%eax)
f010165f:	74 05                	je     f0101666 <memfind+0x1b>
	for (; s < ends; s++)
f0101661:	83 c0 01             	add    $0x1,%eax
f0101664:	eb f3                	jmp    f0101659 <memfind+0xe>
			break;
	return (void *) s;
}
f0101666:	5d                   	pop    %ebp
f0101667:	c3                   	ret    

f0101668 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101668:	55                   	push   %ebp
f0101669:	89 e5                	mov    %esp,%ebp
f010166b:	57                   	push   %edi
f010166c:	56                   	push   %esi
f010166d:	53                   	push   %ebx
f010166e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101671:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101674:	eb 03                	jmp    f0101679 <strtol+0x11>
		s++;
f0101676:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101679:	0f b6 01             	movzbl (%ecx),%eax
f010167c:	3c 20                	cmp    $0x20,%al
f010167e:	74 f6                	je     f0101676 <strtol+0xe>
f0101680:	3c 09                	cmp    $0x9,%al
f0101682:	74 f2                	je     f0101676 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101684:	3c 2b                	cmp    $0x2b,%al
f0101686:	74 2e                	je     f01016b6 <strtol+0x4e>
	int neg = 0;
f0101688:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010168d:	3c 2d                	cmp    $0x2d,%al
f010168f:	74 2f                	je     f01016c0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101691:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101697:	75 05                	jne    f010169e <strtol+0x36>
f0101699:	80 39 30             	cmpb   $0x30,(%ecx)
f010169c:	74 2c                	je     f01016ca <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010169e:	85 db                	test   %ebx,%ebx
f01016a0:	75 0a                	jne    f01016ac <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01016a2:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01016a7:	80 39 30             	cmpb   $0x30,(%ecx)
f01016aa:	74 28                	je     f01016d4 <strtol+0x6c>
		base = 10;
f01016ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01016b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01016b4:	eb 50                	jmp    f0101706 <strtol+0x9e>
		s++;
f01016b6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01016b9:	bf 00 00 00 00       	mov    $0x0,%edi
f01016be:	eb d1                	jmp    f0101691 <strtol+0x29>
		s++, neg = 1;
f01016c0:	83 c1 01             	add    $0x1,%ecx
f01016c3:	bf 01 00 00 00       	mov    $0x1,%edi
f01016c8:	eb c7                	jmp    f0101691 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01016ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01016ce:	74 0e                	je     f01016de <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01016d0:	85 db                	test   %ebx,%ebx
f01016d2:	75 d8                	jne    f01016ac <strtol+0x44>
		s++, base = 8;
f01016d4:	83 c1 01             	add    $0x1,%ecx
f01016d7:	bb 08 00 00 00       	mov    $0x8,%ebx
f01016dc:	eb ce                	jmp    f01016ac <strtol+0x44>
		s += 2, base = 16;
f01016de:	83 c1 02             	add    $0x2,%ecx
f01016e1:	bb 10 00 00 00       	mov    $0x10,%ebx
f01016e6:	eb c4                	jmp    f01016ac <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01016e8:	8d 72 9f             	lea    -0x61(%edx),%esi
f01016eb:	89 f3                	mov    %esi,%ebx
f01016ed:	80 fb 19             	cmp    $0x19,%bl
f01016f0:	77 29                	ja     f010171b <strtol+0xb3>
			dig = *s - 'a' + 10;
f01016f2:	0f be d2             	movsbl %dl,%edx
f01016f5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01016f8:	3b 55 10             	cmp    0x10(%ebp),%edx
f01016fb:	7d 30                	jge    f010172d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01016fd:	83 c1 01             	add    $0x1,%ecx
f0101700:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101704:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101706:	0f b6 11             	movzbl (%ecx),%edx
f0101709:	8d 72 d0             	lea    -0x30(%edx),%esi
f010170c:	89 f3                	mov    %esi,%ebx
f010170e:	80 fb 09             	cmp    $0x9,%bl
f0101711:	77 d5                	ja     f01016e8 <strtol+0x80>
			dig = *s - '0';
f0101713:	0f be d2             	movsbl %dl,%edx
f0101716:	83 ea 30             	sub    $0x30,%edx
f0101719:	eb dd                	jmp    f01016f8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010171b:	8d 72 bf             	lea    -0x41(%edx),%esi
f010171e:	89 f3                	mov    %esi,%ebx
f0101720:	80 fb 19             	cmp    $0x19,%bl
f0101723:	77 08                	ja     f010172d <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101725:	0f be d2             	movsbl %dl,%edx
f0101728:	83 ea 37             	sub    $0x37,%edx
f010172b:	eb cb                	jmp    f01016f8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010172d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101731:	74 05                	je     f0101738 <strtol+0xd0>
		*endptr = (char *) s;
f0101733:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101736:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101738:	89 c2                	mov    %eax,%edx
f010173a:	f7 da                	neg    %edx
f010173c:	85 ff                	test   %edi,%edi
f010173e:	0f 45 c2             	cmovne %edx,%eax
}
f0101741:	5b                   	pop    %ebx
f0101742:	5e                   	pop    %esi
f0101743:	5f                   	pop    %edi
f0101744:	5d                   	pop    %ebp
f0101745:	c3                   	ret    
f0101746:	66 90                	xchg   %ax,%ax
f0101748:	66 90                	xchg   %ax,%ax
f010174a:	66 90                	xchg   %ax,%ax
f010174c:	66 90                	xchg   %ax,%ax
f010174e:	66 90                	xchg   %ax,%ax

f0101750 <__udivdi3>:
f0101750:	55                   	push   %ebp
f0101751:	57                   	push   %edi
f0101752:	56                   	push   %esi
f0101753:	53                   	push   %ebx
f0101754:	83 ec 1c             	sub    $0x1c,%esp
f0101757:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010175b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010175f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101763:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101767:	85 d2                	test   %edx,%edx
f0101769:	75 35                	jne    f01017a0 <__udivdi3+0x50>
f010176b:	39 f3                	cmp    %esi,%ebx
f010176d:	0f 87 bd 00 00 00    	ja     f0101830 <__udivdi3+0xe0>
f0101773:	85 db                	test   %ebx,%ebx
f0101775:	89 d9                	mov    %ebx,%ecx
f0101777:	75 0b                	jne    f0101784 <__udivdi3+0x34>
f0101779:	b8 01 00 00 00       	mov    $0x1,%eax
f010177e:	31 d2                	xor    %edx,%edx
f0101780:	f7 f3                	div    %ebx
f0101782:	89 c1                	mov    %eax,%ecx
f0101784:	31 d2                	xor    %edx,%edx
f0101786:	89 f0                	mov    %esi,%eax
f0101788:	f7 f1                	div    %ecx
f010178a:	89 c6                	mov    %eax,%esi
f010178c:	89 e8                	mov    %ebp,%eax
f010178e:	89 f7                	mov    %esi,%edi
f0101790:	f7 f1                	div    %ecx
f0101792:	89 fa                	mov    %edi,%edx
f0101794:	83 c4 1c             	add    $0x1c,%esp
f0101797:	5b                   	pop    %ebx
f0101798:	5e                   	pop    %esi
f0101799:	5f                   	pop    %edi
f010179a:	5d                   	pop    %ebp
f010179b:	c3                   	ret    
f010179c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017a0:	39 f2                	cmp    %esi,%edx
f01017a2:	77 7c                	ja     f0101820 <__udivdi3+0xd0>
f01017a4:	0f bd fa             	bsr    %edx,%edi
f01017a7:	83 f7 1f             	xor    $0x1f,%edi
f01017aa:	0f 84 98 00 00 00    	je     f0101848 <__udivdi3+0xf8>
f01017b0:	89 f9                	mov    %edi,%ecx
f01017b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01017b7:	29 f8                	sub    %edi,%eax
f01017b9:	d3 e2                	shl    %cl,%edx
f01017bb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01017bf:	89 c1                	mov    %eax,%ecx
f01017c1:	89 da                	mov    %ebx,%edx
f01017c3:	d3 ea                	shr    %cl,%edx
f01017c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01017c9:	09 d1                	or     %edx,%ecx
f01017cb:	89 f2                	mov    %esi,%edx
f01017cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017d1:	89 f9                	mov    %edi,%ecx
f01017d3:	d3 e3                	shl    %cl,%ebx
f01017d5:	89 c1                	mov    %eax,%ecx
f01017d7:	d3 ea                	shr    %cl,%edx
f01017d9:	89 f9                	mov    %edi,%ecx
f01017db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01017df:	d3 e6                	shl    %cl,%esi
f01017e1:	89 eb                	mov    %ebp,%ebx
f01017e3:	89 c1                	mov    %eax,%ecx
f01017e5:	d3 eb                	shr    %cl,%ebx
f01017e7:	09 de                	or     %ebx,%esi
f01017e9:	89 f0                	mov    %esi,%eax
f01017eb:	f7 74 24 08          	divl   0x8(%esp)
f01017ef:	89 d6                	mov    %edx,%esi
f01017f1:	89 c3                	mov    %eax,%ebx
f01017f3:	f7 64 24 0c          	mull   0xc(%esp)
f01017f7:	39 d6                	cmp    %edx,%esi
f01017f9:	72 0c                	jb     f0101807 <__udivdi3+0xb7>
f01017fb:	89 f9                	mov    %edi,%ecx
f01017fd:	d3 e5                	shl    %cl,%ebp
f01017ff:	39 c5                	cmp    %eax,%ebp
f0101801:	73 5d                	jae    f0101860 <__udivdi3+0x110>
f0101803:	39 d6                	cmp    %edx,%esi
f0101805:	75 59                	jne    f0101860 <__udivdi3+0x110>
f0101807:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010180a:	31 ff                	xor    %edi,%edi
f010180c:	89 fa                	mov    %edi,%edx
f010180e:	83 c4 1c             	add    $0x1c,%esp
f0101811:	5b                   	pop    %ebx
f0101812:	5e                   	pop    %esi
f0101813:	5f                   	pop    %edi
f0101814:	5d                   	pop    %ebp
f0101815:	c3                   	ret    
f0101816:	8d 76 00             	lea    0x0(%esi),%esi
f0101819:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101820:	31 ff                	xor    %edi,%edi
f0101822:	31 c0                	xor    %eax,%eax
f0101824:	89 fa                	mov    %edi,%edx
f0101826:	83 c4 1c             	add    $0x1c,%esp
f0101829:	5b                   	pop    %ebx
f010182a:	5e                   	pop    %esi
f010182b:	5f                   	pop    %edi
f010182c:	5d                   	pop    %ebp
f010182d:	c3                   	ret    
f010182e:	66 90                	xchg   %ax,%ax
f0101830:	31 ff                	xor    %edi,%edi
f0101832:	89 e8                	mov    %ebp,%eax
f0101834:	89 f2                	mov    %esi,%edx
f0101836:	f7 f3                	div    %ebx
f0101838:	89 fa                	mov    %edi,%edx
f010183a:	83 c4 1c             	add    $0x1c,%esp
f010183d:	5b                   	pop    %ebx
f010183e:	5e                   	pop    %esi
f010183f:	5f                   	pop    %edi
f0101840:	5d                   	pop    %ebp
f0101841:	c3                   	ret    
f0101842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101848:	39 f2                	cmp    %esi,%edx
f010184a:	72 06                	jb     f0101852 <__udivdi3+0x102>
f010184c:	31 c0                	xor    %eax,%eax
f010184e:	39 eb                	cmp    %ebp,%ebx
f0101850:	77 d2                	ja     f0101824 <__udivdi3+0xd4>
f0101852:	b8 01 00 00 00       	mov    $0x1,%eax
f0101857:	eb cb                	jmp    f0101824 <__udivdi3+0xd4>
f0101859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101860:	89 d8                	mov    %ebx,%eax
f0101862:	31 ff                	xor    %edi,%edi
f0101864:	eb be                	jmp    f0101824 <__udivdi3+0xd4>
f0101866:	66 90                	xchg   %ax,%ax
f0101868:	66 90                	xchg   %ax,%ax
f010186a:	66 90                	xchg   %ax,%ax
f010186c:	66 90                	xchg   %ax,%ax
f010186e:	66 90                	xchg   %ax,%ax

f0101870 <__umoddi3>:
f0101870:	55                   	push   %ebp
f0101871:	57                   	push   %edi
f0101872:	56                   	push   %esi
f0101873:	53                   	push   %ebx
f0101874:	83 ec 1c             	sub    $0x1c,%esp
f0101877:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010187b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010187f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101883:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101887:	85 ed                	test   %ebp,%ebp
f0101889:	89 f0                	mov    %esi,%eax
f010188b:	89 da                	mov    %ebx,%edx
f010188d:	75 19                	jne    f01018a8 <__umoddi3+0x38>
f010188f:	39 df                	cmp    %ebx,%edi
f0101891:	0f 86 b1 00 00 00    	jbe    f0101948 <__umoddi3+0xd8>
f0101897:	f7 f7                	div    %edi
f0101899:	89 d0                	mov    %edx,%eax
f010189b:	31 d2                	xor    %edx,%edx
f010189d:	83 c4 1c             	add    $0x1c,%esp
f01018a0:	5b                   	pop    %ebx
f01018a1:	5e                   	pop    %esi
f01018a2:	5f                   	pop    %edi
f01018a3:	5d                   	pop    %ebp
f01018a4:	c3                   	ret    
f01018a5:	8d 76 00             	lea    0x0(%esi),%esi
f01018a8:	39 dd                	cmp    %ebx,%ebp
f01018aa:	77 f1                	ja     f010189d <__umoddi3+0x2d>
f01018ac:	0f bd cd             	bsr    %ebp,%ecx
f01018af:	83 f1 1f             	xor    $0x1f,%ecx
f01018b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01018b6:	0f 84 b4 00 00 00    	je     f0101970 <__umoddi3+0x100>
f01018bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01018c1:	89 c2                	mov    %eax,%edx
f01018c3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01018c7:	29 c2                	sub    %eax,%edx
f01018c9:	89 c1                	mov    %eax,%ecx
f01018cb:	89 f8                	mov    %edi,%eax
f01018cd:	d3 e5                	shl    %cl,%ebp
f01018cf:	89 d1                	mov    %edx,%ecx
f01018d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01018d5:	d3 e8                	shr    %cl,%eax
f01018d7:	09 c5                	or     %eax,%ebp
f01018d9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01018dd:	89 c1                	mov    %eax,%ecx
f01018df:	d3 e7                	shl    %cl,%edi
f01018e1:	89 d1                	mov    %edx,%ecx
f01018e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01018e7:	89 df                	mov    %ebx,%edi
f01018e9:	d3 ef                	shr    %cl,%edi
f01018eb:	89 c1                	mov    %eax,%ecx
f01018ed:	89 f0                	mov    %esi,%eax
f01018ef:	d3 e3                	shl    %cl,%ebx
f01018f1:	89 d1                	mov    %edx,%ecx
f01018f3:	89 fa                	mov    %edi,%edx
f01018f5:	d3 e8                	shr    %cl,%eax
f01018f7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01018fc:	09 d8                	or     %ebx,%eax
f01018fe:	f7 f5                	div    %ebp
f0101900:	d3 e6                	shl    %cl,%esi
f0101902:	89 d1                	mov    %edx,%ecx
f0101904:	f7 64 24 08          	mull   0x8(%esp)
f0101908:	39 d1                	cmp    %edx,%ecx
f010190a:	89 c3                	mov    %eax,%ebx
f010190c:	89 d7                	mov    %edx,%edi
f010190e:	72 06                	jb     f0101916 <__umoddi3+0xa6>
f0101910:	75 0e                	jne    f0101920 <__umoddi3+0xb0>
f0101912:	39 c6                	cmp    %eax,%esi
f0101914:	73 0a                	jae    f0101920 <__umoddi3+0xb0>
f0101916:	2b 44 24 08          	sub    0x8(%esp),%eax
f010191a:	19 ea                	sbb    %ebp,%edx
f010191c:	89 d7                	mov    %edx,%edi
f010191e:	89 c3                	mov    %eax,%ebx
f0101920:	89 ca                	mov    %ecx,%edx
f0101922:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101927:	29 de                	sub    %ebx,%esi
f0101929:	19 fa                	sbb    %edi,%edx
f010192b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010192f:	89 d0                	mov    %edx,%eax
f0101931:	d3 e0                	shl    %cl,%eax
f0101933:	89 d9                	mov    %ebx,%ecx
f0101935:	d3 ee                	shr    %cl,%esi
f0101937:	d3 ea                	shr    %cl,%edx
f0101939:	09 f0                	or     %esi,%eax
f010193b:	83 c4 1c             	add    $0x1c,%esp
f010193e:	5b                   	pop    %ebx
f010193f:	5e                   	pop    %esi
f0101940:	5f                   	pop    %edi
f0101941:	5d                   	pop    %ebp
f0101942:	c3                   	ret    
f0101943:	90                   	nop
f0101944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101948:	85 ff                	test   %edi,%edi
f010194a:	89 f9                	mov    %edi,%ecx
f010194c:	75 0b                	jne    f0101959 <__umoddi3+0xe9>
f010194e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101953:	31 d2                	xor    %edx,%edx
f0101955:	f7 f7                	div    %edi
f0101957:	89 c1                	mov    %eax,%ecx
f0101959:	89 d8                	mov    %ebx,%eax
f010195b:	31 d2                	xor    %edx,%edx
f010195d:	f7 f1                	div    %ecx
f010195f:	89 f0                	mov    %esi,%eax
f0101961:	f7 f1                	div    %ecx
f0101963:	e9 31 ff ff ff       	jmp    f0101899 <__umoddi3+0x29>
f0101968:	90                   	nop
f0101969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101970:	39 dd                	cmp    %ebx,%ebp
f0101972:	72 08                	jb     f010197c <__umoddi3+0x10c>
f0101974:	39 f7                	cmp    %esi,%edi
f0101976:	0f 87 21 ff ff ff    	ja     f010189d <__umoddi3+0x2d>
f010197c:	89 da                	mov    %ebx,%edx
f010197e:	89 f0                	mov    %esi,%eax
f0101980:	29 f8                	sub    %edi,%eax
f0101982:	19 ea                	sbb    %ebp,%edx
f0101984:	e9 14 ff ff ff       	jmp    f010189d <__umoddi3+0x2d>
