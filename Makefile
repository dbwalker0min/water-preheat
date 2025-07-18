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
FIRMWARE_BIN_MARKER=$(FIRMWARE_DIR)/bin/firmware-build-stamp
ifeq ($(OS),Windows_NT)
  PLATFORM=windows
else
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S),Linux)
    PLATFORM=linux
  else ifeq ($(UNAME_S),Darwin)
    PLATFORM=darwin
  else
    PLATFORM=unknown
  endif
endif
LUACROSS_BIN=$(TOOLS_DIR)/luac.cross

ifeq ($(OS),Windows_NT)
TOUCH = cmd /c type nul >
COPY_FIRMWARE = powershell -Command "$$f = Get-ChildItem -Path '$(FIRMWARE_DIR)/bin' -Filter 'nodemcu_*.bin' | Sort-Object LastWriteTime -Descending | Select-Object -First 1; Write-Output \"$$f\"; if ($$f) { Copy-Item $$f.FullName -Destination '$(TOOLS_DIR)/firmware-latest.bin' }"
COPY_LUACROSS = powershell -Command "$$f = Get-ChildItem -Path '$(FIRMWARE_DIR)' -Filter 'luac.cross*' | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if ($$f) { Copy-Item $$f.FullName -Destination '$(LUACROSS_BIN)' }"
else
TOUCH = touch
COPY_FIRMWARE = mkdir -p $(TOOLS_DIR); LATEST_FIRMWARE=$$(ls -t $(FIRMWARE_DIR)/bin/nodemcu-master-*.bin 2>/dev/null | head -n1); [ -n "$$LATEST_FIRMWARE" ] && cp $$LATEST_FIRMWARE $(TOOLS_DIR)/firmware-latest.bin
COPY_LUACROSS = LATEST_CROSS=$$(ls -t $(FIRMWARE_DIR)/luac.cross* 2>/dev/null | head -n1); [ -n "$$LATEST_CROSS" ] && cp $$LATEST_CROSS $(LUACROSS_BIN)
endif

all: compile

firmware: build-firmware copy-firmware

$(FIRMWARE_DIR):
	git clone --branch release --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git $(FIRMWARE_DIR)

$(FIRMWARE_BIN_MARKER): $(FIRMWARE_DIR) $(USER_CONFIG) $(USER_MODULES)
	docker run --rm -ti \
	  -v $(abspath $(FIRMWARE_DIR)):/opt/nodemcu-firmware \
	  -v $(abspath $(USER_CONFIG)):/opt/nodemcu-firmware/app/include/user_config.h:ro \
	  -v $(abspath $(USER_MODULES)):/opt/nodemcu-firmware/app/include/user_modules.h:ro \
	  marcelstoer/nodemcu-build build
	$(TOUCH) $(FIRMWARE_BIN_MARKER)

build-firmware: $(FIRMWARE_BIN_MARKER)

copy-firmware:
	@$(COPY_FIRMWARE)
 
copy-luacross:
	@$(COPY_LUACROSS)
	chmod +x $(LUACROSS_BIN)

compile: $(LC_FILES)

$(BUILD_DIR)/%.lc: $(SRC_DIR)/%.lua
	docker run --rm \
	  -v $(abspath $(SRC_DIR)):/src:ro \
	  -v $(abspath $(BUILD_DIR)):/build \
	  -v $(abspath $(TOOLS_DIR)):/tools:ro \
	  debian:bookworm-slim \
	  /tools/luac.cross.linux -o /build/$*.lc /src/$*.lua

upload:
	uvx nodemcu-uploader --port $(PORT) upload $(LC_FILES)

repl:
	uvx nodemcu-uploader --port $(PORT) terminal

clean:
	rm -rf $(BUILD_DIR)/*.lc $(FIRMWARE_BIN_MARKER) $(LUACROSS_BIN) $(TOOLS_DIR)/firmware-latest.bin

