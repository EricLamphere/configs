#!/bin/bash

release_branches=$(git lb "*origin/release/v*" | sort -Vr)
set -- $release_branches
latest=$1

prefix="remotes/origin/"
res=${latest//"$prefix"}
echo $res

