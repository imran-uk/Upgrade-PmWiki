#!/bin/bash

# XXX
# run as root

# TODO
#
# * only upgrade if newer version available
# maybe scrape http://www.pmwiki.org/wiki/PmWiki/Download
#
# * rewrite using perl
#
# * do something about "tar: write error" errors (which appear to be harmless)

WIKI_VERSION_URL='http://foo.com/wiki/pmwiki.php/SiteAdmin/Status'

# comment these out when live
RSYNC_DRYRUN='--dry-run'
RSYNC_VERBOSE='--verbose'
# the no- options are because the tarball owner/group is set from the source 
# and will be retained if rsync'd.
RSYNC_OPTIONS='-a --no-owner --no-group'

UPGRADE_ROOT='/root/pmwiki'
BACKUP_ROOT='/var/local/backup'
WIKI_ROOT='/var/www/foo.com/web/wiki'

TDATE=$(date +%Y-%h-%d)

CVER=$(grep VersionNum $WIKI_ROOT/scripts/version.php)
echo "-- i have detected the installed version as [$CVER]"

echo "-- backing up wiki..."
tar -czf $BACKUP_ROOT/wiki-$TDATE.tar.gz $WIKI_ROOT

echo "-- downloading latest pmwiki..."
wget --directory-prefix=$UPGRADE_ROOT http://www.pmwiki.org/pub/pmwiki/pmwiki-latest.tgz

echo "-- extracting..."
tar -xzf $UPGRADE_ROOT/pmwiki-latest.tgz -C $UPGRADE_ROOT

# ugh - KLUDGE - better way? case for rewriting to perl?
LATEST_PMWIKI=$(tar -tzvf $UPGRADE_ROOT/pmwiki-latest.tgz | head -1 | cut -d' ' -f10)
echo "-- i have detected the latest version as [$LATEST_PMWIKI]"

echo "-- installing..."
rsync $RSYNC_OPTIONS $RSYNC_DRYRUN $RSYNC_VERBOSE \
	$UPGRADE_ROOT/$LATEST_PMWIKI/ \
	$WIKI_ROOT/

UVER=$(grep VersionNum $WIKI_ROOT/scripts/version.php)
echo "-- i have detected the installed version as [$UVER]"
echo "-- verify this by visiting: $WIKI_VERSION_URL"

echo "-- cleaning up..."
rm $UPGRADE_ROOT/pmwiki-latest.tgz
rm -rf $UPGRADE_ROOT/$LATEST_PMWIKI
#echo "delete this dir: [$UPGRADE_ROOT/$LATEST_PMWIKI]"
echo "-- done"
