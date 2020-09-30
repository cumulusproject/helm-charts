#!/bin/bash

if [ "$#" -lt "1" ]; then
    echo "must specify chart directory"
    exit 1
fi

set -x
set -e

chart=$1

owner=${GITHUB_USER:-cumulusproject}
repo=${GITHUB_REPO:-helm-charts}
branch=${GITHUB_BRANCH:-gh-pages}
token=${CH_TOKEN}

rm -rf build/release

# Create a fresh clone of the repository
git clone --branch master git@github.com:$owner/$repo.git build/release

cd build/release

# Package the Helm chart
helm package $chart --dependency-update --destination package

# Upload the Helm chart release
cr upload \
    --owner $owner \
    --git-repo $repo \
    --package-path package \
    --token $token

# Switch to the gh-pages branch
git checkout gh-pages

# Update the repository index
cr index \
    --index-path index.yaml \
    --owner $owner \
    --git-repo $repo \
    --charts-repo https://raw.githubusercontent.com/$owner/$repo/$branch \
    --package-path package \
    --token $token

# Commit the updated index.yaml and on to README

#go run github.com/cumulusproject/helm-charts/build/cmd/index2md > README.md
git add index.yaml #README.md
git commit -m "Add $chart release to index.yaml" index.yaml #README.md
git push origin gh-pages

git checkout master

cd ../..

rm -rf build/release
