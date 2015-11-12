SHELL = /bin/bash

VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null)+$(shell git rev-parse --short HEAD)
export GO15VENDOREXPERIMENT=1

GO = go
GOFMT = gofmt -l
GOLINT = golint
GOTEST = $(GO) test --cover --race -v
GOVET = $(GO) vet

SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
DOCKER_HOST = $(shell echo $$DOCKER_HOST)
REGISTRY = $(shell if [ "$$DEV_REGISTRY" == "registry.hub.docker.com" ]; then echo; else echo $$DEV_REGISTRY/; fi)
GIT_SHA = $(shell git rev-parse --short HEAD)

ifndef IMAGE_PREFIX
  IMAGE_PREFIX = deis/
endif

ifndef BUILD_TAG
  BUILD_TAG = git-$(GIT_SHA)
endif

ifndef S3_BUCKET
  S3_BUCKET = deis-updates
endif

define echo_cyan
  @echo "\033[0;36m$(subst ",,$(1))\033[0m"
endef

define echo_yellow
  @echo "\033[0;33m$(subst ",,$(1))\033[0m"
endef

check-docker:
	@if [ -z $$(which docker) ]; then \
	  echo "Missing \`docker\` client which is required for development"; \
	  exit 2; \
	fi

check-registry:
	@if [ -z "$$DEV_REGISTRY" ]; then \
	  echo "DEV_REGISTRY is not exported, try:  make dev-registry"; \
	exit 2; \
	fi

define check-static-binary
  if file $(1) | egrep -q "(statically linked|Mach-O)"; then \
    echo -n ""; \
  else \
    echo "The binary file $(1) is not statically linked. Build canceled"; \
    exit 1; \
  fi
endef
