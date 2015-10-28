#/***************************************************************************
# styleLoad
#
# Laad een gepredefineerde stijl.
#							 -------------------
#		begin				: 2015-10-27
#		git sha				: $Format:%H$
#		copyright			: (C) 2015 by Kay Warrie
#		email				: kaywarrie@gmail.com
# ***************************************************************************/
#
#/***************************************************************************
# *																		 *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or	 *
# *   (at your option) any later version.								   *
# *																		 *
# ***************************************************************************/

#################################################
# Edit the following to match your sources lists
#################################################


#Add iso code for any locales you want to support here (space separated)
# default is no locales
# LOCALES = af
LOCALES =

# translation
SOURCES = \
	__init__.py settings.py \
	styleLoad.py styleLoadWgt.py

PLUGINNAME = styleLoad

PY_FILES = \
	__init__.py settings.py \
	styleLoad.py styleLoadWgt.py

UI_FILES = ui_styleLoadWgt.py

EXTRAS = metadata.txt images

RESOURCE_FILES = resources_rc.py

HELP = help/build/html

PLUGIN_UPLOAD = $(c)/scripts/plugin_upload.py

QGISDIR=.qgis2

default: compile

compile: $(UI_FILES) $(RESOURCE_FILES)

%_rc.py : %.qrc
	pyrcc4 -o $*_rc.py  $<

%.py : %.ui
	#pyuic4 -o $@ $<
	python C:\OSGeo4W64\apps\Python27\lib\site-packages\PyQt4\uic\pyuic.py -o $@ $<

deploy: compile transcompile
	# The deploy  target only works on unix like operating system where
	# the Python plugin directory is located at:
	# $HOME/$(QGISDIR)/python/plugins
	if [ -d "$(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)" ]; then rm -r $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME); fi
	mkdir -p $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)
	cp -vf $(PY_FILES) $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)
	cp -vf $(UI_FILES) $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)
	cp -vf $(RESOURCE_FILES) $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)
	cp -vfr $(EXTRAS) $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)
	cp -vfr i18n $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)

# The dclean target removes compiled python files from plugin directory
# also deletes any .git entry
dclean:
	find $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME) -iname "*.pyc" -delete
	find $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME) -iname ".git" -prune -exec rm -Rf {} \;

derase:
	rm -Rf $(HOME)/$(QGISDIR)/python/plugins/$(PLUGINNAME)

zip: deploy dclean
	# The zip target deploys the plugin and creates a zip file with the deployed
	# content. You can then upload the zip file on http://plugins.qgis.org
	rm -f build/$(PLUGINNAME).zip
	cd $(HOME)/$(QGISDIR)/python/plugins; zip -9r $(CURDIR)/build/$(PLUGINNAME).zip $(PLUGINNAME)

package: compile
	# Create a zip package of the plugin named $(PLUGINNAME).zip.
	# This requires use of git (your plugin development directory must be a
	# git repository).
	# To use, pass a valid commit or tag as follows:
	#   make package VERSION=Version_0.3.2
	rm -f $(PLUGINNAME).zip
	git archive --prefix=$(PLUGINNAME)/ -o $(PLUGINNAME).zip $(VERSION)
	echo "Created package: $(PLUGINNAME).zip"

upload: zip
	$(PLUGIN_UPLOAD) $(PLUGINNAME).zip

transup:
	@chmod +x scripts/update-strings.sh
	@scripts/update-strings.sh $(LOCALES)

transcompile:
	@chmod +x scripts/compile-strings.sh
	@scripts/compile-strings.sh lrelease $(LOCALES)

transclean:
	rm -f i18n/*.qm

clean:
	rm $(UI_FILES) $(RESOURCE_FILES)