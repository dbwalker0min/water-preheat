# NodeMCU Lua Project Template (with Docker Build Support)

# Load environment from .env if it exists
-include .env

# ────────────────────────────────────────────────────────────────
# 🗂️ Structure:
#
# your-project/
# ├── firmware-config/
# │   ├── user_config.h          # Custom config (float/int, settings)
# │   └── user_modules.h         # Enabled Lua modules
# ├── src/
# │   ├── init.lua               # Your Lua app code
# ├── stub/                      # Lua stubs for VSCode IntelliSense
# │   ├── gpio.lua
# │   ├── tmr.lua
# │   ├── wifi.lua
# │   └── node.lua
# ├── Makefile                   # Automates build & upload
# ├── tools/                     # Stores host-specific luac.cross & firmware
# └── nodemcu-firmware/          # Git repo (NodeMCU source)
#
# ────────────────────────────────────────────────────────────────

# 📦 Setup Instructions:
#
# 1. Clone the firmware repo:
#    git clone --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git
#
# 2. Place your custom `user_config.h` and `user_modules.h` into `firmware-config/`
#    You can copy these from `nodemcu-firmware/app/include/` as a starting point
#
# 3. Place Lua source files into `src/`
#
# 4. Run `make firmware` to build firmware + luac.cross
# 5. Run `make compile` to compile .lua → .lc
# 6. Run `make upload` to flash .lc to ESP

# ────────────────────────────────────────────────────────────────

# Makefile

FIRMWARE_DIR=nodemcu-firmware
CONFIG_DIR=firmware-config
SRC_DIR=src
BUILD_DIR=build
TOOLS_DIR=tools
PORT?=COM3
USER_CONFIG=$(CONFIG_DIR)/user_config.h
USER_MODULES=$(CONFIG_DIR)/user_modules.h
LUA_FILES=$(wildcard $(SRC_DIR)/*.lua)
LC_FILES=$(patsubst $(SRC_DIR)/%.lua,$(BUILD_DIR)/%.lc,$(LUA_FILES))
FIRMWARE_BUILD_MARKER_NAME=firmware-build-stamp
FIRMWARE_BIN_MARKER=$(FIRMWARE_DIR)/bin/${FIRMWARE_BUILD_MARKER_NAME}
ARCH := $(shell docker version --format '{{.Server.Arch}}')
LUACROSS_BIN=$(TOOLS_DIR)/luac_cross_$(ARCH)
DOCKER_IMAGE_NAME=dbwalker/lua-compiler-devtool:latest
RESOURCE_DIR=resources

all: compile

firmware: build-firmware copy-artifacts

$(FIRMWARE_DIR):
	git clone --branch release --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git $(FIRMWARE_DIR)

	
$(FIRMWARE_BIN_MARKER): $(FIRMWARE_DIR) $(USER_CONFIG) $(USER_MODULES)
	docker run --rm -ti \
	  -v $(abspath $(FIRMWARE_DIR)):/opt/nodemcu-firmware \
	  -v $(abspath $(USER_CONFIG)):/opt/nodemcu-firmware/app/include/user_config.h:ro \
	  -v $(abspath $(USER_MODULES)):/opt/nodemcu-firmware/app/include/user_modules.h:ro \
	  marcelstoer/nodemcu-build /bin/sh -c "build && touch /opt/nodemcu-firmware/bin/$(FIRMWARE_BIN_MARKER_NAME)"

build-firmware: $(FIRMWARE_BIN_MARKER)

copy-artifacts:
	docker run --rm \
	  -v $(abspath $(FIRMWARE_DIR)):/fw:ro \
	  -v $(abspath $(TOOLS_DIR)):/tools \
	  debian:bookworm-slim \
	  /bin/sh -c "\
	    set -e; \
	    fw_file=$$(ls -t /fw/bin/nodemcu_*.bin | head -n1); \
	    cross_file=$$(ls -t /fw/luac.cross* | head -n1); \
	    cp $$fw_file /tools/firmware-latest.bin; \
	    cp $$cross_file /tools/luac.cross.linux.$(ARCH); \
	    echo 'Copied:'; \
	    echo '  Firmware ->' $$(basename $$fw_file); \
	    echo '  Luacross ->' $$(basename $$cross_file); \
	  "
 

compile: $(FIRMWARE_BIN_MARKER) 
	docker run --rm \
	  -v $(abspath $(SRC_DIR)):/src:ro \
	  -v $(abspath $(BUILD_DIR)):/build \
	  -v $(abspath $(TOOLS_DIR)):/tools:ro \
	  -v $(abspath $(RESOURCE_DIR)):/resources:ro \
	  $(DOCKER_IMAGE_NAME) \
	  make -C /build

upload:
	uvx nodemcu-uploader --port $(PORT) upload $(LC_FILES)

repl:
	uvx nodemcu-uploader --port $(PORT) terminal

clean:
	rm -rf $(BUILD_DIR)/*.lc $(FIRMWARE_BIN_MARKER) $(LUACROSS_BIN) $(TOOLS_DIR)/firmware-latest.bin

