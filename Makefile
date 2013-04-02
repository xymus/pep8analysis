bin/pep8analysis:
	mkdir -p bin
	nitg -o bin/pep8analysis -I lib src/pep8analysis.nit

doc/index.html:
	nitdoc src/pep8analysis.nit

tests:
	make -C tests

.PHONY: bin/pep8analysis tests doc/index.html
