#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

echo "Creating Docs for the NACC App\n"
rm -drf docs/*

jazzy  --readme ./README.md \
       --build-tool-arguments -scheme,"NACC",-target,"NACC" \
       --github_url https://github.com/LittleGreenViper/NACC \
       --title "NACC Doumentation" \
       --min_acl private \
       --theme fullwidth
cp ./icon.png docs/
cp ./img/* docs/img
