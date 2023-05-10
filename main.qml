import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtQuick.Dialogs 1.2
import unik.Unik 1.0
import Qt.labs.settings 1.1
//import QtWebEngine 1.8
import "qrc:Funcs.js" as JS
ApplicationWindow {
    id: app
    visible: true
    width: Qt.platform.os==='android'?640:Screen.width
    height: Qt.platform.os==='android'?400:Screen.height
    title: "Zooland"
    color: 'red'
    property bool dev: false
    property int fs: app.width*0.03
    property string uZoolandVersion: ''
    Settings{
        id: apps
        fileName: unik.getPath(4)+'/zoolandMain.cfg'
        property int uZoolandNumberVersionDownloaded: -1
        property string uZoolandZipAvailable: ''
    }
    Unik{
        id: unik
        onUkStdChanged: {
            let std=ukStd
            std=std.replace(/&quot;/g, '"')
            if(std.indexOf('download git ')<0 && std.indexOf("Git Zip not downloaded.")<0 && std.indexOf("Local Folder:")<0){
                app.log(std)
            }else if(std.indexOf("Git Zip not downloaded.")>=0){
                app.log('Error al descargar el paquete Zooland.')
                app.log('Fallo al intentar descargar el paquete '+apps.uZoolandZipAvailable)
            }else if(std.indexOf("Local Folder:")>=0){
                app.log('El paquete ya se ha descomprimido.')
                app.log('Ahora puedes presionar la tecla hacia abajo para cargar la aplicación.')
                //pb.value=0
            }else{
                let m0=std.split('%')
                let p=parseInt(m0[1])
                pb.value=p
                if(p>=100){
                    let v=apps.uZoolandZipAvailable.split('_v')[1].replace('.zip', '')
                    apps.uZoolandNumberVersionDownloaded=v
                    //app.log('Aplicación Actualizada')
                    app.log('Paquete descargado.')
                    app.log('Paquete de Zooland N°'+v)
                    app.log('Descomprimiendo el paquete...')
                }
            }
            flk.contentY=flk.contentHeight-flk.height
        }
        Component.onCompleted: {
            unik.setEngine(engine)
        }
    }
    //    Timer{
    //        id: tFail
    //        running: true
    //        repeat: true
    //        interval: 5000
    //        onTriggered: app.w=5
    //    }
    Canvas {
        width: app.width
        height: app.height
        anchors.centerIn: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "black"
            ctx.fillRect(0, 0, width, height)

        }
    }
    Row{
        spacing: app.fs*0.5
        anchors.centerIn: parent
        Rectangle{
            id: xLatIzq
            width: app.width*0.35-parent.spacing
            height:app.height
            color: 'black'
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    loadApp()
                }
            }
            Column{
                spacing: app.fs*0.5
                anchors.centerIn: parent
                Text{
                    text: 'CurrentDir: '+currentDir+'\nUpdated: '+updated+'\nmainZoolandPath: '+mainZoolandPath+' modulesPath: '+modulesPath//+' dp: '+documentPath
                    font.pixelSize: Qt.platform.os==='android'?app.fs:app.fs*0.35
                    width: xLatIzq.width-app.fs
                    wrapMode: Text.WrapAnywhere
                    color: 'white'
                    visible: app.dev
                }
                Row{
                    spacing: app.fs*0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button{
                        id: botUpdate
                        text: 'Actualizar'
                        opacity: enabled?1.0:0.5
                        onClicked: updateApp()
                    }
                    Button{
                        text: 'Cargar'
                        onClicked: loadApp()
                    }
                }
                Text{
                    text: 'Teclas: Arriba=Cargar, Abajo=Actualizar, Derecha=Modo Desarrollador, Izquierda=Salir'
                    font.pixelSize: Qt.platform.os==='android'?app.fs:app.fs
                    width: xLatIzq.width-app.fs
                    wrapMode: Text.WrapAnywhere
                    color: 'white'
                }
            }
        }
        Column{
            Rectangle{
                width: app.width*0.65
                height:app.height-pb.height
                color: 'black'
                border.width: 1
                border.color: 'white'
                Flickable{
                    id: flk
                    anchors.fill: parent
                    contentWidth: parent.width
                    contentHeight: ta.contentHeight+app.fs*3
                    clip: true
                    ScrollBar.vertical: ScrollBar {
                        parent: flk.parent
                        anchors.top: flk.top
                        anchors.left: flk.right
                        anchors.bottom: flk.bottom
                    }
                    TextArea{
                        id: ta
                        width: parent.width
                        wrapMode: TextArea.WordWrap
                        color: 'white'
                        font.pixelSize: app.fs
                    }
                }
            }
            ProgressBar {
                id: pb
                width: app.width*0.65
                height: app.fs
                from:0
                to:100
                Rectangle{
                    id: xTxtPorc
                    width: txtPorc.contentWidth
                    height: txtPorc.contentHeight
                    anchors.centerIn: parent
                    color: 'black'
                    opacity: 0.65
                    border.width: 2
                    border.color: 'white'
                }
                Text{
                    id: txtPorc
                    text: '%'+pb.value
                    font.pixelSize: pb.height*0.65
                    color: 'white'
                    anchors.centerIn: xTxtPorc
                }

            }
        }
    }
    QtObject{
        id: setUZoolandVersion
        function setData(data, isData){
            if(isData){
                let j=JSON.parse(data)
                apps.uZoolandZipAvailable=j.data

                let v=j.data.split('_v')[1].replace('.zip', '')

                //apps.uZoolandNumberVersionDownloaded=v
                log('Última versión disponible en el servidor: Paquete Zooland N°'+v)
                if(parseInt(apps.uZoolandNumberVersionDownloaded)!==parseInt(v)){
                    log('Esta versión de Zooland no está actualizada')
                    botUpdate.enabled=true
                }else{
                    log('Esta versión de Zooland está actualizada.')
                    botUpdate.enabled=false
                }
                log('Versión local N°: '+apps.uZoolandNumberVersionDownloaded)
                log('Versión remota: N° '+v)
            }else{
                console.log('Data '+isData+': '+data)
                ta.text+='Error en setUZoolandVersion!\n'
            }
        }
    }

    Shortcut{
        sequence: 'Down'
        onActivated: {
            updateApp()
        }
    }
    Shortcut{
        sequence: 'Up'
        onActivated: {
            loadApp()
        }
    }
    Shortcut{
        sequence: 'Left'
        onActivated: Qt.quit()
    }
    Shortcut{
        sequence: 'Right'
        onActivated: app.dev=!app.dev
    }
    //    Connections {
    //        target: engine
    //        function onWarnings(errors) {
    //            ta.text+='Errors: '+errors.toString()
    //        }
    //    }
    Timer{
        id: tCheckNewVersion
        running: true
        repeat: true
        interval: 15000
        onTriggered: {
            checkNewVersion()
        }
    }
    Component.onCompleted: {
        checkNewVersion()
    }
    function log(t){
        ta.text+=t+'\n'
        flk.contentY=flk.contentHeight-flk.height
    }
    function checkNewVersion(){
        let d=new Date(Date.now())
        let ms=d.getTime()
        JS.getRD('http://zool.loca.lt/zool/getUZoolandVersion?r='+ms, setUZoolandVersion)
    }
    function loadApp(){
        log('Existe mainZoolandPath '+mainZoolandPath+'? '+unik.fileExist(mainZoolandPath))
        let m=(''+mainZoolandPath).replace('mainZooland.qml', 'main.qml')
        log('Existe main.qml '+m+'? '+unik.fileExist(m))
        if(Qt.platform.os==='android'){
            log('Existe /sdcard/Documents/mainZooland.qml ?'+unik.fileExist('/sdcard/Documents/mainZooland.qml'))
            log('Existe /sdcard/Documents/main.qml ?'+unik.fileExist('/sdcard/Documents/main.qml'))
        }

        let v=apps.uZoolandNumberVersionDownloaded
        let mainLocation=''
        if(Qt.platform.os==='android'){
            mainLocation=unik.getPath(4)+'/mainZooland.qml'
        }else{
            mainLocation=unik.getPath(4)+'/mainZooland.qml'
        }
        log('Cargando Zooland desde '+mainLocation)

        let mp=modulesPath
        if(!unik.folderExist(mp)){
            log('Error! La carpeta '+mp+' no existe!')
        }else{
            log('La carpeta '+mp+' no existe!')
        }

        //        let f=documentsPath+'/zooland'
        //        if(!unik.folderExist(f)){
        //            log('Error! La carpeta '+f+' no existe!')
        //            let bmkd=unik.mkdir(f, true)
        //            log('bmkd '+bmkd)
        //            if(unik.folderExist(f)){
        //                log('La carpeta '+f+' fue creada ahora mismo.')
        //            }else{
        //                log('Error! La carpeta '+f+' no se puede crear.')
        //            }
        //        }

        //engine.addImportPath(documentsPath+'/zooland_pn'+v+'/modules')
        engine.load(mainLocation)
        //engine.load(mainLocation)
        //        if(Qt.platform.os==='android'){
        //            //engine.load('file://'+mainZoolandPath)
        //            engine.load(documentsPath+'zooland-n')
        //        }else{
        //            engine.load(mainZoolandPath)
        //        }

    }
    function updateApp(){
        if(!botUpdate.enabled && !app.dev){
            log('No es necesario actualizar. La aplicación ya está actualizada con el paquete N°'+apps.uZoolandNumberVersionDownloaded)
            return
        }
        tCheckNewVersion.stop()
        if(app.dev){
            log('Actualizando forzada de la aplicación...')
        }else{
            log('Actualizando aplicación...')
        }

        let v=apps.uZoolandZipAvailable.split('_v')[1].replace('.zip', '')
        //let f=documentsPath+'/zooland'
        let f=unik.getPath(4)
        if(!unik.folderExist(f)){
            console.log('fne')
            unik.mkdir(f, true)
            if(!unik.folderExist(f)){
                console.log('2 fne')
            }else{
                console.log('2 fe')
            }
        }else{
            console.log('fe')
        }
        console.log('v: '+v)
        console.log('f: '+f)
        updated = unik.downloadGit("http://zool.loca.lt/files/"+apps.uZoolandZipAvailable,f, false);
    }
}
