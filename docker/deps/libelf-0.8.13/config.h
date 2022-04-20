/* config.h.  Generated automatically by configure.  */
/* config.h.in.  Generated automatically from configure.in by autoheader.  */

/* Define to empty if the keyword does not work.  */
/* #undef const */

/* Define if you have a working `mmap' system call.  */
#define HAVE_MMAP 1

/* Define to `long' if <sys/types.h> doesn't define.  */
/* #undef off_t */

/* Define to `unsigned' if <sys/types.h> doesn't define.  */
/* #undef size_t */

/* Define if you have the ANSI C header files.  */
#define STDC_HEADERS 1

/* Define if you want to include extra debugging code */
/* #undef ENABLE_DEBUG */

/* Define if you want to support extended ELF formats */
/* #undef ENABLE_EXTENDED_FORMAT */

/* Define if you want ELF format sanity checks by default */
#define ENABLE_SANITY_CHECKS 1

/* Define if memmove() does not copy overlapping arrays correctly */
/* #undef HAVE_BROKEN_MEMMOVE */

/* Define if you have the catgets function. */
/* #undef HAVE_CATGETS */

/* Define if you have the dgettext function. */
#define HAVE_DGETTEXT 1

/* Define if you have the memset function.  */
#define HAVE_MEMSET 1

/* Define if struct nlist is declared in <elf.h> or <sys/elf.h> */
/* #undef HAVE_STRUCT_NLIST_DECLARATION */

/* Define if Elf32_Dyn is declared in <link.h> */
/* #undef __LIBELF_NEED_LINK_H */

/* Define if Elf32_Dyn is declared in <sys/link.h> */
/* #undef __LIBELF_NEED_SYS_LINK_H */

/* Define to `<elf.h>' or `<sys/elf.h>' if one of them is present */
#define __LIBELF_HEADER_ELF_H <elf.h>

/* Define if you want 64-bit support (and your system supports it) */
#define __LIBELF64 1

/* Define if you want 64-bit support, and are running IRIX */
/* #undef __LIBELF64_IRIX */

/* Define if you want 64-bit support, and are running Linux */
/* #undef __LIBELF64_LINUX */

/* Define if you want symbol versioning (and your system supports it) */
#define __LIBELF_SYMBOL_VERSIONS 1

/* Define if symbol versioning uses Sun section type (SHT_SUNW_*) */
/* #undef __LIBELF_SUN_SYMBOL_VERSIONS */

/* Define if symbol versioning uses GNU section types (SHT_GNU_*) */
#define __LIBELF_GNU_SYMBOL_VERSIONS 1

/* Define to a 64-bit signed integer type if one exists */
#define __libelf_i64_t long

/* Define to a 64-bit unsigned integer type if one exists */
#define __libelf_u64_t unsigned long

/* Define to a 32-bit signed integer type if one exists */
#define __libelf_i32_t int

/* Define to a 32-bit unsigned integer type if one exists */
#define __libelf_u32_t unsigned int

/* Define to a 16-bit signed integer type if one exists */
#define __libelf_i16_t short

/* Define to a 16-bit unsigned integer type if one exists */
#define __libelf_u16_t unsigned short

/* The number of bytes in a __int64.  */
#define SIZEOF___INT64 0

/* The number of bytes in a int.  */
#define SIZEOF_INT 4

/* The number of bytes in a long.  */
#define SIZEOF_LONG 8

/* The number of bytes in a long long.  */
#define SIZEOF_LONG_LONG 8

/* The number of bytes in a short.  */
#define SIZEOF_SHORT 2

/* Define if you have the ftruncate function.  */
#define HAVE_FTRUNCATE 1

/* Define if you have the getpagesize function.  */
#define HAVE_GETPAGESIZE 1

/* Define if you have the memcmp function.  */
#define HAVE_MEMCMP 1

/* Define if you have the memcpy function.  */
#define HAVE_MEMCPY 1

/* Define if you have the memmove function.  */
#define HAVE_MEMMOVE 1

/* Define if you have the memset function.  */
#define HAVE_MEMSET 1

/* Define if you have the <ar.h> header file.  */
#define HAVE_AR_H 1

/* Define if you have the <elf.h> header file.  */
#define HAVE_ELF_H 1

/* Define if you have the <fcntl.h> header file.  */
#define HAVE_FCNTL_H 1

/* Define if you have the <gelf.h> header file.  */
#define HAVE_GELF_H 1

/* Define if you have the <libelf.h> header file.  */
#define HAVE_LIBELF_H 1

/* Define if you have the <link.h> header file.  */
#define HAVE_LINK_H 1

/* Define if you have the <nlist.h> header file.  */
#define HAVE_NLIST_H 1

/* Define if you have the <stdint.h> header file.  */
#define HAVE_STDINT_H 1

/* Define if you have the <sys/elf.h> header file.  */
/* #undef HAVE_SYS_ELF_H */

/* Define if you have the <sys/link.h> header file.  */
/* #undef HAVE_SYS_LINK_H */

/* Define if you have the <unistd.h> header file.  */
#define HAVE_UNISTD_H 1
