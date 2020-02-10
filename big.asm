
_big:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	57                   	push   %edi
   7:	56                   	push   %esi
   8:	53                   	push   %ebx
   9:	81 ec 24 02 00 00    	sub    $0x224,%esp
    char buf[512];
    int fd, i, sectors;
    
    fd = open("big.file", O_CREATE | O_WRONLY);
   f:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  16:	00 
  17:	c7 04 24 98 08 00 00 	movl   $0x898,(%esp)
  1e:	e8 f5 03 00 00       	call   418 <open>
    if(fd < 0){
  23:	85 c0                	test   %eax,%eax
main()
{
    char buf[512];
    int fd, i, sectors;
    
    fd = open("big.file", O_CREATE | O_WRONLY);
  25:	89 c7                	mov    %eax,%edi
    if(fd < 0){
  27:	0f 88 3b 01 00 00    	js     168 <main+0x168>
  2d:	8d 74 24 20          	lea    0x20(%esp),%esi
  31:	31 db                	xor    %ebx,%ebx
  33:	90                   	nop
  34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        exit();
    }
    
    sectors = 0;
    while(1){
        *(int*)buf = sectors;
  38:	89 1e                	mov    %ebx,(%esi)
        int cc = write(fd, buf, sizeof(buf));
  3a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  41:	00 
  42:	89 74 24 04          	mov    %esi,0x4(%esp)
  46:	89 3c 24             	mov    %edi,(%esp)
  49:	e8 aa 03 00 00       	call   3f8 <write>
        if(cc <= 0)
  4e:	85 c0                	test   %eax,%eax
  50:	7e 36                	jle    88 <main+0x88>
            break;
        sectors++;
  52:	83 c3 01             	add    $0x1,%ebx
        if (sectors % 100 == 0)
  55:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
  5a:	f7 eb                	imul   %ebx
  5c:	89 d8                	mov    %ebx,%eax
  5e:	c1 f8 1f             	sar    $0x1f,%eax
  61:	c1 fa 05             	sar    $0x5,%edx
  64:	29 c2                	sub    %eax,%edx
  66:	6b d2 64             	imul   $0x64,%edx,%edx
  69:	39 d3                	cmp    %edx,%ebx
  6b:	75 cb                	jne    38 <main+0x38>
            printf(2, ".");
  6d:	c7 44 24 04 a1 08 00 	movl   $0x8a1,0x4(%esp)
  74:	00 
  75:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  7c:	e8 9f 04 00 00       	call   520 <printf>
  81:	eb b5                	jmp    38 <main+0x38>
  83:	90                   	nop
  84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
    
    printf(1, "\nwrote %d sectors\n", sectors);
  88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8c:	c7 44 24 04 a3 08 00 	movl   $0x8a3,0x4(%esp)
  93:	00 
  94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9b:	e8 80 04 00 00       	call   520 <printf>
    
    close(fd);
  a0:	89 3c 24             	mov    %edi,(%esp)
  a3:	e8 58 03 00 00       	call   400 <close>
    fd = open("big.file", O_RDONLY);
  a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  af:	00 
  b0:	c7 04 24 98 08 00 00 	movl   $0x898,(%esp)
  b7:	e8 5c 03 00 00       	call   418 <open>
    if(fd < 0){
  bc:	85 c0                	test   %eax,%eax
    }
    
    printf(1, "\nwrote %d sectors\n", sectors);
    
    close(fd);
    fd = open("big.file", O_RDONLY);
  be:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(fd < 0){
  c2:	0f 88 c0 00 00 00    	js     188 <main+0x188>
        printf(2, "big: cannot re-open big.file for reading\n");
        exit();
  c8:	31 ff                	xor    %edi,%edi
    }
    for(i = 0; i < sectors; i++){
  ca:	85 db                	test   %ebx,%ebx
  cc:	75 17                	jne    e5 <main+0xe5>
  ce:	66 90                	xchg   %ax,%ax
  d0:	eb 4e                	jmp    120 <main+0x120>
  d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        int cc = read(fd, buf, sizeof(buf));
        if(cc <= 0){
            printf(2, "big: read error at sector %d\n", i);
            exit();
        }
        if(*(int*)buf != i){
  d8:	8b 06                	mov    (%esi),%eax
  da:	39 f8                	cmp    %edi,%eax
  dc:	75 62                	jne    140 <main+0x140>
    fd = open("big.file", O_RDONLY);
    if(fd < 0){
        printf(2, "big: cannot re-open big.file for reading\n");
        exit();
    }
    for(i = 0; i < sectors; i++){
  de:	83 c7 01             	add    $0x1,%edi
  e1:	39 df                	cmp    %ebx,%edi
  e3:	7d 3b                	jge    120 <main+0x120>
        int cc = read(fd, buf, sizeof(buf));
  e5:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  e9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  f0:	00 
  f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  f5:	89 04 24             	mov    %eax,(%esp)
  f8:	e8 f3 02 00 00       	call   3f0 <read>
        if(cc <= 0){
  fd:	85 c0                	test   %eax,%eax
  ff:	7f d7                	jg     d8 <main+0xd8>
            printf(2, "big: read error at sector %d\n", i);
 101:	89 7c 24 08          	mov    %edi,0x8(%esp)
 105:	c7 44 24 04 b6 08 00 	movl   $0x8b6,0x4(%esp)
 10c:	00 
 10d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 114:	e8 07 04 00 00       	call   520 <printf>
            exit();
 119:	e8 ba 02 00 00       	call   3d8 <exit>
 11e:	66 90                	xchg   %ax,%ax
                   *(int*)buf, i);
            exit();
        }
    }
    
    printf(1, "done; ok\n");
 120:	c7 44 24 04 d4 08 00 	movl   $0x8d4,0x4(%esp)
 127:	00 
 128:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12f:	e8 ec 03 00 00       	call   520 <printf>
    
    exit();
 134:	e8 9f 02 00 00       	call   3d8 <exit>
 139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        if(cc <= 0){
            printf(2, "big: read error at sector %d\n", i);
            exit();
        }
        if(*(int*)buf != i){
            printf(2, "big: read the wrong data (%d) for sector %d\n",
 140:	89 44 24 08          	mov    %eax,0x8(%esp)
 144:	89 7c 24 0c          	mov    %edi,0xc(%esp)
 148:	c7 44 24 04 34 09 00 	movl   $0x934,0x4(%esp)
 14f:	00 
 150:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 157:	e8 c4 03 00 00       	call   520 <printf>
                   *(int*)buf, i);
            exit();
 15c:	e8 77 02 00 00       	call   3d8 <exit>
 161:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    char buf[512];
    int fd, i, sectors;
    
    fd = open("big.file", O_CREATE | O_WRONLY);
    if(fd < 0){
        printf(2, "big: cannot open big.file for writing\n");
 168:	c7 44 24 04 e0 08 00 	movl   $0x8e0,0x4(%esp)
 16f:	00 
 170:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 177:	e8 a4 03 00 00       	call   520 <printf>
        exit();
 17c:	e8 57 02 00 00       	call   3d8 <exit>
 181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    printf(1, "\nwrote %d sectors\n", sectors);
    
    close(fd);
    fd = open("big.file", O_RDONLY);
    if(fd < 0){
        printf(2, "big: cannot re-open big.file for reading\n");
 188:	c7 44 24 04 08 09 00 	movl   $0x908,0x4(%esp)
 18f:	00 
 190:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 197:	e8 84 03 00 00       	call   520 <printf>
        exit();
 19c:	e8 37 02 00 00       	call   3d8 <exit>
 1a1:	90                   	nop
 1a2:	90                   	nop
 1a3:	90                   	nop
 1a4:	90                   	nop
 1a5:	90                   	nop
 1a6:	90                   	nop
 1a7:	90                   	nop
 1a8:	90                   	nop
 1a9:	90                   	nop
 1aa:	90                   	nop
 1ab:	90                   	nop
 1ac:	90                   	nop
 1ad:	90                   	nop
 1ae:	90                   	nop
 1af:	90                   	nop

000001b0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 1b0:	55                   	push   %ebp
 1b1:	31 d2                	xor    %edx,%edx
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	8b 45 08             	mov    0x8(%ebp),%eax
 1b8:	53                   	push   %ebx
 1b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 1c4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 1c7:	83 c2 01             	add    $0x1,%edx
 1ca:	84 c9                	test   %cl,%cl
 1cc:	75 f2                	jne    1c0 <strcpy+0x10>
    ;
  return os;
}
 1ce:	5b                   	pop    %ebx
 1cf:	5d                   	pop    %ebp
 1d0:	c3                   	ret    
 1d1:	eb 0d                	jmp    1e0 <strcmp>
 1d3:	90                   	nop
 1d4:	90                   	nop
 1d5:	90                   	nop
 1d6:	90                   	nop
 1d7:	90                   	nop
 1d8:	90                   	nop
 1d9:	90                   	nop
 1da:	90                   	nop
 1db:	90                   	nop
 1dc:	90                   	nop
 1dd:	90                   	nop
 1de:	90                   	nop
 1df:	90                   	nop

000001e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	53                   	push   %ebx
 1e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 1ea:	0f b6 01             	movzbl (%ecx),%eax
 1ed:	84 c0                	test   %al,%al
 1ef:	75 14                	jne    205 <strcmp+0x25>
 1f1:	eb 25                	jmp    218 <strcmp+0x38>
 1f3:	90                   	nop
 1f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 1f8:	83 c1 01             	add    $0x1,%ecx
 1fb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1fe:	0f b6 01             	movzbl (%ecx),%eax
 201:	84 c0                	test   %al,%al
 203:	74 13                	je     218 <strcmp+0x38>
 205:	0f b6 1a             	movzbl (%edx),%ebx
 208:	38 d8                	cmp    %bl,%al
 20a:	74 ec                	je     1f8 <strcmp+0x18>
 20c:	0f b6 db             	movzbl %bl,%ebx
 20f:	0f b6 c0             	movzbl %al,%eax
 212:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 214:	5b                   	pop    %ebx
 215:	5d                   	pop    %ebp
 216:	c3                   	ret    
 217:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 218:	0f b6 1a             	movzbl (%edx),%ebx
 21b:	31 c0                	xor    %eax,%eax
 21d:	0f b6 db             	movzbl %bl,%ebx
 220:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 222:	5b                   	pop    %ebx
 223:	5d                   	pop    %ebp
 224:	c3                   	ret    
 225:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000230 <strlen>:

uint
strlen(const char *s)
{
 230:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 231:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
 233:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 235:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
 237:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 23a:	80 39 00             	cmpb   $0x0,(%ecx)
 23d:	74 0c                	je     24b <strlen+0x1b>
 23f:	90                   	nop
 240:	83 c2 01             	add    $0x1,%edx
 243:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 247:	89 d0                	mov    %edx,%eax
 249:	75 f5                	jne    240 <strlen+0x10>
    ;
  return n;
}
 24b:	5d                   	pop    %ebp
 24c:	c3                   	ret    
 24d:	8d 76 00             	lea    0x0(%esi),%esi

00000250 <memset>:

void*
memset(void *dst, int c, uint n)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	8b 55 08             	mov    0x8(%ebp),%edx
 256:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 257:	8b 4d 10             	mov    0x10(%ebp),%ecx
 25a:	8b 45 0c             	mov    0xc(%ebp),%eax
 25d:	89 d7                	mov    %edx,%edi
 25f:	fc                   	cld    
 260:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 262:	89 d0                	mov    %edx,%eax
 264:	5f                   	pop    %edi
 265:	5d                   	pop    %ebp
 266:	c3                   	ret    
 267:	89 f6                	mov    %esi,%esi
 269:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000270 <strchr>:

char*
strchr(const char *s, char c)
{
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 27a:	0f b6 10             	movzbl (%eax),%edx
 27d:	84 d2                	test   %dl,%dl
 27f:	75 11                	jne    292 <strchr+0x22>
 281:	eb 15                	jmp    298 <strchr+0x28>
 283:	90                   	nop
 284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 288:	83 c0 01             	add    $0x1,%eax
 28b:	0f b6 10             	movzbl (%eax),%edx
 28e:	84 d2                	test   %dl,%dl
 290:	74 06                	je     298 <strchr+0x28>
    if(*s == c)
 292:	38 ca                	cmp    %cl,%dl
 294:	75 f2                	jne    288 <strchr+0x18>
      return (char*)s;
  return 0;
}
 296:	5d                   	pop    %ebp
 297:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 298:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 29a:	5d                   	pop    %ebp
 29b:	90                   	nop
 29c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2a0:	c3                   	ret    
 2a1:	eb 0d                	jmp    2b0 <atoi>
 2a3:	90                   	nop
 2a4:	90                   	nop
 2a5:	90                   	nop
 2a6:	90                   	nop
 2a7:	90                   	nop
 2a8:	90                   	nop
 2a9:	90                   	nop
 2aa:	90                   	nop
 2ab:	90                   	nop
 2ac:	90                   	nop
 2ad:	90                   	nop
 2ae:	90                   	nop
 2af:	90                   	nop

000002b0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 2b0:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b1:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 2b3:	89 e5                	mov    %esp,%ebp
 2b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2b8:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b9:	0f b6 11             	movzbl (%ecx),%edx
 2bc:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2bf:	80 fb 09             	cmp    $0x9,%bl
 2c2:	77 1c                	ja     2e0 <atoi+0x30>
 2c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 2c8:	0f be d2             	movsbl %dl,%edx
 2cb:	83 c1 01             	add    $0x1,%ecx
 2ce:	8d 04 80             	lea    (%eax,%eax,4),%eax
 2d1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d5:	0f b6 11             	movzbl (%ecx),%edx
 2d8:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2db:	80 fb 09             	cmp    $0x9,%bl
 2de:	76 e8                	jbe    2c8 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 2e0:	5b                   	pop    %ebx
 2e1:	5d                   	pop    %ebp
 2e2:	c3                   	ret    
 2e3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 2e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000002f0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f0:	55                   	push   %ebp
 2f1:	89 e5                	mov    %esp,%ebp
 2f3:	56                   	push   %esi
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	53                   	push   %ebx
 2f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
 2fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2fe:	85 db                	test   %ebx,%ebx
 300:	7e 14                	jle    316 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 302:	31 d2                	xor    %edx,%edx
 304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 308:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 30c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 30f:	83 c2 01             	add    $0x1,%edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 312:	39 da                	cmp    %ebx,%edx
 314:	75 f2                	jne    308 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 316:	5b                   	pop    %ebx
 317:	5e                   	pop    %esi
 318:	5d                   	pop    %ebp
 319:	c3                   	ret    
 31a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000320 <stat>:
  return buf;
}

int
stat(const char *n, struct stat *st)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 326:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(const char *n, struct stat *st)
{
 329:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 32c:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 32f:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 334:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 33b:	00 
 33c:	89 04 24             	mov    %eax,(%esp)
 33f:	e8 d4 00 00 00       	call   418 <open>
  if(fd < 0)
 344:	85 c0                	test   %eax,%eax
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 346:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 348:	78 19                	js     363 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	89 1c 24             	mov    %ebx,(%esp)
 350:	89 44 24 04          	mov    %eax,0x4(%esp)
 354:	e8 d7 00 00 00       	call   430 <fstat>
  close(fd);
 359:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 35c:	89 c6                	mov    %eax,%esi
  close(fd);
 35e:	e8 9d 00 00 00       	call   400 <close>
  return r;
}
 363:	89 f0                	mov    %esi,%eax
 365:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 368:	8b 75 fc             	mov    -0x4(%ebp),%esi
 36b:	89 ec                	mov    %ebp,%esp
 36d:	5d                   	pop    %ebp
 36e:	c3                   	ret    
 36f:	90                   	nop

00000370 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	57                   	push   %edi
 374:	56                   	push   %esi
 375:	31 f6                	xor    %esi,%esi
 377:	53                   	push   %ebx
 378:	83 ec 2c             	sub    $0x2c,%esp
 37b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 37e:	eb 06                	jmp    386 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 380:	3c 0a                	cmp    $0xa,%al
 382:	74 39                	je     3bd <gets+0x4d>
 384:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 386:	8d 5e 01             	lea    0x1(%esi),%ebx
 389:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 38c:	7d 31                	jge    3bf <gets+0x4f>
    cc = read(0, &c, 1);
 38e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 391:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 398:	00 
 399:	89 44 24 04          	mov    %eax,0x4(%esp)
 39d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3a4:	e8 47 00 00 00       	call   3f0 <read>
    if(cc < 1)
 3a9:	85 c0                	test   %eax,%eax
 3ab:	7e 12                	jle    3bf <gets+0x4f>
      break;
    buf[i++] = c;
 3ad:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 3b1:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 3b5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 3b9:	3c 0d                	cmp    $0xd,%al
 3bb:	75 c3                	jne    380 <gets+0x10>
 3bd:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 3bf:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 3c3:	89 f8                	mov    %edi,%eax
 3c5:	83 c4 2c             	add    $0x2c,%esp
 3c8:	5b                   	pop    %ebx
 3c9:	5e                   	pop    %esi
 3ca:	5f                   	pop    %edi
 3cb:	5d                   	pop    %ebp
 3cc:	c3                   	ret    
 3cd:	90                   	nop
 3ce:	90                   	nop
 3cf:	90                   	nop

000003d0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3d0:	b8 01 00 00 00       	mov    $0x1,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <exit>:
SYSCALL(exit)
 3d8:	b8 02 00 00 00       	mov    $0x2,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <wait>:
SYSCALL(wait)
 3e0:	b8 03 00 00 00       	mov    $0x3,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <pipe>:
SYSCALL(pipe)
 3e8:	b8 04 00 00 00       	mov    $0x4,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <read>:
SYSCALL(read)
 3f0:	b8 05 00 00 00       	mov    $0x5,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <write>:
SYSCALL(write)
 3f8:	b8 10 00 00 00       	mov    $0x10,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <close>:
SYSCALL(close)
 400:	b8 15 00 00 00       	mov    $0x15,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <kill>:
SYSCALL(kill)
 408:	b8 06 00 00 00       	mov    $0x6,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <exec>:
SYSCALL(exec)
 410:	b8 07 00 00 00       	mov    $0x7,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <open>:
SYSCALL(open)
 418:	b8 0f 00 00 00       	mov    $0xf,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <mknod>:
SYSCALL(mknod)
 420:	b8 11 00 00 00       	mov    $0x11,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <unlink>:
SYSCALL(unlink)
 428:	b8 12 00 00 00       	mov    $0x12,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <fstat>:
SYSCALL(fstat)
 430:	b8 08 00 00 00       	mov    $0x8,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <link>:
SYSCALL(link)
 438:	b8 13 00 00 00       	mov    $0x13,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <mkdir>:
SYSCALL(mkdir)
 440:	b8 14 00 00 00       	mov    $0x14,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <chdir>:
SYSCALL(chdir)
 448:	b8 09 00 00 00       	mov    $0x9,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <dup>:
SYSCALL(dup)
 450:	b8 0a 00 00 00       	mov    $0xa,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <getpid>:
SYSCALL(getpid)
 458:	b8 0b 00 00 00       	mov    $0xb,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <sbrk>:
SYSCALL(sbrk)
 460:	b8 0c 00 00 00       	mov    $0xc,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <sleep>:
SYSCALL(sleep)
 468:	b8 0d 00 00 00       	mov    $0xd,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <uptime>:
SYSCALL(uptime)
 470:	b8 0e 00 00 00       	mov    $0xe,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    
 478:	90                   	nop
 479:	90                   	nop
 47a:	90                   	nop
 47b:	90                   	nop
 47c:	90                   	nop
 47d:	90                   	nop
 47e:	90                   	nop
 47f:	90                   	nop

00000480 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	57                   	push   %edi
 484:	89 cf                	mov    %ecx,%edi
 486:	56                   	push   %esi
 487:	89 c6                	mov    %eax,%esi
 489:	53                   	push   %ebx
 48a:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 48d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 490:	85 c9                	test   %ecx,%ecx
 492:	74 04                	je     498 <printint+0x18>
 494:	85 d2                	test   %edx,%edx
 496:	78 70                	js     508 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 498:	89 d0                	mov    %edx,%eax
 49a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 4a1:	31 c9                	xor    %ecx,%ecx
 4a3:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 4a6:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 4a8:	31 d2                	xor    %edx,%edx
 4aa:	f7 f7                	div    %edi
 4ac:	0f b6 92 6b 09 00 00 	movzbl 0x96b(%edx),%edx
 4b3:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 4b6:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 4b9:	85 c0                	test   %eax,%eax
 4bb:	75 eb                	jne    4a8 <printint+0x28>
  if(neg)
 4bd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 4c0:	85 c0                	test   %eax,%eax
 4c2:	74 08                	je     4cc <printint+0x4c>
    buf[i++] = '-';
 4c4:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 4c9:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 4cc:	8d 79 ff             	lea    -0x1(%ecx),%edi
 4cf:	01 fb                	add    %edi,%ebx
 4d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 4d8:	0f b6 03             	movzbl (%ebx),%eax
 4db:	83 ef 01             	sub    $0x1,%edi
 4de:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4e8:	00 
 4e9:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4ec:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 4ef:	8d 45 e7             	lea    -0x19(%ebp),%eax
 4f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f6:	e8 fd fe ff ff       	call   3f8 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4fb:	83 ff ff             	cmp    $0xffffffff,%edi
 4fe:	75 d8                	jne    4d8 <printint+0x58>
    putc(fd, buf[i]);
}
 500:	83 c4 4c             	add    $0x4c,%esp
 503:	5b                   	pop    %ebx
 504:	5e                   	pop    %esi
 505:	5f                   	pop    %edi
 506:	5d                   	pop    %ebp
 507:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 508:	89 d0                	mov    %edx,%eax
 50a:	f7 d8                	neg    %eax
 50c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 513:	eb 8c                	jmp    4a1 <printint+0x21>
 515:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 519:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000520 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	57                   	push   %edi
 524:	56                   	push   %esi
 525:	53                   	push   %ebx
 526:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 529:	8b 45 0c             	mov    0xc(%ebp),%eax
 52c:	0f b6 10             	movzbl (%eax),%edx
 52f:	84 d2                	test   %dl,%dl
 531:	0f 84 c9 00 00 00    	je     600 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 537:	8d 4d 10             	lea    0x10(%ebp),%ecx
 53a:	31 ff                	xor    %edi,%edi
 53c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 53f:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 541:	8d 75 e7             	lea    -0x19(%ebp),%esi
 544:	eb 1e                	jmp    564 <printf+0x44>
 546:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 548:	83 fa 25             	cmp    $0x25,%edx
 54b:	0f 85 b7 00 00 00    	jne    608 <printf+0xe8>
 551:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 555:	83 c3 01             	add    $0x1,%ebx
 558:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 55c:	84 d2                	test   %dl,%dl
 55e:	0f 84 9c 00 00 00    	je     600 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 564:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 566:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 569:	74 dd                	je     548 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 56b:	83 ff 25             	cmp    $0x25,%edi
 56e:	75 e5                	jne    555 <printf+0x35>
      if(c == 'd'){
 570:	83 fa 64             	cmp    $0x64,%edx
 573:	0f 84 47 01 00 00    	je     6c0 <printf+0x1a0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 579:	83 fa 70             	cmp    $0x70,%edx
 57c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 580:	0f 84 aa 00 00 00    	je     630 <printf+0x110>
 586:	83 fa 78             	cmp    $0x78,%edx
 589:	0f 84 a1 00 00 00    	je     630 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 58f:	83 fa 73             	cmp    $0x73,%edx
 592:	0f 84 c0 00 00 00    	je     658 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 598:	83 fa 63             	cmp    $0x63,%edx
 59b:	90                   	nop
 59c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 5a0:	0f 84 42 01 00 00    	je     6e8 <printf+0x1c8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 5a6:	83 fa 25             	cmp    $0x25,%edx
 5a9:	0f 84 01 01 00 00    	je     6b0 <printf+0x190>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5af:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5b2:	89 55 cc             	mov    %edx,-0x34(%ebp)
 5b5:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 5b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5c0:	00 
 5c1:	89 74 24 04          	mov    %esi,0x4(%esp)
 5c5:	89 0c 24             	mov    %ecx,(%esp)
 5c8:	e8 2b fe ff ff       	call   3f8 <write>
 5cd:	8b 55 cc             	mov    -0x34(%ebp),%edx
 5d0:	88 55 e7             	mov    %dl,-0x19(%ebp)
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5d6:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 5d9:	31 ff                	xor    %edi,%edi
 5db:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5e2:	00 
 5e3:	89 74 24 04          	mov    %esi,0x4(%esp)
 5e7:	89 04 24             	mov    %eax,(%esp)
 5ea:	e8 09 fe ff ff       	call   3f8 <write>
 5ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5f2:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 5f6:	84 d2                	test   %dl,%dl
 5f8:	0f 85 66 ff ff ff    	jne    564 <printf+0x44>
 5fe:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 600:	83 c4 3c             	add    $0x3c,%esp
 603:	5b                   	pop    %ebx
 604:	5e                   	pop    %esi
 605:	5f                   	pop    %edi
 606:	5d                   	pop    %ebp
 607:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 608:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 60b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 60e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 615:	00 
 616:	89 74 24 04          	mov    %esi,0x4(%esp)
 61a:	89 04 24             	mov    %eax,(%esp)
 61d:	e8 d6 fd ff ff       	call   3f8 <write>
 622:	8b 45 0c             	mov    0xc(%ebp),%eax
 625:	e9 2b ff ff ff       	jmp    555 <printf+0x35>
 62a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 630:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 633:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 638:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 63a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 641:	8b 10                	mov    (%eax),%edx
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	e8 35 fe ff ff       	call   480 <printint>
 64b:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 64e:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 652:	e9 fe fe ff ff       	jmp    555 <printf+0x35>
 657:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 658:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        ap++;
        if(s == 0)
 65b:	b9 64 09 00 00       	mov    $0x964,%ecx
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
 660:	8b 3a                	mov    (%edx),%edi
        ap++;
 662:	83 c2 04             	add    $0x4,%edx
 665:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 668:	85 ff                	test   %edi,%edi
 66a:	0f 44 f9             	cmove  %ecx,%edi
          s = "(null)";
        while(*s != 0){
 66d:	0f b6 17             	movzbl (%edi),%edx
 670:	84 d2                	test   %dl,%dl
 672:	74 33                	je     6a7 <printf+0x187>
 674:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 677:	8b 5d 08             	mov    0x8(%ebp),%ebx
 67a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          putc(fd, *s);
          s++;
 680:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 683:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 686:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 68d:	00 
 68e:	89 74 24 04          	mov    %esi,0x4(%esp)
 692:	89 1c 24             	mov    %ebx,(%esp)
 695:	e8 5e fd ff ff       	call   3f8 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 69a:	0f b6 17             	movzbl (%edi),%edx
 69d:	84 d2                	test   %dl,%dl
 69f:	75 df                	jne    680 <printf+0x160>
 6a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 6a4:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6a7:	31 ff                	xor    %edi,%edi
 6a9:	e9 a7 fe ff ff       	jmp    555 <printf+0x35>
 6ae:	66 90                	xchg   %ax,%ax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 6b0:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 6b4:	e9 1a ff ff ff       	jmp    5d3 <printf+0xb3>
 6b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 6c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 6c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 6c8:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 6cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 6d2:	8b 10                	mov    (%eax),%edx
 6d4:	8b 45 08             	mov    0x8(%ebp),%eax
 6d7:	e8 a4 fd ff ff       	call   480 <printint>
 6dc:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 6df:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 6e3:	e9 6d fe ff ff       	jmp    555 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        putc(fd, *ap);
        ap++;
 6eb:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6f0:	8b 02                	mov    (%edx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6f2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6f9:	00 
 6fa:	89 74 24 04          	mov    %esi,0x4(%esp)
 6fe:	89 0c 24             	mov    %ecx,(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 701:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 704:	e8 ef fc ff ff       	call   3f8 <write>
 709:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 70c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 710:	e9 40 fe ff ff       	jmp    555 <printf+0x35>
 715:	90                   	nop
 716:	90                   	nop
 717:	90                   	nop
 718:	90                   	nop
 719:	90                   	nop
 71a:	90                   	nop
 71b:	90                   	nop
 71c:	90                   	nop
 71d:	90                   	nop
 71e:	90                   	nop
 71f:	90                   	nop

00000720 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 720:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 721:	a1 84 09 00 00       	mov    0x984,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 726:	89 e5                	mov    %esp,%ebp
 728:	57                   	push   %edi
 729:	56                   	push   %esi
 72a:	53                   	push   %ebx
 72b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 731:	39 c8                	cmp    %ecx,%eax
 733:	73 1d                	jae    752 <free+0x32>
 735:	8d 76 00             	lea    0x0(%esi),%esi
 738:	8b 10                	mov    (%eax),%edx
 73a:	39 d1                	cmp    %edx,%ecx
 73c:	72 1a                	jb     758 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73e:	39 d0                	cmp    %edx,%eax
 740:	72 08                	jb     74a <free+0x2a>
 742:	39 c8                	cmp    %ecx,%eax
 744:	72 12                	jb     758 <free+0x38>
 746:	39 d1                	cmp    %edx,%ecx
 748:	72 0e                	jb     758 <free+0x38>
 74a:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74c:	39 c8                	cmp    %ecx,%eax
 74e:	66 90                	xchg   %ax,%ax
 750:	72 e6                	jb     738 <free+0x18>
 752:	8b 10                	mov    (%eax),%edx
 754:	eb e8                	jmp    73e <free+0x1e>
 756:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 758:	8b 71 04             	mov    0x4(%ecx),%esi
 75b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 75e:	39 d7                	cmp    %edx,%edi
 760:	74 19                	je     77b <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 762:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 765:	8b 50 04             	mov    0x4(%eax),%edx
 768:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 76b:	39 ce                	cmp    %ecx,%esi
 76d:	74 23                	je     792 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 76f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 771:	a3 84 09 00 00       	mov    %eax,0x984
}
 776:	5b                   	pop    %ebx
 777:	5e                   	pop    %esi
 778:	5f                   	pop    %edi
 779:	5d                   	pop    %ebp
 77a:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77b:	03 72 04             	add    0x4(%edx),%esi
 77e:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 781:	8b 10                	mov    (%eax),%edx
 783:	8b 12                	mov    (%edx),%edx
 785:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 788:	8b 50 04             	mov    0x4(%eax),%edx
 78b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 78e:	39 ce                	cmp    %ecx,%esi
 790:	75 dd                	jne    76f <free+0x4f>
    p->s.size += bp->s.size;
 792:	03 51 04             	add    0x4(%ecx),%edx
 795:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 798:	8b 53 f8             	mov    -0x8(%ebx),%edx
 79b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 79d:	a3 84 09 00 00       	mov    %eax,0x984
}
 7a2:	5b                   	pop    %ebx
 7a3:	5e                   	pop    %esi
 7a4:	5f                   	pop    %edi
 7a5:	5d                   	pop    %ebp
 7a6:	c3                   	ret    
 7a7:	89 f6                	mov    %esi,%esi
 7a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000007b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b0:	55                   	push   %ebp
 7b1:	89 e5                	mov    %esp,%ebp
 7b3:	57                   	push   %edi
 7b4:	56                   	push   %esi
 7b5:	53                   	push   %ebx
 7b6:	83 ec 2c             	sub    $0x2c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 7bc:	8b 0d 84 09 00 00    	mov    0x984,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c2:	83 c3 07             	add    $0x7,%ebx
 7c5:	c1 eb 03             	shr    $0x3,%ebx
 7c8:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 7cb:	85 c9                	test   %ecx,%ecx
 7cd:	0f 84 9b 00 00 00    	je     86e <malloc+0xbe>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d3:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 7d5:	8b 50 04             	mov    0x4(%eax),%edx
 7d8:	39 d3                	cmp    %edx,%ebx
 7da:	76 27                	jbe    803 <malloc+0x53>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 7dc:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 7e3:	be 00 80 00 00       	mov    $0x8000,%esi
 7e8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 7eb:	90                   	nop
 7ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f0:	3b 05 84 09 00 00    	cmp    0x984,%eax
 7f6:	74 30                	je     828 <malloc+0x78>
 7f8:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fa:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 7fc:	8b 50 04             	mov    0x4(%eax),%edx
 7ff:	39 d3                	cmp    %edx,%ebx
 801:	77 ed                	ja     7f0 <malloc+0x40>
      if(p->s.size == nunits)
 803:	39 d3                	cmp    %edx,%ebx
 805:	74 61                	je     868 <malloc+0xb8>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 807:	29 da                	sub    %ebx,%edx
 809:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 80c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 80f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 812:	89 0d 84 09 00 00    	mov    %ecx,0x984
      return (void*)(p + 1);
 818:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 81b:	83 c4 2c             	add    $0x2c,%esp
 81e:	5b                   	pop    %ebx
 81f:	5e                   	pop    %esi
 820:	5f                   	pop    %edi
 821:	5d                   	pop    %ebp
 822:	c3                   	ret    
 823:	90                   	nop
 824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 82b:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
 831:	bf 00 10 00 00       	mov    $0x1000,%edi
 836:	0f 43 fb             	cmovae %ebx,%edi
 839:	0f 42 c6             	cmovb  %esi,%eax
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 83c:	89 04 24             	mov    %eax,(%esp)
 83f:	e8 1c fc ff ff       	call   460 <sbrk>
  if(p == (char*)-1)
 844:	83 f8 ff             	cmp    $0xffffffff,%eax
 847:	74 18                	je     861 <malloc+0xb1>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 849:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 84c:	83 c0 08             	add    $0x8,%eax
 84f:	89 04 24             	mov    %eax,(%esp)
 852:	e8 c9 fe ff ff       	call   720 <free>
  return freep;
 857:	8b 0d 84 09 00 00    	mov    0x984,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 85d:	85 c9                	test   %ecx,%ecx
 85f:	75 99                	jne    7fa <malloc+0x4a>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 861:	31 c0                	xor    %eax,%eax
 863:	eb b6                	jmp    81b <malloc+0x6b>
 865:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 868:	8b 10                	mov    (%eax),%edx
 86a:	89 11                	mov    %edx,(%ecx)
 86c:	eb a4                	jmp    812 <malloc+0x62>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 86e:	c7 05 84 09 00 00 7c 	movl   $0x97c,0x984
 875:	09 00 00 
    base.s.size = 0;
 878:	b9 7c 09 00 00       	mov    $0x97c,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 87d:	c7 05 7c 09 00 00 7c 	movl   $0x97c,0x97c
 884:	09 00 00 
    base.s.size = 0;
 887:	c7 05 80 09 00 00 00 	movl   $0x0,0x980
 88e:	00 00 00 
 891:	e9 3d ff ff ff       	jmp    7d3 <malloc+0x23>
