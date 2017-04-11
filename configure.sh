#! /bin/sh

# local options:  ac_help is the help message that describes them
# and LOCAL_AC_OPTIONS is the script that interprets them.  LOCAL_AC_OPTIONS
# is a script that's processed with eval, so you need to be very careful to
# make certain that what you quote is what you want to quote.

ac_help='--shared		Build shared libraries
--disable-tiff		No tiff support
--disable-png		No png support
--disable-jpeg		No jpeg support'

LOCAL_AC_OPTIONS='
set=`locals $*`;
if [ "$set" ]; then
    eval $set
    shift 1
else
    ac_error=T;
fi'

locals() {
    K=`echo $1 | $AC_UPPERCASE`
    case "$K" in
    --DISABLE-TIFF)
		echo DONT_TIFF=T
		;;
    --DISABLE-PNG)
		echo DONT_PNG=T
		;;
    --DISABLE-JPEG)
		echo DONT_JPEG=T
		;;
    --SHARED)
                echo TRY_SHARED=T
                ;;
    esac
}			


# load in the configuration file
#
TARGET=libgd
. ./configure.inc

# and away we go
#
AC_INIT libgd

AC_PROG_CC

AC_CHECK_HEADERS limits.h
AC_CHECK_HEADERS inttypes.h
AC_CHECK_HEADERS pthread.h
AC_CHECK_HEADERS errno.h
AC_CHECK_HEADERS stddef.h
AC_CHECK_HEADERS string.h
AC_CHECK_HEADERS unistd.h
AC_CHECK_HEADERS limits.h

AC_CFLAGS="$AC_CFLAGS -DHAVE_CONFIG_H=1"
AC_DEFINE 'HAVE_CONFIG_H' '1'

test "$DONT_TIFF" || AC_LIBRARY TIFFOpen -ltiff
test "$DONT_PNG" || AC_LIBRARY png_error -lpng -lpng15
test "$DONT_JPEG" || AC_LIBRARY jpeg_set_defaults -ljpeg
test "$DONT_ZLIB" || AC_LIBRARY inflate -lz

test "$TRY_SHARED" && AC_COMPILER_PIC && AC_CC_SHLIBS

AC_OUTPUT Makefile src/Makefile

LOG
LOG "$TARGET is configured with"

for x in png tiff jpeg;do
    feature=`echo have_lib$x | $AC_UPPERCASE`

    grep $feature config.h && LOG "	$x image support"
done

grep HAVE_LIBZ config.h && LOG "	compression (libz)"
