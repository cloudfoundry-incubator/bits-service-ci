#!/bin/bash -e

lock_name=${1:?"Missing lock name"}

echo Unlocking resource locked by ${lock_name}

git co metadata
git pull -r
mv locks/${lock_name}/claimed/* locks/${lock_name}/unclaimed/
git add locks/${lock_name}
git ci -m "Manually unlocking resource locked by ${lock_name}"
git push origin HEAD
git co -
