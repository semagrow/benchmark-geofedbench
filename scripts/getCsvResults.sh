#!/bin/bash

# Copy this script in .. and run it from there

INPUT=$1
INPUT_TIME=$1-time

# Keep only ids, with their times, that timed-out
grep ";-1" $INPUT | awk -F ";" '{ print $1 }' | xargs -I{} grep "{} " $INPUT_TIME | awk '{ print $10 }' | xargs -I{} grep {} $INPUT_TIME | grep Sources | grep -v Execution | awk '{seen[$10]++; line[$10]=$0};END{for (x in seen) {if (seen[x]==1) print line[x]}}' | colrm 1 68 | sed -e 's/Source Selection Time\: //g' | sed -e 's/Compile Time\: //g' | sed -e 's/Sources\: //g' > temp/$INPUT-timedout-id-time

# Keep only ids, with their queries, that timed-out
grep ";-1" $INPUT | awk -F ";" '{ print $1 }' | xargs -I{} grep "{} " $INPUT_TIME | awk '{ print $10,"-",$23,"-",$26 }' | awk '{seen[$1]++; line[$1]=$0}END{for (x in seen) if (seen[x]==1) print line[x]}' > temp/$INPUT-timedout-id-query


# Keep queries, with their times, that executed
cat $INPUT_TIME | grep Execution | colrm 1 148 | sed -e 's/Run\: //g' | sed -e 's/Source Selection Time\: //g' | sed -e 's/Compile Time\: //g' | sed -e 's/Sources\: //g' | sed -e 's/Execution time\: //g' > temp/$INPUT-exec


# Keep queries, with their number of results
cat $INPUT | grep Results | colrm 1 145 | sed -e 's/Run\: //g' | sed -e 's/Query Evaluation Time\: //g' | sed -e 's/Results\: //g' > temp/$INPUT-res


# Keep queries, with their times, that timed-out 
awk 'FNR==NR { id[$1]=$3" "$4" "$5; next } { split($1,a,"-"); if (a[1] in id) $1=id[a[1]]; print }' temp/$INPUT-timedout-id-query temp/$INPUT-timedout-id-time > temp/$INPUT-timedout


# Keep queries, with their times and number of results, that executed 
awk 'FNR==NR { id[$1]=$6 FS $7; next }{ print $0, id[$1] }' temp/$INPUT-res temp/$INPUT-exec > temp/$INPUT-executed


# Unite all runs (executed and timed-out)
cat temp/$INPUT-executed > csv/$INPUT.csv
cat temp/$INPUT-timedout >> csv/$INPUT.csv
