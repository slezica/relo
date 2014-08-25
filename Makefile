
build: lib
	coffee --map --output lib/ -c src/*


lib:
	mkdir lib


clean:
	rm -rf lib


publish: clean build
	npm publish


.PHONY: clean build
.SILENT: