# This makefile is run in the containter to build the .lc files

SRC_DIR := /src
BUILD_DIR := /build
LUAC := /tools/luac.cross.linux.x86_64  # or arm64

LUA_FILES := $(wildcard $(SRC_DIR)/*.lua)
LC_FILES := $(patsubst $(SRC_DIR)/%.lua,$(BUILD_DIR)/%.lc,$(LUA_FILES))

RESOURCE_SRC_DIR := /resources
RESOURCE_GEN := $(BUILD_DIR)/resource.lua
RESOURCE_COMPILED := $(BUILD_DIR)/resource.lc
MAKE_RESOURCE := /fw/lua_modules/file_lfs/make_resource.lua

all: $(LC_FILES) $(RESOURCE_COMPILED)

# Normal .lua → .lc compilation
$(BUILD_DIR)/%.lc: $(SRC_DIR)/%.lua
	$(LUAC) -o $@ $<

# Generate resource.lua from resources/*
$(RESOURCE_GEN): $(wildcard $(RESOURCE_SRC_DIR)/*)
	lua $(MAKE_RESOURCE) $^ > $@

# Compile resource.lua into resource.lc
$(RESOURCE_COMPILED): $(RESOURCE_GEN)
	$(LUAC) -o $@ $<
