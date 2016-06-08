/***************************************************************************
                            qgismobileapp.qml
                              -------------------
              begin                : 10.12.2014
              copyright            : (C) 2014 by Matthias Kuhn
              email                : matthias (at) opengis.ch
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.4 as Controls
import QtQuick.Dialogs 1.2
import QtQml 2.2
import org.qgis 1.0
import QtPositioning 5.4

Rectangle {
  id: mainWindow
  anchors.fill: parent

  states: [
    State {
      name: "browse"
    },

    State {
      name: "digitize"
    }
  ]
  state: "browse"

  /*
   * The position source to access the GPS
   */
  PositionSource {
    id: positionSource
    // active: true
    active: settings.valueBool( "/QField/Positioning/Active", false )

    onPositionChanged: {
      var coord = positionSource.position.coordinate;
      locationMarker.location = Qt.point( coord.longitude, coord.latitude )
    }
  }

  Item {
    /*
     * This is the map canvas
     * On top of it are the base map and other items like GPS icon...
     */
    id: mapCanvas

    /* Initialize a MapSettings object. This will contain information about
     * the current canvas extent. It is shared between the base map and all
     * map canvas items and is used to transform map coordinates to pixel
     * coordinates.
     * It may change any time and items that hold a reference to this property
     * are responsible to handle this properly.
     */
    property MapSettings mapSettings: MapSettings {}

    /* Placement and size. Share right anchor with featureForm */
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.right: featureForm.left

    /* The base map */
    MapCanvas {
      id: mapCanvasMap
      mapSettings: mapCanvas.mapSettings

      anchors.fill: parent
    }

    /* Feature highlight overlay */
    Item {
      anchors.fill: parent

      transform: MapTransform {
        mapSettings: mapCanvas.mapSettings
      }

      FeatureListModelHighlight {
        model: featureListModel
        selection: featureForm.selection
        mapSettings: mapCanvas.mapSettings
        color: "yellow"
        selectionColor: "#ff7777"
        width: 5
      }
    }

    CoordinateLocator {
      id: coordinateLocator

      mapSettings: mapCanvas.mapSettings

      anchors.fill: parent

      visible: ( mainWindow.state === "digitize" )
    }

    /* GPS marker  */
    LocationMarker {
      id: locationMarker
      mapSettings: mapCanvas.mapSettings
      coordinateTransform: CoordinateTransform {
        sourceCRS: CRS {
          srid: 4326
        }
        destinationCRS: mapCanvas.mapSettings.crs
      }
      anchors.fill: parent
      visible: positionSource.active
    }
  }

  Item {
    id: positionInformationView
    anchors.right: featureForm.left
    anchors.top: parent.top
    visible: settings.valueBool( "/QField/Positioning/ShowInformationView", false )

    width: 250
    height: 200

    Rectangle {
      color: "white"
      opacity: 0.7
      anchors.fill: parent
      radius: 5
    }

    Rectangle {
      color: "transparent"
      border.color: "gray"
      anchors.fill: parent
      radius: 5
    }

    PositionInformationView {
      positionSource: positionSource

      anchors.fill: parent
      anchors.margins: 5
    }
  }

  /* The feature form */
  FeatureListForm {
    id: featureForm
    mapSettings: mapCanvas.mapSettings

    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    width: 0

    border.color: "lightGray"
    border.width: 1

    selection: FeatureListModelSelection { model: featureListModel }
    selectionColor: "#ff7777"
  }

  /* The main menu */
  Row {
    id: mainMenuBar
    height: childrenRect.height

    Button {
      iconSource: "/themes/holodark/settings.png"
      onClicked: {
        mainMenu.popup()
      }
    }

    LayerSelector {
      id: layerSelector

      width: 200*dp
      visible: ( mainWindow.state === "digitize" )
    }

/*
    Item {
      height: parent.height
      width: 300*dp

      Rectangle {
        anchors.fill: parent
        color: "#bb555555"
        border.color: "#dddddd"
        border.width: 1
      }

      MouseArea {
        anchors.fill: parent

        onClicked: {
          mainMenu.popup()
        }
      }

      visible: ( mainWindow.state === "digitize" )
    }
*/
    Button {
      id: gpsButton
      state: positionSource.active ? "On" : "Off"
      visible: positionSource.valid

      states: [
        State {
          name: "Off"
          PropertyChanges {
            target: gpsButton
            iconSource: "/themes/holodark/location_off.png"
          }
        },

        State {
          name: "On"
          PropertyChanges {
            target: gpsButton
            iconSource: "/themes/holodark/location.png"
          }
        }
      ]

      onClicked: {
        if ( positionSource.position.latitudeValid )
        {
          var coord = positionSource.position.coordinate;
          var loc = Qt.point( coord.longitude, coord.latitude );
          mapCanvas.mapSettings.setCenter( locationMarker.coordinateTransform.transform( loc ) )

          if ( !positionSource.active )
          {
            displayToast( qsTr( "Using cached position. Press and hold the positioning button to turn on real-time positioning." ) )
          }
        }
        else
        {
          if ( positionSource.valid )
          {
            if ( positionSource.active )
            {
              displayToast( qsTr( "Waiting for location..." ) )
            }
            else
            {
              displayToast( qsTr( "Activating positioning service..." ) )
              positionSource.active = true
            }
          }
        }
      }

      onPressAndHold: {
        gpsMenu.popup()
      }

      function toggleGps() {
        switch ( gpsButton.state )
        {
          case "Off":
            gpsButton.state = "On"
            displayToast( qsTr( "Positioning is now on" ) )
            break;

          case "On":
            gpsButton.state = "Off"
            displayToast( qsTr( "Positioning is now off" ) )
            break;
        }
      }
    }
  }

  DigitizingToolbar {
    id: digitizingToolbar

    anchors.bottom: mapCanvas.bottom
    anchors.right: mapCanvas.right

    visible: ( mainWindow.state === "digitize" )
    geometry: feature.geometry
    currentLayer: layerSelector.currentLayer

    FeatureModel{
      id: digitizingFeature
      currentLayer: layerSelector.currentLayer

      geometry: Geometry {
        currentCoordinate: coordinateLocator.coordinate
      }
    }

    onGeometryDigitized: {
      coordinateLocator.flash()

      digitizingFeature.applyGeometry()

      if ( !digitizingFeature.suppressFeatureForm() )
      {
        digitizingFeature.resetAttributes();
        overlayFeatureForm.visible = true;
        overlayFeatureForm.state = "Add"
      }
      else
      {
        digitizingFeature.create()
        digitizingFeature.save()
      }
    }
  }

  FileDialog {
    id: openProjectDialog
    title: qsTr( "Please choose a project" )
    visible: false
    nameFilters: [ qsTr( "QGIS projects (*.qgs)" ), qsTr( "All files (*)" ) ]

    width: parent.width
    height: parent.height

    onAccepted: {
      iface.loadProject( openProjectDialog.fileUrl.toString().slice(7) )
    }
  }

  Controls.Menu {
    id: mainMenu
    title: qsTr( "Main Menu" )

    Controls.Menu {
      title: qsTr( "Mode" )

      Controls.MenuItem {
        text: qsTr( "Browse" )
        onTriggered: mainWindow.state = "browse"
      }

      Controls.MenuItem {
        text: qsTr( "Digitize" )
        onTriggered: mainWindow.state = "digitize"
      }
    }

    Controls.MenuItem {
      text: qsTr( "Open Project" )
      iconSource: "/themes/holodark/map.png"
      onTriggered: {
        openProjectDialog.visible = true
      }
    }

    Controls.MenuSeparator {}

    Controls.MenuItem {
      text: qsTr( "About" )

      onTriggered: {
        aboutDialog.visible = true
      }
    }

    Controls.MenuSeparator {}

    Controls.MenuItem {
      text: qsTr( "Quit" )
      iconSource: "/themes/holodark/remove.png"
      onTriggered: {
        Qt.quit()
      }
    }
  }

  Controls.Menu {
    id: gpsMenu
    title: qsTr( "GPS Options" )

    Controls.MenuItem {
      text: qsTr( "Enable GPS" )
      checkable: true
      checked: positionSource.active
      onCheckedChanged: {
        positionSource.active = checked
      }
    }

    Controls.MenuItem {
      text: qsTr( "Center current location" )
      onTriggered: {
        var coord = positionSource.position.coordinate;
        var loc = Qt.point( coord.longitude, coord.latitude );
        mapCanvas.mapSettings.setCenter( locationMarker.coordinateTransform.transform( loc ) )
      }
    }

    Controls.MenuSeparator {}

    Controls.MenuItem {
      text: qsTr( "Show position information" )
      checkable: true
      checked: settings.valueBool( "/QField/Positioning/ShowInformationView", false )
      onCheckedChanged:
      {
        settings.setValue( "/QField/Positioning/ShowInformationView", checked )
        positionInformationView.visible = checked
      }
    }
  }

  Rectangle {
    id: overlayBackground

    anchors.fill: parent

    visible: overlayFeatureForm.visible

    color: "white"
  }

  FeatureForm {
    id: overlayFeatureForm

    anchors.fill: parent

    model: digitizingFeature

    state: "Add"

    visible: false

    onSaved: visible = false
    onCancelled: visible = false
  }

  function displayToast( message ) {
    toastMessage.text = message
    toast.opacity = 1
  }

  Rectangle {
    id: busyMessage
    anchors.fill: parent
    color: "#272727"
    opacity: 0.5
    visible: false

    Controls.BusyIndicator {
      id: busyMessageIndicator
      anchors.centerIn: parent
      running: true
    }

    Text {
      id: busyMessageText
      anchors.top: busyMessageIndicator.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      text: qsTr( "Loading Project" )
    }

    Connections {
      target: iface

      onLoadProjectStarted: {
        busyMessageText.text = qsTr( "Loading Project: %1" ).arg( path )
        busyMessage.visible = true
      }

      onLoadProjectEnded: {
        busyMessage.visible = false
      }
    }
  }

  About {
    id: aboutDialog
    anchors.fill: parent

    visible: false
  }

  WelcomeScreen {
    id: welcomeScreen
    anchors.fill: parent
    visible: !settings.value( "/QField/FirstRunFlag", false )

    onShowOpenProjectDialog: {
      welcomeScreen.visible = false
      openProjectDialog.visible = true
    }
  }

  // Toast
  Rectangle {
    id: toast
    anchors.horizontalCenter: parent.horizontalCenter
    color: "#272727"
    height: 40*dp;
    width: ( (toastMessage.width + 16*dp) <= 192*dp ) ? 192*dp : toastMessage.width + 16*dp
    opacity: 0
    radius: 20*dp
    y: parent.height - 112*dp
    z: 1
    Behavior on opacity {
      NumberAnimation { duration: 500 }
    }

    // Visible only for 3 seconds
    onOpacityChanged: {
      toast.visible = (toast.opacity > 0)
      if ( toast.opacity == 1 ) {
        toastTimer.start()
      }
    }

    Text {
      id: toastMessage
      anchors.centerIn: parent
      font.pixelSize: 16*dp
      color: "#ffffff"
    }
      // Visible only for 3 seconds
    Timer {
      id: toastTimer
      interval: 3000
      onTriggered: { toast.opacity = 0 }
    }
  }
/*
  ToolBar {
    width: childrenRect.width
    height: parent.height
    Column {
      ToolButton {
        iconSource: "/themes/holodark/settings.png"
      }
    }
  }
*/
}
