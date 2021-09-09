#automate digest curation from alert emails -- runs every M & R at 8am w/ cron

date=$(date +"%F")

cd ~/digest_curation #enables me to begin the script from any folder

Rscript code/generate_md.R $date #begin the script to curate papers & generate markdown