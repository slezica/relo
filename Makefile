
build: lib
	coffee --map --output lib/ -c src/*

lib:
	mkdir lib

clean:
	rm -rf lib

.PHONY: clean build
.SILENT: