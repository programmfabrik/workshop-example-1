PLUGIN_NAME = workshop-example-1
PLUGIN_PATH = workshop-example-1

INSTALL_FILES = \
    $(WEB)/l10n/cultures.json \
    $(WEB)/l10n/de-DE.json \
    $(CSS) \
    /l10n/en-US.json \
	$(WEB)/workshop-plugin.1.js \
	$(WEB)/workshop-example-1.html \
	manifest.yml

L10N_FILES = l10n/workshop-1-plugin.csv

SCSS_FILES = src/webfrontend/workshop-plugin.1.scss

COFFEE_FILES = \
    src/webfrontend/workshopRootApp.coffee \

HTML_FILES = workshop-example-1.html

all: build

include easydb-library/tools/base-plugins.make


build: code css
	for file in $(HTML_FILES); do cp src/webfrontend/$$file build/webfrontend/$$file; done

code: $(JS) $(L10N)

clean: clean-base