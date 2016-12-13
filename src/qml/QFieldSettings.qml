import QtQuick 2.0

import Qt.labs.settings 1.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "js/style.js" as Style

Page {
  signal finished

  property alias showScaleBar: showScaleBarCheckBox.checked

  Settings {
    property alias showScaleBar: showScaleBarCheckBox.checked
  }

  Rectangle {
    color: "white"
    anchors.fill: parent
  }

  ColumnLayout {
    anchors.fill: parent

    TabBar {
      id: bar
      anchors { right: parent.right; left: parent.left }

      TabButton {
        text: qsTr("Layout")
        font.pointSize: 14
      }
      TabButton {
        text: qsTr("Global Variables")
        font.pointSize: 14
      }
    }

    StackLayout {
      width: parent.width
      currentIndex: bar.currentIndex

      ColumnLayout {
        Switch {
          id: showScaleBarCheckBox
          anchors { left: parent.left; right: parent.right }
          text: qsTr( "Show Scalebar" )
          font.pointSize: 14
        }

        Switch {
          text: qsTr( "High Dpi support. !EXPERIMENTAL! (requires restart)" )
          font.pointSize: 14

          checked: settings.value( "/HighDpiScaling", false )

          onCheckedChanged: {
            settings.setValue( "/HighDpiScaling", checked )
          }
        }
      }

      Item {
        VariableEditor {
          id: variableEditor
        }
      }
    }
  }

  /** The title toolbar **/
  header: ToolBar {
    id: toolbar

    RowLayout {
      spacing: 20
      anchors.fill: parent

      ToolButton {
        id: saveButton

        contentItem: Image {
          fillMode: Image.Pad
          horizontalAlignment: Image.AlignHCenter
          verticalAlignment: Image.AlignVCenter
          source:Style.getThemeIcon( "ic_save_white_24dp" )
        }

        onClicked: {
          variableEditor.apply()
          finished()
        }
      }

      Label {
        id: titleLabel
        text: qsTr( 'QField Settings' )
        font.bold: true
        font.pointSize: 16
        elide: Label.ElideRight
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        Layout.fillWidth: true
      }

      ToolButton {
        id: closeButton

        contentItem: Image {
          fillMode: Image.Pad
          horizontalAlignment: Image.AlignHCenter
          verticalAlignment: Image.AlignVCenter
          source: Style.getThemeIcon( "ic_close_white_24dp" )
        }

        onClicked: {
          variableEditor.reset()
          finished()
        }
      }
    }
  }
}
