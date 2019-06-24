#! /bin/bash
# Evaluate only

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
source "$sourcedir/shared_constants.sh" || exit 1

if [[ -f "$resultsfile" ]]; then
    errcho ERROR: Resuts file already exists: $resultsfile
    exit 1
fi

# Evaluate
"$scorerdir/scorer.pl" "$metric" "$goldfile" "$outfile" > "$resultsfile" || exit 1

exit 0
