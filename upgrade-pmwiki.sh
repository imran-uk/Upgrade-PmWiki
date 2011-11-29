#!/bin/bash

# run as root

# TODO
#
# * only upgrade if newer version available.
# how to derive latest version? maybe scrape http://www.pmwiki.org/wiki/PmWiki/Download
#
# * test/dry-run mode - turns on verboseness.
#
# * clean-up files after
#
# * rewrite using perl
#
# * do something about "tar: write error" errors
#
# author = ichaudhry@gmail.com

WIKI_ROOT="/var/www/mysite.com/wiki"
TDATE=$(date +%Y-%h-%d)
LATEST_PMWIKI="pmwiki-2.2.35/"

CVER=$(grep VersionNum $WIKI_ROOT/scripts/version.php)
echo "-- current version is $CVER"

echo "-- backing up wiki..."
tar -czf wiki-$TDATE.tar.gz $WIKI_ROOT

echo "-- downloading latest pmwiki..."
wget http://www.pmwiki.org/pub/pmwiki/pmwiki-latest.tgz

echo "-- extracting..."
tar -xzf pmwiki-latest.tgz

# ugh - KLUDGE - better way? case for rewriting to perl!
LATEST_PMWIKI=$(tar -tzvf pmwiki-latest.tgz | head -1 | cut -d' ' -f10)
#echo "[$LATEST_PMWIKI]"

echo "-- installing..."
rsync -a $LATEST_PMWIKI $WIKI_ROOT/

UVER=$(grep VersionNum $WIKI_ROOT/scripts/version.php)
echo "-- upgraded version is $UVER"
