
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 b5 10 80       	mov    $0x8010b5d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 20 2f 10 80       	mov    $0x80102f20,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
	...

80100040 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	56                   	push   %esi
80100044:	53                   	push   %ebx
80100045:	83 ec 10             	sub    $0x10,%esp
80100048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
8010004b:	8d 73 0c             	lea    0xc(%ebx),%esi
8010004e:	89 34 24             	mov    %esi,(%esp)
80100051:	e8 6a 40 00 00       	call   801040c0 <holdingsleep>
80100056:	85 c0                	test   %eax,%eax
80100058:	74 62                	je     801000bc <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
8010005a:	89 34 24             	mov    %esi,(%esp)
8010005d:	e8 be 40 00 00       	call   80104120 <releasesleep>

  acquire(&bcache.lock);
80100062:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100069:	e8 62 43 00 00       	call   801043d0 <acquire>
  b->refcnt--;
8010006e:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100071:	83 e8 01             	sub    $0x1,%eax
  if (b->refcnt == 0) {
80100074:	85 c0                	test   %eax,%eax
    panic("brelse");

  releasesleep(&b->lock);

  acquire(&bcache.lock);
  b->refcnt--;
80100076:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
80100079:	75 2f                	jne    801000aa <brelse+0x6a>
    // no one is waiting for it.
    b->next->prev = b->prev;
8010007b:	8b 43 54             	mov    0x54(%ebx),%eax
8010007e:	8b 53 50             	mov    0x50(%ebx),%edx
80100081:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100084:	8b 43 50             	mov    0x50(%ebx),%eax
80100087:	8b 53 54             	mov    0x54(%ebx),%edx
8010008a:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
8010008d:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
    b->prev = &bcache.head;
80100092:	c7 43 50 dc fc 10 80 	movl   $0x8010fcdc,0x50(%ebx)
  b->refcnt--;
  if (b->refcnt == 0) {
    // no one is waiting for it.
    b->next->prev = b->prev;
    b->prev->next = b->next;
    b->next = bcache.head.next;
80100099:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
8010009c:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
801000a1:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801000a4:	89 1d 30 fd 10 80    	mov    %ebx,0x8010fd30
  }
  
  release(&bcache.lock);
801000aa:	c7 45 08 e0 b5 10 80 	movl   $0x8010b5e0,0x8(%ebp)
}
801000b1:	83 c4 10             	add    $0x10,%esp
801000b4:	5b                   	pop    %ebx
801000b5:	5e                   	pop    %esi
801000b6:	5d                   	pop    %ebp
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
  
  release(&bcache.lock);
801000b7:	e9 c4 42 00 00       	jmp    80104380 <release>
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");
801000bc:	c7 04 24 60 6e 10 80 	movl   $0x80106e60,(%esp)
801000c3:	e8 e8 02 00 00       	call   801003b0 <panic>
801000c8:	90                   	nop
801000c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801000d0 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	53                   	push   %ebx
801000d4:	83 ec 14             	sub    $0x14,%esp
801000d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801000da:	8d 43 0c             	lea    0xc(%ebx),%eax
801000dd:	89 04 24             	mov    %eax,(%esp)
801000e0:	e8 db 3f 00 00       	call   801040c0 <holdingsleep>
801000e5:	85 c0                	test   %eax,%eax
801000e7:	74 10                	je     801000f9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801000e9:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801000ec:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801000ef:	83 c4 14             	add    $0x14,%esp
801000f2:	5b                   	pop    %ebx
801000f3:	5d                   	pop    %ebp
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
801000f4:	e9 17 20 00 00       	jmp    80102110 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
801000f9:	c7 04 24 67 6e 10 80 	movl   $0x80106e67,(%esp)
80100100:	e8 ab 02 00 00       	call   801003b0 <panic>
80100105:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100110 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100110:	55                   	push   %ebp
80100111:	89 e5                	mov    %esp,%ebp
80100113:	57                   	push   %edi
80100114:	56                   	push   %esi
80100115:	53                   	push   %ebx
80100116:	83 ec 1c             	sub    $0x1c,%esp
80100119:	8b 75 08             	mov    0x8(%ebp),%esi
8010011c:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  acquire(&bcache.lock);
8010011f:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100126:	e8 a5 42 00 00       	call   801043d0 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010012b:	8b 1d 30 fd 10 80    	mov    0x8010fd30,%ebx
80100131:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
80100137:	75 12                	jne    8010014b <bread+0x3b>
80100139:	eb 2d                	jmp    80100168 <bread+0x58>
8010013b:	90                   	nop
8010013c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100140:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100143:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
80100149:	74 1d                	je     80100168 <bread+0x58>
    if(b->dev == dev && b->blockno == blockno){
8010014b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010014e:	66 90                	xchg   %ax,%ax
80100150:	75 ee                	jne    80100140 <bread+0x30>
80100152:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100155:	75 e9                	jne    80100140 <bread+0x30>
      b->refcnt++;
80100157:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
8010015b:	90                   	nop
8010015c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100160:	eb 40                	jmp    801001a2 <bread+0x92>
80100162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100168:	8b 1d 2c fd 10 80    	mov    0x8010fd2c,%ebx
8010016e:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
80100174:	75 0d                	jne    80100183 <bread+0x73>
80100176:	eb 58                	jmp    801001d0 <bread+0xc0>
80100178:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010017b:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
80100181:	74 4d                	je     801001d0 <bread+0xc0>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100183:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100186:	85 c0                	test   %eax,%eax
80100188:	75 ee                	jne    80100178 <bread+0x68>
8010018a:	f6 03 04             	testb  $0x4,(%ebx)
8010018d:	75 e9                	jne    80100178 <bread+0x68>
      b->dev = dev;
8010018f:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
80100192:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
80100195:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
8010019b:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801001a2:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801001a9:	e8 d2 41 00 00       	call   80104380 <release>
      acquiresleep(&b->lock);
801001ae:	8d 43 0c             	lea    0xc(%ebx),%eax
801001b1:	89 04 24             	mov    %eax,(%esp)
801001b4:	e8 a7 3f 00 00       	call   80104160 <acquiresleep>
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
801001b9:	f6 03 02             	testb  $0x2,(%ebx)
801001bc:	75 08                	jne    801001c6 <bread+0xb6>
    iderw(b);
801001be:	89 1c 24             	mov    %ebx,(%esp)
801001c1:	e8 4a 1f 00 00       	call   80102110 <iderw>
  }
  return b;
}
801001c6:	83 c4 1c             	add    $0x1c,%esp
801001c9:	89 d8                	mov    %ebx,%eax
801001cb:	5b                   	pop    %ebx
801001cc:	5e                   	pop    %esi
801001cd:	5f                   	pop    %edi
801001ce:	5d                   	pop    %ebp
801001cf:	c3                   	ret    
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001d0:	c7 04 24 6e 6e 10 80 	movl   $0x80106e6e,(%esp)
801001d7:	e8 d4 01 00 00       	call   801003b0 <panic>
801001dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801001e0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
801001e0:	55                   	push   %ebp
801001e1:	89 e5                	mov    %esp,%ebp
801001e3:	53                   	push   %ebx
  // head.next is most recently used.
  struct buf head;
} bcache;

void
binit(void)
801001e4:	bb 14 b6 10 80       	mov    $0x8010b614,%ebx
{
801001e9:	83 ec 14             	sub    $0x14,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
801001ec:	c7 44 24 04 7f 6e 10 	movl   $0x80106e7f,0x4(%esp)
801001f3:	80 
801001f4:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801001fb:	e8 00 40 00 00       	call   80104200 <initlock>
  // head.next is most recently used.
  struct buf head;
} bcache;

void
binit(void)
80100200:	b8 dc fc 10 80       	mov    $0x8010fcdc,%eax

  initlock(&bcache.lock, "bcache");

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100205:	c7 05 2c fd 10 80 dc 	movl   $0x8010fcdc,0x8010fd2c
8010020c:	fc 10 80 
  bcache.head.next = &bcache.head;
8010020f:	c7 05 30 fd 10 80 dc 	movl   $0x8010fcdc,0x8010fd30
80100216:	fc 10 80 
80100219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
80100220:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100223:	8d 43 0c             	lea    0xc(%ebx),%eax
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
    b->prev = &bcache.head;
80100226:	c7 43 50 dc fc 10 80 	movl   $0x8010fcdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010022d:	89 04 24             	mov    %eax,(%esp)
80100230:	c7 44 24 04 86 6e 10 	movl   $0x80106e86,0x4(%esp)
80100237:	80 
80100238:	e8 83 3f 00 00       	call   801041c0 <initsleeplock>
    bcache.head.next->prev = b;
8010023d:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
80100242:	89 58 50             	mov    %ebx,0x50(%eax)

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100245:	89 d8                	mov    %ebx,%eax
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
80100247:	89 1d 30 fd 10 80    	mov    %ebx,0x8010fd30

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010024d:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
80100253:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
80100259:	75 c5                	jne    80100220 <binit+0x40>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
8010025b:	83 c4 14             	add    $0x14,%esp
8010025e:	5b                   	pop    %ebx
8010025f:	5d                   	pop    %ebp
80100260:	c3                   	ret    
	...

80100270 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
80100270:	55                   	push   %ebp
80100271:	89 e5                	mov    %esp,%ebp
80100273:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100276:	c7 44 24 04 8d 6e 10 	movl   $0x80106e8d,0x4(%esp)
8010027d:	80 
8010027e:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
80100285:	e8 76 3f 00 00       	call   80104200 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
8010028a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100291:	00 
80100292:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
void
consoleinit(void)
{
  initlock(&cons.lock, "console");

  devsw[CONSOLE].write = consolewrite;
80100299:	c7 05 8c 09 11 80 b0 	movl   $0x801005b0,0x8011098c
801002a0:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801002a3:	c7 05 88 09 11 80 c0 	movl   $0x801002c0,0x80110988
801002aa:	02 10 80 
  cons.locking = 1;
801002ad:	c7 05 74 a5 10 80 01 	movl   $0x1,0x8010a574
801002b4:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801002b7:	e8 44 20 00 00       	call   80102300 <ioapicenable>
}
801002bc:	c9                   	leave  
801002bd:	c3                   	ret    
801002be:	66 90                	xchg   %ax,%ax

801002c0 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
801002c0:	55                   	push   %ebp
801002c1:	89 e5                	mov    %esp,%ebp
801002c3:	57                   	push   %edi
801002c4:	56                   	push   %esi
801002c5:	53                   	push   %ebx
801002c6:	83 ec 2c             	sub    $0x2c,%esp
801002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
801002cc:	8b 75 08             	mov    0x8(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
801002cf:	89 34 24             	mov    %esi,(%esp)
801002d2:	e8 a9 1a 00 00       	call   80101d80 <iunlock>
  target = n;
801002d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
801002da:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
801002e1:	e8 ea 40 00 00       	call   801043d0 <acquire>
  while(n > 0){
801002e6:	85 db                	test   %ebx,%ebx
801002e8:	7f 26                	jg     80100310 <consoleread+0x50>
801002ea:	e9 bb 00 00 00       	jmp    801003aa <consoleread+0xea>
801002ef:	90                   	nop
    while(input.r == input.w){
      if(myproc()->killed){
801002f0:	e8 1b 38 00 00       	call   80103b10 <myproc>
801002f5:	8b 40 24             	mov    0x24(%eax),%eax
801002f8:	85 c0                	test   %eax,%eax
801002fa:	75 5c                	jne    80100358 <consoleread+0x98>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002fc:	c7 44 24 04 40 a5 10 	movl   $0x8010a540,0x4(%esp)
80100303:	80 
80100304:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
8010030b:	e8 60 3a 00 00       	call   80103d70 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100310:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
80100315:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
8010031b:	74 d3                	je     801002f0 <consoleread+0x30>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
8010031d:	89 c2                	mov    %eax,%edx
8010031f:	83 e2 7f             	and    $0x7f,%edx
80100322:	0f b6 8a 40 ff 10 80 	movzbl -0x7fef00c0(%edx),%ecx
80100329:	8d 78 01             	lea    0x1(%eax),%edi
8010032c:	89 3d c0 ff 10 80    	mov    %edi,0x8010ffc0
80100332:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100335:	83 fa 04             	cmp    $0x4,%edx
80100338:	74 3f                	je     80100379 <consoleread+0xb9>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
8010033a:	8b 45 0c             	mov    0xc(%ebp),%eax
    --n;
8010033d:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100340:	83 fa 0a             	cmp    $0xa,%edx
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
80100343:	88 08                	mov    %cl,(%eax)
    --n;
    if(c == '\n')
80100345:	74 3c                	je     80100383 <consoleread+0xc3>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100347:	85 db                	test   %ebx,%ebx
80100349:	7e 38                	jle    80100383 <consoleread+0xc3>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
8010034b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010034f:	eb bf                	jmp    80100310 <consoleread+0x50>
80100351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
      if(myproc()->killed){
        release(&cons.lock);
80100358:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
8010035f:	e8 1c 40 00 00       	call   80104380 <release>
        ilock(ip);
80100364:	89 34 24             	mov    %esi,(%esp)
80100367:	e8 e4 16 00 00       	call   80101a50 <ilock>
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
8010036c:	83 c4 2c             	add    $0x2c,%esp
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
8010036f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100374:	5b                   	pop    %ebx
80100375:	5e                   	pop    %esi
80100376:	5f                   	pop    %edi
80100377:	5d                   	pop    %ebp
80100378:	c3                   	ret    
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
80100379:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
8010037c:	76 05                	jbe    80100383 <consoleread+0xc3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
8010037e:	a3 c0 ff 10 80       	mov    %eax,0x8010ffc0
80100383:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100386:	29 d8                	sub    %ebx,%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100388:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
8010038f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100392:	e8 e9 3f 00 00       	call   80104380 <release>
  ilock(ip);
80100397:	89 34 24             	mov    %esi,(%esp)
8010039a:	e8 b1 16 00 00       	call   80101a50 <ilock>
8010039f:	8b 45 e0             	mov    -0x20(%ebp),%eax

  return target - n;
}
801003a2:	83 c4 2c             	add    $0x2c,%esp
801003a5:	5b                   	pop    %ebx
801003a6:	5e                   	pop    %esi
801003a7:	5f                   	pop    %edi
801003a8:	5d                   	pop    %ebp
801003a9:	c3                   	ret    

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801003aa:	31 c0                	xor    %eax,%eax
801003ac:	eb da                	jmp    80100388 <consoleread+0xc8>
801003ae:	66 90                	xchg   %ax,%ax

801003b0 <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
801003b0:	55                   	push   %ebp
801003b1:	89 e5                	mov    %esp,%ebp
801003b3:	56                   	push   %esi
801003b4:	53                   	push   %ebx
801003b5:	83 ec 40             	sub    $0x40,%esp
  int i;
  uint pcs[10];

  cli();
  cons.locking = 0;
801003b8:	c7 05 74 a5 10 80 00 	movl   $0x0,0x8010a574
801003bf:	00 00 00 
}

static inline void
cli(void)
{
  asm volatile("cli");
801003c2:	fa                   	cli    
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801003c3:	e8 18 24 00 00       	call   801027e0 <lapicid>
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
801003c8:	8d 75 d0             	lea    -0x30(%ebp),%esi
801003cb:	31 db                	xor    %ebx,%ebx
  uint pcs[10];

  cli();
  cons.locking = 0;
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801003cd:	c7 04 24 95 6e 10 80 	movl   $0x80106e95,(%esp)
801003d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801003d8:	e8 73 04 00 00       	call   80100850 <cprintf>
  cprintf(s);
801003dd:	8b 45 08             	mov    0x8(%ebp),%eax
801003e0:	89 04 24             	mov    %eax,(%esp)
801003e3:	e8 68 04 00 00       	call   80100850 <cprintf>
  cprintf("\n");
801003e8:	c7 04 24 ad 77 10 80 	movl   $0x801077ad,(%esp)
801003ef:	e8 5c 04 00 00       	call   80100850 <cprintf>
  getcallerpcs(&s, pcs);
801003f4:	8d 45 08             	lea    0x8(%ebp),%eax
801003f7:	89 74 24 04          	mov    %esi,0x4(%esp)
801003fb:	89 04 24             	mov    %eax,(%esp)
801003fe:	e8 1d 3e 00 00       	call   80104220 <getcallerpcs>
80100403:	90                   	nop
80100404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
80100408:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
8010040b:	83 c3 01             	add    $0x1,%ebx
    cprintf(" %p", pcs[i]);
8010040e:	c7 04 24 a9 6e 10 80 	movl   $0x80106ea9,(%esp)
80100415:	89 44 24 04          	mov    %eax,0x4(%esp)
80100419:	e8 32 04 00 00       	call   80100850 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
8010041e:	83 fb 0a             	cmp    $0xa,%ebx
80100421:	75 e5                	jne    80100408 <panic+0x58>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
80100423:	c7 05 20 a5 10 80 01 	movl   $0x1,0x8010a520
8010042a:	00 00 00 
8010042d:	eb fe                	jmp    8010042d <panic+0x7d>
8010042f:	90                   	nop

80100430 <consputc>:
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
80100430:	55                   	push   %ebp
80100431:	89 e5                	mov    %esp,%ebp
80100433:	57                   	push   %edi
80100434:	56                   	push   %esi
80100435:	89 c6                	mov    %eax,%esi
80100437:	53                   	push   %ebx
80100438:	83 ec 1c             	sub    $0x1c,%esp
  if(panicked){
8010043b:	83 3d 20 a5 10 80 00 	cmpl   $0x0,0x8010a520
80100442:	74 03                	je     80100447 <consputc+0x17>
80100444:	fa                   	cli    
80100445:	eb fe                	jmp    80100445 <consputc+0x15>
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
80100447:	3d 00 01 00 00       	cmp    $0x100,%eax
8010044c:	0f 84 ac 00 00 00    	je     801004fe <consputc+0xce>
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
80100452:	89 04 24             	mov    %eax,(%esp)
80100455:	e8 36 55 00 00       	call   80105990 <uartputc>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010045a:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
8010045f:	b8 0e 00 00 00       	mov    $0xe,%eax
80100464:	89 ca                	mov    %ecx,%edx
80100466:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100467:	bf d5 03 00 00       	mov    $0x3d5,%edi
8010046c:	89 fa                	mov    %edi,%edx
8010046e:	ec                   	in     (%dx),%al
{
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
8010046f:	0f b6 d8             	movzbl %al,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100472:	89 ca                	mov    %ecx,%edx
80100474:	c1 e3 08             	shl    $0x8,%ebx
80100477:	b8 0f 00 00 00       	mov    $0xf,%eax
8010047c:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010047d:	89 fa                	mov    %edi,%edx
8010047f:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
80100480:	0f b6 c0             	movzbl %al,%eax
80100483:	09 c3                	or     %eax,%ebx

  if(c == '\n')
80100485:	83 fe 0a             	cmp    $0xa,%esi
80100488:	0f 84 fb 00 00 00    	je     80100589 <consputc+0x159>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
8010048e:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100494:	0f 84 e1 00 00 00    	je     8010057b <consputc+0x14b>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010049a:	66 81 e6 ff 00       	and    $0xff,%si
8010049f:	66 81 ce 00 07       	or     $0x700,%si
801004a4:	66 89 b4 1b 00 80 0b 	mov    %si,-0x7ff48000(%ebx,%ebx,1)
801004ab:	80 
801004ac:	83 c3 01             	add    $0x1,%ebx

  if(pos < 0 || pos > 25*80)
801004af:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
801004b5:	0f 87 b4 00 00 00    	ja     8010056f <consputc+0x13f>
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
801004bb:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
801004c1:	8d bc 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edi
801004c8:	7f 5d                	jg     80100527 <consputc+0xf7>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801004ca:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801004cf:	b8 0e 00 00 00       	mov    $0xe,%eax
801004d4:	89 ca                	mov    %ecx,%edx
801004d6:	ee                   	out    %al,(%dx)
801004d7:	be d5 03 00 00       	mov    $0x3d5,%esi
801004dc:	89 d8                	mov    %ebx,%eax
801004de:	c1 f8 08             	sar    $0x8,%eax
801004e1:	89 f2                	mov    %esi,%edx
801004e3:	ee                   	out    %al,(%dx)
801004e4:	b8 0f 00 00 00       	mov    $0xf,%eax
801004e9:	89 ca                	mov    %ecx,%edx
801004eb:	ee                   	out    %al,(%dx)
801004ec:	89 d8                	mov    %ebx,%eax
801004ee:	89 f2                	mov    %esi,%edx
801004f0:	ee                   	out    %al,(%dx)

  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
801004f1:	66 c7 07 20 07       	movw   $0x720,(%edi)
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  cgaputc(c);
}
801004f6:	83 c4 1c             	add    $0x1c,%esp
801004f9:	5b                   	pop    %ebx
801004fa:	5e                   	pop    %esi
801004fb:	5f                   	pop    %edi
801004fc:	5d                   	pop    %ebp
801004fd:	c3                   	ret    
    for(;;)
      ;
  }

  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
801004fe:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100505:	e8 86 54 00 00       	call   80105990 <uartputc>
8010050a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100511:	e8 7a 54 00 00       	call   80105990 <uartputc>
80100516:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010051d:	e8 6e 54 00 00       	call   80105990 <uartputc>
80100522:	e9 33 ff ff ff       	jmp    8010045a <consputc+0x2a>
  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
80100527:	83 eb 50             	sub    $0x50,%ebx

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010052a:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100531:	00 
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100532:	8d bc 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edi

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100539:	c7 44 24 04 a0 80 0b 	movl   $0x800b80a0,0x4(%esp)
80100540:	80 
80100541:	c7 04 24 00 80 0b 80 	movl   $0x800b8000,(%esp)
80100548:	e8 b3 3f 00 00       	call   80104500 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8010054d:	b8 80 07 00 00       	mov    $0x780,%eax
80100552:	29 d8                	sub    %ebx,%eax
80100554:	01 c0                	add    %eax,%eax
80100556:	89 44 24 08          	mov    %eax,0x8(%esp)
8010055a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100561:	00 
80100562:	89 3c 24             	mov    %edi,(%esp)
80100565:	e8 d6 3e 00 00       	call   80104440 <memset>
8010056a:	e9 5b ff ff ff       	jmp    801004ca <consputc+0x9a>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");
8010056f:	c7 04 24 ad 6e 10 80 	movl   $0x80106ead,(%esp)
80100576:	e8 35 fe ff ff       	call   801003b0 <panic>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
8010057b:	31 c0                	xor    %eax,%eax
8010057d:	85 db                	test   %ebx,%ebx
8010057f:	0f 9f c0             	setg   %al
80100582:	29 c3                	sub    %eax,%ebx
80100584:	e9 26 ff ff ff       	jmp    801004af <consputc+0x7f>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
80100589:	89 da                	mov    %ebx,%edx
8010058b:	89 d8                	mov    %ebx,%eax
8010058d:	b9 50 00 00 00       	mov    $0x50,%ecx
80100592:	83 c3 50             	add    $0x50,%ebx
80100595:	c1 fa 1f             	sar    $0x1f,%edx
80100598:	f7 f9                	idiv   %ecx
8010059a:	29 d3                	sub    %edx,%ebx
8010059c:	e9 0e ff ff ff       	jmp    801004af <consputc+0x7f>
801005a1:	eb 0d                	jmp    801005b0 <consolewrite>
801005a3:	90                   	nop
801005a4:	90                   	nop
801005a5:	90                   	nop
801005a6:	90                   	nop
801005a7:	90                   	nop
801005a8:	90                   	nop
801005a9:	90                   	nop
801005aa:	90                   	nop
801005ab:	90                   	nop
801005ac:	90                   	nop
801005ad:	90                   	nop
801005ae:	90                   	nop
801005af:	90                   	nop

801005b0 <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005b0:	55                   	push   %ebp
801005b1:	89 e5                	mov    %esp,%ebp
801005b3:	57                   	push   %edi
801005b4:	56                   	push   %esi
801005b5:	53                   	push   %ebx
801005b6:	83 ec 1c             	sub    $0x1c,%esp
  int i;

  iunlock(ip);
801005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005bc:	8b 75 10             	mov    0x10(%ebp),%esi
801005bf:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  iunlock(ip);
801005c2:	89 04 24             	mov    %eax,(%esp)
801005c5:	e8 b6 17 00 00       	call   80101d80 <iunlock>
  acquire(&cons.lock);
801005ca:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
801005d1:	e8 fa 3d 00 00       	call   801043d0 <acquire>
  for(i = 0; i < n; i++)
801005d6:	85 f6                	test   %esi,%esi
801005d8:	7e 16                	jle    801005f0 <consolewrite+0x40>
801005da:	31 db                	xor    %ebx,%ebx
801005dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    consputc(buf[i] & 0xff);
801005e0:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
801005e4:	83 c3 01             	add    $0x1,%ebx
    consputc(buf[i] & 0xff);
801005e7:	e8 44 fe ff ff       	call   80100430 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
801005ec:	39 de                	cmp    %ebx,%esi
801005ee:	7f f0                	jg     801005e0 <consolewrite+0x30>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
801005f0:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
801005f7:	e8 84 3d 00 00       	call   80104380 <release>
  ilock(ip);
801005fc:	8b 45 08             	mov    0x8(%ebp),%eax
801005ff:	89 04 24             	mov    %eax,(%esp)
80100602:	e8 49 14 00 00       	call   80101a50 <ilock>

  return n;
}
80100607:	83 c4 1c             	add    $0x1c,%esp
8010060a:	89 f0                	mov    %esi,%eax
8010060c:	5b                   	pop    %ebx
8010060d:	5e                   	pop    %esi
8010060e:	5f                   	pop    %edi
8010060f:	5d                   	pop    %ebp
80100610:	c3                   	ret    
80100611:	eb 0d                	jmp    80100620 <consoleintr>
80100613:	90                   	nop
80100614:	90                   	nop
80100615:	90                   	nop
80100616:	90                   	nop
80100617:	90                   	nop
80100618:	90                   	nop
80100619:	90                   	nop
8010061a:	90                   	nop
8010061b:	90                   	nop
8010061c:	90                   	nop
8010061d:	90                   	nop
8010061e:	90                   	nop
8010061f:	90                   	nop

80100620 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100620:	55                   	push   %ebp
80100621:	89 e5                	mov    %esp,%ebp
80100623:	57                   	push   %edi
  int c, doprocdump = 0;

  acquire(&cons.lock);
80100624:	31 ff                	xor    %edi,%edi

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100626:	56                   	push   %esi
80100627:	53                   	push   %ebx
80100628:	83 ec 1c             	sub    $0x1c,%esp
8010062b:	8b 75 08             	mov    0x8(%ebp),%esi
  int c, doprocdump = 0;

  acquire(&cons.lock);
8010062e:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
80100635:	e8 96 3d 00 00       	call   801043d0 <acquire>
8010063a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  while((c = getc()) >= 0){
80100640:	ff d6                	call   *%esi
80100642:	85 c0                	test   %eax,%eax
80100644:	89 c3                	mov    %eax,%ebx
80100646:	0f 88 98 00 00 00    	js     801006e4 <consoleintr+0xc4>
    switch(c){
8010064c:	83 fb 10             	cmp    $0x10,%ebx
8010064f:	90                   	nop
80100650:	0f 84 32 01 00 00    	je     80100788 <consoleintr+0x168>
80100656:	0f 8f a4 00 00 00    	jg     80100700 <consoleintr+0xe0>
8010065c:	83 fb 08             	cmp    $0x8,%ebx
8010065f:	90                   	nop
80100660:	0f 84 a8 00 00 00    	je     8010070e <consoleintr+0xee>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100666:	85 db                	test   %ebx,%ebx
80100668:	74 d6                	je     80100640 <consoleintr+0x20>
8010066a:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
8010066f:	89 c2                	mov    %eax,%edx
80100671:	2b 15 c0 ff 10 80    	sub    0x8010ffc0,%edx
80100677:	83 fa 7f             	cmp    $0x7f,%edx
8010067a:	77 c4                	ja     80100640 <consoleintr+0x20>
        c = (c == '\r') ? '\n' : c;
8010067c:	83 fb 0d             	cmp    $0xd,%ebx
8010067f:	0f 84 0d 01 00 00    	je     80100792 <consoleintr+0x172>
        input.buf[input.e++ % INPUT_BUF] = c;
80100685:	89 c2                	mov    %eax,%edx
80100687:	83 c0 01             	add    $0x1,%eax
8010068a:	83 e2 7f             	and    $0x7f,%edx
8010068d:	88 9a 40 ff 10 80    	mov    %bl,-0x7fef00c0(%edx)
80100693:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(c);
80100698:	89 d8                	mov    %ebx,%eax
8010069a:	e8 91 fd ff ff       	call   80100430 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010069f:	83 fb 04             	cmp    $0x4,%ebx
801006a2:	0f 84 08 01 00 00    	je     801007b0 <consoleintr+0x190>
801006a8:	83 fb 0a             	cmp    $0xa,%ebx
801006ab:	0f 84 ff 00 00 00    	je     801007b0 <consoleintr+0x190>
801006b1:	8b 15 c0 ff 10 80    	mov    0x8010ffc0,%edx
801006b7:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
801006bc:	83 ea 80             	sub    $0xffffff80,%edx
801006bf:	39 d0                	cmp    %edx,%eax
801006c1:	0f 85 79 ff ff ff    	jne    80100640 <consoleintr+0x20>
          input.w = input.e;
801006c7:	a3 c4 ff 10 80       	mov    %eax,0x8010ffc4
          wakeup(&input.r);
801006cc:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
801006d3:	e8 88 30 00 00       	call   80103760 <wakeup>
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801006d8:	ff d6                	call   *%esi
801006da:	85 c0                	test   %eax,%eax
801006dc:	89 c3                	mov    %eax,%ebx
801006de:	0f 89 68 ff ff ff    	jns    8010064c <consoleintr+0x2c>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801006e4:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
801006eb:	e8 90 3c 00 00       	call   80104380 <release>
  if(doprocdump) {
801006f0:	85 ff                	test   %edi,%edi
801006f2:	0f 85 c2 00 00 00    	jne    801007ba <consoleintr+0x19a>
    procdump();  // now call procdump() wo. cons.lock held
  }
}
801006f8:	83 c4 1c             	add    $0x1c,%esp
801006fb:	5b                   	pop    %ebx
801006fc:	5e                   	pop    %esi
801006fd:	5f                   	pop    %edi
801006fe:	5d                   	pop    %ebp
801006ff:	c3                   	ret    
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
80100700:	83 fb 15             	cmp    $0x15,%ebx
80100703:	74 33                	je     80100738 <consoleintr+0x118>
80100705:	83 fb 7f             	cmp    $0x7f,%ebx
80100708:	0f 85 58 ff ff ff    	jne    80100666 <consoleintr+0x46>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010070e:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
80100713:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
80100719:	0f 84 21 ff ff ff    	je     80100640 <consoleintr+0x20>
        input.e--;
8010071f:	83 e8 01             	sub    $0x1,%eax
80100722:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(BACKSPACE);
80100727:	b8 00 01 00 00       	mov    $0x100,%eax
8010072c:	e8 ff fc ff ff       	call   80100430 <consputc>
80100731:	e9 0a ff ff ff       	jmp    80100640 <consoleintr+0x20>
80100736:	66 90                	xchg   %ax,%ax
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100738:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
8010073d:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
80100743:	75 2b                	jne    80100770 <consoleintr+0x150>
80100745:	e9 f6 fe ff ff       	jmp    80100640 <consoleintr+0x20>
8010074a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100750:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(BACKSPACE);
80100755:	b8 00 01 00 00       	mov    $0x100,%eax
8010075a:	e8 d1 fc ff ff       	call   80100430 <consputc>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010075f:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
80100764:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
8010076a:	0f 84 d0 fe ff ff    	je     80100640 <consoleintr+0x20>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100770:	83 e8 01             	sub    $0x1,%eax
80100773:	89 c2                	mov    %eax,%edx
80100775:	83 e2 7f             	and    $0x7f,%edx
80100778:	80 ba 40 ff 10 80 0a 	cmpb   $0xa,-0x7fef00c0(%edx)
8010077f:	75 cf                	jne    80100750 <consoleintr+0x130>
80100781:	e9 ba fe ff ff       	jmp    80100640 <consoleintr+0x20>
80100786:	66 90                	xchg   %ax,%ax
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
80100788:	bf 01 00 00 00       	mov    $0x1,%edi
8010078d:	e9 ae fe ff ff       	jmp    80100640 <consoleintr+0x20>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
80100792:	89 c2                	mov    %eax,%edx
80100794:	83 c0 01             	add    $0x1,%eax
80100797:	83 e2 7f             	and    $0x7f,%edx
8010079a:	c6 82 40 ff 10 80 0a 	movb   $0xa,-0x7fef00c0(%edx)
801007a1:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(c);
801007a6:	b8 0a 00 00 00       	mov    $0xa,%eax
801007ab:	e8 80 fc ff ff       	call   80100430 <consputc>
801007b0:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
801007b5:	e9 0d ff ff ff       	jmp    801006c7 <consoleintr+0xa7>
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
}
801007ba:	83 c4 1c             	add    $0x1c,%esp
801007bd:	5b                   	pop    %ebx
801007be:	5e                   	pop    %esi
801007bf:	5f                   	pop    %edi
801007c0:	5d                   	pop    %ebp
      break;
    }
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
801007c1:	e9 3a 2e 00 00       	jmp    80103600 <procdump>
801007c6:	8d 76 00             	lea    0x0(%esi),%esi
801007c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801007d0 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801007d0:	55                   	push   %ebp
801007d1:	89 e5                	mov    %esp,%ebp
801007d3:	57                   	push   %edi
801007d4:	56                   	push   %esi
801007d5:	89 d6                	mov    %edx,%esi
801007d7:	53                   	push   %ebx
801007d8:	83 ec 1c             	sub    $0x1c,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801007db:	85 c9                	test   %ecx,%ecx
801007dd:	74 04                	je     801007e3 <printint+0x13>
801007df:	85 c0                	test   %eax,%eax
801007e1:	78 55                	js     80100838 <printint+0x68>
    x = -xx;
  else
    x = xx;
801007e3:	31 ff                	xor    %edi,%edi
801007e5:	31 c9                	xor    %ecx,%ecx
801007e7:	8d 5d d8             	lea    -0x28(%ebp),%ebx
801007ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  i = 0;
  do{
    buf[i++] = digits[x % base];
801007f0:	31 d2                	xor    %edx,%edx
801007f2:	f7 f6                	div    %esi
801007f4:	0f b6 92 d0 6e 10 80 	movzbl -0x7fef9130(%edx),%edx
801007fb:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
801007fe:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
80100801:	85 c0                	test   %eax,%eax
80100803:	75 eb                	jne    801007f0 <printint+0x20>

  if(sign)
80100805:	85 ff                	test   %edi,%edi
80100807:	74 08                	je     80100811 <printint+0x41>
    buf[i++] = '-';
80100809:	c6 44 0d d8 2d       	movb   $0x2d,-0x28(%ebp,%ecx,1)
8010080e:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
80100811:	8d 71 ff             	lea    -0x1(%ecx),%esi
80100814:	01 f3                	add    %esi,%ebx
80100816:	66 90                	xchg   %ax,%ax
    consputc(buf[i]);
80100818:	0f be 03             	movsbl (%ebx),%eax
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010081b:	83 ee 01             	sub    $0x1,%esi
8010081e:	83 eb 01             	sub    $0x1,%ebx
    consputc(buf[i]);
80100821:	e8 0a fc ff ff       	call   80100430 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100826:	83 fe ff             	cmp    $0xffffffff,%esi
80100829:	75 ed                	jne    80100818 <printint+0x48>
    consputc(buf[i]);
}
8010082b:	83 c4 1c             	add    $0x1c,%esp
8010082e:	5b                   	pop    %ebx
8010082f:	5e                   	pop    %esi
80100830:	5f                   	pop    %edi
80100831:	5d                   	pop    %ebp
80100832:	c3                   	ret    
80100833:	90                   	nop
80100834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
80100838:	f7 d8                	neg    %eax
8010083a:	bf 01 00 00 00       	mov    $0x1,%edi
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010083f:	eb a4                	jmp    801007e5 <printint+0x15>
80100841:	eb 0d                	jmp    80100850 <cprintf>
80100843:	90                   	nop
80100844:	90                   	nop
80100845:	90                   	nop
80100846:	90                   	nop
80100847:	90                   	nop
80100848:	90                   	nop
80100849:	90                   	nop
8010084a:	90                   	nop
8010084b:	90                   	nop
8010084c:	90                   	nop
8010084d:	90                   	nop
8010084e:	90                   	nop
8010084f:	90                   	nop

80100850 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100850:	55                   	push   %ebp
80100851:	89 e5                	mov    %esp,%ebp
80100853:	57                   	push   %edi
80100854:	56                   	push   %esi
80100855:	53                   	push   %ebx
80100856:	83 ec 2c             	sub    $0x2c,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100859:	8b 3d 74 a5 10 80    	mov    0x8010a574,%edi
  if(locking)
8010085f:	85 ff                	test   %edi,%edi
80100861:	0f 85 39 01 00 00    	jne    801009a0 <cprintf+0x150>
    acquire(&cons.lock);

  if (fmt == 0)
80100867:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010086a:	85 c9                	test   %ecx,%ecx
8010086c:	0f 84 3f 01 00 00    	je     801009b1 <cprintf+0x161>
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100872:	0f b6 01             	movzbl (%ecx),%eax
80100875:	85 c0                	test   %eax,%eax
80100877:	0f 84 93 00 00 00    	je     80100910 <cprintf+0xc0>
    acquire(&cons.lock);

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
8010087d:	8d 75 0c             	lea    0xc(%ebp),%esi
80100880:	31 db                	xor    %ebx,%ebx
80100882:	eb 3f                	jmp    801008c3 <cprintf+0x73>
80100884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
80100888:	83 fa 25             	cmp    $0x25,%edx
8010088b:	0f 84 b7 00 00 00    	je     80100948 <cprintf+0xf8>
80100891:	83 fa 64             	cmp    $0x64,%edx
80100894:	0f 84 8e 00 00 00    	je     80100928 <cprintf+0xd8>
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010089a:	b8 25 00 00 00       	mov    $0x25,%eax
8010089f:	89 55 e0             	mov    %edx,-0x20(%ebp)
801008a2:	e8 89 fb ff ff       	call   80100430 <consputc>
      consputc(c);
801008a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801008aa:	89 d0                	mov    %edx,%eax
801008ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801008b0:	e8 7b fb ff ff       	call   80100430 <consputc>
801008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801008b8:	83 c3 01             	add    $0x1,%ebx
801008bb:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
801008bf:	85 c0                	test   %eax,%eax
801008c1:	74 4d                	je     80100910 <cprintf+0xc0>
    if(c != '%'){
801008c3:	83 f8 25             	cmp    $0x25,%eax
801008c6:	75 e8                	jne    801008b0 <cprintf+0x60>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
801008c8:	83 c3 01             	add    $0x1,%ebx
801008cb:	0f b6 14 19          	movzbl (%ecx,%ebx,1),%edx
    if(c == 0)
801008cf:	85 d2                	test   %edx,%edx
801008d1:	74 3d                	je     80100910 <cprintf+0xc0>
      break;
    switch(c){
801008d3:	83 fa 70             	cmp    $0x70,%edx
801008d6:	74 12                	je     801008ea <cprintf+0x9a>
801008d8:	7e ae                	jle    80100888 <cprintf+0x38>
801008da:	83 fa 73             	cmp    $0x73,%edx
801008dd:	8d 76 00             	lea    0x0(%esi),%esi
801008e0:	74 7e                	je     80100960 <cprintf+0x110>
801008e2:	83 fa 78             	cmp    $0x78,%edx
801008e5:	8d 76 00             	lea    0x0(%esi),%esi
801008e8:	75 b0                	jne    8010089a <cprintf+0x4a>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801008ea:	8b 06                	mov    (%esi),%eax
801008ec:	31 c9                	xor    %ecx,%ecx
801008ee:	ba 10 00 00 00       	mov    $0x10,%edx

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801008f3:	83 c3 01             	add    $0x1,%ebx
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801008f6:	83 c6 04             	add    $0x4,%esi
801008f9:	e8 d2 fe ff ff       	call   801007d0 <printint>
801008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100901:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
80100905:	85 c0                	test   %eax,%eax
80100907:	75 ba                	jne    801008c3 <cprintf+0x73>
80100909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      consputc(c);
      break;
    }
  }

  if(locking)
80100910:	85 ff                	test   %edi,%edi
80100912:	74 0c                	je     80100920 <cprintf+0xd0>
    release(&cons.lock);
80100914:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
8010091b:	e8 60 3a 00 00       	call   80104380 <release>
}
80100920:	83 c4 2c             	add    $0x2c,%esp
80100923:	5b                   	pop    %ebx
80100924:	5e                   	pop    %esi
80100925:	5f                   	pop    %edi
80100926:	5d                   	pop    %ebp
80100927:	c3                   	ret    
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
80100928:	8b 06                	mov    (%esi),%eax
8010092a:	b9 01 00 00 00       	mov    $0x1,%ecx
8010092f:	ba 0a 00 00 00       	mov    $0xa,%edx
80100934:	83 c6 04             	add    $0x4,%esi
80100937:	e8 94 fe ff ff       	call   801007d0 <printint>
8010093c:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
8010093f:	e9 74 ff ff ff       	jmp    801008b8 <cprintf+0x68>
80100944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
80100948:	b8 25 00 00 00       	mov    $0x25,%eax
8010094d:	e8 de fa ff ff       	call   80100430 <consputc>
80100952:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
80100955:	e9 5e ff ff ff       	jmp    801008b8 <cprintf+0x68>
8010095a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
80100960:	8b 16                	mov    (%esi),%edx
80100962:	b8 c9 6e 10 80       	mov    $0x80106ec9,%eax
80100967:	83 c6 04             	add    $0x4,%esi
8010096a:	85 d2                	test   %edx,%edx
8010096c:	0f 44 d0             	cmove  %eax,%edx
        s = "(null)";
      for(; *s; s++)
8010096f:	0f b6 02             	movzbl (%edx),%eax
80100972:	84 c0                	test   %al,%al
80100974:	0f 84 3e ff ff ff    	je     801008b8 <cprintf+0x68>
8010097a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
8010097d:	89 d3                	mov    %edx,%ebx
8010097f:	90                   	nop
        consputc(*s);
80100980:	0f be c0             	movsbl %al,%eax
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100983:	83 c3 01             	add    $0x1,%ebx
        consputc(*s);
80100986:	e8 a5 fa ff ff       	call   80100430 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
8010098b:	0f b6 03             	movzbl (%ebx),%eax
8010098e:	84 c0                	test   %al,%al
80100990:	75 ee                	jne    80100980 <cprintf+0x130>
80100992:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80100995:	8b 4d 08             	mov    0x8(%ebp),%ecx
80100998:	e9 1b ff ff ff       	jmp    801008b8 <cprintf+0x68>
8010099d:	8d 76 00             	lea    0x0(%esi),%esi
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
801009a0:	c7 04 24 40 a5 10 80 	movl   $0x8010a540,(%esp)
801009a7:	e8 24 3a 00 00       	call   801043d0 <acquire>
801009ac:	e9 b6 fe ff ff       	jmp    80100867 <cprintf+0x17>

  if (fmt == 0)
    panic("null fmt");
801009b1:	c7 04 24 c0 6e 10 80 	movl   $0x80106ec0,(%esp)
801009b8:	e8 f3 f9 ff ff       	call   801003b0 <panic>
801009bd:	00 00                	add    %al,(%eax)
	...

801009c0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801009c0:	55                   	push   %ebp
801009c1:	89 e5                	mov    %esp,%ebp
801009c3:	57                   	push   %edi
801009c4:	56                   	push   %esi
801009c5:	53                   	push   %ebx
801009c6:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801009cc:	e8 3f 31 00 00       	call   80103b10 <myproc>
801009d1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801009d7:	e8 e4 23 00 00       	call   80102dc0 <begin_op>

  if((ip = namei(path)) == 0){
801009dc:	8b 45 08             	mov    0x8(%ebp),%eax
801009df:	89 04 24             	mov    %eax,(%esp)
801009e2:	e8 99 15 00 00       	call   80101f80 <namei>
801009e7:	85 c0                	test   %eax,%eax
801009e9:	89 c7                	mov    %eax,%edi
801009eb:	0f 84 34 03 00 00    	je     80100d25 <exec+0x365>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
801009f1:	89 04 24             	mov    %eax,(%esp)
801009f4:	e8 57 10 00 00       	call   80101a50 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
801009f9:	8d 45 94             	lea    -0x6c(%ebp),%eax
801009fc:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100a03:	00 
80100a04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100a0b:	00 
80100a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a10:	89 3c 24             	mov    %edi,(%esp)
80100a13:	e8 a8 0d 00 00       	call   801017c0 <readi>
80100a18:	83 f8 34             	cmp    $0x34,%eax
80100a1b:	0f 85 f7 01 00 00    	jne    80100c18 <exec+0x258>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100a21:	81 7d 94 7f 45 4c 46 	cmpl   $0x464c457f,-0x6c(%ebp)
80100a28:	0f 85 ea 01 00 00    	jne    80100c18 <exec+0x258>
80100a2e:	66 90                	xchg   %ax,%ax
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100a30:	e8 cb 5e 00 00       	call   80106900 <setupkvm>
80100a35:	85 c0                	test   %eax,%eax
80100a37:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100a3d:	0f 84 d5 01 00 00    	je     80100c18 <exec+0x258>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100a43:	66 83 7d c0 00       	cmpw   $0x0,-0x40(%ebp)
80100a48:	8b 5d b0             	mov    -0x50(%ebp),%ebx
80100a4b:	0f 84 c8 02 00 00    	je     80100d19 <exec+0x359>
80100a51:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100a58:	00 00 00 
80100a5b:	31 f6                	xor    %esi,%esi
80100a5d:	eb 13                	jmp    80100a72 <exec+0xb2>
80100a5f:	90                   	nop
80100a60:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80100a64:	83 c6 01             	add    $0x1,%esi
80100a67:	39 f0                	cmp    %esi,%eax
80100a69:	0f 8e c1 00 00 00    	jle    80100b30 <exec+0x170>
80100a6f:	83 c3 20             	add    $0x20,%ebx
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100a72:	8d 55 c8             	lea    -0x38(%ebp),%edx
80100a75:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100a7c:	00 
80100a7d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80100a81:	89 54 24 04          	mov    %edx,0x4(%esp)
80100a85:	89 3c 24             	mov    %edi,(%esp)
80100a88:	e8 33 0d 00 00       	call   801017c0 <readi>
80100a8d:	83 f8 20             	cmp    $0x20,%eax
80100a90:	75 76                	jne    80100b08 <exec+0x148>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100a92:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
80100a96:	75 c8                	jne    80100a60 <exec+0xa0>
      continue;
    if(ph.memsz < ph.filesz)
80100a98:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100a9b:	3b 45 d8             	cmp    -0x28(%ebp),%eax
80100a9e:	66 90                	xchg   %ax,%ax
80100aa0:	72 66                	jb     80100b08 <exec+0x148>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100aa2:	03 45 d0             	add    -0x30(%ebp),%eax
80100aa5:	72 61                	jb     80100b08 <exec+0x148>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100aab:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100ab1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100ab7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80100abb:	89 04 24             	mov    %eax,(%esp)
80100abe:	e8 cd 5f 00 00       	call   80106a90 <allocuvm>
80100ac3:	85 c0                	test   %eax,%eax
80100ac5:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100acb:	74 3b                	je     80100b08 <exec+0x148>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100acd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ad0:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100ad5:	75 31                	jne    80100b08 <exec+0x148>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ad7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100ada:	89 7c 24 08          	mov    %edi,0x8(%esp)
80100ade:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ae2:	89 54 24 10          	mov    %edx,0x10(%esp)
80100ae6:	8b 55 cc             	mov    -0x34(%ebp),%edx
80100ae9:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100aed:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100af3:	89 14 24             	mov    %edx,(%esp)
80100af6:	e8 b5 60 00 00       	call   80106bb0 <loaduvm>
80100afb:	85 c0                	test   %eax,%eax
80100afd:	0f 89 5d ff ff ff    	jns    80100a60 <exec+0xa0>
80100b03:	90                   	nop
80100b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
80100b08:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100b0e:	89 04 24             	mov    %eax,(%esp)
80100b11:	e8 6a 5d 00 00       	call   80106880 <freevm>
  if(ip){
80100b16:	85 ff                	test   %edi,%edi
80100b18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1d:	0f 85 f5 00 00 00    	jne    80100c18 <exec+0x258>
    iunlockput(ip);
    end_op();
  }
  return -1;
}
80100b23:	81 c4 2c 01 00 00    	add    $0x12c,%esp
80100b29:	5b                   	pop    %ebx
80100b2a:	5e                   	pop    %esi
80100b2b:	5f                   	pop    %edi
80100b2c:	5d                   	pop    %ebp
80100b2d:	c3                   	ret    
80100b2e:	66 90                	xchg   %ax,%ax
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b30:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
80100b36:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
80100b3c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80100b42:	8d b3 00 20 00 00    	lea    0x2000(%ebx),%esi
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100b48:	89 3c 24             	mov    %edi,(%esp)
80100b4b:	e8 80 12 00 00       	call   80101dd0 <iunlockput>
  end_op();
80100b50:	e8 3b 21 00 00       	call   80102c90 <end_op>
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100b55:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100b5b:	89 74 24 08          	mov    %esi,0x8(%esp)
80100b5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100b63:	89 0c 24             	mov    %ecx,(%esp)
80100b66:	e8 25 5f 00 00       	call   80106a90 <allocuvm>
80100b6b:	85 c0                	test   %eax,%eax
80100b6d:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100b73:	0f 84 96 00 00 00    	je     80100c0f <exec+0x24f>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100b79:	2d 00 20 00 00       	sub    $0x2000,%eax
80100b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b82:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100b88:	89 04 24             	mov    %eax,(%esp)
80100b8b:	e8 80 5b 00 00       	call   80106710 <clearpteu>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100b90:	8b 55 0c             	mov    0xc(%ebp),%edx
80100b93:	8b 02                	mov    (%edx),%eax
80100b95:	85 c0                	test   %eax,%eax
80100b97:	0f 84 a1 01 00 00    	je     80100d3e <exec+0x37e>
80100b9d:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100ba0:	31 f6                	xor    %esi,%esi
80100ba2:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
80100ba8:	eb 28                	jmp    80100bd2 <exec+0x212>
80100baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
80100bb0:	89 9c b5 10 ff ff ff 	mov    %ebx,-0xf0(%ebp,%esi,4)
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
80100bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100bba:	83 c6 01             	add    $0x1,%esi
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
80100bbd:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
80100bc3:	8d 3c b0             	lea    (%eax,%esi,4),%edi
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100bc6:	8b 04 b0             	mov    (%eax,%esi,4),%eax
80100bc9:	85 c0                	test   %eax,%eax
80100bcb:	74 67                	je     80100c34 <exec+0x274>
    if(argc >= MAXARG)
80100bcd:	83 fe 20             	cmp    $0x20,%esi
80100bd0:	74 3d                	je     80100c0f <exec+0x24f>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100bd2:	89 04 24             	mov    %eax,(%esp)
80100bd5:	e8 86 3a 00 00       	call   80104660 <strlen>
80100bda:	f7 d0                	not    %eax
80100bdc:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100bdf:	8b 07                	mov    (%edi),%eax

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100be1:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100be4:	89 04 24             	mov    %eax,(%esp)
80100be7:	e8 74 3a 00 00       	call   80104660 <strlen>
80100bec:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100bf2:	83 c0 01             	add    $0x1,%eax
80100bf5:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100bf9:	8b 07                	mov    (%edi),%eax
80100bfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100bff:	89 0c 24             	mov    %ecx,(%esp)
80100c02:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c06:	e8 e5 59 00 00       	call   801065f0 <copyout>
80100c0b:	85 c0                	test   %eax,%eax
80100c0d:	79 a1                	jns    80100bb0 <exec+0x1f0>
 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
    end_op();
80100c0f:	31 ff                	xor    %edi,%edi
80100c11:	e9 f2 fe ff ff       	jmp    80100b08 <exec+0x148>
80100c16:	66 90                	xchg   %ax,%ax

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100c18:	89 3c 24             	mov    %edi,(%esp)
80100c1b:	90                   	nop
80100c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100c20:	e8 ab 11 00 00       	call   80101dd0 <iunlockput>
    end_op();
80100c25:	e8 66 20 00 00       	call   80102c90 <end_op>
80100c2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c2f:	e9 ef fe ff ff       	jmp    80100b23 <exec+0x163>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100c34:	8d 4e 03             	lea    0x3(%esi),%ecx
80100c37:	8d 3c b5 04 00 00 00 	lea    0x4(,%esi,4),%edi
80100c3e:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100c45:	c7 84 8d 04 ff ff ff 	movl   $0x0,-0xfc(%ebp,%ecx,4)
80100c4c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100c50:	89 d9                	mov    %ebx,%ecx

  sp -= (3+argc+1) * 4;
80100c52:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100c54:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100c58:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100c5e:	29 f9                	sub    %edi,%ecx
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;

  ustack[0] = 0xffffffff;  // fake return PC
80100c60:	c7 85 04 ff ff ff ff 	movl   $0xffffffff,-0xfc(%ebp)
80100c67:	ff ff ff 
  ustack[1] = argc;
80100c6a:	89 b5 08 ff ff ff    	mov    %esi,-0xf8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100c70:	89 8d 0c ff ff ff    	mov    %ecx,-0xf4(%ebp)

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100c76:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100c7e:	89 04 24             	mov    %eax,(%esp)
80100c81:	e8 6a 59 00 00       	call   801065f0 <copyout>
80100c86:	85 c0                	test   %eax,%eax
80100c88:	78 85                	js     80100c0f <exec+0x24f>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100c8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80100c8d:	0f b6 11             	movzbl (%ecx),%edx
80100c90:	84 d2                	test   %dl,%dl
80100c92:	74 1c                	je     80100cb0 <exec+0x2f0>
80100c94:	89 c8                	mov    %ecx,%eax
80100c96:	83 c0 01             	add    $0x1,%eax
80100c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(*s == '/')
80100ca0:	80 fa 2f             	cmp    $0x2f,%dl
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ca3:	0f b6 10             	movzbl (%eax),%edx
    if(*s == '/')
80100ca6:	0f 44 c8             	cmove  %eax,%ecx
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ca9:	83 c0 01             	add    $0x1,%eax
80100cac:	84 d2                	test   %dl,%dl
80100cae:	75 f0                	jne    80100ca0 <exec+0x2e0>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100cb0:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cb6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80100cba:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100cc1:	00 
80100cc2:	83 c0 6c             	add    $0x6c,%eax
80100cc5:	89 04 24             	mov    %eax,(%esp)
80100cc8:	e8 53 39 00 00       	call   80104620 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ccd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
  curproc->pgdir = pgdir;
80100cd3:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100cd9:	8b 70 04             	mov    0x4(%eax),%esi
  curproc->pgdir = pgdir;
80100cdc:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100cdf:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100ce5:	89 08                	mov    %ecx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100ce7:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ced:	8b 42 18             	mov    0x18(%edx),%eax
80100cf0:	8b 55 ac             	mov    -0x54(%ebp),%edx
80100cf3:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100cf6:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100cfc:	8b 41 18             	mov    0x18(%ecx),%eax
80100cff:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100d02:	89 0c 24             	mov    %ecx,(%esp)
80100d05:	e8 66 5f 00 00       	call   80106c70 <switchuvm>
  freevm(oldpgdir);
80100d0a:	89 34 24             	mov    %esi,(%esp)
80100d0d:	e8 6e 5b 00 00       	call   80106880 <freevm>
80100d12:	31 c0                	xor    %eax,%eax
  return 0;
80100d14:	e9 0a fe ff ff       	jmp    80100b23 <exec+0x163>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d19:	be 00 20 00 00       	mov    $0x2000,%esi
80100d1e:	31 db                	xor    %ebx,%ebx
80100d20:	e9 23 fe ff ff       	jmp    80100b48 <exec+0x188>
  struct proc *curproc = myproc();

  begin_op();

  if((ip = namei(path)) == 0){
    end_op();
80100d25:	e8 66 1f 00 00       	call   80102c90 <end_op>
    cprintf("exec: fail\n");
80100d2a:	c7 04 24 e1 6e 10 80 	movl   $0x80106ee1,(%esp)
80100d31:	e8 1a fb ff ff       	call   80100850 <cprintf>
80100d36:	83 c8 ff             	or     $0xffffffff,%eax
    return -1;
80100d39:	e9 e5 fd ff ff       	jmp    80100b23 <exec+0x163>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d3e:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
80100d44:	b0 10                	mov    $0x10,%al
80100d46:	bf 04 00 00 00       	mov    $0x4,%edi
80100d4b:	b9 03 00 00 00       	mov    $0x3,%ecx
80100d50:	31 f6                	xor    %esi,%esi
80100d52:	8d 95 04 ff ff ff    	lea    -0xfc(%ebp),%edx
80100d58:	e9 e8 fe ff ff       	jmp    80100c45 <exec+0x285>
80100d5d:	00 00                	add    %al,(%eax)
	...

80100d60 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100d60:	55                   	push   %ebp
80100d61:	89 e5                	mov    %esp,%ebp
80100d63:	57                   	push   %edi
80100d64:	56                   	push   %esi
80100d65:	53                   	push   %ebx
80100d66:	83 ec 2c             	sub    $0x2c,%esp
80100d69:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100d6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d72:	8b 45 10             	mov    0x10(%ebp),%eax
80100d75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int r;

  if(f->writable == 0)
80100d78:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100d7c:	0f 84 ae 00 00 00    	je     80100e30 <filewrite+0xd0>
    return -1;
  if(f->type == FD_PIPE)
80100d82:	8b 03                	mov    (%ebx),%eax
80100d84:	83 f8 01             	cmp    $0x1,%eax
80100d87:	0f 84 c2 00 00 00    	je     80100e4f <filewrite+0xef>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100d8d:	83 f8 02             	cmp    $0x2,%eax
80100d90:	0f 85 d7 00 00 00    	jne    80100e6d <filewrite+0x10d>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d99:	31 f6                	xor    %esi,%esi
80100d9b:	85 c0                	test   %eax,%eax
80100d9d:	7f 31                	jg     80100dd0 <filewrite+0x70>
80100d9f:	90                   	nop
80100da0:	e9 9b 00 00 00       	jmp    80100e40 <filewrite+0xe0>
80100da5:	8d 76 00             	lea    0x0(%esi),%esi

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
      iunlock(f->ip);
80100da8:	8b 53 10             	mov    0x10(%ebx),%edx
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80100dab:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100dae:	89 14 24             	mov    %edx,(%esp)
80100db1:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100db4:	e8 c7 0f 00 00       	call   80101d80 <iunlock>
      end_op();
80100db9:	e8 d2 1e 00 00       	call   80102c90 <end_op>
80100dbe:	8b 45 dc             	mov    -0x24(%ebp),%eax

      if(r < 0)
        break;
      if(r != n1)
80100dc1:	39 f8                	cmp    %edi,%eax
80100dc3:	0f 85 98 00 00 00    	jne    80100e61 <filewrite+0x101>
        panic("short filewrite");
      i += r;
80100dc9:	01 c6                	add    %eax,%esi
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100dcb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100dce:	7e 70                	jle    80100e40 <filewrite+0xe0>
      int n1 = n - i;
80100dd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80100dd3:	b8 00 06 00 00       	mov    $0x600,%eax
80100dd8:	29 f7                	sub    %esi,%edi
80100dda:	81 ff 00 06 00 00    	cmp    $0x600,%edi
80100de0:	0f 4f f8             	cmovg  %eax,%edi
      if(n1 > max)
        n1 = max;

      begin_op();
80100de3:	e8 d8 1f 00 00       	call   80102dc0 <begin_op>
      ilock(f->ip);
80100de8:	8b 43 10             	mov    0x10(%ebx),%eax
80100deb:	89 04 24             	mov    %eax,(%esp)
80100dee:	e8 5d 0c 00 00       	call   80101a50 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100df3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80100df7:	8b 43 14             	mov    0x14(%ebx),%eax
80100dfa:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e01:	01 f0                	add    %esi,%eax
80100e03:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e07:	8b 43 10             	mov    0x10(%ebx),%eax
80100e0a:	89 04 24             	mov    %eax,(%esp)
80100e0d:	e8 8e 08 00 00       	call   801016a0 <writei>
80100e12:	85 c0                	test   %eax,%eax
80100e14:	7f 92                	jg     80100da8 <filewrite+0x48>
        f->off += r;
      iunlock(f->ip);
80100e16:	8b 53 10             	mov    0x10(%ebx),%edx
80100e19:	89 14 24             	mov    %edx,(%esp)
80100e1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100e1f:	e8 5c 0f 00 00       	call   80101d80 <iunlock>
      end_op();
80100e24:	e8 67 1e 00 00       	call   80102c90 <end_op>

      if(r < 0)
80100e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2c:	85 c0                	test   %eax,%eax
80100e2e:	74 91                	je     80100dc1 <filewrite+0x61>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
80100e30:	83 c4 2c             	add    $0x2c,%esp
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
80100e33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100e38:	5b                   	pop    %ebx
80100e39:	5e                   	pop    %esi
80100e3a:	5f                   	pop    %edi
80100e3b:	5d                   	pop    %ebp
80100e3c:	c3                   	ret    
80100e3d:	8d 76 00             	lea    0x0(%esi),%esi
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80100e40:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
  }
  panic("filewrite");
80100e43:	89 f0                	mov    %esi,%eax
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80100e45:	75 e9                	jne    80100e30 <filewrite+0xd0>
  }
  panic("filewrite");
}
80100e47:	83 c4 2c             	add    $0x2c,%esp
80100e4a:	5b                   	pop    %ebx
80100e4b:	5e                   	pop    %esi
80100e4c:	5f                   	pop    %edi
80100e4d:	5d                   	pop    %ebp
80100e4e:	c3                   	ret    
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100e4f:	8b 43 0c             	mov    0xc(%ebx),%eax
80100e52:	89 45 08             	mov    %eax,0x8(%ebp)
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
80100e55:	83 c4 2c             	add    $0x2c,%esp
80100e58:	5b                   	pop    %ebx
80100e59:	5e                   	pop    %esi
80100e5a:	5f                   	pop    %edi
80100e5b:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100e5c:	e9 2f 25 00 00       	jmp    80103390 <pipewrite>
      end_op();

      if(r < 0)
        break;
      if(r != n1)
        panic("short filewrite");
80100e61:	c7 04 24 ed 6e 10 80 	movl   $0x80106eed,(%esp)
80100e68:	e8 43 f5 ff ff       	call   801003b0 <panic>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
80100e6d:	c7 04 24 f3 6e 10 80 	movl   $0x80106ef3,(%esp)
80100e74:	e8 37 f5 ff ff       	call   801003b0 <panic>
80100e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100e80 <fileread>:
}

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100e80:	55                   	push   %ebp
80100e81:	89 e5                	mov    %esp,%ebp
80100e83:	83 ec 38             	sub    $0x38,%esp
80100e86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
80100e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100e8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
80100e8f:	8b 75 0c             	mov    0xc(%ebp),%esi
80100e92:	89 7d fc             	mov    %edi,-0x4(%ebp)
80100e95:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80100e98:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e9c:	74 5a                	je     80100ef8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80100e9e:	8b 03                	mov    (%ebx),%eax
80100ea0:	83 f8 01             	cmp    $0x1,%eax
80100ea3:	74 5b                	je     80100f00 <fileread+0x80>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100ea5:	83 f8 02             	cmp    $0x2,%eax
80100ea8:	75 6d                	jne    80100f17 <fileread+0x97>
    ilock(f->ip);
80100eaa:	8b 43 10             	mov    0x10(%ebx),%eax
80100ead:	89 04 24             	mov    %eax,(%esp)
80100eb0:	e8 9b 0b 00 00       	call   80101a50 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100eb5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80100eb9:	8b 43 14             	mov    0x14(%ebx),%eax
80100ebc:	89 74 24 04          	mov    %esi,0x4(%esp)
80100ec0:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ec4:	8b 43 10             	mov    0x10(%ebx),%eax
80100ec7:	89 04 24             	mov    %eax,(%esp)
80100eca:	e8 f1 08 00 00       	call   801017c0 <readi>
80100ecf:	85 c0                	test   %eax,%eax
80100ed1:	7e 03                	jle    80100ed6 <fileread+0x56>
      f->off += r;
80100ed3:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100ed6:	8b 53 10             	mov    0x10(%ebx),%edx
80100ed9:	89 14 24             	mov    %edx,(%esp)
80100edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100edf:	e8 9c 0e 00 00       	call   80101d80 <iunlock>
    return r;
80100ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
80100ee7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80100eea:	8b 75 f8             	mov    -0x8(%ebp),%esi
80100eed:	8b 7d fc             	mov    -0x4(%ebp),%edi
80100ef0:	89 ec                	mov    %ebp,%esp
80100ef2:	5d                   	pop    %ebp
80100ef3:	c3                   	ret    
80100ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
80100ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100efd:	eb e8                	jmp    80100ee7 <fileread+0x67>
80100eff:	90                   	nop
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100f00:	8b 43 0c             	mov    0xc(%ebx),%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80100f03:	8b 75 f8             	mov    -0x8(%ebp),%esi
80100f06:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80100f09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100f0c:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80100f0f:	89 ec                	mov    %ebp,%esp
80100f11:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100f12:	e9 89 23 00 00       	jmp    801032a0 <piperead>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
80100f17:	c7 04 24 fd 6e 10 80 	movl   $0x80106efd,(%esp)
80100f1e:	e8 8d f4 ff ff       	call   801003b0 <panic>
80100f23:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100f30 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100f30:	55                   	push   %ebp
  if(f->type == FD_INODE){
80100f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100f36:	89 e5                	mov    %esp,%ebp
80100f38:	53                   	push   %ebx
80100f39:	83 ec 14             	sub    $0x14,%esp
80100f3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100f3f:	83 3b 02             	cmpl   $0x2,(%ebx)
80100f42:	74 0c                	je     80100f50 <filestat+0x20>
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
}
80100f44:	83 c4 14             	add    $0x14,%esp
80100f47:	5b                   	pop    %ebx
80100f48:	5d                   	pop    %ebp
80100f49:	c3                   	ret    
80100f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
80100f50:	8b 43 10             	mov    0x10(%ebx),%eax
80100f53:	89 04 24             	mov    %eax,(%esp)
80100f56:	e8 f5 0a 00 00       	call   80101a50 <ilock>
    stati(f->ip, st);
80100f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f62:	8b 43 10             	mov    0x10(%ebx),%eax
80100f65:	89 04 24             	mov    %eax,(%esp)
80100f68:	e8 e3 01 00 00       	call   80101150 <stati>
    iunlock(f->ip);
80100f6d:	8b 43 10             	mov    0x10(%ebx),%eax
80100f70:	89 04 24             	mov    %eax,(%esp)
80100f73:	e8 08 0e 00 00       	call   80101d80 <iunlock>
    return 0;
  }
  return -1;
}
80100f78:	83 c4 14             	add    $0x14,%esp
filestat(struct file *f, struct stat *st)
{
  if(f->type == FD_INODE){
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
80100f7b:	31 c0                	xor    %eax,%eax
    return 0;
  }
  return -1;
}
80100f7d:	5b                   	pop    %ebx
80100f7e:	5d                   	pop    %ebp
80100f7f:	c3                   	ret    

80100f80 <filedup>:
}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f80:	55                   	push   %ebp
80100f81:	89 e5                	mov    %esp,%ebp
80100f83:	53                   	push   %ebx
80100f84:	83 ec 14             	sub    $0x14,%esp
80100f87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100f8a:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100f91:	e8 3a 34 00 00       	call   801043d0 <acquire>
  if(f->ref < 1)
80100f96:	8b 43 04             	mov    0x4(%ebx),%eax
80100f99:	85 c0                	test   %eax,%eax
80100f9b:	7e 1a                	jle    80100fb7 <filedup+0x37>
    panic("filedup");
  f->ref++;
80100f9d:	83 c0 01             	add    $0x1,%eax
80100fa0:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100fa3:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100faa:	e8 d1 33 00 00       	call   80104380 <release>
  return f;
}
80100faf:	89 d8                	mov    %ebx,%eax
80100fb1:	83 c4 14             	add    $0x14,%esp
80100fb4:	5b                   	pop    %ebx
80100fb5:	5d                   	pop    %ebp
80100fb6:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
80100fb7:	c7 04 24 06 6f 10 80 	movl   $0x80106f06,(%esp)
80100fbe:	e8 ed f3 ff ff       	call   801003b0 <panic>
80100fc3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100fc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100fd0 <filealloc>:
}

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fd0:	55                   	push   %ebp
80100fd1:	89 e5                	mov    %esp,%ebp
80100fd3:	53                   	push   %ebx
  initlock(&ftable.lock, "ftable");
}

// Allocate a file structure.
struct file*
filealloc(void)
80100fd4:	bb 2c 00 11 80       	mov    $0x8011002c,%ebx
{
80100fd9:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fdc:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80100fe3:	e8 e8 33 00 00       	call   801043d0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
80100fe8:	8b 0d 18 00 11 80    	mov    0x80110018,%ecx
80100fee:	85 c9                	test   %ecx,%ecx
80100ff0:	75 11                	jne    80101003 <filealloc+0x33>
80100ff2:	eb 4a                	jmp    8010103e <filealloc+0x6e>
80100ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff8:	83 c3 18             	add    $0x18,%ebx
80100ffb:	81 fb 74 09 11 80    	cmp    $0x80110974,%ebx
80101001:	74 25                	je     80101028 <filealloc+0x58>
    if(f->ref == 0){
80101003:	8b 53 04             	mov    0x4(%ebx),%edx
80101006:	85 d2                	test   %edx,%edx
80101008:	75 ee                	jne    80100ff8 <filealloc+0x28>
      f->ref = 1;
8010100a:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80101011:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80101018:	e8 63 33 00 00       	call   80104380 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
8010101d:	89 d8                	mov    %ebx,%eax
8010101f:	83 c4 14             	add    $0x14,%esp
80101022:	5b                   	pop    %ebx
80101023:	5d                   	pop    %ebp
80101024:	c3                   	ret    
80101025:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101028:	31 db                	xor    %ebx,%ebx
8010102a:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80101031:	e8 4a 33 00 00       	call   80104380 <release>
  return 0;
}
80101036:	89 d8                	mov    %ebx,%eax
80101038:	83 c4 14             	add    $0x14,%esp
8010103b:	5b                   	pop    %ebx
8010103c:	5d                   	pop    %ebp
8010103d:	c3                   	ret    
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
8010103e:	bb 14 00 11 80       	mov    $0x80110014,%ebx
80101043:	eb c5                	jmp    8010100a <filealloc+0x3a>
80101045:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101049:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101050 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101050:	55                   	push   %ebp
80101051:	89 e5                	mov    %esp,%ebp
80101053:	83 ec 38             	sub    $0x38,%esp
80101056:	89 5d f4             	mov    %ebx,-0xc(%ebp)
80101059:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010105c:	89 75 f8             	mov    %esi,-0x8(%ebp)
8010105f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct file ff;

  acquire(&ftable.lock);
80101062:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80101069:	e8 62 33 00 00       	call   801043d0 <acquire>
  if(f->ref < 1)
8010106e:	8b 43 04             	mov    0x4(%ebx),%eax
80101071:	85 c0                	test   %eax,%eax
80101073:	0f 8e a4 00 00 00    	jle    8010111d <fileclose+0xcd>
    panic("fileclose");
  if(--f->ref > 0){
80101079:	83 e8 01             	sub    $0x1,%eax
8010107c:	85 c0                	test   %eax,%eax
8010107e:	89 43 04             	mov    %eax,0x4(%ebx)
80101081:	74 1d                	je     801010a0 <fileclose+0x50>
    release(&ftable.lock);
80101083:	c7 45 08 e0 ff 10 80 	movl   $0x8010ffe0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
8010108a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010108d:	8b 75 f8             	mov    -0x8(%ebp),%esi
80101090:	8b 7d fc             	mov    -0x4(%ebp),%edi
80101093:	89 ec                	mov    %ebp,%esp
80101095:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
80101096:	e9 e5 32 00 00       	jmp    80104380 <release>
8010109b:	90                   	nop
8010109c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  }
  ff = *f;
801010a0:	8b 43 0c             	mov    0xc(%ebx),%eax
801010a3:	8b 7b 10             	mov    0x10(%ebx),%edi
801010a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801010a9:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
801010ad:	88 45 e7             	mov    %al,-0x19(%ebp)
801010b0:	8b 33                	mov    (%ebx),%esi
  f->ref = 0;
801010b2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
801010b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
801010bf:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
801010c6:	e8 b5 32 00 00       	call   80104380 <release>

  if(ff.type == FD_PIPE)
801010cb:	83 fe 01             	cmp    $0x1,%esi
801010ce:	74 38                	je     80101108 <fileclose+0xb8>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
801010d0:	83 fe 02             	cmp    $0x2,%esi
801010d3:	74 13                	je     801010e8 <fileclose+0x98>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
801010d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801010d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
801010db:	8b 7d fc             	mov    -0x4(%ebp),%edi
801010de:	89 ec                	mov    %ebp,%esp
801010e0:	5d                   	pop    %ebp
801010e1:	c3                   	ret    
801010e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
801010e8:	e8 d3 1c 00 00       	call   80102dc0 <begin_op>
    iput(ff.ip);
801010ed:	89 3c 24             	mov    %edi,(%esp)
801010f0:	e8 3b 0a 00 00       	call   80101b30 <iput>
    end_op();
  }
}
801010f5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801010f8:	8b 75 f8             	mov    -0x8(%ebp),%esi
801010fb:	8b 7d fc             	mov    -0x4(%ebp),%edi
801010fe:	89 ec                	mov    %ebp,%esp
80101100:	5d                   	pop    %ebp
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
80101101:	e9 8a 1b 00 00       	jmp    80102c90 <end_op>
80101106:	66 90                	xchg   %ax,%ax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
80101108:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
8010110c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101110:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101113:	89 04 24             	mov    %eax,(%esp)
80101116:	e8 65 23 00 00       	call   80103480 <pipeclose>
8010111b:	eb b8                	jmp    801010d5 <fileclose+0x85>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
8010111d:	c7 04 24 0e 6f 10 80 	movl   $0x80106f0e,(%esp)
80101124:	e8 87 f2 ff ff       	call   801003b0 <panic>
80101129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101130 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101130:	55                   	push   %ebp
80101131:	89 e5                	mov    %esp,%ebp
80101133:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80101136:	c7 44 24 04 18 6f 10 	movl   $0x80106f18,0x4(%esp)
8010113d:	80 
8010113e:	c7 04 24 e0 ff 10 80 	movl   $0x8010ffe0,(%esp)
80101145:	e8 b6 30 00 00       	call   80104200 <initlock>
}
8010114a:	c9                   	leave  
8010114b:	c3                   	ret    
8010114c:	00 00                	add    %al,(%eax)
	...

80101150 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101150:	55                   	push   %ebp
80101151:	89 e5                	mov    %esp,%ebp
80101153:	8b 55 08             	mov    0x8(%ebp),%edx
80101156:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101159:	8b 0a                	mov    (%edx),%ecx
8010115b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
8010115e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101161:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101164:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101168:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
8010116b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
8010116f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101173:	8b 52 58             	mov    0x58(%edx),%edx
80101176:	89 50 10             	mov    %edx,0x10(%eax)
}
80101179:	5d                   	pop    %ebp
8010117a:	c3                   	ret    
8010117b:	90                   	nop
8010117c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101180 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101180:	55                   	push   %ebp
80101181:	89 e5                	mov    %esp,%ebp
80101183:	53                   	push   %ebx
80101184:	83 ec 14             	sub    $0x14,%esp
80101187:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010118a:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101191:	e8 3a 32 00 00       	call   801043d0 <acquire>
  ip->ref++;
80101196:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
8010119a:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801011a1:	e8 da 31 00 00       	call   80104380 <release>
  return ip;
}
801011a6:	89 d8                	mov    %ebx,%eax
801011a8:	83 c4 14             	add    $0x14,%esp
801011ab:	5b                   	pop    %ebx
801011ac:	5d                   	pop    %ebp
801011ad:	c3                   	ret    
801011ae:	66 90                	xchg   %ax,%ax

801011b0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801011b0:	55                   	push   %ebp
801011b1:	89 e5                	mov    %esp,%ebp
801011b3:	57                   	push   %edi
801011b4:	89 d7                	mov    %edx,%edi
801011b6:	56                   	push   %esi

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
801011b7:	31 f6                	xor    %esi,%esi
{
801011b9:	53                   	push   %ebx
801011ba:	89 c3                	mov    %eax,%ebx
801011bc:	83 ec 2c             	sub    $0x2c,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801011bf:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801011c6:	e8 05 32 00 00       	call   801043d0 <acquire>

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
801011cb:	b8 34 0a 11 80       	mov    $0x80110a34,%eax
801011d0:	eb 16                	jmp    801011e8 <iget+0x38>
801011d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011d8:	85 f6                	test   %esi,%esi
801011da:	74 3c                	je     80101218 <iget+0x68>

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011dc:	05 90 00 00 00       	add    $0x90,%eax
801011e1:	3d 54 26 11 80       	cmp    $0x80112654,%eax
801011e6:	74 48                	je     80101230 <iget+0x80>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011e8:	8b 48 08             	mov    0x8(%eax),%ecx
801011eb:	85 c9                	test   %ecx,%ecx
801011ed:	7e e9                	jle    801011d8 <iget+0x28>
801011ef:	39 18                	cmp    %ebx,(%eax)
801011f1:	75 e5                	jne    801011d8 <iget+0x28>
801011f3:	39 78 04             	cmp    %edi,0x4(%eax)
801011f6:	75 e0                	jne    801011d8 <iget+0x28>
      ip->ref++;
801011f8:	83 c1 01             	add    $0x1,%ecx
801011fb:	89 48 08             	mov    %ecx,0x8(%eax)
      release(&icache.lock);
801011fe:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101208:	e8 73 31 00 00       	call   80104380 <release>
      return ip;
8010120d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);

  return ip;
}
80101210:	83 c4 2c             	add    $0x2c,%esp
80101213:	5b                   	pop    %ebx
80101214:	5e                   	pop    %esi
80101215:	5f                   	pop    %edi
80101216:	5d                   	pop    %ebp
80101217:	c3                   	ret    
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101218:	85 c9                	test   %ecx,%ecx
8010121a:	0f 44 f0             	cmove  %eax,%esi

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010121d:	05 90 00 00 00       	add    $0x90,%eax
80101222:	3d 54 26 11 80       	cmp    $0x80112654,%eax
80101227:	75 bf                	jne    801011e8 <iget+0x38>
80101229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101230:	85 f6                	test   %esi,%esi
80101232:	74 29                	je     8010125d <iget+0xad>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
80101234:	89 1e                	mov    %ebx,(%esi)
  ip->inum = inum;
80101236:	89 7e 04             	mov    %edi,0x4(%esi)
  ip->ref = 1;
80101239:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101240:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80101247:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
8010124e:	e8 2d 31 00 00       	call   80104380 <release>

  return ip;
}
80101253:	83 c4 2c             	add    $0x2c,%esp
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
80101256:	89 f0                	mov    %esi,%eax

  return ip;
}
80101258:	5b                   	pop    %ebx
80101259:	5e                   	pop    %esi
8010125a:	5f                   	pop    %edi
8010125b:	5d                   	pop    %ebp
8010125c:	c3                   	ret    
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
    panic("iget: no inodes");
8010125d:	c7 04 24 1f 6f 10 80 	movl   $0x80106f1f,(%esp)
80101264:	e8 47 f1 ff ff       	call   801003b0 <panic>
80101269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101270 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101270:	55                   	push   %ebp
80101271:	89 e5                	mov    %esp,%ebp
80101273:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80101276:	8b 45 0c             	mov    0xc(%ebp),%eax
80101279:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101280:	00 
80101281:	89 44 24 04          	mov    %eax,0x4(%esp)
80101285:	8b 45 08             	mov    0x8(%ebp),%eax
80101288:	89 04 24             	mov    %eax,(%esp)
8010128b:	e8 e0 32 00 00       	call   80104570 <strncmp>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    
80101292:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801012a0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801012a0:	55                   	push   %ebp
801012a1:	89 e5                	mov    %esp,%ebp
801012a3:	83 ec 28             	sub    $0x28,%esp
801012a6:	89 75 f8             	mov    %esi,-0x8(%ebp)
801012a9:	89 d6                	mov    %edx,%esi
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012ab:	c1 ea 0c             	shr    $0xc,%edx
801012ae:	03 15 f8 09 11 80    	add    0x801109f8,%edx
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801012b4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
801012b7:	89 f3                	mov    %esi,%ebx
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801012b9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
801012bc:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
bfree(int dev, uint b)
{
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
801012c6:	c1 fb 03             	sar    $0x3,%ebx
bfree(int dev, uint b)
{
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012c9:	89 04 24             	mov    %eax,(%esp)
801012cc:	e8 3f ee ff ff       	call   80100110 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801012d1:	89 f1                	mov    %esi,%ecx
801012d3:	be 01 00 00 00       	mov    $0x1,%esi
801012d8:	83 e1 07             	and    $0x7,%ecx
801012db:	d3 e6                	shl    %cl,%esi
  if((bp->data[bi/8] & m) == 0)
801012dd:	0f b6 54 18 5c       	movzbl 0x5c(%eax,%ebx,1),%edx
bfree(int dev, uint b)
{
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012e2:	89 c7                	mov    %eax,%edi
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
801012e4:	0f b6 c2             	movzbl %dl,%eax
801012e7:	85 f0                	test   %esi,%eax
801012e9:	74 27                	je     80101312 <bfree+0x72>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
801012eb:	89 f0                	mov    %esi,%eax
801012ed:	f7 d0                	not    %eax
801012ef:	21 d0                	and    %edx,%eax
801012f1:	88 44 1f 5c          	mov    %al,0x5c(%edi,%ebx,1)
  log_write(bp);
801012f5:	89 3c 24             	mov    %edi,(%esp)
801012f8:	e8 d3 17 00 00       	call   80102ad0 <log_write>
  brelse(bp);
801012fd:	89 3c 24             	mov    %edi,(%esp)
80101300:	e8 3b ed ff ff       	call   80100040 <brelse>
}
80101305:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101308:	8b 75 f8             	mov    -0x8(%ebp),%esi
8010130b:	8b 7d fc             	mov    -0x4(%ebp),%edi
8010130e:	89 ec                	mov    %ebp,%esp
80101310:	5d                   	pop    %ebp
80101311:	c3                   	ret    

  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
80101312:	c7 04 24 2f 6f 10 80 	movl   $0x80106f2f,(%esp)
80101319:	e8 92 f0 ff ff       	call   801003b0 <panic>
8010131e:	66 90                	xchg   %ax,%ax

80101320 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101320:	55                   	push   %ebp
80101321:	89 e5                	mov    %esp,%ebp
80101323:	56                   	push   %esi
80101324:	53                   	push   %ebx
80101325:	83 ec 10             	sub    $0x10,%esp
80101328:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010132b:	8b 43 04             	mov    0x4(%ebx),%eax
8010132e:	c1 e8 03             	shr    $0x3,%eax
80101331:	03 05 f4 09 11 80    	add    0x801109f4,%eax
80101337:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133b:	8b 03                	mov    (%ebx),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 cb ed ff ff       	call   80100110 <bread>
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
80101345:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101349:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010134b:	8b 43 04             	mov    0x4(%ebx),%eax
8010134e:	83 e0 07             	and    $0x7,%eax
80101351:	c1 e0 06             	shl    $0x6,%eax
80101354:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101358:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010135b:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
8010135f:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101363:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
80101367:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010136b:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
8010136f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101373:	8b 53 58             	mov    0x58(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101376:	83 c3 5c             	add    $0x5c,%ebx
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
80101379:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010137c:	83 c0 0c             	add    $0xc,%eax
8010137f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101383:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010138a:	00 
8010138b:	89 04 24             	mov    %eax,(%esp)
8010138e:	e8 6d 31 00 00       	call   80104500 <memmove>
  log_write(bp);
80101393:	89 34 24             	mov    %esi,(%esp)
80101396:	e8 35 17 00 00       	call   80102ad0 <log_write>
  brelse(bp);
8010139b:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010139e:	83 c4 10             	add    $0x10,%esp
801013a1:	5b                   	pop    %ebx
801013a2:	5e                   	pop    %esi
801013a3:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  log_write(bp);
  brelse(bp);
801013a4:	e9 97 ec ff ff       	jmp    80100040 <brelse>
801013a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801013b0 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b0:	55                   	push   %ebp
801013b1:	89 e5                	mov    %esp,%ebp
801013b3:	83 ec 18             	sub    $0x18,%esp
801013b6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
801013b9:	89 75 fc             	mov    %esi,-0x4(%ebp)
801013bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct buf *bp;

  bp = bread(dev, 1);
801013bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801013c6:	00 
801013c7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ca:	89 04 24             	mov    %eax,(%esp)
801013cd:	e8 3e ed ff ff       	call   80100110 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801013d2:	89 34 24             	mov    %esi,(%esp)
801013d5:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801013dc:	00 
void
readsb(int dev, struct superblock *sb)
{
  struct buf *bp;

  bp = bread(dev, 1);
801013dd:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801013df:	83 c0 5c             	add    $0x5c,%eax
801013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801013e6:	e8 15 31 00 00       	call   80104500 <memmove>
  brelse(bp);
}
801013eb:	8b 75 fc             	mov    -0x4(%ebp),%esi
{
  struct buf *bp;

  bp = bread(dev, 1);
  memmove(sb, bp->data, sizeof(*sb));
  brelse(bp);
801013ee:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801013f1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
801013f4:	89 ec                	mov    %ebp,%esp
801013f6:	5d                   	pop    %ebp
{
  struct buf *bp;

  bp = bread(dev, 1);
  memmove(sb, bp->data, sizeof(*sb));
  brelse(bp);
801013f7:	e9 44 ec ff ff       	jmp    80100040 <brelse>
801013fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101400 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101400:	55                   	push   %ebp
80101401:	89 e5                	mov    %esp,%ebp
80101403:	57                   	push   %edi
80101404:	56                   	push   %esi
80101405:	53                   	push   %ebx
80101406:	83 ec 3c             	sub    $0x3c,%esp
80101409:	89 45 d8             	mov    %eax,-0x28(%ebp)
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010140c:	a1 e0 09 11 80       	mov    0x801109e0,%eax
80101411:	85 c0                	test   %eax,%eax
80101413:	0f 84 90 00 00 00    	je     801014a9 <balloc+0xa9>
80101419:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101420:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101423:	c1 f8 0c             	sar    $0xc,%eax
80101426:	03 05 f8 09 11 80    	add    0x801109f8,%eax
8010142c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101430:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101433:	89 04 24             	mov    %eax,(%esp)
80101436:	e8 d5 ec ff ff       	call   80100110 <bread>
8010143b:	8b 15 e0 09 11 80    	mov    0x801109e0,%edx
80101441:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80101444:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010144a:	31 c0                	xor    %eax,%eax
8010144c:	eb 35                	jmp    80101483 <balloc+0x83>
8010144e:	66 90                	xchg   %ax,%ax
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
80101450:	89 c1                	mov    %eax,%ecx
80101452:	bf 01 00 00 00       	mov    $0x1,%edi
80101457:	83 e1 07             	and    $0x7,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010145a:	89 c2                	mov    %eax,%edx

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
8010145c:	d3 e7                	shl    %cl,%edi
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010145e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101461:	c1 fa 03             	sar    $0x3,%edx

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
80101464:	89 7d d4             	mov    %edi,-0x2c(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101467:	0f b6 74 11 5c       	movzbl 0x5c(%ecx,%edx,1),%esi
8010146c:	89 f1                	mov    %esi,%ecx
8010146e:	0f b6 f9             	movzbl %cl,%edi
80101471:	85 7d d4             	test   %edi,-0x2c(%ebp)
80101474:	74 42                	je     801014b8 <balloc+0xb8>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101476:	83 c0 01             	add    $0x1,%eax
80101479:	83 c3 01             	add    $0x1,%ebx
8010147c:	3d 00 10 00 00       	cmp    $0x1000,%eax
80101481:	74 05                	je     80101488 <balloc+0x88>
80101483:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
80101486:	72 c8                	jb     80101450 <balloc+0x50>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101488:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010148b:	89 14 24             	mov    %edx,(%esp)
8010148e:	e8 ad eb ff ff       	call   80100040 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101493:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
8010149a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
8010149d:	39 0d e0 09 11 80    	cmp    %ecx,0x801109e0
801014a3:	0f 87 77 ff ff ff    	ja     80101420 <balloc+0x20>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014a9:	c7 04 24 42 6f 10 80 	movl   $0x80106f42,(%esp)
801014b0:	e8 fb ee ff ff       	call   801003b0 <panic>
801014b5:	8d 76 00             	lea    0x0(%esi),%esi
801014b8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use.
801014bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801014be:	09 f1                	or     %esi,%ecx
801014c0:	88 4c 17 5c          	mov    %cl,0x5c(%edi,%edx,1)
        log_write(bp);
801014c4:	89 3c 24             	mov    %edi,(%esp)
801014c7:	e8 04 16 00 00       	call   80102ad0 <log_write>
        brelse(bp);
801014cc:	89 3c 24             	mov    %edi,(%esp)
801014cf:	e8 6c eb ff ff       	call   80100040 <brelse>
static void
bzero(int dev, int bno)
{
  struct buf *bp;

  bp = bread(dev, bno);
801014d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801014db:	89 04 24             	mov    %eax,(%esp)
801014de:	e8 2d ec ff ff       	call   80100110 <bread>
  memset(bp->data, 0, BSIZE);
801014e3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801014ea:	00 
801014eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801014f2:	00 
static void
bzero(int dev, int bno)
{
  struct buf *bp;

  bp = bread(dev, bno);
801014f3:	89 c6                	mov    %eax,%esi
  memset(bp->data, 0, BSIZE);
801014f5:	83 c0 5c             	add    $0x5c,%eax
801014f8:	89 04 24             	mov    %eax,(%esp)
801014fb:	e8 40 2f 00 00       	call   80104440 <memset>
  log_write(bp);
80101500:	89 34 24             	mov    %esi,(%esp)
80101503:	e8 c8 15 00 00       	call   80102ad0 <log_write>
  brelse(bp);
80101508:	89 34 24             	mov    %esi,(%esp)
8010150b:	e8 30 eb ff ff       	call   80100040 <brelse>
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101510:	83 c4 3c             	add    $0x3c,%esp
80101513:	89 d8                	mov    %ebx,%eax
80101515:	5b                   	pop    %ebx
80101516:	5e                   	pop    %esi
80101517:	5f                   	pop    %edi
80101518:	5d                   	pop    %ebp
80101519:	c3                   	ret    
8010151a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101520 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101520:	55                   	push   %ebp
80101521:	89 e5                	mov    %esp,%ebp
80101523:	83 ec 38             	sub    $0x38,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101526:	83 fa 0a             	cmp    $0xa,%edx

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101529:	89 5d f4             	mov    %ebx,-0xc(%ebp)
8010152c:	89 c3                	mov    %eax,%ebx
8010152e:	89 75 f8             	mov    %esi,-0x8(%ebp)
80101531:	89 7d fc             	mov    %edi,-0x4(%ebp)
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101534:	77 22                	ja     80101558 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0)
80101536:	8d 72 14             	lea    0x14(%edx),%esi
80101539:	8b 44 b0 0c          	mov    0xc(%eax,%esi,4),%eax
8010153d:	85 c0                	test   %eax,%eax
8010153f:	0f 84 f3 00 00 00    	je     80101638 <bmap+0x118>
	  return addr;
  }
 

  panic("bmap: out of range");
}
80101545:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101548:	8b 75 f8             	mov    -0x8(%ebp),%esi
8010154b:	8b 7d fc             	mov    -0x4(%ebp),%edi
8010154e:	89 ec                	mov    %ebp,%esp
80101550:	5d                   	pop    %ebp
80101551:	c3                   	ret    
80101552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }

  bn -= NDIRECT;
80101558:	8d 72 f5             	lea    -0xb(%edx),%esi

  if(bn < NINDIRECT){
8010155b:	83 fe 7f             	cmp    $0x7f,%esi
8010155e:	0f 86 84 00 00 00    	jbe    801015e8 <bmap+0xc8>
    return addr;
  }

  /* Added code */
  
  bn -= NINDIRECT;
80101564:	8d b2 75 ff ff ff    	lea    -0x8b(%edx),%esi
  
  if(bn < NINDIRECT*NINDIRECT){
8010156a:	81 fe ff 3f 00 00    	cmp    $0x3fff,%esi
80101570:	0f 87 1c 01 00 00    	ja     80101692 <bmap+0x172>
	  // Load first indirect block, allocating if necessary.
	  if((addr = ip->addrs[NDIRECT+1]) == 0)
80101576:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010157c:	85 c0                	test   %eax,%eax
8010157e:	0f 84 fc 00 00 00    	je     80101680 <bmap+0x160>
		  ip->addrs[NDIRECT+1] = addr = balloc(ip->dev);
	  bp = bread(ip->dev, addr);
80101584:	89 44 24 04          	mov    %eax,0x4(%esp)
80101588:	8b 03                	mov    (%ebx),%eax
8010158a:	89 04 24             	mov    %eax,(%esp)
8010158d:	e8 7e eb ff ff       	call   80100110 <bread>
80101592:	89 c7                	mov    %eax,%edi
	  a = (uint*)bp->data;

	  // Allocate second indirect block, if necessary.
	  if((addr = a[bn/NINDIRECT]) == 0){
80101594:	89 f0                	mov    %esi,%eax
80101596:	c1 e8 07             	shr    $0x7,%eax
80101599:	8d 54 87 5c          	lea    0x5c(%edi,%eax,4),%edx
8010159d:	8b 02                	mov    (%edx),%eax
8010159f:	85 c0                	test   %eax,%eax
801015a1:	0f 84 b1 00 00 00    	je     80101658 <bmap+0x138>
	  	a[bn/NINDIRECT] = addr = balloc(ip->dev); //disk numb of second indirect block
		log_write(bp);
	  }
	  brelse(bp);
801015a7:	89 3c 24             	mov    %edi,(%esp)

	  // Load second indirect block
	  bp = bread(ip->dev, addr);
	  a = (uint*)bp->data;	//a is second indirect block
	  if((addr = a[bn % NINDIRECT]) == 0){
801015aa:	83 e6 7f             	and    $0x7f,%esi
	  // Allocate second indirect block, if necessary.
	  if((addr = a[bn/NINDIRECT]) == 0){
	  	a[bn/NINDIRECT] = addr = balloc(ip->dev); //disk numb of second indirect block
		log_write(bp);
	  }
	  brelse(bp);
801015ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801015b0:	e8 8b ea ff ff       	call   80100040 <brelse>

	  // Load second indirect block
	  bp = bread(ip->dev, addr);
801015b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801015bc:	8b 03                	mov    (%ebx),%eax
801015be:	89 04 24             	mov    %eax,(%esp)
801015c1:	e8 4a eb ff ff       	call   80100110 <bread>
	  a = (uint*)bp->data;	//a is second indirect block
	  if((addr = a[bn % NINDIRECT]) == 0){
801015c6:	8d 74 b0 5c          	lea    0x5c(%eax,%esi,4),%esi
		log_write(bp);
	  }
	  brelse(bp);

	  // Load second indirect block
	  bp = bread(ip->dev, addr);
801015ca:	89 c7                	mov    %eax,%edi
	  a = (uint*)bp->data;	//a is second indirect block
	  if((addr = a[bn % NINDIRECT]) == 0){
801015cc:	8b 06                	mov    (%esi),%eax
801015ce:	85 c0                	test   %eax,%eax
801015d0:	74 3a                	je     8010160c <bmap+0xec>
		  a[bn % NINDIRECT] = addr = balloc(ip->dev);
		  log_write(bp);
	  }
	  brelse(bp);
801015d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801015d5:	89 3c 24             	mov    %edi,(%esp)
801015d8:	e8 63 ea ff ff       	call   80100040 <brelse>
	  return addr;
801015dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801015e0:	e9 60 ff ff ff       	jmp    80101545 <bmap+0x25>
801015e5:	8d 76 00             	lea    0x0(%esi),%esi

  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
801015e8:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801015ee:	85 c0                	test   %eax,%eax
801015f0:	74 56                	je     80101648 <bmap+0x128>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
801015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801015f6:	8b 03                	mov    (%ebx),%eax
801015f8:	89 04 24             	mov    %eax,(%esp)
801015fb:	e8 10 eb ff ff       	call   80100110 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101600:	8d 74 b0 5c          	lea    0x5c(%eax,%esi,4),%esi

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
80101604:	89 c7                	mov    %eax,%edi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101606:	8b 06                	mov    (%esi),%eax
80101608:	85 c0                	test   %eax,%eax
8010160a:	75 c6                	jne    801015d2 <bmap+0xb2>

	  // Load second indirect block
	  bp = bread(ip->dev, addr);
	  a = (uint*)bp->data;	//a is second indirect block
	  if((addr = a[bn % NINDIRECT]) == 0){
		  a[bn % NINDIRECT] = addr = balloc(ip->dev);
8010160c:	8b 03                	mov    (%ebx),%eax
8010160e:	e8 ed fd ff ff       	call   80101400 <balloc>
80101613:	89 06                	mov    %eax,(%esi)
		  log_write(bp);
80101615:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101618:	89 3c 24             	mov    %edi,(%esp)
8010161b:	e8 b0 14 00 00       	call   80102ad0 <log_write>
80101620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	  }
	  brelse(bp);
80101623:	89 3c 24             	mov    %edi,(%esp)
80101626:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101629:	e8 12 ea ff ff       	call   80100040 <brelse>
	  return addr;
8010162e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101631:	e9 0f ff ff ff       	jmp    80101545 <bmap+0x25>
80101636:	66 90                	xchg   %ax,%ax
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
80101638:	8b 03                	mov    (%ebx),%eax
8010163a:	e8 c1 fd ff ff       	call   80101400 <balloc>
8010163f:	89 44 b3 0c          	mov    %eax,0xc(%ebx,%esi,4)
80101643:	e9 fd fe ff ff       	jmp    80101545 <bmap+0x25>
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101648:	8b 03                	mov    (%ebx),%eax
8010164a:	e8 b1 fd ff ff       	call   80101400 <balloc>
8010164f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
80101655:	eb 9b                	jmp    801015f2 <bmap+0xd2>
80101657:	90                   	nop
	  bp = bread(ip->dev, addr);
	  a = (uint*)bp->data;

	  // Allocate second indirect block, if necessary.
	  if((addr = a[bn/NINDIRECT]) == 0){
	  	a[bn/NINDIRECT] = addr = balloc(ip->dev); //disk numb of second indirect block
80101658:	8b 03                	mov    (%ebx),%eax
8010165a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010165d:	e8 9e fd ff ff       	call   80101400 <balloc>
80101662:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101665:	89 02                	mov    %eax,(%edx)
		log_write(bp);
80101667:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010166a:	89 3c 24             	mov    %edi,(%esp)
8010166d:	e8 5e 14 00 00       	call   80102ad0 <log_write>
80101672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101675:	e9 2d ff ff ff       	jmp    801015a7 <bmap+0x87>
8010167a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  bn -= NINDIRECT;
  
  if(bn < NINDIRECT*NINDIRECT){
	  // Load first indirect block, allocating if necessary.
	  if((addr = ip->addrs[NDIRECT+1]) == 0)
		  ip->addrs[NDIRECT+1] = addr = balloc(ip->dev);
80101680:	8b 03                	mov    (%ebx),%eax
80101682:	e8 79 fd ff ff       	call   80101400 <balloc>
80101687:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
8010168d:	e9 f2 fe ff ff       	jmp    80101584 <bmap+0x64>
	  brelse(bp);
	  return addr;
  }
 

  panic("bmap: out of range");
80101692:	c7 04 24 58 6f 10 80 	movl   $0x80106f58,(%esp)
80101699:	e8 12 ed ff ff       	call   801003b0 <panic>
8010169e:	66 90                	xchg   %ax,%ax

801016a0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801016a0:	55                   	push   %ebp
801016a1:	89 e5                	mov    %esp,%ebp
801016a3:	83 ec 38             	sub    $0x38,%esp
801016a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
801016a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801016ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
801016af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801016b2:	89 7d fc             	mov    %edi,-0x4(%ebp)
801016b5:	8b 75 10             	mov    0x10(%ebp),%esi
801016b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801016bb:	66 83 7b 50 03       	cmpw   $0x3,0x50(%ebx)
801016c0:	74 1e                	je     801016e0 <writei+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
801016c2:	39 73 58             	cmp    %esi,0x58(%ebx)
801016c5:	73 41                	jae    80101708 <writei+0x68>

  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
801016c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801016cc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801016cf:	8b 75 f8             	mov    -0x8(%ebp),%esi
801016d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
801016d5:	89 ec                	mov    %ebp,%esp
801016d7:	5d                   	pop    %ebp
801016d8:	c3                   	ret    
801016d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801016e0:	0f b7 43 52          	movzwl 0x52(%ebx),%eax
801016e4:	66 83 f8 09          	cmp    $0x9,%ax
801016e8:	77 dd                	ja     801016c7 <writei+0x27>
801016ea:	98                   	cwtl   
801016eb:	8b 04 c5 84 09 11 80 	mov    -0x7feef67c(,%eax,8),%eax
801016f2:	85 c0                	test   %eax,%eax
801016f4:	74 d1                	je     801016c7 <writei+0x27>
      return -1;
    return devsw[ip->major].write(ip, src, n);
801016f6:	89 7d 10             	mov    %edi,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
801016f9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801016fc:	8b 75 f8             	mov    -0x8(%ebp),%esi
801016ff:	8b 7d fc             	mov    -0x4(%ebp),%edi
80101702:	89 ec                	mov    %ebp,%esp
80101704:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
80101705:	ff e0                	jmp    *%eax
80101707:	90                   	nop
  }

  if(off > ip->size || off + n < off)
80101708:	89 f8                	mov    %edi,%eax
8010170a:	01 f0                	add    %esi,%eax
8010170c:	72 b9                	jb     801016c7 <writei+0x27>
    return -1;
  if(off + n > MAXFILE*BSIZE)
8010170e:	3d 00 16 81 00       	cmp    $0x811600,%eax
80101713:	77 b2                	ja     801016c7 <writei+0x27>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101715:	85 ff                	test   %edi,%edi
80101717:	0f 84 8a 00 00 00    	je     801017a7 <writei+0x107>
8010171d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101724:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101727:	89 7d dc             	mov    %edi,-0x24(%ebp)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010172a:	89 f2                	mov    %esi,%edx
8010172c:	89 d8                	mov    %ebx,%eax
8010172e:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101731:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101736:	e8 e5 fd ff ff       	call   80101520 <bmap>
8010173b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010173f:	8b 03                	mov    (%ebx),%eax
80101741:	89 04 24             	mov    %eax,(%esp)
80101744:	e8 c7 e9 ff ff       	call   80100110 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101749:	8b 4d dc             	mov    -0x24(%ebp),%ecx
8010174c:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010174f:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101751:	89 f0                	mov    %esi,%eax
80101753:	25 ff 01 00 00       	and    $0x1ff,%eax
80101758:	29 c7                	sub    %eax,%edi
8010175a:	39 cf                	cmp    %ecx,%edi
8010175c:	0f 47 f9             	cmova  %ecx,%edi
    memmove(bp->data + off%BSIZE, src, m);
8010175f:	89 7c 24 08          	mov    %edi,0x8(%esp)
80101763:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101766:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
8010176a:	89 04 24             	mov    %eax,(%esp)
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010176d:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
8010176f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80101773:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101776:	e8 85 2d 00 00       	call   80104500 <memmove>
    log_write(bp);
8010177b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010177e:	89 14 24             	mov    %edx,(%esp)
80101781:	e8 4a 13 00 00       	call   80102ad0 <log_write>
    brelse(bp);
80101786:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101789:	89 14 24             	mov    %edx,(%esp)
8010178c:	e8 af e8 ff ff       	call   80100040 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101791:	01 7d e4             	add    %edi,-0x1c(%ebp)
80101794:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101797:	01 7d e0             	add    %edi,-0x20(%ebp)
8010179a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
8010179d:	77 8b                	ja     8010172a <writei+0x8a>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010179f:	3b 73 58             	cmp    0x58(%ebx),%esi
801017a2:	8b 7d dc             	mov    -0x24(%ebp),%edi
801017a5:	77 07                	ja     801017ae <writei+0x10e>
    ip->size = off;
    iupdate(ip);
  }
  return n;
801017a7:	89 f8                	mov    %edi,%eax
801017a9:	e9 1e ff ff ff       	jmp    801016cc <writei+0x2c>
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
801017ae:	89 73 58             	mov    %esi,0x58(%ebx)
    iupdate(ip);
801017b1:	89 1c 24             	mov    %ebx,(%esp)
801017b4:	e8 67 fb ff ff       	call   80101320 <iupdate>
  }
  return n;
801017b9:	89 f8                	mov    %edi,%eax
801017bb:	e9 0c ff ff ff       	jmp    801016cc <writei+0x2c>

801017c0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801017c0:	55                   	push   %ebp
801017c1:	89 e5                	mov    %esp,%ebp
801017c3:	83 ec 38             	sub    $0x38,%esp
801017c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
801017c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801017cc:	89 75 f8             	mov    %esi,-0x8(%ebp)
801017cf:	8b 4d 14             	mov    0x14(%ebp),%ecx
801017d2:	89 7d fc             	mov    %edi,-0x4(%ebp)
801017d5:	8b 75 10             	mov    0x10(%ebp),%esi
801017d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801017db:	66 83 7b 50 03       	cmpw   $0x3,0x50(%ebx)
801017e0:	74 1e                	je     80101800 <readi+0x40>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
801017e2:	8b 43 58             	mov    0x58(%ebx),%eax
801017e5:	39 f0                	cmp    %esi,%eax
801017e7:	73 3f                	jae    80101828 <readi+0x68>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801017e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801017ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801017f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
801017f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
801017f7:	89 ec                	mov    %ebp,%esp
801017f9:	5d                   	pop    %ebp
801017fa:	c3                   	ret    
801017fb:	90                   	nop
801017fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101800:	0f b7 43 52          	movzwl 0x52(%ebx),%eax
80101804:	66 83 f8 09          	cmp    $0x9,%ax
80101808:	77 df                	ja     801017e9 <readi+0x29>
8010180a:	98                   	cwtl   
8010180b:	8b 04 c5 80 09 11 80 	mov    -0x7feef680(,%eax,8),%eax
80101812:	85 c0                	test   %eax,%eax
80101814:	74 d3                	je     801017e9 <readi+0x29>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
80101816:	89 4d 10             	mov    %ecx,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
80101819:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010181c:	8b 75 f8             	mov    -0x8(%ebp),%esi
8010181f:	8b 7d fc             	mov    -0x4(%ebp),%edi
80101822:	89 ec                	mov    %ebp,%esp
80101824:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
80101825:	ff e0                	jmp    *%eax
80101827:	90                   	nop
  }

  if(off > ip->size || off + n < off)
80101828:	89 ca                	mov    %ecx,%edx
8010182a:	01 f2                	add    %esi,%edx
8010182c:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010182f:	72 b8                	jb     801017e9 <readi+0x29>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101831:	89 c2                	mov    %eax,%edx
80101833:	29 f2                	sub    %esi,%edx
80101835:	3b 45 e0             	cmp    -0x20(%ebp),%eax
80101838:	0f 42 ca             	cmovb  %edx,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010183b:	85 c9                	test   %ecx,%ecx
8010183d:	74 7e                	je     801018bd <readi+0xfd>
8010183f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101846:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101849:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010184c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101850:	89 f2                	mov    %esi,%edx
80101852:	89 d8                	mov    %ebx,%eax
80101854:	c1 ea 09             	shr    $0x9,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101857:	bf 00 02 00 00       	mov    $0x200,%edi
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010185c:	e8 bf fc ff ff       	call   80101520 <bmap>
80101861:	89 44 24 04          	mov    %eax,0x4(%esp)
80101865:	8b 03                	mov    (%ebx),%eax
80101867:	89 04 24             	mov    %eax,(%esp)
8010186a:	e8 a1 e8 ff ff       	call   80100110 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
8010186f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80101872:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101875:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101877:	89 f0                	mov    %esi,%eax
80101879:	25 ff 01 00 00       	and    $0x1ff,%eax
8010187e:	29 c7                	sub    %eax,%edi
80101880:	39 cf                	cmp    %ecx,%edi
80101882:	0f 47 f9             	cmova  %ecx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
80101885:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101889:	01 fe                	add    %edi,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
8010188b:	89 7c 24 08          	mov    %edi,0x8(%esp)
8010188f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101893:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101896:	89 04 24             	mov    %eax,(%esp)
80101899:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010189c:	e8 5f 2c 00 00       	call   80104500 <memmove>
    brelse(bp);
801018a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
801018a4:	89 14 24             	mov    %edx,(%esp)
801018a7:	e8 94 e7 ff ff       	call   80100040 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801018ac:	01 7d e4             	add    %edi,-0x1c(%ebp)
801018af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801018b2:	01 7d e0             	add    %edi,-0x20(%ebp)
801018b5:	39 55 dc             	cmp    %edx,-0x24(%ebp)
801018b8:	77 96                	ja     80101850 <readi+0x90>
801018ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801018bd:	89 c8                	mov    %ecx,%eax
801018bf:	e9 2a ff ff ff       	jmp    801017ee <readi+0x2e>
801018c4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801018ca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801018d0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801018d0:	55                   	push   %ebp
801018d1:	89 e5                	mov    %esp,%ebp
801018d3:	57                   	push   %edi
801018d4:	56                   	push   %esi
801018d5:	53                   	push   %ebx
801018d6:	83 ec 2c             	sub    $0x2c,%esp
801018d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801018dc:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801018e1:	0f 85 8c 00 00 00    	jne    80101973 <dirlookup+0xa3>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801018e7:	8b 4b 58             	mov    0x58(%ebx),%ecx
801018ea:	85 c9                	test   %ecx,%ecx
801018ec:	74 4c                	je     8010193a <dirlookup+0x6a>
{
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
801018ee:	8d 7d d8             	lea    -0x28(%ebp),%edi
801018f1:	31 f6                	xor    %esi,%esi
801018f3:	90                   	nop
801018f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801018f8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801018ff:	00 
80101900:	89 74 24 08          	mov    %esi,0x8(%esp)
80101904:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101908:	89 1c 24             	mov    %ebx,(%esp)
8010190b:	e8 b0 fe ff ff       	call   801017c0 <readi>
80101910:	83 f8 10             	cmp    $0x10,%eax
80101913:	75 52                	jne    80101967 <dirlookup+0x97>
      panic("dirlookup read");
    if(de.inum == 0)
80101915:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010191a:	74 16                	je     80101932 <dirlookup+0x62>
      continue;
    if(namecmp(name, de.name) == 0){
8010191c:	8d 45 da             	lea    -0x26(%ebp),%eax
8010191f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101923:	8b 45 0c             	mov    0xc(%ebp),%eax
80101926:	89 04 24             	mov    %eax,(%esp)
80101929:	e8 42 f9 ff ff       	call   80101270 <namecmp>
8010192e:	85 c0                	test   %eax,%eax
80101930:	74 16                	je     80101948 <dirlookup+0x78>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101932:	83 c6 10             	add    $0x10,%esi
80101935:	39 73 58             	cmp    %esi,0x58(%ebx)
80101938:	77 be                	ja     801018f8 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
8010193a:	83 c4 2c             	add    $0x2c,%esp
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010193d:	31 c0                	xor    %eax,%eax
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
8010193f:	5b                   	pop    %ebx
80101940:	5e                   	pop    %esi
80101941:	5f                   	pop    %edi
80101942:	5d                   	pop    %ebp
80101943:	c3                   	ret    
80101944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
      // entry matches path element
      if(poff)
80101948:	8b 55 10             	mov    0x10(%ebp),%edx
8010194b:	85 d2                	test   %edx,%edx
8010194d:	74 05                	je     80101954 <dirlookup+0x84>
        *poff = off;
8010194f:	8b 45 10             	mov    0x10(%ebp),%eax
80101952:	89 30                	mov    %esi,(%eax)
      inum = de.inum;
      return iget(dp->dev, inum);
80101954:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
80101958:	8b 03                	mov    (%ebx),%eax
8010195a:	e8 51 f8 ff ff       	call   801011b0 <iget>
    }
  }

  return 0;
}
8010195f:	83 c4 2c             	add    $0x2c,%esp
80101962:	5b                   	pop    %ebx
80101963:	5e                   	pop    %esi
80101964:	5f                   	pop    %edi
80101965:	5d                   	pop    %ebp
80101966:	c3                   	ret    
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
80101967:	c7 04 24 7d 6f 10 80 	movl   $0x80106f7d,(%esp)
8010196e:	e8 3d ea ff ff       	call   801003b0 <panic>
{
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
80101973:	c7 04 24 6b 6f 10 80 	movl   $0x80106f6b,(%esp)
8010197a:	e8 31 ea ff ff       	call   801003b0 <panic>
8010197f:	90                   	nop

80101980 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101980:	55                   	push   %ebp
80101981:	89 e5                	mov    %esp,%ebp
80101983:	57                   	push   %edi
80101984:	56                   	push   %esi
80101985:	53                   	push   %ebx
80101986:	83 ec 2c             	sub    $0x2c,%esp
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010198c:	83 3d e8 09 11 80 01 	cmpl   $0x1,0x801109e8
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101993:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101996:	0f b7 45 0c          	movzwl 0xc(%ebp),%eax
8010199a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010199e:	0f 86 95 00 00 00    	jbe    80101a39 <ialloc+0xb9>
801019a4:	be 01 00 00 00       	mov    $0x1,%esi
801019a9:	bb 01 00 00 00       	mov    $0x1,%ebx
801019ae:	eb 15                	jmp    801019c5 <ialloc+0x45>
801019b0:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019b3:	89 3c 24             	mov    %edi,(%esp)
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801019b6:	89 de                	mov    %ebx,%esi
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019b8:	e8 83 e6 ff ff       	call   80100040 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801019bd:	39 1d e8 09 11 80    	cmp    %ebx,0x801109e8
801019c3:	76 74                	jbe    80101a39 <ialloc+0xb9>
    bp = bread(dev, IBLOCK(inum, sb));
801019c5:	89 f0                	mov    %esi,%eax
801019c7:	c1 e8 03             	shr    $0x3,%eax
801019ca:	03 05 f4 09 11 80    	add    0x801109f4,%eax
801019d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801019d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801019d7:	89 04 24             	mov    %eax,(%esp)
801019da:	e8 31 e7 ff ff       	call   80100110 <bread>
801019df:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
801019e1:	89 f0                	mov    %esi,%eax
801019e3:	83 e0 07             	and    $0x7,%eax
801019e6:	c1 e0 06             	shl    $0x6,%eax
801019e9:	8d 54 07 5c          	lea    0x5c(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
801019ed:	66 83 3a 00          	cmpw   $0x0,(%edx)
801019f1:	75 bd                	jne    801019b0 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801019f3:	89 14 24             	mov    %edx,(%esp)
801019f6:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801019fd:	00 
801019fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101a05:	00 
80101a06:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101a09:	e8 32 2a 00 00       	call   80104440 <memset>
      dip->type = type;
80101a0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101a11:	0f b7 45 e2          	movzwl -0x1e(%ebp),%eax
80101a15:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101a18:	89 3c 24             	mov    %edi,(%esp)
80101a1b:	e8 b0 10 00 00       	call   80102ad0 <log_write>
      brelse(bp);
80101a20:	89 3c 24             	mov    %edi,(%esp)
80101a23:	e8 18 e6 ff ff       	call   80100040 <brelse>
      return iget(dev, inum);
80101a28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a2b:	89 f2                	mov    %esi,%edx
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101a2d:	83 c4 2c             	add    $0x2c,%esp
80101a30:	5b                   	pop    %ebx
80101a31:	5e                   	pop    %esi
80101a32:	5f                   	pop    %edi
80101a33:	5d                   	pop    %ebp
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
80101a34:	e9 77 f7 ff ff       	jmp    801011b0 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101a39:	c7 04 24 8c 6f 10 80 	movl   $0x80106f8c,(%esp)
80101a40:	e8 6b e9 ff ff       	call   801003b0 <panic>
80101a45:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101a49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101a50 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a50:	55                   	push   %ebp
80101a51:	89 e5                	mov    %esp,%ebp
80101a53:	56                   	push   %esi
80101a54:	53                   	push   %ebx
80101a55:	83 ec 10             	sub    $0x10,%esp
80101a58:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a5b:	85 db                	test   %ebx,%ebx
80101a5d:	0f 84 b3 00 00 00    	je     80101b16 <ilock+0xc6>
80101a63:	8b 43 08             	mov    0x8(%ebx),%eax
80101a66:	85 c0                	test   %eax,%eax
80101a68:	0f 8e a8 00 00 00    	jle    80101b16 <ilock+0xc6>
    panic("ilock");

  acquiresleep(&ip->lock);
80101a6e:	8d 43 0c             	lea    0xc(%ebx),%eax
80101a71:	89 04 24             	mov    %eax,(%esp)
80101a74:	e8 e7 26 00 00       	call   80104160 <acquiresleep>

  if(ip->valid == 0){
80101a79:	8b 73 4c             	mov    0x4c(%ebx),%esi
80101a7c:	85 f6                	test   %esi,%esi
80101a7e:	74 08                	je     80101a88 <ilock+0x38>
    brelse(bp);
    ip->valid = 1;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
80101a80:	83 c4 10             	add    $0x10,%esp
80101a83:	5b                   	pop    %ebx
80101a84:	5e                   	pop    %esi
80101a85:	5d                   	pop    %ebp
80101a86:	c3                   	ret    
80101a87:	90                   	nop
    panic("ilock");

  acquiresleep(&ip->lock);

  if(ip->valid == 0){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a88:	8b 43 04             	mov    0x4(%ebx),%eax
80101a8b:	c1 e8 03             	shr    $0x3,%eax
80101a8e:	03 05 f4 09 11 80    	add    0x801109f4,%eax
80101a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a98:	8b 03                	mov    (%ebx),%eax
80101a9a:	89 04 24             	mov    %eax,(%esp)
80101a9d:	e8 6e e6 ff ff       	call   80100110 <bread>
80101aa2:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aa4:	8b 43 04             	mov    0x4(%ebx),%eax
80101aa7:	83 e0 07             	and    $0x7,%eax
80101aaa:	c1 e0 06             	shl    $0x6,%eax
80101aad:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101ab1:	0f b7 10             	movzwl (%eax),%edx
80101ab4:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101ab8:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101abc:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101ac0:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101ac4:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101ac8:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101acc:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101ad0:	8b 50 08             	mov    0x8(%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ad3:	83 c0 0c             	add    $0xc,%eax
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
80101ad6:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
80101add:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101ae0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101ae7:	00 
80101ae8:	89 04 24             	mov    %eax,(%esp)
80101aeb:	e8 10 2a 00 00       	call   80104500 <memmove>
    brelse(bp);
80101af0:	89 34 24             	mov    %esi,(%esp)
80101af3:	e8 48 e5 ff ff       	call   80100040 <brelse>
    ip->valid = 1;
    if(ip->type == 0)
80101af8:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    brelse(bp);
    ip->valid = 1;
80101afd:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101b04:	0f 85 76 ff ff ff    	jne    80101a80 <ilock+0x30>
      panic("ilock: no type");
80101b0a:	c7 04 24 a4 6f 10 80 	movl   $0x80106fa4,(%esp)
80101b11:	e8 9a e8 ff ff       	call   801003b0 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
80101b16:	c7 04 24 9e 6f 10 80 	movl   $0x80106f9e,(%esp)
80101b1d:	e8 8e e8 ff ff       	call   801003b0 <panic>
80101b22:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101b30 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	83 ec 38             	sub    $0x38,%esp
80101b36:	89 75 f8             	mov    %esi,-0x8(%ebp)
80101b39:	8b 75 08             	mov    0x8(%ebp),%esi
80101b3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
80101b3f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  acquiresleep(&ip->lock);
80101b42:	8d 7e 0c             	lea    0xc(%esi),%edi
80101b45:	89 3c 24             	mov    %edi,(%esp)
80101b48:	e8 13 26 00 00       	call   80104160 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101b4d:	8b 56 4c             	mov    0x4c(%esi),%edx
80101b50:	85 d2                	test   %edx,%edx
80101b52:	74 07                	je     80101b5b <iput+0x2b>
80101b54:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
80101b59:	74 35                	je     80101b90 <iput+0x60>
      ip->type = 0;
      iupdate(ip);
      ip->valid = 0;
    }
  }
  releasesleep(&ip->lock);
80101b5b:	89 3c 24             	mov    %edi,(%esp)
80101b5e:	e8 bd 25 00 00       	call   80104120 <releasesleep>

  acquire(&icache.lock);
80101b63:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101b6a:	e8 61 28 00 00       	call   801043d0 <acquire>
  ip->ref--;
80101b6f:	83 6e 08 01          	subl   $0x1,0x8(%esi)
  release(&icache.lock);
}
80101b73:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  }
  releasesleep(&ip->lock);

  acquire(&icache.lock);
  ip->ref--;
  release(&icache.lock);
80101b76:	c7 45 08 00 0a 11 80 	movl   $0x80110a00,0x8(%ebp)
}
80101b7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
80101b80:	8b 7d fc             	mov    -0x4(%ebp),%edi
80101b83:	89 ec                	mov    %ebp,%esp
80101b85:	5d                   	pop    %ebp
  }
  releasesleep(&ip->lock);

  acquire(&icache.lock);
  ip->ref--;
  release(&icache.lock);
80101b86:	e9 f5 27 00 00       	jmp    80104380 <release>
80101b8b:	90                   	nop
80101b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
void
iput(struct inode *ip)
{
  acquiresleep(&ip->lock);
  if(ip->valid && ip->nlink == 0){
    acquire(&icache.lock);
80101b90:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101b97:	e8 34 28 00 00       	call   801043d0 <acquire>
    int r = ip->ref;
80101b9c:	8b 5e 08             	mov    0x8(%esi),%ebx
    release(&icache.lock);
80101b9f:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101ba6:	e8 d5 27 00 00       	call   80104380 <release>
    if(r == 1){
80101bab:	83 fb 01             	cmp    $0x1,%ebx
80101bae:	75 ab                	jne    80101b5b <iput+0x2b>
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
80101bb0:	8d 4e 2c             	lea    0x2c(%esi),%ecx
  acquiresleep(&ip->lock);
  if(ip->valid && ip->nlink == 0){
    acquire(&icache.lock);
    int r = ip->ref;
    release(&icache.lock);
    if(r == 1){
80101bb3:	89 f3                	mov    %esi,%ebx
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
80101bb5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101bb8:	89 f7                	mov    %esi,%edi
80101bba:	89 ce                	mov    %ecx,%esi
80101bbc:	eb 09                	jmp    80101bc7 <iput+0x97>
80101bbe:	66 90                	xchg   %ax,%ax
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
80101bc0:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101bc3:	39 f3                	cmp    %esi,%ebx
80101bc5:	74 19                	je     80101be0 <iput+0xb0>
    if(ip->addrs[i]){
80101bc7:	8b 53 5c             	mov    0x5c(%ebx),%edx
80101bca:	85 d2                	test   %edx,%edx
80101bcc:	74 f2                	je     80101bc0 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101bce:	8b 07                	mov    (%edi),%eax
80101bd0:	e8 cb f6 ff ff       	call   801012a0 <bfree>
      ip->addrs[i] = 0;
80101bd5:	c7 43 5c 00 00 00 00 	movl   $0x0,0x5c(%ebx)
80101bdc:	eb e2                	jmp    80101bc0 <iput+0x90>
80101bde:	66 90                	xchg   %ax,%ax
80101be0:	89 fe                	mov    %edi,%esi
80101be2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    }
  }

  if(ip->addrs[NDIRECT]){
80101be5:	8b 86 88 00 00 00    	mov    0x88(%esi),%eax
80101beb:	85 c0                	test   %eax,%eax
80101bed:	75 29                	jne    80101c18 <iput+0xe8>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
80101bef:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
80101bf6:	89 34 24             	mov    %esi,(%esp)
80101bf9:	e8 22 f7 ff ff       	call   80101320 <iupdate>
    int r = ip->ref;
    release(&icache.lock);
    if(r == 1){
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
      ip->type = 0;
80101bfe:	66 c7 46 50 00 00    	movw   $0x0,0x50(%esi)
      iupdate(ip);
80101c04:	89 34 24             	mov    %esi,(%esp)
80101c07:	e8 14 f7 ff ff       	call   80101320 <iupdate>
      ip->valid = 0;
80101c0c:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
80101c13:	e9 43 ff ff ff       	jmp    80101b5b <iput+0x2b>
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c18:	89 44 24 04          	mov    %eax,0x4(%esp)
80101c1c:	8b 06                	mov    (%esi),%eax
    a = (uint*)bp->data;
80101c1e:	31 db                	xor    %ebx,%ebx
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c20:	89 04 24             	mov    %eax,(%esp)
80101c23:	e8 e8 e4 ff ff       	call   80100110 <bread>
    a = (uint*)bp->data;
80101c28:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101c2b:	89 f7                	mov    %esi,%edi
80101c2d:	89 c1                	mov    %eax,%ecx
80101c2f:	83 c1 5c             	add    $0x5c,%ecx
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101c35:	89 ce                	mov    %ecx,%esi
80101c37:	31 c0                	xor    %eax,%eax
80101c39:	eb 12                	jmp    80101c4d <iput+0x11d>
80101c3b:	90                   	nop
80101c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(j = 0; j < NINDIRECT; j++){
80101c40:	83 c3 01             	add    $0x1,%ebx
80101c43:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
80101c49:	89 d8                	mov    %ebx,%eax
80101c4b:	74 10                	je     80101c5d <iput+0x12d>
      if(a[j])
80101c4d:	8b 14 86             	mov    (%esi,%eax,4),%edx
80101c50:	85 d2                	test   %edx,%edx
80101c52:	74 ec                	je     80101c40 <iput+0x110>
        bfree(ip->dev, a[j]);
80101c54:	8b 07                	mov    (%edi),%eax
80101c56:	e8 45 f6 ff ff       	call   801012a0 <bfree>
80101c5b:	eb e3                	jmp    80101c40 <iput+0x110>
    }
    brelse(bp);
80101c5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c60:	89 fe                	mov    %edi,%esi
80101c62:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101c65:	89 04 24             	mov    %eax,(%esp)
80101c68:	e8 d3 e3 ff ff       	call   80100040 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101c6d:	8b 96 88 00 00 00    	mov    0x88(%esi),%edx
80101c73:	8b 06                	mov    (%esi),%eax
80101c75:	e8 26 f6 ff ff       	call   801012a0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101c7a:	c7 86 88 00 00 00 00 	movl   $0x0,0x88(%esi)
80101c81:	00 00 00 
80101c84:	e9 66 ff ff ff       	jmp    80101bef <iput+0xbf>
80101c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101c90 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80101c90:	55                   	push   %ebp
80101c91:	89 e5                	mov    %esp,%ebp
80101c93:	57                   	push   %edi
80101c94:	56                   	push   %esi
80101c95:	53                   	push   %ebx
80101c96:	83 ec 2c             	sub    $0x2c,%esp
80101c99:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80101c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101ca6:	00 
80101ca7:	89 34 24             	mov    %esi,(%esp)
80101caa:	89 44 24 04          	mov    %eax,0x4(%esp)
80101cae:	e8 1d fc ff ff       	call   801018d0 <dirlookup>
80101cb3:	85 c0                	test   %eax,%eax
80101cb5:	0f 85 89 00 00 00    	jne    80101d44 <dirlink+0xb4>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80101cbb:	8b 4e 58             	mov    0x58(%esi),%ecx
80101cbe:	85 c9                	test   %ecx,%ecx
80101cc0:	0f 84 8d 00 00 00    	je     80101d53 <dirlink+0xc3>
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
    return -1;
80101cc6:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101cc9:	31 db                	xor    %ebx,%ebx
80101ccb:	eb 0b                	jmp    80101cd8 <dirlink+0x48>
80101ccd:	8d 76 00             	lea    0x0(%esi),%esi
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80101cd0:	83 c3 10             	add    $0x10,%ebx
80101cd3:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101cd6:	76 24                	jbe    80101cfc <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101cd8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101cdf:	00 
80101ce0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101ce4:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101ce8:	89 34 24             	mov    %esi,(%esp)
80101ceb:	e8 d0 fa ff ff       	call   801017c0 <readi>
80101cf0:	83 f8 10             	cmp    $0x10,%eax
80101cf3:	75 65                	jne    80101d5a <dirlink+0xca>
      panic("dirlink read");
    if(de.inum == 0)
80101cf5:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101cfa:	75 d4                	jne    80101cd0 <dirlink+0x40>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80101cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cff:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101d06:	00 
80101d07:	89 44 24 04          	mov    %eax,0x4(%esp)
80101d0b:	8d 45 da             	lea    -0x26(%ebp),%eax
80101d0e:	89 04 24             	mov    %eax,(%esp)
80101d11:	e8 ba 28 00 00       	call   801045d0 <strncpy>
  de.inum = inum;
80101d16:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d19:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101d20:	00 
80101d21:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101d25:	89 7c 24 04          	mov    %edi,0x4(%esp)
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
80101d29:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d2d:	89 34 24             	mov    %esi,(%esp)
80101d30:	e8 6b f9 ff ff       	call   801016a0 <writei>
80101d35:	83 f8 10             	cmp    $0x10,%eax
80101d38:	75 2c                	jne    80101d66 <dirlink+0xd6>
    panic("dirlink");
80101d3a:	31 c0                	xor    %eax,%eax

  return 0;
}
80101d3c:	83 c4 2c             	add    $0x2c,%esp
80101d3f:	5b                   	pop    %ebx
80101d40:	5e                   	pop    %esi
80101d41:	5f                   	pop    %edi
80101d42:	5d                   	pop    %ebp
80101d43:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
80101d44:	89 04 24             	mov    %eax,(%esp)
80101d47:	e8 e4 fd ff ff       	call   80101b30 <iput>
80101d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
80101d51:	eb e9                	jmp    80101d3c <dirlink+0xac>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d53:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101d56:	31 db                	xor    %ebx,%ebx
80101d58:	eb a2                	jmp    80101cfc <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
80101d5a:	c7 04 24 b3 6f 10 80 	movl   $0x80106fb3,(%esp)
80101d61:	e8 4a e6 ff ff       	call   801003b0 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
80101d66:	c7 04 24 9e 75 10 80 	movl   $0x8010759e,(%esp)
80101d6d:	e8 3e e6 ff ff       	call   801003b0 <panic>
80101d72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101d80 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101d80:	55                   	push   %ebp
80101d81:	89 e5                	mov    %esp,%ebp
80101d83:	83 ec 18             	sub    $0x18,%esp
80101d86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80101d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101d8c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101d8f:	85 db                	test   %ebx,%ebx
80101d91:	74 27                	je     80101dba <iunlock+0x3a>
80101d93:	8d 73 0c             	lea    0xc(%ebx),%esi
80101d96:	89 34 24             	mov    %esi,(%esp)
80101d99:	e8 22 23 00 00       	call   801040c0 <holdingsleep>
80101d9e:	85 c0                	test   %eax,%eax
80101da0:	74 18                	je     80101dba <iunlock+0x3a>
80101da2:	8b 5b 08             	mov    0x8(%ebx),%ebx
80101da5:	85 db                	test   %ebx,%ebx
80101da7:	7e 11                	jle    80101dba <iunlock+0x3a>
    panic("iunlock");

  releasesleep(&ip->lock);
80101da9:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101dac:	8b 5d f8             	mov    -0x8(%ebp),%ebx
80101daf:	8b 75 fc             	mov    -0x4(%ebp),%esi
80101db2:	89 ec                	mov    %ebp,%esp
80101db4:	5d                   	pop    %ebp
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");

  releasesleep(&ip->lock);
80101db5:	e9 66 23 00 00       	jmp    80104120 <releasesleep>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");
80101dba:	c7 04 24 c0 6f 10 80 	movl   $0x80106fc0,(%esp)
80101dc1:	e8 ea e5 ff ff       	call   801003b0 <panic>
80101dc6:	8d 76 00             	lea    0x0(%esi),%esi
80101dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101dd0 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dd0:	55                   	push   %ebp
80101dd1:	89 e5                	mov    %esp,%ebp
80101dd3:	53                   	push   %ebx
80101dd4:	83 ec 14             	sub    $0x14,%esp
80101dd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101dda:	89 1c 24             	mov    %ebx,(%esp)
80101ddd:	e8 9e ff ff ff       	call   80101d80 <iunlock>
  iput(ip);
80101de2:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80101de5:	83 c4 14             	add    $0x14,%esp
80101de8:	5b                   	pop    %ebx
80101de9:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
80101dea:	e9 41 fd ff ff       	jmp    80101b30 <iput>
80101def:	90                   	nop

80101df0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101df0:	55                   	push   %ebp
80101df1:	89 e5                	mov    %esp,%ebp
80101df3:	57                   	push   %edi
80101df4:	56                   	push   %esi
80101df5:	53                   	push   %ebx
80101df6:	89 c3                	mov    %eax,%ebx
80101df8:	83 ec 2c             	sub    $0x2c,%esp
80101dfb:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101dfe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101e01:	80 38 2f             	cmpb   $0x2f,(%eax)
80101e04:	0f 84 14 01 00 00    	je     80101f1e <namex+0x12e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101e0a:	e8 01 1d 00 00       	call   80103b10 <myproc>
80101e0f:	8b 40 68             	mov    0x68(%eax),%eax
80101e12:	89 04 24             	mov    %eax,(%esp)
80101e15:	e8 66 f3 ff ff       	call   80101180 <idup>
80101e1a:	89 c7                	mov    %eax,%edi
80101e1c:	eb 05                	jmp    80101e23 <namex+0x33>
80101e1e:	66 90                	xchg   %ax,%ax
{
  char *s;
  int len;

  while(*path == '/')
    path++;
80101e20:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80101e23:	0f b6 03             	movzbl (%ebx),%eax
80101e26:	3c 2f                	cmp    $0x2f,%al
80101e28:	74 f6                	je     80101e20 <namex+0x30>
    path++;
  if(*path == 0)
80101e2a:	84 c0                	test   %al,%al
80101e2c:	75 1a                	jne    80101e48 <namex+0x58>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101e2e:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101e31:	85 f6                	test   %esi,%esi
80101e33:	0f 85 0d 01 00 00    	jne    80101f46 <namex+0x156>
    iput(ip);
    return 0;
  }
  return ip;
}
80101e39:	83 c4 2c             	add    $0x2c,%esp
80101e3c:	89 f8                	mov    %edi,%eax
80101e3e:	5b                   	pop    %ebx
80101e3f:	5e                   	pop    %esi
80101e40:	5f                   	pop    %edi
80101e41:	5d                   	pop    %ebp
80101e42:	c3                   	ret    
80101e43:	90                   	nop
80101e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101e48:	3c 2f                	cmp    $0x2f,%al
80101e4a:	0f 84 94 00 00 00    	je     80101ee4 <namex+0xf4>
80101e50:	89 de                	mov    %ebx,%esi
80101e52:	eb 08                	jmp    80101e5c <namex+0x6c>
80101e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e58:	3c 2f                	cmp    $0x2f,%al
80101e5a:	74 0a                	je     80101e66 <namex+0x76>
    path++;
80101e5c:	83 c6 01             	add    $0x1,%esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101e5f:	0f b6 06             	movzbl (%esi),%eax
80101e62:	84 c0                	test   %al,%al
80101e64:	75 f2                	jne    80101e58 <namex+0x68>
80101e66:	89 f2                	mov    %esi,%edx
80101e68:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
80101e6a:	83 fa 0d             	cmp    $0xd,%edx
80101e6d:	7e 79                	jle    80101ee8 <namex+0xf8>
    memmove(name, s, DIRSIZ);
80101e6f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101e76:	00 
80101e77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101e7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101e7e:	89 04 24             	mov    %eax,(%esp)
80101e81:	e8 7a 26 00 00       	call   80104500 <memmove>
80101e86:	eb 03                	jmp    80101e8b <namex+0x9b>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
    path++;
80101e88:	83 c6 01             	add    $0x1,%esi
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101e8b:	80 3e 2f             	cmpb   $0x2f,(%esi)
80101e8e:	74 f8                	je     80101e88 <namex+0x98>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80101e90:	85 f6                	test   %esi,%esi
80101e92:	74 9a                	je     80101e2e <namex+0x3e>
    ilock(ip);
80101e94:	89 3c 24             	mov    %edi,(%esp)
80101e97:	e8 b4 fb ff ff       	call   80101a50 <ilock>
    if(ip->type != T_DIR){
80101e9c:	66 83 7f 50 01       	cmpw   $0x1,0x50(%edi)
80101ea1:	75 67                	jne    80101f0a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101ea3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101ea6:	85 c0                	test   %eax,%eax
80101ea8:	74 0c                	je     80101eb6 <namex+0xc6>
80101eaa:	80 3e 00             	cmpb   $0x0,(%esi)
80101ead:	8d 76 00             	lea    0x0(%esi),%esi
80101eb0:	0f 84 7e 00 00 00    	je     80101f34 <namex+0x144>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101eb6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101ebd:	00 
80101ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ec1:	89 3c 24             	mov    %edi,(%esp)
80101ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ec8:	e8 03 fa ff ff       	call   801018d0 <dirlookup>
80101ecd:	85 c0                	test   %eax,%eax
80101ecf:	89 c3                	mov    %eax,%ebx
80101ed1:	74 37                	je     80101f0a <namex+0x11a>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
80101ed3:	89 3c 24             	mov    %edi,(%esp)
80101ed6:	89 df                	mov    %ebx,%edi
80101ed8:	89 f3                	mov    %esi,%ebx
80101eda:	e8 f1 fe ff ff       	call   80101dd0 <iunlockput>
80101edf:	e9 3f ff ff ff       	jmp    80101e23 <namex+0x33>
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101ee4:	89 de                	mov    %ebx,%esi
80101ee6:	31 d2                	xor    %edx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80101ee8:	89 54 24 08          	mov    %edx,0x8(%esp)
80101eec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ef3:	89 04 24             	mov    %eax,(%esp)
80101ef6:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ef9:	e8 02 26 00 00       	call   80104500 <memmove>
    name[len] = 0;
80101efe:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101f01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101f04:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
80101f08:	eb 81                	jmp    80101e8b <namex+0x9b>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
80101f0a:	89 3c 24             	mov    %edi,(%esp)
80101f0d:	31 ff                	xor    %edi,%edi
80101f0f:	e8 bc fe ff ff       	call   80101dd0 <iunlockput>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101f14:	83 c4 2c             	add    $0x2c,%esp
80101f17:	89 f8                	mov    %edi,%eax
80101f19:	5b                   	pop    %ebx
80101f1a:	5e                   	pop    %esi
80101f1b:	5f                   	pop    %edi
80101f1c:	5d                   	pop    %ebp
80101f1d:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
80101f1e:	ba 01 00 00 00       	mov    $0x1,%edx
80101f23:	b8 01 00 00 00       	mov    $0x1,%eax
80101f28:	e8 83 f2 ff ff       	call   801011b0 <iget>
80101f2d:	89 c7                	mov    %eax,%edi
80101f2f:	e9 ef fe ff ff       	jmp    80101e23 <namex+0x33>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
80101f34:	89 3c 24             	mov    %edi,(%esp)
80101f37:	e8 44 fe ff ff       	call   80101d80 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101f3c:	83 c4 2c             	add    $0x2c,%esp
80101f3f:	89 f8                	mov    %edi,%eax
80101f41:	5b                   	pop    %ebx
80101f42:	5e                   	pop    %esi
80101f43:	5f                   	pop    %edi
80101f44:	5d                   	pop    %ebp
80101f45:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
80101f46:	89 3c 24             	mov    %edi,(%esp)
80101f49:	31 ff                	xor    %edi,%edi
80101f4b:	e8 e0 fb ff ff       	call   80101b30 <iput>
    return 0;
80101f50:	e9 e4 fe ff ff       	jmp    80101e39 <namex+0x49>
80101f55:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101f59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101f60 <nameiparent>:
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
80101f60:	55                   	push   %ebp
  return namex(path, 1, name);
80101f61:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
80101f66:	89 e5                	mov    %esp,%ebp
80101f68:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101f6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101f6e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101f71:	c9                   	leave  
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
80101f72:	e9 79 fe ff ff       	jmp    80101df0 <namex>
80101f77:	89 f6                	mov    %esi,%esi
80101f79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101f80 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
80101f80:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101f81:	31 d2                	xor    %edx,%edx
  return ip;
}

struct inode*
namei(char *path)
{
80101f83:	89 e5                	mov    %esp,%ebp
80101f85:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101f88:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101f8e:	e8 5d fe ff ff       	call   80101df0 <namex>
}
80101f93:	c9                   	leave  
80101f94:	c3                   	ret    
80101f95:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101fa0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101fa0:	55                   	push   %ebp
80101fa1:	89 e5                	mov    %esp,%ebp
80101fa3:	53                   	push   %ebx
  int i = 0;
  
  initlock(&icache.lock, "icache");
80101fa4:	31 db                	xor    %ebx,%ebx
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101fa6:	83 ec 24             	sub    $0x24,%esp
  int i = 0;
  
  initlock(&icache.lock, "icache");
80101fa9:	c7 44 24 04 c8 6f 10 	movl   $0x80106fc8,0x4(%esp)
80101fb0:	80 
80101fb1:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101fb8:	e8 43 22 00 00       	call   80104200 <initlock>
80101fbd:	8d 76 00             	lea    0x0(%esi),%esi
  for(i = 0; i < NINODE; i++) {
    initsleeplock(&icache.inode[i].lock, "inode");
80101fc0:	8d 04 db             	lea    (%ebx,%ebx,8),%eax
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101fc3:	83 c3 01             	add    $0x1,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
80101fc6:	c1 e0 04             	shl    $0x4,%eax
80101fc9:	05 40 0a 11 80       	add    $0x80110a40,%eax
80101fce:	c7 44 24 04 cf 6f 10 	movl   $0x80106fcf,0x4(%esp)
80101fd5:	80 
80101fd6:	89 04 24             	mov    %eax,(%esp)
80101fd9:	e8 e2 21 00 00       	call   801041c0 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101fde:	83 fb 32             	cmp    $0x32,%ebx
80101fe1:	75 dd                	jne    80101fc0 <iinit+0x20>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe6:	c7 44 24 04 e0 09 11 	movl   $0x801109e0,0x4(%esp)
80101fed:	80 
80101fee:	89 04 24             	mov    %eax,(%esp)
80101ff1:	e8 ba f3 ff ff       	call   801013b0 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101ff6:	a1 f8 09 11 80       	mov    0x801109f8,%eax
80101ffb:	c7 04 24 d8 6f 10 80 	movl   $0x80106fd8,(%esp)
80102002:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80102006:	a1 f4 09 11 80       	mov    0x801109f4,%eax
8010200b:	89 44 24 18          	mov    %eax,0x18(%esp)
8010200f:	a1 f0 09 11 80       	mov    0x801109f0,%eax
80102014:	89 44 24 14          	mov    %eax,0x14(%esp)
80102018:	a1 ec 09 11 80       	mov    0x801109ec,%eax
8010201d:	89 44 24 10          	mov    %eax,0x10(%esp)
80102021:	a1 e8 09 11 80       	mov    0x801109e8,%eax
80102026:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010202a:	a1 e4 09 11 80       	mov    0x801109e4,%eax
8010202f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102033:	a1 e0 09 11 80       	mov    0x801109e0,%eax
80102038:	89 44 24 04          	mov    %eax,0x4(%esp)
8010203c:	e8 0f e8 ff ff       	call   80100850 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80102041:	83 c4 24             	add    $0x24,%esp
80102044:	5b                   	pop    %ebx
80102045:	5d                   	pop    %ebp
80102046:	c3                   	ret    
	...

80102050 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102050:	55                   	push   %ebp
80102051:	89 c1                	mov    %eax,%ecx
80102053:	89 e5                	mov    %esp,%ebp
80102055:	56                   	push   %esi
80102056:	53                   	push   %ebx
80102057:	83 ec 10             	sub    $0x10,%esp
  if(b == 0)
8010205a:	85 c0                	test   %eax,%eax
8010205c:	0f 84 99 00 00 00    	je     801020fb <idestart+0xab>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102062:	8b 58 08             	mov    0x8(%eax),%ebx
80102065:	81 fb 1f 4e 00 00    	cmp    $0x4e1f,%ebx
8010206b:	0f 87 7e 00 00 00    	ja     801020ef <idestart+0x9f>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102071:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102076:	66 90                	xchg   %ax,%ax
80102078:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102079:	25 c0 00 00 00       	and    $0xc0,%eax
8010207e:	83 f8 40             	cmp    $0x40,%eax
80102081:	75 f5                	jne    80102078 <idestart+0x28>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102083:	31 f6                	xor    %esi,%esi
80102085:	ba f6 03 00 00       	mov    $0x3f6,%edx
8010208a:	89 f0                	mov    %esi,%eax
8010208c:	ee                   	out    %al,(%dx)
8010208d:	ba f2 01 00 00       	mov    $0x1f2,%edx
80102092:	b8 01 00 00 00       	mov    $0x1,%eax
80102097:	ee                   	out    %al,(%dx)
80102098:	b2 f3                	mov    $0xf3,%dl
8010209a:	89 d8                	mov    %ebx,%eax
8010209c:	ee                   	out    %al,(%dx)
8010209d:	89 d8                	mov    %ebx,%eax
8010209f:	b2 f4                	mov    $0xf4,%dl
801020a1:	c1 f8 08             	sar    $0x8,%eax
801020a4:	ee                   	out    %al,(%dx)
801020a5:	b2 f5                	mov    $0xf5,%dl
801020a7:	89 f0                	mov    %esi,%eax
801020a9:	ee                   	out    %al,(%dx)
801020aa:	8b 41 04             	mov    0x4(%ecx),%eax
801020ad:	b2 f6                	mov    $0xf6,%dl
801020af:	83 e0 01             	and    $0x1,%eax
801020b2:	c1 e0 04             	shl    $0x4,%eax
801020b5:	83 c8 e0             	or     $0xffffffe0,%eax
801020b8:	ee                   	out    %al,(%dx)
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
801020b9:	f6 01 04             	testb  $0x4,(%ecx)
801020bc:	75 12                	jne    801020d0 <idestart+0x80>
801020be:	ba f7 01 00 00       	mov    $0x1f7,%edx
801020c3:	b8 20 00 00 00       	mov    $0x20,%eax
801020c8:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
801020c9:	83 c4 10             	add    $0x10,%esp
801020cc:	5b                   	pop    %ebx
801020cd:	5e                   	pop    %esi
801020ce:	5d                   	pop    %ebp
801020cf:	c3                   	ret    
801020d0:	b2 f7                	mov    $0xf7,%dl
801020d2:	b8 30 00 00 00       	mov    $0x30,%eax
801020d7:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
801020d8:	ba f0 01 00 00       	mov    $0x1f0,%edx
801020dd:	8d 71 5c             	lea    0x5c(%ecx),%esi
801020e0:	b9 80 00 00 00       	mov    $0x80,%ecx
801020e5:	fc                   	cld    
801020e6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801020e8:	83 c4 10             	add    $0x10,%esp
801020eb:	5b                   	pop    %ebx
801020ec:	5e                   	pop    %esi
801020ed:	5d                   	pop    %ebp
801020ee:	c3                   	ret    
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  if(b->blockno >= FSSIZE)
    panic("incorrect blockno");
801020ef:	c7 04 24 34 70 10 80 	movl   $0x80107034,(%esp)
801020f6:	e8 b5 e2 ff ff       	call   801003b0 <panic>
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
801020fb:	c7 04 24 2b 70 10 80 	movl   $0x8010702b,(%esp)
80102102:	e8 a9 e2 ff ff       	call   801003b0 <panic>
80102107:	89 f6                	mov    %esi,%esi
80102109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102110 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102110:	55                   	push   %ebp
80102111:	89 e5                	mov    %esp,%ebp
80102113:	53                   	push   %ebx
80102114:	83 ec 14             	sub    $0x14,%esp
80102117:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010211a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010211d:	89 04 24             	mov    %eax,(%esp)
80102120:	e8 9b 1f 00 00       	call   801040c0 <holdingsleep>
80102125:	85 c0                	test   %eax,%eax
80102127:	0f 84 8f 00 00 00    	je     801021bc <iderw+0xac>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010212d:	8b 03                	mov    (%ebx),%eax
8010212f:	83 e0 06             	and    $0x6,%eax
80102132:	83 f8 02             	cmp    $0x2,%eax
80102135:	0f 84 99 00 00 00    	je     801021d4 <iderw+0xc4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010213b:	8b 53 04             	mov    0x4(%ebx),%edx
8010213e:	85 d2                	test   %edx,%edx
80102140:	74 09                	je     8010214b <iderw+0x3b>
80102142:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
80102147:	85 c0                	test   %eax,%eax
80102149:	74 7d                	je     801021c8 <iderw+0xb8>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
8010214b:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80102152:	e8 79 22 00 00       	call   801043d0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102157:	ba b4 a5 10 80       	mov    $0x8010a5b4,%edx
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock

  // Append b to idequeue.
  b->qnext = 0;
8010215c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
80102163:	a1 b4 a5 10 80       	mov    0x8010a5b4,%eax
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102168:	85 c0                	test   %eax,%eax
8010216a:	74 0e                	je     8010217a <iderw+0x6a>
8010216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102170:	8d 50 58             	lea    0x58(%eax),%edx
80102173:	8b 40 58             	mov    0x58(%eax),%eax
80102176:	85 c0                	test   %eax,%eax
80102178:	75 f6                	jne    80102170 <iderw+0x60>
    ;
  *pp = b;
8010217a:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010217c:	39 1d b4 a5 10 80    	cmp    %ebx,0x8010a5b4
80102182:	75 14                	jne    80102198 <iderw+0x88>
80102184:	eb 2d                	jmp    801021b3 <iderw+0xa3>
80102186:	66 90                	xchg   %ax,%ax
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80102188:	c7 44 24 04 80 a5 10 	movl   $0x8010a580,0x4(%esp)
8010218f:	80 
80102190:	89 1c 24             	mov    %ebx,(%esp)
80102193:	e8 d8 1b 00 00       	call   80103d70 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102198:	8b 03                	mov    (%ebx),%eax
8010219a:	83 e0 06             	and    $0x6,%eax
8010219d:	83 f8 02             	cmp    $0x2,%eax
801021a0:	75 e6                	jne    80102188 <iderw+0x78>
    sleep(b, &idelock);
  }


  release(&idelock);
801021a2:	c7 45 08 80 a5 10 80 	movl   $0x8010a580,0x8(%ebp)
}
801021a9:	83 c4 14             	add    $0x14,%esp
801021ac:	5b                   	pop    %ebx
801021ad:	5d                   	pop    %ebp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }


  release(&idelock);
801021ae:	e9 cd 21 00 00       	jmp    80104380 <release>
    ;
  *pp = b;

  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
801021b3:	89 d8                	mov    %ebx,%eax
801021b5:	e8 96 fe ff ff       	call   80102050 <idestart>
801021ba:	eb dc                	jmp    80102198 <iderw+0x88>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
801021bc:	c7 04 24 46 70 10 80 	movl   $0x80107046,(%esp)
801021c3:	e8 e8 e1 ff ff       	call   801003b0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
801021c8:	c7 04 24 71 70 10 80 	movl   $0x80107071,(%esp)
801021cf:	e8 dc e1 ff ff       	call   801003b0 <panic>
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
801021d4:	c7 04 24 5c 70 10 80 	movl   $0x8010705c,(%esp)
801021db:	e8 d0 e1 ff ff       	call   801003b0 <panic>

801021e0 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
801021e0:	55                   	push   %ebp
801021e1:	89 e5                	mov    %esp,%ebp
801021e3:	57                   	push   %edi
801021e4:	53                   	push   %ebx
801021e5:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801021e8:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
801021ef:	e8 dc 21 00 00       	call   801043d0 <acquire>

  if((b = idequeue) == 0){
801021f4:	8b 1d b4 a5 10 80    	mov    0x8010a5b4,%ebx
801021fa:	85 db                	test   %ebx,%ebx
801021fc:	74 2d                	je     8010222b <ideintr+0x4b>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
801021fe:	8b 43 58             	mov    0x58(%ebx),%eax
80102201:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102206:	8b 0b                	mov    (%ebx),%ecx
80102208:	f6 c1 04             	test   $0x4,%cl
8010220b:	74 33                	je     80102240 <ideintr+0x60>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
8010220d:	83 c9 02             	or     $0x2,%ecx
80102210:	83 e1 fb             	and    $0xfffffffb,%ecx
80102213:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
80102215:	89 1c 24             	mov    %ebx,(%esp)
80102218:	e8 43 15 00 00       	call   80103760 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010221d:	a1 b4 a5 10 80       	mov    0x8010a5b4,%eax
80102222:	85 c0                	test   %eax,%eax
80102224:	74 05                	je     8010222b <ideintr+0x4b>
    idestart(idequeue);
80102226:	e8 25 fe ff ff       	call   80102050 <idestart>

  release(&idelock);
8010222b:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80102232:	e8 49 21 00 00       	call   80104380 <release>
}
80102237:	83 c4 10             	add    $0x10,%esp
8010223a:	5b                   	pop    %ebx
8010223b:	5f                   	pop    %edi
8010223c:	5d                   	pop    %ebp
8010223d:	c3                   	ret    
8010223e:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102240:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102245:	8d 76 00             	lea    0x0(%esi),%esi
80102248:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102249:	0f b6 c0             	movzbl %al,%eax
8010224c:	89 c7                	mov    %eax,%edi
8010224e:	81 e7 c0 00 00 00    	and    $0xc0,%edi
80102254:	83 ff 40             	cmp    $0x40,%edi
80102257:	75 ef                	jne    80102248 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102259:	a8 21                	test   $0x21,%al
8010225b:	75 b0                	jne    8010220d <ideintr+0x2d>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
8010225d:	8d 7b 5c             	lea    0x5c(%ebx),%edi
80102260:	b9 80 00 00 00       	mov    $0x80,%ecx
80102265:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010226a:	fc                   	cld    
8010226b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010226d:	8b 0b                	mov    (%ebx),%ecx
8010226f:	eb 9c                	jmp    8010220d <ideintr+0x2d>
80102271:	eb 0d                	jmp    80102280 <ideinit>
80102273:	90                   	nop
80102274:	90                   	nop
80102275:	90                   	nop
80102276:	90                   	nop
80102277:	90                   	nop
80102278:	90                   	nop
80102279:	90                   	nop
8010227a:	90                   	nop
8010227b:	90                   	nop
8010227c:	90                   	nop
8010227d:	90                   	nop
8010227e:	90                   	nop
8010227f:	90                   	nop

80102280 <ideinit>:
  return 0;
}

void
ideinit(void)
{
80102280:	55                   	push   %ebp
80102281:	89 e5                	mov    %esp,%ebp
80102283:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102286:	c7 44 24 04 8f 70 10 	movl   $0x8010708f,0x4(%esp)
8010228d:	80 
8010228e:	c7 04 24 80 a5 10 80 	movl   $0x8010a580,(%esp)
80102295:	e8 66 1f 00 00       	call   80104200 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010229a:	a1 20 2d 11 80       	mov    0x80112d20,%eax
8010229f:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801022a6:	83 e8 01             	sub    $0x1,%eax
801022a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ad:	e8 4e 00 00 00       	call   80102300 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022b2:	ba f7 01 00 00       	mov    $0x1f7,%edx
801022b7:	90                   	nop
801022b8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801022b9:	25 c0 00 00 00       	and    $0xc0,%eax
801022be:	83 f8 40             	cmp    $0x40,%eax
801022c1:	75 f5                	jne    801022b8 <ideinit+0x38>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801022c3:	ba f6 01 00 00       	mov    $0x1f6,%edx
801022c8:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
801022cd:	ee                   	out    %al,(%dx)
801022ce:	31 c9                	xor    %ecx,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022d0:	b2 f7                	mov    $0xf7,%dl
801022d2:	eb 0f                	jmp    801022e3 <ideinit+0x63>
801022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801022d8:	83 c1 01             	add    $0x1,%ecx
801022db:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
801022e1:	74 0f                	je     801022f2 <ideinit+0x72>
801022e3:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
801022e4:	84 c0                	test   %al,%al
801022e6:	74 f0                	je     801022d8 <ideinit+0x58>
      havedisk1 = 1;
801022e8:	c7 05 b8 a5 10 80 01 	movl   $0x1,0x8010a5b8
801022ef:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801022f2:	ba f6 01 00 00       	mov    $0x1f6,%edx
801022f7:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
801022fc:	ee                   	out    %al,(%dx)
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
801022fd:	c9                   	leave  
801022fe:	c3                   	ret    
	...

80102300 <ioapicenable>:
  }
}

void
ioapicenable(int irq, int cpunum)
{
80102300:	55                   	push   %ebp
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102301:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
  }
}

void
ioapicenable(int irq, int cpunum)
{
80102307:	89 e5                	mov    %esp,%ebp
80102309:	8b 55 08             	mov    0x8(%ebp),%edx
8010230c:	53                   	push   %ebx
8010230d:	8b 45 0c             	mov    0xc(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102310:	8d 5a 20             	lea    0x20(%edx),%ebx
80102313:	8d 54 12 10          	lea    0x10(%edx,%edx,1),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102317:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102319:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
8010231f:	83 c2 01             	add    $0x1,%edx
{
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102322:	c1 e0 18             	shl    $0x18,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
80102325:	89 59 10             	mov    %ebx,0x10(%ecx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102328:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
8010232e:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102330:	8b 15 54 26 11 80    	mov    0x80112654,%edx
80102336:	89 42 10             	mov    %eax,0x10(%edx)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102339:	5b                   	pop    %ebx
8010233a:	5d                   	pop    %ebp
8010233b:	c3                   	ret    
8010233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102340 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102340:	55                   	push   %ebp
80102341:	89 e5                	mov    %esp,%ebp
80102343:	56                   	push   %esi
80102344:	53                   	push   %ebx
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80102345:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
  ioapic->data = data;
}

void
ioapicinit(void)
{
8010234a:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010234d:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80102354:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
8010235b:	00 00 00 
  return ioapic->data;
8010235e:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80102364:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
8010236b:	00 00 00 
  return ioapic->data;
8010236e:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
void
ioapicinit(void)
{
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102373:	c7 05 54 26 11 80 00 	movl   $0xfec00000,0x80112654
8010237a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010237d:	c1 ee 10             	shr    $0x10,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80102380:	c1 e8 18             	shr    $0x18,%eax
ioapicinit(void)
{
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102383:	81 e6 ff 00 00 00    	and    $0xff,%esi
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80102389:	39 c2                	cmp    %eax,%edx
8010238b:	74 12                	je     8010239f <ioapicinit+0x5f>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010238d:	c7 04 24 94 70 10 80 	movl   $0x80107094,(%esp)
80102394:	e8 b7 e4 ff ff       	call   80100850 <cprintf>
80102399:	8b 1d 54 26 11 80    	mov    0x80112654,%ebx
8010239f:	ba 10 00 00 00       	mov    $0x10,%edx
801023a4:	31 c0                	xor    %eax,%eax
801023a6:	eb 06                	jmp    801023ae <ioapicinit+0x6e>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801023a8:	8b 1d 54 26 11 80    	mov    0x80112654,%ebx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
801023ae:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
801023b0:	8b 1d 54 26 11 80    	mov    0x80112654,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801023b6:	8d 48 20             	lea    0x20(%eax),%ecx
801023b9:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801023bf:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
801023c2:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
801023c5:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
801023cb:	8d 5a 01             	lea    0x1(%edx),%ebx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801023ce:	83 c2 02             	add    $0x2,%edx
801023d1:	39 c6                	cmp    %eax,%esi
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
801023d3:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
801023d5:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
801023db:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801023e2:	7d c4                	jge    801023a8 <ioapicinit+0x68>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801023e4:	83 c4 10             	add    $0x10,%esp
801023e7:	5b                   	pop    %ebx
801023e8:	5e                   	pop    %esi
801023e9:	5d                   	pop    %ebp
801023ea:	c3                   	ret    
801023eb:	00 00                	add    %al,(%eax)
801023ed:	00 00                	add    %al,(%eax)
	...

801023f0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801023f0:	55                   	push   %ebp
801023f1:	89 e5                	mov    %esp,%ebp
801023f3:	53                   	push   %ebx
801023f4:	83 ec 14             	sub    $0x14,%esp
  struct run *r;

  if(kmem.use_lock)
801023f7:	8b 15 94 26 11 80    	mov    0x80112694,%edx
801023fd:	85 d2                	test   %edx,%edx
801023ff:	75 2f                	jne    80102430 <kalloc+0x40>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102401:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  if(r)
80102407:	85 db                	test   %ebx,%ebx
80102409:	74 07                	je     80102412 <kalloc+0x22>
    kmem.freelist = r->next;
8010240b:	8b 03                	mov    (%ebx),%eax
8010240d:	a3 98 26 11 80       	mov    %eax,0x80112698
  if(kmem.use_lock)
80102412:	a1 94 26 11 80       	mov    0x80112694,%eax
80102417:	85 c0                	test   %eax,%eax
80102419:	74 0c                	je     80102427 <kalloc+0x37>
    release(&kmem.lock);
8010241b:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
80102422:	e8 59 1f 00 00       	call   80104380 <release>
  return (char*)r;
}
80102427:	89 d8                	mov    %ebx,%eax
80102429:	83 c4 14             	add    $0x14,%esp
8010242c:	5b                   	pop    %ebx
8010242d:	5d                   	pop    %ebp
8010242e:	c3                   	ret    
8010242f:	90                   	nop
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
80102430:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
80102437:	e8 94 1f 00 00       	call   801043d0 <acquire>
8010243c:	eb c3                	jmp    80102401 <kalloc+0x11>
8010243e:	66 90                	xchg   %ax,%ax

80102440 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102440:	55                   	push   %ebp
80102441:	89 e5                	mov    %esp,%ebp
80102443:	53                   	push   %ebx
80102444:	83 ec 14             	sub    $0x14,%esp
80102447:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010244a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102450:	75 7c                	jne    801024ce <kfree+0x8e>
80102452:	81 fb c8 54 11 80    	cmp    $0x801154c8,%ebx
80102458:	72 74                	jb     801024ce <kfree+0x8e>
8010245a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102460:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102465:	77 67                	ja     801024ce <kfree+0x8e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102467:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010246e:	00 
8010246f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102476:	00 
80102477:	89 1c 24             	mov    %ebx,(%esp)
8010247a:	e8 c1 1f 00 00       	call   80104440 <memset>

  if(kmem.use_lock)
8010247f:	a1 94 26 11 80       	mov    0x80112694,%eax
80102484:	85 c0                	test   %eax,%eax
80102486:	75 38                	jne    801024c0 <kfree+0x80>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102488:	a1 98 26 11 80       	mov    0x80112698,%eax
8010248d:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010248f:	8b 0d 94 26 11 80    	mov    0x80112694,%ecx

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
80102495:	89 1d 98 26 11 80    	mov    %ebx,0x80112698
  if(kmem.use_lock)
8010249b:	85 c9                	test   %ecx,%ecx
8010249d:	75 09                	jne    801024a8 <kfree+0x68>
    release(&kmem.lock);
}
8010249f:	83 c4 14             	add    $0x14,%esp
801024a2:	5b                   	pop    %ebx
801024a3:	5d                   	pop    %ebp
801024a4:	c3                   	ret    
801024a5:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if(kmem.use_lock)
    release(&kmem.lock);
801024a8:	c7 45 08 60 26 11 80 	movl   $0x80112660,0x8(%ebp)
}
801024af:	83 c4 14             	add    $0x14,%esp
801024b2:	5b                   	pop    %ebx
801024b3:	5d                   	pop    %ebp
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if(kmem.use_lock)
    release(&kmem.lock);
801024b4:	e9 c7 1e 00 00       	jmp    80104380 <release>
801024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);

  if(kmem.use_lock)
    acquire(&kmem.lock);
801024c0:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
801024c7:	e8 04 1f 00 00       	call   801043d0 <acquire>
801024cc:	eb ba                	jmp    80102488 <kfree+0x48>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");
801024ce:	c7 04 24 c6 70 10 80 	movl   $0x801070c6,(%esp)
801024d5:	e8 d6 de ff ff       	call   801003b0 <panic>
801024da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801024e0 <freerange>:
  kmem.use_lock = 1;
}

void
freerange(void *vstart, void *vend)
{
801024e0:	55                   	push   %ebp
801024e1:	89 e5                	mov    %esp,%ebp
801024e3:	56                   	push   %esi
801024e4:	53                   	push   %ebx
801024e5:	83 ec 10             	sub    $0x10,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801024e8:	8b 55 08             	mov    0x8(%ebp),%edx
  kmem.use_lock = 1;
}

void
freerange(void *vstart, void *vend)
{
801024eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801024ee:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
801024f4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801024fa:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
80102500:	39 f3                	cmp    %esi,%ebx
80102502:	76 08                	jbe    8010250c <freerange+0x2c>
80102504:	eb 18                	jmp    8010251e <freerange+0x3e>
80102506:	66 90                	xchg   %ax,%ax
80102508:	89 da                	mov    %ebx,%edx
8010250a:	89 c3                	mov    %eax,%ebx
    kfree(p);
8010250c:	89 14 24             	mov    %edx,(%esp)
8010250f:	e8 2c ff ff ff       	call   80102440 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102514:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
8010251a:	39 f0                	cmp    %esi,%eax
8010251c:	76 ea                	jbe    80102508 <freerange+0x28>
    kfree(p);
}
8010251e:	83 c4 10             	add    $0x10,%esp
80102521:	5b                   	pop    %ebx
80102522:	5e                   	pop    %esi
80102523:	5d                   	pop    %ebp
80102524:	c3                   	ret    
80102525:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102529:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102530 <kinit2>:
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
80102530:	55                   	push   %ebp
80102531:	89 e5                	mov    %esp,%ebp
80102533:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102536:	8b 45 0c             	mov    0xc(%ebp),%eax
80102539:	89 44 24 04          	mov    %eax,0x4(%esp)
8010253d:	8b 45 08             	mov    0x8(%ebp),%eax
80102540:	89 04 24             	mov    %eax,(%esp)
80102543:	e8 98 ff ff ff       	call   801024e0 <freerange>
  kmem.use_lock = 1;
80102548:	c7 05 94 26 11 80 01 	movl   $0x1,0x80112694
8010254f:	00 00 00 
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    
80102554:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010255a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80102560 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102560:	55                   	push   %ebp
80102561:	89 e5                	mov    %esp,%ebp
80102563:	83 ec 18             	sub    $0x18,%esp
80102566:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80102569:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010256c:	89 75 fc             	mov    %esi,-0x4(%ebp)
8010256f:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102572:	c7 44 24 04 cc 70 10 	movl   $0x801070cc,0x4(%esp)
80102579:	80 
8010257a:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
80102581:	e8 7a 1c 00 00       	call   80104200 <initlock>
  kmem.use_lock = 0;
80102586:	c7 05 94 26 11 80 00 	movl   $0x0,0x80112694
8010258d:	00 00 00 
  freerange(vstart, vend);
80102590:	89 75 0c             	mov    %esi,0xc(%ebp)
}
80102593:	8b 75 fc             	mov    -0x4(%ebp),%esi
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
80102596:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80102599:	8b 5d f8             	mov    -0x8(%ebp),%ebx
8010259c:	89 ec                	mov    %ebp,%esp
8010259e:	5d                   	pop    %ebp
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
8010259f:	e9 3c ff ff ff       	jmp    801024e0 <freerange>
	...

801025b0 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801025b0:	55                   	push   %ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025b1:	ba 64 00 00 00       	mov    $0x64,%edx
801025b6:	89 e5                	mov    %esp,%ebp
801025b8:	ec                   	in     (%dx),%al
801025b9:	89 c2                	mov    %eax,%edx
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801025bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025c0:	83 e2 01             	and    $0x1,%edx
801025c3:	74 41                	je     80102606 <kbdgetc+0x56>
801025c5:	ba 60 00 00 00       	mov    $0x60,%edx
801025ca:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801025cb:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
801025ce:	3d e0 00 00 00       	cmp    $0xe0,%eax
801025d3:	0f 84 7f 00 00 00    	je     80102658 <kbdgetc+0xa8>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801025d9:	84 c0                	test   %al,%al
801025db:	79 2b                	jns    80102608 <kbdgetc+0x58>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801025dd:	8b 15 bc a5 10 80    	mov    0x8010a5bc,%edx
801025e3:	89 c1                	mov    %eax,%ecx
801025e5:	83 e1 7f             	and    $0x7f,%ecx
801025e8:	f6 c2 40             	test   $0x40,%dl
801025eb:	0f 44 c1             	cmove  %ecx,%eax
    shift &= ~(shiftcode[data] | E0ESC);
801025ee:	0f b6 80 e0 70 10 80 	movzbl -0x7fef8f20(%eax),%eax
801025f5:	83 c8 40             	or     $0x40,%eax
801025f8:	0f b6 c0             	movzbl %al,%eax
801025fb:	f7 d0                	not    %eax
801025fd:	21 d0                	and    %edx,%eax
801025ff:	a3 bc a5 10 80       	mov    %eax,0x8010a5bc
80102604:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102606:	5d                   	pop    %ebp
80102607:	c3                   	ret    
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102608:	8b 0d bc a5 10 80    	mov    0x8010a5bc,%ecx
8010260e:	f6 c1 40             	test   $0x40,%cl
80102611:	74 05                	je     80102618 <kbdgetc+0x68>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102613:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
80102615:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
80102618:	0f b6 90 e0 70 10 80 	movzbl -0x7fef8f20(%eax),%edx
8010261f:	09 ca                	or     %ecx,%edx
80102621:	0f b6 88 e0 71 10 80 	movzbl -0x7fef8e20(%eax),%ecx
80102628:	31 ca                	xor    %ecx,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010262a:	89 d1                	mov    %edx,%ecx
8010262c:	83 e1 03             	and    $0x3,%ecx
8010262f:	8b 0c 8d e0 72 10 80 	mov    -0x7fef8d20(,%ecx,4),%ecx
    data |= 0x80;
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
80102636:	89 15 bc a5 10 80    	mov    %edx,0x8010a5bc
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
8010263c:	83 e2 08             	and    $0x8,%edx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
8010263f:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
80102643:	74 c1                	je     80102606 <kbdgetc+0x56>
    if('a' <= c && c <= 'z')
80102645:	8d 50 9f             	lea    -0x61(%eax),%edx
80102648:	83 fa 19             	cmp    $0x19,%edx
8010264b:	77 1b                	ja     80102668 <kbdgetc+0xb8>
      c += 'A' - 'a';
8010264d:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102650:	5d                   	pop    %ebp
80102651:	c3                   	ret    
80102652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
80102658:	30 c0                	xor    %al,%al
8010265a:	83 0d bc a5 10 80 40 	orl    $0x40,0x8010a5bc
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102661:	5d                   	pop    %ebp
80102662:	c3                   	ret    
80102663:	90                   	nop
80102664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
80102668:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
8010266b:	8d 50 20             	lea    0x20(%eax),%edx
8010266e:	83 f9 19             	cmp    $0x19,%ecx
80102671:	0f 46 c2             	cmovbe %edx,%eax
  }
  return c;
}
80102674:	5d                   	pop    %ebp
80102675:	c3                   	ret    
80102676:	8d 76 00             	lea    0x0(%esi),%esi
80102679:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102680 <kbdintr>:

void
kbdintr(void)
{
80102680:	55                   	push   %ebp
80102681:	89 e5                	mov    %esp,%ebp
80102683:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102686:	c7 04 24 b0 25 10 80 	movl   $0x801025b0,(%esp)
8010268d:	e8 8e df ff ff       	call   80100620 <consoleintr>
}
80102692:	c9                   	leave  
80102693:	c3                   	ret    
	...

801026a0 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
801026a0:	a1 9c 26 11 80       	mov    0x8011269c,%eax
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(void)
{
801026a5:	55                   	push   %ebp
801026a6:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801026a8:	85 c0                	test   %eax,%eax
801026aa:	0f 84 09 01 00 00    	je     801027b9 <lapicinit+0x119>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026b0:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
801026b7:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026ba:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801026bf:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026c2:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
801026c9:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026cc:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801026d1:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026d4:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
801026db:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
801026de:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801026e3:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026e6:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
801026ed:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
801026f0:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801026f5:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026f8:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
801026ff:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102702:	a1 9c 26 11 80       	mov    0x8011269c,%eax
80102707:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010270a:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102711:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102714:	a1 9c 26 11 80       	mov    0x8011269c,%eax
80102719:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010271c:	8b 50 30             	mov    0x30(%eax),%edx
8010271f:	c1 ea 10             	shr    $0x10,%edx
80102722:	80 fa 03             	cmp    $0x3,%dl
80102725:	0f 87 95 00 00 00    	ja     801027c0 <lapicinit+0x120>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010272b:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102732:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102735:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010273a:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010273d:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102744:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102747:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010274c:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010274f:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102756:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102759:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010275e:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102761:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102768:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010276b:	a1 9c 26 11 80       	mov    0x8011269c,%eax
80102770:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102773:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
8010277a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010277d:	a1 9c 26 11 80       	mov    0x8011269c,%eax
80102782:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102785:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
8010278c:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
8010278f:	8b 0d 9c 26 11 80    	mov    0x8011269c,%ecx
80102795:	8b 41 20             	mov    0x20(%ecx),%eax
80102798:	8d 91 00 03 00 00    	lea    0x300(%ecx),%edx
8010279e:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801027a0:	8b 02                	mov    (%edx),%eax
801027a2:	f6 c4 10             	test   $0x10,%ah
801027a5:	75 f9                	jne    801027a0 <lapicinit+0x100>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027a7:	c7 81 80 00 00 00 00 	movl   $0x0,0x80(%ecx)
801027ae:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801027b1:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801027b6:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801027b9:	5d                   	pop    %ebp
801027ba:	c3                   	ret    
801027bb:	90                   	nop
801027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027c0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801027c7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801027ca:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801027cf:	8b 50 20             	mov    0x20(%eax),%edx
801027d2:	e9 54 ff ff ff       	jmp    8010272b <lapicinit+0x8b>
801027d7:	89 f6                	mov    %esi,%esi
801027d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801027e0 <lapicid>:
}

int
lapicid(void)
{
  if (!lapic)
801027e0:	8b 15 9c 26 11 80    	mov    0x8011269c,%edx
801027e6:	31 c0                	xor    %eax,%eax
  lapicw(TPR, 0);
}

int
lapicid(void)
{
801027e8:	55                   	push   %ebp
801027e9:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801027eb:	85 d2                	test   %edx,%edx
801027ed:	74 06                	je     801027f5 <lapicid+0x15>
    return 0;
  return lapic[ID] >> 24;
801027ef:	8b 42 20             	mov    0x20(%edx),%eax
801027f2:	c1 e8 18             	shr    $0x18,%eax
}
801027f5:	5d                   	pop    %ebp
801027f6:	c3                   	ret    
801027f7:	89 f6                	mov    %esi,%esi
801027f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102800 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102800:	a1 9c 26 11 80       	mov    0x8011269c,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102805:	55                   	push   %ebp
80102806:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102808:	85 c0                	test   %eax,%eax
8010280a:	74 12                	je     8010281e <lapiceoi+0x1e>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010280c:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102813:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102816:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010281b:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
8010281e:	5d                   	pop    %ebp
8010281f:	c3                   	ret    

80102820 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102820:	55                   	push   %ebp
80102821:	89 e5                	mov    %esp,%ebp
}
80102823:	5d                   	pop    %ebp
80102824:	c3                   	ret    
80102825:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102830 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102830:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102831:	ba 70 00 00 00       	mov    $0x70,%edx
80102836:	89 e5                	mov    %esp,%ebp
80102838:	b8 0f 00 00 00       	mov    $0xf,%eax
8010283d:	53                   	push   %ebx
8010283e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102841:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
80102845:	ee                   	out    %al,(%dx)
80102846:	b8 0a 00 00 00       	mov    $0xa,%eax
8010284b:	b2 71                	mov    $0x71,%dl
8010284d:	ee                   	out    %al,(%dx)
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
8010284e:	89 c8                	mov    %ecx,%eax
80102850:	c1 e8 04             	shr    $0x4,%eax
80102853:	66 a3 69 04 00 80    	mov    %ax,0x80000469

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102859:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010285e:	c1 e3 18             	shl    $0x18,%ebx
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102861:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102868:	00 00 
//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
8010286a:	c1 e9 0c             	shr    $0xc,%ecx
8010286d:	80 cd 06             	or     $0x6,%ch

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102870:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102876:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010287b:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010287e:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102885:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102888:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010288d:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102890:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102897:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010289a:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010289f:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801028a2:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801028a8:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801028ad:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801028b0:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801028b6:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801028bb:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801028be:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801028c4:	a1 9c 26 11 80       	mov    0x8011269c,%eax
801028c9:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801028cc:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801028d2:	a1 9c 26 11 80       	mov    0x8011269c,%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801028d7:	5b                   	pop    %ebx
801028d8:	5d                   	pop    %ebp
//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
  lapic[ID];  // wait for write to finish, by reading
801028d9:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801028dc:	c3                   	ret    
801028dd:	8d 76 00             	lea    0x0(%esi),%esi

801028e0 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801028e0:	55                   	push   %ebp
801028e1:	ba 70 00 00 00       	mov    $0x70,%edx
801028e6:	89 e5                	mov    %esp,%ebp
801028e8:	b8 0b 00 00 00       	mov    $0xb,%eax
801028ed:	57                   	push   %edi
801028ee:	56                   	push   %esi
801028ef:	53                   	push   %ebx
801028f0:	83 ec 6c             	sub    $0x6c,%esp
801028f3:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028f4:	b2 71                	mov    $0x71,%dl
801028f6:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028f7:	bb 70 00 00 00       	mov    $0x70,%ebx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028fc:	88 45 a7             	mov    %al,-0x59(%ebp)
801028ff:	90                   	nop
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102900:	31 c0                	xor    %eax,%eax
80102902:	89 da                	mov    %ebx,%edx
80102904:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102905:	b9 71 00 00 00       	mov    $0x71,%ecx
8010290a:	89 ca                	mov    %ecx,%edx
8010290c:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010290d:	0f b6 f0             	movzbl %al,%esi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102910:	89 da                	mov    %ebx,%edx
80102912:	b8 02 00 00 00       	mov    $0x2,%eax
80102917:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102918:	89 ca                	mov    %ecx,%edx
8010291a:	ec                   	in     (%dx),%al
8010291b:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010291e:	89 da                	mov    %ebx,%edx
80102920:	89 45 a8             	mov    %eax,-0x58(%ebp)
80102923:	b8 04 00 00 00       	mov    $0x4,%eax
80102928:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102929:	89 ca                	mov    %ecx,%edx
8010292b:	ec                   	in     (%dx),%al
8010292c:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010292f:	89 da                	mov    %ebx,%edx
80102931:	89 45 ac             	mov    %eax,-0x54(%ebp)
80102934:	b8 07 00 00 00       	mov    $0x7,%eax
80102939:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010293a:	89 ca                	mov    %ecx,%edx
8010293c:	ec                   	in     (%dx),%al
8010293d:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102940:	89 da                	mov    %ebx,%edx
80102942:	89 45 b0             	mov    %eax,-0x50(%ebp)
80102945:	b8 08 00 00 00       	mov    $0x8,%eax
8010294a:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010294b:	89 ca                	mov    %ecx,%edx
8010294d:	ec                   	in     (%dx),%al
8010294e:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102951:	89 da                	mov    %ebx,%edx
80102953:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80102956:	b8 09 00 00 00       	mov    $0x9,%eax
8010295b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010295c:	89 ca                	mov    %ecx,%edx
8010295e:	ec                   	in     (%dx),%al
8010295f:	0f b6 f8             	movzbl %al,%edi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102962:	89 da                	mov    %ebx,%edx
80102964:	b8 0a 00 00 00       	mov    $0xa,%eax
80102969:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010296a:	89 ca                	mov    %ecx,%edx
8010296c:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010296d:	84 c0                	test   %al,%al
8010296f:	78 8f                	js     80102900 <cmostime+0x20>
80102971:	8b 45 a8             	mov    -0x58(%ebp),%eax
80102974:	8b 55 ac             	mov    -0x54(%ebp),%edx
80102977:	89 75 d0             	mov    %esi,-0x30(%ebp)
8010297a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010297d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102980:	8b 45 b0             	mov    -0x50(%ebp),%eax
80102983:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102986:	8b 55 b4             	mov    -0x4c(%ebp),%edx
80102989:	89 45 dc             	mov    %eax,-0x24(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010298c:	31 c0                	xor    %eax,%eax
8010298e:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102991:	89 da                	mov    %ebx,%edx
80102993:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102994:	89 ca                	mov    %ecx,%edx
80102996:	ec                   	in     (%dx),%al
}

static void
fill_rtcdate(struct rtcdate *r)
{
  r->second = cmos_read(SECS);
80102997:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010299a:	89 da                	mov    %ebx,%edx
8010299c:	89 45 b8             	mov    %eax,-0x48(%ebp)
8010299f:	b8 02 00 00 00       	mov    $0x2,%eax
801029a4:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029a5:	89 ca                	mov    %ecx,%edx
801029a7:	ec                   	in     (%dx),%al
  r->minute = cmos_read(MINS);
801029a8:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ab:	89 da                	mov    %ebx,%edx
801029ad:	89 45 bc             	mov    %eax,-0x44(%ebp)
801029b0:	b8 04 00 00 00       	mov    $0x4,%eax
801029b5:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029b6:	89 ca                	mov    %ecx,%edx
801029b8:	ec                   	in     (%dx),%al
  r->hour   = cmos_read(HOURS);
801029b9:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029bc:	89 da                	mov    %ebx,%edx
801029be:	89 45 c0             	mov    %eax,-0x40(%ebp)
801029c1:	b8 07 00 00 00       	mov    $0x7,%eax
801029c6:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029c7:	89 ca                	mov    %ecx,%edx
801029c9:	ec                   	in     (%dx),%al
  r->day    = cmos_read(DAY);
801029ca:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029cd:	89 da                	mov    %ebx,%edx
801029cf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801029d2:	b8 08 00 00 00       	mov    $0x8,%eax
801029d7:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029d8:	89 ca                	mov    %ecx,%edx
801029da:	ec                   	in     (%dx),%al
  r->month  = cmos_read(MONTH);
801029db:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029de:	89 da                	mov    %ebx,%edx
801029e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
801029e3:	b8 09 00 00 00       	mov    $0x9,%eax
801029e8:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029e9:	89 ca                	mov    %ecx,%edx
801029eb:	ec                   	in     (%dx),%al
  r->year   = cmos_read(YEAR);
801029ec:	0f b6 c8             	movzbl %al,%ecx
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029ef:	8d 55 d0             	lea    -0x30(%ebp),%edx
801029f2:	8d 45 b8             	lea    -0x48(%ebp),%eax
  r->second = cmos_read(SECS);
  r->minute = cmos_read(MINS);
  r->hour   = cmos_read(HOURS);
  r->day    = cmos_read(DAY);
  r->month  = cmos_read(MONTH);
  r->year   = cmos_read(YEAR);
801029f5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801029f8:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801029ff:	00 
80102a00:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a04:	89 14 24             	mov    %edx,(%esp)
80102a07:	e8 94 1a 00 00       	call   801044a0 <memcmp>
80102a0c:	85 c0                	test   %eax,%eax
80102a0e:	0f 85 ec fe ff ff    	jne    80102900 <cmostime+0x20>
      break;
  }

  // convert
  if(bcd) {
80102a14:	f6 45 a7 04          	testb  $0x4,-0x59(%ebp)
80102a18:	75 78                	jne    80102a92 <cmostime+0x1b2>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102a1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102a1d:	89 c2                	mov    %eax,%edx
80102a1f:	83 e0 0f             	and    $0xf,%eax
80102a22:	c1 ea 04             	shr    $0x4,%edx
80102a25:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a28:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102a2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102a31:	89 c2                	mov    %eax,%edx
80102a33:	83 e0 0f             	and    $0xf,%eax
80102a36:	c1 ea 04             	shr    $0x4,%edx
80102a39:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a3c:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102a42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102a45:	89 c2                	mov    %eax,%edx
80102a47:	83 e0 0f             	and    $0xf,%eax
80102a4a:	c1 ea 04             	shr    $0x4,%edx
80102a4d:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a50:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a53:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102a56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102a59:	89 c2                	mov    %eax,%edx
80102a5b:	83 e0 0f             	and    $0xf,%eax
80102a5e:	c1 ea 04             	shr    $0x4,%edx
80102a61:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a64:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102a6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102a6d:	89 c2                	mov    %eax,%edx
80102a6f:	83 e0 0f             	and    $0xf,%eax
80102a72:	c1 ea 04             	shr    $0x4,%edx
80102a75:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a78:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102a7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102a81:	89 c2                	mov    %eax,%edx
80102a83:	83 e0 0f             	and    $0xf,%eax
80102a86:	c1 ea 04             	shr    $0x4,%edx
80102a89:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102a8c:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102a8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102a92:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102a95:	8b 55 08             	mov    0x8(%ebp),%edx
80102a98:	89 02                	mov    %eax,(%edx)
80102a9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102a9d:	89 42 04             	mov    %eax,0x4(%edx)
80102aa0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102aa3:	89 42 08             	mov    %eax,0x8(%edx)
80102aa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102aa9:	89 42 0c             	mov    %eax,0xc(%edx)
80102aac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102aaf:	89 42 10             	mov    %eax,0x10(%edx)
80102ab2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ab5:	89 42 14             	mov    %eax,0x14(%edx)
  r->year += 2000;
80102ab8:	81 42 14 d0 07 00 00 	addl   $0x7d0,0x14(%edx)
}
80102abf:	83 c4 6c             	add    $0x6c,%esp
80102ac2:	5b                   	pop    %ebx
80102ac3:	5e                   	pop    %esi
80102ac4:	5f                   	pop    %edi
80102ac5:	5d                   	pop    %ebp
80102ac6:	c3                   	ret    
	...

80102ad0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102ad0:	55                   	push   %ebp
80102ad1:	89 e5                	mov    %esp,%ebp
80102ad3:	53                   	push   %ebx
80102ad4:	83 ec 14             	sub    $0x14,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102ad7:	a1 e8 26 11 80       	mov    0x801126e8,%eax
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102adc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102adf:	83 f8 1d             	cmp    $0x1d,%eax
80102ae2:	7f 7e                	jg     80102b62 <log_write+0x92>
80102ae4:	8b 15 d8 26 11 80    	mov    0x801126d8,%edx
80102aea:	83 ea 01             	sub    $0x1,%edx
80102aed:	39 d0                	cmp    %edx,%eax
80102aef:	7d 71                	jge    80102b62 <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102af1:	a1 dc 26 11 80       	mov    0x801126dc,%eax
80102af6:	85 c0                	test   %eax,%eax
80102af8:	7e 74                	jle    80102b6e <log_write+0x9e>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102afa:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102b01:	e8 ca 18 00 00       	call   801043d0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102b06:	8b 0d e8 26 11 80    	mov    0x801126e8,%ecx
80102b0c:	85 c9                	test   %ecx,%ecx
80102b0e:	7e 4b                	jle    80102b5b <log_write+0x8b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102b10:	8b 53 08             	mov    0x8(%ebx),%edx
80102b13:	31 c0                	xor    %eax,%eax
80102b15:	39 15 ec 26 11 80    	cmp    %edx,0x801126ec
80102b1b:	75 0c                	jne    80102b29 <log_write+0x59>
80102b1d:	eb 11                	jmp    80102b30 <log_write+0x60>
80102b1f:	90                   	nop
80102b20:	3b 14 85 ec 26 11 80 	cmp    -0x7feed914(,%eax,4),%edx
80102b27:	74 07                	je     80102b30 <log_write+0x60>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80102b29:	83 c0 01             	add    $0x1,%eax
80102b2c:	39 c8                	cmp    %ecx,%eax
80102b2e:	7c f0                	jl     80102b20 <log_write+0x50>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80102b30:	89 14 85 ec 26 11 80 	mov    %edx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
80102b37:	39 05 e8 26 11 80    	cmp    %eax,0x801126e8
80102b3d:	75 08                	jne    80102b47 <log_write+0x77>
    log.lh.n++;
80102b3f:	83 c0 01             	add    $0x1,%eax
80102b42:	a3 e8 26 11 80       	mov    %eax,0x801126e8
  b->flags |= B_DIRTY; // prevent eviction
80102b47:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102b4a:	c7 45 08 a0 26 11 80 	movl   $0x801126a0,0x8(%ebp)
}
80102b51:	83 c4 14             	add    $0x14,%esp
80102b54:	5b                   	pop    %ebx
80102b55:	5d                   	pop    %ebp
  }
  log.lh.block[i] = b->blockno;
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
  release(&log.lock);
80102b56:	e9 25 18 00 00       	jmp    80104380 <release>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80102b5b:	8b 53 08             	mov    0x8(%ebx),%edx
80102b5e:	31 c0                	xor    %eax,%eax
80102b60:	eb ce                	jmp    80102b30 <log_write+0x60>
log_write(struct buf *b)
{
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
80102b62:	c7 04 24 f0 72 10 80 	movl   $0x801072f0,(%esp)
80102b69:	e8 42 d8 ff ff       	call   801003b0 <panic>
  if (log.outstanding < 1)
    panic("log_write outside of trans");
80102b6e:	c7 04 24 06 73 10 80 	movl   $0x80107306,(%esp)
80102b75:	e8 36 d8 ff ff       	call   801003b0 <panic>
80102b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102b80 <install_trans>:
}

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102b80:	55                   	push   %ebp
80102b81:	89 e5                	mov    %esp,%ebp
80102b83:	57                   	push   %edi
80102b84:	56                   	push   %esi
80102b85:	53                   	push   %ebx
80102b86:	83 ec 1c             	sub    $0x1c,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102b89:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
80102b8f:	85 d2                	test   %edx,%edx
80102b91:	7e 78                	jle    80102c0b <install_trans+0x8b>
80102b93:	31 db                	xor    %ebx,%ebx
80102b95:	8d 76 00             	lea    0x0(%esi),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102b98:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102b9d:	8d 44 03 01          	lea    0x1(%ebx,%eax,1),%eax
80102ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ba5:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102baa:	89 04 24             	mov    %eax,(%esp)
80102bad:	e8 5e d5 ff ff       	call   80100110 <bread>
80102bb2:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102bb4:	8b 04 9d ec 26 11 80 	mov    -0x7feed914(,%ebx,4),%eax
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102bbb:	83 c3 01             	add    $0x1,%ebx
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bc2:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102bc7:	89 04 24             	mov    %eax,(%esp)
80102bca:	e8 41 d5 ff ff       	call   80100110 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102bcf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80102bd6:	00 
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102bd7:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102bd9:	8d 47 5c             	lea    0x5c(%edi),%eax
80102bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102be0:	8d 46 5c             	lea    0x5c(%esi),%eax
80102be3:	89 04 24             	mov    %eax,(%esp)
80102be6:	e8 15 19 00 00       	call   80104500 <memmove>
    bwrite(dbuf);  // write dst to disk
80102beb:	89 34 24             	mov    %esi,(%esp)
80102bee:	e8 dd d4 ff ff       	call   801000d0 <bwrite>
    brelse(lbuf);
80102bf3:	89 3c 24             	mov    %edi,(%esp)
80102bf6:	e8 45 d4 ff ff       	call   80100040 <brelse>
    brelse(dbuf);
80102bfb:	89 34 24             	mov    %esi,(%esp)
80102bfe:	e8 3d d4 ff ff       	call   80100040 <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102c03:	39 1d e8 26 11 80    	cmp    %ebx,0x801126e8
80102c09:	7f 8d                	jg     80102b98 <install_trans+0x18>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80102c0b:	83 c4 1c             	add    $0x1c,%esp
80102c0e:	5b                   	pop    %ebx
80102c0f:	5e                   	pop    %esi
80102c10:	5f                   	pop    %edi
80102c11:	5d                   	pop    %ebp
80102c12:	c3                   	ret    
80102c13:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102c19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c20 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102c20:	55                   	push   %ebp
80102c21:	89 e5                	mov    %esp,%ebp
80102c23:	56                   	push   %esi
80102c24:	53                   	push   %ebx
80102c25:	83 ec 10             	sub    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102c28:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c31:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102c36:	89 04 24             	mov    %eax,(%esp)
80102c39:	e8 d2 d4 ff ff       	call   80100110 <bread>
80102c3e:	89 c6                	mov    %eax,%esi
  struct logheader *hb = (struct logheader *) (buf->data);
80102c40:	8d 58 5c             	lea    0x5c(%eax),%ebx
  int i;
  hb->n = log.lh.n;
80102c43:	a1 e8 26 11 80       	mov    0x801126e8,%eax
80102c48:	89 46 5c             	mov    %eax,0x5c(%esi)
  for (i = 0; i < log.lh.n; i++) {
80102c4b:	8b 0d e8 26 11 80    	mov    0x801126e8,%ecx
80102c51:	85 c9                	test   %ecx,%ecx
80102c53:	7e 19                	jle    80102c6e <write_head+0x4e>
80102c55:	31 d2                	xor    %edx,%edx
80102c57:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102c58:	8b 0c 95 ec 26 11 80 	mov    -0x7feed914(,%edx,4),%ecx
80102c5f:	89 4c 93 04          	mov    %ecx,0x4(%ebx,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102c63:	83 c2 01             	add    $0x1,%edx
80102c66:	39 15 e8 26 11 80    	cmp    %edx,0x801126e8
80102c6c:	7f ea                	jg     80102c58 <write_head+0x38>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80102c6e:	89 34 24             	mov    %esi,(%esp)
80102c71:	e8 5a d4 ff ff       	call   801000d0 <bwrite>
  brelse(buf);
80102c76:	89 34 24             	mov    %esi,(%esp)
80102c79:	e8 c2 d3 ff ff       	call   80100040 <brelse>
}
80102c7e:	83 c4 10             	add    $0x10,%esp
80102c81:	5b                   	pop    %ebx
80102c82:	5e                   	pop    %esi
80102c83:	5d                   	pop    %ebp
80102c84:	c3                   	ret    
80102c85:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102c89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c90 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102c90:	55                   	push   %ebp
80102c91:	89 e5                	mov    %esp,%ebp
80102c93:	57                   	push   %edi
80102c94:	56                   	push   %esi
80102c95:	53                   	push   %ebx
80102c96:	83 ec 1c             	sub    $0x1c,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102c99:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102ca0:	e8 2b 17 00 00       	call   801043d0 <acquire>
  log.outstanding -= 1;
80102ca5:	a1 dc 26 11 80       	mov    0x801126dc,%eax
  if(log.committing)
80102caa:	8b 3d e0 26 11 80    	mov    0x801126e0,%edi
end_op(void)
{
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
80102cb0:	83 e8 01             	sub    $0x1,%eax
  if(log.committing)
80102cb3:	85 ff                	test   %edi,%edi
end_op(void)
{
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
80102cb5:	a3 dc 26 11 80       	mov    %eax,0x801126dc
  if(log.committing)
80102cba:	0f 85 f2 00 00 00    	jne    80102db2 <end_op+0x122>
    panic("log.committing");
  if(log.outstanding == 0){
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	0f 85 ca 00 00 00    	jne    80102d92 <end_op+0x102>
    do_commit = 1;
    log.committing = 1;
80102cc8:	c7 05 e0 26 11 80 01 	movl   $0x1,0x801126e0
80102ccf:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102cd2:	31 db                	xor    %ebx,%ebx
80102cd4:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102cdb:	e8 a0 16 00 00       	call   80104380 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102ce0:	8b 35 e8 26 11 80    	mov    0x801126e8,%esi
80102ce6:	85 f6                	test   %esi,%esi
80102ce8:	0f 8e 8e 00 00 00    	jle    80102d7c <end_op+0xec>
80102cee:	66 90                	xchg   %ax,%ax
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102cf0:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102cf5:	8d 44 03 01          	lea    0x1(%ebx,%eax,1),%eax
80102cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cfd:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102d02:	89 04 24             	mov    %eax,(%esp)
80102d05:	e8 06 d4 ff ff       	call   80100110 <bread>
80102d0a:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d0c:	8b 04 9d ec 26 11 80 	mov    -0x7feed914(,%ebx,4),%eax
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102d13:	83 c3 01             	add    $0x1,%ebx
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d16:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d1a:	a1 e4 26 11 80       	mov    0x801126e4,%eax
80102d1f:	89 04 24             	mov    %eax,(%esp)
80102d22:	e8 e9 d3 ff ff       	call   80100110 <bread>
    memmove(to->data, from->data, BSIZE);
80102d27:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80102d2e:	00 
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102d2f:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102d31:	83 c0 5c             	add    $0x5c,%eax
80102d34:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d38:	8d 46 5c             	lea    0x5c(%esi),%eax
80102d3b:	89 04 24             	mov    %eax,(%esp)
80102d3e:	e8 bd 17 00 00       	call   80104500 <memmove>
    bwrite(to);  // write the log
80102d43:	89 34 24             	mov    %esi,(%esp)
80102d46:	e8 85 d3 ff ff       	call   801000d0 <bwrite>
    brelse(from);
80102d4b:	89 3c 24             	mov    %edi,(%esp)
80102d4e:	e8 ed d2 ff ff       	call   80100040 <brelse>
    brelse(to);
80102d53:	89 34 24             	mov    %esi,(%esp)
80102d56:	e8 e5 d2 ff ff       	call   80100040 <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102d5b:	3b 1d e8 26 11 80    	cmp    0x801126e8,%ebx
80102d61:	7c 8d                	jl     80102cf0 <end_op+0x60>
static void
commit()
{
  if (log.lh.n > 0) {
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102d63:	e8 b8 fe ff ff       	call   80102c20 <write_head>
    install_trans(); // Now install writes to home locations
80102d68:	e8 13 fe ff ff       	call   80102b80 <install_trans>
    log.lh.n = 0;
80102d6d:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
80102d74:	00 00 00 
    write_head();    // Erase the transaction from the log
80102d77:	e8 a4 fe ff ff       	call   80102c20 <write_head>

  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
    acquire(&log.lock);
80102d7c:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102d83:	e8 48 16 00 00       	call   801043d0 <acquire>
    log.committing = 0;
80102d88:	c7 05 e0 26 11 80 00 	movl   $0x0,0x801126e0
80102d8f:	00 00 00 
    wakeup(&log);
80102d92:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102d99:	e8 c2 09 00 00       	call   80103760 <wakeup>
    release(&log.lock);
80102d9e:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102da5:	e8 d6 15 00 00       	call   80104380 <release>
  }
}
80102daa:	83 c4 1c             	add    $0x1c,%esp
80102dad:	5b                   	pop    %ebx
80102dae:	5e                   	pop    %esi
80102daf:	5f                   	pop    %edi
80102db0:	5d                   	pop    %ebp
80102db1:	c3                   	ret    
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
  if(log.committing)
    panic("log.committing");
80102db2:	c7 04 24 21 73 10 80 	movl   $0x80107321,(%esp)
80102db9:	e8 f2 d5 ff ff       	call   801003b0 <panic>
80102dbe:	66 90                	xchg   %ax,%ax

80102dc0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102dc0:	55                   	push   %ebp
80102dc1:	89 e5                	mov    %esp,%ebp
80102dc3:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80102dc6:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102dcd:	e8 fe 15 00 00       	call   801043d0 <acquire>
80102dd2:	eb 18                	jmp    80102dec <begin_op+0x2c>
80102dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80102dd8:	c7 44 24 04 a0 26 11 	movl   $0x801126a0,0x4(%esp)
80102ddf:	80 
80102de0:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102de7:	e8 84 0f 00 00       	call   80103d70 <sleep>
void
begin_op(void)
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
80102dec:	a1 e0 26 11 80       	mov    0x801126e0,%eax
80102df1:	85 c0                	test   %eax,%eax
80102df3:	75 e3                	jne    80102dd8 <begin_op+0x18>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102df5:	8b 15 dc 26 11 80    	mov    0x801126dc,%edx
80102dfb:	83 c2 01             	add    $0x1,%edx
80102dfe:	8d 04 92             	lea    (%edx,%edx,4),%eax
80102e01:	01 c0                	add    %eax,%eax
80102e03:	03 05 e8 26 11 80    	add    0x801126e8,%eax
80102e09:	83 f8 1e             	cmp    $0x1e,%eax
80102e0c:	7f ca                	jg     80102dd8 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102e0e:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80102e15:	89 15 dc 26 11 80    	mov    %edx,0x801126dc
      release(&log.lock);
80102e1b:	e8 60 15 00 00       	call   80104380 <release>
      break;
    }
  }
}
80102e20:	c9                   	leave  
80102e21:	c3                   	ret    
80102e22:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102e30 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e30:	55                   	push   %ebp
80102e31:	89 e5                	mov    %esp,%ebp
80102e33:	56                   	push   %esi
80102e34:	53                   	push   %ebx
80102e35:	83 ec 30             	sub    $0x30,%esp
80102e38:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e3b:	c7 44 24 04 30 73 10 	movl   $0x80107330,0x4(%esp)
80102e42:	80 
80102e43:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102e4a:	e8 b1 13 00 00       	call   80104200 <initlock>
  readsb(dev, &sb);
80102e4f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e52:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e56:	89 1c 24             	mov    %ebx,(%esp)
80102e59:	e8 52 e5 ff ff       	call   801013b0 <readsb>
  log.start = sb.logstart;
80102e5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  log.size = sb.nlog;
80102e61:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.dev = dev;
80102e64:	89 1d e4 26 11 80    	mov    %ebx,0x801126e4

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
80102e6a:	89 1c 24             	mov    %ebx,(%esp)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
80102e6d:	a3 d4 26 11 80       	mov    %eax,0x801126d4
  log.size = sb.nlog;
80102e72:	89 15 d8 26 11 80    	mov    %edx,0x801126d8

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
80102e78:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e7c:	e8 8f d2 ff ff       	call   80100110 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102e81:	8b 58 5c             	mov    0x5c(%eax),%ebx
// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
80102e84:	8d 70 5c             	lea    0x5c(%eax),%esi
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80102e87:	85 db                	test   %ebx,%ebx
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102e89:	89 1d e8 26 11 80    	mov    %ebx,0x801126e8
  for (i = 0; i < log.lh.n; i++) {
80102e8f:	7e 19                	jle    80102eaa <initlog+0x7a>
80102e91:	31 d2                	xor    %edx,%edx
80102e93:	90                   	nop
80102e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    log.lh.block[i] = lh->block[i];
80102e98:	8b 4c 96 04          	mov    0x4(%esi,%edx,4),%ecx
80102e9c:	89 0c 95 ec 26 11 80 	mov    %ecx,-0x7feed914(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80102ea3:	83 c2 01             	add    $0x1,%edx
80102ea6:	39 da                	cmp    %ebx,%edx
80102ea8:	75 ee                	jne    80102e98 <initlog+0x68>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80102eaa:	89 04 24             	mov    %eax,(%esp)
80102ead:	e8 8e d1 ff ff       	call   80100040 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102eb2:	e8 c9 fc ff ff       	call   80102b80 <install_trans>
  log.lh.n = 0;
80102eb7:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
80102ebe:	00 00 00 
  write_head(); // clear the log
80102ec1:	e8 5a fd ff ff       	call   80102c20 <write_head>
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
  log.dev = dev;
  recover_from_log();
}
80102ec6:	83 c4 30             	add    $0x30,%esp
80102ec9:	5b                   	pop    %ebx
80102eca:	5e                   	pop    %esi
80102ecb:	5d                   	pop    %ebp
80102ecc:	c3                   	ret    
80102ecd:	00 00                	add    %al,(%eax)
	...

80102ed0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102ed0:	55                   	push   %ebp
80102ed1:	89 e5                	mov    %esp,%ebp
80102ed3:	53                   	push   %ebx
80102ed4:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102ed7:	e8 a4 11 00 00       	call   80104080 <cpuid>
80102edc:	89 c3                	mov    %eax,%ebx
80102ede:	e8 9d 11 00 00       	call   80104080 <cpuid>
80102ee3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80102ee7:	c7 04 24 34 73 10 80 	movl   $0x80107334,(%esp)
80102eee:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ef2:	e8 59 d9 ff ff       	call   80100850 <cprintf>
  idtinit();       // load idt register
80102ef7:	e8 d4 26 00 00       	call   801055d0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102efc:	e8 ef 0a 00 00       	call   801039f0 <mycpu>
80102f01:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102f03:	b8 01 00 00 00       	mov    $0x1,%eax
80102f08:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102f0f:	e8 5c 0b 00 00       	call   80103a70 <scheduler>
80102f14:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102f1a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80102f20 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
80102f23:	83 e4 f0             	and    $0xfffffff0,%esp
80102f26:	53                   	push   %ebx
80102f27:	83 ec 1c             	sub    $0x1c,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102f2a:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80102f31:	80 
80102f32:	c7 04 24 c8 54 11 80 	movl   $0x801154c8,(%esp)
80102f39:	e8 22 f6 ff ff       	call   80102560 <kinit1>
  kvmalloc();      // kernel page table
80102f3e:	e8 4d 3a 00 00       	call   80106990 <kvmalloc>
  mpinit();        // detect other processors
80102f43:	e8 98 01 00 00       	call   801030e0 <mpinit>
  lapicinit();     // interrupt controller
80102f48:	e8 53 f7 ff ff       	call   801026a0 <lapicinit>
80102f4d:	8d 76 00             	lea    0x0(%esi),%esi
  seginit();       // segment descriptors
80102f50:	e8 1b 3e 00 00       	call   80106d70 <seginit>
  picinit();       // disable pic
80102f55:	e8 26 03 00 00       	call   80103280 <picinit>
  ioapicinit();    // another interrupt controller
80102f5a:	e8 e1 f3 ff ff       	call   80102340 <ioapicinit>
80102f5f:	90                   	nop
  consoleinit();   // console hardware
80102f60:	e8 0b d3 ff ff       	call   80100270 <consoleinit>
  uartinit();      // serial port
80102f65:	e8 76 2a 00 00       	call   801059e0 <uartinit>
  pinit();         // process table
80102f6a:	e8 31 11 00 00       	call   801040a0 <pinit>
80102f6f:	90                   	nop
  tvinit();        // trap vectors
80102f70:	e8 3b 29 00 00       	call   801058b0 <tvinit>
  binit();         // buffer cache
80102f75:	e8 66 d2 ff ff       	call   801001e0 <binit>
  fileinit();      // file table
80102f7a:	e8 b1 e1 ff ff       	call   80101130 <fileinit>
80102f7f:	90                   	nop
  ideinit();       // disk 
80102f80:	e8 fb f2 ff ff       	call   80102280 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102f85:	c7 44 24 08 8a 00 00 	movl   $0x8a,0x8(%esp)
80102f8c:	00 
80102f8d:	c7 44 24 04 8c a4 10 	movl   $0x8010a48c,0x4(%esp)
80102f94:	80 
80102f95:	c7 04 24 00 70 00 80 	movl   $0x80007000,(%esp)
80102f9c:	e8 5f 15 00 00       	call   80104500 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102fa1:	69 05 20 2d 11 80 b0 	imul   $0xb0,0x80112d20,%eax
80102fa8:	00 00 00 
80102fab:	05 a0 27 11 80       	add    $0x801127a0,%eax
80102fb0:	3d a0 27 11 80       	cmp    $0x801127a0,%eax
80102fb5:	76 6c                	jbe    80103023 <main+0x103>
80102fb7:	bb a0 27 11 80       	mov    $0x801127a0,%ebx
80102fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(c == mycpu())  // We've started already.
80102fc0:	e8 2b 0a 00 00       	call   801039f0 <mycpu>
80102fc5:	39 d8                	cmp    %ebx,%eax
80102fc7:	74 41                	je     8010300a <main+0xea>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102fc9:	e8 22 f4 ff ff       	call   801023f0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
80102fce:	c7 05 f8 6f 00 80 50 	movl   $0x80103050,0x80006ff8
80102fd5:	30 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102fd8:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102fdf:	90 10 00 

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
    *(void**)(code-4) = stack + KSTACKSIZE;
80102fe2:	05 00 10 00 00       	add    $0x1000,%eax
80102fe7:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80102fec:	0f b6 03             	movzbl (%ebx),%eax
80102fef:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
80102ff6:	00 
80102ff7:	89 04 24             	mov    %eax,(%esp)
80102ffa:	e8 31 f8 ff ff       	call   80102830 <lapicstartap>
80102fff:	90                   	nop

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103000:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103006:	85 c0                	test   %eax,%eax
80103008:	74 f6                	je     80103000 <main+0xe0>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010300a:	69 05 20 2d 11 80 b0 	imul   $0xb0,0x80112d20,%eax
80103011:	00 00 00 
80103014:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
8010301a:	05 a0 27 11 80       	add    $0x801127a0,%eax
8010301f:	39 c3                	cmp    %eax,%ebx
80103021:	72 9d                	jb     80102fc0 <main+0xa0>
  tvinit();        // trap vectors
  binit();         // buffer cache
  fileinit();      // file table
  ideinit();       // disk 
  startothers();   // start other processors
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103023:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010302a:	8e 
8010302b:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103032:	e8 f9 f4 ff ff       	call   80102530 <kinit2>
  userinit();      // first user process
80103037:	e8 b4 08 00 00       	call   801038f0 <userinit>
  mpmain();        // finish this processor's setup
8010303c:	e8 8f fe ff ff       	call   80102ed0 <mpmain>
80103041:	eb 0d                	jmp    80103050 <mpenter>
80103043:	90                   	nop
80103044:	90                   	nop
80103045:	90                   	nop
80103046:	90                   	nop
80103047:	90                   	nop
80103048:	90                   	nop
80103049:	90                   	nop
8010304a:	90                   	nop
8010304b:	90                   	nop
8010304c:	90                   	nop
8010304d:	90                   	nop
8010304e:	90                   	nop
8010304f:	90                   	nop

80103050 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103056:	e8 a5 34 00 00       	call   80106500 <switchkvm>
  seginit();
8010305b:	e8 10 3d 00 00       	call   80106d70 <seginit>
  lapicinit();
80103060:	e8 3b f6 ff ff       	call   801026a0 <lapicinit>
  mpmain();
80103065:	e8 66 fe ff ff       	call   80102ed0 <mpmain>
8010306a:	00 00                	add    %al,(%eax)
8010306c:	00 00                	add    %al,(%eax)
	...

80103070 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103070:	55                   	push   %ebp
80103071:	89 e5                	mov    %esp,%ebp
80103073:	56                   	push   %esi
80103074:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80103075:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010307b:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
8010307e:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80103081:	39 f3                	cmp    %esi,%ebx
80103083:	73 3c                	jae    801030c1 <mpsearch1+0x51>
80103085:	8d 76 00             	lea    0x0(%esi),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103088:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010308f:	00 
80103090:	c7 44 24 04 48 73 10 	movl   $0x80107348,0x4(%esp)
80103097:	80 
80103098:	89 1c 24             	mov    %ebx,(%esp)
8010309b:	e8 00 14 00 00       	call   801044a0 <memcmp>
801030a0:	85 c0                	test   %eax,%eax
801030a2:	75 16                	jne    801030ba <mpsearch1+0x4a>
801030a4:	31 d2                	xor    %edx,%edx
801030a6:	66 90                	xchg   %ax,%ax
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
801030a8:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801030ac:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801030af:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801030b1:	83 f8 10             	cmp    $0x10,%eax
801030b4:	75 f2                	jne    801030a8 <mpsearch1+0x38>
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801030b6:	84 d2                	test   %dl,%dl
801030b8:	74 10                	je     801030ca <mpsearch1+0x5a>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801030ba:	83 c3 10             	add    $0x10,%ebx
801030bd:	39 de                	cmp    %ebx,%esi
801030bf:	77 c7                	ja     80103088 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
801030c1:	83 c4 10             	add    $0x10,%esp
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801030c4:	31 c0                	xor    %eax,%eax
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
801030c6:	5b                   	pop    %ebx
801030c7:	5e                   	pop    %esi
801030c8:	5d                   	pop    %ebp
801030c9:	c3                   	ret    
801030ca:	83 c4 10             	add    $0x10,%esp

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
801030cd:	89 d8                	mov    %ebx,%eax
  return 0;
}
801030cf:	5b                   	pop    %ebx
801030d0:	5e                   	pop    %esi
801030d1:	5d                   	pop    %ebp
801030d2:	c3                   	ret    
801030d3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801030d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801030e0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
801030e0:	55                   	push   %ebp
801030e1:	89 e5                	mov    %esp,%ebp
801030e3:	57                   	push   %edi
801030e4:	56                   	push   %esi
801030e5:	53                   	push   %ebx
801030e6:	83 ec 2c             	sub    $0x2c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801030e9:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
801030f0:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
801030f7:	c1 e0 08             	shl    $0x8,%eax
801030fa:	09 d0                	or     %edx,%eax
801030fc:	c1 e0 04             	shl    $0x4,%eax
801030ff:	85 c0                	test   %eax,%eax
80103101:	75 1b                	jne    8010311e <mpinit+0x3e>
    if((mp = mpsearch1(p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
80103103:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
8010310a:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80103111:	c1 e0 08             	shl    $0x8,%eax
80103114:	09 d0                	or     %edx,%eax
80103116:	c1 e0 0a             	shl    $0xa,%eax
80103119:	2d 00 04 00 00       	sub    $0x400,%eax
8010311e:	ba 00 04 00 00       	mov    $0x400,%edx
80103123:	e8 48 ff ff ff       	call   80103070 <mpsearch1>
80103128:	85 c0                	test   %eax,%eax
8010312a:	89 c7                	mov    %eax,%edi
8010312c:	0f 84 9b 00 00 00    	je     801031cd <mpinit+0xed>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103132:	8b 77 04             	mov    0x4(%edi),%esi
80103135:	85 f6                	test   %esi,%esi
80103137:	75 0c                	jne    80103145 <mpinit+0x65>
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
80103139:	c7 04 24 52 73 10 80 	movl   $0x80107352,(%esp)
80103140:	e8 6b d2 ff ff       	call   801003b0 <panic>
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103145:	8d 9e 00 00 00 80    	lea    -0x80000000(%esi),%ebx
  if(memcmp(conf, "PCMP", 4) != 0)
8010314b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103152:	00 
80103153:	c7 44 24 04 4d 73 10 	movl   $0x8010734d,0x4(%esp)
8010315a:	80 
8010315b:	89 1c 24             	mov    %ebx,(%esp)
8010315e:	e8 3d 13 00 00       	call   801044a0 <memcmp>
80103163:	85 c0                	test   %eax,%eax
80103165:	75 d2                	jne    80103139 <mpinit+0x59>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80103167:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
8010316b:	3c 04                	cmp    $0x4,%al
8010316d:	74 04                	je     80103173 <mpinit+0x93>
8010316f:	3c 01                	cmp    $0x1,%al
80103171:	75 c6                	jne    80103139 <mpinit+0x59>
  *pmp = mp;
  return conf;
}

void
mpinit(void)
80103173:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80103177:	89 d8                	mov    %ebx,%eax
  *pmp = mp;
  return conf;
}

void
mpinit(void)
80103179:	8d 8c 16 00 00 00 80 	lea    -0x80000000(%esi,%edx,1),%ecx
80103180:	31 d2                	xor    %edx,%edx
80103182:	eb 08                	jmp    8010318c <mpinit+0xac>
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
80103184:	0f b6 30             	movzbl (%eax),%esi
80103187:	83 c0 01             	add    $0x1,%eax
8010318a:	01 f2                	add    %esi,%edx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
8010318c:	39 c8                	cmp    %ecx,%eax
8010318e:	75 f4                	jne    80103184 <mpinit+0xa4>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80103190:	84 d2                	test   %dl,%dl
80103192:	75 a5                	jne    80103139 <mpinit+0x59>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80103194:	8b 43 24             	mov    0x24(%ebx),%eax
80103197:	a3 9c 26 11 80       	mov    %eax,0x8011269c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010319c:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
801031a0:	8d 43 2c             	lea    0x2c(%ebx),%eax
801031a3:	8d 14 13             	lea    (%ebx,%edx,1),%edx
801031a6:	bb 01 00 00 00       	mov    $0x1,%ebx
801031ab:	90                   	nop
801031ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801031b0:	39 d0                	cmp    %edx,%eax
801031b2:	73 4b                	jae    801031ff <mpinit+0x11f>
801031b4:	0f b6 08             	movzbl (%eax),%ecx
    switch(*p){
801031b7:	80 f9 04             	cmp    $0x4,%cl
801031ba:	76 07                	jbe    801031c3 <mpinit+0xe3>

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801031bc:	31 db                	xor    %ebx,%ebx
    switch(*p){
801031be:	80 f9 04             	cmp    $0x4,%cl
801031c1:	77 f9                	ja     801031bc <mpinit+0xdc>
801031c3:	0f b6 c9             	movzbl %cl,%ecx
801031c6:	ff 24 8d 8c 73 10 80 	jmp    *-0x7fef8c74(,%ecx,4)
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
801031cd:	ba 00 00 01 00       	mov    $0x10000,%edx
801031d2:	b8 00 00 0f 00       	mov    $0xf0000,%eax
801031d7:	e8 94 fe ff ff       	call   80103070 <mpsearch1>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801031dc:	85 c0                	test   %eax,%eax
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
801031de:	89 c7                	mov    %eax,%edi
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801031e0:	0f 85 4c ff ff ff    	jne    80103132 <mpinit+0x52>
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
801031e6:	c7 04 24 52 73 10 80 	movl   $0x80107352,(%esp)
801031ed:	e8 be d1 ff ff       	call   801003b0 <panic>
801031f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801031f8:	83 c0 08             	add    $0x8,%eax

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801031fb:	39 d0                	cmp    %edx,%eax
801031fd:	72 b5                	jb     801031b4 <mpinit+0xd4>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
801031ff:	85 db                	test   %ebx,%ebx
80103201:	74 6f                	je     80103272 <mpinit+0x192>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80103203:	80 7f 0c 00          	cmpb   $0x0,0xc(%edi)
80103207:	74 12                	je     8010321b <mpinit+0x13b>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103209:	ba 22 00 00 00       	mov    $0x22,%edx
8010320e:	b8 70 00 00 00       	mov    $0x70,%eax
80103213:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103214:	b2 23                	mov    $0x23,%dl
80103216:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103217:	83 c8 01             	or     $0x1,%eax
8010321a:	ee                   	out    %al,(%dx)
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
8010321b:	83 c4 2c             	add    $0x2c,%esp
8010321e:	5b                   	pop    %ebx
8010321f:	5e                   	pop    %esi
80103220:	5f                   	pop    %edi
80103221:	5d                   	pop    %ebp
80103222:	c3                   	ret    
80103223:	90                   	nop
80103224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80103228:	8b 0d 20 2d 11 80    	mov    0x80112d20,%ecx
8010322e:	83 f9 07             	cmp    $0x7,%ecx
80103231:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80103234:	7f 1c                	jg     80103252 <mpinit+0x172>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103236:	69 f1 b0 00 00 00    	imul   $0xb0,%ecx,%esi
8010323c:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
80103240:	88 8e a0 27 11 80    	mov    %cl,-0x7feed860(%esi)
        ncpu++;
80103246:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103249:	83 c1 01             	add    $0x1,%ecx
8010324c:	89 0d 20 2d 11 80    	mov    %ecx,0x80112d20
      }
      p += sizeof(struct mpproc);
80103252:	83 c0 14             	add    $0x14,%eax
      continue;
80103255:	e9 56 ff ff ff       	jmp    801031b0 <mpinit+0xd0>
8010325a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80103260:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103264:	83 c0 08             	add    $0x8,%eax
      }
      p += sizeof(struct mpproc);
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80103267:	88 0d 80 27 11 80    	mov    %cl,0x80112780
      p += sizeof(struct mpioapic);
      continue;
8010326d:	e9 3e ff ff ff       	jmp    801031b0 <mpinit+0xd0>
      ismp = 0;
      break;
    }
  }
  if(!ismp)
    panic("Didn't find a suitable machine");
80103272:	c7 04 24 6c 73 10 80 	movl   $0x8010736c,(%esp)
80103279:	e8 32 d1 ff ff       	call   801003b0 <panic>
	...

80103280 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103280:	55                   	push   %ebp
80103281:	ba 21 00 00 00       	mov    $0x21,%edx
80103286:	89 e5                	mov    %esp,%ebp
80103288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010328d:	ee                   	out    %al,(%dx)
8010328e:	b2 a1                	mov    $0xa1,%dl
80103290:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103291:	5d                   	pop    %ebp
80103292:	c3                   	ret    
	...

801032a0 <piperead>:
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
{
801032a0:	55                   	push   %ebp
801032a1:	89 e5                	mov    %esp,%ebp
801032a3:	57                   	push   %edi
801032a4:	56                   	push   %esi
801032a5:	53                   	push   %ebx
801032a6:	83 ec 1c             	sub    $0x1c,%esp
801032a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801032ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
801032af:	89 1c 24             	mov    %ebx,(%esp)
801032b2:	e8 19 11 00 00       	call   801043d0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801032b7:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
801032bd:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
801032c3:	75 5b                	jne    80103320 <piperead+0x80>
801032c5:	8b 8b 40 02 00 00    	mov    0x240(%ebx),%ecx
801032cb:	85 c9                	test   %ecx,%ecx
801032cd:	74 51                	je     80103320 <piperead+0x80>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801032cf:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
801032d5:	eb 25                	jmp    801032fc <piperead+0x5c>
801032d7:	90                   	nop
801032d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801032dc:	89 34 24             	mov    %esi,(%esp)
801032df:	e8 8c 0a 00 00       	call   80103d70 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801032e4:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
801032ea:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
801032f0:	75 2e                	jne    80103320 <piperead+0x80>
801032f2:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
801032f8:	85 c0                	test   %eax,%eax
801032fa:	74 24                	je     80103320 <piperead+0x80>
    if(myproc()->killed){
801032fc:	e8 0f 08 00 00       	call   80103b10 <myproc>
80103301:	8b 50 24             	mov    0x24(%eax),%edx
80103304:	85 d2                	test   %edx,%edx
80103306:	74 d0                	je     801032d8 <piperead+0x38>
      release(&p->lock);
80103308:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010330d:	89 1c 24             	mov    %ebx,(%esp)
80103310:	e8 6b 10 00 00       	call   80104380 <release>
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80103315:	83 c4 1c             	add    $0x1c,%esp
80103318:	89 f0                	mov    %esi,%eax
8010331a:	5b                   	pop    %ebx
8010331b:	5e                   	pop    %esi
8010331c:	5f                   	pop    %edi
8010331d:	5d                   	pop    %ebp
8010331e:	c3                   	ret    
8010331f:	90                   	nop
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103320:	85 ff                	test   %edi,%edi
80103322:	7e 5e                	jle    80103382 <piperead+0xe2>
    if(p->nread == p->nwrite)
80103324:	31 f6                	xor    %esi,%esi
80103326:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
8010332c:	75 12                	jne    80103340 <piperead+0xa0>
8010332e:	66 90                	xchg   %ax,%ax
80103330:	eb 50                	jmp    80103382 <piperead+0xe2>
80103332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103338:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
8010333e:	74 22                	je     80103362 <piperead+0xc2>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103340:	89 d0                	mov    %edx,%eax
80103342:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103345:	83 c2 01             	add    $0x1,%edx
80103348:	25 ff 01 00 00       	and    $0x1ff,%eax
8010334d:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103352:	88 04 31             	mov    %al,(%ecx,%esi,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103355:	83 c6 01             	add    $0x1,%esi
80103358:	39 f7                	cmp    %esi,%edi
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010335a:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103360:	7f d6                	jg     80103338 <piperead+0x98>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103362:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103368:	89 04 24             	mov    %eax,(%esp)
8010336b:	e8 f0 03 00 00       	call   80103760 <wakeup>
  release(&p->lock);
80103370:	89 1c 24             	mov    %ebx,(%esp)
80103373:	e8 08 10 00 00       	call   80104380 <release>
  return i;
}
80103378:	83 c4 1c             	add    $0x1c,%esp
8010337b:	89 f0                	mov    %esi,%eax
8010337d:	5b                   	pop    %ebx
8010337e:	5e                   	pop    %esi
8010337f:	5f                   	pop    %edi
80103380:	5d                   	pop    %ebp
80103381:	c3                   	ret    
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103382:	31 f6                	xor    %esi,%esi
80103384:	eb dc                	jmp    80103362 <piperead+0xc2>
80103386:	8d 76 00             	lea    0x0(%esi),%esi
80103389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103390 <pipewrite>:
}

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103390:	55                   	push   %ebp
80103391:	89 e5                	mov    %esp,%ebp
80103393:	57                   	push   %edi
80103394:	56                   	push   %esi
80103395:	53                   	push   %ebx
80103396:	83 ec 3c             	sub    $0x3c,%esp
80103399:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010339c:	89 1c 24             	mov    %ebx,(%esp)
8010339f:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
801033a5:	e8 26 10 00 00       	call   801043d0 <acquire>
  for(i = 0; i < n; i++){
801033aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
801033ad:	85 c9                	test   %ecx,%ecx
801033af:	0f 8e 8c 00 00 00    	jle    80103441 <pipewrite+0xb1>
801033b5:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801033bb:	8d bb 38 02 00 00    	lea    0x238(%ebx),%edi
801033c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801033c8:	eb 36                	jmp    80103400 <pipewrite+0x70>
801033ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801033d0:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
801033d6:	85 d2                	test   %edx,%edx
801033d8:	74 7e                	je     80103458 <pipewrite+0xc8>
801033da:	e8 31 07 00 00       	call   80103b10 <myproc>
801033df:	8b 40 24             	mov    0x24(%eax),%eax
801033e2:	85 c0                	test   %eax,%eax
801033e4:	75 72                	jne    80103458 <pipewrite+0xc8>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801033e6:	89 34 24             	mov    %esi,(%esp)
801033e9:	e8 72 03 00 00       	call   80103760 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801033ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801033f2:	89 3c 24             	mov    %edi,(%esp)
801033f5:	e8 76 09 00 00       	call   80103d70 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801033fa:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103400:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
80103406:	81 c2 00 02 00 00    	add    $0x200,%edx
8010340c:	39 d0                	cmp    %edx,%eax
8010340e:	74 c0                	je     801033d0 <pipewrite+0x40>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103410:	89 c2                	mov    %eax,%edx
80103412:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103415:	83 c0 01             	add    $0x1,%eax
80103418:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010341e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80103421:	8b 55 0c             	mov    0xc(%ebp),%edx
80103424:	0f b6 0c 0a          	movzbl (%edx,%ecx,1),%ecx
80103428:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010342b:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
8010342f:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103435:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103439:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010343c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
8010343f:	7f bf                	jg     80103400 <pipewrite+0x70>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103441:	89 34 24             	mov    %esi,(%esp)
80103444:	e8 17 03 00 00       	call   80103760 <wakeup>
  release(&p->lock);
80103449:	89 1c 24             	mov    %ebx,(%esp)
8010344c:	e8 2f 0f 00 00       	call   80104380 <release>
  return n;
80103451:	eb 14                	jmp    80103467 <pipewrite+0xd7>
80103453:	90                   	nop
80103454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
80103458:	89 1c 24             	mov    %ebx,(%esp)
8010345b:	e8 20 0f 00 00       	call   80104380 <release>
80103460:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103467:	8b 45 10             	mov    0x10(%ebp),%eax
8010346a:	83 c4 3c             	add    $0x3c,%esp
8010346d:	5b                   	pop    %ebx
8010346e:	5e                   	pop    %esi
8010346f:	5f                   	pop    %edi
80103470:	5d                   	pop    %ebp
80103471:	c3                   	ret    
80103472:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103480 <pipeclose>:
  return -1;
}

void
pipeclose(struct pipe *p, int writable)
{
80103480:	55                   	push   %ebp
80103481:	89 e5                	mov    %esp,%ebp
80103483:	83 ec 18             	sub    $0x18,%esp
80103486:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80103489:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010348c:	89 75 fc             	mov    %esi,-0x4(%ebp)
8010348f:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
80103492:	89 1c 24             	mov    %ebx,(%esp)
80103495:	e8 36 0f 00 00       	call   801043d0 <acquire>
  if(writable){
8010349a:	85 f6                	test   %esi,%esi
8010349c:	74 42                	je     801034e0 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
8010349e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
801034a4:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
801034ab:	00 00 00 
    wakeup(&p->nread);
801034ae:	89 04 24             	mov    %eax,(%esp)
801034b1:	e8 aa 02 00 00       	call   80103760 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
801034b6:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
801034bc:	85 c0                	test   %eax,%eax
801034be:	75 0a                	jne    801034ca <pipeclose+0x4a>
801034c0:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
801034c6:	85 f6                	test   %esi,%esi
801034c8:	74 36                	je     80103500 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
801034ca:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801034cd:	8b 75 fc             	mov    -0x4(%ebp),%esi
801034d0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
801034d3:	89 ec                	mov    %ebp,%esp
801034d5:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
801034d6:	e9 a5 0e 00 00       	jmp    80104380 <release>
801034db:	90                   	nop
801034dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
801034e0:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
801034e6:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801034ed:	00 00 00 
    wakeup(&p->nwrite);
801034f0:	89 04 24             	mov    %eax,(%esp)
801034f3:	e8 68 02 00 00       	call   80103760 <wakeup>
801034f8:	eb bc                	jmp    801034b6 <pipeclose+0x36>
801034fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
80103500:	89 1c 24             	mov    %ebx,(%esp)
80103503:	e8 78 0e 00 00       	call   80104380 <release>
    kfree((char*)p);
  } else
    release(&p->lock);
}
80103508:	8b 75 fc             	mov    -0x4(%ebp),%esi
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
8010350b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
8010350e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
80103511:	89 ec                	mov    %ebp,%esp
80103513:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
80103514:	e9 27 ef ff ff       	jmp    80102440 <kfree>
80103519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103520 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	57                   	push   %edi
80103524:	56                   	push   %esi
80103525:	53                   	push   %ebx
80103526:	83 ec 1c             	sub    $0x1c,%esp
80103529:	8b 75 08             	mov    0x8(%ebp),%esi
8010352c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010352f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103535:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010353b:	e8 90 da ff ff       	call   80100fd0 <filealloc>
80103540:	85 c0                	test   %eax,%eax
80103542:	89 06                	mov    %eax,(%esi)
80103544:	0f 84 9c 00 00 00    	je     801035e6 <pipealloc+0xc6>
8010354a:	e8 81 da ff ff       	call   80100fd0 <filealloc>
8010354f:	85 c0                	test   %eax,%eax
80103551:	89 03                	mov    %eax,(%ebx)
80103553:	0f 84 7f 00 00 00    	je     801035d8 <pipealloc+0xb8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103559:	e8 92 ee ff ff       	call   801023f0 <kalloc>
8010355e:	85 c0                	test   %eax,%eax
80103560:	89 c7                	mov    %eax,%edi
80103562:	74 74                	je     801035d8 <pipealloc+0xb8>
    goto bad;
  p->readopen = 1;
80103564:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010356b:	00 00 00 
  p->writeopen = 1;
8010356e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103575:	00 00 00 
  p->nwrite = 0;
80103578:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010357f:	00 00 00 
  p->nread = 0;
80103582:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103589:	00 00 00 
  initlock(&p->lock, "pipe");
8010358c:	89 04 24             	mov    %eax,(%esp)
8010358f:	c7 44 24 04 a0 73 10 	movl   $0x801073a0,0x4(%esp)
80103596:	80 
80103597:	e8 64 0c 00 00       	call   80104200 <initlock>
  (*f0)->type = FD_PIPE;
8010359c:	8b 06                	mov    (%esi),%eax
8010359e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801035a4:	8b 06                	mov    (%esi),%eax
801035a6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801035aa:	8b 06                	mov    (%esi),%eax
801035ac:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801035b0:	8b 06                	mov    (%esi),%eax
801035b2:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801035b5:	8b 03                	mov    (%ebx),%eax
801035b7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801035bd:	8b 03                	mov    (%ebx),%eax
801035bf:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801035c3:	8b 03                	mov    (%ebx),%eax
801035c5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801035c9:	8b 03                	mov    (%ebx),%eax
801035cb:	89 78 0c             	mov    %edi,0xc(%eax)
801035ce:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801035d0:	83 c4 1c             	add    $0x1c,%esp
801035d3:	5b                   	pop    %ebx
801035d4:	5e                   	pop    %esi
801035d5:	5f                   	pop    %edi
801035d6:	5d                   	pop    %ebp
801035d7:	c3                   	ret    

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
801035d8:	8b 06                	mov    (%esi),%eax
801035da:	85 c0                	test   %eax,%eax
801035dc:	74 08                	je     801035e6 <pipealloc+0xc6>
    fileclose(*f0);
801035de:	89 04 24             	mov    %eax,(%esp)
801035e1:	e8 6a da ff ff       	call   80101050 <fileclose>
  if(*f1)
801035e6:	8b 13                	mov    (%ebx),%edx
801035e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035ed:	85 d2                	test   %edx,%edx
801035ef:	74 df                	je     801035d0 <pipealloc+0xb0>
    fileclose(*f1);
801035f1:	89 14 24             	mov    %edx,(%esp)
801035f4:	e8 57 da ff ff       	call   80101050 <fileclose>
801035f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035fe:	eb d0                	jmp    801035d0 <pipealloc+0xb0>

80103600 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103600:	55                   	push   %ebp
80103601:	89 e5                	mov    %esp,%ebp
80103603:	57                   	push   %edi
80103604:	56                   	push   %esi
80103605:	53                   	push   %ebx
//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
80103606:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
{
8010360b:	83 ec 4c             	sub    $0x4c,%esp
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010360e:	8d 7d c0             	lea    -0x40(%ebp),%edi
80103611:	eb 4b                	jmp    8010365e <procdump+0x5e>
80103613:	90                   	nop
80103614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103618:	8b 04 85 b0 74 10 80 	mov    -0x7fef8b50(,%eax,4),%eax
8010361f:	85 c0                	test   %eax,%eax
80103621:	74 47                	je     8010366a <procdump+0x6a>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
80103623:	89 44 24 08          	mov    %eax,0x8(%esp)
80103627:	8b 43 10             	mov    0x10(%ebx),%eax
8010362a:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010362d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80103631:	c7 04 24 a9 73 10 80 	movl   $0x801073a9,(%esp)
80103638:	89 44 24 04          	mov    %eax,0x4(%esp)
8010363c:	e8 0f d2 ff ff       	call   80100850 <cprintf>
    if(p->state == SLEEPING){
80103641:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103645:	74 31                	je     80103678 <procdump+0x78>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103647:	c7 04 24 ad 77 10 80 	movl   $0x801077ad,(%esp)
8010364e:	e8 fd d1 ff ff       	call   80100850 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103653:	83 c3 7c             	add    $0x7c,%ebx
80103656:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
8010365c:	74 5a                	je     801036b8 <procdump+0xb8>
    if(p->state == UNUSED)
8010365e:	8b 43 0c             	mov    0xc(%ebx),%eax
80103661:	85 c0                	test   %eax,%eax
80103663:	74 ee                	je     80103653 <procdump+0x53>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103665:	83 f8 05             	cmp    $0x5,%eax
80103668:	76 ae                	jbe    80103618 <procdump+0x18>
8010366a:	b8 a5 73 10 80       	mov    $0x801073a5,%eax
8010366f:	eb b2                	jmp    80103623 <procdump+0x23>
80103671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103678:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010367b:	31 f6                	xor    %esi,%esi
8010367d:	89 7c 24 04          	mov    %edi,0x4(%esp)
80103681:	8b 40 0c             	mov    0xc(%eax),%eax
80103684:	83 c0 08             	add    $0x8,%eax
80103687:	89 04 24             	mov    %eax,(%esp)
8010368a:	e8 91 0b 00 00       	call   80104220 <getcallerpcs>
8010368f:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
80103690:	8b 04 b7             	mov    (%edi,%esi,4),%eax
80103693:	85 c0                	test   %eax,%eax
80103695:	74 b0                	je     80103647 <procdump+0x47>
80103697:	83 c6 01             	add    $0x1,%esi
        cprintf(" %p", pc[i]);
8010369a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010369e:	c7 04 24 a9 6e 10 80 	movl   $0x80106ea9,(%esp)
801036a5:	e8 a6 d1 ff ff       	call   80100850 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801036aa:	83 fe 0a             	cmp    $0xa,%esi
801036ad:	75 e1                	jne    80103690 <procdump+0x90>
801036af:	eb 96                	jmp    80103647 <procdump+0x47>
801036b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801036b8:	83 c4 4c             	add    $0x4c,%esp
801036bb:	5b                   	pop    %ebx
801036bc:	5e                   	pop    %esi
801036bd:	5f                   	pop    %edi
801036be:	5d                   	pop    %ebp
801036bf:	90                   	nop
801036c0:	c3                   	ret    
801036c1:	eb 0d                	jmp    801036d0 <kill>
801036c3:	90                   	nop
801036c4:	90                   	nop
801036c5:	90                   	nop
801036c6:	90                   	nop
801036c7:	90                   	nop
801036c8:	90                   	nop
801036c9:	90                   	nop
801036ca:	90                   	nop
801036cb:	90                   	nop
801036cc:	90                   	nop
801036cd:	90                   	nop
801036ce:	90                   	nop
801036cf:	90                   	nop

801036d0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801036d0:	55                   	push   %ebp
801036d1:	89 e5                	mov    %esp,%ebp
801036d3:	53                   	push   %ebx
801036d4:	83 ec 14             	sub    $0x14,%esp
801036d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801036da:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801036e1:	e8 ea 0c 00 00       	call   801043d0 <acquire>

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
801036e6:	b8 f0 2d 11 80       	mov    $0x80112df0,%eax
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
801036eb:	39 1d 84 2d 11 80    	cmp    %ebx,0x80112d84
801036f1:	75 0f                	jne    80103702 <kill+0x32>
801036f3:	eb 5a                	jmp    8010374f <kill+0x7f>
801036f5:	8d 76 00             	lea    0x0(%esi),%esi
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036f8:	83 c0 7c             	add    $0x7c,%eax
801036fb:	3d 74 4c 11 80       	cmp    $0x80114c74,%eax
80103700:	74 36                	je     80103738 <kill+0x68>
    if(p->pid == pid){
80103702:	39 58 10             	cmp    %ebx,0x10(%eax)
80103705:	75 f1                	jne    801036f8 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103707:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
8010370b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103712:	74 14                	je     80103728 <kill+0x58>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103714:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
8010371b:	e8 60 0c 00 00       	call   80104380 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80103720:	83 c4 14             	add    $0x14,%esp
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
80103723:	31 c0                	xor    %eax,%eax
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80103725:	5b                   	pop    %ebx
80103726:	5d                   	pop    %ebp
80103727:	c3                   	ret    
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
80103728:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
8010372f:	eb e3                	jmp    80103714 <kill+0x44>
80103731:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80103738:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
8010373f:	e8 3c 0c 00 00       	call   80104380 <release>
  return -1;
}
80103744:	83 c4 14             	add    $0x14,%esp
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80103747:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
8010374c:	5b                   	pop    %ebx
8010374d:	5d                   	pop    %ebp
8010374e:	c3                   	ret    
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
8010374f:	b8 74 2d 11 80       	mov    $0x80112d74,%eax
80103754:	eb b1                	jmp    80103707 <kill+0x37>
80103756:	8d 76 00             	lea    0x0(%esi),%esi
80103759:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103760 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103760:	55                   	push   %ebp
80103761:	89 e5                	mov    %esp,%ebp
80103763:	53                   	push   %ebx
80103764:	83 ec 14             	sub    $0x14,%esp
80103767:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010376a:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103771:	e8 5a 0c 00 00       	call   801043d0 <acquire>
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
80103776:	b8 74 2d 11 80       	mov    $0x80112d74,%eax
8010377b:	eb 0d                	jmp    8010378a <wakeup+0x2a>
8010377d:	8d 76 00             	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103780:	83 c0 7c             	add    $0x7c,%eax
80103783:	3d 74 4c 11 80       	cmp    $0x80114c74,%eax
80103788:	74 1e                	je     801037a8 <wakeup+0x48>
    if(p->state == SLEEPING && p->chan == chan)
8010378a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010378e:	75 f0                	jne    80103780 <wakeup+0x20>
80103790:	3b 58 20             	cmp    0x20(%eax),%ebx
80103793:	75 eb                	jne    80103780 <wakeup+0x20>
      p->state = RUNNABLE;
80103795:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010379c:	83 c0 7c             	add    $0x7c,%eax
8010379f:	3d 74 4c 11 80       	cmp    $0x80114c74,%eax
801037a4:	75 e4                	jne    8010378a <wakeup+0x2a>
801037a6:	66 90                	xchg   %ax,%ax
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
801037a8:	c7 45 08 40 2d 11 80 	movl   $0x80112d40,0x8(%ebp)
}
801037af:	83 c4 14             	add    $0x14,%esp
801037b2:	5b                   	pop    %ebx
801037b3:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
801037b4:	e9 c7 0b 00 00       	jmp    80104380 <release>
801037b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801037c0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801037c0:	55                   	push   %ebp
801037c1:	89 e5                	mov    %esp,%ebp
801037c3:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801037c6:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801037cd:	e8 ae 0b 00 00       	call   80104380 <release>

  if (first) {
801037d2:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801037d7:	85 c0                	test   %eax,%eax
801037d9:	75 05                	jne    801037e0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801037db:	c9                   	leave  
801037dc:	c3                   	ret    
801037dd:	8d 76 00             	lea    0x0(%esi),%esi

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801037e0:	c7 05 04 a0 10 80 00 	movl   $0x0,0x8010a004
801037e7:	00 00 00 
    iinit(ROOTDEV);
801037ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801037f1:	e8 aa e7 ff ff       	call   80101fa0 <iinit>
    initlog(ROOTDEV);
801037f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801037fd:	e8 2e f6 ff ff       	call   80102e30 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103802:	c9                   	leave  
80103803:	c3                   	ret    
80103804:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010380a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103810 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103810:	55                   	push   %ebp
80103811:	89 e5                	mov    %esp,%ebp
80103813:	53                   	push   %ebx
80103814:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103817:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
8010381e:	e8 ad 0b 00 00       	call   801043d0 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
80103823:	8b 0d 80 2d 11 80    	mov    0x80112d80,%ecx
80103829:	85 c9                	test   %ecx,%ecx
8010382b:	0f 84 a5 00 00 00    	je     801038d6 <allocproc+0xc6>
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
80103831:	bb f0 2d 11 80       	mov    $0x80112df0,%ebx
80103836:	eb 0b                	jmp    80103843 <allocproc+0x33>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103838:	83 c3 7c             	add    $0x7c,%ebx
8010383b:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103841:	74 7d                	je     801038c0 <allocproc+0xb0>
    if(p->state == UNUSED)
80103843:	8b 53 0c             	mov    0xc(%ebx),%edx
80103846:	85 d2                	test   %edx,%edx
80103848:	75 ee                	jne    80103838 <allocproc+0x28>

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010384a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103851:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80103856:	89 43 10             	mov    %eax,0x10(%ebx)
80103859:	83 c0 01             	add    $0x1,%eax
8010385c:	a3 00 a0 10 80       	mov    %eax,0x8010a000

  release(&ptable.lock);
80103861:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103868:	e8 13 0b 00 00       	call   80104380 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010386d:	e8 7e eb ff ff       	call   801023f0 <kalloc>
80103872:	85 c0                	test   %eax,%eax
80103874:	89 43 08             	mov    %eax,0x8(%ebx)
80103877:	74 67                	je     801038e0 <allocproc+0xd0>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103879:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010387f:	89 53 18             	mov    %edx,0x18(%ebx)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
80103882:	c7 80 b0 0f 00 00 c4 	movl   $0x801055c4,0xfb0(%eax)
80103889:	55 10 80 

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
8010388c:	05 9c 0f 00 00       	add    $0xf9c,%eax
80103891:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103894:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010389b:	00 
8010389c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801038a3:	00 
801038a4:	89 04 24             	mov    %eax,(%esp)
801038a7:	e8 94 0b 00 00       	call   80104440 <memset>
  p->context->eip = (uint)forkret;
801038ac:	8b 43 1c             	mov    0x1c(%ebx),%eax
801038af:	c7 40 10 c0 37 10 80 	movl   $0x801037c0,0x10(%eax)

  return p;
}
801038b6:	89 d8                	mov    %ebx,%eax
801038b8:	83 c4 14             	add    $0x14,%esp
801038bb:	5b                   	pop    %ebx
801038bc:	5d                   	pop    %ebp
801038bd:	c3                   	ret    
801038be:	66 90                	xchg   %ax,%ax

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801038c0:	31 db                	xor    %ebx,%ebx
801038c2:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801038c9:	e8 b2 0a 00 00       	call   80104380 <release>
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
801038ce:	89 d8                	mov    %ebx,%eax
801038d0:	83 c4 14             	add    $0x14,%esp
801038d3:	5b                   	pop    %ebx
801038d4:	5d                   	pop    %ebp
801038d5:	c3                   	ret    
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;
801038d6:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
801038db:	e9 6a ff ff ff       	jmp    8010384a <allocproc+0x3a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801038e0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
801038e7:	31 db                	xor    %ebx,%ebx
    return 0;
801038e9:	eb cb                	jmp    801038b6 <allocproc+0xa6>
801038eb:	90                   	nop
801038ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801038f0 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801038f0:	55                   	push   %ebp
801038f1:	89 e5                	mov    %esp,%ebp
801038f3:	53                   	push   %ebx
801038f4:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801038f7:	e8 14 ff ff ff       	call   80103810 <allocproc>
801038fc:	89 c3                	mov    %eax,%ebx
  
  initproc = p;
801038fe:	a3 c0 a5 10 80       	mov    %eax,0x8010a5c0
  if((p->pgdir = setupkvm()) == 0)
80103903:	e8 f8 2f 00 00       	call   80106900 <setupkvm>
80103908:	85 c0                	test   %eax,%eax
8010390a:	89 43 04             	mov    %eax,0x4(%ebx)
8010390d:	0f 84 ce 00 00 00    	je     801039e1 <userinit+0xf1>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103913:	89 04 24             	mov    %eax,(%esp)
80103916:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
8010391d:	00 
8010391e:	c7 44 24 04 60 a4 10 	movl   $0x8010a460,0x4(%esp)
80103925:	80 
80103926:	e8 15 2e 00 00       	call   80106740 <inituvm>
  p->sz = PGSIZE;
8010392b:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103931:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80103938:	00 
80103939:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103940:	00 
80103941:	8b 43 18             	mov    0x18(%ebx),%eax
80103944:	89 04 24             	mov    %eax,(%esp)
80103947:	e8 f4 0a 00 00       	call   80104440 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010394c:	8b 43 18             	mov    0x18(%ebx),%eax
8010394f:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103955:	8b 43 18             	mov    0x18(%ebx),%eax
80103958:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010395e:	8b 43 18             	mov    0x18(%ebx),%eax
80103961:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103965:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103969:	8b 43 18             	mov    0x18(%ebx),%eax
8010396c:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103970:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103974:	8b 43 18             	mov    0x18(%ebx),%eax
80103977:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010397e:	8b 43 18             	mov    0x18(%ebx),%eax
80103981:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103988:	8b 43 18             	mov    0x18(%ebx),%eax
8010398b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103992:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103995:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010399c:	00 
8010399d:	c7 44 24 04 cb 73 10 	movl   $0x801073cb,0x4(%esp)
801039a4:	80 
801039a5:	89 04 24             	mov    %eax,(%esp)
801039a8:	e8 73 0c 00 00       	call   80104620 <safestrcpy>
  p->cwd = namei("/");
801039ad:	c7 04 24 d4 73 10 80 	movl   $0x801073d4,(%esp)
801039b4:	e8 c7 e5 ff ff       	call   80101f80 <namei>
801039b9:	89 43 68             	mov    %eax,0x68(%ebx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801039bc:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801039c3:	e8 08 0a 00 00       	call   801043d0 <acquire>

  p->state = RUNNABLE;
801039c8:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)

  release(&ptable.lock);
801039cf:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801039d6:	e8 a5 09 00 00       	call   80104380 <release>
}
801039db:	83 c4 14             	add    $0x14,%esp
801039de:	5b                   	pop    %ebx
801039df:	5d                   	pop    %ebp
801039e0:	c3                   	ret    

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
801039e1:	c7 04 24 b2 73 10 80 	movl   $0x801073b2,(%esp)
801039e8:	e8 c3 c9 ff ff       	call   801003b0 <panic>
801039ed:	8d 76 00             	lea    0x0(%esi),%esi

801039f0 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039f0:	55                   	push   %ebp
801039f1:	89 e5                	mov    %esp,%ebp
801039f3:	57                   	push   %edi
801039f4:	56                   	push   %esi
801039f5:	53                   	push   %ebx
801039f6:	83 ec 1c             	sub    $0x1c,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801039f9:	9c                   	pushf  
801039fa:	58                   	pop    %eax
  int apicid, i;
  
  if(readeflags()&FL_IF)
801039fb:	f6 c4 02             	test   $0x2,%ah
801039fe:	75 5e                	jne    80103a5e <mycpu+0x6e>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
80103a00:	e8 db ed ff ff       	call   801027e0 <lapicid>
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103a05:	8b 35 20 2d 11 80    	mov    0x80112d20,%esi
80103a0b:	85 f6                	test   %esi,%esi
80103a0d:	7e 43                	jle    80103a52 <mycpu+0x62>
    if (cpus[i].apicid == apicid)
80103a0f:	0f b6 3d a0 27 11 80 	movzbl 0x801127a0,%edi
80103a16:	31 d2                	xor    %edx,%edx
80103a18:	b9 50 28 11 80       	mov    $0x80112850,%ecx
80103a1d:	bb a0 27 11 80       	mov    $0x801127a0,%ebx
80103a22:	39 f8                	cmp    %edi,%eax
80103a24:	74 22                	je     80103a48 <mycpu+0x58>
80103a26:	66 90                	xchg   %ax,%ax
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103a28:	83 c2 01             	add    $0x1,%edx
80103a2b:	39 f2                	cmp    %esi,%edx
80103a2d:	7d 23                	jge    80103a52 <mycpu+0x62>
    if (cpus[i].apicid == apicid)
80103a2f:	0f b6 19             	movzbl (%ecx),%ebx
80103a32:	81 c1 b0 00 00 00    	add    $0xb0,%ecx
80103a38:	39 d8                	cmp    %ebx,%eax
80103a3a:	75 ec                	jne    80103a28 <mycpu+0x38>
80103a3c:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103a42:	8d 9a a0 27 11 80    	lea    -0x7feed860(%edx),%ebx
      return &cpus[i];
  }
  panic("unknown apicid\n");
}
80103a48:	83 c4 1c             	add    $0x1c,%esp
80103a4b:	89 d8                	mov    %ebx,%eax
80103a4d:	5b                   	pop    %ebx
80103a4e:	5e                   	pop    %esi
80103a4f:	5f                   	pop    %edi
80103a50:	5d                   	pop    %ebp
80103a51:	c3                   	ret    
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80103a52:	c7 04 24 d6 73 10 80 	movl   $0x801073d6,(%esp)
80103a59:	e8 52 c9 ff ff       	call   801003b0 <panic>
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
80103a5e:	c7 04 24 88 74 10 80 	movl   $0x80107488,(%esp)
80103a65:	e8 46 c9 ff ff       	call   801003b0 <panic>
80103a6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103a70 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80103a70:	55                   	push   %ebp
80103a71:	89 e5                	mov    %esp,%ebp
80103a73:	57                   	push   %edi
80103a74:	56                   	push   %esi
80103a75:	53                   	push   %ebx
80103a76:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80103a79:	e8 72 ff ff ff       	call   801039f0 <mycpu>
80103a7e:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103a80:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103a87:	00 00 00 
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
80103a8a:	8d 78 04             	lea    0x4(%eax),%edi
80103a8d:	8d 76 00             	lea    0x0(%esi),%esi
}

static inline void
sti(void)
{
  asm volatile("sti");
80103a90:	fb                   	sti    
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
80103a91:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80103a96:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103a9d:	e8 2e 09 00 00       	call   801043d0 <acquire>
80103aa2:	eb 0f                	jmp    80103ab3 <scheduler+0x43>
80103aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103aa8:	83 c3 7c             	add    $0x7c,%ebx
80103aab:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103ab1:	74 45                	je     80103af8 <scheduler+0x88>
      if(p->state != RUNNABLE)
80103ab3:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103ab7:	75 ef                	jne    80103aa8 <scheduler+0x38>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80103ab9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103abf:	89 1c 24             	mov    %ebx,(%esp)
80103ac2:	e8 a9 31 00 00       	call   80106c70 <switchuvm>
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
80103ac7:	8b 43 1c             	mov    0x1c(%ebx),%eax
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;
80103aca:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ad1:	83 c3 7c             	add    $0x7c,%ebx
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
80103ad4:	89 3c 24             	mov    %edi,(%esp)
80103ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103adb:	e8 9c 0b 00 00       	call   8010467c <swtch>
      switchkvm();
80103ae0:	e8 1b 2a 00 00       	call   80106500 <switchkvm>
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ae5:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80103aeb:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103af2:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103af5:	75 bc                	jne    80103ab3 <scheduler+0x43>
80103af7:	90                   	nop

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80103af8:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103aff:	e8 7c 08 00 00       	call   80104380 <release>

  }
80103b04:	eb 8a                	jmp    80103a90 <scheduler+0x20>
80103b06:	8d 76 00             	lea    0x0(%esi),%esi
80103b09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103b10 <myproc>:
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103b10:	55                   	push   %ebp
80103b11:	89 e5                	mov    %esp,%ebp
80103b13:	53                   	push   %ebx
80103b14:	83 ec 04             	sub    $0x4,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103b17:	e8 d4 07 00 00       	call   801042f0 <pushcli>
  c = mycpu();
80103b1c:	e8 cf fe ff ff       	call   801039f0 <mycpu>
  p = c->proc;
80103b21:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103b27:	e8 54 07 00 00       	call   80104280 <popcli>
  return p;
}
80103b2c:	83 c4 04             	add    $0x4,%esp
80103b2f:	89 d8                	mov    %ebx,%eax
80103b31:	5b                   	pop    %ebx
80103b32:	5d                   	pop    %ebp
80103b33:	c3                   	ret    
80103b34:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103b3a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103b40 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103b40:	55                   	push   %ebp
80103b41:	89 e5                	mov    %esp,%ebp
80103b43:	57                   	push   %edi
80103b44:	56                   	push   %esi
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
80103b45:	be ff ff ff ff       	mov    $0xffffffff,%esi
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103b4a:	53                   	push   %ebx
80103b4b:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103b4e:	e8 bd ff ff ff       	call   80103b10 <myproc>
80103b53:	89 c3                	mov    %eax,%ebx

  // Allocate process.
  if((np = allocproc()) == 0){
80103b55:	e8 b6 fc ff ff       	call   80103810 <allocproc>
80103b5a:	85 c0                	test   %eax,%eax
80103b5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103b5f:	0f 84 bf 00 00 00    	je     80103c24 <fork+0xe4>
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103b65:	8b 03                	mov    (%ebx),%eax
80103b67:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b6b:	8b 43 04             	mov    0x4(%ebx),%eax
80103b6e:	89 04 24             	mov    %eax,(%esp)
80103b71:	e8 3a 2e 00 00       	call   801069b0 <copyuvm>
80103b76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b79:	85 c0                	test   %eax,%eax
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	0f 84 aa 00 00 00    	je     80103c2e <fork+0xee>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
80103b84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  np->parent = curproc;
  *np->tf = *curproc->tf;
80103b87:	b9 13 00 00 00       	mov    $0x13,%ecx
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
80103b8c:	8b 03                	mov    (%ebx),%eax
  np->parent = curproc;
80103b8e:	89 5a 14             	mov    %ebx,0x14(%edx)
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
80103b91:	89 02                	mov    %eax,(%edx)
  np->parent = curproc;
  *np->tf = *curproc->tf;
80103b93:	8b 42 18             	mov    0x18(%edx),%eax
80103b96:	8b 73 18             	mov    0x18(%ebx),%esi
80103b99:	89 c7                	mov    %eax,%edi
80103b9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103b9d:	31 f6                	xor    %esi,%esi
80103b9f:	8b 42 18             	mov    0x18(%edx),%eax
80103ba2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
80103ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
80103bb0:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103bb4:	85 c0                	test   %eax,%eax
80103bb6:	74 0f                	je     80103bc7 <fork+0x87>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103bb8:	89 04 24             	mov    %eax,(%esp)
80103bbb:	e8 c0 d3 ff ff       	call   80100f80 <filedup>
80103bc0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103bc3:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80103bc7:	83 c6 01             	add    $0x1,%esi
80103bca:	83 fe 10             	cmp    $0x10,%esi
80103bcd:	75 e1                	jne    80103bb0 <fork+0x70>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80103bcf:	8b 43 68             	mov    0x68(%ebx),%eax

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103bd2:	83 c3 6c             	add    $0x6c,%ebx
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80103bd5:	89 04 24             	mov    %eax,(%esp)
80103bd8:	e8 a3 d5 ff ff       	call   80101180 <idup>
80103bdd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103be0:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103be3:	89 d0                	mov    %edx,%eax
80103be5:	83 c0 6c             	add    $0x6c,%eax
80103be8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80103bef:	00 
80103bf0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80103bf4:	89 04 24             	mov    %eax,(%esp)
80103bf7:	e8 24 0a 00 00       	call   80104620 <safestrcpy>

  pid = np->pid;
80103bfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103bff:	8b 70 10             	mov    0x10(%eax),%esi

  acquire(&ptable.lock);
80103c02:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103c09:	e8 c2 07 00 00       	call   801043d0 <acquire>

  np->state = RUNNABLE;
80103c0e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103c11:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)

  release(&ptable.lock);
80103c18:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103c1f:	e8 5c 07 00 00       	call   80104380 <release>

  return pid;
}
80103c24:	83 c4 2c             	add    $0x2c,%esp
80103c27:	89 f0                	mov    %esi,%eax
80103c29:	5b                   	pop    %ebx
80103c2a:	5e                   	pop    %esi
80103c2b:	5f                   	pop    %edi
80103c2c:	5d                   	pop    %ebp
80103c2d:	c3                   	ret    
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
80103c2e:	8b 42 08             	mov    0x8(%edx),%eax
80103c31:	89 04 24             	mov    %eax,(%esp)
80103c34:	e8 07 e8 ff ff       	call   80102440 <kfree>
    np->kstack = 0;
80103c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c3c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103c43:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103c4a:	eb d8                	jmp    80103c24 <fork+0xe4>
80103c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103c50 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c50:	55                   	push   %ebp
80103c51:	89 e5                	mov    %esp,%ebp
80103c53:	83 ec 18             	sub    $0x18,%esp
80103c56:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80103c59:	89 75 fc             	mov    %esi,-0x4(%ebp)
80103c5c:	8b 75 08             	mov    0x8(%ebp),%esi
  uint sz;
  struct proc *curproc = myproc();
80103c5f:	e8 ac fe ff ff       	call   80103b10 <myproc>

  sz = curproc->sz;
  if(n > 0){
80103c64:	83 fe 00             	cmp    $0x0,%esi
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();
80103c67:	89 c3                	mov    %eax,%ebx

  sz = curproc->sz;
80103c69:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103c6b:	7f 1b                	jg     80103c88 <growproc+0x38>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
80103c6d:	75 39                	jne    80103ca8 <growproc+0x58>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
80103c6f:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103c71:	89 1c 24             	mov    %ebx,(%esp)
80103c74:	e8 f7 2f 00 00       	call   80106c70 <switchuvm>
80103c79:	31 c0                	xor    %eax,%eax
  return 0;
}
80103c7b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
80103c7e:	8b 75 fc             	mov    -0x4(%ebp),%esi
80103c81:	89 ec                	mov    %ebp,%esp
80103c83:	5d                   	pop    %ebp
80103c84:	c3                   	ret    
80103c85:	8d 76 00             	lea    0x0(%esi),%esi
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103c88:	01 c6                	add    %eax,%esi
80103c8a:	89 74 24 08          	mov    %esi,0x8(%esp)
80103c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c92:	8b 43 04             	mov    0x4(%ebx),%eax
80103c95:	89 04 24             	mov    %eax,(%esp)
80103c98:	e8 f3 2d 00 00       	call   80106a90 <allocuvm>
80103c9d:	85 c0                	test   %eax,%eax
80103c9f:	75 ce                	jne    80103c6f <growproc+0x1f>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
80103ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ca6:	eb d3                	jmp    80103c7b <growproc+0x2b>
  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ca8:	01 c6                	add    %eax,%esi
80103caa:	89 74 24 08          	mov    %esi,0x8(%esp)
80103cae:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cb2:	8b 43 04             	mov    0x4(%ebx),%eax
80103cb5:	89 04 24             	mov    %eax,(%esp)
80103cb8:	e8 13 2b 00 00       	call   801067d0 <deallocuvm>
80103cbd:	85 c0                	test   %eax,%eax
80103cbf:	75 ae                	jne    80103c6f <growproc+0x1f>
80103cc1:	eb de                	jmp    80103ca1 <growproc+0x51>
80103cc3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103cd0 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80103cd0:	55                   	push   %ebp
80103cd1:	89 e5                	mov    %esp,%ebp
80103cd3:	56                   	push   %esi
80103cd4:	53                   	push   %ebx
80103cd5:	83 ec 10             	sub    $0x10,%esp
  int intena;
  struct proc *p = myproc();
80103cd8:	e8 33 fe ff ff       	call   80103b10 <myproc>

  if(!holding(&ptable.lock))
80103cdd:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();
80103ce4:	89 c3                	mov    %eax,%ebx

  if(!holding(&ptable.lock))
80103ce6:	e8 45 06 00 00       	call   80104330 <holding>
80103ceb:	85 c0                	test   %eax,%eax
80103ced:	74 4f                	je     80103d3e <sched+0x6e>
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
80103cef:	e8 fc fc ff ff       	call   801039f0 <mycpu>
80103cf4:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103cfb:	75 65                	jne    80103d62 <sched+0x92>
    panic("sched locks");
  if(p->state == RUNNING)
80103cfd:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103d01:	74 53                	je     80103d56 <sched+0x86>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d03:	9c                   	pushf  
80103d04:	58                   	pop    %eax
    panic("sched running");
  if(readeflags()&FL_IF)
80103d05:	f6 c4 02             	test   $0x2,%ah
80103d08:	75 40                	jne    80103d4a <sched+0x7a>
    panic("sched interruptible");
  intena = mycpu()->intena;
80103d0a:	e8 e1 fc ff ff       	call   801039f0 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103d0f:	83 c3 1c             	add    $0x1c,%ebx
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
80103d12:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103d18:	e8 d3 fc ff ff       	call   801039f0 <mycpu>
80103d1d:	8b 40 04             	mov    0x4(%eax),%eax
80103d20:	89 1c 24             	mov    %ebx,(%esp)
80103d23:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d27:	e8 50 09 00 00       	call   8010467c <swtch>
  mycpu()->intena = intena;
80103d2c:	e8 bf fc ff ff       	call   801039f0 <mycpu>
80103d31:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103d37:	83 c4 10             	add    $0x10,%esp
80103d3a:	5b                   	pop    %ebx
80103d3b:	5e                   	pop    %esi
80103d3c:	5d                   	pop    %ebp
80103d3d:	c3                   	ret    
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
80103d3e:	c7 04 24 e6 73 10 80 	movl   $0x801073e6,(%esp)
80103d45:	e8 66 c6 ff ff       	call   801003b0 <panic>
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
80103d4a:	c7 04 24 12 74 10 80 	movl   $0x80107412,(%esp)
80103d51:	e8 5a c6 ff ff       	call   801003b0 <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
80103d56:	c7 04 24 04 74 10 80 	movl   $0x80107404,(%esp)
80103d5d:	e8 4e c6 ff ff       	call   801003b0 <panic>
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
80103d62:	c7 04 24 f8 73 10 80 	movl   $0x801073f8,(%esp)
80103d69:	e8 42 c6 ff ff       	call   801003b0 <panic>
80103d6e:	66 90                	xchg   %ax,%ax

80103d70 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80103d70:	55                   	push   %ebp
80103d71:	89 e5                	mov    %esp,%ebp
80103d73:	83 ec 28             	sub    $0x28,%esp
80103d76:	89 5d f4             	mov    %ebx,-0xc(%ebp)
80103d79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103d7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
80103d7f:	8b 75 08             	mov    0x8(%ebp),%esi
80103d82:	89 7d fc             	mov    %edi,-0x4(%ebp)
  struct proc *p = myproc();
80103d85:	e8 86 fd ff ff       	call   80103b10 <myproc>
  
  if(p == 0)
80103d8a:	85 c0                	test   %eax,%eax
// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
80103d8c:	89 c7                	mov    %eax,%edi
  
  if(p == 0)
80103d8e:	0f 84 8b 00 00 00    	je     80103e1f <sleep+0xaf>
    panic("sleep");

  if(lk == 0)
80103d94:	85 db                	test   %ebx,%ebx
80103d96:	74 7b                	je     80103e13 <sleep+0xa3>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103d98:	81 fb 40 2d 11 80    	cmp    $0x80112d40,%ebx
80103d9e:	74 50                	je     80103df0 <sleep+0x80>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103da0:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103da7:	e8 24 06 00 00       	call   801043d0 <acquire>
    release(lk);
80103dac:	89 1c 24             	mov    %ebx,(%esp)
80103daf:	e8 cc 05 00 00       	call   80104380 <release>
  }
  // Go to sleep.
  p->chan = chan;
80103db4:	89 77 20             	mov    %esi,0x20(%edi)
  p->state = SLEEPING;
80103db7:	c7 47 0c 02 00 00 00 	movl   $0x2,0xc(%edi)

  sched();
80103dbe:	e8 0d ff ff ff       	call   80103cd0 <sched>

  // Tidy up.
  p->chan = 0;
80103dc3:	c7 47 20 00 00 00 00 	movl   $0x0,0x20(%edi)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
80103dca:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103dd1:	e8 aa 05 00 00       	call   80104380 <release>
    acquire(lk);
  }
}
80103dd6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
80103dd9:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
80103ddc:	8b 7d fc             	mov    -0x4(%ebp),%edi
80103ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80103de2:	89 ec                	mov    %ebp,%esp
80103de4:	5d                   	pop    %ebp
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
80103de5:	e9 e6 05 00 00       	jmp    801043d0 <acquire>
80103dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
80103df0:	89 70 20             	mov    %esi,0x20(%eax)
  p->state = SLEEPING;
80103df3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80103dfa:	e8 d1 fe ff ff       	call   80103cd0 <sched>

  // Tidy up.
  p->chan = 0;
80103dff:	c7 47 20 00 00 00 00 	movl   $0x0,0x20(%edi)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
80103e06:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80103e09:	8b 75 f8             	mov    -0x8(%ebp),%esi
80103e0c:	8b 7d fc             	mov    -0x4(%ebp),%edi
80103e0f:	89 ec                	mov    %ebp,%esp
80103e11:	5d                   	pop    %ebp
80103e12:	c3                   	ret    
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
80103e13:	c7 04 24 2c 74 10 80 	movl   $0x8010742c,(%esp)
80103e1a:	e8 91 c5 ff ff       	call   801003b0 <panic>
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");
80103e1f:	c7 04 24 26 74 10 80 	movl   $0x80107426,(%esp)
80103e26:	e8 85 c5 ff ff       	call   801003b0 <panic>
80103e2b:	90                   	nop
80103e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103e30 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
80103e33:	56                   	push   %esi
80103e34:	53                   	push   %ebx
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
80103e35:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103e3a:	83 ec 20             	sub    $0x20,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103e3d:	e8 ce fc ff ff       	call   80103b10 <myproc>
  
  acquire(&ptable.lock);
80103e42:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103e49:	89 c6                	mov    %eax,%esi
  
  acquire(&ptable.lock);
80103e4b:	e8 80 05 00 00       	call   801043d0 <acquire>
80103e50:	31 c0                	xor    %eax,%eax
80103e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e58:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103e5e:	72 2a                	jb     80103e8a <wait+0x5a>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80103e60:	85 c0                	test   %eax,%eax
80103e62:	74 4c                	je     80103eb0 <wait+0x80>
80103e64:	8b 5e 24             	mov    0x24(%esi),%ebx
80103e67:	85 db                	test   %ebx,%ebx
80103e69:	75 45                	jne    80103eb0 <wait+0x80>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103e6b:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
80103e70:	c7 44 24 04 40 2d 11 	movl   $0x80112d40,0x4(%esp)
80103e77:	80 
80103e78:	89 34 24             	mov    %esi,(%esp)
80103e7b:	e8 f0 fe ff ff       	call   80103d70 <sleep>
80103e80:	31 c0                	xor    %eax,%eax
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e82:	81 fb 74 4c 11 80    	cmp    $0x80114c74,%ebx
80103e88:	73 d6                	jae    80103e60 <wait+0x30>
      if(p->parent != curproc)
80103e8a:	3b 73 14             	cmp    0x14(%ebx),%esi
80103e8d:	74 09                	je     80103e98 <wait+0x68>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e8f:	83 c3 7c             	add    $0x7c,%ebx
80103e92:	eb c4                	jmp    80103e58 <wait+0x28>
80103e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
80103e98:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103ea0:	74 26                	je     80103ec8 <wait+0x98>
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
80103ea2:	b8 01 00 00 00       	mov    $0x1,%eax
80103ea7:	eb e6                	jmp    80103e8f <wait+0x5f>
80103ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
80103eb0:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103eb7:	e8 c4 04 00 00       	call   80104380 <release>
80103ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103ec1:	83 c4 20             	add    $0x20,%esp
80103ec4:	5b                   	pop    %ebx
80103ec5:	5e                   	pop    %esi
80103ec6:	5d                   	pop    %ebp
80103ec7:	c3                   	ret    
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
80103ec8:	8b 43 10             	mov    0x10(%ebx),%eax
        kfree(p->kstack);
80103ecb:	8b 53 08             	mov    0x8(%ebx),%edx
80103ece:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ed1:	89 14 24             	mov    %edx,(%esp)
80103ed4:	e8 67 e5 ff ff       	call   80102440 <kfree>
        p->kstack = 0;
        freevm(p->pgdir);
80103ed9:	8b 53 04             	mov    0x4(%ebx),%edx
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
80103edc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103ee3:	89 14 24             	mov    %edx,(%esp)
80103ee6:	e8 95 29 00 00       	call   80106880 <freevm>
        p->pid = 0;
80103eeb:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103ef2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103ef9:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103efd:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103f04:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103f0b:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103f12:	e8 69 04 00 00       	call   80104380 <release>
        return pid;
80103f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1a:	eb a5                	jmp    80103ec1 <wait+0x91>
80103f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103f20 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
80103f20:	55                   	push   %ebp
80103f21:	89 e5                	mov    %esp,%ebp
80103f23:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103f26:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103f2d:	e8 9e 04 00 00       	call   801043d0 <acquire>
  myproc()->state = RUNNABLE;
80103f32:	e8 d9 fb ff ff       	call   80103b10 <myproc>
80103f37:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103f3e:	e8 8d fd ff ff       	call   80103cd0 <sched>
  release(&ptable.lock);
80103f43:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103f4a:	e8 31 04 00 00       	call   80104380 <release>
}
80103f4f:	c9                   	leave  
80103f50:	c3                   	ret    
80103f51:	eb 0d                	jmp    80103f60 <exit>
80103f53:	90                   	nop
80103f54:	90                   	nop
80103f55:	90                   	nop
80103f56:	90                   	nop
80103f57:	90                   	nop
80103f58:	90                   	nop
80103f59:	90                   	nop
80103f5a:	90                   	nop
80103f5b:	90                   	nop
80103f5c:	90                   	nop
80103f5d:	90                   	nop
80103f5e:	90                   	nop
80103f5f:	90                   	nop

80103f60 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103f60:	55                   	push   %ebp
80103f61:	89 e5                	mov    %esp,%ebp
80103f63:	56                   	push   %esi
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");
80103f64:	31 f6                	xor    %esi,%esi
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103f66:	53                   	push   %ebx
80103f67:	83 ec 10             	sub    $0x10,%esp
  struct proc *curproc = myproc();
80103f6a:	e8 a1 fb ff ff       	call   80103b10 <myproc>
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103f6f:	3b 05 c0 a5 10 80    	cmp    0x8010a5c0,%eax
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
80103f75:	89 c3                	mov    %eax,%ebx
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103f77:	0f 84 ed 00 00 00    	je     8010406a <exit+0x10a>
80103f7d:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
80103f80:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103f84:	85 c0                	test   %eax,%eax
80103f86:	74 10                	je     80103f98 <exit+0x38>
      fileclose(curproc->ofile[fd]);
80103f88:	89 04 24             	mov    %eax,(%esp)
80103f8b:	e8 c0 d0 ff ff       	call   80101050 <fileclose>
      curproc->ofile[fd] = 0;
80103f90:	c7 44 b3 28 00 00 00 	movl   $0x0,0x28(%ebx,%esi,4)
80103f97:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103f98:	83 c6 01             	add    $0x1,%esi
80103f9b:	83 fe 10             	cmp    $0x10,%esi
80103f9e:	75 e0                	jne    80103f80 <exit+0x20>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80103fa0:	e8 1b ee ff ff       	call   80102dc0 <begin_op>
  iput(curproc->cwd);
80103fa5:	8b 43 68             	mov    0x68(%ebx),%eax
80103fa8:	89 04 24             	mov    %eax,(%esp)
80103fab:	e8 80 db ff ff       	call   80101b30 <iput>
  end_op();
80103fb0:	e8 db ec ff ff       	call   80102c90 <end_op>
  curproc->cwd = 0;
80103fb5:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

  acquire(&ptable.lock);
80103fbc:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103fc3:	e8 08 04 00 00       	call   801043d0 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103fc8:	8b 43 14             	mov    0x14(%ebx),%eax

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
80103fcb:	ba 74 2d 11 80       	mov    $0x80112d74,%edx
80103fd0:	eb 11                	jmp    80103fe3 <exit+0x83>
80103fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fd8:	83 c2 7c             	add    $0x7c,%edx
80103fdb:	81 fa 74 4c 11 80    	cmp    $0x80114c74,%edx
80103fe1:	74 1d                	je     80104000 <exit+0xa0>
    if(p->state == SLEEPING && p->chan == chan)
80103fe3:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103fe7:	75 ef                	jne    80103fd8 <exit+0x78>
80103fe9:	3b 42 20             	cmp    0x20(%edx),%eax
80103fec:	75 ea                	jne    80103fd8 <exit+0x78>
      p->state = RUNNABLE;
80103fee:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ff5:	83 c2 7c             	add    $0x7c,%edx
80103ff8:	81 fa 74 4c 11 80    	cmp    $0x80114c74,%edx
80103ffe:	75 e3                	jne    80103fe3 <exit+0x83>
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
80104000:	a1 c0 a5 10 80       	mov    0x8010a5c0,%eax
80104005:	b9 74 2d 11 80       	mov    $0x80112d74,%ecx
8010400a:	eb 0f                	jmp    8010401b <exit+0xbb>
8010400c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104010:	83 c1 7c             	add    $0x7c,%ecx
80104013:	81 f9 74 4c 11 80    	cmp    $0x80114c74,%ecx
80104019:	74 37                	je     80104052 <exit+0xf2>
    if(p->parent == curproc){
8010401b:	3b 59 14             	cmp    0x14(%ecx),%ebx
8010401e:	75 f0                	jne    80104010 <exit+0xb0>
      p->parent = initproc;
      if(p->state == ZOMBIE)
80104020:	83 79 0c 05          	cmpl   $0x5,0xc(%ecx)
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
80104024:	89 41 14             	mov    %eax,0x14(%ecx)
      if(p->state == ZOMBIE)
80104027:	75 e7                	jne    80104010 <exit+0xb0>
80104029:	ba 74 2d 11 80       	mov    $0x80112d74,%edx
8010402e:	eb 0b                	jmp    8010403b <exit+0xdb>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104030:	83 c2 7c             	add    $0x7c,%edx
80104033:	81 fa 74 4c 11 80    	cmp    $0x80114c74,%edx
80104039:	74 d5                	je     80104010 <exit+0xb0>
    if(p->state == SLEEPING && p->chan == chan)
8010403b:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010403f:	75 ef                	jne    80104030 <exit+0xd0>
80104041:	3b 42 20             	cmp    0x20(%edx),%eax
80104044:	75 ea                	jne    80104030 <exit+0xd0>
      p->state = RUNNABLE;
80104046:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010404d:	8d 76 00             	lea    0x0(%esi),%esi
80104050:	eb de                	jmp    80104030 <exit+0xd0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104052:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
80104059:	e8 72 fc ff ff       	call   80103cd0 <sched>
  panic("zombie exit");
8010405e:	c7 04 24 4a 74 10 80 	movl   $0x8010744a,(%esp)
80104065:	e8 46 c3 ff ff       	call   801003b0 <panic>
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");
8010406a:	c7 04 24 3d 74 10 80 	movl   $0x8010743d,(%esp)
80104071:	e8 3a c3 ff ff       	call   801003b0 <panic>
80104076:	8d 76 00             	lea    0x0(%esi),%esi
80104079:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104080 <cpuid>:
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
80104080:	55                   	push   %ebp
80104081:	89 e5                	mov    %esp,%ebp
80104083:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104086:	e8 65 f9 ff ff       	call   801039f0 <mycpu>
}
8010408b:	c9                   	leave  
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
8010408c:	2d a0 27 11 80       	sub    $0x801127a0,%eax
80104091:	c1 f8 04             	sar    $0x4,%eax
80104094:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010409a:	c3                   	ret    
8010409b:	90                   	nop
8010409c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801040a0 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801040a0:	55                   	push   %ebp
801040a1:	89 e5                	mov    %esp,%ebp
801040a3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801040a6:	c7 44 24 04 56 74 10 	movl   $0x80107456,0x4(%esp)
801040ad:	80 
801040ae:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801040b5:	e8 46 01 00 00       	call   80104200 <initlock>
}
801040ba:	c9                   	leave  
801040bb:	c3                   	ret    
801040bc:	00 00                	add    %al,(%eax)
	...

801040c0 <holdingsleep>:
  release(&lk->lk);
}

int
holdingsleep(struct sleeplock *lk)
{
801040c0:	55                   	push   %ebp
801040c1:	89 e5                	mov    %esp,%ebp
801040c3:	83 ec 28             	sub    $0x28,%esp
801040c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
801040c9:	8b 75 08             	mov    0x8(%ebp),%esi
801040cc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
801040cf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  int r;
  
  acquire(&lk->lk);
801040d2:	8d 5e 04             	lea    0x4(%esi),%ebx
801040d5:	89 1c 24             	mov    %ebx,(%esp)
801040d8:	e8 f3 02 00 00       	call   801043d0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
801040dd:	8b 06                	mov    (%esi),%eax
801040df:	85 c0                	test   %eax,%eax
801040e1:	75 1d                	jne    80104100 <holdingsleep+0x40>
801040e3:	31 ff                	xor    %edi,%edi
  release(&lk->lk);
801040e5:	89 1c 24             	mov    %ebx,(%esp)
801040e8:	e8 93 02 00 00       	call   80104380 <release>
  return r;
}
801040ed:	89 f8                	mov    %edi,%eax
801040ef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801040f2:	8b 75 f8             	mov    -0x8(%ebp),%esi
801040f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
801040f8:	89 ec                	mov    %ebp,%esp
801040fa:	5d                   	pop    %ebp
801040fb:	c3                   	ret    
801040fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
holdingsleep(struct sleeplock *lk)
{
  int r;
  
  acquire(&lk->lk);
  r = lk->locked && (lk->pid == myproc()->pid);
80104100:	8b 76 3c             	mov    0x3c(%esi),%esi
80104103:	bf 01 00 00 00       	mov    $0x1,%edi
80104108:	e8 03 fa ff ff       	call   80103b10 <myproc>
8010410d:	3b 70 10             	cmp    0x10(%eax),%esi
80104110:	75 d1                	jne    801040e3 <holdingsleep+0x23>
80104112:	eb d1                	jmp    801040e5 <holdingsleep+0x25>
80104114:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010411a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104120 <releasesleep>:
  release(&lk->lk);
}

void
releasesleep(struct sleeplock *lk)
{
80104120:	55                   	push   %ebp
80104121:	89 e5                	mov    %esp,%ebp
80104123:	83 ec 18             	sub    $0x18,%esp
80104126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80104129:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010412c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  acquire(&lk->lk);
8010412f:	8d 73 04             	lea    0x4(%ebx),%esi
80104132:	89 34 24             	mov    %esi,(%esp)
80104135:	e8 96 02 00 00       	call   801043d0 <acquire>
  lk->locked = 0;
8010413a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80104140:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104147:	89 1c 24             	mov    %ebx,(%esp)
8010414a:	e8 11 f6 ff ff       	call   80103760 <wakeup>
  release(&lk->lk);
}
8010414f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
{
  acquire(&lk->lk);
  lk->locked = 0;
  lk->pid = 0;
  wakeup(lk);
  release(&lk->lk);
80104152:	89 75 08             	mov    %esi,0x8(%ebp)
}
80104155:	8b 75 fc             	mov    -0x4(%ebp),%esi
80104158:	89 ec                	mov    %ebp,%esp
8010415a:	5d                   	pop    %ebp
{
  acquire(&lk->lk);
  lk->locked = 0;
  lk->pid = 0;
  wakeup(lk);
  release(&lk->lk);
8010415b:	e9 20 02 00 00       	jmp    80104380 <release>

80104160 <acquiresleep>:
  lk->pid = 0;
}

void
acquiresleep(struct sleeplock *lk)
{
80104160:	55                   	push   %ebp
80104161:	89 e5                	mov    %esp,%ebp
80104163:	56                   	push   %esi
80104164:	53                   	push   %ebx
80104165:	83 ec 10             	sub    $0x10,%esp
80104168:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
8010416b:	8d 73 04             	lea    0x4(%ebx),%esi
8010416e:	89 34 24             	mov    %esi,(%esp)
80104171:	e8 5a 02 00 00       	call   801043d0 <acquire>
  while (lk->locked) {
80104176:	8b 0b                	mov    (%ebx),%ecx
80104178:	85 c9                	test   %ecx,%ecx
8010417a:	74 16                	je     80104192 <acquiresleep+0x32>
8010417c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    sleep(lk, &lk->lk);
80104180:	89 74 24 04          	mov    %esi,0x4(%esp)
80104184:	89 1c 24             	mov    %ebx,(%esp)
80104187:	e8 e4 fb ff ff       	call   80103d70 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
8010418c:	8b 13                	mov    (%ebx),%edx
8010418e:	85 d2                	test   %edx,%edx
80104190:	75 ee                	jne    80104180 <acquiresleep+0x20>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104192:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104198:	e8 73 f9 ff ff       	call   80103b10 <myproc>
8010419d:	8b 40 10             	mov    0x10(%eax),%eax
801041a0:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801041a3:	89 75 08             	mov    %esi,0x8(%ebp)
}
801041a6:	83 c4 10             	add    $0x10,%esp
801041a9:	5b                   	pop    %ebx
801041aa:	5e                   	pop    %esi
801041ab:	5d                   	pop    %ebp
  while (lk->locked) {
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
  lk->pid = myproc()->pid;
  release(&lk->lk);
801041ac:	e9 cf 01 00 00       	jmp    80104380 <release>
801041b1:	eb 0d                	jmp    801041c0 <initsleeplock>
801041b3:	90                   	nop
801041b4:	90                   	nop
801041b5:	90                   	nop
801041b6:	90                   	nop
801041b7:	90                   	nop
801041b8:	90                   	nop
801041b9:	90                   	nop
801041ba:	90                   	nop
801041bb:	90                   	nop
801041bc:	90                   	nop
801041bd:	90                   	nop
801041be:	90                   	nop
801041bf:	90                   	nop

801041c0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801041c0:	55                   	push   %ebp
801041c1:	89 e5                	mov    %esp,%ebp
801041c3:	53                   	push   %ebx
801041c4:	83 ec 14             	sub    $0x14,%esp
801041c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801041ca:	c7 44 24 04 c8 74 10 	movl   $0x801074c8,0x4(%esp)
801041d1:	80 
801041d2:	8d 43 04             	lea    0x4(%ebx),%eax
801041d5:	89 04 24             	mov    %eax,(%esp)
801041d8:	e8 23 00 00 00       	call   80104200 <initlock>
  lk->name = name;
801041dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
801041e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801041e6:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)

void
initsleeplock(struct sleeplock *lk, char *name)
{
  initlock(&lk->lk, "sleep lock");
  lk->name = name;
801041ed:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
  lk->pid = 0;
}
801041f0:	83 c4 14             	add    $0x14,%esp
801041f3:	5b                   	pop    %ebx
801041f4:	5d                   	pop    %ebp
801041f5:	c3                   	ret    
	...

80104200 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104200:	55                   	push   %ebp
80104201:	89 e5                	mov    %esp,%ebp
80104203:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104206:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104209:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
8010420f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
  lk->cpu = 0;
80104212:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104219:	5d                   	pop    %ebp
8010421a:	c3                   	ret    
8010421b:	90                   	nop
8010421c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104220 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104220:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104221:	31 c0                	xor    %eax,%eax
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104223:	89 e5                	mov    %esp,%ebp
80104225:	53                   	push   %ebx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104226:	8b 55 08             	mov    0x8(%ebp),%edx
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010422c:	83 ea 08             	sub    $0x8,%edx
8010422f:	90                   	nop
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104230:	8d 8a 00 00 00 80    	lea    -0x80000000(%edx),%ecx
80104236:	81 f9 fe ff ff 7f    	cmp    $0x7ffffffe,%ecx
8010423c:	77 1a                	ja     80104258 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010423e:	8b 4a 04             	mov    0x4(%edx),%ecx
80104241:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104244:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
80104247:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104249:	83 f8 0a             	cmp    $0xa,%eax
8010424c:	75 e2                	jne    80104230 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
8010424e:	5b                   	pop    %ebx
8010424f:	5d                   	pop    %ebp
80104250:	c3                   	ret    
80104251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104258:	83 f8 09             	cmp    $0x9,%eax
8010425b:	7f f1                	jg     8010424e <getcallerpcs+0x2e>
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
8010425d:	8d 14 83             	lea    (%ebx,%eax,4),%edx
  }
  for(; i < 10; i++)
80104260:	83 c0 01             	add    $0x1,%eax
    pcs[i] = 0;
80104263:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104269:	83 c2 04             	add    $0x4,%edx
8010426c:	83 f8 0a             	cmp    $0xa,%eax
8010426f:	75 ef                	jne    80104260 <getcallerpcs+0x40>
    pcs[i] = 0;
}
80104271:	5b                   	pop    %ebx
80104272:	5d                   	pop    %ebp
80104273:	c3                   	ret    
80104274:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010427a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104280 <popcli>:
  mycpu()->ncli += 1;
}

void
popcli(void)
{
80104280:	55                   	push   %ebp
80104281:	89 e5                	mov    %esp,%ebp
80104283:	83 ec 18             	sub    $0x18,%esp
80104286:	9c                   	pushf  
80104287:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104288:	f6 c4 02             	test   $0x2,%ah
8010428b:	75 49                	jne    801042d6 <popcli+0x56>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010428d:	e8 5e f7 ff ff       	call   801039f0 <mycpu>
80104292:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104298:	83 ea 01             	sub    $0x1,%edx
8010429b:	85 d2                	test   %edx,%edx
8010429d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801042a3:	78 25                	js     801042ca <popcli+0x4a>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801042a5:	e8 46 f7 ff ff       	call   801039f0 <mycpu>
801042aa:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801042b0:	85 d2                	test   %edx,%edx
801042b2:	74 04                	je     801042b8 <popcli+0x38>
    sti();
}
801042b4:	c9                   	leave  
801042b5:	c3                   	ret    
801042b6:	66 90                	xchg   %ax,%ax
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801042b8:	e8 33 f7 ff ff       	call   801039f0 <mycpu>
801042bd:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801042c3:	85 c0                	test   %eax,%eax
801042c5:	74 ed                	je     801042b4 <popcli+0x34>
}

static inline void
sti(void)
{
  asm volatile("sti");
801042c7:	fb                   	sti    
    sti();
}
801042c8:	c9                   	leave  
801042c9:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
801042ca:	c7 04 24 ea 74 10 80 	movl   $0x801074ea,(%esp)
801042d1:	e8 da c0 ff ff       	call   801003b0 <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
801042d6:	c7 04 24 d3 74 10 80 	movl   $0x801074d3,(%esp)
801042dd:	e8 ce c0 ff ff       	call   801003b0 <panic>
801042e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801042e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801042f0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801042f0:	55                   	push   %ebp
801042f1:	89 e5                	mov    %esp,%ebp
801042f3:	53                   	push   %ebx
801042f4:	83 ec 04             	sub    $0x4,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042f7:	9c                   	pushf  
801042f8:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
801042f9:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
801042fa:	e8 f1 f6 ff ff       	call   801039f0 <mycpu>
801042ff:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80104305:	85 c9                	test   %ecx,%ecx
80104307:	75 11                	jne    8010431a <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
80104309:	e8 e2 f6 ff ff       	call   801039f0 <mycpu>
8010430e:	81 e3 00 02 00 00    	and    $0x200,%ebx
80104314:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
8010431a:	e8 d1 f6 ff ff       	call   801039f0 <mycpu>
8010431f:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104326:	83 c4 04             	add    $0x4,%esp
80104329:	5b                   	pop    %ebx
8010432a:	5d                   	pop    %ebp
8010432b:	c3                   	ret    
8010432c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104330 <holding>:
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104330:	55                   	push   %ebp
80104331:	89 e5                	mov    %esp,%ebp
80104333:	83 ec 08             	sub    $0x8,%esp
80104336:	89 1c 24             	mov    %ebx,(%esp)
80104339:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010433c:	89 74 24 04          	mov    %esi,0x4(%esp)
  int r;
  pushcli();
80104340:	e8 ab ff ff ff       	call   801042f0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104345:	8b 33                	mov    (%ebx),%esi
80104347:	85 f6                	test   %esi,%esi
80104349:	75 15                	jne    80104360 <holding+0x30>
8010434b:	31 f6                	xor    %esi,%esi
  popcli();
8010434d:	e8 2e ff ff ff       	call   80104280 <popcli>
  return r;
}
80104352:	89 f0                	mov    %esi,%eax
80104354:	8b 1c 24             	mov    (%esp),%ebx
80104357:	8b 74 24 04          	mov    0x4(%esp),%esi
8010435b:	89 ec                	mov    %ebp,%esp
8010435d:	5d                   	pop    %ebp
8010435e:	c3                   	ret    
8010435f:	90                   	nop
int
holding(struct spinlock *lock)
{
  int r;
  pushcli();
  r = lock->locked && lock->cpu == mycpu();
80104360:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104363:	be 01 00 00 00       	mov    $0x1,%esi
80104368:	e8 83 f6 ff ff       	call   801039f0 <mycpu>
8010436d:	39 c3                	cmp    %eax,%ebx
8010436f:	75 da                	jne    8010434b <holding+0x1b>
80104371:	eb da                	jmp    8010434d <holding+0x1d>
80104373:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104379:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104380 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
80104380:	55                   	push   %ebp
80104381:	89 e5                	mov    %esp,%ebp
80104383:	53                   	push   %ebx
80104384:	83 ec 14             	sub    $0x14,%esp
80104387:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
8010438a:	89 1c 24             	mov    %ebx,(%esp)
8010438d:	e8 9e ff ff ff       	call   80104330 <holding>
80104392:	85 c0                	test   %eax,%eax
80104394:	74 23                	je     801043b9 <release+0x39>
    panic("release");

  lk->pcs[0] = 0;
80104396:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
8010439d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801043a4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801043a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

  popcli();
}
801043af:	83 c4 14             	add    $0x14,%esp
801043b2:	5b                   	pop    %ebx
801043b3:	5d                   	pop    %ebp
  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );

  popcli();
801043b4:	e9 c7 fe ff ff       	jmp    80104280 <popcli>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
801043b9:	c7 04 24 f1 74 10 80 	movl   $0x801074f1,(%esp)
801043c0:	e8 eb bf ff ff       	call   801003b0 <panic>
801043c5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801043c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801043d0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801043d0:	55                   	push   %ebp
801043d1:	89 e5                	mov    %esp,%ebp
801043d3:	53                   	push   %ebx
801043d4:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801043d7:	e8 14 ff ff ff       	call   801042f0 <pushcli>
  if(holding(lk))
801043dc:	8b 45 08             	mov    0x8(%ebp),%eax
801043df:	89 04 24             	mov    %eax,(%esp)
801043e2:	e8 49 ff ff ff       	call   80104330 <holding>
801043e7:	85 c0                	test   %eax,%eax
801043e9:	75 3c                	jne    80104427 <acquire+0x57>
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043eb:	b9 01 00 00 00       	mov    $0x1,%ecx
    panic("acquire");

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801043f0:	8b 55 08             	mov    0x8(%ebp),%edx
801043f3:	89 c8                	mov    %ecx,%eax
801043f5:	f0 87 02             	lock xchg %eax,(%edx)
801043f8:	85 c0                	test   %eax,%eax
801043fa:	75 f4                	jne    801043f0 <acquire+0x20>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801043fc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104401:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104404:	e8 e7 f5 ff ff       	call   801039f0 <mycpu>
80104409:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010440c:	8b 45 08             	mov    0x8(%ebp),%eax
8010440f:	83 c0 0c             	add    $0xc,%eax
80104412:	89 44 24 04          	mov    %eax,0x4(%esp)
80104416:	8d 45 08             	lea    0x8(%ebp),%eax
80104419:	89 04 24             	mov    %eax,(%esp)
8010441c:	e8 ff fd ff ff       	call   80104220 <getcallerpcs>
}
80104421:	83 c4 14             	add    $0x14,%esp
80104424:	5b                   	pop    %ebx
80104425:	5d                   	pop    %ebp
80104426:	c3                   	ret    
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
80104427:	c7 04 24 f9 74 10 80 	movl   $0x801074f9,(%esp)
8010442e:	e8 7d bf ff ff       	call   801003b0 <panic>
	...

80104440 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104440:	55                   	push   %ebp
80104441:	89 e5                	mov    %esp,%ebp
80104443:	83 ec 08             	sub    $0x8,%esp
80104446:	8b 55 08             	mov    0x8(%ebp),%edx
80104449:	89 1c 24             	mov    %ebx,(%esp)
8010444c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010444f:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104453:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104456:	f6 c2 03             	test   $0x3,%dl
80104459:	75 05                	jne    80104460 <memset+0x20>
8010445b:	f6 c1 03             	test   $0x3,%cl
8010445e:	74 18                	je     80104478 <memset+0x38>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80104460:	89 d7                	mov    %edx,%edi
80104462:	fc                   	cld    
80104463:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104465:	89 d0                	mov    %edx,%eax
80104467:	8b 1c 24             	mov    (%esp),%ebx
8010446a:	8b 7c 24 04          	mov    0x4(%esp),%edi
8010446e:	89 ec                	mov    %ebp,%esp
80104470:	5d                   	pop    %ebp
80104471:	c3                   	ret    
80104472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

void*
memset(void *dst, int c, uint n)
{
  if ((int)dst%4 == 0 && n%4 == 0){
    c &= 0xFF;
80104478:	0f b6 f8             	movzbl %al,%edi
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
8010447b:	89 f8                	mov    %edi,%eax
8010447d:	89 fb                	mov    %edi,%ebx
8010447f:	c1 e0 18             	shl    $0x18,%eax
80104482:	c1 e3 10             	shl    $0x10,%ebx
80104485:	09 d8                	or     %ebx,%eax
80104487:	09 f8                	or     %edi,%eax
80104489:	c1 e7 08             	shl    $0x8,%edi
8010448c:	09 f8                	or     %edi,%eax
8010448e:	89 d7                	mov    %edx,%edi
80104490:	c1 e9 02             	shr    $0x2,%ecx
80104493:	fc                   	cld    
80104494:	f3 ab                	rep stos %eax,%es:(%edi)
80104496:	eb cd                	jmp    80104465 <memset+0x25>
80104498:	90                   	nop
80104499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801044a0 <memcmp>:
  return dst;
}

int
memcmp(const void *v1, const void *v2, uint n)
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	57                   	push   %edi
801044a4:	56                   	push   %esi
801044a5:	53                   	push   %ebx
801044a6:	8b 55 10             	mov    0x10(%ebp),%edx
801044a9:	8b 75 08             	mov    0x8(%ebp),%esi
801044ac:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801044af:	85 d2                	test   %edx,%edx
801044b1:	74 2d                	je     801044e0 <memcmp+0x40>
    if(*s1 != *s2)
801044b3:	0f b6 1e             	movzbl (%esi),%ebx
801044b6:	0f b6 0f             	movzbl (%edi),%ecx
801044b9:	38 cb                	cmp    %cl,%bl
801044bb:	75 2b                	jne    801044e8 <memcmp+0x48>
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801044bd:	83 ea 01             	sub    $0x1,%edx
801044c0:	31 c0                	xor    %eax,%eax
801044c2:	eb 18                	jmp    801044dc <memcmp+0x3c>
801044c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(*s1 != *s2)
801044c8:	0f b6 5c 06 01       	movzbl 0x1(%esi,%eax,1),%ebx
801044cd:	83 ea 01             	sub    $0x1,%edx
801044d0:	0f b6 4c 07 01       	movzbl 0x1(%edi,%eax,1),%ecx
801044d5:	83 c0 01             	add    $0x1,%eax
801044d8:	38 cb                	cmp    %cl,%bl
801044da:	75 0c                	jne    801044e8 <memcmp+0x48>
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801044dc:	85 d2                	test   %edx,%edx
801044de:	75 e8                	jne    801044c8 <memcmp+0x28>
801044e0:	31 c0                	xor    %eax,%eax
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
801044e2:	5b                   	pop    %ebx
801044e3:	5e                   	pop    %esi
801044e4:	5f                   	pop    %edi
801044e5:	5d                   	pop    %ebp
801044e6:	c3                   	ret    
801044e7:	90                   	nop

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
801044e8:	0f b6 c3             	movzbl %bl,%eax
801044eb:	0f b6 c9             	movzbl %cl,%ecx
801044ee:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
801044f0:	5b                   	pop    %ebx
801044f1:	5e                   	pop    %esi
801044f2:	5f                   	pop    %edi
801044f3:	5d                   	pop    %ebp
801044f4:	c3                   	ret    
801044f5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801044f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104500 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104500:	55                   	push   %ebp
80104501:	89 e5                	mov    %esp,%ebp
80104503:	57                   	push   %edi
80104504:	56                   	push   %esi
80104505:	53                   	push   %ebx
80104506:	8b 45 08             	mov    0x8(%ebp),%eax
80104509:	8b 75 0c             	mov    0xc(%ebp),%esi
8010450c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010450f:	39 c6                	cmp    %eax,%esi
80104511:	73 2d                	jae    80104540 <memmove+0x40>
80104513:	8d 3c 1e             	lea    (%esi,%ebx,1),%edi
80104516:	39 f8                	cmp    %edi,%eax
80104518:	73 26                	jae    80104540 <memmove+0x40>
    s += n;
    d += n;
    while(n-- > 0)
8010451a:	85 db                	test   %ebx,%ebx
8010451c:	74 1d                	je     8010453b <memmove+0x3b>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
8010451e:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80104521:	31 d2                	xor    %edx,%edx
80104523:	90                   	nop
80104524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
      *--d = *--s;
80104528:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
8010452d:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
80104531:	83 ea 01             	sub    $0x1,%edx
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104534:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
80104537:	85 c9                	test   %ecx,%ecx
80104539:	75 ed                	jne    80104528 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
8010453b:	5b                   	pop    %ebx
8010453c:	5e                   	pop    %esi
8010453d:	5f                   	pop    %edi
8010453e:	5d                   	pop    %ebp
8010453f:	c3                   	ret    
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104540:	31 d2                	xor    %edx,%edx
      *--d = *--s;
  } else
    while(n-- > 0)
80104542:	85 db                	test   %ebx,%ebx
80104544:	74 f5                	je     8010453b <memmove+0x3b>
80104546:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80104548:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
8010454c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
8010454f:	83 c2 01             	add    $0x1,%edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104552:	39 d3                	cmp    %edx,%ebx
80104554:	75 f2                	jne    80104548 <memmove+0x48>
      *d++ = *s++;

  return dst;
}
80104556:	5b                   	pop    %ebx
80104557:	5e                   	pop    %esi
80104558:	5f                   	pop    %edi
80104559:	5d                   	pop    %ebp
8010455a:	c3                   	ret    
8010455b:	90                   	nop
8010455c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104560 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104560:	55                   	push   %ebp
80104561:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104563:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104564:	e9 97 ff ff ff       	jmp    80104500 <memmove>
80104569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104570 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104570:	55                   	push   %ebp
80104571:	89 e5                	mov    %esp,%ebp
80104573:	57                   	push   %edi
80104574:	56                   	push   %esi
80104575:	53                   	push   %ebx
80104576:	8b 7d 10             	mov    0x10(%ebp),%edi
80104579:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010457c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while(n > 0 && *p && *p == *q)
8010457f:	85 ff                	test   %edi,%edi
80104581:	74 3d                	je     801045c0 <strncmp+0x50>
80104583:	0f b6 01             	movzbl (%ecx),%eax
80104586:	84 c0                	test   %al,%al
80104588:	75 18                	jne    801045a2 <strncmp+0x32>
8010458a:	eb 3c                	jmp    801045c8 <strncmp+0x58>
8010458c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104590:	83 ef 01             	sub    $0x1,%edi
80104593:	74 2b                	je     801045c0 <strncmp+0x50>
    n--, p++, q++;
80104595:	83 c1 01             	add    $0x1,%ecx
80104598:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010459b:	0f b6 01             	movzbl (%ecx),%eax
8010459e:	84 c0                	test   %al,%al
801045a0:	74 26                	je     801045c8 <strncmp+0x58>
801045a2:	0f b6 33             	movzbl (%ebx),%esi
801045a5:	89 f2                	mov    %esi,%edx
801045a7:	38 d0                	cmp    %dl,%al
801045a9:	74 e5                	je     80104590 <strncmp+0x20>
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
801045ab:	81 e6 ff 00 00 00    	and    $0xff,%esi
801045b1:	0f b6 c0             	movzbl %al,%eax
801045b4:	29 f0                	sub    %esi,%eax
}
801045b6:	5b                   	pop    %ebx
801045b7:	5e                   	pop    %esi
801045b8:	5f                   	pop    %edi
801045b9:	5d                   	pop    %ebp
801045ba:	c3                   	ret    
801045bb:	90                   	nop
801045bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801045c0:	31 c0                	xor    %eax,%eax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
801045c2:	5b                   	pop    %ebx
801045c3:	5e                   	pop    %esi
801045c4:	5f                   	pop    %edi
801045c5:	5d                   	pop    %ebp
801045c6:	c3                   	ret    
801045c7:	90                   	nop
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801045c8:	0f b6 33             	movzbl (%ebx),%esi
801045cb:	eb de                	jmp    801045ab <strncmp+0x3b>
801045cd:	8d 76 00             	lea    0x0(%esi),%esi

801045d0 <strncpy>:
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
{
801045d0:	55                   	push   %ebp
801045d1:	89 e5                	mov    %esp,%ebp
801045d3:	8b 45 08             	mov    0x8(%ebp),%eax
801045d6:	56                   	push   %esi
801045d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801045da:	53                   	push   %ebx
801045db:	8b 75 0c             	mov    0xc(%ebp),%esi
801045de:	89 c3                	mov    %eax,%ebx
801045e0:	eb 09                	jmp    801045eb <strncpy+0x1b>
801045e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
801045e8:	83 c6 01             	add    $0x1,%esi
801045eb:	83 e9 01             	sub    $0x1,%ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
801045ee:	8d 51 01             	lea    0x1(%ecx),%edx
{
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
801045f1:	85 d2                	test   %edx,%edx
801045f3:	7e 0c                	jle    80104601 <strncpy+0x31>
801045f5:	0f b6 16             	movzbl (%esi),%edx
801045f8:	88 13                	mov    %dl,(%ebx)
801045fa:	83 c3 01             	add    $0x1,%ebx
801045fd:	84 d2                	test   %dl,%dl
801045ff:	75 e7                	jne    801045e8 <strncpy+0x18>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
80104601:	31 d2                	xor    %edx,%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80104603:	85 c9                	test   %ecx,%ecx
80104605:	7e 0c                	jle    80104613 <strncpy+0x43>
80104607:	90                   	nop
    *s++ = 0;
80104608:	c6 04 13 00          	movb   $0x0,(%ebx,%edx,1)
8010460c:	83 c2 01             	add    $0x1,%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010460f:	39 ca                	cmp    %ecx,%edx
80104611:	75 f5                	jne    80104608 <strncpy+0x38>
    *s++ = 0;
  return os;
}
80104613:	5b                   	pop    %ebx
80104614:	5e                   	pop    %esi
80104615:	5d                   	pop    %ebp
80104616:	c3                   	ret    
80104617:	89 f6                	mov    %esi,%esi
80104619:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104620 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104620:	55                   	push   %ebp
80104621:	89 e5                	mov    %esp,%ebp
80104623:	8b 55 10             	mov    0x10(%ebp),%edx
80104626:	56                   	push   %esi
80104627:	8b 45 08             	mov    0x8(%ebp),%eax
8010462a:	53                   	push   %ebx
8010462b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *os;

  os = s;
  if(n <= 0)
8010462e:	85 d2                	test   %edx,%edx
80104630:	7e 1f                	jle    80104651 <safestrcpy+0x31>
80104632:	89 c1                	mov    %eax,%ecx
80104634:	eb 05                	jmp    8010463b <safestrcpy+0x1b>
80104636:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104638:	83 c6 01             	add    $0x1,%esi
8010463b:	83 ea 01             	sub    $0x1,%edx
8010463e:	85 d2                	test   %edx,%edx
80104640:	7e 0c                	jle    8010464e <safestrcpy+0x2e>
80104642:	0f b6 1e             	movzbl (%esi),%ebx
80104645:	88 19                	mov    %bl,(%ecx)
80104647:	83 c1 01             	add    $0x1,%ecx
8010464a:	84 db                	test   %bl,%bl
8010464c:	75 ea                	jne    80104638 <safestrcpy+0x18>
    ;
  *s = 0;
8010464e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104651:	5b                   	pop    %ebx
80104652:	5e                   	pop    %esi
80104653:	5d                   	pop    %ebp
80104654:	c3                   	ret    
80104655:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104659:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104660 <strlen>:

int
strlen(const char *s)
{
80104660:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104661:	31 c0                	xor    %eax,%eax
  return os;
}

int
strlen(const char *s)
{
80104663:	89 e5                	mov    %esp,%ebp
80104665:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104668:	80 3a 00             	cmpb   $0x0,(%edx)
8010466b:	74 0c                	je     80104679 <strlen+0x19>
8010466d:	8d 76 00             	lea    0x0(%esi),%esi
80104670:	83 c0 01             	add    $0x1,%eax
80104673:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104677:	75 f7                	jne    80104670 <strlen+0x10>
    ;
  return n;
}
80104679:	5d                   	pop    %ebp
8010467a:	c3                   	ret    
	...

8010467c <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010467c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104680:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104684:	55                   	push   %ebp
  pushl %ebx
80104685:	53                   	push   %ebx
  pushl %esi
80104686:	56                   	push   %esi
  pushl %edi
80104687:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104688:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010468a:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010468c:	5f                   	pop    %edi
  popl %esi
8010468d:	5e                   	pop    %esi
  popl %ebx
8010468e:	5b                   	pop    %ebx
  popl %ebp
8010468f:	5d                   	pop    %ebp
  ret
80104690:	c3                   	ret    
	...

801046a0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801046a0:	55                   	push   %ebp
801046a1:	89 e5                	mov    %esp,%ebp
801046a3:	53                   	push   %ebx
801046a4:	83 ec 04             	sub    $0x4,%esp
801046a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801046aa:	e8 61 f4 ff ff       	call   80103b10 <myproc>

  if(addr >= curproc->sz)
801046af:	39 18                	cmp    %ebx,(%eax)
801046b1:	77 0d                	ja     801046c0 <fetchstr+0x20>
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801046b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    if(*s == 0)
      return s - *pp;
  }
  return -1;
}
801046b8:	83 c4 04             	add    $0x4,%esp
801046bb:	5b                   	pop    %ebx
801046bc:	5d                   	pop    %ebp
801046bd:	c3                   	ret    
801046be:	66 90                	xchg   %ax,%ax
  char *s, *ep;
  struct proc *curproc = myproc();

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
801046c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801046c3:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801046c5:	8b 08                	mov    (%eax),%ecx
  for(s = *pp; s < ep; s++){
801046c7:	39 cb                	cmp    %ecx,%ebx
801046c9:	73 e8                	jae    801046b3 <fetchstr+0x13>
    if(*s == 0)
801046cb:	31 c0                	xor    %eax,%eax
801046cd:	89 da                	mov    %ebx,%edx
801046cf:	80 3b 00             	cmpb   $0x0,(%ebx)
801046d2:	74 e4                	je     801046b8 <fetchstr+0x18>
801046d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801046d8:	83 c2 01             	add    $0x1,%edx
801046db:	39 d1                	cmp    %edx,%ecx
801046dd:	76 d4                	jbe    801046b3 <fetchstr+0x13>
    if(*s == 0)
801046df:	80 3a 00             	cmpb   $0x0,(%edx)
801046e2:	75 f4                	jne    801046d8 <fetchstr+0x38>
801046e4:	89 d0                	mov    %edx,%eax
801046e6:	29 d8                	sub    %ebx,%eax
801046e8:	eb ce                	jmp    801046b8 <fetchstr+0x18>
801046ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801046f0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801046f0:	55                   	push   %ebp
801046f1:	89 e5                	mov    %esp,%ebp
801046f3:	53                   	push   %ebx
801046f4:	83 ec 04             	sub    $0x4,%esp
801046f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801046fa:	e8 11 f4 ff ff       	call   80103b10 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801046ff:	8b 00                	mov    (%eax),%eax
80104701:	39 d8                	cmp    %ebx,%eax
80104703:	77 0b                	ja     80104710 <fetchint+0x20>
    return -1;
  *ip = *(int*)(addr);
  return 0;
80104705:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010470a:	83 c4 04             	add    $0x4,%esp
8010470d:	5b                   	pop    %ebx
8010470e:	5d                   	pop    %ebp
8010470f:	c3                   	ret    
int
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104710:	8d 53 04             	lea    0x4(%ebx),%edx
80104713:	39 d0                	cmp    %edx,%eax
80104715:	72 ee                	jb     80104705 <fetchint+0x15>
    return -1;
  *ip = *(int*)(addr);
80104717:	8b 45 0c             	mov    0xc(%ebp),%eax
8010471a:	8b 13                	mov    (%ebx),%edx
8010471c:	89 10                	mov    %edx,(%eax)
8010471e:	31 c0                	xor    %eax,%eax
  return 0;
80104720:	eb e8                	jmp    8010470a <fetchint+0x1a>
80104722:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104729:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104730 <argint>:
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104730:	55                   	push   %ebp
80104731:	89 e5                	mov    %esp,%ebp
80104733:	83 ec 08             	sub    $0x8,%esp
80104736:	89 1c 24             	mov    %ebx,(%esp)
80104739:	89 74 24 04          	mov    %esi,0x4(%esp)
8010473d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104740:	8b 75 0c             	mov    0xc(%ebp),%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104743:	e8 c8 f3 ff ff       	call   80103b10 <myproc>
80104748:	89 75 0c             	mov    %esi,0xc(%ebp)
8010474b:	8b 40 18             	mov    0x18(%eax),%eax
8010474e:	8b 40 44             	mov    0x44(%eax),%eax
80104751:	8d 44 98 04          	lea    0x4(%eax,%ebx,4),%eax
80104755:	89 45 08             	mov    %eax,0x8(%ebp)
}
80104758:	8b 1c 24             	mov    (%esp),%ebx
8010475b:	8b 74 24 04          	mov    0x4(%esp),%esi
8010475f:	89 ec                	mov    %ebp,%esp
80104761:	5d                   	pop    %ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104762:	e9 89 ff ff ff       	jmp    801046f0 <fetchint>
80104767:	89 f6                	mov    %esi,%esi
80104769:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104770 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104770:	55                   	push   %ebp
80104771:	89 e5                	mov    %esp,%ebp
80104773:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104776:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104779:	89 44 24 04          	mov    %eax,0x4(%esp)
8010477d:	8b 45 08             	mov    0x8(%ebp),%eax
80104780:	89 04 24             	mov    %eax,(%esp)
80104783:	e8 a8 ff ff ff       	call   80104730 <argint>
80104788:	89 c2                	mov    %eax,%edx
8010478a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010478f:	85 d2                	test   %edx,%edx
80104791:	78 12                	js     801047a5 <argstr+0x35>
    return -1;
  return fetchstr(addr, pp);
80104793:	8b 45 0c             	mov    0xc(%ebp),%eax
80104796:	89 44 24 04          	mov    %eax,0x4(%esp)
8010479a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479d:	89 04 24             	mov    %eax,(%esp)
801047a0:	e8 fb fe ff ff       	call   801046a0 <fetchstr>
}
801047a5:	c9                   	leave  
801047a6:	c3                   	ret    
801047a7:	89 f6                	mov    %esi,%esi
801047a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801047b0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801047b0:	55                   	push   %ebp
801047b1:	89 e5                	mov    %esp,%ebp
801047b3:	83 ec 28             	sub    $0x28,%esp
801047b6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
801047b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
801047bc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int i;
  struct proc *curproc = myproc();
801047bf:	e8 4c f3 ff ff       	call   80103b10 <myproc>
801047c4:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801047c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801047c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801047cd:	8b 45 08             	mov    0x8(%ebp),%eax
801047d0:	89 04 24             	mov    %eax,(%esp)
801047d3:	e8 58 ff ff ff       	call   80104730 <argint>
801047d8:	85 c0                	test   %eax,%eax
801047da:	79 14                	jns    801047f0 <argptr+0x40>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
801047dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801047e1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
801047e4:	8b 75 fc             	mov    -0x4(%ebp),%esi
801047e7:	89 ec                	mov    %ebp,%esp
801047e9:	5d                   	pop    %ebp
801047ea:	c3                   	ret    
801047eb:	90                   	nop
801047ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int i;
  struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801047f0:	85 db                	test   %ebx,%ebx
801047f2:	78 e8                	js     801047dc <argptr+0x2c>
801047f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f7:	8b 16                	mov    (%esi),%edx
801047f9:	39 d0                	cmp    %edx,%eax
801047fb:	73 df                	jae    801047dc <argptr+0x2c>
801047fd:	01 c3                	add    %eax,%ebx
801047ff:	39 da                	cmp    %ebx,%edx
80104801:	72 d9                	jb     801047dc <argptr+0x2c>
    return -1;
  *pp = (char*)i;
80104803:	8b 55 0c             	mov    0xc(%ebp),%edx
80104806:	89 02                	mov    %eax,(%edx)
80104808:	31 c0                	xor    %eax,%eax
  return 0;
8010480a:	eb d5                	jmp    801047e1 <argptr+0x31>
8010480c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104810 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	83 ec 18             	sub    $0x18,%esp
80104816:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80104819:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int num;
  struct proc *curproc = myproc();
8010481c:	e8 ef f2 ff ff       	call   80103b10 <myproc>

  num = curproc->tf->eax;
80104821:	8b 58 18             	mov    0x18(%eax),%ebx

void
syscall(void)
{
  int num;
  struct proc *curproc = myproc();
80104824:	89 c6                	mov    %eax,%esi

  num = curproc->tf->eax;
80104826:	8b 43 1c             	mov    0x1c(%ebx),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104829:	8d 50 ff             	lea    -0x1(%eax),%edx
8010482c:	83 fa 14             	cmp    $0x14,%edx
8010482f:	77 1f                	ja     80104850 <syscall+0x40>
80104831:	8b 14 85 20 75 10 80 	mov    -0x7fef8ae0(,%eax,4),%edx
80104838:	85 d2                	test   %edx,%edx
8010483a:	74 14                	je     80104850 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
8010483c:	ff d2                	call   *%edx
8010483e:	89 43 1c             	mov    %eax,0x1c(%ebx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104841:	8b 5d f8             	mov    -0x8(%ebp),%ebx
80104844:	8b 75 fc             	mov    -0x4(%ebp),%esi
80104847:	89 ec                	mov    %ebp,%esp
80104849:	5d                   	pop    %ebp
8010484a:	c3                   	ret    
8010484b:	90                   	nop
8010484c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80104850:	89 44 24 0c          	mov    %eax,0xc(%esp)
80104854:	8d 46 6c             	lea    0x6c(%esi),%eax
80104857:	89 44 24 08          	mov    %eax,0x8(%esp)
8010485b:	8b 46 10             	mov    0x10(%esi),%eax
8010485e:	c7 04 24 01 75 10 80 	movl   $0x80107501,(%esp)
80104865:	89 44 24 04          	mov    %eax,0x4(%esp)
80104869:	e8 e2 bf ff ff       	call   80100850 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
8010486e:	8b 46 18             	mov    0x18(%esi),%eax
80104871:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104878:	8b 5d f8             	mov    -0x8(%ebp),%ebx
8010487b:	8b 75 fc             	mov    -0x4(%ebp),%esi
8010487e:	89 ec                	mov    %ebp,%esp
80104880:	5d                   	pop    %ebp
80104881:	c3                   	ret    
	...

80104890 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104890:	55                   	push   %ebp
80104891:	89 e5                	mov    %esp,%ebp
80104893:	53                   	push   %ebx
80104894:	89 c3                	mov    %eax,%ebx
80104896:	83 ec 04             	sub    $0x4,%esp
  int fd;
  struct proc *curproc = myproc();
80104899:	e8 72 f2 ff ff       	call   80103b10 <myproc>
8010489e:	89 c2                	mov    %eax,%edx
801048a0:	31 c0                	xor    %eax,%eax
801048a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
801048a8:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
801048ac:	85 c9                	test   %ecx,%ecx
801048ae:	74 18                	je     801048c8 <fdalloc+0x38>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801048b0:	83 c0 01             	add    $0x1,%eax
801048b3:	83 f8 10             	cmp    $0x10,%eax
801048b6:	75 f0                	jne    801048a8 <fdalloc+0x18>
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
}
801048b8:	83 c4 04             	add    $0x4,%esp
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801048bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
}
801048c0:	5b                   	pop    %ebx
801048c1:	5d                   	pop    %ebp
801048c2:	c3                   	ret    
801048c3:	90                   	nop
801048c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
801048c8:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
    }
  }
  return -1;
}
801048cc:	83 c4 04             	add    $0x4,%esp
801048cf:	5b                   	pop    %ebx
801048d0:	5d                   	pop    %ebp
801048d1:	c3                   	ret    
801048d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801048e0 <sys_pipe>:
  return exec(path, argv);
}

int
sys_pipe(void)
{
801048e0:	55                   	push   %ebp
801048e1:	89 e5                	mov    %esp,%ebp
801048e3:	53                   	push   %ebx
801048e4:	83 ec 24             	sub    $0x24,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801048e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048ea:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801048f1:	00 
801048f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801048f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801048fd:	e8 ae fe ff ff       	call   801047b0 <argptr>
80104902:	85 c0                	test   %eax,%eax
80104904:	79 12                	jns    80104918 <sys_pipe+0x38>
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
80104906:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010490b:	83 c4 24             	add    $0x24,%esp
8010490e:	5b                   	pop    %ebx
8010490f:	5d                   	pop    %ebp
80104910:	c3                   	ret    
80104911:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104918:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010491b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010491f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104922:	89 04 24             	mov    %eax,(%esp)
80104925:	e8 f6 eb ff ff       	call   80103520 <pipealloc>
8010492a:	85 c0                	test   %eax,%eax
8010492c:	78 d8                	js     80104906 <sys_pipe+0x26>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010492e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104931:	e8 5a ff ff ff       	call   80104890 <fdalloc>
80104936:	85 c0                	test   %eax,%eax
80104938:	89 c3                	mov    %eax,%ebx
8010493a:	78 28                	js     80104964 <sys_pipe+0x84>
8010493c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010493f:	e8 4c ff ff ff       	call   80104890 <fdalloc>
80104944:	85 c0                	test   %eax,%eax
80104946:	78 0f                	js     80104957 <sys_pipe+0x77>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104948:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010494b:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
8010494d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104950:	89 42 04             	mov    %eax,0x4(%edx)
80104953:	31 c0                	xor    %eax,%eax
  return 0;
80104955:	eb b4                	jmp    8010490b <sys_pipe+0x2b>
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
80104957:	e8 b4 f1 ff ff       	call   80103b10 <myproc>
8010495c:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104963:	00 
    fileclose(rf);
80104964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104967:	89 04 24             	mov    %eax,(%esp)
8010496a:	e8 e1 c6 ff ff       	call   80101050 <fileclose>
    fileclose(wf);
8010496f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104972:	89 04 24             	mov    %eax,(%esp)
80104975:	e8 d6 c6 ff ff       	call   80101050 <fileclose>
8010497a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
8010497f:	eb 8a                	jmp    8010490b <sys_pipe+0x2b>
80104981:	eb 0d                	jmp    80104990 <sys_exec>
80104983:	90                   	nop
80104984:	90                   	nop
80104985:	90                   	nop
80104986:	90                   	nop
80104987:	90                   	nop
80104988:	90                   	nop
80104989:	90                   	nop
8010498a:	90                   	nop
8010498b:	90                   	nop
8010498c:	90                   	nop
8010498d:	90                   	nop
8010498e:	90                   	nop
8010498f:	90                   	nop

80104990 <sys_exec>:
  return 0;
}

int
sys_exec(void)
{
80104990:	55                   	push   %ebp
80104991:	89 e5                	mov    %esp,%ebp
80104993:	81 ec b8 00 00 00    	sub    $0xb8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104999:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  return 0;
}

int
sys_exec(void)
{
8010499c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
8010499f:	89 75 f8             	mov    %esi,-0x8(%ebp)
801049a2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801049a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801049a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801049b0:	e8 bb fd ff ff       	call   80104770 <argstr>
801049b5:	85 c0                	test   %eax,%eax
801049b7:	79 17                	jns    801049d0 <sys_exec+0x40>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
801049b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
801049be:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801049c1:	8b 75 f8             	mov    -0x8(%ebp),%esi
801049c4:	8b 7d fc             	mov    -0x4(%ebp),%edi
801049c7:	89 ec                	mov    %ebp,%esp
801049c9:	5d                   	pop    %ebp
801049ca:	c3                   	ret    
801049cb:	90                   	nop
801049cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801049d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801049d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801049d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049de:	e8 4d fd ff ff       	call   80104730 <argint>
801049e3:	85 c0                	test   %eax,%eax
801049e5:	78 d2                	js     801049b9 <sys_exec+0x29>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801049e7:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
801049ed:	31 f6                	xor    %esi,%esi
801049ef:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801049f6:	00 
801049f7:	31 db                	xor    %ebx,%ebx
801049f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104a00:	00 
80104a01:	89 3c 24             	mov    %edi,(%esp)
80104a04:	e8 37 fa ff ff       	call   80104440 <memset>
80104a09:	eb 22                	jmp    80104a2d <sys_exec+0x9d>
80104a0b:	90                   	nop
80104a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104a10:	8d 14 b7             	lea    (%edi,%esi,4),%edx
80104a13:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a17:	89 04 24             	mov    %eax,(%esp)
80104a1a:	e8 81 fc ff ff       	call   801046a0 <fetchstr>
80104a1f:	85 c0                	test   %eax,%eax
80104a21:	78 96                	js     801049b9 <sys_exec+0x29>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80104a23:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104a26:	83 fb 20             	cmp    $0x20,%ebx

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80104a29:	89 de                	mov    %ebx,%esi
    if(i >= NELEM(argv))
80104a2b:	74 8c                	je     801049b9 <sys_exec+0x29>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104a2d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104a30:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a34:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
80104a3b:	03 45 e0             	add    -0x20(%ebp),%eax
80104a3e:	89 04 24             	mov    %eax,(%esp)
80104a41:	e8 aa fc ff ff       	call   801046f0 <fetchint>
80104a46:	85 c0                	test   %eax,%eax
80104a48:	0f 88 6b ff ff ff    	js     801049b9 <sys_exec+0x29>
      return -1;
    if(uarg == 0){
80104a4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a51:	85 c0                	test   %eax,%eax
80104a53:	75 bb                	jne    80104a10 <sys_exec+0x80>
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104a55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104a58:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
80104a5f:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104a63:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104a67:	89 04 24             	mov    %eax,(%esp)
80104a6a:	e8 51 bf ff ff       	call   801009c0 <exec>
80104a6f:	e9 4a ff ff ff       	jmp    801049be <sys_exec+0x2e>
80104a74:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104a7a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104a80 <sys_chdir>:
  return 0;
}

int
sys_chdir(void)
{
80104a80:	55                   	push   %ebp
80104a81:	89 e5                	mov    %esp,%ebp
80104a83:	56                   	push   %esi
80104a84:	53                   	push   %ebx
80104a85:	83 ec 20             	sub    $0x20,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104a88:	e8 83 f0 ff ff       	call   80103b10 <myproc>
80104a8d:	89 c3                	mov    %eax,%ebx
  
  begin_op();
80104a8f:	e8 2c e3 ff ff       	call   80102dc0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104a94:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a97:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104aa2:	e8 c9 fc ff ff       	call   80104770 <argstr>
80104aa7:	85 c0                	test   %eax,%eax
80104aa9:	78 4d                	js     80104af8 <sys_chdir+0x78>
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	89 04 24             	mov    %eax,(%esp)
80104ab1:	e8 ca d4 ff ff       	call   80101f80 <namei>
80104ab6:	85 c0                	test   %eax,%eax
80104ab8:	89 c6                	mov    %eax,%esi
80104aba:	74 3c                	je     80104af8 <sys_chdir+0x78>
    end_op();
    return -1;
  }
  ilock(ip);
80104abc:	89 04 24             	mov    %eax,(%esp)
80104abf:	e8 8c cf ff ff       	call   80101a50 <ilock>
  if(ip->type != T_DIR){
80104ac4:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104ac9:	75 25                	jne    80104af0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104acb:	89 34 24             	mov    %esi,(%esp)
80104ace:	e8 ad d2 ff ff       	call   80101d80 <iunlock>
  iput(curproc->cwd);
80104ad3:	8b 43 68             	mov    0x68(%ebx),%eax
80104ad6:	89 04 24             	mov    %eax,(%esp)
80104ad9:	e8 52 d0 ff ff       	call   80101b30 <iput>
  end_op();
80104ade:	e8 ad e1 ff ff       	call   80102c90 <end_op>
  curproc->cwd = ip;
80104ae3:	31 c0                	xor    %eax,%eax
80104ae5:	89 73 68             	mov    %esi,0x68(%ebx)
  return 0;
}
80104ae8:	83 c4 20             	add    $0x20,%esp
80104aeb:	5b                   	pop    %ebx
80104aec:	5e                   	pop    %esi
80104aed:	5d                   	pop    %ebp
80104aee:	c3                   	ret    
80104aef:	90                   	nop
    end_op();
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
80104af0:	89 34 24             	mov    %esi,(%esp)
80104af3:	e8 d8 d2 ff ff       	call   80101dd0 <iunlockput>
    end_op();
80104af8:	e8 93 e1 ff ff       	call   80102c90 <end_op>
  iunlock(ip);
  iput(curproc->cwd);
  end_op();
  curproc->cwd = ip;
  return 0;
}
80104afd:	83 c4 20             	add    $0x20,%esp
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
    end_op();
80104b00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  iunlock(ip);
  iput(curproc->cwd);
  end_op();
  curproc->cwd = ip;
  return 0;
}
80104b05:	5b                   	pop    %ebx
80104b06:	5e                   	pop    %esi
80104b07:	5d                   	pop    %ebp
80104b08:	c3                   	ret    
80104b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104b10 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104b10:	55                   	push   %ebp
80104b11:	89 e5                	mov    %esp,%ebp
80104b13:	83 ec 48             	sub    $0x48,%esp
80104b16:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80104b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b1c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104b1f:	8d 75 da             	lea    -0x26(%ebp),%esi
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104b22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104b25:	31 db                	xor    %ebx,%ebx
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104b27:	89 7d fc             	mov    %edi,-0x4(%ebp)
80104b2a:	89 d7                	mov    %edx,%edi
80104b2c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104b2f:	89 74 24 04          	mov    %esi,0x4(%esp)
80104b33:	89 04 24             	mov    %eax,(%esp)
80104b36:	e8 25 d4 ff ff       	call   80101f60 <nameiparent>
80104b3b:	85 c0                	test   %eax,%eax
80104b3d:	74 48                	je     80104b87 <create+0x77>
    return 0;
  ilock(dp);
80104b3f:	89 04 24             	mov    %eax,(%esp)
80104b42:	89 45 cc             	mov    %eax,-0x34(%ebp)
80104b45:	e8 06 cf ff ff       	call   80101a50 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104b4a:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104b4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80104b54:	00 
80104b55:	89 74 24 04          	mov    %esi,0x4(%esp)
80104b59:	89 14 24             	mov    %edx,(%esp)
80104b5c:	e8 6f cd ff ff       	call   801018d0 <dirlookup>
80104b61:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104b64:	85 c0                	test   %eax,%eax
80104b66:	89 c3                	mov    %eax,%ebx
80104b68:	74 3e                	je     80104ba8 <create+0x98>
    iunlockput(dp);
80104b6a:	89 14 24             	mov    %edx,(%esp)
80104b6d:	e8 5e d2 ff ff       	call   80101dd0 <iunlockput>
    ilock(ip);
80104b72:	89 1c 24             	mov    %ebx,(%esp)
80104b75:	e8 d6 ce ff ff       	call   80101a50 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104b7a:	66 83 ff 02          	cmp    $0x2,%di
80104b7e:	75 18                	jne    80104b98 <create+0x88>
80104b80:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104b85:	75 11                	jne    80104b98 <create+0x88>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104b87:	89 d8                	mov    %ebx,%eax
80104b89:	8b 75 f8             	mov    -0x8(%ebp),%esi
80104b8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80104b8f:	8b 7d fc             	mov    -0x4(%ebp),%edi
80104b92:	89 ec                	mov    %ebp,%esp
80104b94:	5d                   	pop    %ebp
80104b95:	c3                   	ret    
80104b96:	66 90                	xchg   %ax,%ax
  if((ip = dirlookup(dp, name, 0)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
80104b98:	89 1c 24             	mov    %ebx,(%esp)
80104b9b:	31 db                	xor    %ebx,%ebx
80104b9d:	e8 2e d2 ff ff       	call   80101dd0 <iunlockput>
    return 0;
80104ba2:	eb e3                	jmp    80104b87 <create+0x77>
80104ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80104ba8:	0f bf c7             	movswl %di,%eax
80104bab:	89 44 24 04          	mov    %eax,0x4(%esp)
80104baf:	8b 02                	mov    (%edx),%eax
80104bb1:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104bb4:	89 04 24             	mov    %eax,(%esp)
80104bb7:	e8 c4 cd ff ff       	call   80101980 <ialloc>
80104bbc:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104bbf:	85 c0                	test   %eax,%eax
80104bc1:	89 c3                	mov    %eax,%ebx
80104bc3:	0f 84 b7 00 00 00    	je     80104c80 <create+0x170>
    panic("create: ialloc");

  ilock(ip);
80104bc9:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104bcc:	89 04 24             	mov    %eax,(%esp)
80104bcf:	e8 7c ce ff ff       	call   80101a50 <ilock>
  ip->major = major;
80104bd4:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
80104bd8:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104bdc:	0f b7 4d d0          	movzwl -0x30(%ebp),%ecx
  ip->nlink = 1;
80104be0:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
80104be6:	66 89 4b 54          	mov    %cx,0x54(%ebx)
  ip->nlink = 1;
  iupdate(ip);
80104bea:	89 1c 24             	mov    %ebx,(%esp)
80104bed:	e8 2e c7 ff ff       	call   80101320 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80104bf2:	66 83 ff 01          	cmp    $0x1,%di
80104bf6:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104bf9:	74 2d                	je     80104c28 <create+0x118>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
80104bfb:	8b 43 04             	mov    0x4(%ebx),%eax
80104bfe:	89 14 24             	mov    %edx,(%esp)
80104c01:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104c04:	89 74 24 04          	mov    %esi,0x4(%esp)
80104c08:	89 44 24 08          	mov    %eax,0x8(%esp)
80104c0c:	e8 7f d0 ff ff       	call   80101c90 <dirlink>
80104c11:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104c14:	85 c0                	test   %eax,%eax
80104c16:	78 74                	js     80104c8c <create+0x17c>
    panic("create: dirlink");

  iunlockput(dp);
80104c18:	89 14 24             	mov    %edx,(%esp)
80104c1b:	e8 b0 d1 ff ff       	call   80101dd0 <iunlockput>

  return ip;
80104c20:	e9 62 ff ff ff       	jmp    80104b87 <create+0x77>
80104c25:	8d 76 00             	lea    0x0(%esi),%esi
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
80104c28:	66 83 42 56 01       	addw   $0x1,0x56(%edx)
    iupdate(dp);
80104c2d:	89 14 24             	mov    %edx,(%esp)
80104c30:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104c33:	e8 e8 c6 ff ff       	call   80101320 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104c38:	8b 43 04             	mov    0x4(%ebx),%eax
80104c3b:	c7 44 24 04 88 75 10 	movl   $0x80107588,0x4(%esp)
80104c42:	80 
80104c43:	89 1c 24             	mov    %ebx,(%esp)
80104c46:	89 44 24 08          	mov    %eax,0x8(%esp)
80104c4a:	e8 41 d0 ff ff       	call   80101c90 <dirlink>
80104c4f:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104c52:	85 c0                	test   %eax,%eax
80104c54:	78 1e                	js     80104c74 <create+0x164>
80104c56:	8b 42 04             	mov    0x4(%edx),%eax
80104c59:	c7 44 24 04 87 75 10 	movl   $0x80107587,0x4(%esp)
80104c60:	80 
80104c61:	89 1c 24             	mov    %ebx,(%esp)
80104c64:	89 44 24 08          	mov    %eax,0x8(%esp)
80104c68:	e8 23 d0 ff ff       	call   80101c90 <dirlink>
80104c6d:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104c70:	85 c0                	test   %eax,%eax
80104c72:	79 87                	jns    80104bfb <create+0xeb>
      panic("create dots");
80104c74:	c7 04 24 8a 75 10 80 	movl   $0x8010758a,(%esp)
80104c7b:	e8 30 b7 ff ff       	call   801003b0 <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
80104c80:	c7 04 24 78 75 10 80 	movl   $0x80107578,(%esp)
80104c87:	e8 24 b7 ff ff       	call   801003b0 <panic>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
80104c8c:	c7 04 24 96 75 10 80 	movl   $0x80107596,(%esp)
80104c93:	e8 18 b7 ff ff       	call   801003b0 <panic>
80104c98:	90                   	nop
80104c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104ca0 <sys_mknod>:
  return 0;
}

int
sys_mknod(void)
{
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
80104ca3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104ca6:	e8 15 e1 ff ff       	call   80102dc0 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104cab:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cae:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104cb9:	e8 b2 fa ff ff       	call   80104770 <argstr>
80104cbe:	85 c0                	test   %eax,%eax
80104cc0:	78 5e                	js     80104d20 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80104cc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104cd0:	e8 5b fa ff ff       	call   80104730 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80104cd5:	85 c0                	test   %eax,%eax
80104cd7:	78 47                	js     80104d20 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80104cd9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ce0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80104ce7:	e8 44 fa ff ff       	call   80104730 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80104cec:	85 c0                	test   %eax,%eax
80104cee:	78 30                	js     80104d20 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80104cf0:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104cf4:	ba 03 00 00 00       	mov    $0x3,%edx
80104cf9:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104cfd:	89 04 24             	mov    %eax,(%esp)
80104d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d03:	e8 08 fe ff ff       	call   80104b10 <create>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80104d08:	85 c0                	test   %eax,%eax
80104d0a:	74 14                	je     80104d20 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
    return -1;
  }
  iunlockput(ip);
80104d0c:	89 04 24             	mov    %eax,(%esp)
80104d0f:	e8 bc d0 ff ff       	call   80101dd0 <iunlockput>
  end_op();
80104d14:	e8 77 df ff ff       	call   80102c90 <end_op>
80104d19:	31 c0                	xor    %eax,%eax
  return 0;
}
80104d1b:	c9                   	leave  
80104d1c:	c3                   	ret    
80104d1d:	8d 76 00             	lea    0x0(%esi),%esi
  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80104d20:	e8 6b df ff ff       	call   80102c90 <end_op>
80104d25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  }
  iunlockput(ip);
  end_op();
  return 0;
}
80104d2a:	c9                   	leave  
80104d2b:	c3                   	ret    
80104d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104d30 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
80104d30:	55                   	push   %ebp
80104d31:	89 e5                	mov    %esp,%ebp
80104d33:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104d36:	e8 85 e0 ff ff       	call   80102dc0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104d3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104d49:	e8 22 fa ff ff       	call   80104770 <argstr>
80104d4e:	85 c0                	test   %eax,%eax
80104d50:	78 2e                	js     80104d80 <sys_mkdir+0x50>
80104d52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5c:	31 c9                	xor    %ecx,%ecx
80104d5e:	ba 01 00 00 00       	mov    $0x1,%edx
80104d63:	e8 a8 fd ff ff       	call   80104b10 <create>
80104d68:	85 c0                	test   %eax,%eax
80104d6a:	74 14                	je     80104d80 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104d6c:	89 04 24             	mov    %eax,(%esp)
80104d6f:	e8 5c d0 ff ff       	call   80101dd0 <iunlockput>
  end_op();
80104d74:	e8 17 df ff ff       	call   80102c90 <end_op>
80104d79:	31 c0                	xor    %eax,%eax
  return 0;
}
80104d7b:	c9                   	leave  
80104d7c:	c3                   	ret    
80104d7d:	8d 76 00             	lea    0x0(%esi),%esi
  char *path;
  struct inode *ip;

  begin_op();
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    end_op();
80104d80:	e8 0b df ff ff       	call   80102c90 <end_op>
80104d85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
  }
  iunlockput(ip);
  end_op();
  return 0;
}
80104d8a:	c9                   	leave  
80104d8b:	c3                   	ret    
80104d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104d90 <sys_link>:
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	83 ec 48             	sub    $0x48,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104d96:	8d 45 e0             	lea    -0x20(%ebp),%eax
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80104d99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
80104d9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
80104d9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104da2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104da6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104dad:	e8 be f9 ff ff       	call   80104770 <argstr>
80104db2:	85 c0                	test   %eax,%eax
80104db4:	79 12                	jns    80104dc8 <sys_link+0x38>
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  end_op();
  return -1;
80104db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80104dbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
80104dc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
80104dc4:	89 ec                	mov    %ebp,%esp
80104dc6:	5d                   	pop    %ebp
80104dc7:	c3                   	ret    
sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104dc8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dcf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104dd6:	e8 95 f9 ff ff       	call   80104770 <argstr>
80104ddb:	85 c0                	test   %eax,%eax
80104ddd:	78 d7                	js     80104db6 <sys_link+0x26>
    return -1;

  begin_op();
80104ddf:	e8 dc df ff ff       	call   80102dc0 <begin_op>
  if((ip = namei(old)) == 0){
80104de4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104de7:	89 04 24             	mov    %eax,(%esp)
80104dea:	e8 91 d1 ff ff       	call   80101f80 <namei>
80104def:	85 c0                	test   %eax,%eax
80104df1:	89 c3                	mov    %eax,%ebx
80104df3:	0f 84 a6 00 00 00    	je     80104e9f <sys_link+0x10f>
    end_op();
    return -1;
  }

  ilock(ip);
80104df9:	89 04 24             	mov    %eax,(%esp)
80104dfc:	e8 4f cc ff ff       	call   80101a50 <ilock>
  if(ip->type == T_DIR){
80104e01:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104e06:	0f 84 8b 00 00 00    	je     80104e97 <sys_link+0x107>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
80104e0c:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
80104e11:	8d 7d d2             	lea    -0x2e(%ebp),%edi
    end_op();
    return -1;
  }

  ip->nlink++;
  iupdate(ip);
80104e14:	89 1c 24             	mov    %ebx,(%esp)
80104e17:	e8 04 c5 ff ff       	call   80101320 <iupdate>
  iunlock(ip);
80104e1c:	89 1c 24             	mov    %ebx,(%esp)
80104e1f:	e8 5c cf ff ff       	call   80101d80 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80104e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e27:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104e2b:	89 04 24             	mov    %eax,(%esp)
80104e2e:	e8 2d d1 ff ff       	call   80101f60 <nameiparent>
80104e33:	85 c0                	test   %eax,%eax
80104e35:	89 c6                	mov    %eax,%esi
80104e37:	74 49                	je     80104e82 <sys_link+0xf2>
    goto bad;
  ilock(dp);
80104e39:	89 04 24             	mov    %eax,(%esp)
80104e3c:	e8 0f cc ff ff       	call   80101a50 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104e41:	8b 06                	mov    (%esi),%eax
80104e43:	3b 03                	cmp    (%ebx),%eax
80104e45:	75 33                	jne    80104e7a <sys_link+0xea>
80104e47:	8b 43 04             	mov    0x4(%ebx),%eax
80104e4a:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104e4e:	89 34 24             	mov    %esi,(%esp)
80104e51:	89 44 24 08          	mov    %eax,0x8(%esp)
80104e55:	e8 36 ce ff ff       	call   80101c90 <dirlink>
80104e5a:	85 c0                	test   %eax,%eax
80104e5c:	78 1c                	js     80104e7a <sys_link+0xea>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
80104e5e:	89 34 24             	mov    %esi,(%esp)
80104e61:	e8 6a cf ff ff       	call   80101dd0 <iunlockput>
  iput(ip);
80104e66:	89 1c 24             	mov    %ebx,(%esp)
80104e69:	e8 c2 cc ff ff       	call   80101b30 <iput>

  end_op();
80104e6e:	e8 1d de ff ff       	call   80102c90 <end_op>
80104e73:	31 c0                	xor    %eax,%eax

  return 0;
80104e75:	e9 41 ff ff ff       	jmp    80104dbb <sys_link+0x2b>

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
80104e7a:	89 34 24             	mov    %esi,(%esp)
80104e7d:	e8 4e cf ff ff       	call   80101dd0 <iunlockput>
  end_op();

  return 0;

bad:
  ilock(ip);
80104e82:	89 1c 24             	mov    %ebx,(%esp)
80104e85:	e8 c6 cb ff ff       	call   80101a50 <ilock>
  ip->nlink--;
80104e8a:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80104e8f:	89 1c 24             	mov    %ebx,(%esp)
80104e92:	e8 89 c4 ff ff       	call   80101320 <iupdate>
  iunlockput(ip);
80104e97:	89 1c 24             	mov    %ebx,(%esp)
80104e9a:	e8 31 cf ff ff       	call   80101dd0 <iunlockput>
  end_op();
80104e9f:	e8 ec dd ff ff       	call   80102c90 <end_op>
80104ea4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
80104ea9:	e9 0d ff ff ff       	jmp    80104dbb <sys_link+0x2b>
80104eae:	66 90                	xchg   %ax,%ax

80104eb0 <sys_open>:
  return ip;
}

int
sys_open(void)
{
80104eb0:	55                   	push   %ebp
80104eb1:	89 e5                	mov    %esp,%ebp
80104eb3:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104eb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return ip;
}

int
sys_open(void)
{
80104eb9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80104ebc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ec3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104eca:	e8 a1 f8 ff ff       	call   80104770 <argstr>
80104ecf:	85 c0                	test   %eax,%eax
80104ed1:	79 15                	jns    80104ee8 <sys_open+0x38>
  f->type = FD_INODE;
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
80104ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ed8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
80104edb:	8b 75 fc             	mov    -0x4(%ebp),%esi
80104ede:	89 ec                	mov    %ebp,%esp
80104ee0:	5d                   	pop    %ebp
80104ee1:	c3                   	ret    
80104ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104ee8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104eef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ef6:	e8 35 f8 ff ff       	call   80104730 <argint>
80104efb:	85 c0                	test   %eax,%eax
80104efd:	78 d4                	js     80104ed3 <sys_open+0x23>
    return -1;

  begin_op();
80104eff:	e8 bc de ff ff       	call   80102dc0 <begin_op>

  if(omode & O_CREATE){
80104f04:	f6 45 f1 02          	testb  $0x2,-0xf(%ebp)
80104f08:	74 76                	je     80104f80 <sys_open+0xd0>
    ip = create(path, T_FILE, 0, 0);
80104f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0d:	31 c9                	xor    %ecx,%ecx
80104f0f:	ba 02 00 00 00       	mov    $0x2,%edx
80104f14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104f1b:	e8 f0 fb ff ff       	call   80104b10 <create>
    if(ip == 0){
80104f20:	85 c0                	test   %eax,%eax
    return -1;

  begin_op();

  if(omode & O_CREATE){
    ip = create(path, T_FILE, 0, 0);
80104f22:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104f24:	0f 84 a2 00 00 00    	je     80104fcc <sys_open+0x11c>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104f2a:	e8 a1 c0 ff ff       	call   80100fd0 <filealloc>
80104f2f:	85 c0                	test   %eax,%eax
80104f31:	89 c3                	mov    %eax,%ebx
80104f33:	0f 84 8b 00 00 00    	je     80104fc4 <sys_open+0x114>
80104f39:	e8 52 f9 ff ff       	call   80104890 <fdalloc>
80104f3e:	85 c0                	test   %eax,%eax
80104f40:	78 7a                	js     80104fbc <sys_open+0x10c>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104f42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104f45:	89 34 24             	mov    %esi,(%esp)
80104f48:	e8 33 ce ff ff       	call   80101d80 <iunlock>
  end_op();
80104f4d:	e8 3e dd ff ff       	call   80102c90 <end_op>

  f->type = FD_INODE;
80104f52:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104f58:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104f5b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104f62:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f65:	83 f2 01             	xor    $0x1,%edx
80104f68:	83 e2 01             	and    $0x1,%edx
80104f6b:	88 53 08             	mov    %dl,0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104f6e:	f6 45 f0 03          	testb  $0x3,-0x10(%ebp)
80104f72:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
80104f76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104f79:	e9 5a ff ff ff       	jmp    80104ed8 <sys_open+0x28>
80104f7e:	66 90                	xchg   %ax,%ax
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80104f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f83:	89 04 24             	mov    %eax,(%esp)
80104f86:	e8 f5 cf ff ff       	call   80101f80 <namei>
80104f8b:	85 c0                	test   %eax,%eax
80104f8d:	89 c6                	mov    %eax,%esi
80104f8f:	74 3b                	je     80104fcc <sys_open+0x11c>
      end_op();
      return -1;
    }
    ilock(ip);
80104f91:	89 04 24             	mov    %eax,(%esp)
80104f94:	e8 b7 ca ff ff       	call   80101a50 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104f99:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104f9e:	75 8a                	jne    80104f2a <sys_open+0x7a>
80104fa0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80104fa3:	85 db                	test   %ebx,%ebx
80104fa5:	74 83                	je     80104f2a <sys_open+0x7a>
      iunlockput(ip);
80104fa7:	89 34 24             	mov    %esi,(%esp)
80104faa:	e8 21 ce ff ff       	call   80101dd0 <iunlockput>
      end_op();
80104faf:	e8 dc dc ff ff       	call   80102c90 <end_op>
80104fb4:	83 c8 ff             	or     $0xffffffff,%eax
      return -1;
80104fb7:	e9 1c ff ff ff       	jmp    80104ed8 <sys_open+0x28>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
80104fbc:	89 1c 24             	mov    %ebx,(%esp)
80104fbf:	e8 8c c0 ff ff       	call   80101050 <fileclose>
    iunlockput(ip);
80104fc4:	89 34 24             	mov    %esi,(%esp)
80104fc7:	e8 04 ce ff ff       	call   80101dd0 <iunlockput>
    end_op();
80104fcc:	e8 bf dc ff ff       	call   80102c90 <end_op>
80104fd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    return -1;
80104fd6:	e9 fd fe ff ff       	jmp    80104ed8 <sys_open+0x28>
80104fdb:	90                   	nop
80104fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104fe0 <sys_unlink>:
}

//PAGEBREAK!
int
sys_unlink(void)
{
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
80104fe3:	57                   	push   %edi
80104fe4:	56                   	push   %esi
80104fe5:	53                   	push   %ebx
80104fe6:	83 ec 6c             	sub    $0x6c,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80104fe9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104fec:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ff0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104ff7:	e8 74 f7 ff ff       	call   80104770 <argstr>
80104ffc:	89 c2                	mov    %eax,%edx
80104ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105003:	85 d2                	test   %edx,%edx
80105005:	0f 88 0b 01 00 00    	js     80105116 <sys_unlink+0x136>
    return -1;

  begin_op();
  if((dp = nameiparent(path, name)) == 0){
8010500b:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
  uint off;

  if(argstr(0, &path) < 0)
    return -1;

  begin_op();
8010500e:	e8 ad dd ff ff       	call   80102dc0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105013:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80105017:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010501a:	89 04 24             	mov    %eax,(%esp)
8010501d:	e8 3e cf ff ff       	call   80101f60 <nameiparent>
80105022:	85 c0                	test   %eax,%eax
80105024:	89 45 a4             	mov    %eax,-0x5c(%ebp)
80105027:	0f 84 53 01 00 00    	je     80105180 <sys_unlink+0x1a0>
    end_op();
    return -1;
  }

  ilock(dp);
8010502d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80105030:	89 04 24             	mov    %eax,(%esp)
80105033:	e8 18 ca ff ff       	call   80101a50 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105038:	c7 44 24 04 88 75 10 	movl   $0x80107588,0x4(%esp)
8010503f:	80 
80105040:	89 1c 24             	mov    %ebx,(%esp)
80105043:	e8 28 c2 ff ff       	call   80101270 <namecmp>
80105048:	85 c0                	test   %eax,%eax
8010504a:	0f 84 25 01 00 00    	je     80105175 <sys_unlink+0x195>
80105050:	c7 44 24 04 87 75 10 	movl   $0x80107587,0x4(%esp)
80105057:	80 
80105058:	89 1c 24             	mov    %ebx,(%esp)
8010505b:	e8 10 c2 ff ff       	call   80101270 <namecmp>
80105060:	85 c0                	test   %eax,%eax
80105062:	0f 84 0d 01 00 00    	je     80105175 <sys_unlink+0x195>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105068:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010506b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010506f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80105073:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80105076:	89 04 24             	mov    %eax,(%esp)
80105079:	e8 52 c8 ff ff       	call   801018d0 <dirlookup>
8010507e:	85 c0                	test   %eax,%eax
80105080:	89 c6                	mov    %eax,%esi
80105082:	0f 84 ed 00 00 00    	je     80105175 <sys_unlink+0x195>
    goto bad;
  ilock(ip);
80105088:	89 04 24             	mov    %eax,(%esp)
8010508b:	e8 c0 c9 ff ff       	call   80101a50 <ilock>

  if(ip->nlink < 1)
80105090:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
80105095:	0f 8e 2a 01 00 00    	jle    801051c5 <sys_unlink+0x1e5>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
8010509b:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801050a0:	74 7e                	je     80105120 <sys_unlink+0x140>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
801050a2:	8d 5d c2             	lea    -0x3e(%ebp),%ebx
801050a5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801050ac:	00 
801050ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801050b4:	00 
801050b5:	89 1c 24             	mov    %ebx,(%esp)
801050b8:	e8 83 f3 ff ff       	call   80104440 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801050bd:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801050c4:	00 
801050c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801050c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801050cc:	89 44 24 08          	mov    %eax,0x8(%esp)
801050d0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801050d3:	89 04 24             	mov    %eax,(%esp)
801050d6:	e8 c5 c5 ff ff       	call   801016a0 <writei>
801050db:	83 f8 10             	cmp    $0x10,%eax
801050de:	0f 85 d5 00 00 00    	jne    801051b9 <sys_unlink+0x1d9>
    panic("unlink: writei");
  if(ip->type == T_DIR){
801050e4:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801050e9:	0f 84 a9 00 00 00    	je     80105198 <sys_unlink+0x1b8>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
801050ef:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801050f2:	89 04 24             	mov    %eax,(%esp)
801050f5:	e8 d6 cc ff ff       	call   80101dd0 <iunlockput>

  ip->nlink--;
801050fa:	66 83 6e 56 01       	subw   $0x1,0x56(%esi)
  iupdate(ip);
801050ff:	89 34 24             	mov    %esi,(%esp)
80105102:	e8 19 c2 ff ff       	call   80101320 <iupdate>
  iunlockput(ip);
80105107:	89 34 24             	mov    %esi,(%esp)
8010510a:	e8 c1 cc ff ff       	call   80101dd0 <iunlockput>

  end_op();
8010510f:	e8 7c db ff ff       	call   80102c90 <end_op>
80105114:	31 c0                	xor    %eax,%eax

bad:
  iunlockput(dp);
  end_op();
  return -1;
}
80105116:	83 c4 6c             	add    $0x6c,%esp
80105119:	5b                   	pop    %ebx
8010511a:	5e                   	pop    %esi
8010511b:	5f                   	pop    %edi
8010511c:	5d                   	pop    %ebp
8010511d:	c3                   	ret    
8010511e:	66 90                	xchg   %ax,%ax
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105120:	83 7e 58 20          	cmpl   $0x20,0x58(%esi)
80105124:	0f 86 78 ff ff ff    	jbe    801050a2 <sys_unlink+0xc2>
8010512a:	8d 7d b2             	lea    -0x4e(%ebp),%edi
8010512d:	bb 20 00 00 00       	mov    $0x20,%ebx
80105132:	eb 10                	jmp    80105144 <sys_unlink+0x164>
80105134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105138:	83 c3 10             	add    $0x10,%ebx
8010513b:	3b 5e 58             	cmp    0x58(%esi),%ebx
8010513e:	0f 83 5e ff ff ff    	jae    801050a2 <sys_unlink+0xc2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105144:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010514b:	00 
8010514c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80105150:	89 7c 24 04          	mov    %edi,0x4(%esp)
80105154:	89 34 24             	mov    %esi,(%esp)
80105157:	e8 64 c6 ff ff       	call   801017c0 <readi>
8010515c:	83 f8 10             	cmp    $0x10,%eax
8010515f:	75 4c                	jne    801051ad <sys_unlink+0x1cd>
      panic("isdirempty: readi");
    if(de.inum != 0)
80105161:	66 83 7d b2 00       	cmpw   $0x0,-0x4e(%ebp)
80105166:	74 d0                	je     80105138 <sys_unlink+0x158>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
80105168:	89 34 24             	mov    %esi,(%esp)
8010516b:	90                   	nop
8010516c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105170:	e8 5b cc ff ff       	call   80101dd0 <iunlockput>
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105175:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80105178:	89 04 24             	mov    %eax,(%esp)
8010517b:	e8 50 cc ff ff       	call   80101dd0 <iunlockput>
  end_op();
80105180:	e8 0b db ff ff       	call   80102c90 <end_op>
  return -1;
}
80105185:	83 c4 6c             	add    $0x6c,%esp

  return 0;

bad:
  iunlockput(dp);
  end_op();
80105188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return -1;
}
8010518d:	5b                   	pop    %ebx
8010518e:	5e                   	pop    %esi
8010518f:	5f                   	pop    %edi
80105190:	5d                   	pop    %ebp
80105191:	c3                   	ret    
80105192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
80105198:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010519b:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
801051a0:	89 04 24             	mov    %eax,(%esp)
801051a3:	e8 78 c1 ff ff       	call   80101320 <iupdate>
801051a8:	e9 42 ff ff ff       	jmp    801050ef <sys_unlink+0x10f>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
801051ad:	c7 04 24 b8 75 10 80 	movl   $0x801075b8,(%esp)
801051b4:	e8 f7 b1 ff ff       	call   801003b0 <panic>
    goto bad;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
801051b9:	c7 04 24 ca 75 10 80 	movl   $0x801075ca,(%esp)
801051c0:	e8 eb b1 ff ff       	call   801003b0 <panic>
  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
801051c5:	c7 04 24 a6 75 10 80 	movl   $0x801075a6,(%esp)
801051cc:	e8 df b1 ff ff       	call   801003b0 <panic>
801051d1:	eb 0d                	jmp    801051e0 <T.62>
801051d3:	90                   	nop
801051d4:	90                   	nop
801051d5:	90                   	nop
801051d6:	90                   	nop
801051d7:	90                   	nop
801051d8:	90                   	nop
801051d9:	90                   	nop
801051da:	90                   	nop
801051db:	90                   	nop
801051dc:	90                   	nop
801051dd:	90                   	nop
801051de:	90                   	nop
801051df:	90                   	nop

801051e0 <T.62>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
801051e0:	55                   	push   %ebp
801051e1:	89 e5                	mov    %esp,%ebp
801051e3:	83 ec 28             	sub    $0x28,%esp
801051e6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
801051e9:	89 c3                	mov    %eax,%ebx
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
801051ee:	89 75 fc             	mov    %esi,-0x4(%ebp)
801051f1:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801051f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801051fe:	e8 2d f5 ff ff       	call   80104730 <argint>
80105203:	85 c0                	test   %eax,%eax
80105205:	79 11                	jns    80105218 <T.62+0x38>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
80105207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
8010520c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
8010520f:	8b 75 fc             	mov    -0x4(%ebp),%esi
80105212:	89 ec                	mov    %ebp,%esp
80105214:	5d                   	pop    %ebp
80105215:	c3                   	ret    
80105216:	66 90                	xchg   %ax,%ax
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105218:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010521c:	77 e9                	ja     80105207 <T.62+0x27>
8010521e:	e8 ed e8 ff ff       	call   80103b10 <myproc>
80105223:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105226:	8b 54 88 28          	mov    0x28(%eax,%ecx,4),%edx
8010522a:	85 d2                	test   %edx,%edx
8010522c:	74 d9                	je     80105207 <T.62+0x27>
    return -1;
  if(pfd)
8010522e:	85 db                	test   %ebx,%ebx
80105230:	74 02                	je     80105234 <T.62+0x54>
    *pfd = fd;
80105232:	89 0b                	mov    %ecx,(%ebx)
  if(pf)
80105234:	31 c0                	xor    %eax,%eax
80105236:	85 f6                	test   %esi,%esi
80105238:	74 d2                	je     8010520c <T.62+0x2c>
    *pf = f;
8010523a:	89 16                	mov    %edx,(%esi)
8010523c:	eb ce                	jmp    8010520c <T.62+0x2c>
8010523e:	66 90                	xchg   %ax,%ax

80105240 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
80105240:	55                   	push   %ebp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105241:	31 c0                	xor    %eax,%eax
  return -1;
}

int
sys_dup(void)
{
80105243:	89 e5                	mov    %esp,%ebp
80105245:	53                   	push   %ebx
80105246:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105249:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010524c:	e8 8f ff ff ff       	call   801051e0 <T.62>
80105251:	85 c0                	test   %eax,%eax
80105253:	79 13                	jns    80105268 <sys_dup+0x28>
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
80105255:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
8010525a:	89 d8                	mov    %ebx,%eax
8010525c:	83 c4 24             	add    $0x24,%esp
8010525f:	5b                   	pop    %ebx
80105260:	5d                   	pop    %ebp
80105261:	c3                   	ret    
80105262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
80105268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526b:	e8 20 f6 ff ff       	call   80104890 <fdalloc>
80105270:	85 c0                	test   %eax,%eax
80105272:	89 c3                	mov    %eax,%ebx
80105274:	78 df                	js     80105255 <sys_dup+0x15>
    return -1;
  filedup(f);
80105276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105279:	89 04 24             	mov    %eax,(%esp)
8010527c:	e8 ff bc ff ff       	call   80100f80 <filedup>
  return fd;
80105281:	eb d7                	jmp    8010525a <sys_dup+0x1a>
80105283:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105290 <sys_read>:
}

int
sys_read(void)
{
80105290:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105291:	31 c0                	xor    %eax,%eax
  return fd;
}

int
sys_read(void)
{
80105293:	89 e5                	mov    %esp,%ebp
80105295:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105298:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010529b:	e8 40 ff ff ff       	call   801051e0 <T.62>
801052a0:	85 c0                	test   %eax,%eax
801052a2:	79 0c                	jns    801052b0 <sys_read+0x20>
    return -1;
  return fileread(f, p, n);
801052a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052a9:	c9                   	leave  
801052aa:	c3                   	ret    
801052ab:	90                   	nop
801052ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801052b7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801052be:	e8 6d f4 ff ff       	call   80104730 <argint>
801052c3:	85 c0                	test   %eax,%eax
801052c5:	78 dd                	js     801052a4 <sys_read+0x14>
801052c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801052d1:	89 44 24 08          	mov    %eax,0x8(%esp)
801052d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801052d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801052dc:	e8 cf f4 ff ff       	call   801047b0 <argptr>
801052e1:	85 c0                	test   %eax,%eax
801052e3:	78 bf                	js     801052a4 <sys_read+0x14>
    return -1;
  return fileread(f, p, n);
801052e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e8:	89 44 24 08          	mov    %eax,0x8(%esp)
801052ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801052f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f6:	89 04 24             	mov    %eax,(%esp)
801052f9:	e8 82 bb ff ff       	call   80100e80 <fileread>
}
801052fe:	c9                   	leave  
801052ff:	c3                   	ret    

80105300 <sys_write>:

int
sys_write(void)
{
80105300:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105301:	31 c0                	xor    %eax,%eax
  return fileread(f, p, n);
}

int
sys_write(void)
{
80105303:	89 e5                	mov    %esp,%ebp
80105305:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105308:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010530b:	e8 d0 fe ff ff       	call   801051e0 <T.62>
80105310:	85 c0                	test   %eax,%eax
80105312:	79 0c                	jns    80105320 <sys_write+0x20>
    return -1;
  return filewrite(f, p, n);
80105314:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105319:	c9                   	leave  
8010531a:	c3                   	ret    
8010531b:	90                   	nop
8010531c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105320:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105323:	89 44 24 04          	mov    %eax,0x4(%esp)
80105327:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010532e:	e8 fd f3 ff ff       	call   80104730 <argint>
80105333:	85 c0                	test   %eax,%eax
80105335:	78 dd                	js     80105314 <sys_write+0x14>
80105337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010533a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105341:	89 44 24 08          	mov    %eax,0x8(%esp)
80105345:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105348:	89 44 24 04          	mov    %eax,0x4(%esp)
8010534c:	e8 5f f4 ff ff       	call   801047b0 <argptr>
80105351:	85 c0                	test   %eax,%eax
80105353:	78 bf                	js     80105314 <sys_write+0x14>
    return -1;
  return filewrite(f, p, n);
80105355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105358:	89 44 24 08          	mov    %eax,0x8(%esp)
8010535c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010535f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105366:	89 04 24             	mov    %eax,(%esp)
80105369:	e8 f2 b9 ff ff       	call   80100d60 <filewrite>
}
8010536e:	c9                   	leave  
8010536f:	c3                   	ret    

80105370 <sys_fstat>:
  return 0;
}

int
sys_fstat(void)
{
80105370:	55                   	push   %ebp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105371:	31 c0                	xor    %eax,%eax
  return 0;
}

int
sys_fstat(void)
{
80105373:	89 e5                	mov    %esp,%ebp
80105375:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105378:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010537b:	e8 60 fe ff ff       	call   801051e0 <T.62>
80105380:	85 c0                	test   %eax,%eax
80105382:	79 0c                	jns    80105390 <sys_fstat+0x20>
    return -1;
  return filestat(f, st);
80105384:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105389:	c9                   	leave  
8010538a:	c3                   	ret    
8010538b:	90                   	nop
8010538c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
sys_fstat(void)
{
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105390:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105393:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010539a:	00 
8010539b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010539f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801053a6:	e8 05 f4 ff ff       	call   801047b0 <argptr>
801053ab:	85 c0                	test   %eax,%eax
801053ad:	78 d5                	js     80105384 <sys_fstat+0x14>
    return -1;
  return filestat(f, st);
801053af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801053b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b9:	89 04 24             	mov    %eax,(%esp)
801053bc:	e8 6f bb ff ff       	call   80100f30 <filestat>
}
801053c1:	c9                   	leave  
801053c2:	c3                   	ret    
801053c3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801053c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801053d0 <sys_close>:
  return filewrite(f, p, n);
}

int
sys_close(void)
{
801053d0:	55                   	push   %ebp
801053d1:	89 e5                	mov    %esp,%ebp
801053d3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053d6:	8d 55 f0             	lea    -0x10(%ebp),%edx
801053d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053dc:	e8 ff fd ff ff       	call   801051e0 <T.62>
801053e1:	89 c2                	mov    %eax,%edx
801053e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e8:	85 d2                	test   %edx,%edx
801053ea:	78 1d                	js     80105409 <sys_close+0x39>
    return -1;
  myproc()->ofile[fd] = 0;
801053ec:	e8 1f e7 ff ff       	call   80103b10 <myproc>
801053f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053f4:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801053fb:	00 
  fileclose(f);
801053fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ff:	89 04 24             	mov    %eax,(%esp)
80105402:	e8 49 bc ff ff       	call   80101050 <fileclose>
80105407:	31 c0                	xor    %eax,%eax
  return 0;
}
80105409:	c9                   	leave  
8010540a:	c3                   	ret    
8010540b:	00 00                	add    %al,(%eax)
8010540d:	00 00                	add    %al,(%eax)
	...

80105410 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	53                   	push   %ebx
80105414:	83 ec 14             	sub    $0x14,%esp
  uint xticks;

  acquire(&tickslock);
80105417:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
8010541e:	e8 ad ef ff ff       	call   801043d0 <acquire>
  xticks = ticks;
80105423:	8b 1d c0 54 11 80    	mov    0x801154c0,%ebx
  release(&tickslock);
80105429:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
80105430:	e8 4b ef ff ff       	call   80104380 <release>
  return xticks;
}
80105435:	83 c4 14             	add    $0x14,%esp
80105438:	89 d8                	mov    %ebx,%eax
8010543a:	5b                   	pop    %ebx
8010543b:	5d                   	pop    %ebp
8010543c:	c3                   	ret    
8010543d:	8d 76 00             	lea    0x0(%esi),%esi

80105440 <sys_getpid>:
  return kill(pid);
}

int
sys_getpid(void)
{
80105440:	55                   	push   %ebp
80105441:	89 e5                	mov    %esp,%ebp
80105443:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105446:	e8 c5 e6 ff ff       	call   80103b10 <myproc>
8010544b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010544e:	c9                   	leave  
8010544f:	c3                   	ret    

80105450 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
80105450:	55                   	push   %ebp
80105451:	89 e5                	mov    %esp,%ebp
80105453:	53                   	push   %ebx
80105454:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105457:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010545a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010545e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105465:	e8 c6 f2 ff ff       	call   80104730 <argint>
8010546a:	89 c2                	mov    %eax,%edx
8010546c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105471:	85 d2                	test   %edx,%edx
80105473:	78 58                	js     801054cd <sys_sleep+0x7d>
    return -1;
  acquire(&tickslock);
80105475:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
8010547c:	e8 4f ef ff ff       	call   801043d0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105481:	8b 55 f4             	mov    -0xc(%ebp),%edx
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
80105484:	8b 1d c0 54 11 80    	mov    0x801154c0,%ebx
  while(ticks - ticks0 < n){
8010548a:	85 d2                	test   %edx,%edx
8010548c:	75 22                	jne    801054b0 <sys_sleep+0x60>
8010548e:	eb 48                	jmp    801054d8 <sys_sleep+0x88>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105490:	c7 44 24 04 80 4c 11 	movl   $0x80114c80,0x4(%esp)
80105497:	80 
80105498:	c7 04 24 c0 54 11 80 	movl   $0x801154c0,(%esp)
8010549f:	e8 cc e8 ff ff       	call   80103d70 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801054a4:	a1 c0 54 11 80       	mov    0x801154c0,%eax
801054a9:	29 d8                	sub    %ebx,%eax
801054ab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801054ae:	73 28                	jae    801054d8 <sys_sleep+0x88>
    if(myproc()->killed){
801054b0:	e8 5b e6 ff ff       	call   80103b10 <myproc>
801054b5:	8b 40 24             	mov    0x24(%eax),%eax
801054b8:	85 c0                	test   %eax,%eax
801054ba:	74 d4                	je     80105490 <sys_sleep+0x40>
      release(&tickslock);
801054bc:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
801054c3:	e8 b8 ee ff ff       	call   80104380 <release>
801054c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
801054cd:	83 c4 24             	add    $0x24,%esp
801054d0:	5b                   	pop    %ebx
801054d1:	5d                   	pop    %ebp
801054d2:	c3                   	ret    
801054d3:	90                   	nop
801054d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801054d8:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
801054df:	e8 9c ee ff ff       	call   80104380 <release>
  return 0;
}
801054e4:	83 c4 24             	add    $0x24,%esp
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801054e7:	31 c0                	xor    %eax,%eax
  return 0;
}
801054e9:	5b                   	pop    %ebx
801054ea:	5d                   	pop    %ebp
801054eb:	c3                   	ret    
801054ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801054f0 <sys_sbrk>:
  return myproc()->pid;
}

int
sys_sbrk(void)
{
801054f0:	55                   	push   %ebp
801054f1:	89 e5                	mov    %esp,%ebp
801054f3:	53                   	push   %ebx
801054f4:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801054f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801054fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105505:	e8 26 f2 ff ff       	call   80104730 <argint>
8010550a:	85 c0                	test   %eax,%eax
8010550c:	79 12                	jns    80105520 <sys_sbrk+0x30>
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
8010550e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105513:	83 c4 24             	add    $0x24,%esp
80105516:	5b                   	pop    %ebx
80105517:	5d                   	pop    %ebp
80105518:	c3                   	ret    
80105519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
80105520:	e8 eb e5 ff ff       	call   80103b10 <myproc>
80105525:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010552a:	89 04 24             	mov    %eax,(%esp)
8010552d:	e8 1e e7 ff ff       	call   80103c50 <growproc>
80105532:	89 c2                	mov    %eax,%edx
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
80105534:	89 d8                	mov    %ebx,%eax
  if(growproc(n) < 0)
80105536:	85 d2                	test   %edx,%edx
80105538:	79 d9                	jns    80105513 <sys_sbrk+0x23>
8010553a:	eb d2                	jmp    8010550e <sys_sbrk+0x1e>
8010553c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105540 <sys_kill>:
  return wait();
}

int
sys_kill(void)
{
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105546:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105549:	89 44 24 04          	mov    %eax,0x4(%esp)
8010554d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105554:	e8 d7 f1 ff ff       	call   80104730 <argint>
80105559:	89 c2                	mov    %eax,%edx
8010555b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105560:	85 d2                	test   %edx,%edx
80105562:	78 0b                	js     8010556f <sys_kill+0x2f>
    return -1;
  return kill(pid);
80105564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105567:	89 04 24             	mov    %eax,(%esp)
8010556a:	e8 61 e1 ff ff       	call   801036d0 <kill>
}
8010556f:	c9                   	leave  
80105570:	c3                   	ret    
80105571:	eb 0d                	jmp    80105580 <sys_wait>
80105573:	90                   	nop
80105574:	90                   	nop
80105575:	90                   	nop
80105576:	90                   	nop
80105577:	90                   	nop
80105578:	90                   	nop
80105579:	90                   	nop
8010557a:	90                   	nop
8010557b:	90                   	nop
8010557c:	90                   	nop
8010557d:	90                   	nop
8010557e:	90                   	nop
8010557f:	90                   	nop

80105580 <sys_wait>:
  return 0;  // not reached
}

int
sys_wait(void)
{
80105580:	55                   	push   %ebp
80105581:	89 e5                	mov    %esp,%ebp
80105583:	83 ec 08             	sub    $0x8,%esp
  return wait();
}
80105586:	c9                   	leave  
}

int
sys_wait(void)
{
  return wait();
80105587:	e9 a4 e8 ff ff       	jmp    80103e30 <wait>
8010558c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105590 <sys_exit>:
  return fork();
}

int
sys_exit(void)
{
80105590:	55                   	push   %ebp
80105591:	89 e5                	mov    %esp,%ebp
80105593:	83 ec 08             	sub    $0x8,%esp
  exit();
80105596:	e8 c5 e9 ff ff       	call   80103f60 <exit>
  return 0;  // not reached
}
8010559b:	31 c0                	xor    %eax,%eax
8010559d:	c9                   	leave  
8010559e:	c3                   	ret    
8010559f:	90                   	nop

801055a0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801055a0:	55                   	push   %ebp
801055a1:	89 e5                	mov    %esp,%ebp
801055a3:	83 ec 08             	sub    $0x8,%esp
  return fork();
}
801055a6:	c9                   	leave  
#include "proc.h"

int
sys_fork(void)
{
  return fork();
801055a7:	e9 94 e5 ff ff       	jmp    80103b40 <fork>

801055ac <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801055ac:	1e                   	push   %ds
  pushl %es
801055ad:	06                   	push   %es
  pushl %fs
801055ae:	0f a0                	push   %fs
  pushl %gs
801055b0:	0f a8                	push   %gs
  pushal
801055b2:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801055b3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801055b7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801055b9:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801055bb:	54                   	push   %esp
  call trap
801055bc:	e8 3f 00 00 00       	call   80105600 <trap>
  addl $4, %esp
801055c1:	83 c4 04             	add    $0x4,%esp

801055c4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801055c4:	61                   	popa   
  popl %gs
801055c5:	0f a9                	pop    %gs
  popl %fs
801055c7:	0f a1                	pop    %fs
  popl %es
801055c9:	07                   	pop    %es
  popl %ds
801055ca:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801055cb:	83 c4 08             	add    $0x8,%esp
  iret
801055ce:	cf                   	iret   
	...

801055d0 <idtinit>:
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
801055d0:	55                   	push   %ebp
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
  pd[1] = (uint)p;
801055d1:	b8 c0 4c 11 80       	mov    $0x80114cc0,%eax
801055d6:	89 e5                	mov    %esp,%ebp
801055d8:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
801055db:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
801055e1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801055e5:	c1 e8 10             	shr    $0x10,%eax
801055e8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801055ec:	8d 45 fa             	lea    -0x6(%ebp),%eax
801055ef:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801055f2:	c9                   	leave  
801055f3:	c3                   	ret    
801055f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801055fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80105600 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	83 ec 48             	sub    $0x48,%esp
80105606:	89 5d f4             	mov    %ebx,-0xc(%ebp)
80105609:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010560c:	89 75 f8             	mov    %esi,-0x8(%ebp)
8010560f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  if(tf->trapno == T_SYSCALL){
80105612:	8b 43 30             	mov    0x30(%ebx),%eax
80105615:	83 f8 40             	cmp    $0x40,%eax
80105618:	0f 84 02 02 00 00    	je     80105820 <trap+0x220>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010561e:	83 e8 20             	sub    $0x20,%eax
80105621:	83 f8 1f             	cmp    $0x1f,%eax
80105624:	0f 86 fe 00 00 00    	jbe    80105728 <trap+0x128>
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010562a:	e8 e1 e4 ff ff       	call   80103b10 <myproc>
8010562f:	85 c0                	test   %eax,%eax
80105631:	0f 84 43 02 00 00    	je     8010587a <trap+0x27a>
80105637:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010563b:	0f 84 39 02 00 00    	je     8010587a <trap+0x27a>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105641:	0f 20 d2             	mov    %cr2,%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105644:	8b 7b 38             	mov    0x38(%ebx),%edi
80105647:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010564a:	e8 31 ea ff ff       	call   80104080 <cpuid>
8010564f:	8b 4b 34             	mov    0x34(%ebx),%ecx
80105652:	89 c6                	mov    %eax,%esi
80105654:	8b 43 30             	mov    0x30(%ebx),%eax
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80105657:	89 4d d8             	mov    %ecx,-0x28(%ebp)
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010565a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010565d:	e8 ae e4 ff ff       	call   80103b10 <myproc>
80105662:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105665:	e8 a6 e4 ff ff       	call   80103b10 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010566a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010566d:	89 7c 24 18          	mov    %edi,0x18(%esp)
80105671:	89 74 24 14          	mov    %esi,0x14(%esp)
80105675:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80105679:	8b 4d d8             	mov    -0x28(%ebp),%ecx
8010567c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80105680:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105683:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105687:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010568a:	83 c2 6c             	add    $0x6c,%edx
8010568d:	89 54 24 08          	mov    %edx,0x8(%esp)
80105691:	8b 40 10             	mov    0x10(%eax),%eax
80105694:	c7 04 24 34 76 10 80 	movl   $0x80107634,(%esp)
8010569b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010569f:	e8 ac b1 ff ff       	call   80100850 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801056a4:	e8 67 e4 ff ff       	call   80103b10 <myproc>
801056a9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801056b0:	e8 5b e4 ff ff       	call   80103b10 <myproc>
801056b5:	85 c0                	test   %eax,%eax
801056b7:	74 1c                	je     801056d5 <trap+0xd5>
801056b9:	e8 52 e4 ff ff       	call   80103b10 <myproc>
801056be:	8b 50 24             	mov    0x24(%eax),%edx
801056c1:	85 d2                	test   %edx,%edx
801056c3:	74 10                	je     801056d5 <trap+0xd5>
801056c5:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801056c9:	83 e0 03             	and    $0x3,%eax
801056cc:	83 f8 03             	cmp    $0x3,%eax
801056cf:	0f 84 8b 01 00 00    	je     80105860 <trap+0x260>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801056d5:	e8 36 e4 ff ff       	call   80103b10 <myproc>
801056da:	85 c0                	test   %eax,%eax
801056dc:	74 11                	je     801056ef <trap+0xef>
801056de:	66 90                	xchg   %ax,%ax
801056e0:	e8 2b e4 ff ff       	call   80103b10 <myproc>
801056e5:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801056e9:	0f 84 11 01 00 00    	je     80105800 <trap+0x200>
801056ef:	90                   	nop
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801056f0:	e8 1b e4 ff ff       	call   80103b10 <myproc>
801056f5:	85 c0                	test   %eax,%eax
801056f7:	74 1c                	je     80105715 <trap+0x115>
801056f9:	e8 12 e4 ff ff       	call   80103b10 <myproc>
801056fe:	8b 40 24             	mov    0x24(%eax),%eax
80105701:	85 c0                	test   %eax,%eax
80105703:	74 10                	je     80105715 <trap+0x115>
80105705:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105709:	83 e0 03             	and    $0x3,%eax
8010570c:	83 f8 03             	cmp    $0x3,%eax
8010570f:	0f 84 34 01 00 00    	je     80105849 <trap+0x249>
    exit();
}
80105715:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80105718:	8b 75 f8             	mov    -0x8(%ebp),%esi
8010571b:	8b 7d fc             	mov    -0x4(%ebp),%edi
8010571e:	89 ec                	mov    %ebp,%esp
80105720:	5d                   	pop    %ebp
80105721:	c3                   	ret    
80105722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105728:	ff 24 85 84 76 10 80 	jmp    *-0x7fef897c(,%eax,4)
8010572f:	90                   	nop
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80105730:	e8 ab ca ff ff       	call   801021e0 <ideintr>
80105735:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
80105738:	e8 c3 d0 ff ff       	call   80102800 <lapiceoi>
8010573d:	8d 76 00             	lea    0x0(%esi),%esi
    break;
80105740:	e9 6b ff ff ff       	jmp    801056b0 <trap+0xb0>
80105745:	8d 76 00             	lea    0x0(%esi),%esi
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105748:	8b 7b 38             	mov    0x38(%ebx),%edi
8010574b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
8010574f:	e8 2c e9 ff ff       	call   80104080 <cpuid>
80105754:	c7 04 24 dc 75 10 80 	movl   $0x801075dc,(%esp)
8010575b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
8010575f:	89 74 24 08          	mov    %esi,0x8(%esp)
80105763:	89 44 24 04          	mov    %eax,0x4(%esp)
80105767:	e8 e4 b0 ff ff       	call   80100850 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
8010576c:	e8 8f d0 ff ff       	call   80102800 <lapiceoi>
    break;
80105771:	e9 3a ff ff ff       	jmp    801056b0 <trap+0xb0>
80105776:	66 90                	xchg   %ax,%ax
80105778:	90                   	nop
80105779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80105780:	e8 eb 01 00 00       	call   80105970 <uartintr>
80105785:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
80105788:	e8 73 d0 ff ff       	call   80102800 <lapiceoi>
8010578d:	8d 76 00             	lea    0x0(%esi),%esi
    break;
80105790:	e9 1b ff ff ff       	jmp    801056b0 <trap+0xb0>
80105795:	8d 76 00             	lea    0x0(%esi),%esi
80105798:	90                   	nop
80105799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801057a0:	e8 db ce ff ff       	call   80102680 <kbdintr>
801057a5:	8d 76 00             	lea    0x0(%esi),%esi
    lapiceoi();
801057a8:	e8 53 d0 ff ff       	call   80102800 <lapiceoi>
801057ad:	8d 76 00             	lea    0x0(%esi),%esi
    break;
801057b0:	e9 fb fe ff ff       	jmp    801056b0 <trap+0xb0>
801057b5:	8d 76 00             	lea    0x0(%esi),%esi
801057b8:	90                   	nop
801057b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801057c0:	e8 bb e8 ff ff       	call   80104080 <cpuid>
801057c5:	85 c0                	test   %eax,%eax
801057c7:	0f 85 68 ff ff ff    	jne    80105735 <trap+0x135>
      acquire(&tickslock);
801057cd:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
801057d4:	e8 f7 eb ff ff       	call   801043d0 <acquire>
      ticks++;
801057d9:	83 05 c0 54 11 80 01 	addl   $0x1,0x801154c0
      wakeup(&ticks);
801057e0:	c7 04 24 c0 54 11 80 	movl   $0x801154c0,(%esp)
801057e7:	e8 74 df ff ff       	call   80103760 <wakeup>
      release(&tickslock);
801057ec:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
801057f3:	e8 88 eb ff ff       	call   80104380 <release>
801057f8:	e9 38 ff ff ff       	jmp    80105735 <trap+0x135>
801057fd:	8d 76 00             	lea    0x0(%esi),%esi
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
80105800:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105804:	0f 85 e5 fe ff ff    	jne    801056ef <trap+0xef>
8010580a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    yield();
80105810:	e8 0b e7 ff ff       	call   80103f20 <yield>
80105815:	e9 d5 fe ff ff       	jmp    801056ef <trap+0xef>
8010581a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
80105820:	e8 eb e2 ff ff       	call   80103b10 <myproc>
80105825:	8b 70 24             	mov    0x24(%eax),%esi
80105828:	85 f6                	test   %esi,%esi
8010582a:	75 44                	jne    80105870 <trap+0x270>
      exit();
    myproc()->tf = tf;
8010582c:	e8 df e2 ff ff       	call   80103b10 <myproc>
80105831:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105834:	e8 d7 ef ff ff       	call   80104810 <syscall>
    if(myproc()->killed)
80105839:	e8 d2 e2 ff ff       	call   80103b10 <myproc>
8010583e:	8b 48 24             	mov    0x24(%eax),%ecx
80105841:	85 c9                	test   %ecx,%ecx
80105843:	0f 84 cc fe ff ff    	je     80105715 <trap+0x115>
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80105849:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010584c:	8b 75 f8             	mov    -0x8(%ebp),%esi
8010584f:	8b 7d fc             	mov    -0x4(%ebp),%edi
80105852:	89 ec                	mov    %ebp,%esp
80105854:	5d                   	pop    %ebp
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
80105855:	e9 06 e7 ff ff       	jmp    80103f60 <exit>
8010585a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
80105860:	e8 fb e6 ff ff       	call   80103f60 <exit>
80105865:	e9 6b fe ff ff       	jmp    801056d5 <trap+0xd5>
8010586a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
80105870:	e8 eb e6 ff ff       	call   80103f60 <exit>
80105875:	8d 76 00             	lea    0x0(%esi),%esi
80105878:	eb b2                	jmp    8010582c <trap+0x22c>
8010587a:	0f 20 d7             	mov    %cr2,%edi

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010587d:	8b 73 38             	mov    0x38(%ebx),%esi
80105880:	e8 fb e7 ff ff       	call   80104080 <cpuid>
80105885:	89 7c 24 10          	mov    %edi,0x10(%esp)
80105889:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010588d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105891:	8b 43 30             	mov    0x30(%ebx),%eax
80105894:	c7 04 24 00 76 10 80 	movl   $0x80107600,(%esp)
8010589b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010589f:	e8 ac af ff ff       	call   80100850 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801058a4:	c7 04 24 77 76 10 80 	movl   $0x80107677,(%esp)
801058ab:	e8 00 ab ff ff       	call   801003b0 <panic>

801058b0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801058b0:	55                   	push   %ebp
801058b1:	31 c0                	xor    %eax,%eax
801058b3:	89 e5                	mov    %esp,%ebp
801058b5:	ba c0 4c 11 80       	mov    $0x80114cc0,%edx
801058ba:	83 ec 18             	sub    $0x18,%esp
801058bd:	8d 76 00             	lea    0x0(%esi),%esi
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801058c0:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
801058c7:	66 89 0c c5 c0 4c 11 	mov    %cx,-0x7feeb340(,%eax,8)
801058ce:	80 
801058cf:	c1 e9 10             	shr    $0x10,%ecx
801058d2:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
801058d9:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
801058de:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
801058e3:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801058e8:	83 c0 01             	add    $0x1,%eax
801058eb:	3d 00 01 00 00       	cmp    $0x100,%eax
801058f0:	75 ce                	jne    801058c0 <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801058f2:	a1 08 a1 10 80       	mov    0x8010a108,%eax

  initlock(&tickslock, "time");
801058f7:	c7 44 24 04 7c 76 10 	movl   $0x8010767c,0x4(%esp)
801058fe:	80 
801058ff:	c7 04 24 80 4c 11 80 	movl   $0x80114c80,(%esp)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105906:	66 c7 05 c2 4e 11 80 	movw   $0x8,0x80114ec2
8010590d:	08 00 
8010590f:	66 a3 c0 4e 11 80    	mov    %ax,0x80114ec0
80105915:	c1 e8 10             	shr    $0x10,%eax
80105918:	c6 05 c4 4e 11 80 00 	movb   $0x0,0x80114ec4
8010591f:	c6 05 c5 4e 11 80 ef 	movb   $0xef,0x80114ec5
80105926:	66 a3 c6 4e 11 80    	mov    %ax,0x80114ec6

  initlock(&tickslock, "time");
8010592c:	e8 cf e8 ff ff       	call   80104200 <initlock>
}
80105931:	c9                   	leave  
80105932:	c3                   	ret    
	...

80105940 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105940:	a1 c4 a5 10 80       	mov    0x8010a5c4,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105945:	55                   	push   %ebp
80105946:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105948:	85 c0                	test   %eax,%eax
8010594a:	75 0c                	jne    80105958 <uartgetc+0x18>
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
8010594c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105951:	5d                   	pop    %ebp
80105952:	c3                   	ret    
80105953:	90                   	nop
80105954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105958:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010595d:	ec                   	in     (%dx),%al
static int
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010595e:	a8 01                	test   $0x1,%al
80105960:	74 ea                	je     8010594c <uartgetc+0xc>
80105962:	b2 f8                	mov    $0xf8,%dl
80105964:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105965:	0f b6 c0             	movzbl %al,%eax
}
80105968:	5d                   	pop    %ebp
80105969:	c3                   	ret    
8010596a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105970 <uartintr>:

void
uartintr(void)
{
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80105976:	c7 04 24 40 59 10 80 	movl   $0x80105940,(%esp)
8010597d:	e8 9e ac ff ff       	call   80100620 <consoleintr>
}
80105982:	c9                   	leave  
80105983:	c3                   	ret    
80105984:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010598a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80105990 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	56                   	push   %esi
80105994:	be fd 03 00 00       	mov    $0x3fd,%esi
80105999:	53                   	push   %ebx
  int i;

  if(!uart)
8010599a:	31 db                	xor    %ebx,%ebx
    uartputc(*p);
}

void
uartputc(int c)
{
8010599c:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
8010599f:	8b 15 c4 a5 10 80    	mov    0x8010a5c4,%edx
801059a5:	85 d2                	test   %edx,%edx
801059a7:	75 1e                	jne    801059c7 <uartputc+0x37>
801059a9:	eb 2c                	jmp    801059d7 <uartputc+0x47>
801059ab:	90                   	nop
801059ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801059b0:	83 c3 01             	add    $0x1,%ebx
    microdelay(10);
801059b3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801059ba:	e8 61 ce ff ff       	call   80102820 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801059bf:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
801059c5:	74 07                	je     801059ce <uartputc+0x3e>
801059c7:	89 f2                	mov    %esi,%edx
801059c9:	ec                   	in     (%dx),%al
801059ca:	a8 20                	test   $0x20,%al
801059cc:	74 e2                	je     801059b0 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801059ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
801059d3:	8b 45 08             	mov    0x8(%ebp),%eax
801059d6:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
801059d7:	83 c4 10             	add    $0x10,%esp
801059da:	5b                   	pop    %ebx
801059db:	5e                   	pop    %esi
801059dc:	5d                   	pop    %ebp
801059dd:	c3                   	ret    
801059de:	66 90                	xchg   %ax,%ax

801059e0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801059e0:	55                   	push   %ebp
801059e1:	31 c9                	xor    %ecx,%ecx
801059e3:	89 e5                	mov    %esp,%ebp
801059e5:	89 c8                	mov    %ecx,%eax
801059e7:	57                   	push   %edi
801059e8:	bf fa 03 00 00       	mov    $0x3fa,%edi
801059ed:	56                   	push   %esi
801059ee:	89 fa                	mov    %edi,%edx
801059f0:	53                   	push   %ebx
801059f1:	83 ec 1c             	sub    $0x1c,%esp
801059f4:	ee                   	out    %al,(%dx)
801059f5:	bb fb 03 00 00       	mov    $0x3fb,%ebx
801059fa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801059ff:	89 da                	mov    %ebx,%edx
80105a01:	ee                   	out    %al,(%dx)
80105a02:	b8 0c 00 00 00       	mov    $0xc,%eax
80105a07:	b2 f8                	mov    $0xf8,%dl
80105a09:	ee                   	out    %al,(%dx)
80105a0a:	be f9 03 00 00       	mov    $0x3f9,%esi
80105a0f:	89 c8                	mov    %ecx,%eax
80105a11:	89 f2                	mov    %esi,%edx
80105a13:	ee                   	out    %al,(%dx)
80105a14:	b8 03 00 00 00       	mov    $0x3,%eax
80105a19:	89 da                	mov    %ebx,%edx
80105a1b:	ee                   	out    %al,(%dx)
80105a1c:	b2 fc                	mov    $0xfc,%dl
80105a1e:	89 c8                	mov    %ecx,%eax
80105a20:	ee                   	out    %al,(%dx)
80105a21:	b8 01 00 00 00       	mov    $0x1,%eax
80105a26:	89 f2                	mov    %esi,%edx
80105a28:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105a29:	b2 fd                	mov    $0xfd,%dl
80105a2b:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80105a2c:	3c ff                	cmp    $0xff,%al
80105a2e:	74 45                	je     80105a75 <uartinit+0x95>
    return;
  uart = 1;
80105a30:	c7 05 c4 a5 10 80 01 	movl   $0x1,0x8010a5c4
80105a37:	00 00 00 
80105a3a:	89 fa                	mov    %edi,%edx
80105a3c:	ec                   	in     (%dx),%al
80105a3d:	b2 f8                	mov    $0xf8,%dl
80105a3f:	ec                   	in     (%dx),%al

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);
80105a40:	bb 04 77 10 80       	mov    $0x80107704,%ebx
80105a45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a4c:	00 
80105a4d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80105a54:	e8 a7 c8 ff ff       	call   80102300 <ioapicenable>
80105a59:	b8 78 00 00 00       	mov    $0x78,%eax
80105a5e:	66 90                	xchg   %ax,%ax

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
80105a60:	0f be c0             	movsbl %al,%eax
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80105a63:	83 c3 01             	add    $0x1,%ebx
    uartputc(*p);
80105a66:	89 04 24             	mov    %eax,(%esp)
80105a69:	e8 22 ff ff ff       	call   80105990 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80105a6e:	0f b6 03             	movzbl (%ebx),%eax
80105a71:	84 c0                	test   %al,%al
80105a73:	75 eb                	jne    80105a60 <uartinit+0x80>
    uartputc(*p);
}
80105a75:	83 c4 1c             	add    $0x1c,%esp
80105a78:	5b                   	pop    %ebx
80105a79:	5e                   	pop    %esi
80105a7a:	5f                   	pop    %edi
80105a7b:	5d                   	pop    %ebp
80105a7c:	c3                   	ret    
80105a7d:	00 00                	add    %al,(%eax)
	...

80105a80 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105a80:	6a 00                	push   $0x0
  pushl $0
80105a82:	6a 00                	push   $0x0
  jmp alltraps
80105a84:	e9 23 fb ff ff       	jmp    801055ac <alltraps>

80105a89 <vector1>:
.globl vector1
vector1:
  pushl $0
80105a89:	6a 00                	push   $0x0
  pushl $1
80105a8b:	6a 01                	push   $0x1
  jmp alltraps
80105a8d:	e9 1a fb ff ff       	jmp    801055ac <alltraps>

80105a92 <vector2>:
.globl vector2
vector2:
  pushl $0
80105a92:	6a 00                	push   $0x0
  pushl $2
80105a94:	6a 02                	push   $0x2
  jmp alltraps
80105a96:	e9 11 fb ff ff       	jmp    801055ac <alltraps>

80105a9b <vector3>:
.globl vector3
vector3:
  pushl $0
80105a9b:	6a 00                	push   $0x0
  pushl $3
80105a9d:	6a 03                	push   $0x3
  jmp alltraps
80105a9f:	e9 08 fb ff ff       	jmp    801055ac <alltraps>

80105aa4 <vector4>:
.globl vector4
vector4:
  pushl $0
80105aa4:	6a 00                	push   $0x0
  pushl $4
80105aa6:	6a 04                	push   $0x4
  jmp alltraps
80105aa8:	e9 ff fa ff ff       	jmp    801055ac <alltraps>

80105aad <vector5>:
.globl vector5
vector5:
  pushl $0
80105aad:	6a 00                	push   $0x0
  pushl $5
80105aaf:	6a 05                	push   $0x5
  jmp alltraps
80105ab1:	e9 f6 fa ff ff       	jmp    801055ac <alltraps>

80105ab6 <vector6>:
.globl vector6
vector6:
  pushl $0
80105ab6:	6a 00                	push   $0x0
  pushl $6
80105ab8:	6a 06                	push   $0x6
  jmp alltraps
80105aba:	e9 ed fa ff ff       	jmp    801055ac <alltraps>

80105abf <vector7>:
.globl vector7
vector7:
  pushl $0
80105abf:	6a 00                	push   $0x0
  pushl $7
80105ac1:	6a 07                	push   $0x7
  jmp alltraps
80105ac3:	e9 e4 fa ff ff       	jmp    801055ac <alltraps>

80105ac8 <vector8>:
.globl vector8
vector8:
  pushl $8
80105ac8:	6a 08                	push   $0x8
  jmp alltraps
80105aca:	e9 dd fa ff ff       	jmp    801055ac <alltraps>

80105acf <vector9>:
.globl vector9
vector9:
  pushl $0
80105acf:	6a 00                	push   $0x0
  pushl $9
80105ad1:	6a 09                	push   $0x9
  jmp alltraps
80105ad3:	e9 d4 fa ff ff       	jmp    801055ac <alltraps>

80105ad8 <vector10>:
.globl vector10
vector10:
  pushl $10
80105ad8:	6a 0a                	push   $0xa
  jmp alltraps
80105ada:	e9 cd fa ff ff       	jmp    801055ac <alltraps>

80105adf <vector11>:
.globl vector11
vector11:
  pushl $11
80105adf:	6a 0b                	push   $0xb
  jmp alltraps
80105ae1:	e9 c6 fa ff ff       	jmp    801055ac <alltraps>

80105ae6 <vector12>:
.globl vector12
vector12:
  pushl $12
80105ae6:	6a 0c                	push   $0xc
  jmp alltraps
80105ae8:	e9 bf fa ff ff       	jmp    801055ac <alltraps>

80105aed <vector13>:
.globl vector13
vector13:
  pushl $13
80105aed:	6a 0d                	push   $0xd
  jmp alltraps
80105aef:	e9 b8 fa ff ff       	jmp    801055ac <alltraps>

80105af4 <vector14>:
.globl vector14
vector14:
  pushl $14
80105af4:	6a 0e                	push   $0xe
  jmp alltraps
80105af6:	e9 b1 fa ff ff       	jmp    801055ac <alltraps>

80105afb <vector15>:
.globl vector15
vector15:
  pushl $0
80105afb:	6a 00                	push   $0x0
  pushl $15
80105afd:	6a 0f                	push   $0xf
  jmp alltraps
80105aff:	e9 a8 fa ff ff       	jmp    801055ac <alltraps>

80105b04 <vector16>:
.globl vector16
vector16:
  pushl $0
80105b04:	6a 00                	push   $0x0
  pushl $16
80105b06:	6a 10                	push   $0x10
  jmp alltraps
80105b08:	e9 9f fa ff ff       	jmp    801055ac <alltraps>

80105b0d <vector17>:
.globl vector17
vector17:
  pushl $17
80105b0d:	6a 11                	push   $0x11
  jmp alltraps
80105b0f:	e9 98 fa ff ff       	jmp    801055ac <alltraps>

80105b14 <vector18>:
.globl vector18
vector18:
  pushl $0
80105b14:	6a 00                	push   $0x0
  pushl $18
80105b16:	6a 12                	push   $0x12
  jmp alltraps
80105b18:	e9 8f fa ff ff       	jmp    801055ac <alltraps>

80105b1d <vector19>:
.globl vector19
vector19:
  pushl $0
80105b1d:	6a 00                	push   $0x0
  pushl $19
80105b1f:	6a 13                	push   $0x13
  jmp alltraps
80105b21:	e9 86 fa ff ff       	jmp    801055ac <alltraps>

80105b26 <vector20>:
.globl vector20
vector20:
  pushl $0
80105b26:	6a 00                	push   $0x0
  pushl $20
80105b28:	6a 14                	push   $0x14
  jmp alltraps
80105b2a:	e9 7d fa ff ff       	jmp    801055ac <alltraps>

80105b2f <vector21>:
.globl vector21
vector21:
  pushl $0
80105b2f:	6a 00                	push   $0x0
  pushl $21
80105b31:	6a 15                	push   $0x15
  jmp alltraps
80105b33:	e9 74 fa ff ff       	jmp    801055ac <alltraps>

80105b38 <vector22>:
.globl vector22
vector22:
  pushl $0
80105b38:	6a 00                	push   $0x0
  pushl $22
80105b3a:	6a 16                	push   $0x16
  jmp alltraps
80105b3c:	e9 6b fa ff ff       	jmp    801055ac <alltraps>

80105b41 <vector23>:
.globl vector23
vector23:
  pushl $0
80105b41:	6a 00                	push   $0x0
  pushl $23
80105b43:	6a 17                	push   $0x17
  jmp alltraps
80105b45:	e9 62 fa ff ff       	jmp    801055ac <alltraps>

80105b4a <vector24>:
.globl vector24
vector24:
  pushl $0
80105b4a:	6a 00                	push   $0x0
  pushl $24
80105b4c:	6a 18                	push   $0x18
  jmp alltraps
80105b4e:	e9 59 fa ff ff       	jmp    801055ac <alltraps>

80105b53 <vector25>:
.globl vector25
vector25:
  pushl $0
80105b53:	6a 00                	push   $0x0
  pushl $25
80105b55:	6a 19                	push   $0x19
  jmp alltraps
80105b57:	e9 50 fa ff ff       	jmp    801055ac <alltraps>

80105b5c <vector26>:
.globl vector26
vector26:
  pushl $0
80105b5c:	6a 00                	push   $0x0
  pushl $26
80105b5e:	6a 1a                	push   $0x1a
  jmp alltraps
80105b60:	e9 47 fa ff ff       	jmp    801055ac <alltraps>

80105b65 <vector27>:
.globl vector27
vector27:
  pushl $0
80105b65:	6a 00                	push   $0x0
  pushl $27
80105b67:	6a 1b                	push   $0x1b
  jmp alltraps
80105b69:	e9 3e fa ff ff       	jmp    801055ac <alltraps>

80105b6e <vector28>:
.globl vector28
vector28:
  pushl $0
80105b6e:	6a 00                	push   $0x0
  pushl $28
80105b70:	6a 1c                	push   $0x1c
  jmp alltraps
80105b72:	e9 35 fa ff ff       	jmp    801055ac <alltraps>

80105b77 <vector29>:
.globl vector29
vector29:
  pushl $0
80105b77:	6a 00                	push   $0x0
  pushl $29
80105b79:	6a 1d                	push   $0x1d
  jmp alltraps
80105b7b:	e9 2c fa ff ff       	jmp    801055ac <alltraps>

80105b80 <vector30>:
.globl vector30
vector30:
  pushl $0
80105b80:	6a 00                	push   $0x0
  pushl $30
80105b82:	6a 1e                	push   $0x1e
  jmp alltraps
80105b84:	e9 23 fa ff ff       	jmp    801055ac <alltraps>

80105b89 <vector31>:
.globl vector31
vector31:
  pushl $0
80105b89:	6a 00                	push   $0x0
  pushl $31
80105b8b:	6a 1f                	push   $0x1f
  jmp alltraps
80105b8d:	e9 1a fa ff ff       	jmp    801055ac <alltraps>

80105b92 <vector32>:
.globl vector32
vector32:
  pushl $0
80105b92:	6a 00                	push   $0x0
  pushl $32
80105b94:	6a 20                	push   $0x20
  jmp alltraps
80105b96:	e9 11 fa ff ff       	jmp    801055ac <alltraps>

80105b9b <vector33>:
.globl vector33
vector33:
  pushl $0
80105b9b:	6a 00                	push   $0x0
  pushl $33
80105b9d:	6a 21                	push   $0x21
  jmp alltraps
80105b9f:	e9 08 fa ff ff       	jmp    801055ac <alltraps>

80105ba4 <vector34>:
.globl vector34
vector34:
  pushl $0
80105ba4:	6a 00                	push   $0x0
  pushl $34
80105ba6:	6a 22                	push   $0x22
  jmp alltraps
80105ba8:	e9 ff f9 ff ff       	jmp    801055ac <alltraps>

80105bad <vector35>:
.globl vector35
vector35:
  pushl $0
80105bad:	6a 00                	push   $0x0
  pushl $35
80105baf:	6a 23                	push   $0x23
  jmp alltraps
80105bb1:	e9 f6 f9 ff ff       	jmp    801055ac <alltraps>

80105bb6 <vector36>:
.globl vector36
vector36:
  pushl $0
80105bb6:	6a 00                	push   $0x0
  pushl $36
80105bb8:	6a 24                	push   $0x24
  jmp alltraps
80105bba:	e9 ed f9 ff ff       	jmp    801055ac <alltraps>

80105bbf <vector37>:
.globl vector37
vector37:
  pushl $0
80105bbf:	6a 00                	push   $0x0
  pushl $37
80105bc1:	6a 25                	push   $0x25
  jmp alltraps
80105bc3:	e9 e4 f9 ff ff       	jmp    801055ac <alltraps>

80105bc8 <vector38>:
.globl vector38
vector38:
  pushl $0
80105bc8:	6a 00                	push   $0x0
  pushl $38
80105bca:	6a 26                	push   $0x26
  jmp alltraps
80105bcc:	e9 db f9 ff ff       	jmp    801055ac <alltraps>

80105bd1 <vector39>:
.globl vector39
vector39:
  pushl $0
80105bd1:	6a 00                	push   $0x0
  pushl $39
80105bd3:	6a 27                	push   $0x27
  jmp alltraps
80105bd5:	e9 d2 f9 ff ff       	jmp    801055ac <alltraps>

80105bda <vector40>:
.globl vector40
vector40:
  pushl $0
80105bda:	6a 00                	push   $0x0
  pushl $40
80105bdc:	6a 28                	push   $0x28
  jmp alltraps
80105bde:	e9 c9 f9 ff ff       	jmp    801055ac <alltraps>

80105be3 <vector41>:
.globl vector41
vector41:
  pushl $0
80105be3:	6a 00                	push   $0x0
  pushl $41
80105be5:	6a 29                	push   $0x29
  jmp alltraps
80105be7:	e9 c0 f9 ff ff       	jmp    801055ac <alltraps>

80105bec <vector42>:
.globl vector42
vector42:
  pushl $0
80105bec:	6a 00                	push   $0x0
  pushl $42
80105bee:	6a 2a                	push   $0x2a
  jmp alltraps
80105bf0:	e9 b7 f9 ff ff       	jmp    801055ac <alltraps>

80105bf5 <vector43>:
.globl vector43
vector43:
  pushl $0
80105bf5:	6a 00                	push   $0x0
  pushl $43
80105bf7:	6a 2b                	push   $0x2b
  jmp alltraps
80105bf9:	e9 ae f9 ff ff       	jmp    801055ac <alltraps>

80105bfe <vector44>:
.globl vector44
vector44:
  pushl $0
80105bfe:	6a 00                	push   $0x0
  pushl $44
80105c00:	6a 2c                	push   $0x2c
  jmp alltraps
80105c02:	e9 a5 f9 ff ff       	jmp    801055ac <alltraps>

80105c07 <vector45>:
.globl vector45
vector45:
  pushl $0
80105c07:	6a 00                	push   $0x0
  pushl $45
80105c09:	6a 2d                	push   $0x2d
  jmp alltraps
80105c0b:	e9 9c f9 ff ff       	jmp    801055ac <alltraps>

80105c10 <vector46>:
.globl vector46
vector46:
  pushl $0
80105c10:	6a 00                	push   $0x0
  pushl $46
80105c12:	6a 2e                	push   $0x2e
  jmp alltraps
80105c14:	e9 93 f9 ff ff       	jmp    801055ac <alltraps>

80105c19 <vector47>:
.globl vector47
vector47:
  pushl $0
80105c19:	6a 00                	push   $0x0
  pushl $47
80105c1b:	6a 2f                	push   $0x2f
  jmp alltraps
80105c1d:	e9 8a f9 ff ff       	jmp    801055ac <alltraps>

80105c22 <vector48>:
.globl vector48
vector48:
  pushl $0
80105c22:	6a 00                	push   $0x0
  pushl $48
80105c24:	6a 30                	push   $0x30
  jmp alltraps
80105c26:	e9 81 f9 ff ff       	jmp    801055ac <alltraps>

80105c2b <vector49>:
.globl vector49
vector49:
  pushl $0
80105c2b:	6a 00                	push   $0x0
  pushl $49
80105c2d:	6a 31                	push   $0x31
  jmp alltraps
80105c2f:	e9 78 f9 ff ff       	jmp    801055ac <alltraps>

80105c34 <vector50>:
.globl vector50
vector50:
  pushl $0
80105c34:	6a 00                	push   $0x0
  pushl $50
80105c36:	6a 32                	push   $0x32
  jmp alltraps
80105c38:	e9 6f f9 ff ff       	jmp    801055ac <alltraps>

80105c3d <vector51>:
.globl vector51
vector51:
  pushl $0
80105c3d:	6a 00                	push   $0x0
  pushl $51
80105c3f:	6a 33                	push   $0x33
  jmp alltraps
80105c41:	e9 66 f9 ff ff       	jmp    801055ac <alltraps>

80105c46 <vector52>:
.globl vector52
vector52:
  pushl $0
80105c46:	6a 00                	push   $0x0
  pushl $52
80105c48:	6a 34                	push   $0x34
  jmp alltraps
80105c4a:	e9 5d f9 ff ff       	jmp    801055ac <alltraps>

80105c4f <vector53>:
.globl vector53
vector53:
  pushl $0
80105c4f:	6a 00                	push   $0x0
  pushl $53
80105c51:	6a 35                	push   $0x35
  jmp alltraps
80105c53:	e9 54 f9 ff ff       	jmp    801055ac <alltraps>

80105c58 <vector54>:
.globl vector54
vector54:
  pushl $0
80105c58:	6a 00                	push   $0x0
  pushl $54
80105c5a:	6a 36                	push   $0x36
  jmp alltraps
80105c5c:	e9 4b f9 ff ff       	jmp    801055ac <alltraps>

80105c61 <vector55>:
.globl vector55
vector55:
  pushl $0
80105c61:	6a 00                	push   $0x0
  pushl $55
80105c63:	6a 37                	push   $0x37
  jmp alltraps
80105c65:	e9 42 f9 ff ff       	jmp    801055ac <alltraps>

80105c6a <vector56>:
.globl vector56
vector56:
  pushl $0
80105c6a:	6a 00                	push   $0x0
  pushl $56
80105c6c:	6a 38                	push   $0x38
  jmp alltraps
80105c6e:	e9 39 f9 ff ff       	jmp    801055ac <alltraps>

80105c73 <vector57>:
.globl vector57
vector57:
  pushl $0
80105c73:	6a 00                	push   $0x0
  pushl $57
80105c75:	6a 39                	push   $0x39
  jmp alltraps
80105c77:	e9 30 f9 ff ff       	jmp    801055ac <alltraps>

80105c7c <vector58>:
.globl vector58
vector58:
  pushl $0
80105c7c:	6a 00                	push   $0x0
  pushl $58
80105c7e:	6a 3a                	push   $0x3a
  jmp alltraps
80105c80:	e9 27 f9 ff ff       	jmp    801055ac <alltraps>

80105c85 <vector59>:
.globl vector59
vector59:
  pushl $0
80105c85:	6a 00                	push   $0x0
  pushl $59
80105c87:	6a 3b                	push   $0x3b
  jmp alltraps
80105c89:	e9 1e f9 ff ff       	jmp    801055ac <alltraps>

80105c8e <vector60>:
.globl vector60
vector60:
  pushl $0
80105c8e:	6a 00                	push   $0x0
  pushl $60
80105c90:	6a 3c                	push   $0x3c
  jmp alltraps
80105c92:	e9 15 f9 ff ff       	jmp    801055ac <alltraps>

80105c97 <vector61>:
.globl vector61
vector61:
  pushl $0
80105c97:	6a 00                	push   $0x0
  pushl $61
80105c99:	6a 3d                	push   $0x3d
  jmp alltraps
80105c9b:	e9 0c f9 ff ff       	jmp    801055ac <alltraps>

80105ca0 <vector62>:
.globl vector62
vector62:
  pushl $0
80105ca0:	6a 00                	push   $0x0
  pushl $62
80105ca2:	6a 3e                	push   $0x3e
  jmp alltraps
80105ca4:	e9 03 f9 ff ff       	jmp    801055ac <alltraps>

80105ca9 <vector63>:
.globl vector63
vector63:
  pushl $0
80105ca9:	6a 00                	push   $0x0
  pushl $63
80105cab:	6a 3f                	push   $0x3f
  jmp alltraps
80105cad:	e9 fa f8 ff ff       	jmp    801055ac <alltraps>

80105cb2 <vector64>:
.globl vector64
vector64:
  pushl $0
80105cb2:	6a 00                	push   $0x0
  pushl $64
80105cb4:	6a 40                	push   $0x40
  jmp alltraps
80105cb6:	e9 f1 f8 ff ff       	jmp    801055ac <alltraps>

80105cbb <vector65>:
.globl vector65
vector65:
  pushl $0
80105cbb:	6a 00                	push   $0x0
  pushl $65
80105cbd:	6a 41                	push   $0x41
  jmp alltraps
80105cbf:	e9 e8 f8 ff ff       	jmp    801055ac <alltraps>

80105cc4 <vector66>:
.globl vector66
vector66:
  pushl $0
80105cc4:	6a 00                	push   $0x0
  pushl $66
80105cc6:	6a 42                	push   $0x42
  jmp alltraps
80105cc8:	e9 df f8 ff ff       	jmp    801055ac <alltraps>

80105ccd <vector67>:
.globl vector67
vector67:
  pushl $0
80105ccd:	6a 00                	push   $0x0
  pushl $67
80105ccf:	6a 43                	push   $0x43
  jmp alltraps
80105cd1:	e9 d6 f8 ff ff       	jmp    801055ac <alltraps>

80105cd6 <vector68>:
.globl vector68
vector68:
  pushl $0
80105cd6:	6a 00                	push   $0x0
  pushl $68
80105cd8:	6a 44                	push   $0x44
  jmp alltraps
80105cda:	e9 cd f8 ff ff       	jmp    801055ac <alltraps>

80105cdf <vector69>:
.globl vector69
vector69:
  pushl $0
80105cdf:	6a 00                	push   $0x0
  pushl $69
80105ce1:	6a 45                	push   $0x45
  jmp alltraps
80105ce3:	e9 c4 f8 ff ff       	jmp    801055ac <alltraps>

80105ce8 <vector70>:
.globl vector70
vector70:
  pushl $0
80105ce8:	6a 00                	push   $0x0
  pushl $70
80105cea:	6a 46                	push   $0x46
  jmp alltraps
80105cec:	e9 bb f8 ff ff       	jmp    801055ac <alltraps>

80105cf1 <vector71>:
.globl vector71
vector71:
  pushl $0
80105cf1:	6a 00                	push   $0x0
  pushl $71
80105cf3:	6a 47                	push   $0x47
  jmp alltraps
80105cf5:	e9 b2 f8 ff ff       	jmp    801055ac <alltraps>

80105cfa <vector72>:
.globl vector72
vector72:
  pushl $0
80105cfa:	6a 00                	push   $0x0
  pushl $72
80105cfc:	6a 48                	push   $0x48
  jmp alltraps
80105cfe:	e9 a9 f8 ff ff       	jmp    801055ac <alltraps>

80105d03 <vector73>:
.globl vector73
vector73:
  pushl $0
80105d03:	6a 00                	push   $0x0
  pushl $73
80105d05:	6a 49                	push   $0x49
  jmp alltraps
80105d07:	e9 a0 f8 ff ff       	jmp    801055ac <alltraps>

80105d0c <vector74>:
.globl vector74
vector74:
  pushl $0
80105d0c:	6a 00                	push   $0x0
  pushl $74
80105d0e:	6a 4a                	push   $0x4a
  jmp alltraps
80105d10:	e9 97 f8 ff ff       	jmp    801055ac <alltraps>

80105d15 <vector75>:
.globl vector75
vector75:
  pushl $0
80105d15:	6a 00                	push   $0x0
  pushl $75
80105d17:	6a 4b                	push   $0x4b
  jmp alltraps
80105d19:	e9 8e f8 ff ff       	jmp    801055ac <alltraps>

80105d1e <vector76>:
.globl vector76
vector76:
  pushl $0
80105d1e:	6a 00                	push   $0x0
  pushl $76
80105d20:	6a 4c                	push   $0x4c
  jmp alltraps
80105d22:	e9 85 f8 ff ff       	jmp    801055ac <alltraps>

80105d27 <vector77>:
.globl vector77
vector77:
  pushl $0
80105d27:	6a 00                	push   $0x0
  pushl $77
80105d29:	6a 4d                	push   $0x4d
  jmp alltraps
80105d2b:	e9 7c f8 ff ff       	jmp    801055ac <alltraps>

80105d30 <vector78>:
.globl vector78
vector78:
  pushl $0
80105d30:	6a 00                	push   $0x0
  pushl $78
80105d32:	6a 4e                	push   $0x4e
  jmp alltraps
80105d34:	e9 73 f8 ff ff       	jmp    801055ac <alltraps>

80105d39 <vector79>:
.globl vector79
vector79:
  pushl $0
80105d39:	6a 00                	push   $0x0
  pushl $79
80105d3b:	6a 4f                	push   $0x4f
  jmp alltraps
80105d3d:	e9 6a f8 ff ff       	jmp    801055ac <alltraps>

80105d42 <vector80>:
.globl vector80
vector80:
  pushl $0
80105d42:	6a 00                	push   $0x0
  pushl $80
80105d44:	6a 50                	push   $0x50
  jmp alltraps
80105d46:	e9 61 f8 ff ff       	jmp    801055ac <alltraps>

80105d4b <vector81>:
.globl vector81
vector81:
  pushl $0
80105d4b:	6a 00                	push   $0x0
  pushl $81
80105d4d:	6a 51                	push   $0x51
  jmp alltraps
80105d4f:	e9 58 f8 ff ff       	jmp    801055ac <alltraps>

80105d54 <vector82>:
.globl vector82
vector82:
  pushl $0
80105d54:	6a 00                	push   $0x0
  pushl $82
80105d56:	6a 52                	push   $0x52
  jmp alltraps
80105d58:	e9 4f f8 ff ff       	jmp    801055ac <alltraps>

80105d5d <vector83>:
.globl vector83
vector83:
  pushl $0
80105d5d:	6a 00                	push   $0x0
  pushl $83
80105d5f:	6a 53                	push   $0x53
  jmp alltraps
80105d61:	e9 46 f8 ff ff       	jmp    801055ac <alltraps>

80105d66 <vector84>:
.globl vector84
vector84:
  pushl $0
80105d66:	6a 00                	push   $0x0
  pushl $84
80105d68:	6a 54                	push   $0x54
  jmp alltraps
80105d6a:	e9 3d f8 ff ff       	jmp    801055ac <alltraps>

80105d6f <vector85>:
.globl vector85
vector85:
  pushl $0
80105d6f:	6a 00                	push   $0x0
  pushl $85
80105d71:	6a 55                	push   $0x55
  jmp alltraps
80105d73:	e9 34 f8 ff ff       	jmp    801055ac <alltraps>

80105d78 <vector86>:
.globl vector86
vector86:
  pushl $0
80105d78:	6a 00                	push   $0x0
  pushl $86
80105d7a:	6a 56                	push   $0x56
  jmp alltraps
80105d7c:	e9 2b f8 ff ff       	jmp    801055ac <alltraps>

80105d81 <vector87>:
.globl vector87
vector87:
  pushl $0
80105d81:	6a 00                	push   $0x0
  pushl $87
80105d83:	6a 57                	push   $0x57
  jmp alltraps
80105d85:	e9 22 f8 ff ff       	jmp    801055ac <alltraps>

80105d8a <vector88>:
.globl vector88
vector88:
  pushl $0
80105d8a:	6a 00                	push   $0x0
  pushl $88
80105d8c:	6a 58                	push   $0x58
  jmp alltraps
80105d8e:	e9 19 f8 ff ff       	jmp    801055ac <alltraps>

80105d93 <vector89>:
.globl vector89
vector89:
  pushl $0
80105d93:	6a 00                	push   $0x0
  pushl $89
80105d95:	6a 59                	push   $0x59
  jmp alltraps
80105d97:	e9 10 f8 ff ff       	jmp    801055ac <alltraps>

80105d9c <vector90>:
.globl vector90
vector90:
  pushl $0
80105d9c:	6a 00                	push   $0x0
  pushl $90
80105d9e:	6a 5a                	push   $0x5a
  jmp alltraps
80105da0:	e9 07 f8 ff ff       	jmp    801055ac <alltraps>

80105da5 <vector91>:
.globl vector91
vector91:
  pushl $0
80105da5:	6a 00                	push   $0x0
  pushl $91
80105da7:	6a 5b                	push   $0x5b
  jmp alltraps
80105da9:	e9 fe f7 ff ff       	jmp    801055ac <alltraps>

80105dae <vector92>:
.globl vector92
vector92:
  pushl $0
80105dae:	6a 00                	push   $0x0
  pushl $92
80105db0:	6a 5c                	push   $0x5c
  jmp alltraps
80105db2:	e9 f5 f7 ff ff       	jmp    801055ac <alltraps>

80105db7 <vector93>:
.globl vector93
vector93:
  pushl $0
80105db7:	6a 00                	push   $0x0
  pushl $93
80105db9:	6a 5d                	push   $0x5d
  jmp alltraps
80105dbb:	e9 ec f7 ff ff       	jmp    801055ac <alltraps>

80105dc0 <vector94>:
.globl vector94
vector94:
  pushl $0
80105dc0:	6a 00                	push   $0x0
  pushl $94
80105dc2:	6a 5e                	push   $0x5e
  jmp alltraps
80105dc4:	e9 e3 f7 ff ff       	jmp    801055ac <alltraps>

80105dc9 <vector95>:
.globl vector95
vector95:
  pushl $0
80105dc9:	6a 00                	push   $0x0
  pushl $95
80105dcb:	6a 5f                	push   $0x5f
  jmp alltraps
80105dcd:	e9 da f7 ff ff       	jmp    801055ac <alltraps>

80105dd2 <vector96>:
.globl vector96
vector96:
  pushl $0
80105dd2:	6a 00                	push   $0x0
  pushl $96
80105dd4:	6a 60                	push   $0x60
  jmp alltraps
80105dd6:	e9 d1 f7 ff ff       	jmp    801055ac <alltraps>

80105ddb <vector97>:
.globl vector97
vector97:
  pushl $0
80105ddb:	6a 00                	push   $0x0
  pushl $97
80105ddd:	6a 61                	push   $0x61
  jmp alltraps
80105ddf:	e9 c8 f7 ff ff       	jmp    801055ac <alltraps>

80105de4 <vector98>:
.globl vector98
vector98:
  pushl $0
80105de4:	6a 00                	push   $0x0
  pushl $98
80105de6:	6a 62                	push   $0x62
  jmp alltraps
80105de8:	e9 bf f7 ff ff       	jmp    801055ac <alltraps>

80105ded <vector99>:
.globl vector99
vector99:
  pushl $0
80105ded:	6a 00                	push   $0x0
  pushl $99
80105def:	6a 63                	push   $0x63
  jmp alltraps
80105df1:	e9 b6 f7 ff ff       	jmp    801055ac <alltraps>

80105df6 <vector100>:
.globl vector100
vector100:
  pushl $0
80105df6:	6a 00                	push   $0x0
  pushl $100
80105df8:	6a 64                	push   $0x64
  jmp alltraps
80105dfa:	e9 ad f7 ff ff       	jmp    801055ac <alltraps>

80105dff <vector101>:
.globl vector101
vector101:
  pushl $0
80105dff:	6a 00                	push   $0x0
  pushl $101
80105e01:	6a 65                	push   $0x65
  jmp alltraps
80105e03:	e9 a4 f7 ff ff       	jmp    801055ac <alltraps>

80105e08 <vector102>:
.globl vector102
vector102:
  pushl $0
80105e08:	6a 00                	push   $0x0
  pushl $102
80105e0a:	6a 66                	push   $0x66
  jmp alltraps
80105e0c:	e9 9b f7 ff ff       	jmp    801055ac <alltraps>

80105e11 <vector103>:
.globl vector103
vector103:
  pushl $0
80105e11:	6a 00                	push   $0x0
  pushl $103
80105e13:	6a 67                	push   $0x67
  jmp alltraps
80105e15:	e9 92 f7 ff ff       	jmp    801055ac <alltraps>

80105e1a <vector104>:
.globl vector104
vector104:
  pushl $0
80105e1a:	6a 00                	push   $0x0
  pushl $104
80105e1c:	6a 68                	push   $0x68
  jmp alltraps
80105e1e:	e9 89 f7 ff ff       	jmp    801055ac <alltraps>

80105e23 <vector105>:
.globl vector105
vector105:
  pushl $0
80105e23:	6a 00                	push   $0x0
  pushl $105
80105e25:	6a 69                	push   $0x69
  jmp alltraps
80105e27:	e9 80 f7 ff ff       	jmp    801055ac <alltraps>

80105e2c <vector106>:
.globl vector106
vector106:
  pushl $0
80105e2c:	6a 00                	push   $0x0
  pushl $106
80105e2e:	6a 6a                	push   $0x6a
  jmp alltraps
80105e30:	e9 77 f7 ff ff       	jmp    801055ac <alltraps>

80105e35 <vector107>:
.globl vector107
vector107:
  pushl $0
80105e35:	6a 00                	push   $0x0
  pushl $107
80105e37:	6a 6b                	push   $0x6b
  jmp alltraps
80105e39:	e9 6e f7 ff ff       	jmp    801055ac <alltraps>

80105e3e <vector108>:
.globl vector108
vector108:
  pushl $0
80105e3e:	6a 00                	push   $0x0
  pushl $108
80105e40:	6a 6c                	push   $0x6c
  jmp alltraps
80105e42:	e9 65 f7 ff ff       	jmp    801055ac <alltraps>

80105e47 <vector109>:
.globl vector109
vector109:
  pushl $0
80105e47:	6a 00                	push   $0x0
  pushl $109
80105e49:	6a 6d                	push   $0x6d
  jmp alltraps
80105e4b:	e9 5c f7 ff ff       	jmp    801055ac <alltraps>

80105e50 <vector110>:
.globl vector110
vector110:
  pushl $0
80105e50:	6a 00                	push   $0x0
  pushl $110
80105e52:	6a 6e                	push   $0x6e
  jmp alltraps
80105e54:	e9 53 f7 ff ff       	jmp    801055ac <alltraps>

80105e59 <vector111>:
.globl vector111
vector111:
  pushl $0
80105e59:	6a 00                	push   $0x0
  pushl $111
80105e5b:	6a 6f                	push   $0x6f
  jmp alltraps
80105e5d:	e9 4a f7 ff ff       	jmp    801055ac <alltraps>

80105e62 <vector112>:
.globl vector112
vector112:
  pushl $0
80105e62:	6a 00                	push   $0x0
  pushl $112
80105e64:	6a 70                	push   $0x70
  jmp alltraps
80105e66:	e9 41 f7 ff ff       	jmp    801055ac <alltraps>

80105e6b <vector113>:
.globl vector113
vector113:
  pushl $0
80105e6b:	6a 00                	push   $0x0
  pushl $113
80105e6d:	6a 71                	push   $0x71
  jmp alltraps
80105e6f:	e9 38 f7 ff ff       	jmp    801055ac <alltraps>

80105e74 <vector114>:
.globl vector114
vector114:
  pushl $0
80105e74:	6a 00                	push   $0x0
  pushl $114
80105e76:	6a 72                	push   $0x72
  jmp alltraps
80105e78:	e9 2f f7 ff ff       	jmp    801055ac <alltraps>

80105e7d <vector115>:
.globl vector115
vector115:
  pushl $0
80105e7d:	6a 00                	push   $0x0
  pushl $115
80105e7f:	6a 73                	push   $0x73
  jmp alltraps
80105e81:	e9 26 f7 ff ff       	jmp    801055ac <alltraps>

80105e86 <vector116>:
.globl vector116
vector116:
  pushl $0
80105e86:	6a 00                	push   $0x0
  pushl $116
80105e88:	6a 74                	push   $0x74
  jmp alltraps
80105e8a:	e9 1d f7 ff ff       	jmp    801055ac <alltraps>

80105e8f <vector117>:
.globl vector117
vector117:
  pushl $0
80105e8f:	6a 00                	push   $0x0
  pushl $117
80105e91:	6a 75                	push   $0x75
  jmp alltraps
80105e93:	e9 14 f7 ff ff       	jmp    801055ac <alltraps>

80105e98 <vector118>:
.globl vector118
vector118:
  pushl $0
80105e98:	6a 00                	push   $0x0
  pushl $118
80105e9a:	6a 76                	push   $0x76
  jmp alltraps
80105e9c:	e9 0b f7 ff ff       	jmp    801055ac <alltraps>

80105ea1 <vector119>:
.globl vector119
vector119:
  pushl $0
80105ea1:	6a 00                	push   $0x0
  pushl $119
80105ea3:	6a 77                	push   $0x77
  jmp alltraps
80105ea5:	e9 02 f7 ff ff       	jmp    801055ac <alltraps>

80105eaa <vector120>:
.globl vector120
vector120:
  pushl $0
80105eaa:	6a 00                	push   $0x0
  pushl $120
80105eac:	6a 78                	push   $0x78
  jmp alltraps
80105eae:	e9 f9 f6 ff ff       	jmp    801055ac <alltraps>

80105eb3 <vector121>:
.globl vector121
vector121:
  pushl $0
80105eb3:	6a 00                	push   $0x0
  pushl $121
80105eb5:	6a 79                	push   $0x79
  jmp alltraps
80105eb7:	e9 f0 f6 ff ff       	jmp    801055ac <alltraps>

80105ebc <vector122>:
.globl vector122
vector122:
  pushl $0
80105ebc:	6a 00                	push   $0x0
  pushl $122
80105ebe:	6a 7a                	push   $0x7a
  jmp alltraps
80105ec0:	e9 e7 f6 ff ff       	jmp    801055ac <alltraps>

80105ec5 <vector123>:
.globl vector123
vector123:
  pushl $0
80105ec5:	6a 00                	push   $0x0
  pushl $123
80105ec7:	6a 7b                	push   $0x7b
  jmp alltraps
80105ec9:	e9 de f6 ff ff       	jmp    801055ac <alltraps>

80105ece <vector124>:
.globl vector124
vector124:
  pushl $0
80105ece:	6a 00                	push   $0x0
  pushl $124
80105ed0:	6a 7c                	push   $0x7c
  jmp alltraps
80105ed2:	e9 d5 f6 ff ff       	jmp    801055ac <alltraps>

80105ed7 <vector125>:
.globl vector125
vector125:
  pushl $0
80105ed7:	6a 00                	push   $0x0
  pushl $125
80105ed9:	6a 7d                	push   $0x7d
  jmp alltraps
80105edb:	e9 cc f6 ff ff       	jmp    801055ac <alltraps>

80105ee0 <vector126>:
.globl vector126
vector126:
  pushl $0
80105ee0:	6a 00                	push   $0x0
  pushl $126
80105ee2:	6a 7e                	push   $0x7e
  jmp alltraps
80105ee4:	e9 c3 f6 ff ff       	jmp    801055ac <alltraps>

80105ee9 <vector127>:
.globl vector127
vector127:
  pushl $0
80105ee9:	6a 00                	push   $0x0
  pushl $127
80105eeb:	6a 7f                	push   $0x7f
  jmp alltraps
80105eed:	e9 ba f6 ff ff       	jmp    801055ac <alltraps>

80105ef2 <vector128>:
.globl vector128
vector128:
  pushl $0
80105ef2:	6a 00                	push   $0x0
  pushl $128
80105ef4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105ef9:	e9 ae f6 ff ff       	jmp    801055ac <alltraps>

80105efe <vector129>:
.globl vector129
vector129:
  pushl $0
80105efe:	6a 00                	push   $0x0
  pushl $129
80105f00:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105f05:	e9 a2 f6 ff ff       	jmp    801055ac <alltraps>

80105f0a <vector130>:
.globl vector130
vector130:
  pushl $0
80105f0a:	6a 00                	push   $0x0
  pushl $130
80105f0c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105f11:	e9 96 f6 ff ff       	jmp    801055ac <alltraps>

80105f16 <vector131>:
.globl vector131
vector131:
  pushl $0
80105f16:	6a 00                	push   $0x0
  pushl $131
80105f18:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105f1d:	e9 8a f6 ff ff       	jmp    801055ac <alltraps>

80105f22 <vector132>:
.globl vector132
vector132:
  pushl $0
80105f22:	6a 00                	push   $0x0
  pushl $132
80105f24:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105f29:	e9 7e f6 ff ff       	jmp    801055ac <alltraps>

80105f2e <vector133>:
.globl vector133
vector133:
  pushl $0
80105f2e:	6a 00                	push   $0x0
  pushl $133
80105f30:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105f35:	e9 72 f6 ff ff       	jmp    801055ac <alltraps>

80105f3a <vector134>:
.globl vector134
vector134:
  pushl $0
80105f3a:	6a 00                	push   $0x0
  pushl $134
80105f3c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105f41:	e9 66 f6 ff ff       	jmp    801055ac <alltraps>

80105f46 <vector135>:
.globl vector135
vector135:
  pushl $0
80105f46:	6a 00                	push   $0x0
  pushl $135
80105f48:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105f4d:	e9 5a f6 ff ff       	jmp    801055ac <alltraps>

80105f52 <vector136>:
.globl vector136
vector136:
  pushl $0
80105f52:	6a 00                	push   $0x0
  pushl $136
80105f54:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105f59:	e9 4e f6 ff ff       	jmp    801055ac <alltraps>

80105f5e <vector137>:
.globl vector137
vector137:
  pushl $0
80105f5e:	6a 00                	push   $0x0
  pushl $137
80105f60:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105f65:	e9 42 f6 ff ff       	jmp    801055ac <alltraps>

80105f6a <vector138>:
.globl vector138
vector138:
  pushl $0
80105f6a:	6a 00                	push   $0x0
  pushl $138
80105f6c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105f71:	e9 36 f6 ff ff       	jmp    801055ac <alltraps>

80105f76 <vector139>:
.globl vector139
vector139:
  pushl $0
80105f76:	6a 00                	push   $0x0
  pushl $139
80105f78:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105f7d:	e9 2a f6 ff ff       	jmp    801055ac <alltraps>

80105f82 <vector140>:
.globl vector140
vector140:
  pushl $0
80105f82:	6a 00                	push   $0x0
  pushl $140
80105f84:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105f89:	e9 1e f6 ff ff       	jmp    801055ac <alltraps>

80105f8e <vector141>:
.globl vector141
vector141:
  pushl $0
80105f8e:	6a 00                	push   $0x0
  pushl $141
80105f90:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105f95:	e9 12 f6 ff ff       	jmp    801055ac <alltraps>

80105f9a <vector142>:
.globl vector142
vector142:
  pushl $0
80105f9a:	6a 00                	push   $0x0
  pushl $142
80105f9c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105fa1:	e9 06 f6 ff ff       	jmp    801055ac <alltraps>

80105fa6 <vector143>:
.globl vector143
vector143:
  pushl $0
80105fa6:	6a 00                	push   $0x0
  pushl $143
80105fa8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105fad:	e9 fa f5 ff ff       	jmp    801055ac <alltraps>

80105fb2 <vector144>:
.globl vector144
vector144:
  pushl $0
80105fb2:	6a 00                	push   $0x0
  pushl $144
80105fb4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105fb9:	e9 ee f5 ff ff       	jmp    801055ac <alltraps>

80105fbe <vector145>:
.globl vector145
vector145:
  pushl $0
80105fbe:	6a 00                	push   $0x0
  pushl $145
80105fc0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105fc5:	e9 e2 f5 ff ff       	jmp    801055ac <alltraps>

80105fca <vector146>:
.globl vector146
vector146:
  pushl $0
80105fca:	6a 00                	push   $0x0
  pushl $146
80105fcc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105fd1:	e9 d6 f5 ff ff       	jmp    801055ac <alltraps>

80105fd6 <vector147>:
.globl vector147
vector147:
  pushl $0
80105fd6:	6a 00                	push   $0x0
  pushl $147
80105fd8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105fdd:	e9 ca f5 ff ff       	jmp    801055ac <alltraps>

80105fe2 <vector148>:
.globl vector148
vector148:
  pushl $0
80105fe2:	6a 00                	push   $0x0
  pushl $148
80105fe4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105fe9:	e9 be f5 ff ff       	jmp    801055ac <alltraps>

80105fee <vector149>:
.globl vector149
vector149:
  pushl $0
80105fee:	6a 00                	push   $0x0
  pushl $149
80105ff0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105ff5:	e9 b2 f5 ff ff       	jmp    801055ac <alltraps>

80105ffa <vector150>:
.globl vector150
vector150:
  pushl $0
80105ffa:	6a 00                	push   $0x0
  pushl $150
80105ffc:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106001:	e9 a6 f5 ff ff       	jmp    801055ac <alltraps>

80106006 <vector151>:
.globl vector151
vector151:
  pushl $0
80106006:	6a 00                	push   $0x0
  pushl $151
80106008:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010600d:	e9 9a f5 ff ff       	jmp    801055ac <alltraps>

80106012 <vector152>:
.globl vector152
vector152:
  pushl $0
80106012:	6a 00                	push   $0x0
  pushl $152
80106014:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106019:	e9 8e f5 ff ff       	jmp    801055ac <alltraps>

8010601e <vector153>:
.globl vector153
vector153:
  pushl $0
8010601e:	6a 00                	push   $0x0
  pushl $153
80106020:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106025:	e9 82 f5 ff ff       	jmp    801055ac <alltraps>

8010602a <vector154>:
.globl vector154
vector154:
  pushl $0
8010602a:	6a 00                	push   $0x0
  pushl $154
8010602c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106031:	e9 76 f5 ff ff       	jmp    801055ac <alltraps>

80106036 <vector155>:
.globl vector155
vector155:
  pushl $0
80106036:	6a 00                	push   $0x0
  pushl $155
80106038:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010603d:	e9 6a f5 ff ff       	jmp    801055ac <alltraps>

80106042 <vector156>:
.globl vector156
vector156:
  pushl $0
80106042:	6a 00                	push   $0x0
  pushl $156
80106044:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106049:	e9 5e f5 ff ff       	jmp    801055ac <alltraps>

8010604e <vector157>:
.globl vector157
vector157:
  pushl $0
8010604e:	6a 00                	push   $0x0
  pushl $157
80106050:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106055:	e9 52 f5 ff ff       	jmp    801055ac <alltraps>

8010605a <vector158>:
.globl vector158
vector158:
  pushl $0
8010605a:	6a 00                	push   $0x0
  pushl $158
8010605c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106061:	e9 46 f5 ff ff       	jmp    801055ac <alltraps>

80106066 <vector159>:
.globl vector159
vector159:
  pushl $0
80106066:	6a 00                	push   $0x0
  pushl $159
80106068:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010606d:	e9 3a f5 ff ff       	jmp    801055ac <alltraps>

80106072 <vector160>:
.globl vector160
vector160:
  pushl $0
80106072:	6a 00                	push   $0x0
  pushl $160
80106074:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106079:	e9 2e f5 ff ff       	jmp    801055ac <alltraps>

8010607e <vector161>:
.globl vector161
vector161:
  pushl $0
8010607e:	6a 00                	push   $0x0
  pushl $161
80106080:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106085:	e9 22 f5 ff ff       	jmp    801055ac <alltraps>

8010608a <vector162>:
.globl vector162
vector162:
  pushl $0
8010608a:	6a 00                	push   $0x0
  pushl $162
8010608c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106091:	e9 16 f5 ff ff       	jmp    801055ac <alltraps>

80106096 <vector163>:
.globl vector163
vector163:
  pushl $0
80106096:	6a 00                	push   $0x0
  pushl $163
80106098:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010609d:	e9 0a f5 ff ff       	jmp    801055ac <alltraps>

801060a2 <vector164>:
.globl vector164
vector164:
  pushl $0
801060a2:	6a 00                	push   $0x0
  pushl $164
801060a4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801060a9:	e9 fe f4 ff ff       	jmp    801055ac <alltraps>

801060ae <vector165>:
.globl vector165
vector165:
  pushl $0
801060ae:	6a 00                	push   $0x0
  pushl $165
801060b0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801060b5:	e9 f2 f4 ff ff       	jmp    801055ac <alltraps>

801060ba <vector166>:
.globl vector166
vector166:
  pushl $0
801060ba:	6a 00                	push   $0x0
  pushl $166
801060bc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801060c1:	e9 e6 f4 ff ff       	jmp    801055ac <alltraps>

801060c6 <vector167>:
.globl vector167
vector167:
  pushl $0
801060c6:	6a 00                	push   $0x0
  pushl $167
801060c8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801060cd:	e9 da f4 ff ff       	jmp    801055ac <alltraps>

801060d2 <vector168>:
.globl vector168
vector168:
  pushl $0
801060d2:	6a 00                	push   $0x0
  pushl $168
801060d4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801060d9:	e9 ce f4 ff ff       	jmp    801055ac <alltraps>

801060de <vector169>:
.globl vector169
vector169:
  pushl $0
801060de:	6a 00                	push   $0x0
  pushl $169
801060e0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801060e5:	e9 c2 f4 ff ff       	jmp    801055ac <alltraps>

801060ea <vector170>:
.globl vector170
vector170:
  pushl $0
801060ea:	6a 00                	push   $0x0
  pushl $170
801060ec:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801060f1:	e9 b6 f4 ff ff       	jmp    801055ac <alltraps>

801060f6 <vector171>:
.globl vector171
vector171:
  pushl $0
801060f6:	6a 00                	push   $0x0
  pushl $171
801060f8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801060fd:	e9 aa f4 ff ff       	jmp    801055ac <alltraps>

80106102 <vector172>:
.globl vector172
vector172:
  pushl $0
80106102:	6a 00                	push   $0x0
  pushl $172
80106104:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106109:	e9 9e f4 ff ff       	jmp    801055ac <alltraps>

8010610e <vector173>:
.globl vector173
vector173:
  pushl $0
8010610e:	6a 00                	push   $0x0
  pushl $173
80106110:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106115:	e9 92 f4 ff ff       	jmp    801055ac <alltraps>

8010611a <vector174>:
.globl vector174
vector174:
  pushl $0
8010611a:	6a 00                	push   $0x0
  pushl $174
8010611c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106121:	e9 86 f4 ff ff       	jmp    801055ac <alltraps>

80106126 <vector175>:
.globl vector175
vector175:
  pushl $0
80106126:	6a 00                	push   $0x0
  pushl $175
80106128:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010612d:	e9 7a f4 ff ff       	jmp    801055ac <alltraps>

80106132 <vector176>:
.globl vector176
vector176:
  pushl $0
80106132:	6a 00                	push   $0x0
  pushl $176
80106134:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106139:	e9 6e f4 ff ff       	jmp    801055ac <alltraps>

8010613e <vector177>:
.globl vector177
vector177:
  pushl $0
8010613e:	6a 00                	push   $0x0
  pushl $177
80106140:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106145:	e9 62 f4 ff ff       	jmp    801055ac <alltraps>

8010614a <vector178>:
.globl vector178
vector178:
  pushl $0
8010614a:	6a 00                	push   $0x0
  pushl $178
8010614c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106151:	e9 56 f4 ff ff       	jmp    801055ac <alltraps>

80106156 <vector179>:
.globl vector179
vector179:
  pushl $0
80106156:	6a 00                	push   $0x0
  pushl $179
80106158:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010615d:	e9 4a f4 ff ff       	jmp    801055ac <alltraps>

80106162 <vector180>:
.globl vector180
vector180:
  pushl $0
80106162:	6a 00                	push   $0x0
  pushl $180
80106164:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106169:	e9 3e f4 ff ff       	jmp    801055ac <alltraps>

8010616e <vector181>:
.globl vector181
vector181:
  pushl $0
8010616e:	6a 00                	push   $0x0
  pushl $181
80106170:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106175:	e9 32 f4 ff ff       	jmp    801055ac <alltraps>

8010617a <vector182>:
.globl vector182
vector182:
  pushl $0
8010617a:	6a 00                	push   $0x0
  pushl $182
8010617c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106181:	e9 26 f4 ff ff       	jmp    801055ac <alltraps>

80106186 <vector183>:
.globl vector183
vector183:
  pushl $0
80106186:	6a 00                	push   $0x0
  pushl $183
80106188:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010618d:	e9 1a f4 ff ff       	jmp    801055ac <alltraps>

80106192 <vector184>:
.globl vector184
vector184:
  pushl $0
80106192:	6a 00                	push   $0x0
  pushl $184
80106194:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106199:	e9 0e f4 ff ff       	jmp    801055ac <alltraps>

8010619e <vector185>:
.globl vector185
vector185:
  pushl $0
8010619e:	6a 00                	push   $0x0
  pushl $185
801061a0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801061a5:	e9 02 f4 ff ff       	jmp    801055ac <alltraps>

801061aa <vector186>:
.globl vector186
vector186:
  pushl $0
801061aa:	6a 00                	push   $0x0
  pushl $186
801061ac:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801061b1:	e9 f6 f3 ff ff       	jmp    801055ac <alltraps>

801061b6 <vector187>:
.globl vector187
vector187:
  pushl $0
801061b6:	6a 00                	push   $0x0
  pushl $187
801061b8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801061bd:	e9 ea f3 ff ff       	jmp    801055ac <alltraps>

801061c2 <vector188>:
.globl vector188
vector188:
  pushl $0
801061c2:	6a 00                	push   $0x0
  pushl $188
801061c4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801061c9:	e9 de f3 ff ff       	jmp    801055ac <alltraps>

801061ce <vector189>:
.globl vector189
vector189:
  pushl $0
801061ce:	6a 00                	push   $0x0
  pushl $189
801061d0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801061d5:	e9 d2 f3 ff ff       	jmp    801055ac <alltraps>

801061da <vector190>:
.globl vector190
vector190:
  pushl $0
801061da:	6a 00                	push   $0x0
  pushl $190
801061dc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801061e1:	e9 c6 f3 ff ff       	jmp    801055ac <alltraps>

801061e6 <vector191>:
.globl vector191
vector191:
  pushl $0
801061e6:	6a 00                	push   $0x0
  pushl $191
801061e8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801061ed:	e9 ba f3 ff ff       	jmp    801055ac <alltraps>

801061f2 <vector192>:
.globl vector192
vector192:
  pushl $0
801061f2:	6a 00                	push   $0x0
  pushl $192
801061f4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801061f9:	e9 ae f3 ff ff       	jmp    801055ac <alltraps>

801061fe <vector193>:
.globl vector193
vector193:
  pushl $0
801061fe:	6a 00                	push   $0x0
  pushl $193
80106200:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106205:	e9 a2 f3 ff ff       	jmp    801055ac <alltraps>

8010620a <vector194>:
.globl vector194
vector194:
  pushl $0
8010620a:	6a 00                	push   $0x0
  pushl $194
8010620c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106211:	e9 96 f3 ff ff       	jmp    801055ac <alltraps>

80106216 <vector195>:
.globl vector195
vector195:
  pushl $0
80106216:	6a 00                	push   $0x0
  pushl $195
80106218:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010621d:	e9 8a f3 ff ff       	jmp    801055ac <alltraps>

80106222 <vector196>:
.globl vector196
vector196:
  pushl $0
80106222:	6a 00                	push   $0x0
  pushl $196
80106224:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106229:	e9 7e f3 ff ff       	jmp    801055ac <alltraps>

8010622e <vector197>:
.globl vector197
vector197:
  pushl $0
8010622e:	6a 00                	push   $0x0
  pushl $197
80106230:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106235:	e9 72 f3 ff ff       	jmp    801055ac <alltraps>

8010623a <vector198>:
.globl vector198
vector198:
  pushl $0
8010623a:	6a 00                	push   $0x0
  pushl $198
8010623c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106241:	e9 66 f3 ff ff       	jmp    801055ac <alltraps>

80106246 <vector199>:
.globl vector199
vector199:
  pushl $0
80106246:	6a 00                	push   $0x0
  pushl $199
80106248:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010624d:	e9 5a f3 ff ff       	jmp    801055ac <alltraps>

80106252 <vector200>:
.globl vector200
vector200:
  pushl $0
80106252:	6a 00                	push   $0x0
  pushl $200
80106254:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106259:	e9 4e f3 ff ff       	jmp    801055ac <alltraps>

8010625e <vector201>:
.globl vector201
vector201:
  pushl $0
8010625e:	6a 00                	push   $0x0
  pushl $201
80106260:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106265:	e9 42 f3 ff ff       	jmp    801055ac <alltraps>

8010626a <vector202>:
.globl vector202
vector202:
  pushl $0
8010626a:	6a 00                	push   $0x0
  pushl $202
8010626c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106271:	e9 36 f3 ff ff       	jmp    801055ac <alltraps>

80106276 <vector203>:
.globl vector203
vector203:
  pushl $0
80106276:	6a 00                	push   $0x0
  pushl $203
80106278:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010627d:	e9 2a f3 ff ff       	jmp    801055ac <alltraps>

80106282 <vector204>:
.globl vector204
vector204:
  pushl $0
80106282:	6a 00                	push   $0x0
  pushl $204
80106284:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106289:	e9 1e f3 ff ff       	jmp    801055ac <alltraps>

8010628e <vector205>:
.globl vector205
vector205:
  pushl $0
8010628e:	6a 00                	push   $0x0
  pushl $205
80106290:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106295:	e9 12 f3 ff ff       	jmp    801055ac <alltraps>

8010629a <vector206>:
.globl vector206
vector206:
  pushl $0
8010629a:	6a 00                	push   $0x0
  pushl $206
8010629c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801062a1:	e9 06 f3 ff ff       	jmp    801055ac <alltraps>

801062a6 <vector207>:
.globl vector207
vector207:
  pushl $0
801062a6:	6a 00                	push   $0x0
  pushl $207
801062a8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801062ad:	e9 fa f2 ff ff       	jmp    801055ac <alltraps>

801062b2 <vector208>:
.globl vector208
vector208:
  pushl $0
801062b2:	6a 00                	push   $0x0
  pushl $208
801062b4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801062b9:	e9 ee f2 ff ff       	jmp    801055ac <alltraps>

801062be <vector209>:
.globl vector209
vector209:
  pushl $0
801062be:	6a 00                	push   $0x0
  pushl $209
801062c0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801062c5:	e9 e2 f2 ff ff       	jmp    801055ac <alltraps>

801062ca <vector210>:
.globl vector210
vector210:
  pushl $0
801062ca:	6a 00                	push   $0x0
  pushl $210
801062cc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801062d1:	e9 d6 f2 ff ff       	jmp    801055ac <alltraps>

801062d6 <vector211>:
.globl vector211
vector211:
  pushl $0
801062d6:	6a 00                	push   $0x0
  pushl $211
801062d8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801062dd:	e9 ca f2 ff ff       	jmp    801055ac <alltraps>

801062e2 <vector212>:
.globl vector212
vector212:
  pushl $0
801062e2:	6a 00                	push   $0x0
  pushl $212
801062e4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801062e9:	e9 be f2 ff ff       	jmp    801055ac <alltraps>

801062ee <vector213>:
.globl vector213
vector213:
  pushl $0
801062ee:	6a 00                	push   $0x0
  pushl $213
801062f0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801062f5:	e9 b2 f2 ff ff       	jmp    801055ac <alltraps>

801062fa <vector214>:
.globl vector214
vector214:
  pushl $0
801062fa:	6a 00                	push   $0x0
  pushl $214
801062fc:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106301:	e9 a6 f2 ff ff       	jmp    801055ac <alltraps>

80106306 <vector215>:
.globl vector215
vector215:
  pushl $0
80106306:	6a 00                	push   $0x0
  pushl $215
80106308:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010630d:	e9 9a f2 ff ff       	jmp    801055ac <alltraps>

80106312 <vector216>:
.globl vector216
vector216:
  pushl $0
80106312:	6a 00                	push   $0x0
  pushl $216
80106314:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106319:	e9 8e f2 ff ff       	jmp    801055ac <alltraps>

8010631e <vector217>:
.globl vector217
vector217:
  pushl $0
8010631e:	6a 00                	push   $0x0
  pushl $217
80106320:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106325:	e9 82 f2 ff ff       	jmp    801055ac <alltraps>

8010632a <vector218>:
.globl vector218
vector218:
  pushl $0
8010632a:	6a 00                	push   $0x0
  pushl $218
8010632c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106331:	e9 76 f2 ff ff       	jmp    801055ac <alltraps>

80106336 <vector219>:
.globl vector219
vector219:
  pushl $0
80106336:	6a 00                	push   $0x0
  pushl $219
80106338:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010633d:	e9 6a f2 ff ff       	jmp    801055ac <alltraps>

80106342 <vector220>:
.globl vector220
vector220:
  pushl $0
80106342:	6a 00                	push   $0x0
  pushl $220
80106344:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106349:	e9 5e f2 ff ff       	jmp    801055ac <alltraps>

8010634e <vector221>:
.globl vector221
vector221:
  pushl $0
8010634e:	6a 00                	push   $0x0
  pushl $221
80106350:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106355:	e9 52 f2 ff ff       	jmp    801055ac <alltraps>

8010635a <vector222>:
.globl vector222
vector222:
  pushl $0
8010635a:	6a 00                	push   $0x0
  pushl $222
8010635c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106361:	e9 46 f2 ff ff       	jmp    801055ac <alltraps>

80106366 <vector223>:
.globl vector223
vector223:
  pushl $0
80106366:	6a 00                	push   $0x0
  pushl $223
80106368:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010636d:	e9 3a f2 ff ff       	jmp    801055ac <alltraps>

80106372 <vector224>:
.globl vector224
vector224:
  pushl $0
80106372:	6a 00                	push   $0x0
  pushl $224
80106374:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106379:	e9 2e f2 ff ff       	jmp    801055ac <alltraps>

8010637e <vector225>:
.globl vector225
vector225:
  pushl $0
8010637e:	6a 00                	push   $0x0
  pushl $225
80106380:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106385:	e9 22 f2 ff ff       	jmp    801055ac <alltraps>

8010638a <vector226>:
.globl vector226
vector226:
  pushl $0
8010638a:	6a 00                	push   $0x0
  pushl $226
8010638c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106391:	e9 16 f2 ff ff       	jmp    801055ac <alltraps>

80106396 <vector227>:
.globl vector227
vector227:
  pushl $0
80106396:	6a 00                	push   $0x0
  pushl $227
80106398:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010639d:	e9 0a f2 ff ff       	jmp    801055ac <alltraps>

801063a2 <vector228>:
.globl vector228
vector228:
  pushl $0
801063a2:	6a 00                	push   $0x0
  pushl $228
801063a4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801063a9:	e9 fe f1 ff ff       	jmp    801055ac <alltraps>

801063ae <vector229>:
.globl vector229
vector229:
  pushl $0
801063ae:	6a 00                	push   $0x0
  pushl $229
801063b0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801063b5:	e9 f2 f1 ff ff       	jmp    801055ac <alltraps>

801063ba <vector230>:
.globl vector230
vector230:
  pushl $0
801063ba:	6a 00                	push   $0x0
  pushl $230
801063bc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801063c1:	e9 e6 f1 ff ff       	jmp    801055ac <alltraps>

801063c6 <vector231>:
.globl vector231
vector231:
  pushl $0
801063c6:	6a 00                	push   $0x0
  pushl $231
801063c8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801063cd:	e9 da f1 ff ff       	jmp    801055ac <alltraps>

801063d2 <vector232>:
.globl vector232
vector232:
  pushl $0
801063d2:	6a 00                	push   $0x0
  pushl $232
801063d4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801063d9:	e9 ce f1 ff ff       	jmp    801055ac <alltraps>

801063de <vector233>:
.globl vector233
vector233:
  pushl $0
801063de:	6a 00                	push   $0x0
  pushl $233
801063e0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801063e5:	e9 c2 f1 ff ff       	jmp    801055ac <alltraps>

801063ea <vector234>:
.globl vector234
vector234:
  pushl $0
801063ea:	6a 00                	push   $0x0
  pushl $234
801063ec:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801063f1:	e9 b6 f1 ff ff       	jmp    801055ac <alltraps>

801063f6 <vector235>:
.globl vector235
vector235:
  pushl $0
801063f6:	6a 00                	push   $0x0
  pushl $235
801063f8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801063fd:	e9 aa f1 ff ff       	jmp    801055ac <alltraps>

80106402 <vector236>:
.globl vector236
vector236:
  pushl $0
80106402:	6a 00                	push   $0x0
  pushl $236
80106404:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106409:	e9 9e f1 ff ff       	jmp    801055ac <alltraps>

8010640e <vector237>:
.globl vector237
vector237:
  pushl $0
8010640e:	6a 00                	push   $0x0
  pushl $237
80106410:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106415:	e9 92 f1 ff ff       	jmp    801055ac <alltraps>

8010641a <vector238>:
.globl vector238
vector238:
  pushl $0
8010641a:	6a 00                	push   $0x0
  pushl $238
8010641c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106421:	e9 86 f1 ff ff       	jmp    801055ac <alltraps>

80106426 <vector239>:
.globl vector239
vector239:
  pushl $0
80106426:	6a 00                	push   $0x0
  pushl $239
80106428:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010642d:	e9 7a f1 ff ff       	jmp    801055ac <alltraps>

80106432 <vector240>:
.globl vector240
vector240:
  pushl $0
80106432:	6a 00                	push   $0x0
  pushl $240
80106434:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106439:	e9 6e f1 ff ff       	jmp    801055ac <alltraps>

8010643e <vector241>:
.globl vector241
vector241:
  pushl $0
8010643e:	6a 00                	push   $0x0
  pushl $241
80106440:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106445:	e9 62 f1 ff ff       	jmp    801055ac <alltraps>

8010644a <vector242>:
.globl vector242
vector242:
  pushl $0
8010644a:	6a 00                	push   $0x0
  pushl $242
8010644c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106451:	e9 56 f1 ff ff       	jmp    801055ac <alltraps>

80106456 <vector243>:
.globl vector243
vector243:
  pushl $0
80106456:	6a 00                	push   $0x0
  pushl $243
80106458:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010645d:	e9 4a f1 ff ff       	jmp    801055ac <alltraps>

80106462 <vector244>:
.globl vector244
vector244:
  pushl $0
80106462:	6a 00                	push   $0x0
  pushl $244
80106464:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106469:	e9 3e f1 ff ff       	jmp    801055ac <alltraps>

8010646e <vector245>:
.globl vector245
vector245:
  pushl $0
8010646e:	6a 00                	push   $0x0
  pushl $245
80106470:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106475:	e9 32 f1 ff ff       	jmp    801055ac <alltraps>

8010647a <vector246>:
.globl vector246
vector246:
  pushl $0
8010647a:	6a 00                	push   $0x0
  pushl $246
8010647c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106481:	e9 26 f1 ff ff       	jmp    801055ac <alltraps>

80106486 <vector247>:
.globl vector247
vector247:
  pushl $0
80106486:	6a 00                	push   $0x0
  pushl $247
80106488:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010648d:	e9 1a f1 ff ff       	jmp    801055ac <alltraps>

80106492 <vector248>:
.globl vector248
vector248:
  pushl $0
80106492:	6a 00                	push   $0x0
  pushl $248
80106494:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106499:	e9 0e f1 ff ff       	jmp    801055ac <alltraps>

8010649e <vector249>:
.globl vector249
vector249:
  pushl $0
8010649e:	6a 00                	push   $0x0
  pushl $249
801064a0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801064a5:	e9 02 f1 ff ff       	jmp    801055ac <alltraps>

801064aa <vector250>:
.globl vector250
vector250:
  pushl $0
801064aa:	6a 00                	push   $0x0
  pushl $250
801064ac:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801064b1:	e9 f6 f0 ff ff       	jmp    801055ac <alltraps>

801064b6 <vector251>:
.globl vector251
vector251:
  pushl $0
801064b6:	6a 00                	push   $0x0
  pushl $251
801064b8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801064bd:	e9 ea f0 ff ff       	jmp    801055ac <alltraps>

801064c2 <vector252>:
.globl vector252
vector252:
  pushl $0
801064c2:	6a 00                	push   $0x0
  pushl $252
801064c4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801064c9:	e9 de f0 ff ff       	jmp    801055ac <alltraps>

801064ce <vector253>:
.globl vector253
vector253:
  pushl $0
801064ce:	6a 00                	push   $0x0
  pushl $253
801064d0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801064d5:	e9 d2 f0 ff ff       	jmp    801055ac <alltraps>

801064da <vector254>:
.globl vector254
vector254:
  pushl $0
801064da:	6a 00                	push   $0x0
  pushl $254
801064dc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801064e1:	e9 c6 f0 ff ff       	jmp    801055ac <alltraps>

801064e6 <vector255>:
.globl vector255
vector255:
  pushl $0
801064e6:	6a 00                	push   $0x0
  pushl $255
801064e8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801064ed:	e9 ba f0 ff ff       	jmp    801055ac <alltraps>
	...

80106500 <switchkvm>:
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106500:	a1 c4 54 11 80       	mov    0x801154c4,%eax

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80106505:	55                   	push   %ebp
80106506:	89 e5                	mov    %esp,%ebp
80106508:	2d 00 00 00 80       	sub    $0x80000000,%eax
8010650d:	0f 22 d8             	mov    %eax,%cr3
  lcr3(V2P(kpgdir));   // switch to the kernel page table
}
80106510:	5d                   	pop    %ebp
80106511:	c3                   	ret    
80106512:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106519:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106520 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106520:	55                   	push   %ebp
80106521:	89 e5                	mov    %esp,%ebp
80106523:	83 ec 28             	sub    $0x28,%esp
80106526:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106529:	89 d3                	mov    %edx,%ebx
8010652b:	c1 eb 16             	shr    $0x16,%ebx
8010652e:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106531:	89 75 fc             	mov    %esi,-0x4(%ebp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
80106534:	8b 33                	mov    (%ebx),%esi
80106536:	f7 c6 01 00 00 00    	test   $0x1,%esi
8010653c:	74 22                	je     80106560 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010653e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80106544:	81 ee 00 00 00 80    	sub    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
8010654a:	c1 ea 0a             	shr    $0xa,%edx
8010654d:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106553:	8d 04 16             	lea    (%esi,%edx,1),%eax
}
80106556:	8b 5d f8             	mov    -0x8(%ebp),%ebx
80106559:	8b 75 fc             	mov    -0x4(%ebp),%esi
8010655c:	89 ec                	mov    %ebp,%esp
8010655e:	5d                   	pop    %ebp
8010655f:	c3                   	ret    

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106560:	85 c9                	test   %ecx,%ecx
80106562:	75 04                	jne    80106568 <walkpgdir+0x48>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106564:	31 c0                	xor    %eax,%eax
80106566:	eb ee                	jmp    80106556 <walkpgdir+0x36>

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106568:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010656b:	90                   	nop
8010656c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106570:	e8 7b be ff ff       	call   801023f0 <kalloc>
80106575:	85 c0                	test   %eax,%eax
80106577:	89 c6                	mov    %eax,%esi
80106579:	74 e9                	je     80106564 <walkpgdir+0x44>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010657b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106582:	00 
80106583:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010658a:	00 
8010658b:	89 04 24             	mov    %eax,(%esp)
8010658e:	e8 ad de ff ff       	call   80104440 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106593:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106599:	83 c8 07             	or     $0x7,%eax
8010659c:	89 03                	mov    %eax,(%ebx)
8010659e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065a1:	eb a7                	jmp    8010654a <walkpgdir+0x2a>
801065a3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801065a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801065b0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801065b0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065b1:	31 c9                	xor    %ecx,%ecx

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801065b3:	89 e5                	mov    %esp,%ebp
801065b5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801065bb:	8b 45 08             	mov    0x8(%ebp),%eax
801065be:	e8 5d ff ff ff       	call   80106520 <walkpgdir>
  if((*pte & PTE_P) == 0)
801065c3:	8b 00                	mov    (%eax),%eax
801065c5:	a8 01                	test   $0x1,%al
801065c7:	75 07                	jne    801065d0 <uva2ka+0x20>
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801065c9:	31 c0                	xor    %eax,%eax
}
801065cb:	c9                   	leave  
801065cc:	c3                   	ret    
801065cd:	8d 76 00             	lea    0x0(%esi),%esi
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
801065d0:	a8 04                	test   $0x4,%al
801065d2:	74 f5                	je     801065c9 <uva2ka+0x19>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801065d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065d9:	2d 00 00 00 80       	sub    $0x80000000,%eax
}
801065de:	c9                   	leave  
801065df:	90                   	nop
801065e0:	c3                   	ret    
801065e1:	eb 0d                	jmp    801065f0 <copyout>
801065e3:	90                   	nop
801065e4:	90                   	nop
801065e5:	90                   	nop
801065e6:	90                   	nop
801065e7:	90                   	nop
801065e8:	90                   	nop
801065e9:	90                   	nop
801065ea:	90                   	nop
801065eb:	90                   	nop
801065ec:	90                   	nop
801065ed:	90                   	nop
801065ee:	90                   	nop
801065ef:	90                   	nop

801065f0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801065f0:	55                   	push   %ebp
801065f1:	89 e5                	mov    %esp,%ebp
801065f3:	57                   	push   %edi
801065f4:	56                   	push   %esi
801065f5:	53                   	push   %ebx
801065f6:	83 ec 2c             	sub    $0x2c,%esp
801065f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
801065fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801065ff:	85 db                	test   %ebx,%ebx
80106601:	74 75                	je     80106678 <copyout+0x88>
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80106603:	8b 45 10             	mov    0x10(%ebp),%eax
80106606:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106609:	eb 39                	jmp    80106644 <copyout+0x54>
8010660b:	90                   	nop
8010660c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80106610:	89 f7                	mov    %esi,%edi
80106612:	29 d7                	sub    %edx,%edi
80106614:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010661a:	39 df                	cmp    %ebx,%edi
8010661c:	0f 47 fb             	cmova  %ebx,%edi
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
8010661f:	29 f2                	sub    %esi,%edx
80106621:	89 7c 24 08          	mov    %edi,0x8(%esp)
80106625:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106628:	8d 14 10             	lea    (%eax,%edx,1),%edx
8010662b:	89 14 24             	mov    %edx,(%esp)
8010662e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106632:	e8 c9 de ff ff       	call   80104500 <memmove>
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106637:	29 fb                	sub    %edi,%ebx
80106639:	74 3d                	je     80106678 <copyout+0x88>
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
8010663b:	01 7d e4             	add    %edi,-0x1c(%ebp)
    va = va0 + PGSIZE;
8010663e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
80106644:	89 d6                	mov    %edx,%esi
80106646:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010664c:	89 74 24 04          	mov    %esi,0x4(%esp)
80106650:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106653:	89 0c 24             	mov    %ecx,(%esp)
80106656:	89 55 e0             	mov    %edx,-0x20(%ebp)
80106659:	e8 52 ff ff ff       	call   801065b0 <uva2ka>
    if(pa0 == 0)
8010665e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106661:	85 c0                	test   %eax,%eax
80106663:	75 ab                	jne    80106610 <copyout+0x20>
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
80106665:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
80106668:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010666d:	5b                   	pop    %ebx
8010666e:	5e                   	pop    %esi
8010666f:	5f                   	pop    %edi
80106670:	5d                   	pop    %ebp
80106671:	c3                   	ret    
80106672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106678:	83 c4 2c             	add    $0x2c,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
8010667b:	31 c0                	xor    %eax,%eax
  }
  return 0;
}
8010667d:	5b                   	pop    %ebx
8010667e:	5e                   	pop    %esi
8010667f:	5f                   	pop    %edi
80106680:	5d                   	pop    %ebp
80106681:	c3                   	ret    
80106682:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106689:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106690 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	57                   	push   %edi
80106694:	56                   	push   %esi
80106695:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106696:	89 d3                	mov    %edx,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106698:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010669c:	83 ec 2c             	sub    $0x2c,%esp
8010669f:	8b 75 08             	mov    0x8(%ebp),%esi
801066a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801066a5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801066ab:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
801066b1:	83 4d 0c 01          	orl    $0x1,0xc(%ebp)
801066b5:	eb 1d                	jmp    801066d4 <mappages+0x44>
801066b7:	90                   	nop
  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
801066b8:	f6 00 01             	testb  $0x1,(%eax)
801066bb:	75 45                	jne    80106702 <mappages+0x72>
      panic("remap");
    *pte = pa | perm | PTE_P;
801066bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801066c0:	09 f2                	or     %esi,%edx
    if(a == last)
801066c2:	39 fb                	cmp    %edi,%ebx
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
801066c4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801066c6:	74 30                	je     801066f8 <mappages+0x68>
      break;
    a += PGSIZE;
801066c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
801066ce:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801066d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066d7:	b9 01 00 00 00       	mov    $0x1,%ecx
801066dc:	89 da                	mov    %ebx,%edx
801066de:	e8 3d fe ff ff       	call   80106520 <walkpgdir>
801066e3:	85 c0                	test   %eax,%eax
801066e5:	75 d1                	jne    801066b8 <mappages+0x28>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
801066e7:	83 c4 2c             	add    $0x2c,%esp
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
801066ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return 0;
}
801066ef:	5b                   	pop    %ebx
801066f0:	5e                   	pop    %esi
801066f1:	5f                   	pop    %edi
801066f2:	5d                   	pop    %ebp
801066f3:	c3                   	ret    
801066f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801066f8:	83 c4 2c             	add    $0x2c,%esp
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
801066fb:	31 c0                	xor    %eax,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
801066fd:	5b                   	pop    %ebx
801066fe:	5e                   	pop    %esi
801066ff:	5f                   	pop    %edi
80106700:	5d                   	pop    %ebp
80106701:	c3                   	ret    
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
80106702:	c7 04 24 0c 77 10 80 	movl   $0x8010770c,(%esp)
80106709:	e8 a2 9c ff ff       	call   801003b0 <panic>
8010670e:	66 90                	xchg   %ax,%ax

80106710 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106710:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106711:	31 c9                	xor    %ecx,%ecx

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106713:	89 e5                	mov    %esp,%ebp
80106715:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106718:	8b 55 0c             	mov    0xc(%ebp),%edx
8010671b:	8b 45 08             	mov    0x8(%ebp),%eax
8010671e:	e8 fd fd ff ff       	call   80106520 <walkpgdir>
  if(pte == 0)
80106723:	85 c0                	test   %eax,%eax
80106725:	74 05                	je     8010672c <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106727:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010672a:	c9                   	leave  
8010672b:	c3                   	ret    
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
8010672c:	c7 04 24 12 77 10 80 	movl   $0x80107712,(%esp)
80106733:	e8 78 9c ff ff       	call   801003b0 <panic>
80106738:	90                   	nop
80106739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106740 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106740:	55                   	push   %ebp
80106741:	89 e5                	mov    %esp,%ebp
80106743:	83 ec 38             	sub    $0x38,%esp
80106746:	89 75 f8             	mov    %esi,-0x8(%ebp)
80106749:	8b 75 10             	mov    0x10(%ebp),%esi
8010674c:	8b 45 08             	mov    0x8(%ebp),%eax
8010674f:	89 7d fc             	mov    %edi,-0x4(%ebp)
80106752:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106755:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  char *mem;

  if(sz >= PGSIZE)
80106758:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010675e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char *mem;

  if(sz >= PGSIZE)
80106761:	77 59                	ja     801067bc <inituvm+0x7c>
    panic("inituvm: more than a page");
  mem = kalloc();
80106763:	e8 88 bc ff ff       	call   801023f0 <kalloc>
  memset(mem, 0, PGSIZE);
80106768:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010676f:	00 
80106770:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106777:	00 
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
80106778:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010677a:	89 04 24             	mov    %eax,(%esp)
8010677d:	e8 be dc ff ff       	call   80104440 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106782:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106788:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010678d:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80106794:	00 
80106795:	31 d2                	xor    %edx,%edx
80106797:	89 04 24             	mov    %eax,(%esp)
8010679a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010679d:	e8 ee fe ff ff       	call   80106690 <mappages>
  memmove(mem, init, sz);
801067a2:	89 75 10             	mov    %esi,0x10(%ebp)
}
801067a5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
801067a8:	89 7d 0c             	mov    %edi,0xc(%ebp)
}
801067ab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
801067ae:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801067b1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801067b4:	89 ec                	mov    %ebp,%esp
801067b6:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
801067b7:	e9 44 dd ff ff       	jmp    80104500 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
801067bc:	c7 04 24 1c 77 10 80 	movl   $0x8010771c,(%esp)
801067c3:	e8 e8 9b ff ff       	call   801003b0 <panic>
801067c8:	90                   	nop
801067c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801067d0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801067d0:	55                   	push   %ebp
801067d1:	89 e5                	mov    %esp,%ebp
801067d3:	57                   	push   %edi
801067d4:	56                   	push   %esi
801067d5:	53                   	push   %ebx
801067d6:	83 ec 2c             	sub    $0x2c,%esp
801067d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801067dc:	39 75 10             	cmp    %esi,0x10(%ebp)
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801067df:	8b 7d 08             	mov    0x8(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
801067e2:	89 f0                	mov    %esi,%eax
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801067e4:	73 7d                	jae    80106863 <deallocuvm+0x93>
    return oldsz;

  a = PGROUNDUP(newsz);
801067e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
801067e9:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
801067ef:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801067f5:	39 de                	cmp    %ebx,%esi
801067f7:	77 3d                	ja     80106836 <deallocuvm+0x66>
801067f9:	eb 65                	jmp    80106860 <deallocuvm+0x90>
801067fb:	90                   	nop
801067fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
80106800:	8b 10                	mov    (%eax),%edx
80106802:	f6 c2 01             	test   $0x1,%dl
80106805:	74 25                	je     8010682c <deallocuvm+0x5c>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106807:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010680d:	8d 76 00             	lea    0x0(%esi),%esi
80106810:	74 59                	je     8010686b <deallocuvm+0x9b>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106812:	81 ea 00 00 00 80    	sub    $0x80000000,%edx
80106818:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010681b:	89 14 24             	mov    %edx,(%esp)
8010681e:	e8 1d bc ff ff       	call   80102440 <kfree>
      *pte = 0;
80106823:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106826:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010682c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106832:	39 de                	cmp    %ebx,%esi
80106834:	76 2a                	jbe    80106860 <deallocuvm+0x90>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106836:	31 c9                	xor    %ecx,%ecx
80106838:	89 da                	mov    %ebx,%edx
8010683a:	89 f8                	mov    %edi,%eax
8010683c:	e8 df fc ff ff       	call   80106520 <walkpgdir>
    if(!pte)
80106841:	85 c0                	test   %eax,%eax
80106843:	75 bb                	jne    80106800 <deallocuvm+0x30>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106845:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
8010684b:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80106851:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106857:	39 de                	cmp    %ebx,%esi
80106859:	77 db                	ja     80106836 <deallocuvm+0x66>
8010685b:	90                   	nop
8010685c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80106860:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106863:	83 c4 2c             	add    $0x2c,%esp
80106866:	5b                   	pop    %ebx
80106867:	5e                   	pop    %esi
80106868:	5f                   	pop    %edi
80106869:	5d                   	pop    %ebp
8010686a:	c3                   	ret    
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
8010686b:	c7 04 24 c6 70 10 80 	movl   $0x801070c6,(%esp)
80106872:	e8 39 9b ff ff       	call   801003b0 <panic>
80106877:	89 f6                	mov    %esi,%esi
80106879:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106880 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106880:	55                   	push   %ebp
80106881:	89 e5                	mov    %esp,%ebp
80106883:	56                   	push   %esi
80106884:	53                   	push   %ebx
80106885:	83 ec 10             	sub    $0x10,%esp
80106888:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
8010688b:	85 db                	test   %ebx,%ebx
8010688d:	74 5e                	je     801068ed <freevm+0x6d>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010688f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106896:	00 
80106897:	31 f6                	xor    %esi,%esi
80106899:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801068a0:	80 
801068a1:	89 1c 24             	mov    %ebx,(%esp)
801068a4:	e8 27 ff ff ff       	call   801067d0 <deallocuvm>
801068a9:	eb 10                	jmp    801068bb <freevm+0x3b>
801068ab:	90                   	nop
801068ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(i = 0; i < NPDENTRIES; i++){
801068b0:	83 c6 01             	add    $0x1,%esi
801068b3:	81 fe 00 04 00 00    	cmp    $0x400,%esi
801068b9:	74 24                	je     801068df <freevm+0x5f>
    if(pgdir[i] & PTE_P){
801068bb:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
801068be:	a8 01                	test   $0x1,%al
801068c0:	74 ee                	je     801068b0 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
801068c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801068c7:	83 c6 01             	add    $0x1,%esi
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
801068ca:	2d 00 00 00 80       	sub    $0x80000000,%eax
801068cf:	89 04 24             	mov    %eax,(%esp)
801068d2:	e8 69 bb ff ff       	call   80102440 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801068d7:	81 fe 00 04 00 00    	cmp    $0x400,%esi
801068dd:	75 dc                	jne    801068bb <freevm+0x3b>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801068df:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801068e2:	83 c4 10             	add    $0x10,%esp
801068e5:	5b                   	pop    %ebx
801068e6:	5e                   	pop    %esi
801068e7:	5d                   	pop    %ebp
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801068e8:	e9 53 bb ff ff       	jmp    80102440 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
801068ed:	c7 04 24 36 77 10 80 	movl   $0x80107736,(%esp)
801068f4:	e8 b7 9a ff ff       	call   801003b0 <panic>
801068f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106900 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80106900:	55                   	push   %ebp
80106901:	89 e5                	mov    %esp,%ebp
80106903:	56                   	push   %esi
80106904:	53                   	push   %ebx
80106905:	83 ec 10             	sub    $0x10,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80106908:	e8 e3 ba ff ff       	call   801023f0 <kalloc>
8010690d:	85 c0                	test   %eax,%eax
8010690f:	89 c6                	mov    %eax,%esi
80106911:	74 53                	je     80106966 <setupkvm+0x66>
    return 0;
  memset(pgdir, 0, PGSIZE);
80106913:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010691a:	00 
8010691b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106922:	00 
80106923:	89 04 24             	mov    %eax,(%esp)
80106926:	e8 15 db ff ff       	call   80104440 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010692b:	b8 60 a4 10 80       	mov    $0x8010a460,%eax
80106930:	3d 20 a4 10 80       	cmp    $0x8010a420,%eax
80106935:	76 2f                	jbe    80106966 <setupkvm+0x66>
 { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
80106937:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010693c:	8b 43 04             	mov    0x4(%ebx),%eax
8010693f:	8b 53 0c             	mov    0xc(%ebx),%edx
80106942:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106945:	89 04 24             	mov    %eax,(%esp)
80106948:	89 54 24 04          	mov    %edx,0x4(%esp)
8010694c:	8b 13                	mov    (%ebx),%edx
8010694e:	29 c1                	sub    %eax,%ecx
80106950:	89 f0                	mov    %esi,%eax
80106952:	e8 39 fd ff ff       	call   80106690 <mappages>
80106957:	85 c0                	test   %eax,%eax
80106959:	78 15                	js     80106970 <setupkvm+0x70>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010695b:	83 c3 10             	add    $0x10,%ebx
8010695e:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106964:	75 d6                	jne    8010693c <setupkvm+0x3c>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
}
80106966:	83 c4 10             	add    $0x10,%esp
80106969:	89 f0                	mov    %esi,%eax
8010696b:	5b                   	pop    %ebx
8010696c:	5e                   	pop    %esi
8010696d:	5d                   	pop    %ebp
8010696e:	c3                   	ret    
8010696f:	90                   	nop
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80106970:	89 34 24             	mov    %esi,(%esp)
80106973:	31 f6                	xor    %esi,%esi
80106975:	e8 06 ff ff ff       	call   80106880 <freevm>
      return 0;
    }
  return pgdir;
}
8010697a:	83 c4 10             	add    $0x10,%esp
8010697d:	89 f0                	mov    %esi,%eax
8010697f:	5b                   	pop    %ebx
80106980:	5e                   	pop    %esi
80106981:	5d                   	pop    %ebp
80106982:	c3                   	ret    
80106983:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106989:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106990 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80106990:	55                   	push   %ebp
80106991:	89 e5                	mov    %esp,%ebp
80106993:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106996:	e8 65 ff ff ff       	call   80106900 <setupkvm>
8010699b:	a3 c4 54 11 80       	mov    %eax,0x801154c4
801069a0:	2d 00 00 00 80       	sub    $0x80000000,%eax
801069a5:	0f 22 d8             	mov    %eax,%cr3
  switchkvm();
}
801069a8:	c9                   	leave  
801069a9:	c3                   	ret    
801069aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801069b0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801069b0:	55                   	push   %ebp
801069b1:	89 e5                	mov    %esp,%ebp
801069b3:	57                   	push   %edi
801069b4:	56                   	push   %esi
801069b5:	53                   	push   %ebx
801069b6:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801069b9:	e8 42 ff ff ff       	call   80106900 <setupkvm>
801069be:	85 c0                	test   %eax,%eax
801069c0:	89 c7                	mov    %eax,%edi
801069c2:	0f 84 91 00 00 00    	je     80106a59 <copyuvm+0xa9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801069c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801069cb:	85 c0                	test   %eax,%eax
801069cd:	0f 84 86 00 00 00    	je     80106a59 <copyuvm+0xa9>
801069d3:	31 f6                	xor    %esi,%esi
801069d5:	eb 54                	jmp    80106a2b <copyuvm+0x7b>
801069d7:	90                   	nop
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801069d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069db:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801069e2:	00 
801069e3:	89 1c 24             	mov    %ebx,(%esp)
801069e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801069eb:	2d 00 00 00 80       	sub    $0x80000000,%eax
801069f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801069f4:	e8 07 db ff ff       	call   80104500 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801069f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069fc:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106a01:	89 f2                	mov    %esi,%edx
80106a03:	25 ff 0f 00 00       	and    $0xfff,%eax
80106a08:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a0c:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106a12:	89 04 24             	mov    %eax,(%esp)
80106a15:	89 f8                	mov    %edi,%eax
80106a17:	e8 74 fc ff ff       	call   80106690 <mappages>
80106a1c:	85 c0                	test   %eax,%eax
80106a1e:	78 48                	js     80106a68 <copyuvm+0xb8>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106a20:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106a26:	39 75 0c             	cmp    %esi,0xc(%ebp)
80106a29:	76 2e                	jbe    80106a59 <copyuvm+0xa9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2e:	31 c9                	xor    %ecx,%ecx
80106a30:	89 f2                	mov    %esi,%edx
80106a32:	e8 e9 fa ff ff       	call   80106520 <walkpgdir>
80106a37:	85 c0                	test   %eax,%eax
80106a39:	74 43                	je     80106a7e <copyuvm+0xce>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106a3b:	8b 00                	mov    (%eax),%eax
80106a3d:	a8 01                	test   $0x1,%al
80106a3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a42:	74 2e                	je     80106a72 <copyuvm+0xc2>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106a44:	e8 a7 b9 ff ff       	call   801023f0 <kalloc>
80106a49:	85 c0                	test   %eax,%eax
80106a4b:	89 c3                	mov    %eax,%ebx
80106a4d:	75 89                	jne    801069d8 <copyuvm+0x28>
    }
  }
  return d;

bad:
  freevm(d);
80106a4f:	89 3c 24             	mov    %edi,(%esp)
80106a52:	31 ff                	xor    %edi,%edi
80106a54:	e8 27 fe ff ff       	call   80106880 <freevm>
  return 0;
}
80106a59:	83 c4 2c             	add    $0x2c,%esp
80106a5c:	89 f8                	mov    %edi,%eax
80106a5e:	5b                   	pop    %ebx
80106a5f:	5e                   	pop    %esi
80106a60:	5f                   	pop    %edi
80106a61:	5d                   	pop    %ebp
80106a62:	c3                   	ret    
80106a63:	90                   	nop
80106a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
      kfree(mem);
80106a68:	89 1c 24             	mov    %ebx,(%esp)
80106a6b:	e8 d0 b9 ff ff       	call   80102440 <kfree>
      goto bad;
80106a70:	eb dd                	jmp    80106a4f <copyuvm+0x9f>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106a72:	c7 04 24 61 77 10 80 	movl   $0x80107761,(%esp)
80106a79:	e8 32 99 ff ff       	call   801003b0 <panic>

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106a7e:	c7 04 24 47 77 10 80 	movl   $0x80107747,(%esp)
80106a85:	e8 26 99 ff ff       	call   801003b0 <panic>
80106a8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106a90 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106a90:	55                   	push   %ebp
80106a91:	89 e5                	mov    %esp,%ebp
80106a93:	57                   	push   %edi
80106a94:	56                   	push   %esi
80106a95:	53                   	push   %ebx
80106a96:	83 ec 2c             	sub    $0x2c,%esp
80106a99:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80106a9c:	85 ff                	test   %edi,%edi
80106a9e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106aa1:	0f 88 9c 00 00 00    	js     80106b43 <allocuvm+0xb3>
    return 0;
  if(newsz < oldsz)
80106aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aaa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
80106aad:	0f 82 a5 00 00 00    	jb     80106b58 <allocuvm+0xc8>
    return oldsz;

  a = PGROUNDUP(oldsz);
80106ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
80106ab6:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
80106abc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106ac2:	39 f7                	cmp    %esi,%edi
80106ac4:	77 50                	ja     80106b16 <allocuvm+0x86>
80106ac6:	e9 90 00 00 00       	jmp    80106b5b <allocuvm+0xcb>
80106acb:	90                   	nop
80106acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
80106ad0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106ad7:	00 
80106ad8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106adf:	00 
80106ae0:	89 04 24             	mov    %eax,(%esp)
80106ae3:	e8 58 d9 ff ff       	call   80104440 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106ae8:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106aee:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106af3:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80106afa:	00 
80106afb:	89 f2                	mov    %esi,%edx
80106afd:	89 04 24             	mov    %eax,(%esp)
80106b00:	8b 45 08             	mov    0x8(%ebp),%eax
80106b03:	e8 88 fb ff ff       	call   80106690 <mappages>
80106b08:	85 c0                	test   %eax,%eax
80106b0a:	78 5c                	js     80106b68 <allocuvm+0xd8>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80106b0c:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106b12:	39 f7                	cmp    %esi,%edi
80106b14:	76 45                	jbe    80106b5b <allocuvm+0xcb>
    mem = kalloc();
80106b16:	e8 d5 b8 ff ff       	call   801023f0 <kalloc>
    if(mem == 0){
80106b1b:	85 c0                	test   %eax,%eax
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
    mem = kalloc();
80106b1d:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106b1f:	75 af                	jne    80106ad0 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80106b21:	c7 04 24 7b 77 10 80 	movl   $0x8010777b,(%esp)
80106b28:	e8 23 9d ff ff       	call   80100850 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b30:	89 7c 24 04          	mov    %edi,0x4(%esp)
80106b34:	89 44 24 08          	mov    %eax,0x8(%esp)
80106b38:	8b 45 08             	mov    0x8(%ebp),%eax
80106b3b:	89 04 24             	mov    %eax,(%esp)
80106b3e:	e8 8d fc ff ff       	call   801067d0 <deallocuvm>
80106b43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
80106b4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b4d:	83 c4 2c             	add    $0x2c,%esp
80106b50:	5b                   	pop    %ebx
80106b51:	5e                   	pop    %esi
80106b52:	5f                   	pop    %edi
80106b53:	5d                   	pop    %ebp
80106b54:	c3                   	ret    
80106b55:	8d 76 00             	lea    0x0(%esi),%esi
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;
80106b58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
80106b5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b5e:	83 c4 2c             	add    $0x2c,%esp
80106b61:	5b                   	pop    %ebx
80106b62:	5e                   	pop    %esi
80106b63:	5f                   	pop    %edi
80106b64:	5d                   	pop    %ebp
80106b65:	c3                   	ret    
80106b66:	66 90                	xchg   %ax,%ax
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
80106b68:	c7 04 24 93 77 10 80 	movl   $0x80107793,(%esp)
80106b6f:	e8 dc 9c ff ff       	call   80100850 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106b74:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b77:	89 7c 24 04          	mov    %edi,0x4(%esp)
80106b7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80106b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b82:	89 04 24             	mov    %eax,(%esp)
80106b85:	e8 46 fc ff ff       	call   801067d0 <deallocuvm>
      kfree(mem);
80106b8a:	89 1c 24             	mov    %ebx,(%esp)
80106b8d:	e8 ae b8 ff ff       	call   80102440 <kfree>
80106b92:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      return 0;
    }
  }
  return newsz;
}
80106b99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b9c:	83 c4 2c             	add    $0x2c,%esp
80106b9f:	5b                   	pop    %ebx
80106ba0:	5e                   	pop    %esi
80106ba1:	5f                   	pop    %edi
80106ba2:	5d                   	pop    %ebp
80106ba3:	c3                   	ret    
80106ba4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106baa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80106bb0 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106bb0:	55                   	push   %ebp
80106bb1:	89 e5                	mov    %esp,%ebp
80106bb3:	57                   	push   %edi
80106bb4:	56                   	push   %esi
80106bb5:	53                   	push   %ebx
80106bb6:	83 ec 2c             	sub    $0x2c,%esp
80106bb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106bbc:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
80106bc2:	0f 85 96 00 00 00    	jne    80106c5e <loaduvm+0xae>
    panic("loaduvm: addr must be page aligned");
80106bc8:	8b 75 18             	mov    0x18(%ebp),%esi
80106bcb:	31 db                	xor    %ebx,%ebx
  for(i = 0; i < sz; i += PGSIZE){
80106bcd:	85 f6                	test   %esi,%esi
80106bcf:	75 18                	jne    80106be9 <loaduvm+0x39>
80106bd1:	eb 75                	jmp    80106c48 <loaduvm+0x98>
80106bd3:	90                   	nop
80106bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106bd8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106bde:	81 ee 00 10 00 00    	sub    $0x1000,%esi
80106be4:	39 5d 18             	cmp    %ebx,0x18(%ebp)
80106be7:	76 5f                	jbe    80106c48 <loaduvm+0x98>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106be9:	8b 45 08             	mov    0x8(%ebp),%eax
80106bec:	31 c9                	xor    %ecx,%ecx
80106bee:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
80106bf1:	e8 2a f9 ff ff       	call   80106520 <walkpgdir>
80106bf6:	85 c0                	test   %eax,%eax
80106bf8:	74 58                	je     80106c52 <loaduvm+0xa2>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
80106bfa:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
80106c00:	ba 00 10 00 00       	mov    $0x1000,%edx
  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
80106c05:	8b 00                	mov    (%eax),%eax
    if(sz - i < PGSIZE)
80106c07:	0f 42 d6             	cmovb  %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106c0a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80106c0e:	8b 4d 14             	mov    0x14(%ebp),%ecx
80106c11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106c16:	2d 00 00 00 80       	sub    $0x80000000,%eax
80106c1b:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
80106c1e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c22:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c26:	8b 45 10             	mov    0x10(%ebp),%eax
80106c29:	89 04 24             	mov    %eax,(%esp)
80106c2c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80106c2f:	e8 8c ab ff ff       	call   801017c0 <readi>
80106c34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106c37:	39 d0                	cmp    %edx,%eax
80106c39:	74 9d                	je     80106bd8 <loaduvm+0x28>
      return -1;
  }
  return 0;
}
80106c3b:	83 c4 2c             	add    $0x2c,%esp
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return -1;
  }
  return 0;
}
80106c43:	5b                   	pop    %ebx
80106c44:	5e                   	pop    %esi
80106c45:	5f                   	pop    %edi
80106c46:	5d                   	pop    %ebp
80106c47:	c3                   	ret    
80106c48:	83 c4 2c             	add    $0x2c,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106c4b:	31 c0                	xor    %eax,%eax
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
}
80106c4d:	5b                   	pop    %ebx
80106c4e:	5e                   	pop    %esi
80106c4f:	5f                   	pop    %edi
80106c50:	5d                   	pop    %ebp
80106c51:	c3                   	ret    

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106c52:	c7 04 24 af 77 10 80 	movl   $0x801077af,(%esp)
80106c59:	e8 52 97 ff ff       	call   801003b0 <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
80106c5e:	c7 04 24 0c 78 10 80 	movl   $0x8010780c,(%esp)
80106c65:	e8 46 97 ff ff       	call   801003b0 <panic>
80106c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106c70 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106c70:	55                   	push   %ebp
80106c71:	89 e5                	mov    %esp,%ebp
80106c73:	57                   	push   %edi
80106c74:	56                   	push   %esi
80106c75:	53                   	push   %ebx
80106c76:	83 ec 2c             	sub    $0x2c,%esp
80106c79:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106c7c:	85 f6                	test   %esi,%esi
80106c7e:	0f 84 c4 00 00 00    	je     80106d48 <switchuvm+0xd8>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106c84:	8b 4e 08             	mov    0x8(%esi),%ecx
80106c87:	85 c9                	test   %ecx,%ecx
80106c89:	0f 84 d1 00 00 00    	je     80106d60 <switchuvm+0xf0>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80106c8f:	8b 56 04             	mov    0x4(%esi),%edx
80106c92:	85 d2                	test   %edx,%edx
80106c94:	0f 84 ba 00 00 00    	je     80106d54 <switchuvm+0xe4>
    panic("switchuvm: no pgdir");

  pushcli();
80106c9a:	e8 51 d6 ff ff       	call   801042f0 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106c9f:	e8 4c cd ff ff       	call   801039f0 <mycpu>
80106ca4:	89 c3                	mov    %eax,%ebx
80106ca6:	e8 45 cd ff ff       	call   801039f0 <mycpu>
80106cab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106cae:	e8 3d cd ff ff       	call   801039f0 <mycpu>
80106cb3:	89 c7                	mov    %eax,%edi
80106cb5:	e8 36 cd ff ff       	call   801039f0 <mycpu>
80106cba:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106cc1:	67 00 
80106cc3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106cc6:	c6 83 9d 00 00 00 99 	movb   $0x99,0x9d(%ebx)
80106ccd:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106cd4:	83 c2 08             	add    $0x8,%edx
80106cd7:	66 89 93 9a 00 00 00 	mov    %dx,0x9a(%ebx)
80106cde:	83 c0 08             	add    $0x8,%eax
80106ce1:	8d 57 08             	lea    0x8(%edi),%edx
80106ce4:	c1 ea 10             	shr    $0x10,%edx
80106ce7:	c1 e8 18             	shr    $0x18,%eax
80106cea:	88 93 9c 00 00 00    	mov    %dl,0x9c(%ebx)
80106cf0:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106cf6:	e8 f5 cc ff ff       	call   801039f0 <mycpu>
80106cfb:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106d02:	e8 e9 cc ff ff       	call   801039f0 <mycpu>
80106d07:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106d0d:	e8 de cc ff ff       	call   801039f0 <mycpu>
80106d12:	8b 56 08             	mov    0x8(%esi),%edx
80106d15:	81 c2 00 10 00 00    	add    $0x1000,%edx
80106d1b:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106d1e:	e8 cd cc ff ff       	call   801039f0 <mycpu>
80106d23:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
80106d29:	b8 28 00 00 00       	mov    $0x28,%eax
80106d2e:	0f 00 d8             	ltr    %ax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106d31:	8b 46 04             	mov    0x4(%esi),%eax
80106d34:	2d 00 00 00 80       	sub    $0x80000000,%eax
80106d39:	0f 22 d8             	mov    %eax,%cr3
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
  popcli();
}
80106d3c:	83 c4 2c             	add    $0x2c,%esp
80106d3f:	5b                   	pop    %ebx
80106d40:	5e                   	pop    %esi
80106d41:	5f                   	pop    %edi
80106d42:	5d                   	pop    %ebp
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
  popcli();
80106d43:	e9 38 d5 ff ff       	jmp    80104280 <popcli>
// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
80106d48:	c7 04 24 cd 77 10 80 	movl   $0x801077cd,(%esp)
80106d4f:	e8 5c 96 ff ff       	call   801003b0 <panic>
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
80106d54:	c7 04 24 f8 77 10 80 	movl   $0x801077f8,(%esp)
80106d5b:	e8 50 96 ff ff       	call   801003b0 <panic>
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
80106d60:	c7 04 24 e3 77 10 80 	movl   $0x801077e3,(%esp)
80106d67:	e8 44 96 ff ff       	call   801003b0 <panic>
80106d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106d70 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106d70:	55                   	push   %ebp
80106d71:	89 e5                	mov    %esp,%ebp
80106d73:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106d76:	e8 05 d3 ff ff       	call   80104080 <cpuid>
80106d7b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106d81:	05 a0 27 11 80       	add    $0x801127a0,%eax
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106d86:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106d8c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106d92:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106d96:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
80106d9a:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
80106d9e:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106da2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106da9:	ff ff 
80106dab:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106db2:	00 00 
80106db4:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106dbb:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
80106dc2:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
80106dc9:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106dd0:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80106dd7:	ff ff 
80106dd9:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80106de0:	00 00 
80106de2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80106de9:	c6 80 8d 00 00 00 fa 	movb   $0xfa,0x8d(%eax)
80106df0:	c6 80 8e 00 00 00 cf 	movb   $0xcf,0x8e(%eax)
80106df7:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106dfe:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80106e05:	ff ff 
80106e07:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80106e0e:	00 00 
80106e10:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80106e17:	c6 80 95 00 00 00 f2 	movb   $0xf2,0x95(%eax)
80106e1e:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
80106e25:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106e2c:	83 c0 70             	add    $0x70,%eax
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
80106e2f:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106e35:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106e39:	c1 e8 10             	shr    $0x10,%eax
80106e3c:	66 89 45 f6          	mov    %ax,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80106e40:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106e43:	0f 01 10             	lgdtl  (%eax)
}
80106e46:	c9                   	leave  
80106e47:	c3                   	ret    
