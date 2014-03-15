#!/bin/bash

gulp build
MESSAGE=$(git log -1 HEAD --pretty=format:%s)
cd public
git add --all .
git commit -m "$MESSAGE"
git push origin gh-pages
cd ..
