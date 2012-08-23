#!/bin/bash
#
# Fanboy-Merge (Ultimate) Adblock list grabber script v1.1 (18/03/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#

export ZIP="nice -n 19 /usr/local/bin/7za a -mx=9 -y -tgzip"
export NICE="nice -n 19"
export TAC="/usr/bin/tac"
export CAT="/bin/cat"
export MAINDIR="/tmp/Ramdisk/www/adblock"
export SPLITDIR="/tmp/Ramdisk/www/adblock/split/test"
export HGSERV="/tmp/hgstuff/fanboy-adblock-list"
export TESTDIR="/tmp/work"
export ADDCHECKSUM="nice -n 19 perl $HGSERV/scripts/addChecksum.pl"
export LOGFILE="/etc/crons/log.txt"
export HG="/usr/local/bin/hg"
export SHA256SUM="/usr/bin/sha256sum"
export IEDIR="/tmp/ieramdisk"
export SUBS="/tmp/ieramdisk/subscriptions"
export IRONDIR="/tmp/Ramdisk/www/adblock/iron"

# Clear old files
#
rm -rf $TESTDIR/fanboy-addon-temp*.txt $TESTDIR/enhancedstats-addon-temp*.txt $TESTDIR/fanboy-stats-temp*.txt $TESTDIR/fanboy-complete.txt $TESTDIR/fanboy-ultimate.txt

# Tracking filter: Trim off header file, remove empty lines, and bottom line
sed '1,9d' $HGSERV/fanboy-adblocklist-stats.txt > $TESTDIR/fanboy-stats-temp2.txt
sed '/^$/d' $TESTDIR/fanboy-stats-temp2.txt > $TESTDIR/fanboy-stats-temp3.txt
sed '$d' < $TESTDIR/fanboy-stats-temp3.txt > $TESTDIR/fanboy-stats-temp.txt

# Annoyances filter: Trim off header file, remove empty lines, and bottom line
sed '1,10d' $HGSERV/fanboy-adblocklist-addon.txt > $TESTDIR/fanboy-addon-temp2.txt
sed '/^$/d' $TESTDIR/fanboy-addon-temp2.txt > $TESTDIR/fanboy-addon-temp3.txt

# Enhanced-tracking filter: Trim off header file, remove empty lines, and bottom line
sed '1,9d' $MAINDIR/enhancedstats.txt > $TESTDIR/enhancedstats-addon-temp2.txt
sed '/^$/d' $TESTDIR/enhancedstats-addon-temp2.txt > $TESTDIR/enhancedstats-addon-temp3.txt
sed '$d' < $TESTDIR/enhancedstats-addon-temp3.txt > $TESTDIR/enhancedstats-addon-temp.txt

# Remove dubes
sed -i '/analytics.js/d' $TESTDIR/fanboy-stats-temp.txt
sed -i '/com\/ga.js/d' $TESTDIR/fanboy-stats-temp.txt
sed -i '/\/js\/tracking.js/d' $TESTDIR/fanboy-stats-temp.txt

# Insert a new line to avoid chars running into each other
#
cat $MAINDIR/fanboy-adblock.txt | sed '$a!' > $TESTDIR/fanboy-adblocklist-current.txt

# Merge to the files together
#
cat $TESTDIR/fanboy-adblocklist-current.txt $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt $TESTDIR/fanboy-addon-temp3.txt > $TESTDIR/fanboy-ultimate.txt

# Ultimate List for IE (minus the main list)
#
cat $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt $TESTDIR/fanboy-addon-temp3.txt > $MAINDIR/fanboy-ultimate-ie.txt
cat $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt > $TESTDIR/fanboy-complete.txt > $MAINDIR/fanboy-complete-ie.txt

# Complete List
#
cat $TESTDIR/fanboy-adblocklist-current.txt $TESTDIR/fanboy-stats-temp.txt $TESTDIR/enhancedstats-addon-temp.txt > $TESTDIR/fanboy-complete.txt

# Add titles
#
sed -i 's/Adblock\ List/Complete\ List/g' $TESTDIR/fanboy-complete.txt
sed -i 's/Adblock\ List/Ultimate\ List/g' $TESTDIR/fanboy-ultimate.txt

# Create backups for zero'd addchecksum
#
cp -f $TESTDIR/fanboy-complete.txt $TESTDIR/fanboy-complete-bak.txt
cp -f $TESTDIR/fanboy-ultimate.txt $TESTDIR/fanboy-ultimate-bak.txt

# Addchecksum
#
$ADDCHECKSUM $TESTDIR/fanboy-complete.txt
$ADDCHECKSUM $TESTDIR/fanboy-ultimate.txt

# Now lets check if fanboy-merged.txt isnt zero
#
if [ -s $TESTDIR/fanboy-complete.txt ] && [ -s $TESTDIR/fanboy-ultimate.txt ];
then
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-complete.txt $MAINDIR/r/fanboy-complete.txt
  cp -f $TESTDIR/fanboy-ultimate.txt $MAINDIR/r/fanboy-ultimate.txt

  # Delete files before compressing
  #
  rm -f $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-complete.txt.gz

  # Compress Files
  #
  $ZIP $TESTDIR/fanboy-complete.txt.gz $TESTDIR/fanboy-complete.txt > /dev/null
  $ZIP $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-ultimate.txt > /dev/null
  
  # Copy to server
  #
  cp -f $TESTDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
  cp -f $TESTDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz

  # Check Compressed file exists first for -complete
  #
  if [ -f $TESTDIR/fanboy-complete.txt.gz ];
  then
     rm -f $MAINDIR/r/fanboy-complete.txt.gz
     cp $TESTDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
     ## DEBUG
     ### echo "Updated fanboy-complete"
     echo "Updated fanboy-complete.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
  else
     ### echo "Unable to update fanboy-complete"
     echo "*** ERROR ***: Unable to update fanboy-complete.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
  fi

  # Check Compressed file exists first for -ultimate
  #
  if [ -f $TESTDIR/fanboy-ultimate.txt.gz ];
  then
     rm -rf $MAINDIR/r/fanboy-ultimate.txt.gz
     cp $TESTDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz
     ## DEBUG
     ### echo "Updated fanboy-ultimate"
     echo "Updated fanboy-ultimate.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
  else
     ### echo "Unable to update fanboy-ultimate"
     echo "*** ERROR ***: Unable to update fanboy-ultimate.txt.gz (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
  fi
else
  # Addchecksum
  #
  $ADDCHECKSUM $TESTDIR/fanboy-complete-bak.txt
  $ADDCHECKSUM $TESTDIR/fanboy-ultimate-bak.txt
  
  # Copy Merged file to main dir
  #
  cp -f $TESTDIR/fanboy-complete-bak.txt $MAINDIR/r/fanboy-complete.txt
  cp -f $TESTDIR/fanboy-ultimate-bak.txt $MAINDIR/r/fanboy-ultimate.txt
  
  # Delete files before compressing
  #
  rm -f $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-complete.txt.gz
  
  # Compress Files
  #
  $ZIP $TESTDIR/fanboy-complete.txt.gz $TESTDIR/fanboy-complete-bak.txt > /dev/null
  $ZIP $TESTDIR/fanboy-ultimate.txt.gz $TESTDIR/fanboy-ultimate-bak.txt > /dev/null
  
  # Copy to server
  #
  cp -f $TESTDIR/fanboy-complete.txt.gz $MAINDIR/r/fanboy-complete.txt.gz
  cp -f $TESTDIR/fanboy-ultimate.txt.gz $MAINDIR/r/fanboy-ultimate.txt.gz
  
  # Log
  #
  echo "*** ERROR ***: Addchecksum Zero'd the file: fanboy-adblock-ultimate.txt (script: firefox-adblock-ultimate.sh) on `date +'%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
fi


