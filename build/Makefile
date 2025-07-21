# This makefile is run in the containter to build the .lc files

SRC_DIR := /src
BUILD_DIR := /build

RESOURCE_SRC_DIR := /resources
RESOURCE_GEN := $(SRC_DIR)/resource.lua
MAKE_RESOURCE := /fw/lua_modules/file_lfs/make_resource.lua

# Generate resource.lua from resources/*
$(RESOURCE_GEN): $(wildcard $(RESOURCE_SRC_DIR)/*)
	lua $(MAKE_RESOURCE) -o /src/resources.lua $^

