import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4 as Controls
import "../js/style.js" as Style

/*
  * field_format
  * display_format
  * calendar_popup
  * allow_null
 */


Item {
  signal valueChanged(var value, bool isNull)

  height: childrenRect.height
  anchors { right: parent.right; left: parent.left }

  Column {
    id: main
    property var currentValue: value

    anchors { right: parent.right; left: parent.left }

    Label {
      id: label
      MouseArea {
        anchors.fill: parent
        onClicked: {
          popup.open()
        }
      }

      Image {
        source: Style.getThemeIcon( "ic_clear_black_18dp" )
        anchors.left: parent.right
        visible: main.currentValue !== undefined && config['allow_null']

        MouseArea {
          anchors.fill: parent
          onClicked: {
            main.currentValue = undefined
          }
        }
      }
    }

    Popup {
      id: popup
      modal: true
      focus: true
      closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

      Controls.Calendar {
        id: calendar
        selectedDate: currentValue
        weekNumbersVisible: true
        focus: false
        anchors.fill: parent

        onSelectedDateChanged: {
          main.currentValue = selectedDate
        }
      }
    }

    onCurrentValueChanged: {
      valueChanged(currentValue, main.currentValue === undefined)
      if (main.currentValue === undefined)
      {
        label.text = 'NULL'
        label.color = 'gray'
      }
      else
      {
        label.color = 'black'
        label.text = new Date(value).toLocaleString(Qt.locale(), config['display_format'] )
      }
    }
  }
}
