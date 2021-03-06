npmbin := $(shell npm bin)

all: lint lib yaml attributions docs
	npm test

yaml: data/holidays.json

data/holidays.json: data/countries/*.yaml data/names.yaml
	npm run yaml

lib: src/*
	npm run transpile

test: v8. v10. v11.

v%:
	n $@ && npm test

dist:
	npm run webpack

docs: tree README.md
	npx markedpp --githubid -i docs/specification.md -o docs/specification.md
	npx markedpp --githubid -i README.md -o README.md

lint:
	npm run lint

tree: yaml
	node scripts/addtree.js

writetests: yaml
	$(npmbin)/mocha test/all.mocha.js --writetests

attributions: LICENSE

gitChanges:
	@git diff-files --quiet # fail if unstaged changes
	@git diff-index --quiet HEAD # fail if uncommited changes

gh-pages: gitChanges
	git branch -f gh-pages
	git checkout gh-pages
	git reset --hard master
	cp -r examples/browser/index* .
	git add .
	git commit -a -m 'build(gh-pages): update'
	git checkout master

push: gitChanges
	git push origin master
	git push origin gh-pages -f

LICENSE: data/countries/*.yaml
	node scripts/attributions.js

.PHONY: all doc lint test tree writetests yaml dist gitChanges gh-pages push
