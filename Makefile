SHELL=/bin/bash
include .env
git_user != git config user.name
nsname=http://$(NS_DOMAIN)/\#$(NAME)
title != echo $(TITLE)
include inc/repo.mk inc/expath-pkg.mk
.PHONY: all
all: build

.PHONY: test
test: compile-test
	@prove -v bin/xQtest

.PHONY: clean
clean:
	@rm -rfv tmp
	@rm -rfv build
	@rm -rfv deploy

.PHONY: up
up: 
	@echo -e '##[ $@ ]##'
	@bin/exStartUp

.PHONY: down
down:
	@echo -e '##[ $@ ]##'
	@docker-compose down

.PHONY: compile-main
compile-main: content/${NAME}.xqm
	@echo '##[ $@  $< ]##'
	@mkdir -p tmp
	@bin/xQcompile $<

.PHONY: compile-test
compile-test: unit-tests/t-${NAME}.xqm
	@#' that will not compile unless ${NAME}.xqm is deployed '
	@echo '##[ $@  $< ]##'
	@mkdir -p tmp
	@bin/xQcompile $< | grep -oP '^INFO:(.+)OK!$$' \
 || ( bin/xQcompile $< ; false )

build/repo.xml: export repoXML:=$(repoXML)
build/repo.xml:
	@echo '##[ $@ ]##'
	@echo "$${repoXML}"
	@mkdir -p $(dir $@)
	@echo "$${repoXML}" > $@

build/expath-pkg.xml: export expathPkgXML:=$(expathPkgXML)
build/expath-pkg.xml:
	@echo '##[ $@ ]##'
	@echo "$${expathPkgXML}" 
	@mkdir -p $(dir $@)
	@echo "$${expathPkgXML}" > $@

build/content/$(NAME).xqm: content/$(NAME).xqm
	@echo '##[ $@ ]##'
	@mkdir -p $(dir $@)
	@cp $< $@

deploy/$(NAME).xar: \
 build/repo.xml \
 build/expath-pkg.xml \
 build/content/$(NAME).xqm
	@echo '##[ $@ ]## '
	@mkdir -p $(dir $@)
	@cd build && zip $(abspath $@) -r .

.PHONY: build
build: compile-main deploy/$(NAME).xar
	@echo '##[ $@ ]##'
	@bin/xQdeploy deploy/$(NAME).xar
	@bin/semVer patch
	@touch unit-tests/t-$(NAME).xqm

.PHONY: reset
reset:
	@echo '##[ $@ ]##'
	@git describe --abbrev=0 --tag
	@# git describe --tags $(git rev-list --tags --max-count=1)
	@echo 'revert .env VERSION to current tag' 
	@source .env; sed -i "s/^VERSION=$${VERSION}/VERSION=$(shell git describe --abbrev=0 --tag )/" .env

.PHONY: prep-release
prep-release:
	@echo '##[ $@ ]##'
	@echo -n "current latest tag: " 
	@git describe --abbrev=0 --tag
	@# git describe --tags $(git rev-list --tags --max-count=1)
	@echo 'revert .env VERSION to current tag' 
	@sed -i "s/$(shell grep  -oP '^VERSION=(.+)' .env)/VERSION=$(shell git describe --abbrev=0 --tag )/" .env
	@echo -n ' - bump the version: ' 
	@bin/semVer patch
	@grep -oP '^VERSION=\K(.+)$$' .env
	@echo ' - do a build from the current tag' 
	@$(MAKE) clean --silent
	@$(MAKE) --silent
	@grep -oP '^VERSION=v\K(.+)$$' .env
	@echo $$(grep -oP 'version="\K((\d+\.){2}\d+)' build/expath-pkg.xml)
	@echo 'v$(shell grep -oP 'version="\K((\d+\.){2}\d+)' build/expath-pkg.xml)'

.PHONY: push-release
push-release:
	@git tag v$(shell grep -oP 'version="\K((\d+\.){2}\d+)' build/expath-pkg.xml)
	@git push origin  v$(shell grep -oP 'version="\K((\d+\.){2}\d+)' build/expath-pkg.xml)

# https://docs.travis-ci.com/user/deployment/releases
.PHONY: travis-setup-releases
travis-setup-releases:
	@echo '##[ $@ ]##'
	@travis setup releases
	@#travis encrypt TOKEN="$$(<../.myJWT)" --add 

.PHONY: gitLog
gitLog:
	@clear
	@git --no-pager log \
  -n 10\
 --pretty=format:'%Cred%h%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'

.PHONY: smoke
smoke: 
	@echo '##[ $@ ]##'
	@bin/xQcall 'oAuth1:example()' \
 | grep -oP '^\s-\s(\w|-)(.+)$$'
	@bin/xQcall 'oAuth1:example()' \
 | grep -oP '^OAuth(.+)$$'

.PHONY: coverage
coverage: 
	@echo '##[ $@ ]##'
	@$(MAKE) down --silent
	@$(MAKE) up --silent
	@$(MAKE) --silent
	@bin/xQcall 'system:enable-tracing(true())'
	@bin/xQcall 'oAuth1:example()' &>/dev/null
	@bin/xQcall 'system:enable-tracing(false())'
	@bin/xQtrace

.PHONY: rec-test
rec-test:
	asciinema rec tmp/oAuth1.cast \
 --overwrite \
 --title='grantmacken/oAuth1 run `make test && make smoke && make coverage`  '\
 --command='make test --silent && make smoke --silent && make coverage --silent '

.PHONY: rec-smoke
rec-smoke:
	asciinema rec tmp/oAuth1.cast --overwrite --title='grantmacken/oAuth1 run `make smoke`  ' --command='make smoke --silent'

PHONY: play
play:
	asciinema play tmp/oAuth1.cast

.PHONY: upload
upload:
	asciinema upload tmp/oAuth1.cast
