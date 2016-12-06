import QtQuick 2.0
import QtQuick.Controls 2.0

Item {
  signal valueChanged(var value, bool isNull)

  anchors.left: parent.left
  anchors.right: parent.right

  height: childrenRect.height


  ComboBox {
    id: comboBox

    property var reverseConfig: ({})
    property var currentValue: value

    anchors { left: parent.left; right: parent.right }

    currentIndex: find(reverseConfig[value])

    Component.onCompleted: {
      model = Object.keys(config['map']);
      for(var key in config['map']) {
        reverseConfig[config['map'][key]] = key;
      }
      currentIndex = find(reverseConfig[value])
    }

    onCurrentTextChanged: {
      valueChanged(config['map'][currentText], false)
    }

    // Workaround to get a signal when the value has changed
    onCurrentValueChanged: {
      currentIndex = find(reverseConfig[value])
    }

    MouseArea {
      anchors.fill: parent
      propagateComposedEvents: true

      onClicked: mouse.accepted = false
      onPressed: { forceActiveFocus(); mouse.accepted = false; }
      onReleased: mouse.accepted = false;
      onDoubleClicked: mouse.accepted = false;
      onPositionChanged: mouse.accepted = false;
      onPressAndHold: mouse.accepted = false;
    }
  }
}
