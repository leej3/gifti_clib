#!/bin/bash
if [ $# -lt 2 ]
then
echo The two arguments required are the path to the gifti tool  and to the test-data directory name
exit 1
fi

GT=$1
DATA=$2
OUT_DATA=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
cd ${OUT_DATA}

pref=$OUT_DATA/c25

# display and comapre datasets with row- and column-major data orders
$GT -show_gifti -infile $DATA/small.col.maj.3.gii > $pref.out.show.cm.txt
$GT -show_gifti -infile $DATA/small.row.maj.3.gii > $pref.out.show.rm.txt

# ===== checking diffs =====
diff $pref.out.show.[cr]m.txt

$GT                                                                           \
-show_gifti                                                                   \
-perm_by_iord 1                                                               \
-infile $DATA/small.col.maj.3.gii > $pref.out.show.crm.txt                


# ===== checking diffs =====
diff $pref.out.show.rm.txt $pref.out.show.crm.txt


# compare the 3x10 over DA versions
$GT                                                                           \
-show_gifti                                                                   \
-perm_by_iord 1                                                               \
-infile $DATA/small.3.10.cm.gii > $pref.out.show.3.cm.txt                 


$GT                                                                           \
-show_gifti                                                                   \
-perm_by_iord 1                                                               \
-infile $DATA/small.3.10.rm.gii > $pref.out.show.3.rm.txt                 


# ===== checking diffs =====
diff $pref.out.show.3.cm.txt $pref.out.show.3.rm.txt

# No 3dinfo...
# 3dinfo small.3.10.cm.gii > $pref.out.info.3.cm.txt
# 3dinfo small.3.10.rm.gii > $pref.out.info.3.rm.txt
# diff $pref.out.info.3.[cr]m.txt

rm -rf $OUT_DATA