#!/bin/bash 
echo "Hello, World"
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

convert -quality 100 ./${terms//[[:space:]]}count.pdf `echo ${terms//[[:space:]]}count.pdf | sed -e 's/\.pdf/\.jpg/g'`

convert -quality 100 ./${terms//[[:space:]]}normalized.pdf `echo ${terms//[[:space:]]}normalized.pdf | sed -e 's/\.pdf/\.jpg/g'`
