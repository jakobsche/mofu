# Die Variablen Target_CPU und Target_OS müssen immer als make-Parameter angegeben werden
# Für Windows-Systeme muß Lazarus für "cross compile" eingerichtet sein, oder es müssen bereits aktuelle 
# compilierte Binaries in lib/*-win*/ vorhanden sein
# Für make muß dann das Ziel defaultwin angegeben werden.

Target = $(Target_CPU)-$(Target_OS)

default: bin/$(Target)/mofu/mofu bin/$(Target)/mofu/mofu.ico

defaultwin: bin/$(Target)/mofu/mofu.exe

bin/$(Target)/mofu/mofu.exe: lib/$(Target)/mofu.exe bin/$(Target)/mofu 
	strip -o bin/$(Target)/mofu/mofu.exe lib/$(Target)/mofu.exe

bin/$(Target)/mofu/mofu: lib/$(Target)/mofu bin/$(Target)/mofu
	strip -o bin/$(Target)/mofu/mofu lib/$(Target)/mofu

bin/$(Target)/mofu: bin/$(Target)
	mkdir bin/$(Target)/mofu

bin/$(Target): bin
	mkdir bin/$(Target)

bin:
	mkdir bin

lib/$(Target)/mofu lib/$(Target)/mofu.exe: mofu.lpi 
	lazbuild -r --os=$(Target_OS) --cpu=$(Target_CPU) mofu.lpi

bin/$(Target)/mofu/mofu.ico: mofu.ico
	cp mofu.ico bin/$(Target)/mofu/
