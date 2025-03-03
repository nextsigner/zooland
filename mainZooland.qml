import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtGraphicalEffects 1.12
import QtQuick.Dialogs 1.2
import unik.UnikHere 1.0
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

    property int uZipCount: 0
    property int uZipNumberDes: 0


    onDevChanged: {
        updateMenu()
    }
    Settings{
        id: apps
        fileName: unikHere.getPath(4)+'/zoolandMain.cfg'
        property int uZoolandNumberVersionDownloaded: -1
        property string uZoolandZipAvailable: ''
        property bool cleanAuto: false
        property bool updateGitAuto: false
        property bool engineLoadData: false
        property bool autoLoad: false
    }
    UnikHere{
        id: unikHere
        onUkStdChanged: {
            let std=ukStd
            std=std.replace(/&quot;/g, '"')
            if(std.indexOf('download git ')<0 && std.indexOf("Git Zip not downloaded.")<0 && std.indexOf("Local Folder:")<0 && std.indexOf("Zip Des:")<0 && std.indexOf("Zip Count:")<0){
                app.log(std)
            }else if(std.indexOf("Git Zip not downloaded.")>=0){
                app.log('Error al descargar el paquete Zooland.')
                app.log('Fallo al intentar descargar el paquete '+apps.uZoolandZipAvailable)
            }else if(std.indexOf("Zip Count:")>=0){
                let nzc=std.split(':')[1]
                app.uZipCount=nzc
                app.uZipNumberDes=0
                log('Se van a descomprimir un total de '+app.uZipCount+' archivos.')

            }else if(std.indexOf("Zip Des:")>=0){
                app.uZipNumberDes++
                txtTask.text='Descomprimiendo'
                let porc=100/app.uZipCount*app.uZipNumberDes
                pb.value=parseInt(porc)
                //log('N° '+app.uZipNumberDes+' de '+app.uZipCount+': %'+porc)
            }else if(std.indexOf("Local Folder:")>=0){
                app.log('El paquete ya se ha descomprimido.')
                app.log('Ahora puedes lanzar la aplicación.')
                lv.currentIndex=0
                let fpAL=unikHere.getPath(4)+'/autoload'
                if(unikHere.fileExist(fpAL)){
                    let fpALData=unikHere.getFile(fpAL).replace(/\n/g, '')
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
                txtTask.text='Descargando'
                let m0=std.split('%')
                let p=parseInt(m0[1])
                pb.value=p
                if(p>=100){
                    let v=apps.uZoolandZipAvailable.split('_v')[1].replace('.zip', '')
                    apps.uZoolandNumberVersionDownloaded=parseInt(v)
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
            unikHere.setEngine(engine)
            setOrigin('url', 'https://github.com/nextsigner/mialbum')
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
                    font.pixelSize: app.fs//*0.5
                }
            }
            HostEditor{id: hostEditor; visible: false}
        }

        Column{
            id: colBottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: pb.visible
            Rectangle{
                id: xTxtPorc
                width: rowPbTxts.width+app.fs*0.5//txtPorc.contentWidth
                height: app.fs//txtPorc.contentHeight
                //anchors.centerIn: parent
                color: 'black'
                opacity: 0.65
                border.width: 2
                border.color: 'white'
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.bottom: parent.top
                //anchors.bottomMargin: app.fs//*0.1
                Row{
                    id: rowPbTxts
                    spacing: app.fs*0.25
                    anchors.centerIn: xTxtPorc
                    Text{
                        id: txtTask
                        font.pixelSize: parent.parent.height*0.6
                        color: 'white'
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text{
                        id: txtPorc
                        text: pb.value===0?'':'%'+pb.value
                        font.pixelSize: parent.parent.height*0.6
                        color: 'white'
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            ProgressBar {
                id: pb
                width: app.width-app.fs
                height: app.fs*0.5
                from:0
                to:100
                anchors.horizontalCenter: parent.horizontalCenter
                onValueChanged: {
                    if(value===0)txtTask.text='Esperando para realizar una tarea.'
                }
                //visible: value>=1

            }
        }
    }
    Mando{id: mando}
    Component{
        id: compItemLv
        Item{
            id: xItem
            width: txtItem.contentWidth+app.fs*0.5
            height: app.fs*1.2//*0.8
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
                font.pixelSize: app.fs//*0.65
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
                let fp=unikHere.getPath(4)+'/host'
                let h=unikHere.getFile(fp)//.replace(/ /g, '').replace(/\n/g, '')
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
        sequence: 'Esc'
        onActivated: {
            if(Qt.platform.os==='linux'){
                Qt.quit()
            }else{
                app.close()
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
        updateMenu()
        let autoFilePath=unikHere.getPath(4)+'/auto'
        if(unikHere.fileExist(autoFilePath)){
            let code=unikHere.getFile(autoFilePath)
            let comp = Qt.createQmlObject(code, app, 'autoZoolandCode')
            return
        }

        getUrlsReps()
        app.requestActivate()



        let h=unikHere.getFile(unikHere.getPath(4)+'/host').replace(/ /g, '').replace(/\n/g, '')
        log('Servidor: '+h+'\n')
        let vfp=unikHere.getPath(4)+'/version'
        if(unikHere.fileExist(unikHere.getPath(4)+'/main.qml') && unikHere.fileExist(vfp) && unikHere.folderExist(unikHere.getPath(4)+'/modules')){
            let v=unikHere.getFile(vfp).replace(/ /g, '').replace(/\n/g, '')
            log('Versión instalada: '+v+'')
        }else{

        }

        if(!apps.autoLoad && !apps.updateGitAuto && unikHere.fileExist(unikHere.getPath(4)+'/host')){
            checkNewVersion()
        }
        if(apps.cleanAuto)clearDir()
    }
    function updateMenu(){
        lm.clear()
        lm.append(lm.addItem('Lanzar', 'Presione Enter para lanzar la aplicación.'))
        lm.append(lm.addItem('!GitHub', 'Presione Enter para actualizar el paquete desde GitHub.com o GitLab.'))
        lm.append(lm.addItem('!Servidor', 'Presione Enter para actualizar el paquete desde el servidor.'))
        lm.append(lm.addItem('Novedades', 'Presione Enter para comprobar si hay un nuevo paquete de esta aplicación.'))
        lm.append(lm.addItem('Urls', 'Presione Enter editar la url del servidor.'))
        //lm.append(lm.addItem('Modo Desarrollador', 'Presione Enter para ver detalles técnicos y activar otras funciones.'))

        lm.append(lm.addItem('Ayuda', 'Presione Enter para ver la ayuda.'))
        if(app.dev){
            lm.append(lm.addItem('Limpiar', 'Presione Enter para eliminar archivos descargados anteriormente.'))
            lm.append(lm.addItem('!Listar', 'Presione Enter para listar los archivos descargados de la aplicación.'))
            lm.append(lm.addItem('Auto Update Git', 'Presionar Enter para que esta aplicación se acutalice automáticamente desde el repositorio Git cada vez que se inicia.'))
            lm.append(lm.addItem('Auto Limpiar', 'd2'))
            lm.append(lm.addItem('Engine Load', 'Presionar Enter para definir si el código fuente se carga en la ventana actual de aplicación o en una nueva.'))
            lm.append(lm.addItem('Auto Carga', 'Presione Enter para cambiar el modo automático de carga del código fuente.'))
        }
        lm.append(lm.addItem('!Salir', 'Presione Enter para cerrar esta aplicación.'))
        lv.currentIndex=0
    }
    function runEnter(){
        //unik.getSpeakEngines()
        tLogTip.stop()
        var fp
        var h
        if(lv.currentIndex===0){
            //Cargar
            loadApp()
            return
        }
        //if(lv.currentIndex===1){
        if(lm.get(lv.currentIndex).txt==='!Servidor'){
            //Actualizar
            tAutoLoad.stop()
            tAutoUpdateGit.stop()
            updateApp(1)
            return
        }
        if(lm.get(lv.currentIndex).txt==='!GitHub'){
            //Actualizar desde GitHub
            tAutoLoad.stop()
            tAutoUpdateGit.stop()
            updateApp(2)
            return
        }
        if(lm.get(lv.currentIndex).txt==='Novedades'){
            //Chequear si hay nueva version
            checkNewVersion()
            return
        }
        if(lm.get(lv.currentIndex).txt==='Urls'){
            if(!hostEditor.visible){
                hostEditor.visible=true
            }else{
                hostEditor.enter()
            }

        }
        if(lm.get(lv.currentIndex).txt==='Limpiar'){
            clearDir()
        }
        if(lm.get(lv.currentIndex).txt==='Ayuda'){
            //Ayuda
            fp=unikHere.getPath(4)+'/host'
            h=unikHere.getFile(fp)//.replace(/ /g, '').replace(/\n/g, '')
            let strAyuda=''
            strAyuda+='Si el servidor Zool Server con url '+h+' se encuentra apagado, necesitas ayuda o soporte sobre esta aplicación, puedes recibir ayuda mediante las siguientes vías de contacto.'+'\n';
            strAyuda+='Whatsapp: +549 11 3802 4370.'+'\n';
            strAyuda+='E-Mail: nextsigner@gmail.com.'+'\n';
            strAyuda+='Twitch: https://twitch.tv/RicardoMartinPizarro'+'\n';
            strAyuda+='Instagram: @RicardoMartinPizarro'+'\n';
            log(strAyuda)
        }

        //DEV Listar archivos
        if(lm.get(lv.currentIndex).txt==='!Listar'){
            let folderForList=unikHere.getPath(4)
            let fileList=unikHere.getFileList(folderForList, ['*.qml'], false)
            log('\nLista de archivos.\nCarpeta: '+folderForList)
            if(fileList.length===0){
                log('No hay ningún archivos del tipo QML en esta carpeta: '+folderForList)
            }else{
                log('\nLista de archivos QML.\n')
                log(fileList.toString().split(',').join('\n'))
            }
            let folderList=unikHere.getFileList(folderForList, [], true)
            if(folderList.length===0){
                log('No hay ningún archivos del tipo carpeta en esta carpeta: '+folderForList)
            }else{
                log('\nLista de subcarpetas.')
                for(var i=0;i<folderList.length;i++){
                    //log(folderList.toString().split(',').join('\n'))
                    let c=folderList[i]
                    if(c==='.' || c==='..')continue
                    let subFolder=folderForList+'/'+c
                    let isFolder=unikHere.isFolder(subFolder)
                    //log('SubCarpeta '+subFolder+' isFolder: '+isFolder)
                    if(!isFolder){
                        fileList=unikHere.getFileList(subFolder, ['*.qml'], false)
                        if(fileList.length>0){
                            log('\nSub carpeta '+subFolder+':')
                            log(fileList.toString().split(',').join('\n'))
                        }
                    }else{
                        //let subFolder2=subFolder+'/'+
                        let subFolderList=unikHere.getFileList(subFolder, [], true)
                        //log('\nIterando carpeta '+subFolder+':')
                        if(subFolderList.length>0){
                            //log('\nSub carpeta '+subFolder+':')
                            //log(subFolderList.toString().split(',').join('\n'))
                            for(var i2=0;i2<subFolderList.length;i2++){
                                let c2=subFolderList[i]
                                if(c2==='.' || c2==='..')continue
                                let subFolder2=subFolder+'/'+c2
                                let fileList2=unikHere.getFileList(subFolder2, ['*.qml', '*'], false)
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
        if(lm.get(lv.currentIndex).txt==='AutoUpdate'){
            apps.updateGitAuto=!apps.updateGitAuto
            if(apps.updateGitAuto){
                log('Se ha seteado esta aplicación para que se actualice automáticamente cada vez que se encienda.')
            }else{
                log('Se ha desactivado la función de auto actualización.')
            }
        }
        //DEV Listar archivos
        if(lm.get(lv.currentIndex).txt==='!Listar'){
            let folderForList=unikHere.getPath(4)
            let fileList=unikHere.getFileList(folderForList, ['*.qml'], false)
            log('\nLista de archivos.\nCarpeta: '+folderForList)
            if(fileList.length===0){
                log('No hay ningún archivos del tipo QML en esta carpeta: '+folderForList)
            }else{
                log('\nLista de archivos QML.\n')
                log(fileList.toString().split(',').join('\n'))
            }
            let folderList=unikHere.getFileList(folderForList, [], true)
            if(folderList.length===0){
                log('No hay ningún archivos del tipo carpeta en esta carpeta: '+folderForList)
            }else{
                log('\nLista de subcarpetas.')
                for(var i=0;i<folderList.length;i++){
                    //log(folderList.toString().split(',').join('\n'))
                    let c=folderList[i]
                    if(c==='.' || c==='..')continue
                    let subFolder=folderForList+'/'+c
                    let isFolder=unikHere.isFolder(subFolder)
                    //log('SubCarpeta '+subFolder+' isFolder: '+isFolder)
                    if(!isFolder){
                        fileList=unikHere.getFileList(subFolder, ['*.qml'], false)
                        if(fileList.length>0){
                            log('\nSub carpeta '+subFolder+':')
                            log(fileList.toString().split(',').join('\n'))
                        }
                    }else{
                        //let subFolder2=subFolder+'/'+
                        let subFolderList=unikHere.getFileList(subFolder, [], true)
                        //log('\nIterando carpeta '+subFolder+':')
                        if(subFolderList.length>0){
                            //log('\nSub carpeta '+subFolder+':')
                            //log(subFolderList.toString().split(',').join('\n'))
                            for(var i2=0;i2<subFolderList.length;i2++){
                                let c2=subFolderList[i]
                                if(c2==='.' || c2==='..')continue
                                let subFolder2=subFolder+'/'+c2
                                let fileList2=unikHere.getFileList(subFolder2, ['*.qml', '*'], false)
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
        if(lm.get(lv.currentIndex).txt==='AutoClear'){
            apps.cleanAuto=!apps.cleanAuto
            if(apps.cleanAuto){
                log('Se ha seteado esta aplicación para que limpie la carpeta de instalación automáticamente cada vez que se encienda.')
            }else{
                log('Se ha desactivado la función de auto borrado de carpeta de instalación.')
            }
        }

        //SET BOOL ENGINE LOAD DATA
        if(lm.get(lv.currentIndex).txt==='EngineLoad'){
            apps.engineLoadData=!apps.engineLoadData
            if(apps.engineLoadData){
                log('A partir de ahora el código fuente de la aplicación se cargará en esta ventana actual reemplazando todo lo que se está viendo y ejecutando en este momento.')
            }else{
                log('A partir de ahora el código fuente se cargará en una nueva ventana de aplicación.')
            }
        }

        //SET BOOL AUTO LOAD
        if(lm.get(lv.currentIndex).txt==='AutoLoad'){
            apps.autoLoad=!apps.autoLoad
            if(apps.autoLoad){
                log('A partir de ahora el código fuente de la aplicación se cargará automáticamente.')
            }else{
                log('A partir de ahora para cargar el código fuente deberá presionar el botón Lanzar.')
            }
        }

        //if(lv.currentIndex===lm.count-1){
        if(lm.get(lv.currentIndex).txt==='!Salir'){
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
            let fp=unikHere.getPath(4)+'/url'
            let h=app.aUrlsReps[app.currentUrlRepIndex].replace(/ /g, '').replace(/\n/g, '')
            unikHere.setFile(fp, h)
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
            let fp=unikHere.getPath(4)+'/host'
            let h=app.aUrlsReps[app.currentUrlRepIndex].replace(/ /g, '').replace(/\n/g, '')
            unikHere.setFile(fp, h)
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
        let fp=unikHere.getPath(4)+'/host'
        let h=unikHere.getFile(fp).replace(/ /g, '').replace(/\n/g, '')
        JS.getRD(h+':8100/zool/getUZoolandVersion?r='+ms, setUZoolandVersion)
    }
    function loadApp(){
        //        log('Existe mainZoolandPath '+mainZoolandPath+'? '+unikHere.fileExist(mainZoolandPath))
        //        let m=(''+mainZoolandPath).replace('mainZooland.qml', 'main.qml')
        //        log('Existe main.qml '+m+'? '+unikHere.fileExist(m))
        //        if(Qt.platform.os==='android'){
        //            log('Existe /sdcard/Documents/mainZooland.qml ?'+unikHere.fileExist('/sdcard/Documents/mainZooland.qml'))
        //            log('Existe /sdcard/Documents/main.qml ?'+unikHere.fileExist('/sdcard/Documents/main.qml'))
        //        }

        splash.enableAn=false
        splash.t=splash.t+'\nCargando...'

        let v=apps.uZoolandNumberVersionDownloaded
        let mainLocation=''

        if(Qt.platform.os==='android'){
            mainLocation=unikHere.getPath(4)+'/mainZooland.qml'
            let fd=unikHere.getFile(unikHere.getPath(4)+'/main.qml')
            if(fd!=='error'){
                unikHere.setFile(mainLocation, fd)
            }
        }else{
            mainLocation=unikHere.getPath(4)+'/mainZooland.qml'
        }
        log('Cargando Zooland desde '+mainLocation)

        let mp=modulesPath
        if(!unikHere.folderExist(mp)){
            log('Error! La carpeta '+mp+' no existe!')
        }else{
            log('La carpeta '+mp+' no existe!')
        }

        //        let f=documentsPath+'/zooland'
        //        if(!unikHere.folderExist(f)){
        //            log('Error! La carpeta '+f+' no existe!')
        //            let bmkd=unikHere.mkdir(f, true)
        //            log('bmkd '+bmkd)
        //            if(unikHere.folderExist(f)){
        //                log('La carpeta '+f+' fue creada ahora mismo.')
        //            }else{
        //                log('Error! La carpeta '+f+' no se puede crear.')
        //            }
        //        }

        //engine.addImportPath(documentsPath+'/zooland_pn'+v+'/modules')
        if(!apps.engineLoadData){
            engine.load(mainLocation)
        }else{
            let mainQmlData=unikHere.getFile(mainLocation)
            engine.loadData(mainQmlData, 'file:./')
        }
    }
    function updateApp(num){
        if(app.dev){
            log('Actualizando de manera forzada de la aplicación...')
        }else{
            log('Actualizando aplicación...')
        }
        let f=unikHere.getPath(4)
        let fp=''
        let h=''

        if(num===1){
            let m0=apps.uZoolandZipAvailable.split('_v')
            let v=''
            if(apps.uZoolandZipAvailable!=='zooland-main.zip' && apps.uZoolandNumberVersionDownloaded >= 0){
                v=m0[1].replace('.zip', '')
            }
            f=unikHere.getPath(4)
            fp=unikHere.getPath(4)+'/url'
            h=unikHere.getFile(fp).replace(/ /g, '').replace(/\n/g, '')
            let url=h+":8100/files/"+apps.uZoolandZipAvailable
            log('\nDescargando '+url+'\n')
            //updated = unikHere.downloadGit(url,f, false);
            updated = unikHere.downloadGit(url, 'main', f, false);
            return
        }
        if(num===2){
            f=unikHere.getPath(4)
            fp=unikHere.getPath(4)+'/url'
            log('Obteniendo url desde '+fp)
            h=unikHere.getFile(fp).replace(/ /g, '').replace(/\n/g, '')
            log('Se descargaran datos de la url '+h)
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
            //updated = unikHere.downloadGit(h, 'main', f, false);
            updated = unikHere.downloadGit(h, f);
            return
        }
    }
    function clearDir(){
        let fpHost=unikHere.getPath(4)+'/host'
        let hHost=unikHere.getFile(fpHost).replace(/ /g, '').replace(/\n/g, '')
        let fpUrl=unikHere.getPath(4)+'/url'
        let hUrl=unikHere.getFile(fpUrl).replace(/ /g, '').replace(/\n/g, '')

        let borrado=unikHere.clearDir(unikHere.getPath(4))

        if(borrado){
            log('Se han eliminado todos los archivos de la carpeta '+unikHere.getPath(4))
            unikHere.setFile(fpHost, hHost)
            unikHere.setFile(fpUrl, hUrl)
        }
    }
    function setOrigin(t, o){
        let fp=unikHere.getPath(4)+'/'+t
        let h=o.replace(/ /g, '').replace(/\n/g, '')
        unikHere.setFile(fp, h)
    }
}
