
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 1c             	sub    $0x1c,%esp
   9:	8b 75 08             	mov    0x8(%ebp),%esi
   c:	8b 7d 0c             	mov    0xc(%ebp),%edi
   f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
  18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1c:	89 3c 24             	mov    %edi,(%esp)
  1f:	e8 3c 00 00 00       	call   60 <matchhere>
  24:	85 c0                	test   %eax,%eax
  26:	75 20                	jne    48 <matchstar+0x48>
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0f b6 03             	movzbl (%ebx),%eax
  2b:	84 c0                	test   %al,%al
  2d:	74 0f                	je     3e <matchstar+0x3e>
  2f:	0f be c0             	movsbl %al,%eax
  32:	83 c3 01             	add    $0x1,%ebx
  35:	39 f0                	cmp    %esi,%eax
  37:	74 df                	je     18 <matchstar+0x18>
  39:	83 fe 2e             	cmp    $0x2e,%esi
  3c:	74 da                	je     18 <matchstar+0x18>
  return 0;
}
  3e:	83 c4 1c             	add    $0x1c,%esp
int matchstar(int c, char *re, char *text)
{
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  41:	31 c0                	xor    %eax,%eax
  return 0;
}
  43:	5b                   	pop    %ebx
  44:	5e                   	pop    %esi
  45:	5f                   	pop    %edi
  46:	5d                   	pop    %ebp
  47:	c3                   	ret    
  48:	83 c4 1c             	add    $0x1c,%esp

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
  4b:	b8 01 00 00 00       	mov    $0x1,%eax
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  return 0;
}
  50:	5b                   	pop    %ebx
  51:	5e                   	pop    %esi
  52:	5f                   	pop    %edi
  53:	5d                   	pop    %ebp
  54:	c3                   	ret    
  55:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000060 <matchhere>:
  return 0;
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  60:	55                   	push   %ebp
  61:	89 e5                	mov    %esp,%ebp
  63:	56                   	push   %esi
  64:	53                   	push   %ebx
  65:	83 ec 10             	sub    $0x10,%esp
  68:	8b 55 08             	mov    0x8(%ebp),%edx
  6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  if(re[0] == '\0')
  6e:	0f b6 02             	movzbl (%edx),%eax
  71:	84 c0                	test   %al,%al
  73:	75 1c                	jne    91 <matchhere+0x31>
  75:	eb 51                	jmp    c8 <matchhere+0x68>
  77:	90                   	nop
    return 1;
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	0f b6 19             	movzbl (%ecx),%ebx
  7b:	84 db                	test   %bl,%bl
  7d:	74 39                	je     b8 <matchhere+0x58>
  7f:	3c 2e                	cmp    $0x2e,%al
  81:	74 04                	je     87 <matchhere+0x27>
  83:	38 d8                	cmp    %bl,%al
  85:	75 31                	jne    b8 <matchhere+0x58>
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
  87:	0f b6 02             	movzbl (%edx),%eax
  8a:	84 c0                	test   %al,%al
  8c:	74 3a                	je     c8 <matchhere+0x68>
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  8e:	83 c1 01             	add    $0x1,%ecx
// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
    return 1;
  if(re[1] == '*')
  91:	0f b6 5a 01          	movzbl 0x1(%edx),%ebx
  95:	8d 72 01             	lea    0x1(%edx),%esi
  98:	80 fb 2a             	cmp    $0x2a,%bl
  9b:	74 3b                	je     d8 <matchhere+0x78>
    return matchstar(re[0], re+2, text);
  if(re[0] == '$' && re[1] == '\0')
  9d:	3c 24                	cmp    $0x24,%al
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
    return 1;
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  9f:	89 f2                	mov    %esi,%edx
  if(re[0] == '$' && re[1] == '\0')
  a1:	75 d5                	jne    78 <matchhere+0x18>
  a3:	84 db                	test   %bl,%bl
  a5:	75 d1                	jne    78 <matchhere+0x18>
    return *text == '\0';
  a7:	31 c0                	xor    %eax,%eax
  a9:	80 39 00             	cmpb   $0x0,(%ecx)
  ac:	0f 94 c0             	sete   %al
  af:	eb 09                	jmp    ba <matchhere+0x5a>
  b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
  b8:	31 c0                	xor    %eax,%eax
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  return 0;
}
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	5b                   	pop    %ebx
  be:	5e                   	pop    %esi
  bf:	5d                   	pop    %ebp
  c0:	c3                   	ret    
  c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  c8:	83 c4 10             	add    $0x10,%esp
}

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
  cb:	b8 01 00 00 00       	mov    $0x1,%eax
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  return 0;
}
  d0:	5b                   	pop    %ebx
  d1:	5e                   	pop    %esi
  d2:	5d                   	pop    %ebp
  d3:	c3                   	ret    
  d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
int matchhere(char *re, char *text)
{
  if(re[0] == '\0')
    return 1;
  if(re[1] == '*')
    return matchstar(re[0], re+2, text);
  d8:	83 c2 02             	add    $0x2,%edx
  db:	0f be c0             	movsbl %al,%eax
  de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  e6:	89 04 24             	mov    %eax,(%esp)
  e9:	e8 12 ff ff ff       	call   0 <matchstar>
  if(re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
    return matchhere(re+1, text+1);
  return 0;
}
  ee:	83 c4 10             	add    $0x10,%esp
  f1:	5b                   	pop    %ebx
  f2:	5e                   	pop    %esi
  f3:	5d                   	pop    %ebp
  f4:	c3                   	ret    
  f5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000100 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	56                   	push   %esi
 104:	53                   	push   %ebx
 105:	83 ec 10             	sub    $0x10,%esp
 108:	8b 75 08             	mov    0x8(%ebp),%esi
 10b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(re[0] == '^')
 10e:	80 3e 5e             	cmpb   $0x5e,(%esi)
 111:	75 08                	jne    11b <match+0x1b>
 113:	eb 2f                	jmp    144 <match+0x44>
 115:	8d 76 00             	lea    0x0(%esi),%esi
    return matchhere(re+1, text);
  do{  // must look at empty string
    if(matchhere(re, text))
      return 1;
  }while(*text++ != '\0');
 118:	83 c3 01             	add    $0x1,%ebx
match(char *re, char *text)
{
  if(re[0] == '^')
    return matchhere(re+1, text);
  do{  // must look at empty string
    if(matchhere(re, text))
 11b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 11f:	89 34 24             	mov    %esi,(%esp)
 122:	e8 39 ff ff ff       	call   60 <matchhere>
 127:	85 c0                	test   %eax,%eax
 129:	75 0d                	jne    138 <match+0x38>
      return 1;
  }while(*text++ != '\0');
 12b:	80 3b 00             	cmpb   $0x0,(%ebx)
 12e:	75 e8                	jne    118 <match+0x18>
  return 0;
}
 130:	83 c4 10             	add    $0x10,%esp
 133:	5b                   	pop    %ebx
 134:	5e                   	pop    %esi
 135:	5d                   	pop    %ebp
 136:	c3                   	ret    
 137:	90                   	nop
 138:	83 c4 10             	add    $0x10,%esp
  if(re[0] == '^')
    return matchhere(re+1, text);
  do{  // must look at empty string
    if(matchhere(re, text))
      return 1;
  }while(*text++ != '\0');
 13b:	b8 01 00 00 00       	mov    $0x1,%eax
  return 0;
}
 140:	5b                   	pop    %ebx
 141:	5e                   	pop    %esi
 142:	5d                   	pop    %ebp
 143:	c3                   	ret    

int
match(char *re, char *text)
{
  if(re[0] == '^')
    return matchhere(re+1, text);
 144:	83 c6 01             	add    $0x1,%esi
 147:	89 75 08             	mov    %esi,0x8(%ebp)
  do{  // must look at empty string
    if(matchhere(re, text))
      return 1;
  }while(*text++ != '\0');
  return 0;
}
 14a:	83 c4 10             	add    $0x10,%esp
 14d:	5b                   	pop    %ebx
 14e:	5e                   	pop    %esi
 14f:	5d                   	pop    %ebp

int
match(char *re, char *text)
{
  if(re[0] == '^')
    return matchhere(re+1, text);
 150:	e9 0b ff ff ff       	jmp    60 <matchhere>
 155:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 159:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000160 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	57                   	push   %edi
 164:	56                   	push   %esi
 165:	53                   	push   %ebx
 166:	83 ec 2c             	sub    $0x2c,%esp
 169:	8b 7d 08             	mov    0x8(%ebp),%edi
 16c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 173:	90                   	nop
 174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int n, m;
  char *p, *q;

  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 178:	b8 ff 03 00 00       	mov    $0x3ff,%eax
 17d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
 180:	89 44 24 08          	mov    %eax,0x8(%esp)
 184:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 187:	05 a0 0a 00 00       	add    $0xaa0,%eax
 18c:	89 44 24 04          	mov    %eax,0x4(%esp)
 190:	8b 45 0c             	mov    0xc(%ebp),%eax
 193:	89 04 24             	mov    %eax,(%esp)
 196:	e8 e5 03 00 00       	call   580 <read>
 19b:	85 c0                	test   %eax,%eax
 19d:	0f 8e b9 00 00 00    	jle    25c <grep+0xfc>
    m += n;
 1a3:	01 45 e4             	add    %eax,-0x1c(%ebp)
    buf[m] = '\0';
 1a6:	be a0 0a 00 00       	mov    $0xaa0,%esi
 1ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1ae:	c6 80 a0 0a 00 00 00 	movb   $0x0,0xaa0(%eax)
 1b5:	8d 76 00             	lea    0x0(%esi),%esi
    p = buf;
    while((q = strchr(p, '\n')) != 0){
 1b8:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
 1bf:	00 
 1c0:	89 34 24             	mov    %esi,(%esp)
 1c3:	e8 38 02 00 00       	call   400 <strchr>
 1c8:	85 c0                	test   %eax,%eax
 1ca:	89 c3                	mov    %eax,%ebx
 1cc:	74 42                	je     210 <grep+0xb0>
      *q = 0;
 1ce:	c6 03 00             	movb   $0x0,(%ebx)
      if(match(pattern, p)){
 1d1:	89 74 24 04          	mov    %esi,0x4(%esp)
 1d5:	89 3c 24             	mov    %edi,(%esp)
 1d8:	e8 23 ff ff ff       	call   100 <match>
 1dd:	85 c0                	test   %eax,%eax
 1df:	75 07                	jne    1e8 <grep+0x88>
 1e1:	83 c3 01             	add    $0x1,%ebx
        *q = '\n';
        write(1, p, q+1 - p);
 1e4:	89 de                	mov    %ebx,%esi
 1e6:	eb d0                	jmp    1b8 <grep+0x58>
    buf[m] = '\0';
    p = buf;
    while((q = strchr(p, '\n')) != 0){
      *q = 0;
      if(match(pattern, p)){
        *q = '\n';
 1e8:	c6 03 0a             	movb   $0xa,(%ebx)
        write(1, p, q+1 - p);
 1eb:	83 c3 01             	add    $0x1,%ebx
 1ee:	89 d8                	mov    %ebx,%eax
 1f0:	29 f0                	sub    %esi,%eax
 1f2:	89 74 24 04          	mov    %esi,0x4(%esp)
 1f6:	89 de                	mov    %ebx,%esi
 1f8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 203:	e8 80 03 00 00       	call   588 <write>
 208:	eb ae                	jmp    1b8 <grep+0x58>
 20a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      }
      p = q+1;
    }
    if(p == buf)
 210:	81 fe a0 0a 00 00    	cmp    $0xaa0,%esi
 216:	74 38                	je     250 <grep+0xf0>
      m = 0;
    if(m > 0){
 218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 21b:	85 c0                	test   %eax,%eax
 21d:	0f 8e 55 ff ff ff    	jle    178 <grep+0x18>
      m -= p - buf;
 223:	81 45 e4 a0 0a 00 00 	addl   $0xaa0,-0x1c(%ebp)
 22a:	29 75 e4             	sub    %esi,-0x1c(%ebp)
      memmove(buf, p, m);
 22d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 230:	89 74 24 04          	mov    %esi,0x4(%esp)
 234:	c7 04 24 a0 0a 00 00 	movl   $0xaa0,(%esp)
 23b:	89 44 24 08          	mov    %eax,0x8(%esp)
 23f:	e8 3c 02 00 00       	call   480 <memmove>
 244:	e9 2f ff ff ff       	jmp    178 <grep+0x18>
 249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 250:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 257:	e9 1c ff ff ff       	jmp    178 <grep+0x18>
    }
  }
}
 25c:	83 c4 2c             	add    $0x2c,%esp
 25f:	5b                   	pop    %ebx
 260:	5e                   	pop    %esi
 261:	5f                   	pop    %edi
 262:	5d                   	pop    %ebp
 263:	c3                   	ret    
 264:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 26a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

00000270 <main>:

int
main(int argc, char *argv[])
{
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	83 e4 f0             	and    $0xfffffff0,%esp
 276:	57                   	push   %edi
 277:	56                   	push   %esi
 278:	53                   	push   %ebx
 279:	83 ec 24             	sub    $0x24,%esp
 27c:	8b 7d 08             	mov    0x8(%ebp),%edi
 27f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int fd, i;
  char *pattern;

  if(argc <= 1){
 282:	83 ff 01             	cmp    $0x1,%edi
 285:	0f 8e 95 00 00 00    	jle    320 <main+0xb0>
    printf(2, "usage: grep pattern [file ...]\n");
    exit();
  }
  pattern = argv[1];
 28b:	8b 43 04             	mov    0x4(%ebx),%eax

  if(argc <= 2){
 28e:	83 ff 02             	cmp    $0x2,%edi

  if(argc <= 1){
    printf(2, "usage: grep pattern [file ...]\n");
    exit();
  }
  pattern = argv[1];
 291:	89 44 24 1c          	mov    %eax,0x1c(%esp)

  if(argc <= 2){
 295:	74 71                	je     308 <main+0x98>
    grep(pattern, 0);
    exit();
 297:	83 c3 08             	add    $0x8,%ebx
 29a:	be 02 00 00 00       	mov    $0x2,%esi
 29f:	90                   	nop
  }

  for(i = 2; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 2a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a7:	00 
 2a8:	8b 03                	mov    (%ebx),%eax
 2aa:	89 04 24             	mov    %eax,(%esp)
 2ad:	e8 f6 02 00 00       	call   5a8 <open>
 2b2:	85 c0                	test   %eax,%eax
 2b4:	78 32                	js     2e8 <main+0x78>
      printf(1, "grep: cannot open %s\n", argv[i]);
      exit();
    }
    grep(pattern, fd);
 2b6:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 2ba:	83 c6 01             	add    $0x1,%esi
 2bd:	83 c3 04             	add    $0x4,%ebx
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "grep: cannot open %s\n", argv[i]);
      exit();
    }
    grep(pattern, fd);
 2c0:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c4:	89 44 24 18          	mov    %eax,0x18(%esp)
 2c8:	89 14 24             	mov    %edx,(%esp)
 2cb:	e8 90 fe ff ff       	call   160 <grep>
    close(fd);
 2d0:	8b 44 24 18          	mov    0x18(%esp),%eax
 2d4:	89 04 24             	mov    %eax,(%esp)
 2d7:	e8 b4 02 00 00       	call   590 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 2dc:	39 f7                	cmp    %esi,%edi
 2de:	7f c0                	jg     2a0 <main+0x30>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 2e0:	e8 83 02 00 00       	call   568 <exit>
 2e5:	8d 76 00             	lea    0x0(%esi),%esi
    exit();
  }

  for(i = 2; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "grep: cannot open %s\n", argv[i]);
 2e8:	8b 03                	mov    (%ebx),%eax
 2ea:	c7 44 24 04 48 0a 00 	movl   $0xa48,0x4(%esp)
 2f1:	00 
 2f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f9:	89 44 24 08          	mov    %eax,0x8(%esp)
 2fd:	e8 ae 03 00 00       	call   6b0 <printf>
      exit();
 302:	e8 61 02 00 00       	call   568 <exit>
 307:	90                   	nop
    exit();
  }
  pattern = argv[1];

  if(argc <= 2){
    grep(pattern, 0);
 308:	89 04 24             	mov    %eax,(%esp)
 30b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 312:	00 
 313:	e8 48 fe ff ff       	call   160 <grep>
    exit();
 318:	e8 4b 02 00 00       	call   568 <exit>
 31d:	8d 76 00             	lea    0x0(%esi),%esi
{
  int fd, i;
  char *pattern;

  if(argc <= 1){
    printf(2, "usage: grep pattern [file ...]\n");
 320:	c7 44 24 04 28 0a 00 	movl   $0xa28,0x4(%esp)
 327:	00 
 328:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 32f:	e8 7c 03 00 00       	call   6b0 <printf>
    exit();
 334:	e8 2f 02 00 00       	call   568 <exit>
 339:	90                   	nop
 33a:	90                   	nop
 33b:	90                   	nop
 33c:	90                   	nop
 33d:	90                   	nop
 33e:	90                   	nop
 33f:	90                   	nop

00000340 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 340:	55                   	push   %ebp
 341:	31 d2                	xor    %edx,%edx
 343:	89 e5                	mov    %esp,%ebp
 345:	8b 45 08             	mov    0x8(%ebp),%eax
 348:	53                   	push   %ebx
 349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 34c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 350:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
 354:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 357:	83 c2 01             	add    $0x1,%edx
 35a:	84 c9                	test   %cl,%cl
 35c:	75 f2                	jne    350 <strcpy+0x10>
    ;
  return os;
}
 35e:	5b                   	pop    %ebx
 35f:	5d                   	pop    %ebp
 360:	c3                   	ret    
 361:	eb 0d                	jmp    370 <strcmp>
 363:	90                   	nop
 364:	90                   	nop
 365:	90                   	nop
 366:	90                   	nop
 367:	90                   	nop
 368:	90                   	nop
 369:	90                   	nop
 36a:	90                   	nop
 36b:	90                   	nop
 36c:	90                   	nop
 36d:	90                   	nop
 36e:	90                   	nop
 36f:	90                   	nop

00000370 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	53                   	push   %ebx
 374:	8b 4d 08             	mov    0x8(%ebp),%ecx
 377:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 37a:	0f b6 01             	movzbl (%ecx),%eax
 37d:	84 c0                	test   %al,%al
 37f:	75 14                	jne    395 <strcmp+0x25>
 381:	eb 25                	jmp    3a8 <strcmp+0x38>
 383:	90                   	nop
 384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p++, q++;
 388:	83 c1 01             	add    $0x1,%ecx
 38b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 38e:	0f b6 01             	movzbl (%ecx),%eax
 391:	84 c0                	test   %al,%al
 393:	74 13                	je     3a8 <strcmp+0x38>
 395:	0f b6 1a             	movzbl (%edx),%ebx
 398:	38 d8                	cmp    %bl,%al
 39a:	74 ec                	je     388 <strcmp+0x18>
 39c:	0f b6 db             	movzbl %bl,%ebx
 39f:	0f b6 c0             	movzbl %al,%eax
 3a2:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 3a4:	5b                   	pop    %ebx
 3a5:	5d                   	pop    %ebp
 3a6:	c3                   	ret    
 3a7:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3a8:	0f b6 1a             	movzbl (%edx),%ebx
 3ab:	31 c0                	xor    %eax,%eax
 3ad:	0f b6 db             	movzbl %bl,%ebx
 3b0:	29 d8                	sub    %ebx,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
}
 3b2:	5b                   	pop    %ebx
 3b3:	5d                   	pop    %ebp
 3b4:	c3                   	ret    
 3b5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000003c0 <strlen>:

uint
strlen(const char *s)
{
 3c0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
 3c1:	31 d2                	xor    %edx,%edx
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
 3c3:	89 e5                	mov    %esp,%ebp
  int n;

  for(n = 0; s[n]; n++)
 3c5:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
 3c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 3ca:	80 39 00             	cmpb   $0x0,(%ecx)
 3cd:	74 0c                	je     3db <strlen+0x1b>
 3cf:	90                   	nop
 3d0:	83 c2 01             	add    $0x1,%edx
 3d3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 3d7:	89 d0                	mov    %edx,%eax
 3d9:	75 f5                	jne    3d0 <strlen+0x10>
    ;
  return n;
}
 3db:	5d                   	pop    %ebp
 3dc:	c3                   	ret    
 3dd:	8d 76 00             	lea    0x0(%esi),%esi

000003e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	8b 55 08             	mov    0x8(%ebp),%edx
 3e6:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 3e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ed:	89 d7                	mov    %edx,%edi
 3ef:	fc                   	cld    
 3f0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 3f2:	89 d0                	mov    %edx,%eax
 3f4:	5f                   	pop    %edi
 3f5:	5d                   	pop    %ebp
 3f6:	c3                   	ret    
 3f7:	89 f6                	mov    %esi,%esi
 3f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000400 <strchr>:

char*
strchr(const char *s, char c)
{
 400:	55                   	push   %ebp
 401:	89 e5                	mov    %esp,%ebp
 403:	8b 45 08             	mov    0x8(%ebp),%eax
 406:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 40a:	0f b6 10             	movzbl (%eax),%edx
 40d:	84 d2                	test   %dl,%dl
 40f:	75 11                	jne    422 <strchr+0x22>
 411:	eb 15                	jmp    428 <strchr+0x28>
 413:	90                   	nop
 414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 418:	83 c0 01             	add    $0x1,%eax
 41b:	0f b6 10             	movzbl (%eax),%edx
 41e:	84 d2                	test   %dl,%dl
 420:	74 06                	je     428 <strchr+0x28>
    if(*s == c)
 422:	38 ca                	cmp    %cl,%dl
 424:	75 f2                	jne    418 <strchr+0x18>
      return (char*)s;
  return 0;
}
 426:	5d                   	pop    %ebp
 427:	c3                   	ret    
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 428:	31 c0                	xor    %eax,%eax
    if(*s == c)
      return (char*)s;
  return 0;
}
 42a:	5d                   	pop    %ebp
 42b:	90                   	nop
 42c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 430:	c3                   	ret    
 431:	eb 0d                	jmp    440 <atoi>
 433:	90                   	nop
 434:	90                   	nop
 435:	90                   	nop
 436:	90                   	nop
 437:	90                   	nop
 438:	90                   	nop
 439:	90                   	nop
 43a:	90                   	nop
 43b:	90                   	nop
 43c:	90                   	nop
 43d:	90                   	nop
 43e:	90                   	nop
 43f:	90                   	nop

00000440 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 440:	55                   	push   %ebp
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 441:	31 c0                	xor    %eax,%eax
  return r;
}

int
atoi(const char *s)
{
 443:	89 e5                	mov    %esp,%ebp
 445:	8b 4d 08             	mov    0x8(%ebp),%ecx
 448:	53                   	push   %ebx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 449:	0f b6 11             	movzbl (%ecx),%edx
 44c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 44f:	80 fb 09             	cmp    $0x9,%bl
 452:	77 1c                	ja     470 <atoi+0x30>
 454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    n = n*10 + *s++ - '0';
 458:	0f be d2             	movsbl %dl,%edx
 45b:	83 c1 01             	add    $0x1,%ecx
 45e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 461:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 465:	0f b6 11             	movzbl (%ecx),%edx
 468:	8d 5a d0             	lea    -0x30(%edx),%ebx
 46b:	80 fb 09             	cmp    $0x9,%bl
 46e:	76 e8                	jbe    458 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 470:	5b                   	pop    %ebx
 471:	5d                   	pop    %ebp
 472:	c3                   	ret    
 473:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000480 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	56                   	push   %esi
 484:	8b 45 08             	mov    0x8(%ebp),%eax
 487:	53                   	push   %ebx
 488:	8b 5d 10             	mov    0x10(%ebp),%ebx
 48b:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 48e:	85 db                	test   %ebx,%ebx
 490:	7e 14                	jle    4a6 <memmove+0x26>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 492:	31 d2                	xor    %edx,%edx
 494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 498:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 49c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 49f:	83 c2 01             	add    $0x1,%edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4a2:	39 da                	cmp    %ebx,%edx
 4a4:	75 f2                	jne    498 <memmove+0x18>
    *dst++ = *src++;
  return vdst;
}
 4a6:	5b                   	pop    %ebx
 4a7:	5e                   	pop    %esi
 4a8:	5d                   	pop    %ebp
 4a9:	c3                   	ret    
 4aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

000004b0 <stat>:
  return buf;
}

int
stat(const char *n, struct stat *st)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
  return buf;
}

int
stat(const char *n, struct stat *st)
{
 4b9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 4bc:	89 75 fc             	mov    %esi,-0x4(%ebp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
 4bf:	be ff ff ff ff       	mov    $0xffffffff,%esi
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4cb:	00 
 4cc:	89 04 24             	mov    %eax,(%esp)
 4cf:	e8 d4 00 00 00       	call   5a8 <open>
  if(fd < 0)
 4d4:	85 c0                	test   %eax,%eax
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4d6:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 4d8:	78 19                	js     4f3 <stat+0x43>
    return -1;
  r = fstat(fd, st);
 4da:	8b 45 0c             	mov    0xc(%ebp),%eax
 4dd:	89 1c 24             	mov    %ebx,(%esp)
 4e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e4:	e8 d7 00 00 00       	call   5c0 <fstat>
  close(fd);
 4e9:	89 1c 24             	mov    %ebx,(%esp)
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
 4ec:	89 c6                	mov    %eax,%esi
  close(fd);
 4ee:	e8 9d 00 00 00       	call   590 <close>
  return r;
}
 4f3:	89 f0                	mov    %esi,%eax
 4f5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 4f8:	8b 75 fc             	mov    -0x4(%ebp),%esi
 4fb:	89 ec                	mov    %ebp,%esp
 4fd:	5d                   	pop    %ebp
 4fe:	c3                   	ret    
 4ff:	90                   	nop

00000500 <gets>:
  return 0;
}

char*
gets(char *buf, int max)
{
 500:	55                   	push   %ebp
 501:	89 e5                	mov    %esp,%ebp
 503:	57                   	push   %edi
 504:	56                   	push   %esi
 505:	31 f6                	xor    %esi,%esi
 507:	53                   	push   %ebx
 508:	83 ec 2c             	sub    $0x2c,%esp
 50b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 50e:	eb 06                	jmp    516 <gets+0x16>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 510:	3c 0a                	cmp    $0xa,%al
 512:	74 39                	je     54d <gets+0x4d>
 514:	89 de                	mov    %ebx,%esi
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 516:	8d 5e 01             	lea    0x1(%esi),%ebx
 519:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 51c:	7d 31                	jge    54f <gets+0x4f>
    cc = read(0, &c, 1);
 51e:	8d 45 e7             	lea    -0x19(%ebp),%eax
 521:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 528:	00 
 529:	89 44 24 04          	mov    %eax,0x4(%esp)
 52d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 534:	e8 47 00 00 00       	call   580 <read>
    if(cc < 1)
 539:	85 c0                	test   %eax,%eax
 53b:	7e 12                	jle    54f <gets+0x4f>
      break;
    buf[i++] = c;
 53d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 541:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 545:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 549:	3c 0d                	cmp    $0xd,%al
 54b:	75 c3                	jne    510 <gets+0x10>
 54d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 54f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 553:	89 f8                	mov    %edi,%eax
 555:	83 c4 2c             	add    $0x2c,%esp
 558:	5b                   	pop    %ebx
 559:	5e                   	pop    %esi
 55a:	5f                   	pop    %edi
 55b:	5d                   	pop    %ebp
 55c:	c3                   	ret    
 55d:	90                   	nop
 55e:	90                   	nop
 55f:	90                   	nop

00000560 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 560:	b8 01 00 00 00       	mov    $0x1,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <exit>:
SYSCALL(exit)
 568:	b8 02 00 00 00       	mov    $0x2,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <wait>:
SYSCALL(wait)
 570:	b8 03 00 00 00       	mov    $0x3,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <pipe>:
SYSCALL(pipe)
 578:	b8 04 00 00 00       	mov    $0x4,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <read>:
SYSCALL(read)
 580:	b8 05 00 00 00       	mov    $0x5,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <write>:
SYSCALL(write)
 588:	b8 10 00 00 00       	mov    $0x10,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <close>:
SYSCALL(close)
 590:	b8 15 00 00 00       	mov    $0x15,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <kill>:
SYSCALL(kill)
 598:	b8 06 00 00 00       	mov    $0x6,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <exec>:
SYSCALL(exec)
 5a0:	b8 07 00 00 00       	mov    $0x7,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <open>:
SYSCALL(open)
 5a8:	b8 0f 00 00 00       	mov    $0xf,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <mknod>:
SYSCALL(mknod)
 5b0:	b8 11 00 00 00       	mov    $0x11,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <unlink>:
SYSCALL(unlink)
 5b8:	b8 12 00 00 00       	mov    $0x12,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <fstat>:
SYSCALL(fstat)
 5c0:	b8 08 00 00 00       	mov    $0x8,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <link>:
SYSCALL(link)
 5c8:	b8 13 00 00 00       	mov    $0x13,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <mkdir>:
SYSCALL(mkdir)
 5d0:	b8 14 00 00 00       	mov    $0x14,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <chdir>:
SYSCALL(chdir)
 5d8:	b8 09 00 00 00       	mov    $0x9,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <dup>:
SYSCALL(dup)
 5e0:	b8 0a 00 00 00       	mov    $0xa,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <getpid>:
SYSCALL(getpid)
 5e8:	b8 0b 00 00 00       	mov    $0xb,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <sbrk>:
SYSCALL(sbrk)
 5f0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <sleep>:
SYSCALL(sleep)
 5f8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <uptime>:
SYSCALL(uptime)
 600:	b8 0e 00 00 00       	mov    $0xe,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    
 608:	90                   	nop
 609:	90                   	nop
 60a:	90                   	nop
 60b:	90                   	nop
 60c:	90                   	nop
 60d:	90                   	nop
 60e:	90                   	nop
 60f:	90                   	nop

00000610 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	57                   	push   %edi
 614:	89 cf                	mov    %ecx,%edi
 616:	56                   	push   %esi
 617:	89 c6                	mov    %eax,%esi
 619:	53                   	push   %ebx
 61a:	83 ec 4c             	sub    $0x4c,%esp
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 61d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 620:	85 c9                	test   %ecx,%ecx
 622:	74 04                	je     628 <printint+0x18>
 624:	85 d2                	test   %edx,%edx
 626:	78 70                	js     698 <printint+0x88>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 628:	89 d0                	mov    %edx,%eax
 62a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 631:	31 c9                	xor    %ecx,%ecx
 633:	8d 5d d7             	lea    -0x29(%ebp),%ebx
 636:	66 90                	xchg   %ax,%ax
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
 638:	31 d2                	xor    %edx,%edx
 63a:	f7 f7                	div    %edi
 63c:	0f b6 92 65 0a 00 00 	movzbl 0xa65(%edx),%edx
 643:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
 646:	83 c1 01             	add    $0x1,%ecx
  }while((x /= base) != 0);
 649:	85 c0                	test   %eax,%eax
 64b:	75 eb                	jne    638 <printint+0x28>
  if(neg)
 64d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 650:	85 c0                	test   %eax,%eax
 652:	74 08                	je     65c <printint+0x4c>
    buf[i++] = '-';
 654:	c6 44 0d d7 2d       	movb   $0x2d,-0x29(%ebp,%ecx,1)
 659:	83 c1 01             	add    $0x1,%ecx

  while(--i >= 0)
 65c:	8d 79 ff             	lea    -0x1(%ecx),%edi
 65f:	01 fb                	add    %edi,%ebx
 661:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 668:	0f b6 03             	movzbl (%ebx),%eax
 66b:	83 ef 01             	sub    $0x1,%edi
 66e:	83 eb 01             	sub    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 671:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 678:	00 
 679:	89 34 24             	mov    %esi,(%esp)
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 67c:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 67f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 682:	89 44 24 04          	mov    %eax,0x4(%esp)
 686:	e8 fd fe ff ff       	call   588 <write>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 68b:	83 ff ff             	cmp    $0xffffffff,%edi
 68e:	75 d8                	jne    668 <printint+0x58>
    putc(fd, buf[i]);
}
 690:	83 c4 4c             	add    $0x4c,%esp
 693:	5b                   	pop    %ebx
 694:	5e                   	pop    %esi
 695:	5f                   	pop    %edi
 696:	5d                   	pop    %ebp
 697:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 698:	89 d0                	mov    %edx,%eax
 69a:	f7 d8                	neg    %eax
 69c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
 6a3:	eb 8c                	jmp    631 <printint+0x21>
 6a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 6a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

000006b0 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	57                   	push   %edi
 6b4:	56                   	push   %esi
 6b5:	53                   	push   %ebx
 6b6:	83 ec 3c             	sub    $0x3c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bc:	0f b6 10             	movzbl (%eax),%edx
 6bf:	84 d2                	test   %dl,%dl
 6c1:	0f 84 c9 00 00 00    	je     790 <printf+0xe0>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 6c7:	8d 4d 10             	lea    0x10(%ebp),%ecx
 6ca:	31 ff                	xor    %edi,%edi
 6cc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
 6cf:	31 db                	xor    %ebx,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 6d1:	8d 75 e7             	lea    -0x19(%ebp),%esi
 6d4:	eb 1e                	jmp    6f4 <printf+0x44>
 6d6:	66 90                	xchg   %ax,%ax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 6d8:	83 fa 25             	cmp    $0x25,%edx
 6db:	0f 85 b7 00 00 00    	jne    798 <printf+0xe8>
 6e1:	66 bf 25 00          	mov    $0x25,%di
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6e5:	83 c3 01             	add    $0x1,%ebx
 6e8:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 6ec:	84 d2                	test   %dl,%dl
 6ee:	0f 84 9c 00 00 00    	je     790 <printf+0xe0>
    c = fmt[i] & 0xff;
    if(state == 0){
 6f4:	85 ff                	test   %edi,%edi
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
 6f6:	0f b6 d2             	movzbl %dl,%edx
    if(state == 0){
 6f9:	74 dd                	je     6d8 <printf+0x28>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6fb:	83 ff 25             	cmp    $0x25,%edi
 6fe:	75 e5                	jne    6e5 <printf+0x35>
      if(c == 'd'){
 700:	83 fa 64             	cmp    $0x64,%edx
 703:	0f 84 47 01 00 00    	je     850 <printf+0x1a0>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 709:	83 fa 70             	cmp    $0x70,%edx
 70c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 710:	0f 84 aa 00 00 00    	je     7c0 <printf+0x110>
 716:	83 fa 78             	cmp    $0x78,%edx
 719:	0f 84 a1 00 00 00    	je     7c0 <printf+0x110>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 71f:	83 fa 73             	cmp    $0x73,%edx
 722:	0f 84 c0 00 00 00    	je     7e8 <printf+0x138>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 728:	83 fa 63             	cmp    $0x63,%edx
 72b:	90                   	nop
 72c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 730:	0f 84 42 01 00 00    	je     878 <printf+0x1c8>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 736:	83 fa 25             	cmp    $0x25,%edx
 739:	0f 84 01 01 00 00    	je     840 <printf+0x190>
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 73f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 742:	89 55 cc             	mov    %edx,-0x34(%ebp)
 745:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 749:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 750:	00 
 751:	89 74 24 04          	mov    %esi,0x4(%esp)
 755:	89 0c 24             	mov    %ecx,(%esp)
 758:	e8 2b fe ff ff       	call   588 <write>
 75d:	8b 55 cc             	mov    -0x34(%ebp),%edx
 760:	88 55 e7             	mov    %dl,-0x19(%ebp)
 763:	8b 45 08             	mov    0x8(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 766:	83 c3 01             	add    $0x1,%ebx
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 769:	31 ff                	xor    %edi,%edi
 76b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 772:	00 
 773:	89 74 24 04          	mov    %esi,0x4(%esp)
 777:	89 04 24             	mov    %eax,(%esp)
 77a:	e8 09 fe ff ff       	call   588 <write>
 77f:	8b 45 0c             	mov    0xc(%ebp),%eax
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 782:	0f b6 14 18          	movzbl (%eax,%ebx,1),%edx
 786:	84 d2                	test   %dl,%dl
 788:	0f 85 66 ff ff ff    	jne    6f4 <printf+0x44>
 78e:	66 90                	xchg   %ax,%ax
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 790:	83 c4 3c             	add    $0x3c,%esp
 793:	5b                   	pop    %ebx
 794:	5e                   	pop    %esi
 795:	5f                   	pop    %edi
 796:	5d                   	pop    %ebp
 797:	c3                   	ret    
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 798:	8b 45 08             	mov    0x8(%ebp),%eax
  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 79b:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 79e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7a5:	00 
 7a6:	89 74 24 04          	mov    %esi,0x4(%esp)
 7aa:	89 04 24             	mov    %eax,(%esp)
 7ad:	e8 d6 fd ff ff       	call   588 <write>
 7b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b5:	e9 2b ff ff ff       	jmp    6e5 <printf+0x35>
 7ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 7c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 7c3:	b9 10 00 00 00       	mov    $0x10,%ecx
        ap++;
 7c8:	31 ff                	xor    %edi,%edi
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 7ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 7d1:	8b 10                	mov    (%eax),%edx
 7d3:	8b 45 08             	mov    0x8(%ebp),%eax
 7d6:	e8 35 fe ff ff       	call   610 <printint>
 7db:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 7de:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 7e2:	e9 fe fe ff ff       	jmp    6e5 <printf+0x35>
 7e7:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 7e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        ap++;
        if(s == 0)
 7eb:	b9 5e 0a 00 00       	mov    $0xa5e,%ecx
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
 7f0:	8b 3a                	mov    (%edx),%edi
        ap++;
 7f2:	83 c2 04             	add    $0x4,%edx
 7f5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        if(s == 0)
 7f8:	85 ff                	test   %edi,%edi
 7fa:	0f 44 f9             	cmove  %ecx,%edi
          s = "(null)";
        while(*s != 0){
 7fd:	0f b6 17             	movzbl (%edi),%edx
 800:	84 d2                	test   %dl,%dl
 802:	74 33                	je     837 <printf+0x187>
 804:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 807:	8b 5d 08             	mov    0x8(%ebp),%ebx
 80a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          putc(fd, *s);
          s++;
 810:	83 c7 01             	add    $0x1,%edi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 813:	88 55 e7             	mov    %dl,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 816:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 81d:	00 
 81e:	89 74 24 04          	mov    %esi,0x4(%esp)
 822:	89 1c 24             	mov    %ebx,(%esp)
 825:	e8 5e fd ff ff       	call   588 <write>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 82a:	0f b6 17             	movzbl (%edi),%edx
 82d:	84 d2                	test   %dl,%dl
 82f:	75 df                	jne    810 <printf+0x160>
 831:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 834:	8b 45 0c             	mov    0xc(%ebp),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 837:	31 ff                	xor    %edi,%edi
 839:	e9 a7 fe ff ff       	jmp    6e5 <printf+0x35>
 83e:	66 90                	xchg   %ax,%ax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 840:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 844:	e9 1a ff ff ff       	jmp    763 <printf+0xb3>
 849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 850:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 853:	b9 0a 00 00 00       	mov    $0xa,%ecx
        ap++;
 858:	66 31 ff             	xor    %di,%di
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 85b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 862:	8b 10                	mov    (%eax),%edx
 864:	8b 45 08             	mov    0x8(%ebp),%eax
 867:	e8 a4 fd ff ff       	call   610 <printint>
 86c:	8b 45 0c             	mov    0xc(%ebp),%eax
        ap++;
 86f:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 873:	e9 6d fe ff ff       	jmp    6e5 <printf+0x35>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 878:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        putc(fd, *ap);
        ap++;
 87b:	31 ff                	xor    %edi,%edi
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 87d:	8b 4d 08             	mov    0x8(%ebp),%ecx
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 880:	8b 02                	mov    (%edx),%eax
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 882:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 889:	00 
 88a:	89 74 24 04          	mov    %esi,0x4(%esp)
 88e:	89 0c 24             	mov    %ecx,(%esp)
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 891:	88 45 e7             	mov    %al,-0x19(%ebp)
#include "user.h"

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
 894:	e8 ef fc ff ff       	call   588 <write>
 899:	8b 45 0c             	mov    0xc(%ebp),%eax
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
 89c:	83 45 d4 04          	addl   $0x4,-0x2c(%ebp)
 8a0:	e9 40 fe ff ff       	jmp    6e5 <printf+0x35>
 8a5:	90                   	nop
 8a6:	90                   	nop
 8a7:	90                   	nop
 8a8:	90                   	nop
 8a9:	90                   	nop
 8aa:	90                   	nop
 8ab:	90                   	nop
 8ac:	90                   	nop
 8ad:	90                   	nop
 8ae:	90                   	nop
 8af:	90                   	nop

000008b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b0:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b1:	a1 88 0a 00 00       	mov    0xa88,%eax
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b6:	89 e5                	mov    %esp,%ebp
 8b8:	57                   	push   %edi
 8b9:	56                   	push   %esi
 8ba:	53                   	push   %ebx
 8bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8be:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c1:	39 c8                	cmp    %ecx,%eax
 8c3:	73 1d                	jae    8e2 <free+0x32>
 8c5:	8d 76 00             	lea    0x0(%esi),%esi
 8c8:	8b 10                	mov    (%eax),%edx
 8ca:	39 d1                	cmp    %edx,%ecx
 8cc:	72 1a                	jb     8e8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ce:	39 d0                	cmp    %edx,%eax
 8d0:	72 08                	jb     8da <free+0x2a>
 8d2:	39 c8                	cmp    %ecx,%eax
 8d4:	72 12                	jb     8e8 <free+0x38>
 8d6:	39 d1                	cmp    %edx,%ecx
 8d8:	72 0e                	jb     8e8 <free+0x38>
 8da:	89 d0                	mov    %edx,%eax
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8dc:	39 c8                	cmp    %ecx,%eax
 8de:	66 90                	xchg   %ax,%ax
 8e0:	72 e6                	jb     8c8 <free+0x18>
 8e2:	8b 10                	mov    (%eax),%edx
 8e4:	eb e8                	jmp    8ce <free+0x1e>
 8e6:	66 90                	xchg   %ax,%ax
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8e8:	8b 71 04             	mov    0x4(%ecx),%esi
 8eb:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 8ee:	39 d7                	cmp    %edx,%edi
 8f0:	74 19                	je     90b <free+0x5b>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 8f2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 8f5:	8b 50 04             	mov    0x4(%eax),%edx
 8f8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 8fb:	39 ce                	cmp    %ecx,%esi
 8fd:	74 23                	je     922 <free+0x72>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 8ff:	89 08                	mov    %ecx,(%eax)
  freep = p;
 901:	a3 88 0a 00 00       	mov    %eax,0xa88
}
 906:	5b                   	pop    %ebx
 907:	5e                   	pop    %esi
 908:	5f                   	pop    %edi
 909:	5d                   	pop    %ebp
 90a:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 90b:	03 72 04             	add    0x4(%edx),%esi
 90e:	89 71 04             	mov    %esi,0x4(%ecx)
    bp->s.ptr = p->s.ptr->s.ptr;
 911:	8b 10                	mov    (%eax),%edx
 913:	8b 12                	mov    (%edx),%edx
 915:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 918:	8b 50 04             	mov    0x4(%eax),%edx
 91b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 91e:	39 ce                	cmp    %ecx,%esi
 920:	75 dd                	jne    8ff <free+0x4f>
    p->s.size += bp->s.size;
 922:	03 51 04             	add    0x4(%ecx),%edx
 925:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 928:	8b 53 f8             	mov    -0x8(%ebx),%edx
 92b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 92d:	a3 88 0a 00 00       	mov    %eax,0xa88
}
 932:	5b                   	pop    %ebx
 933:	5e                   	pop    %esi
 934:	5f                   	pop    %edi
 935:	5d                   	pop    %ebp
 936:	c3                   	ret    
 937:	89 f6                	mov    %esi,%esi
 939:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

00000940 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 940:	55                   	push   %ebp
 941:	89 e5                	mov    %esp,%ebp
 943:	57                   	push   %edi
 944:	56                   	push   %esi
 945:	53                   	push   %ebx
 946:	83 ec 2c             	sub    $0x2c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 949:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((prevp = freep) == 0){
 94c:	8b 0d 88 0a 00 00    	mov    0xa88,%ecx
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 952:	83 c3 07             	add    $0x7,%ebx
 955:	c1 eb 03             	shr    $0x3,%ebx
 958:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 95b:	85 c9                	test   %ecx,%ecx
 95d:	0f 84 9b 00 00 00    	je     9fe <malloc+0xbe>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 963:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 965:	8b 50 04             	mov    0x4(%eax),%edx
 968:	39 d3                	cmp    %edx,%ebx
 96a:	76 27                	jbe    993 <malloc+0x53>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 96c:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 973:	be 00 80 00 00       	mov    $0x8000,%esi
 978:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 97b:	90                   	nop
 97c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 980:	3b 05 88 0a 00 00    	cmp    0xa88,%eax
 986:	74 30                	je     9b8 <malloc+0x78>
 988:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 98c:	8b 50 04             	mov    0x4(%eax),%edx
 98f:	39 d3                	cmp    %edx,%ebx
 991:	77 ed                	ja     980 <malloc+0x40>
      if(p->s.size == nunits)
 993:	39 d3                	cmp    %edx,%ebx
 995:	74 61                	je     9f8 <malloc+0xb8>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 997:	29 da                	sub    %ebx,%edx
 999:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 99c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 99f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 9a2:	89 0d 88 0a 00 00    	mov    %ecx,0xa88
      return (void*)(p + 1);
 9a8:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9ab:	83 c4 2c             	add    $0x2c,%esp
 9ae:	5b                   	pop    %ebx
 9af:	5e                   	pop    %esi
 9b0:	5f                   	pop    %edi
 9b1:	5d                   	pop    %ebp
 9b2:	c3                   	ret    
 9b3:	90                   	nop
 9b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 9b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9bb:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
 9c1:	bf 00 10 00 00       	mov    $0x1000,%edi
 9c6:	0f 43 fb             	cmovae %ebx,%edi
 9c9:	0f 42 c6             	cmovb  %esi,%eax
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 9cc:	89 04 24             	mov    %eax,(%esp)
 9cf:	e8 1c fc ff ff       	call   5f0 <sbrk>
  if(p == (char*)-1)
 9d4:	83 f8 ff             	cmp    $0xffffffff,%eax
 9d7:	74 18                	je     9f1 <malloc+0xb1>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 9d9:	89 78 04             	mov    %edi,0x4(%eax)
  free((void*)(hp + 1));
 9dc:	83 c0 08             	add    $0x8,%eax
 9df:	89 04 24             	mov    %eax,(%esp)
 9e2:	e8 c9 fe ff ff       	call   8b0 <free>
  return freep;
 9e7:	8b 0d 88 0a 00 00    	mov    0xa88,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 9ed:	85 c9                	test   %ecx,%ecx
 9ef:	75 99                	jne    98a <malloc+0x4a>
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 9f1:	31 c0                	xor    %eax,%eax
 9f3:	eb b6                	jmp    9ab <malloc+0x6b>
 9f5:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 9f8:	8b 10                	mov    (%eax),%edx
 9fa:	89 11                	mov    %edx,(%ecx)
 9fc:	eb a4                	jmp    9a2 <malloc+0x62>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 9fe:	c7 05 88 0a 00 00 80 	movl   $0xa80,0xa88
 a05:	0a 00 00 
    base.s.size = 0;
 a08:	b9 80 0a 00 00       	mov    $0xa80,%ecx
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 a0d:	c7 05 80 0a 00 00 80 	movl   $0xa80,0xa80
 a14:	0a 00 00 
    base.s.size = 0;
 a17:	c7 05 84 0a 00 00 00 	movl   $0x0,0xa84
 a1e:	00 00 00 
 a21:	e9 3d ff ff ff       	jmp    963 <malloc+0x23>
