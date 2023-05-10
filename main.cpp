#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "uk.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setApplicationName("Zooland");
    app.setOrganizationName("Unikode.org");
    app.setOrganizationDomain("http://zool.loca.lt");
    app.setApplicationVersion("1");

    qmlRegisterType<UK>("unik.Unik", 1, 0, "Unik");

    QQmlApplicationEngine engine;


    UK u;
    //QByteArray ufd=""; //Unik Folder Data
    //ufd.append(u.getPath(4));
    //ufd.append(u.getPath(8));
    //ufd.append("/zooland");
    //QDir::setCurrent(ufd);
    QDir::setCurrent(u.getPath(4));

    //Add properties
//    QDir mypath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
//    //QDir::setCurrent(mypath.currentPath());
//    if(!mypath.cd("zooland2"))
//    {
//        if(mypath.mkpath("zooland"))
//            qDebug() << "path created";
//        else
//            qDebug() << "path not created";
//    }
//    else
//    {
//        qDebug() << "inside dir";
//    }

    QByteArray dp="";
    dp.append(u.getPath(4));
    engine.rootContext()->setContextProperty("documentsPath", dp);

    QByteArray cd="";
    cd.append(QDir::currentPath());
    engine.rootContext()->setContextProperty("currentDir", cd);

    //bool updated = u.downloadGit("https://github.com/nextsigner/zooland-release", cd);
    u.debugLog=false;
    bool updated=false;
    bool folderIsWritable=false;
    QString dato1FileData="nada";
#ifdef Q_OS_ANDROID
    QByteArray dato1="Dato 1";
    QByteArray fileDato1="";
    fileDato1.append(cd);
    fileDato1.append("/dato1.txt");
    u.setFile(fileDato1, dato1);
    folderIsWritable=u.fileExist(fileDato1);
    if(folderIsWritable){
        dato1FileData.append(u.getFile(fileDato1));
    }
    //updated = u.downloadGit("https://github.com/nextsigner/zooland-release", cd);
    //updated = u.downloadZipFile("http://zool.loca.lt/files/zooland-main.zip", cd);
    //updated = u.downloadGit("http://zool.loca.lt/files/zooland-main.zip",dp, false);
#else
    //updated = u.downloadZipFile("http://zool.loca.lt/files/zooland-main.zip",cd);
    //updated = u.downloadGit("http://zool.loca.lt/files/zooland-main.zip",cd, false);
    updated = false;//u.downloadGit("http://zool.loca.lt/files/zooland-main.zip",dp, false);
#endif

    //QString s;
    //s.append(u.getHttpFile("http://zool.loca.lt"));
    //qDebug()<<s;
    //Add import path for folder./modules
    QByteArray modulesPath="";
    modulesPath.append(u.getPath(4));
    modulesPath.append("/modules");
    engine.addImportPath(modulesPath);

    QByteArray mainLocation="";
    mainLocation.append(QDir::currentPath());
#ifdef Q_OS_ANDROID
    mainLocation="";
    mainLocation.append(u.getPath(4));
    mainLocation.append("/mainZooland.qml");
#else
    mainLocation="";
    mainLocation.append("/home/ns/nsp/zooland-release");
    mainLocation.append("/main.qml");

    //mainLocation="";
    //mainLocation.append("qrc:main.qml");
#endif


    engine.rootContext()->setContextProperty("modulesPath", modulesPath);
    engine.rootContext()->setContextProperty("updated", updated);
    //engine.rootContext()->setContextProperty("folderIsWritable", folderIsWritable);
    //engine.rootContext()->setContextProperty("dato1FileData", dato1FileData);


    engine.rootContext()->setContextProperty("engine", &engine);
    engine.rootContext()->setContextProperty("mainZoolandPath", mainLocation);
    //const QUrl url(mainLocation);
    QDir::setCurrent(u.getPath(4));
    engine.addImportPath(u.getPath(4)+"/modules");

#ifdef Q_OS_ANDROID
    bool loadDirect=false;
    if(loadDirect){
        QDir::setCurrent(u.getPath(4));
        engine.addImportPath(QDir::currentPath()+"/modules");
        mainLocation="";
        mainLocation.append(QDir::currentPath());
        mainLocation.append("/main.qml");
    }else{


    }
    if(loadDirect){
        const QUrl url10(mainLocation);
        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                         &app, [url10](QObject *obj, const QUrl &objUrl) {
            if (!obj && url10 == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
        engine.load(url10);
    }else{
        const QUrl url(QStringLiteral("qrc:main.qml"));
        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                         &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
        engine.load(url);
    }
#else
    //QDir::setCurrent("/home/ns/nsp/zooland-release/");
    //engine.addImportPath("/home/ns/nsp/zooland-release/modules");
    //const QUrl url2(QStringLiteral("file:///home/ns/nsp/zooland-release/mainZooland.qml"));
    bool fromZoolandRelease=true;
    if(fromZoolandRelease){
        QDir::setCurrent(("/home/ns/nsp/zooland-release"));
        engine.addImportPath(QDir::currentPath()+"/modules");
        mainLocation="";
        mainLocation.append("/home/ns/nsp/zooland-release");
        mainLocation.append("/main.qml");

        //Descomentar para probar el qrc:main.qml mientras se programa en GNU/Linux.
        //mainLocation="qrc:main.qml";

        const QUrl url3(mainLocation);
        engine.load(url3);
    }else{
        const QUrl url2("qrc:main.qml");
        engine.load(url2);
    }
#endif


    return app.exec();
}
