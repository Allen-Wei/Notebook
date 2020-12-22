#ref: https://stackoverflow.com/questions/17291995/push-existing-project-into-github
#git clone https://gitee.com/alanway/Notebook.git
git remote add gitlab git@gitlab.com:alanwei/notebook.git
git remote add github git@github.com:alanwei43/Notebook.git
git remote add oschina git@gitee.com:alanway/Notebook.git

git config --local --get-regexp remote.+