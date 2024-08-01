#!/bin/bash

release_branches=$(git lb "*origin/release/v*")

sorted=$(echo $release_branches | sort -V)
set -- $sorted
latest=$1

prefix="remotes/origin/"
res=${latest//"$prefix"}
echo $res

