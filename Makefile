COFFEE_FILES_WEB = \
    src/webfrontend/js/RootApp.coffee \

JS_WEB = build/workshop/webfrontend/workshop.js

PLUGIN_NAME = workshop
ZIP_NAME ?= $(PLUGIN_NAME).zip
BUILD_DIR = build

## Style Files
SCSS_FILES = src/webfrontend/scss/main.scss

## HTML Files
HTML_FILES = \
    src/webfrontend/html/workshop.html \

## L10N
L10N_DIR = $(BUILD_DIR)/$(PLUGIN_NAME)/l10n
L10N_CSV_FILE = src/l10n/workshop.csv

all: build ## build all

loca:
	mkdir -p $(L10N_DIR)
	cp $(L10N_CSV_FILE) $(L10N_DIR)

build: clean code css loca ## build all (creates build folder)
	mkdir -p $(BUILD_DIR)/$(PLUGIN_NAME)
	cp manifest.master.yml $(BUILD_DIR)/$(PLUGIN_NAME)/manifest.yml

code: $(JS_WEB) concat-html ## build Coffeescript

zip: build ## build zip file for publishing
	cd $(BUILD_DIR) && zip $(ZIP_NAME) -r $(PLUGIN_NAME)

clean: ## clean build files
	rm -f $(JS)
	rm -rf $(BUILD_DIR)

${JS_WEB}: $(subst .coffee,.coffee.js,${COFFEE_FILES_WEB})
	mkdir -p $(dir $@)
	cat $^ > $@

%.coffee.js: %.coffee
	coffee -b -p --compile "$^" > "$@" || ( rm -f "$@" ; false )

concat-html: ## Concatenate HTML files
	cat $(HTML_FILES) > $(BUILD_DIR)/$(PLUGIN_NAME)/webfrontend/workshop.html

css: ## Compile SASS to CSS
	sass $(SCSS_FILES):$(BUILD_DIR)/$(PLUGIN_NAME)/webfrontend/workshop.css
