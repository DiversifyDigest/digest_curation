#automate digest curation from alert emails

date=$(date +"%F")

cd ~/digest_curation #enables me to begin the script from any folder

Rscript code/generate_md.R $date #begin the script to curate papers & generate markdown

echo "output/digest_$date.md created"