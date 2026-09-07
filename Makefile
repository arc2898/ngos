CC ?= cc
CFLAGS ?= -Os -s -Wall -Wextra -Wno-unused-function
LDFLAGS ?= -lX11
PREFIX ?= /usr
all: ngoswm ngdm
ngoswm: src/ngoswm.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
ngdm: src/ngdm.c
	$(CC) $(CFLAGS) -o $@ $<
install: all
	install -Dm755 ngoswm $(DESTDIR)$(PREFIX)/bin/ngoswm
	install -Dm755 ngdm $(DESTDIR)$(PREFIX)/sbin/ngdm
	install -Dm755 session/ngos-session $(DESTDIR)$(PREFIX)/bin/ngos-session
	install -Dm644 theme/ngos.desktop $(DESTDIR)$(PREFIX)/share/xsessions/ngos.desktop
clean:
	rm -f ngoswm ngdm
.PHONY: all install clean
