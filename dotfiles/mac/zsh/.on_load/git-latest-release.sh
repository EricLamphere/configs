#!/bin/bash

release_branches=$(git lb "*origin/release/v*" | sed 's/v\./v/g' | sort -Vr)
set -- $release_branches
latest=$1

prefix="remotes/origin/"
res=${latest//"$prefix"}
echo $res

