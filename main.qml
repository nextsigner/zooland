import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtQuick.Dialogs 1.2
import unik.Unik 1.0
import Qt.labs.settings 1.1
import QtQuick.Shapes 1.12
import QtWebChannel 1.0
import QtWebSockets 1.1
import "qrc:Funcs.js" as JS
import "qrc:"

ApplicationWindow {
    id: app
    visible: true
    width: Qt.platform.os==='android'?640:Screen.width
    height: Qt.platform.os==='android'?400:Screen.height
    title: "Zooland"
    color: 'black'
    property bool dev: false
    property int fs: app.width*0.03
    property string uZoolandVersion: ''
    property var aUrlsReps: []
    property int currentUrlRepIndex: 0

    onDevChanged: {
        updateMenu()
    }
    Settings{
        id: apps
        fileName: unik.getPath(4)+'/zoolandMain.cfg'
        property int uZoolandNumberVersionDownloaded: -1
        property string uZoolandZipAvailable: ''
        property bool cleanAuto: false
        property bool updateGitAuto: false
        property bool engineLoadData: true
        property bool autoLoad: false
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
                lv.currentIndex=0
                let fpAL=unik.getPath(4)+'/autoload'
                if(unik.fileExist(fpAL)){
                    let fpALData=unik.getFile(fpAL).replace(/\n/g, '')
                    if(fpALData==='true'){
                        apps.autoLoad=true
                    }else{
                        apps.autoLoad=false
                    }
                }
                if(apps.autoLoad){
                    log('Iniciando carga automática del código fuente.')
                    loadApp()
                }
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
    Timer{
        id: tAutoUpdateGit
        running: apps.updateGitAuto
        repeat: false
        interval: 3000
        onTriggered: {
            updateApp(2)
        }
    }
    Timer{
        id: tAutoLoad
        running: apps.autoLoad && !apps.updateGitAuto
        repeat: true
        interval: 4000
        property int v: 0
        onTriggered: {
            if(v===3){
                loadApp()
                stop()
            }else{
                v++
            }
        }
    }
    Timer{
        id: tLogTip
        running: true
        repeat: false
        interval: 1500
        property string text: '?'
        onTriggered: {
            log(text)
        }
    }
    Timer{
        id: tPbToZero
        running: false
        repeat: false
        interval: 15000
        onTriggered: pb.value=0
    }
    Timer{
        id: tGetUrlsReps
        running: true
        repeat: true
        interval: 15000
        onTriggered: getUrlsReps()
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
            height:app.height-colBottom.height-lv.height-app.fs
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
                //TextArea{
                Text{
                    id: ta
                    width: parent.width
                    wrapMode: TextArea.WordWrap
                    color: 'white'
                    font.pixelSize: app.fs*0.5
                }
            }
            HostEditor{id: hostEditor; visible: false}
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
                tLogTip.restart()
                tLogTip.text='\n'+des
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
    Splash{id: splash; visible: apps.autoLoad}
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
                let fp=unik.getPath(4)+'/host'
                let h=unik.getFile(fp)//.replace(/ /g, '').replace(/\n/g, '')
                log('\nEl servidor Zool Server con url '+h+' no está encendido.')
                log('Pruebe cambiando la configuración del servidor.')
                log('Para más información selecciona la opción Ayuda.')
            }
        }
    }



    QtObject{
        id: setUrlsReps
        function setData(data, isData){
            if(isData){
                let m0=data.split('\n')
                let a=[]
                for(var i=0;i<m0.length-1;i++){
                    if(m0[i]!=='')a.push(m0[i])
                }
                app.aUrlsReps=a

            }
        }
    }
    function getUrlsReps(){
        let ms=new Date(Date.now()).getTime()
        let url="https://raw.githubusercontent.com/nextsigner/nextsigner.github.io/master/zool/zooland-reps?r="+ms
        JS.getRD(url, setUrlsReps)
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
        getUrlsReps()
        app.requestActivate()
        let h=unik.getFile(unik.getPath(4)+'/host').replace(/ /g, '').replace(/\n/g, '')
        log('Servidor: '+h+'\n')
        let vfp=unik.getPath(4)+'/version'
        if(unik.fileExist(unik.getPath(4)+'/main.qml') && unik.fileExist(vfp) && unik.folderExist(unik.getPath(4)+'/modules')){
            let v=unik.getFile(vfp).replace(/ /g, '').replace(/\n/g, '')
            log('Versión instalada: '+v+'')
        }else{

        }
        updateMenu()
        checkNewVersion()
        if(apps.cleanAuto)clearDir()
    }
    function updateMenu(){
        lm.clear()
        lm.append(lm.addItem('Lanzar', 'Presione Enter para lanzar la aplicación.'))
        lm.append(lm.addItem('Act. desde Servidor', 'Presione Enter para actualizar el paquete desde el servidor.'))
        lm.append(lm.addItem('Act. desde GitHub', 'Presione Enter para actualizar el paquete desde GitHub.com o GitLab.'))
        lm.append(lm.addItem('Novedades', 'Presione Enter para comprobar si hay un nuevo paquete de esta aplicación.'))
        lm.append(lm.addItem('Urls', 'Presione Enter editar la url del servidor.'))
        //lm.append(lm.addItem('Modo Desarrollador', 'Presione Enter para ver detalles técnicos y activar otras funciones.'))
        lm.append(lm.addItem('Limpiar', 'Presione Enter para eliminar archivos descargados anteriormente.'))
        lm.append(lm.addItem('Ayuda', 'Presione Enter para ver la ayuda.'))
        if(app.dev){
            lm.append(lm.addItem('Listar carpeta', 'Presione Enter para listar los archivos descargados de la aplicación.'))
            lm.append(lm.addItem('Auto Update Git', 'Presionar Enter para que esta aplicación se acutalice automáticamente desde el repositorio Git cada vez que se inicia.'))
            lm.append(lm.addItem('Auto Limpiar', 'd2'))
            lm.append(lm.addItem('Engine Load', 'Presionar Enter para definir si el código fuente se carga en la ventana actual de aplicación o en una nueva.'))
            lm.append(lm.addItem('Auto Carga', 'Presione Enter para cambiar el modo automático de carga del código fuente.'))
        }
        lm.append(lm.addItem('Salir', 'Presione Enter para cerrar esta aplicación.'))
        lv.currentIndex=0
    }
    function runEnter(){
        tLogTip.stop()
        var fp
        var h
        if(lv.currentIndex===0){
            //Cargar
            loadApp()
            return
        }
        if(lv.currentIndex===1){
            //Actualizar
            updateApp(1)
            return
        }
        if(lv.currentIndex===2){
            //Actualizar desde GitHub
            updateApp(2)
            return
        }
        if(lv.currentIndex===3){
            //Chequear si hay nueva version
            checkNewVersion()
            return
        }
        if(lv.currentIndex===4){
            if(!hostEditor.visible){
                hostEditor.visible=true
            }else{
                hostEditor.enter()
            }

        }
        //        if(lv.currentIndex===5){
        //            //Modo Dev
        //            app.dev=!app.dev
        //            if(app.dev){
        //                log('\nEl Modo Desarrollador ha sido activado.')
        //                let t= '\nCurrentDir: '+currentDir+'\nUpdated: '+updated+'\nmainZoolandPath: '+mainZoolandPath+' modulesPath: '+modulesPath
        //                log(t)
        //                log('\nAhora si desea forzar la actualización de la aplicación, presione el mando hacia abajo.')
        //                if(apps.uZoolandNumberVersionDownloaded<0){
        //                    apps.uZoolandZipAvailable='zooland-main.zip'
        //                }
        //                fp=unik.getPath(4)+'/host'
        //                h=unik.getFile(fp)//.replace(/ /g, '').replace(/\n/g, '')
        //                log('\nSi el servidor Zool Server con url '+h+' se encuentra encendido, la actualización forzada se realizará desde el paquete '+apps.uZoolandZipAvailable)
        //            }else{
        //                log('El Modo Desarrollador ha sido desactivado.')

        //            }
        //        }
        if(lv.currentIndex===5){
            clearDir()
        }

        if(lv.currentIndex===6){
            //Ayuda
            fp=unik.getPath(4)+'/host'
            h=unik.getFile(fp)//.replace(/ /g, '').replace(/\n/g, '')
            let strAyuda=''
            strAyuda+='Si el servidor Zool Server con url '+h+' se encuentra apagado, necesitas ayuda o soporte sobre esta aplicación, puedes recibir ayuda mediante las siguientes vías de contacto.'+'\n';
            strAyuda+='Whatsapp: +549 11 3802 4370.'+'\n';
            strAyuda+='E-Mail: nextsigner@gmail.com.'+'\n';
            strAyuda+='Twitch: https://twitch.tv/RicardoMartinPizarro'+'\n';
            strAyuda+='Instagram: @RicardoMartinPizarro'+'\n';
            log(strAyuda)
        }

        //DEV Listar archivos
        if(lv.currentIndex===7){
            let folderForList=unik.getPath(4)
            let fileList=unik.getFileList(folderForList, ['*.qml'], false)
            log('\nLista de archivos.\nCarpeta: '+folderForList)
            if(fileList.length===0){
                log('No hay ningún archivos del tipo QML en esta carpeta: '+folderForList)
            }else{
                log('\nLista de archivos QML.\n')
                log(fileList.toString().split(',').join('\n'))
            }
            let folderList=unik.getFileList(folderForList, [], true)
            if(folderList.length===0){
                log('No hay ningún archivos del tipo carpeta en esta carpeta: '+folderForList)
            }else{
                log('\nLista de subcarpetas.')
                for(var i=0;i<folderList.length;i++){
                    //log(folderList.toString().split(',').join('\n'))
                    let c=folderList[i]
                    if(c==='.' || c==='..')continue
                    let subFolder=folderForList+'/'+c
                    let isFolder=unik.isFolder(subFolder)
                    //log('SubCarpeta '+subFolder+' isFolder: '+isFolder)
                    if(!isFolder){
                        fileList=unik.getFileList(subFolder, ['*.qml'], false)
                        if(fileList.length>0){
                            log('\nSub carpeta '+subFolder+':')
                            log(fileList.toString().split(',').join('\n'))
                        }
                    }else{
                        //let subFolder2=subFolder+'/'+
                        let subFolderList=unik.getFileList(subFolder, [], true)
                        //log('\nIterando carpeta '+subFolder+':')
                        if(subFolderList.length>0){
                            //log('\nSub carpeta '+subFolder+':')
                            //log(subFolderList.toString().split(',').join('\n'))
                            for(var i2=0;i2<subFolderList.length;i2++){
                                let c2=subFolderList[i]
                                if(c2==='.' || c2==='..')continue
                                let subFolder2=subFolder+'/'+c2
                                let fileList2=unik.getFileList(subFolder2, ['*.qml', '*'], false)
                                if(fileList2.length>0){
                                    log('\nSub carpeta nivel 2'+subFolder2+':')
                                    log(fileList2
                                        .toString().split(',').join('\n'))
                                }
                            }
                        }
                    }

                }

            }



            //log(fileList)
        }

        //SET BOOL AUTO UPDATE GIT
        if(lv.currentIndex===8){
            apps.updateGitAuto=!apps.updateGitAuto
            if(apps.updateGitAuto){
                log('Se ha seteado esta aplicación para que se actualice automáticamente cada vez que se encienda.')
            }else{
                log('Se ha desactivado la función de auto actualización.')
            }
        }
        //DEV Listar archivos
        if(lv.currentIndex===7){
            let folderForList=unik.getPath(4)
            let fileList=unik.getFileList(folderForList, ['*.qml'], false)
            log('\nLista de archivos.\nCarpeta: '+folderForList)
            if(fileList.length===0){
                log('No hay ningún archivos del tipo QML en esta carpeta: '+folderForList)
            }else{
                log('\nLista de archivos QML.\n')
                log(fileList.toString().split(',').join('\n'))
            }
            let folderList=unik.getFileList(folderForList, [], true)
            if(folderList.length===0){
                log('No hay ningún archivos del tipo carpeta en esta carpeta: '+folderForList)
            }else{
                log('\nLista de subcarpetas.')
                for(var i=0;i<folderList.length;i++){
                    //log(folderList.toString().split(',').join('\n'))
                    let c=folderList[i]
                    if(c==='.' || c==='..')continue
                    let subFolder=folderForList+'/'+c
                    let isFolder=unik.isFolder(subFolder)
                    //log('SubCarpeta '+subFolder+' isFolder: '+isFolder)
                    if(!isFolder){
                        fileList=unik.getFileList(subFolder, ['*.qml'], false)
                        if(fileList.length>0){
                            log('\nSub carpeta '+subFolder+':')
                            log(fileList.toString().split(',').join('\n'))
                        }
                    }else{
                        //let subFolder2=subFolder+'/'+
                        let subFolderList=unik.getFileList(subFolder, [], true)
                        //log('\nIterando carpeta '+subFolder+':')
                        if(subFolderList.length>0){
                            //log('\nSub carpeta '+subFolder+':')
                            //log(subFolderList.toString().split(',').join('\n'))
                            for(var i2=0;i2<subFolderList.length;i2++){
                                let c2=subFolderList[i]
                                if(c2==='.' || c2==='..')continue
                                let subFolder2=subFolder+'/'+c2
                                let fileList2=unik.getFileList(subFolder2, ['*.qml', '*'], false)
                                if(fileList2.length>0){
                                    log('\nSub carpeta nivel 2'+subFolder2+':')
                                    log(fileList2
                                        .toString().split(',').join('\n'))
                                }
                            }
                        }
                    }

                }

            }



            //log(fileList)
        }

        //SET BOOL AUTO CLEAR DIR
        if(lv.currentIndex===9){
            apps.cleanAuto=!apps.cleanAuto
            if(apps.cleanAuto){
                log('Se ha seteado esta aplicación para que limpie la carpeta de instalación automáticamente cada vez que se encienda.')
            }else{
                log('Se ha desactivado la función de auto borrado de carpeta de instalación.')
            }
        }

        //SET BOOL ENGINE LOAD DATA
        if(lv.currentIndex===10){
            apps.engineLoadData=!apps.engineLoadData
            if(apps.engineLoadData){
                log('A partir de ahora el código fuente de la aplicación se cargará en esta ventana actual reemplazando todo lo que se está viendo y ejecutando en este momento.')
            }else{
                log('A partir de ahora el código fuente se cargará en una nueva ventana de aplicación.')
            }
        }

        //SET BOOL AUTO LOAD
        if(lv.currentIndex===11){
            apps.autoLoad=!apps.autoLoad
            if(apps.autoLoad){
                log('A partir de ahora el código fuente de la aplicación se cargará automáticamente.')
            }else{
                log('A partir de ahora para cargar el código fuente deberá presionar el botón Lanzar.')
            }
        }

        if(lv.currentIndex===lm.count-1){
            //Salir
            Qt.quit()
        }
    }
    property int cantReqDev: 0
    function runToLeft(){
        //splash.visible=!splash.visible
        if(tAutoLoad.running){
            tAutoLoad.stop()

            return
        }
        if(lv.currentIndex>0){
            lv.currentIndex--
        }else{
            if(app.cantReqDev<3){
                app.cantReqDev++
            }else{
                cantReqDev=0
            }
            if(app.cantReqDev===3){
                app.dev=true
            }else{
                app.dev=false
            }
        }
    }
    function runToRight(){
        if(lv.currentIndex<lm.count-1){
            lv.currentIndex++
        }
    }
    function runToDown(){
        if(splash.visible){
            splash.visible=false
            return
        }
        if(lm.get(lv.currentIndex).txt==='Urls' && app.dev){
            tAutoLoad.stop()
            tAutoUpdateGit.stop()
            if(app.currentUrlRepIndex<app.aUrlsReps.length-1){
                app.currentUrlRepIndex++
            }else{
                app.currentUrlRepIndex=0
            }
            let fp=unik.getPath(4)+'/url'
            let h=app.aUrlsReps[app.currentUrlRepIndex].replace(/ /g, '').replace(/\n/g, '')
            unik.setFile(fp, h)
            log('Se ha definido la Url de Repositorio para origen del código fuente: '+h)
            return
        }
        if(hostEditor.visible){
            hostEditor.toDown()
            return
        }
        if(flk.contentY<flk.contentHeight-flk.height){
            flk.contentY=flk.contentY+app.fs*0.5
        }
    }
    function runToUp(){
        if(lm.get(lv.currentIndex).txt==='Urls' && app.dev){
            tAutoLoad.stop()
            tAutoUpdateGit.stop()
            if(app.currentUrlRepIndex<app.aUrlsReps.length-1){
                app.currentUrlRepIndex++
            }else{
                app.currentUrlRepIndex=0
            }
            let fp=unik.getPath(4)+'/host'
            let h=app.aUrlsReps[app.currentUrlRepIndex].replace(/ /g, '').replace(/\n/g, '')
            unik.setFile(fp, h)
            log('Se ha definido la Url de Repositorio para Host: '+h)
            return
        }
        if(hostEditor.visible){
            hostEditor.toUp()
            return
        }
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
        let fp=unik.getPath(4)+'/host'
        let h=unik.getFile(fp).replace(/ /g, '').replace(/\n/g, '')
        JS.getRD(h+':8100/zool/getUZoolandVersion?r='+ms, setUZoolandVersion)
    }
    function loadApp(){
        //        log('Existe mainZoolandPath '+mainZoolandPath+'? '+unik.fileExist(mainZoolandPath))
        //        let m=(''+mainZoolandPath).replace('mainZooland.qml', 'main.qml')
        //        log('Existe main.qml '+m+'? '+unik.fileExist(m))
        //        if(Qt.platform.os==='android'){
        //            log('Existe /sdcard/Documents/mainZooland.qml ?'+unik.fileExist('/sdcard/Documents/mainZooland.qml'))
        //            log('Existe /sdcard/Documents/main.qml ?'+unik.fileExist('/sdcard/Documents/main.qml'))
        //        }

        splash.enableAn=false
        splash.t=splash.t+'\nCargando...'

        let v=apps.uZoolandNumberVersionDownloaded
        let mainLocation=''

        if(Qt.platform.os==='android'){
            mainLocation=unik.getPath(4)+'/mainZooland.qml'
            let fd=unik.getFile(unik.getPath(4)+'/main.qml')
            if(fd!=='error'){
                unik.setFile(mainLocation, fd)
            }
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
        if(!apps.engineLoadData){
            engine.load(mainLocation)
        }else{
            let mainQmlData=unik.getFile(mainLocation)
            engine.loadData(mainQmlData, 'file:./')
        }
    }
    function updateApp(num){
        if(app.dev){
            log('Actualizando de manera forzada de la aplicación...')
        }else{
            log('Actualizando aplicación...')
        }
        let f=unik.getPath(4)
        let fp=''
        let h=''

        if(num===1){
            let m0=apps.uZoolandZipAvailable.split('_v')
            let v=''
            if(apps.uZoolandZipAvailable!=='zooland-main.zip' && apps.uZoolandNumberVersionDownloaded >= 0){
                v=m0[1].replace('.zip', '')
            }
            f=unik.getPath(4)
            fp=unik.getPath(4)+'/host'
            h=unik.getFile(fp).replace(/ /g, '').replace(/\n/g, '')
            updated = unik.downloadGit(h+":8100/files/"+apps.uZoolandZipAvailable,f, false);
            return
        }
        if(num===2){
            f=unik.getPath(4)
            fp=unik.getPath(4)+'/url'
            h=unik.getFile(fp).replace(/ /g, '').replace(/\n/g, '')
            if(h==='' || h.length<=3){
                log('La url del código fuente no es válida.')
                log('Url: '+h)
                return
            }
            log('Comienza la descarga del código fuente desde '+h)
            log('Por favor espere.')
            if(apps.autoLoad){
                log('El código fuente será cargado y ejecutado automáticamente luego de la descarga.')
            }
            updated = unik.downloadGit(h,f, true);
            return
        }
    }
    function clearDir(){
        let fpHost=unik.getPath(4)+'/host'
        let hHost=unik.getFile(fpHost).replace(/ /g, '').replace(/\n/g, '')
        let fpUrl=unik.getPath(4)+'/url'
        let hUrl=unik.getFile(fpUrl).replace(/ /g, '').replace(/\n/g, '')

        let borrado=unik.clearDir(unik.getPath(4))

        if(borrado){
            log('Se han eliminado todos los archivos de la carpeta '+unik.getPath(4))
            unik.setFile(fpHost, hHost)
            unik.setFile(fpUrl, hUrl)
        }
    }
}
