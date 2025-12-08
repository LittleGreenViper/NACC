#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

cp ./icon.png docs

echo "Creating Docs for the NACC App\n"
rm -drf docs/mainapp/*

jazzy  --readme ./README.md \
       --build-tool-arguments -scheme,"Main App Target",-target,"Main App Target" \
       --github_url https://github.com/LittleGreenViper/NACC/tree/master/Sources/NACC \
       --title "NACC App Doumentation" \
       --min_acl private \
       --output docs/mainapp \
       --theme fullwidth

cp ./icon.png docs/mainapp/
cp ./img/* docs/mainapp/img

echo "Creating Docs for the NACC Widget\n"
rm -drf docs/widget/*

jazzy  --readme ./Sources/NACCWidget/README.md \
       --build-tool-arguments -scheme,"Widget Target",-target,"Widget Target" \
       --github_url https://github.com/LittleGreenViper/NACC/tree/master/Sources/NACCWidget \
       --title "NACC Widget Doumentation" \
       --min_acl private \
       --output docs/widget \
       --theme fullwidth
cp ./icon.png docs/widget/
cp ./img/* docs/widget/img

echo "Creating Docs for the NACC Intents\n"
rm -drf docs/intent/*

jazzy  --readme ./Sources/NACCIntents/README.md \
       --build-tool-arguments -scheme,"Intents Target",-target,"Intents Target" \
       --github_url https://github.com/LittleGreenViper/NACC/tree/master/Sources/NACCIntents \
       --title "NACC Intents Doumentation" \
       --min_acl private \
       --output docs/intent \
       --theme fullwidth
cp ./icon.png docs/intent/
cp ./img/* docs/intent/img

echo "Creating Docs for the NACC Watch App\n"
rm -drf docs/watch/*

jazzy  --readme ./Sources/NACCWatch/README.md \
       --build-tool-arguments -scheme,"Watch Target",-target,"Watch Target" \
       --github_url https://github.com/LittleGreenViper/NACC/tree/master/Sources/NACCWatch \
       --title "NACC Watch App Doumentation" \
       --min_acl private \
       --output docs/watch \
       --theme fullwidth
cp ./icon.png docs/watch/
cp ./img/* docs/watch/img

echo "Creating Docs for the NACC Watch Complications\n"
rm -drf docs/complication/*

jazzy  --readme ./Sources/NACCWatchComplication/README.md \
       --build-tool-arguments -scheme,"Complications Target",-target,"Complications Target" \
       --github_url https://github.com/LittleGreenViper/NACC/tree/master/Sources/NACCWatchComplication \
       --title "NACC Watch Complication Doumentation" \
       --min_acl private \
       --output docs/complication \
       --theme fullwidth
cp ./icon.png docs/complication/
cp ./img/* docs/watch/img
