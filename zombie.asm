
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 42 02 00 00       	call   250 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 ca 02 00 00       	call   2e8 <sleep>
  exit();
  1e:	e8 35 02 00 00       	call   258 <exit>
  23:	90                   	nop
  24:	90                   	nop
  25:	90                   	nop
  26:	90                   	nop
  27:	90                   	nop
  28:	90                   	nop
  29:	90                   	nop
  2a:	90                   	nop
  2b:	90                   	nop
  2c:	90                   	nop
  2d:	90                   	nop
  2e:	90                   	nop
  2f:	90                   	nop

00000030 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  30:	55                   	push   %ebp
  31:	31 d2                	xor    %edx,%edx
  33:	89 e5                	mov    %esp,%ebp
  35:	8b 45 08             	mov    0x8(%ebp),%eax
  38:	53                   	push   %ebx
  39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  40:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  44:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  47:	83 c2 01             	add    $0x1,%edx
  4a:	84 c9                	test   %cl,%cl
  4c:	75 f2                	jne    40 <strcpy+0x10>
    ;
  return os;
}
  4e:	5b                   	pop    %ebx
  4f:	5d                   	pop    %ebp
  50:	c3                   	ret    
  51:	eb 0d                	jmp    60 <strcmp>
  53:	90                   	nop
  54:	90                   	nop
  55:	90                   	nop
  56:	90                   	nop
  57:	90                   	nop
  58:	90                   	nop
  59:	90                   	nop
  5a:	90                   	nop
  5b:	90                   	nop
  5c:	90                   	nop
  5d:	90                   	nop
  5e:	90                   	nop
  5f:	90                   	nop

00000060 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  60:	55                   	push   %ebp
  61:	89 e5                	mov    %esp,%ebp
  63:	53                   	push   %ebx
  64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  67:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  6a:	0f b6 01             	movzbl (%ecx),%eax
  6d:	84 c0                	test   %al,%al
  6f:	75 14                	jne    85 <strcmp+0x25>
  71:	eb 25                	jmp    98 <strcmp+0x38>
  73:	90                   	nop
  74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
  78:	83 c1 01             	add    $0x1,%ecx
  7b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  7e:	0f b6 01             	movzbl (%ecx),%eax
  81:	84 c0                	test   %al,%al
  83:	74 13                	je     98 <strcmp+0x38>
  85:	0f b6 1a             	movzbl (%edx),%ebx
  88:	38 d8                	cmp    %bl,%al
  8a:	74 ec                	je     78 <strcmp+0x18>
  8c:	0f b6 db             	movzbl %bl,%ebx
  8f:	0f b6 c0             	movzbl %al,%eax
  92:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
  94:	5b                   	pop    %ebx
  95:	5d                   	pop    %ebp
  96:	c3                   	ret    
  97:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  98:	0f b6 1a             	movzbl (%edx),%ebx
  9b:	31 c0                	xor    %eax,%eax
  9d:	0f b6 db             	movzbl %bl,%ebx
  a0:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
  a2:	5b                   	pop    %ebx
  a3:	5d                   	pop    %ebp
  a4:	c3                   	ret    
  a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000000b0 <strlen>:

uint
strlen(const char *s)
{
  b0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
  b1:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
  b3:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
  b5:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
  b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  ba:	80 39 00             	cmpb   $0x0,(%ecx)
  bd:	74 0c                	je     cb <strlen+0x1b>
  bf:	90                   	nop
  c0:	83 c2 01             	add    $0x1,%edx
  c3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  c7:	89 d0                	mov    %edx,%eax
  c9:	75 f5                	jne    c0 <strlen+0x10>
    ;
  return n;
}
  cb:	5d                   	pop    %ebp
  cc:	c3                   	ret    
  cd:	8d 76 00             	lea    0x0(%esi),%esi

000000d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
  d3:	8b 55 08             	mov    0x8(%ebp),%edx
  d6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  da:	8b 45 0c             	mov    0xc(%ebp),%eax
  dd:	89 d7                	mov    %edx,%edi
  df:	fc                   	cld    
  e0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  e2:	89 d0                	mov    %edx,%eax
  e4:	5f                   	pop    %edi
  e5:	5d                   	pop    %ebp
  e6:	c3                   	ret    
  e7:	89 f6                	mov    %esi,%esi
  e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000000f0 <strchr>:

char*
strchr(const char *s, char c)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	8b 45 08             	mov    0x8(%ebp),%eax
  f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  fa:	0f b6 10             	movzbl (%eax),%edx
  fd:	84 d2                	test   %dl,%dl
  ff:	75 11                	jne    112 <strchr+0x22>
 101:	eb 15                	jmp    118 <strchr+0x28>
 103:	90                   	nop
 104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 108:	83 c0 01             	add    $0x1,%eax
 10b:	0f b6 10             	movzbl (%eax),%edx
 10e:	84 d2                	test   %dl,%dl
 110:	74 06                	je     118 <strchr+0x28>
    if(*s == c)
 112:	38 ca                	cmp    %cl,%dl
 114:	75 f2                	jne    108 <strchr+0x18>
      return (char*)s;
  return 0;
}
 116:	5d                   	pop    %ebp
 117:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 118:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 11a:	5d                   	pop    %ebp
 11b:	90                   	nop
 11c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 120:	c3                   	ret    
 121:	eb 0d                	jmp    130 <atoi>
 123:	90                   	nop
 124:	90                   	nop
 125:	90                   	nop
 126:	90                   	nop
 127:	90                   	nop
 128:	90                   	nop
 129:	90                   	nop
 12a:	90                   	nop
 12b:	90                   	nop
 12c:	90                   	nop
 12d:	90                   	nop
 12e:	90                   	nop
 12f:	90                   	nop

00000130 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 130:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 131:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 133:	89 e5                	mov    %esp,%ebp
 135:	8b 4d 08             	mov    0x8(%ebp),%ecx
 138:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 139:	0f b6 11             	movzbl (%ecx),%edx
 13c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 13f:	80 fb 09             	cmp    $0x9,%bl
 142:	77 1c                	ja     160 <atoi+0x30>
 144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 148:	0f be d2             	movsbl %dl,%edx
 14b:	83 c1 01             	add    $0x1,%ecx
 14e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 151:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 155:	0f b6 11             	movzbl (%ecx),%edx
 158:	8d 5a d0             	lea    -0x30(%edx),%ebx
 15b:	80 fb 09             	cmp    $0x9,%bl
 15e:	76 e8                	jbe    148 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 160:	5b                   	pop    %ebx
 161:	5d                   	pop    %ebp
 162:	c3                   	ret    
 163:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000170 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	56                   	push   %esi
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	53                   	push   %ebx
 178:	8b 5d 10             	mov    0x10(%ebp),%ebx
 17b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 17e:	85 db                	test   %ebx,%ebx
 180:	7e 14                	jle    196 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 182:	31 d2                	xor    %edx,%edx
 184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 188:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 18c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 18f:	83 c2 01             	add    $0x1,%edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 192:	39 da                	cmp    %ebx,%edx
 194:	75 f2                	jne    188 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 196:	5b                   	pop    %ebx
 197:	5e                   	pop    %esi
 198:	5d                   	pop    %ebp
 199:	c3                   	ret    
 19a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

000001a0 <stat>:
  return buf;
}

int
stat(const char *n, struct stat *st)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a6:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(const char *n, struct stat *st)
{
 1a9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 1ac:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 1af:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1bb:	00 
 1bc:	89 04 24             	mov    %eax,(%esp)
 1bf:	e8 d4 00 00 00       	call   298 <open>
  if(fd < 0)
 1c4:	85 c0                	test   %eax,%eax
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c6:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 1c8:	78 19                	js     1e3 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 1ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cd:	89 1c 24             	mov    %ebx,(%esp)
 1d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d4:	e8 d7 00 00 00       	call   2b0 <fstat>
  close(fd);
 1d9:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 1dc:	89 c6                	mov    %eax,%esi
  close(fd);
 1de:	e8 9d 00 00 00       	call   280 <close>
  return r;
}
 1e3:	89 f0                	mov    %esi,%eax
 1e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 1e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
 1eb:	89 ec                	mov    %ebp,%esp
 1ed:	5d                   	pop    %ebp
 1ee:	c3                   	ret    
 1ef:	90                   	nop

000001f0 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	57                   	push   %edi
 1f4:	56                   	push   %esi
 1f5:	31 f6                	xor    %esi,%esi
 1f7:	53                   	push   %ebx
 1f8:	83 ec 2c             	sub    $0x2c,%esp
 1fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fe:	eb 06                	jmp    206 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 200:	3c 0a                	cmp    $0xa,%al
 202:	74 39                	je     23d <gets+0x4d>
 204:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 206:	8d 5e 01             	lea    0x1(%esi),%ebx
 209:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 20c:	7d 31                	jge    23f <gets+0x4f>
    cc = read(0, &c, 1);
 20e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 211:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 218:	00 
 219:	89 44 24 04          	mov    %eax,0x4(%esp)
 21d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 224:	e8 47 00 00 00       	call   270 <read>
    if(cc < 1)
 229:	85 c0                	test   %eax,%eax
 22b:	7e 12                	jle    23f <gets+0x4f>
      break;
    buf[i++] = c;
 22d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 231:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 235:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 239:	3c 0d                	cmp    $0xd,%al
 23b:	75 c3                	jne    200 <gets+0x10>
 23d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 23f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 243:	89 f8                	mov    %edi,%eax
 245:	83 c4 2c             	add    $0x2c,%esp
 248:	5b                   	pop    %ebx
 249:	5e                   	pop    %esi
 24a:	5f                   	pop    %edi
 24b:	5d                   	pop    %ebp
 24c:	c3                   	ret    
 24d:	90                   	nop
 24e:	90                   	nop
 24f:	90                   	nop

00000250 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 250:	b8 01 00 00 00       	mov    $0x1,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <exit>:
SYSCALL(exit)
 258:	b8 02 00 00 00       	mov    $0x2,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <wait>:
SYSCALL(wait)
 260:	b8 03 00 00 00       	mov    $0x3,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <pipe>:
SYSCALL(pipe)
 268:	b8 04 00 00 00       	mov    $0x4,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <read>:
SYSCALL(read)
 270:	b8 05 00 00 00       	mov    $0x5,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <write>:
SYSCALL(write)
 278:	b8 10 00 00 00       	mov    $0x10,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <close>:
SYSCALL(close)
 280:	b8 15 00 00 00       	mov    $0x15,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <kill>:
SYSCALL(kill)
 288:	b8 06 00 00 00       	mov    $0x6,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <exec>:
SYSCALL(exec)
 290:	b8 07 00 00 00       	mov    $0x7,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <open>:
SYSCALL(open)
 298:	b8 0f 00 00 00       	mov    $0xf,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <mknod>:
SYSCALL(mknod)
 2a0:	b8 11 00 00 00       	mov    $0x11,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <unlink>:
SYSCALL(unlink)
 2a8:	b8 12 00 00 00       	mov    $0x12,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <fstat>:
SYSCALL(fstat)
 2b0:	b8 08 00 00 00       	mov    $0x8,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <link>:
SYSCALL(link)
 2b8:	b8 13 00 00 00       	mov    $0x13,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <mkdir>:
SYSCALL(mkdir)
 2c0:	b8 14 00 00 00       	mov    $0x14,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <chdir>:
SYSCALL(chdir)
 2c8:	b8 09 00 00 00       	mov    $0x9,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <dup>:
SYSCALL(dup)
 2d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <getpid>:
SYSCALL(getpid)
 2d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <sbrk>:
SYSCALL(sbrk)
 2e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <sleep>:
SYSCALL(sleep)
 2e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <uptime>:
SYSCALL(uptime)
 2f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    
 2f8:	90                   	nop
 2f9:	90                   	nop
 2fa:	90                   	nop
 2fb:	90                   	nop
 2fc:	90                   	nop
 2fd:	90                   	nop
 2fe:	90                   	nop
 2ff:	90                   	nop

00000300 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	57                   	push   %edi
 304:	89 cf                	mov    %ecx,%edi
 306:	56                   	push   %esi
 307:	89 c6                	mov    %eax,%esi
 309:	53                   	push   %ebx
 30a:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 30d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 310:	85 c9                	test   %ecx,%ecx
 312:	74 04                	je     318 <printint+0x18>
 314:	85 d2                	test   %edx,%edx
 316:	78 70                	js     388 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 318:	89 d0                	mov    %edx,%eax
 31a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 321:	31 c9                	xor    %ecx,%ecx
 323:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 326:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 328:	31 d2                	xor    %edx,%edx
 32a:	f7 f7                	div    %edi
 32c:	0f b6 92 1d 07 00 00 	movzbl 0x71d(%edx),%edx
 333:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 336:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 339:	85 c0                	test   %eax,%eax
 33b:	75 eb                	jne    328 <printint+0x28>
  if(neg)
 33d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 340:	85 c0                	test   %eax,%eax
 342:	74 08                	je     34c <printint+0x4c>
    buf[i++] = '-';
 344:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 349:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 34c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 34f:	01 fb                	add    %edi,%ebx
 351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 358:	0f b6 03             	movzbl (%ebx),%eax
 35b:	83 ef 01             	sub    $0x1,%edi
 35e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 361:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 368:	00 
 369:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 36c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 36f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 372:	89 44 24 04          	mov    %eax,0x4(%esp)
 376:	e8 fd fe ff ff       	call   278 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 37b:	83 ff ff             	cmp    $0xffffffff,%edi
 37e:	75 d8                	jne    358 <printint+0x58>
    putc(fd, buf[i]);
}
 380:	83 c4 4c             	add    $0x4c,%esp
 383:	5b                   	pop    %ebx
 384:	5e                   	pop    %esi
 385:	5f                   	pop    %edi
 386:	5d                   	pop    %ebp
 387:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 388:	89 d0                	mov    %edx,%eax
 38a:	f7 d8                	neg    %eax
 38c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 393:	eb 8c                	jmp    321 <printint+0x21>
 395:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 399:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003a0 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	57                   	push   %edi
 3a4:	56                   	push   %esi
 3a5:	53                   	push   %ebx
 3a6:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ac:	0f b6 10             	movzbl (%eax),%edx
 3af:	84 d2                	test   %dl,%dl
 3b1:	0f 84 c9 00 00 00    	je     480 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3b7:	8d 4d 10             	lea    0x10(%ebp),%ecx
 3ba:	31 ff                	xor    %edi,%edi
 3bc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 3bf:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 3c1:	8d 75 e7             	lea    -0x19(%ebp),%esi
 3c4:	eb 1e                	jmp    3e4 <printf+0x44>
 3c6:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 3c8:	83 fa 25             	cmp    $0x25,%edx
 3cb:	0f 85 b7 00 00 00    	jne    488 <printf+0xe8>
 3d1:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3d5:	83 c3 01             	add    $0x1,%ebx
 3d8:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 3dc:	84 d2                	test   %dl,%dl
 3de:	0f 84 9c 00 00 00    	je     480 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 3e4:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 3e6:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 3e9:	74 dd                	je     3c8 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3eb:	83 ff 25             	cmp    $0x25,%edi
 3ee:	75 e5                	jne    3d5 <printf+0x35>
      if(c == 'd'){
 3f0:	83 fa 64             	cmp    $0x64,%edx
 3f3:	0f 84 47 01 00 00    	je     540 <printf+0x1a0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3f9:	83 fa 70             	cmp    $0x70,%edx
 3fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 400:	0f 84 aa 00 00 00    	je     4b0 <printf+0x110>
 406:	83 fa 78             	cmp    $0x78,%edx
 409:	0f 84 a1 00 00 00    	je     4b0 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 40f:	83 fa 73             	cmp    $0x73,%edx
 412:	0f 84 c0 00 00 00    	je     4d8 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 418:	83 fa 63             	cmp    $0x63,%edx
 41b:	90                   	nop
 41c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 420:	0f 84 42 01 00 00    	je     568 <printf+0x1c8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 426:	83 fa 25             	cmp    $0x25,%edx
 429:	0f 84 01 01 00 00    	je     530 <printf+0x190>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 42f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 432:	89 55 cc             	mov    %edx,-0x34(%ebp)
 435:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 439:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 440:	00 
 441:	89 74 24 04          	mov    %esi,0x4(%esp)
 445:	89 0c 24             	mov    %ecx,(%esp)
 448:	e8 2b fe ff ff       	call   278 <write>
 44d:	8b 55 cc             	mov    -0x34(%ebp),%edx
 450:	88 55 e7             	mov    %dl,-0x19(%ebp)
 453:	8b 45 08             	mov    0x8(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 456:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 459:	31 ff                	xor    %edi,%edi
 45b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 462:	00 
 463:	89 74 24 04          	mov    %esi,0x4(%esp)
 467:	89 04 24             	mov    %eax,(%esp)
 46a:	e8 09 fe ff ff       	call   278 <write>
 46f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 472:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 476:	84 d2                	test   %dl,%dl
 478:	0f 85 66 ff ff ff    	jne    3e4 <printf+0x44>
 47e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 480:	83 c4 3c             	add    $0x3c,%esp
 483:	5b                   	pop    %ebx
 484:	5e                   	pop    %esi
 485:	5f                   	pop    %edi
 486:	5d                   	pop    %ebp
 487:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 488:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 48b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 48e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 495:	00 
 496:	89 74 24 04          	mov    %esi,0x4(%esp)
 49a:	89 04 24             	mov    %eax,(%esp)
 49d:	e8 d6 fd ff ff       	call   278 <write>
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	e9 2b ff ff ff       	jmp    3d5 <printf+0x35>
 4aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 4b3:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 4b8:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4c1:	8b 10                	mov    (%eax),%edx
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	e8 35 fe ff ff       	call   300 <printint>
 4cb:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 4ce:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 4d2:	e9 fe fe ff ff       	jmp    3d5 <printf+0x35>
 4d7:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 4d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        ap++;
        if(s == 0)
 4db:	b9 16 07 00 00       	mov    $0x716,%ecx
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
 4e0:	8b 3a                	mov    (%edx),%edi
        ap++;
 4e2:	83 c2 04             	add    $0x4,%edx
 4e5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 4e8:	85 ff                	test   %edi,%edi
 4ea:	0f 44 f9             	cmove  %ecx,%edi
          s = "(null)";
        while(*s != 0){
 4ed:	0f b6 17             	movzbl (%edi),%edx
 4f0:	84 d2                	test   %dl,%dl
 4f2:	74 33                	je     527 <printf+0x187>
 4f4:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 4f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
 4fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          putc(fd, *s);
          s++;
 500:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 503:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 506:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 50d:	00 
 50e:	89 74 24 04          	mov    %esi,0x4(%esp)
 512:	89 1c 24             	mov    %ebx,(%esp)
 515:	e8 5e fd ff ff       	call   278 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 51a:	0f b6 17             	movzbl (%edi),%edx
 51d:	84 d2                	test   %dl,%dl
 51f:	75 df                	jne    500 <printf+0x160>
 521:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 524:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 527:	31 ff                	xor    %edi,%edi
 529:	e9 a7 fe ff ff       	jmp    3d5 <printf+0x35>
 52e:	66 90                	xchg   %ax,%ax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 530:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 534:	e9 1a ff ff ff       	jmp    453 <printf+0xb3>
 539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 540:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 543:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 548:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 54b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 552:	8b 10                	mov    (%eax),%edx
 554:	8b 45 08             	mov    0x8(%ebp),%eax
 557:	e8 a4 fd ff ff       	call   300 <printint>
 55c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 55f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 563:	e9 6d fe ff ff       	jmp    3d5 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 568:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        putc(fd, *ap);
        ap++;
 56b:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 56d:	8b 4d 08             	mov    0x8(%ebp),%ecx
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 570:	8b 02                	mov    (%edx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 572:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 579:	00 
 57a:	89 74 24 04          	mov    %esi,0x4(%esp)
 57e:	89 0c 24             	mov    %ecx,(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 581:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 584:	e8 ef fc ff ff       	call   278 <write>
 589:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 58c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 590:	e9 40 fe ff ff       	jmp    3d5 <printf+0x35>
 595:	90                   	nop
 596:	90                   	nop
 597:	90                   	nop
 598:	90                   	nop
 599:	90                   	nop
 59a:	90                   	nop
 59b:	90                   	nop
 59c:	90                   	nop
 59d:	90                   	nop
 59e:	90                   	nop
 59f:	90                   	nop

000005a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5a0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a1:	a1 38 07 00 00       	mov    0x738,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 5a6:	89 e5                	mov    %esp,%ebp
 5a8:	57                   	push   %edi
 5a9:	56                   	push   %esi
 5aa:	53                   	push   %ebx
 5ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ae:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5b1:	39 c8                	cmp    %ecx,%eax
 5b3:	73 1d                	jae    5d2 <free+0x32>
 5b5:	8d 76 00             	lea    0x0(%esi),%esi
 5b8:	8b 10                	mov    (%eax),%edx
 5ba:	39 d1                	cmp    %edx,%ecx
 5bc:	72 1a                	jb     5d8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5be:	39 d0                	cmp    %edx,%eax
 5c0:	72 08                	jb     5ca <free+0x2a>
 5c2:	39 c8                	cmp    %ecx,%eax
 5c4:	72 12                	jb     5d8 <free+0x38>
 5c6:	39 d1                	cmp    %edx,%ecx
 5c8:	72 0e                	jb     5d8 <free+0x38>
 5ca:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5cc:	39 c8                	cmp    %ecx,%eax
 5ce:	66 90                	xchg   %ax,%ax
 5d0:	72 e6                	jb     5b8 <free+0x18>
 5d2:	8b 10                	mov    (%eax),%edx
 5d4:	eb e8                	jmp    5be <free+0x1e>
 5d6:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5d8:	8b 71 04             	mov    0x4(%ecx),%esi
 5db:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5de:	39 d7                	cmp    %edx,%edi
 5e0:	74 19                	je     5fb <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5e2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5e5:	8b 50 04             	mov    0x4(%eax),%edx
 5e8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5eb:	39 ce                	cmp    %ecx,%esi
 5ed:	74 23                	je     612 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ef:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5f1:	a3 38 07 00 00       	mov    %eax,0x738
}
 5f6:	5b                   	pop    %ebx
 5f7:	5e                   	pop    %esi
 5f8:	5f                   	pop    %edi
 5f9:	5d                   	pop    %ebp
 5fa:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 5fb:	03 72 04             	add    0x4(%edx),%esi
 5fe:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 601:	8b 10                	mov    (%eax),%edx
 603:	8b 12                	mov    (%edx),%edx
 605:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 608:	8b 50 04             	mov    0x4(%eax),%edx
 60b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 60e:	39 ce                	cmp    %ecx,%esi
 610:	75 dd                	jne    5ef <free+0x4f>
    p->s.size += bp->s.size;
 612:	03 51 04             	add    0x4(%ecx),%edx
 615:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 618:	8b 53 f8             	mov    -0x8(%ebx),%edx
 61b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 61d:	a3 38 07 00 00       	mov    %eax,0x738
}
 622:	5b                   	pop    %ebx
 623:	5e                   	pop    %esi
 624:	5f                   	pop    %edi
 625:	5d                   	pop    %ebp
 626:	c3                   	ret    
 627:	89 f6                	mov    %esi,%esi
 629:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000630 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 630:	55                   	push   %ebp
 631:	89 e5                	mov    %esp,%ebp
 633:	57                   	push   %edi
 634:	56                   	push   %esi
 635:	53                   	push   %ebx
 636:	83 ec 2c             	sub    $0x2c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 639:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 63c:	8b 0d 38 07 00 00    	mov    0x738,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 642:	83 c3 07             	add    $0x7,%ebx
 645:	c1 eb 03             	shr    $0x3,%ebx
 648:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 64b:	85 c9                	test   %ecx,%ecx
 64d:	0f 84 9b 00 00 00    	je     6ee <malloc+0xbe>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 653:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 655:	8b 50 04             	mov    0x4(%eax),%edx
 658:	39 d3                	cmp    %edx,%ebx
 65a:	76 27                	jbe    683 <malloc+0x53>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 65c:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 663:	be 00 80 00 00       	mov    $0x8000,%esi
 668:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 66b:	90                   	nop
 66c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 670:	3b 05 38 07 00 00    	cmp    0x738,%eax
 676:	74 30                	je     6a8 <malloc+0x78>
 678:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 67a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 67c:	8b 50 04             	mov    0x4(%eax),%edx
 67f:	39 d3                	cmp    %edx,%ebx
 681:	77 ed                	ja     670 <malloc+0x40>
      if(p->s.size == nunits)
 683:	39 d3                	cmp    %edx,%ebx
 685:	74 61                	je     6e8 <malloc+0xb8>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 687:	29 da                	sub    %ebx,%edx
 689:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 68c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 68f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 692:	89 0d 38 07 00 00    	mov    %ecx,0x738
      return (void*)(p + 1);
 698:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 69b:	83 c4 2c             	add    $0x2c,%esp
 69e:	5b                   	pop    %ebx
 69f:	5e                   	pop    %esi
 6a0:	5f                   	pop    %edi
 6a1:	5d                   	pop    %ebp
 6a2:	c3                   	ret    
 6a3:	90                   	nop
 6a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 6a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ab:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
 6b1:	bf 00 10 00 00       	mov    $0x1000,%edi
 6b6:	0f 43 fb             	cmovae %ebx,%edi
 6b9:	0f 42 c6             	cmovb  %esi,%eax
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 6bc:	89 04 24             	mov    %eax,(%esp)
 6bf:	e8 1c fc ff ff       	call   2e0 <sbrk>
  if(p == (char*)-1)
 6c4:	83 f8 ff             	cmp    $0xffffffff,%eax
 6c7:	74 18                	je     6e1 <malloc+0xb1>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 6c9:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 6cc:	83 c0 08             	add    $0x8,%eax
 6cf:	89 04 24             	mov    %eax,(%esp)
 6d2:	e8 c9 fe ff ff       	call   5a0 <free>
  return freep;
 6d7:	8b 0d 38 07 00 00    	mov    0x738,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 6dd:	85 c9                	test   %ecx,%ecx
 6df:	75 99                	jne    67a <malloc+0x4a>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 6e1:	31 c0                	xor    %eax,%eax
 6e3:	eb b6                	jmp    69b <malloc+0x6b>
 6e5:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 6e8:	8b 10                	mov    (%eax),%edx
 6ea:	89 11                	mov    %edx,(%ecx)
 6ec:	eb a4                	jmp    692 <malloc+0x62>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 6ee:	c7 05 38 07 00 00 30 	movl   $0x730,0x738
 6f5:	07 00 00 
    base.s.size = 0;
 6f8:	b9 30 07 00 00       	mov    $0x730,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 6fd:	c7 05 30 07 00 00 30 	movl   $0x730,0x730
 704:	07 00 00 
    base.s.size = 0;
 707:	c7 05 34 07 00 00 00 	movl   $0x0,0x734
 70e:	00 00 00 
 711:	e9 3d ff ff ff       	jmp    653 <malloc+0x23>
