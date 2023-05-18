import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtQuick.Dialogs 1.2
import unik.Unik 1.0
import Qt.labs.settings 1.1
import QtQuick.Shapes 1.12
import "qrc:Funcs.js" as JS
import "qrc:"
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
                app.log('Ahora puedes lanzar la aplicación.')
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
                    app.log('Por favor espere.')
                    tPbToZero.restart()
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
    Timer{
        id: tPbToZero
        running: false
        repeat: false
        interval: 15000
        onTriggered: pb.value=0
    }
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
    Column{
        spacing: app.fs*0.5
        anchors.bottom: parent.bottom
        ListView{
            id: lv
            width: app.width
            height: app.fs
            spacing: app.fs*0.1
            anchors.horizontalCenter: parent.horizontalCenter
            //clip: true
            orientation: ListView.Horizontal
            model: lm
            delegate: compItemLv
            ListModel{
                id: lm
                function addItem(t,d){
                    return{
                        txt:t,
                        des: d
                    }
                }
            }
        }
        Rectangle{
                width: app.width
                height:app.height-colBottom.height-lv.height-app.fs*0.5
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

        Column{
            id: colBottom
            anchors.horizontalCenter: parent.horizontalCenter
            ProgressBar {
                id: pb
                width: app.width-app.fs
                height: app.fs
                from:0
                to:100
                anchors.horizontalCenter: parent.horizontalCenter
                visible: value>=1
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
    Mando{id: mando}
    Component{
        id: compItemLv
        Item{
            id: xItem
            width: txtItem.contentWidth+app.fs*0.5
            height: app.fs*0.8
            anchors.verticalCenter: parent.verticalCenter
            property bool selected: index===lv.currentIndex
            onSelectedChanged: {
                log('\n'+des)
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    lv.currentIndex=index
                    runEnter()
                }
            }
            Rectangle{
                anchors.fill: parent
                radius: app.fs*0.25
                opacity: xItem.selected?1.0:0.5
            }
            Text{
                id: txtItem
                text: txt
                font.pixelSize: app.fs*0.65
                anchors.centerIn: parent
            }
        }

    }
    QtObject{
        id: setUZoolandVersion
        function setData(data, isData){
            if(isData){
                let j=JSON.parse(data)
                if(!j.data){
                    apps.uZoolandZipAvailable='zooland-main.zip'
                    if(apps.uZoolandNumberVersionDownloaded>=0){
                        log('Su última versión de paquete instalada es la N°'+apps.uZoolandNumberVersionDownloaded)
                    }else{
                        log('Al parecer aún no ha instalado ningún paquete de la aplicación.')
                    }
                    log('El servidor de momento tiene disponible el paquete '+apps.uZoolandZipAvailable)
                    return
                }
                apps.uZoolandZipAvailable=j.data

                let v=j.data.split('_v')[1].replace('.zip', '')

                //apps.uZoolandNumberVersionDownloaded=v
                log('Última versión disponible en el servidor: Paquete Zooland N°'+v)
                if(parseInt(apps.uZoolandNumberVersionDownloaded)!==parseInt(v)){
                    log('Esta versión de Zooland no está actualizada')
                    //botUpdate.enabled=true
                }else{
                    log('Esta versión de Zooland está actualizada.')
                    //botUpdate.enabled=false
                }
                log('Versión local N°: '+apps.uZoolandNumberVersionDownloaded)
                log('Versión remota: N° '+v)
            }else{
                log('El servidor Zool Server no está encendido.')
                log('Para más información selecciona la opción Ayuda.')
            }
        }
    }


    Shortcut{
        sequence: 'Down'
        onActivated: {
            runToDown()
        }
    }
    Shortcut{
        sequence: 'Up'
        onActivated: {
            runToUp()
        }
    }
    Shortcut{
        sequence: 'Left'
        onActivated: {
            runToLeft()
        }
    }
    Shortcut{
        sequence: 'Right'
        onActivated: {
            runToRight()
        }
    }
    Shortcut{
        sequence: 'Enter'
        onActivated: {
            runEnter()
        }
    }
    Shortcut{
        sequence: 'Return'
        onActivated: {
            runEnter()
        }
    }
    Component.onCompleted: {
        lm.append(lm.addItem('Lanzar App', 'Presione Enter para lanzar la aplicación.'))
        lm.append(lm.addItem('Actualizar', 'Presione Enter para actualizar el paquete.'))
        lm.append(lm.addItem('¿Hay un nuevo Paquete?', 'Presione Enter para comprobar si hay un nuevo paquete de esta aplicación.'))
        lm.append(lm.addItem('Modo Desarrollador', 'Presione Enter para ver detalles técnicos y activar otras funciones.'))
        lm.append(lm.addItem('Ayuda', 'Presione Enter para ver la ayuda.'))
        lm.append(lm.addItem('Salir', 'Presione Enter para cerrar esta aplicación.'))
        lv.currentIndex=-1
        checkNewVersion()
    }
    function runEnter(){
        if(lv.currentIndex===0){
            //Cargar
            loadApp()
            return
        }
        if(lv.currentIndex===1){
            //Actualizar
            updateApp()
            return
        }
        if(lv.currentIndex===2){
            //Chequear si hay nueva version
            checkNewVersion()
            return
        }
        if(lv.currentIndex===3){
            //Modo Dev
            app.dev=!app.dev
            if(app.dev){
                log('\nEl Modo Desarrollador ha sido activado.')
                let t= '\nCurrentDir: '+currentDir+'\nUpdated: '+updated+'\nmainZoolandPath: '+mainZoolandPath+' modulesPath: '+modulesPath
                log(t)
                log('\nAhora si desea forzar la actualización de la aplicación, presione el mando hacia abajo.')
                if(apps.uZoolandNumberVersionDownloaded<0){
                    apps.uZoolandZipAvailable='zooland-main.zip'
                }
                log('\nSi el servidor Zool Server se encuentra encendido, la actualización forzada se realizará desde el paquete '+apps.uZoolandZipAvailable)
            }else{
                log('El Modo Desarrollador ha sido desactivado.')

            }
        }
        if(lv.currentIndex===4){
            //Ayuda
            let strAyuda=''
            strAyuda+='Si el servidor se encuentra apagado, necesitas ayuda o soporte sobre esta aplicación, puedes recibir ayuda mediante las siguientes vías de contacto.'+'\n';
            strAyuda+='Whatsapp: +549 11 3802 4370.'+'\n';
            strAyuda+='E-Mail: nextsigner@gmail.com.'+'\n';
            strAyuda+='Twitch: https://twitch.tv/RicardoMartinPizarro'+'\n';
            strAyuda+='Instagram: @RicardoMartinPizarro'+'\n';
            log(strAyuda)
        }
        if(lv.currentIndex===lm.count-1){
            //Salir
            Qt.quit()
        }
    }
    function runToLeft(){
        if(lv.currentIndex>0){
            lv.currentIndex--
        }
    }
    function runToRight(){
        if(lv.currentIndex<lm.count-1){
            lv.currentIndex++
        }
    }
    function runToDown(){
        if(flk.contentY<flk.contentHeight-flk.height){
            flk.contentY=flk.contentY+app.fs*0.5
        }
    }
    function runToUp(){
        if(flk.contentY>0){
            flk.contentY=flk.contentY-app.fs*0.5
        }
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
        if(app.dev){
            log('Actualizando de manera forzada de la aplicación...')
        }else{
            log('Actualizando aplicación...')
        }

        let m0=apps.uZoolandZipAvailable.split('_v')
        let v=''
        if(apps.uZoolandZipAvailable!=='zooland-main.zip' && apps.uZoolandNumberVersionDownloaded >= 0){
            v=m0[1].replace('.zip', '')
        }

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
