#!/bin/bash

git checkout main

# delete build folder
rm -rf _site/

# create a '_site' directory checked out to the gh-pages branch
git worktree add -B gh-pages _site

# build the project
docker run \
	-v ${GITHUB_WORKSPACE}:/srv/jekyll -v ${GITHUB_WORKSPACE}/_site \
        jekyll/builder:latest /bin/bash -c "chmod -R 777 /srv/jekyll && jekyll build --future"

# cd into build folder, which is now on the gh-pages branch
cd _site

# fail if for some reason this isn't the gh-pages branch
current_branch=$(git symbolic-ref --short -q HEAD)
if [ "$current_branch" != "gh-pages" ]; then
  echo "Expected build folder to be on gh-pages branch."
  exit 1
fi

# commit and push to gh-pages
git config --global user.name '${GITHUB_ACTOR}'
git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'
git add . && git commit -m "`date`"
#git remote set-url --push origin https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
git push --force --set-upstream origin gh-pages
