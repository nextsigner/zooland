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
    ufd.append(u.getPath(4));
    //ufd.append("/zooland");
    QDir::setCurrent(ufd);

    //Add properties
    QByteArray cd="";
    cd.append(QDir::currentPath());
    engine.rootContext()->setContextProperty("currentDir", cd);

    //Add import path for folder./modules
    QByteArray modulesPath="";
    QByteArray mainLocation="";
    mainLocation.append(QDir::currentPath());
    modulesPath.append(mainLocation);
    modulesPath.append("/modules");
    engine.addImportPath(modulesPath);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
