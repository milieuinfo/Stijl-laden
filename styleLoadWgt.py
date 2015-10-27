# -*- coding: utf-8 -*-
"""
/***************************************************************************
 styleLoadDockWidget
                                 A QGIS plugin
 Laad een gepredefineerde stijl.
                             -------------------
        begin                : 2015-10-27
        git sha              : $Format:%H$
        copyright            : (C) 2015 by Kay Warrie
        email                : kaywarrie@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""

import os, sys, glob
from PyQt4 import QtGui, QtCore
from qgis.core import *
from settings import settings
from ui_styleLoadWgt import Ui_styleLoadWgt

class styleLoadDockWidget(QtGui.QDockWidget):
    closingPlugin = QtCore.pyqtSignal()
    def __init__(self, iface, parent=None):
        super(styleLoadDockWidget, self).__init__(parent)
        self.setWindowFlags( self.windowFlags() & ~QtCore.Qt.WindowContextHelpButtonHint )

        # initialize locale
        locale = QtCore.QSettings().value("locale/userLocale", "ln")[0:2]

        localePath = os.path.join(os.path.dirname(__file__), 'i18n', '{}.qm'.format(locale))
        if os.path.exists(localePath):
            self.translator = QtCore.QTranslator()
            self.translator.load(localePath)
            QtCore.QCoreApplication.installTranslator(self.translator)

        self.iface = iface
        self._initGui()

    def _initGui(self):
       self.ui = Ui_styleLoadWgt()
       self.ui.setupUi(self)

       self.refreshContent()
       self.ui.commitBtn.clicked.connect( self.commitBtnClicked )
       self.ui.setSourceBtn.clicked.connect(self.saveSource)
       self.iface.mapCanvas().layersChanged.connect(self.refreshContent)

    def commitBtnClicked(self):
       lyrIdx = self.ui.layerCbx.currentIndex()
       mapLayer = self.mapLayers.values()[lyrIdx]
       if len( self.ui.qmlList.selectedItems() ):
           qmlItem = self.ui.qmlList.selectedItems()[0]
           qmlPath = os.path.join( self.s.qmlDir , qmlItem.text() )
       else:
           return

       mapLayer.loadNamedStyle( qmlPath )

       self.refreshContent()

    def refreshContent(self):
       self.s = settings()

       self.styles = glob.glob( os.path.join( self.s.qmlDir, "*.qml" ))
       self.mapLayers = QgsMapLayerRegistry.instance().mapLayers()

       self.ui.layerCbx.clear()
       self.ui.layerCbx.insertItems(0, [ l.name() for l in self.mapLayers.values()])
       self.ui.qmlList.clear()
       self.ui.qmlList.insertItems(0, [os.path.split(n)[1] for n in self.styles])
       self.iface.mapCanvas().refreshAllLayers()

    def closeEvent(self, event):
        self.closingPlugin.emit()
        event.accept()

    def saveSource( self ):
        Fdlg = QtGui.QFileDialog()
        home = os.path.expanduser("~")
        fName = Fdlg.getExistingDirectory( self, "Open Folder", directory=home )
        if fName:
            self.s.qmlDir = fName
            self.s.saveSettings()
            self.refreshContent()
