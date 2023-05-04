import QtQuick 2.12
import QtQuick.Window 2.0
import QtQuick.Controls 2.5

ApplicationWindow {
    id: app
    visible: true
    width: Qt.platform.os==='android'?640:Screen.width
    height: Qt.platform.os==='android'?400:Screen.height
    title: "Zooland"
    property int fs: app.width*0.03

    Rectangle{
        width: app.width*0.8
        height:app.height*0.8
        color: 'red'
        anchors.centerIn: parent
        Text{
            text: 'CurrentDir: '+currentDir+'\nUpdated: '+updated+' folderIsWritable: '+folderIsWritable+' dato1FileData: '+dato1FileData+' dp: '+documentPath
            font.pixelSize: Qt.platform.os==='android'?app.fs*2:app.fs
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
