# Pep/8 Analysis

This project provides tools to statically analyze Pep/8 programs in order to detect bugs or bad programming practices.

# Installation

Make sure you have a Nit compiler installed (http://nitlanguage.org) and the environment variable NIT\_DIR correctly set to the Nit installation directory.

Clone the source from http://github.com/xymus/pep8analyzer.git and compile with `make .

# Usage

For basic results, execute on the Pep/8 program prog.pep with `bin/pep8analyzer prog.pep`.

Call `bin/pep8analyer --help` for a description of the available (and up to date) options.
