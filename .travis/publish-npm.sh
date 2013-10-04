#!/bin/bash
if [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ]; then
	ref=$TRAVIS_BRANCH-`git log --pretty=format:%h -1`
	sed -ri 's/("version": "[[:digit:]]\.[[:digit:]]\.[[:digit:]]-).*/\1'$ref'",/' package.json
	echo -e "$NPM_USER\n$NPM_PASS\n$NPM_EMAIL" | npm adduser
	npm publish --tag dev
else
	echo 'Not publishing to npm...'
fi
