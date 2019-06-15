PREFIX:=/usr/local
PLISTDIR:=/Library/LaunchAgents
BINDIR:=${PREFIX}/bin
APT:=$(shell which apt)
FREQUENCY:=3600
ARGS:=-path $(BINDIR)/osx-ca-certs

PLIST=us.diatr.openssl-osx-ca.plist
XMLARGS=$(ARGS:%=<string>%</string>)

.PHONY: install
.PHONY: uninstall
.PHONY: copy
.PHONY: package

osx-ca-certs: osx-ca-certs.m
	clang -framework CoreFoundation -framework Security $< -o $@

install: copy
	launchctl load $(PLISTDIR)/$(PLIST)

uninstall:
	launchctl unload $(PLISTDIR)/$(PLIST)
	rm $(BINDIR)/openssl-osx-ca
	rm $(BINDIR)/osx-ca-certs
	rm $(PLISTDIR)/us.diatr.openssl-osx-ca.plist

copy: $(PLISTDIR)/$(PLIST) $(BINDIR)/osx-ca-certs $(BINDIR)/openssl-osx-ca

$(PLISTDIR):
	install -d $(PLISTDIR)

$(BINDIR):
	install -d $(BINDIR)

$(PLISTDIR)/$(PLIST): Library/LaunchAgents/$(PLIST) $(PLISTDIR) Makefile
	cat $< | \
		sed 's:{BINDIR}:$(BINDIR):g' | \
		sed 's:{FREQUENCY}:$(FREQUENCY):g' | \
		sed 's:{ARGS}:$(XMLARGS):g' | \
		sed 's:{APT}:$(APT):g' > $@

$(BINDIR)/openssl-osx-ca: bin/openssl-osx-ca $(BINDIR)
	install -m 0755 $< $@

$(BINDIR)/osx-ca-certs: osx-ca-certs $(BINDIR)
	install -m 0755 $< $@

clean:
	rm -f osx-ca-certs
