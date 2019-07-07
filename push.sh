#ref: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
RED='\033[0;31m'
NC='\033[0m' 

# git add --all
# git commit -a -m $1
echo -e "${RED}push to origin${NC}"
git push origin master
echo -e "${RED}push to gitlab${NC}"
git push gitlab master
echo -e "${RED}push to github${NC}"
git push github master
echo -e "${RED}push to oschina${NC}"
git push oschina master
