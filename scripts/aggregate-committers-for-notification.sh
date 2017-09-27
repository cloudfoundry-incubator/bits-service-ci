#! /bin/bash -ex

for input in input*; do
    pushd $input
        if [ ! -e .git ]; then
            popd
            continue
        fi
        now=$(date +%s)
        commit_date=$(git show -s --format=%ct)
        time_since_commit=$((now-commit_date))
        # This is really just a heuristic:
        # commits older than 3 days are not responsible for a broken build
        if [ "$time_since_commit" -gt "259200" ]; then # 3 days = 3*24*60*60 seconds
            popd
            continue
        fi
        echo $(git show -s --format=%ce) >> ../points-of-contact/committers
        set +e
        git show --summary | grep 'On behalf of:' >> ../points-of-contact/committers
        set -e
    popd
done

# generate slack users from committer email addresses
cp points-of-contact/committers points-of-contact/slack-users
sed -e '/pego@de.ibm.com\|peter.gtz@gmail.com\|norman.sutorius@de.ibm.com\|Steffen.Uhlig@de.ibm.com\|EGURNOV@de.ibm.com/!d' -i points-of-contact/slack-users
sed -e s/pego@de.ibm.com/pego/gI -i points-of-contact/slack-users
sed -e s/peter.gtz@gmail.com/pego/gI -i points-of-contact/slack-users
sed -e s/norman.sutorius@de.ibm.com/norman/gI -i points-of-contact/slack-users
sed -e s/Steffen.Uhlig@de.ibm.com/suhlig/gI -i points-of-contact/slack-users
sed -e s/EGURNOV@de.ibm.com/egurnov/gI -i points-of-contact/slack-users
awk '{print "<@" $0 ">"}' points-of-contact/committers > points-of-contact/slack-users-with-at
mv points-of-contact/slack-users-with-at points-of-contact/slack-users

# Make slack users available in a single line:
tr '\n' ' ' < points-of-contact/slack-users > points-of-contact/slack-users-single-line
cat points-of-contact/slack-users-single-line
