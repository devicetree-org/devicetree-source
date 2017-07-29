#!/bin/bash

set -e
set -o pipefail

${SCRIPTS}/flatten-symlinks.pl | \
	sed -n -f ${SCRIPTS}/rewrite-paths.sed | \
	GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info

if [ -f "$GIT_INDEX_FILE.new" ] ; then
    mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"
else
    rm "$GIT_INDEX_FILE"
fi

exit 0
