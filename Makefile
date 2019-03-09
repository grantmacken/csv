SHELL=/bin/bash
LAST_TAG_COMMIT = $(shell git rev-list --tags --max-count=1)
LAST_TAG = $(shell git describe --tags $(LAST_TAG_COMMIT) )
TAG_PREFIX = "v"

VERSION != grep -oP '^v\K(.+)$$' VERSION
include .env

git_user != git config user.name
nsname=http://$(NS_DOMAIN)/\#$(NAME)
title != echo $(TITLE)
include inc/*

.PHONY: default
default: clean compile-main build

build: deploy/$(NAME).xar
	@echo '##[ $@ ]##'
	@bin/xQdeploy $<
	@bin/semVer $(VERSION) patch > VERSION
	@#touch unit-tests/t-$(NAME).xqm
	@echo -n 'INFO: prepped for next build: ' && cat VERSION

.PHONY: test
test: compile-test
	@prove -v bin/xQtest

.PHONY: clean
clean:
	@rm -rfv tmp &>/dev/null
	@rm -rfv build &>/dev/null
	@rm -rfv deploy &>/dev/null

.PHONY: up
up: clean
	@echo -e '##[ $@ ]##'
	@bin/exStartUp
	@touch VERSION && echo 'v0.0.1' > VERSION

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

.PHONY: prep-release
prep-release:
	@echo '##[ $@ ]##'
	@echo ' - working VERSION: $(VERSION) ' 
	@echo ' -        last tag: $(LAST_TAG)' 
	@if [ -z '$(LAST_TAG)' ] ; \
 then echo 'v0.0.0' > VERSION ; \
 else echo '$(LAST_TAG)' > VERSION ; fi 
	@bin/semVer $$(< ./VERSION) patch > VERSION
	@echo " -  bumped VERSION: $$(< ./VERSION) " 
	@echo ' - do a build from the bumped version' 
	@$(MAKE) --silent
	@echo -n ' - expath-pkg version: ' 
	@grep -oP 'version="\K((\d+\.){2}\d+)' build/expath-pkg.xml

.PHONY: release
release:
	@git tag v$$(grep -oP 'version="\K((\d+\.){2}\d+)' build/expath-pkg.xml)
	@git push origin  v$$(grep -oP 'version="\K((\d+\.){2}\d+)' build/expath-pkg.xml)

.PHONY: log
log:
	@docker logs -f --since 1m $(CONTAINER)

.PHONY: travis-enable
travis-enable:
	@echo '##[ $@ ]##'
	@travis enable

# https://docs.travis-ci.com/user/deployment/releases
.PHONY: travis-setup-releases
travis-setup-releases:
	@echo '##[ $@ ]##'
	@travis setup releases

.PHONY: gitLog
gitLog:
	@clear
	@git --no-pager log \
  -n 10\
 --pretty=format:'%Cred%h%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'

.PHONY: smoke
smoke: 
	@echo '##[ $@ ]##'
	@bin/xQcall 'csv:example()' \
 | grep -oP '^(\d{4}(.+))|(.+\.\d{2})|(\s+)$$'

.PHONY: coverage
coverage: 
	@echo '##[ $@ ]##'
	@bin/xQcall 'system:clear-trace()'  &>/dev/null
	@bin/xQcall 'system:enable-tracing(true())'  &>/dev/null
	@bin/xQcall 'csv:example()' &>/dev/null
	@bin/xQcall 'system:enable-tracing(false())' &>/dev/null
	@bin/xQtrace

.PHONY: guide
guide: 
	@echo '##[ $@ ]##'
	@bin/xQguide

.PHONY: rec
rec:
	@mkdir ../tmp
	@asciinema rec ../tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv ran `make up'\
 --idle-time-limit 1 \
 --command='nvim'

.PHONY: rec-example
rec-example:
	@mkdir -p ../tmp
	@clear
	@asciinema rec ../tmp/csv.cast \
 --overwrite \
 --title="grantmacken/csv called 'csv:example()'" \
 --command="\
sleep 1 && printf %60s | tr ' ' '='  && echo && \
echo ' - given this csv file ... ' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
cat unit-tests/fixtures/2018-12.csv && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - when we provide mapped key-values ..'  && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo 'map {\"href\" : \"/db/unit-tests/fixtures/2018-12.csv\", ' && \
echo '     \"header-line\": 6,' && \
echo '     \"record-start\": 8,' && \
echo '     \"separator\": \",\"}' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
echo ' - then calling csv:example function results in... ' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
bin/xQcall 'csv:example()' && \
sleep 1 && printf %60s | tr ' ' '-'  && echo && \
sleep 1 && printf %60s | tr ' ' '='  && echo\
"


.PHONY: rec-up
rec-up:
	@asciinema rec tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv ran `make up'\
 --command='make up'

.PHONY: rec-build
rec-build:
	@clear
	@asciinema rec tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv ran `make'\
 --command='make'

.PHONY: rec-test
rec-test:
	@clear
	@asciinema rec tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv ran `make test'\
 --command='make test'

.PHONY: rec-smoke
rec-smoke:
	@clear
	@asciinema rec tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv ran `make smoke'\
 --command='make smoke'

.PHONY: rec-cov
rec-cov:
	@clear
	@asciinema rec tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv ran `make coverage'\
 --command='make coverage'

.PHONY: rec-guide
rec-guide:
	@clear
	@asciinema rec tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv ran `make guide'\
 --command='make guide'

.PHONY: rec-test-all
rec-test-all:
	asciinema rec tmp/csv.cast \
 --overwrite \
 --title='grantmacken/csv run `make test && make smoke && make coverage and make guide`'\
 --command='make test --silent && \
            make smoke --silent && \
            make coverage --silent && \
            make guide --silent'

PHONY: play
play:
	@clear && asciinema play ../tmp/csv.cast

.PHONY: upload
upload:
	asciinema upload ../tmp/csv.cast
