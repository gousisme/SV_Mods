@echo off
git fetch origin
git checkout --ours .
git merge --strategy=ours origin/main
pause
