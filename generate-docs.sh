echo "* Hard reset of docs branch"
pushd doc || exit
git fetch
git checkout docs
git reset --hard origin/docs
popd || exit

echo "* Compiling"
swift package \
    --allow-writing-to-directory ./docs \
    generate-documentation --target SwiftMETAR --output-path ./docs \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path SwiftMETAR

echo "* Copying to docs branch"
rsync -rv --delete --exclude=".git" --force docs/ doc/
rm -rf docs

pushd doc || exit
echo "* Committing docs"
git add -A
git commit -m "Documentation update, by $USER"
echo "* Pushing docs"
git push
popd || exit
