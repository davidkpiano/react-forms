BIN           = ./node_modules/.bin
TESTS         = $(shell find ./src -path '**/__tests__/*-test.js')
SRC           = $(shell find ./src -name '*.js' -not -path '*/__tests__/*')
NODE          = $(BIN)/babel-node $(BABEL_OPTIONS)
MOCHA_OPTIONS = --compilers js:babel/register --require ./src/__tests__/setup.js
MOCHA         = NODE_ENV=test node $(BIN)/mocha $(MOCHA_OPTIONS)
VERSION       = $(shell node -e 'console.log(require("./package.json").version)')

build:
	@$(BIN)/webpack --config webpack.build.config.js

watch:
	@$(BIN)/webpack --config webpack.build.config.js --watch

lint::
	@$(BIN)/eslint $(SRC)

test::
	@$(MOCHA) -- $(TESTS)

ci:
	@$(MOCHA) --watch -- $(TESTS)

version-major version-minor version-patch: lint test build
	@npm version $(@:version-%=%)

_publish-git:
	git tag $(VERSION)
	git push --tags origin HEAD:develop

_publish-beta-npm: build
	npm publish --tag beta

publish: _publish-git _publish-beta-npm

clean:
	@rm -rf lib/
