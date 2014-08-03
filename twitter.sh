#!/bin/bash 
terms=${@}
num=$#
CWD=$(pwd)

echo "Total number of search terms is $num"

# Iterate over companies and collect Twitter data
for var in "$@"
do
    echo "Search term is: $var"
    ruby twitter.rb "$var"
done

R --vanilla --args "$num" "$CWD/data/" "$terms" < twitter_graph.R > outfile.txt

sleep 10

# convert -quality 100 ./data/${terms//[[:space:]]}count.pdf `echo ./data/${/terms//[[:space:]]}count.pdf | sed -e 's/\.pdf/\.jpg/g'`

convert -quality 100 ./data/${terms//[[:space:]]}count.pdf `echo ./data/${terms//[[:space:]]}count.pdf | sed -e 's/\.pdf/\.jpg/g'`

convert -quality 100 ./data/${terms//[[:space:]]}normalized.pdf `echo ./data/${terms//[[:space:]]}normalized.pdf | sed -e 's/\.pdf/\.jpg/g'`
