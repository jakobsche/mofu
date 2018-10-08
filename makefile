Target = $(Target_CPU)-$(Target_OS)

default: bin/$(Target)/mofu/mofu

bin/$(Target)/mofu/mofu: lib/$(Target)/mofu bin/$(Target)/mofu
	strip -o bin/$(Target)/mofu/mofu lib/$(Target)/mofu

bin/$(Target)/mofu: bin/$(Target)
	mkdir bin/$(Target)/mofu

bin/$(Target): bin
	mkdir bin/$(Target)

bin:
	mkdir bin

lib/$(Target)/mofu: mofu.lpi
	lazbuild -r --os=$(Target_OS) --cpu=$(Target_CPU) mofu.lpi