
help:                      ## Available make commands
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's~:~~' | sed -e 's~##~~'

usage: help         

build-dev:                 ## Build dev Docker image
	docker build -f Dockerfile --progress plain --target dev -t unfor19/sls-utils .

run-dev:                   ## Run dev Docker container
	docker run --rm -it -v "${HOME}/.aws/:/home/appuser/.aws:ro" -v "${PWD}/":/code/ --workdir=/code/ --entrypoint=bash unfor19/sls-utils

dev: build-dev run-dev     ## Build and Run dev Docker container
