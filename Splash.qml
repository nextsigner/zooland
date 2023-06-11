import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle{
    id: r
    width: parent.width
    height: parent.height
    color: 'black'
    property alias t: l.text
    property bool enableAn: true
    onVisibleChanged: {
        if(visible){
            tapa.opacity=0.0
        }else{
            tapa.opacity=1.0
        }
    }
    Column{
        id: col
        spacing: r.height*0.025
        anchors.centerIn: parent
        Item{
            width: r.width*0.2
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            Image{
                id: splash
                width: parent.width
                height: width
                anchors.centerIn: parent
                visible: !r.enableAn
            }
            //            FastBlur {
            //                anchors.fill: splash
            //                source: splash
            //                radius: 32
            BrightnessContrast {
                anchors.fill: splash
                source: splash
                brightness: 0.5
                contrast: 0.0
                visible: r.enableAn

                SequentialAnimation on brightness{
                    loops: Animation.Infinite
                    NumberAnimation{
                        from: 0.0
                        to: 0.5
                        duration: 2500
                    }
                    PauseAnimation {
                        duration: 1000
                    }
                    NumberAnimation{
                        from: 0.5
                        to: 0.0
                        duration: 1000
                    }
                    PauseAnimation {
                        duration: 3000
                    }

                }
            }
        }
        Item{
            width: 1
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                id: l
                text: 'Zooland'
                color: 'white'
                font.pixelSize: col.spacing*2
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Text{
        text: 'Presionar hacia abajo\npara ir a opciones'
        color: 'white'
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
    }
    Rectangle{
        id: tapa
        anchors.fill: parent
        color: 'black'
        opacity: 1.0
        Behavior on opacity{NumberAnimation{duration: 2000}}
    }


    Component.onCompleted: {
        let sp=unik.getPath(4)+'/splash.png'
        if(!unik.fileExist(sp)){
            splash.source='qrc:splash.png'
        }else{
            splash.source='file://'+sp
        }
        let appName=unik.getPath(4)+'/appname'
        if(unik.fileExist(appName)){
            l.text=unik.getFile(appName).replace(/\n/g, '')
        }

    }
}
