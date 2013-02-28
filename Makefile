bin/pep8analysis:
	mkdir -p bin
	nitc -o bin/pep8analysis src/pep8analysis.nit

doc/index.html:
	nitdoc src/pep8analysis.nit

tests:
	make -C tests

.PHONY: bin/pep8analysis tests doc/index.html
