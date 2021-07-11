import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3


ApplicationWindow {
    width: 360
    height: 300
    visible: true

    Button {
        anchors.centerIn: parent
        text: "click me!"
        onClicked: labelTest.text = backend.test()
    }

    Label{
        id: labelTest
        text: "bien le bonjour"
    }
}
