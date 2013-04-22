#!/bin/sh

# git branch -D upstream/rewritten-prev upstream/master upstream/rewritten filter-state      

set -e

export SCRIPTS=$(dirname $(readlink -f $0))

UPSTREAM_MASTER=upstream/master
UPSTREAM_REWRITTEN=upstream/dts

LAST=$(git show-ref -s $UPSTREAM_MASTER||true)
if [ -n "$LAST" ] ; then
    RANGE="$LAST..$UPSTREAM_REWRITTEN"
else
    # This must be a new conversion...
    RANGE="$UPSTREAM_REWRITTEN"
fi

rm -f .git/refs/original/refs/heads/${UPSTREAM_REWRITTEN}

git branch -f $UPSTREAM_REWRITTEN FETCH_HEAD

sh $SCRIPTS/git-filter-branch \
	--index-filter ${SCRIPTS}/index-filter.sh \
	--msg-filter 'cat && /bin/echo -e "\n[ upstream commit: $GIT_COMMIT ]"' \
	--tag-name-filter 'while read t ; do /bin/echo -n $t-dts ; done' \
	--prune-empty --state-branch refs/heads/filter-state \
	-- $RANGE

git branch -f $UPSTREAM_MASTER FETCH_HEAD
