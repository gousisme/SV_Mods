#!/bin/bash
git fetch origin
git checkout --ours .
git merge --strategy=ours origin/main
chmod +x "$0"