import QtQuick 2.0
import QtQuick.Controls 2.0
import "qrc:Funcs.js" as JS

Rectangle{
    id: r
    width: app.width
    height: app.fs*3
    color: 'black'
    border.width: 2
    border.color: 'white'
    property bool editHost: true
    onEditHostChanged: {
        if(editHost){
            ti.focus=true
        }else{
            tiZip.focus=true
        }
    }
    onVisibleChanged: {
        if(visible){
            let fp=unik.getPath(4)+'/host'
            let h=unik.getFile(fp)//.replace(/ /g, '').replace(/\n/g, '')
            if(h==='' || h.lenght < 3){
                h='http://zool.loca.lt'
            }
            ti.text=h
            ti.focus=true

            fp=unik.getPath(4)+'/url'
            h=unik.getFile(fp)//.replace(/ /g, '').replace(/\n/g, '')
            if(h!=='error'){
                tiZip.text=h
            }
            if(!r.editHost)tiZip.focus=true
        }else{
            ti.focus=false
            tiZip.focus=false
        }
    }
    Text{
        text: r.editHost?'Definir Url de Servidor':'Definir Url de Códico Fuente'
        color: 'white'
        font.pixelSize: app.fs*0.35
        anchors.left: parent.left
        anchors.leftMargin: app.fs*0.25
        anchors.top: parent.top
        anchors.topMargin: app.fs*0.25
    }
    Row{
        spacing: app.fs*0.25
        anchors.centerIn: parent
        Rectangle{
            width: r.width-bot1.width-parent.spacing*2
            height: app.fs
            color: 'transparent'
            border.width: 2
            border.color: 'white'
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            TextInput{
                id: ti
                width: parent.width-4
                height: parent.height-4
                color: 'white'
                font.pixelSize: parent.height-app.fs*0.1
                anchors.centerIn: parent
                visible: r.editHost
            }
            TextInput{
                id: tiZip
                width: parent.width-4
                height: parent.height-4
                color: 'white'
                font.pixelSize: parent.height-app.fs*0.1
                anchors.centerIn: parent
                visible: !r.editHost
            }
        }
        Button{
            id: bot1
            text: ti.text!==''?'Listo':'Auto'
            anchors.verticalCenter: parent.verticalCenter
            visible: r.editHost
            onClicked: r.enter()
        }
        Button{
            id: botZip
            text: ti.text!==''?'Listo':'Auto'
            anchors.verticalCenter: parent.verticalCenter
            visible: !r.editHost
            onClicked: !r.enter()
        }
    }
    function enter(){
        if(r.editHost){
            if(ti.text!==''){
                let fp=unik.getPath(4)+'/host'
                let h=ti.text.replace(/ /g, '').replace(/\n/g, '')
                unik.setFile(fp, h)
                log('Se ha definido la url del servidor: '+h)
                r.visible=false
                app.checkNewVersion()
            }else{
                let ms=new Date(Date.now()).getTime()
                JS.getRD('https://nextsigner.github.io/zool/zool?r='+ms, setUrlFromGitHub)
            }
        }else{
            let fp=unik.getPath(4)+'/url'
            let h=tiZip.text.replace(/ /g, '').replace(/\n/g, '')
            unik.setFile(fp, h)
            log('Se ha definido la url código fuente: '+h)
            r.visible=false
            //app.checkNewVersion()
        }
    }
    //-->Get Https
    QtObject{
        id: setUrlFromGitHub
        function setData(data, isData){
            if(isData){
                if(data.indexOf('http')>=0){
                    let fp=unik.getPath(4)+'/host'
                    let h=(''+data).replace(/ /g, '').replace(/\n/g, '')
                    unik.setFile(fp, h)
                    log('Se ha definido la url del servidor utilizando el modo auto: '+h)
                    r.visible=false
                    app.checkNewVersion()
                }
            }else{
                log('Se ha podido definir al nueva Url de Servidor automáticamente: '+data)
            }
        }
    }
    //<--Get Https

    function toUp(){
        r.editHost=!r.editHost
    }
    function toDown(){
        r.editHost=!r.editHost
    }
}
