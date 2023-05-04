#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "uk.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<UK>("unik.Unik", 1, 0, "Unik");

    QQmlApplicationEngine engine;


    UK u;
    QByteArray ufd=""; //Unik Folder Data
    //ufd.append(u.getPath(4));
    ufd.append(u.getPath(8));
    //ufd.append("/zooland");
    QDir::setCurrent(ufd);

    //Add properties
    QByteArray dp="";
    dp.append(u.getPath(3));
    engine.rootContext()->setContextProperty("documentPath", dp);

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
    updated = u.downloadGit("http://zool.loca.lt/files/zooland-main.zip",dp, false);
#else
    //updated = u.downloadZipFile("http://zool.loca.lt/files/zooland-main.zip",cd);
    //updated = u.downloadGit("http://zool.loca.lt/files/zooland-main.zip",cd, false);
#endif

    //QString s;
    //s.append(u.getHttpFile("http://zool.loca.lt"));
    //qDebug()<<s;
    //Add import path for folder./modules
    QByteArray modulesPath="";
    modulesPath.append(QDir::currentPath());
    QByteArray mainLocation="";
    mainLocation.append(QDir::currentPath());
#ifdef Q_OS_ANDROID
    mainLocation.append("/mainZooland.qml");
#else
    mainLocation="";
    mainLocation.append("/home/ns/nsp/zooland-release");
    mainLocation.append("/mainZooland.qml");
#endif
    modulesPath.append("/modules");
    engine.addImportPath(modulesPath);

    engine.rootContext()->setContextProperty("updated", updated);
    engine.rootContext()->setContextProperty("folderIsWritable", folderIsWritable);
    engine.rootContext()->setContextProperty("dato1FileData", dato1FileData);

    //const QUrl url(mainLocation);
    const QUrl url(QStringLiteral("qrc:main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    //engine.load(url);
#ifdef Q_OS_ANDROID
    if(updated){
        engine.load(mainLocation);
    }else{
        engine.load(url);
    }
#else
    QDir::setCurrent("/home/ns/nsp/zooland-release/");
    engine.addImportPath("/home/ns/nsp/zooland-release/modules");
    const QUrl url2(QStringLiteral("file:///home/ns/nsp/zooland-release/mainZooland.qml"));
    engine.load(url2);
#endif


    return app.exec();
}
