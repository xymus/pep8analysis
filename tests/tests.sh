BIN=../bin/pep8analysis
test_dir=$1

for f in $test_dir/*; do
	$BIN $f
done

