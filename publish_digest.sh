
######################################################
#Generate the folder for the new post on the website
#######################################################

date=$(date +"%F")

cd ~/DiversifyDigest_wowchemy_repo #move to the website repo

hugo new --kind publication digest/digest_$date #create folder for the new digest

cp ../digest_curation/output/digest_$date.md content/digest/digest_$date/index.md #move the markdown template to the website folder and rename to overwrite the existing md file

git status #check addition of new file

git add .

git commit -m "add new digest"

######################################################
#Rebuild the webpage & publish
#######################################################

hugo #rebuild website

cd public

git status #check rebuild

git add . 

git commit -m "rebuild with new digest"

git push origin master #push new digest to the website

echo "digest_$date published"

######################################################
#Setup and trigger automatic tweets
#######################################################

cd ~/digest_curation

git pull #prevent merge conflicts in csv of tweet links

Rscript code/get_article_links.R #run the code to randomly select links to tweet for the next week

git add .

git commit -m "generate digest md"

git push origin master #push raw digest data to trigger git hub action & tweet the digest link
