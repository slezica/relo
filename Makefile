
build: lib
	coffee --map --output lib/ -c src/*

lib:
	mkdir lib

clean:
	rm -rf lib


test: build
	mocha test/test.coffee --slow 2000 --timeout 5000 --compilers coffee:coffee-script/register

.PHONY: clean build test
.SILENT: