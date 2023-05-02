import QtQuick 2.12
import QtQuick.Window 2.0
import QtQuick.Controls 2.5

ApplicationWindow {
    id: app
    visible: true
    width: Screen.width
    height: Screen.height
    title: "Zooland"
    property int fs: app.width*0.03

    Rectangle{
        width: app.width*0.8
        height: app.height*0.8
        color: 'red'
        anchors.centerIn: parent
        Text{
            text: 'CurrentDir: '+currentDir
            font.pixelSize: app.fs
            width: parent.width
            wrapMode: Text.WrapAnywhere
            color: 'white'
        }
    }

    Shortcut{
        sequence: 'Right'
        onActivated: Qt.quit()
    }
}
