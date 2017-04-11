lib:
	make -C src

install clean distclean spotless:
	make -C src $<
