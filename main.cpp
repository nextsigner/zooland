#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QtTextToSpeech/QTextToSpeech>
#include <QLoggingCategory>

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#endif
#include "uk.h"

#ifndef Q_OS_ANDROID
#include "micurl.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    //QGuiApplication app(argc, argv);



    QGuiApplication app(argc, argv);
    app.setApplicationName("Zooland");
    app.setOrganizationName("Unikode.org");
    app.setOrganizationDomain("http://unikey.loca.lt");
    app.setApplicationVersion("1.31");

    UK u;
#ifndef Q_OS_ANDROID
    MICURL curl;// = new MICURL(this); // Usa MICURL
#endif

    qmlRegisterType<UK>("unik.UnikHere", 1, 0, "UnikHere");


    QQmlApplicationEngine engine;

    //-->Android Permissions
#ifdef Q_OS_ANDROID
    auto  result = QtAndroid::checkPermission(QString("android.permission.CAMERA"));
    if(result == QtAndroid::PermissionResult::Denied){
        QtAndroid::PermissionResultMap resultHash = QtAndroid::requestPermissionsSync(QStringList({"android.permission.CAMERA"}));
        if(resultHash["android.permission.CAMERA"] == QtAndroid::PermissionResult::Denied)
            return 0;
    }
    auto  result2 = QtAndroid::checkPermission(QString("android.permission.WRITE_EXTERNAL_STORAGE"));
    if(result2 == QtAndroid::PermissionResult::Denied){
        QtAndroid::PermissionResultMap resultHash = QtAndroid::requestPermissionsSync(QStringList({"android.permission.WRITE_EXTERNAL_STORAGE"}));
        if(resultHash["android.permission.WRITE_EXTERNAL_STORAGE"] == QtAndroid::PermissionResult::Denied)
            return 0;
    }
    auto  result3 = QtAndroid::checkPermission(QString("android.permission.READ_EXTERNAL_STORAGE"));
    if(result3 == QtAndroid::PermissionResult::Denied){
        QtAndroid::PermissionResultMap resultHash = QtAndroid::requestPermissionsSync(QStringList({"android.permission.READ_EXTERNAL_STORAGE"}));
        if(resultHash["android.permission.READ_EXTERNAL_STORAGE"] == QtAndroid::PermissionResult::Denied)
            return 0;
    }
    auto  result4 = QtAndroid::checkPermission(QString("android.permission.INTERNET"));
    if(result4 == QtAndroid::PermissionResult::Denied){
        QtAndroid::PermissionResultMap resultHash = QtAndroid::requestPermissionsSync(QStringList({"android.permission.INTERNET"}));
        if(resultHash["android.permission.INTERNET"] == QtAndroid::PermissionResult::Denied)
            return 0;
    }else {
        qInfo()<<"Este dispositivo tiene permiso para INTERNET.";
    }
#endif
    //<--Android Permissions

    //--> TTS
    QLoggingCategory::setFilterRules(QStringLiteral("qt.speech.tts=true \n qt.speech.tts.*=true"));
    //∫qDebug()<<"TTS AVAILABLE ENGINES: "<<QTextToSpeech::availableEngines();
    QTextToSpeech *tts2 = new QTextToSpeech(QTextToSpeech::availableEngines().at(0));
    u.tts = qobject_cast<QTextToSpeech *>( tts2 );
    Q_ASSERT( u.tts != nullptr );
    QObject::connect(u.tts, SIGNAL(stateChanged(QTextToSpeech::State)), &u, SLOT(stateChanged(QTextToSpeech::State)));
    //qDebug()<<"TTS AVAILABLE ENGINES: "<<u.tts->availableEngines();
    u.ttsEnginesList = u.tts->availableEngines();
    QVoice currentVoice = u.tts->voice();
    foreach (QVoice voice, u.tts->availableVoices()){
        u.ttsVoices.append(voice);
        u.ttsVoicesList.append(QString("%1 - %2 - %3").arg(voice.name())
                               .arg(QVoice::genderName(voice.gender()))
                               .arg(QVoice::ageName(voice.age())));
        if (voice.name() == currentVoice.name())
            u.ttsCurrentVoice = u.ttsVoicesList.at(u.ttsVoicesList.count() - 1);
    }
    QVector<QLocale> locales = u.tts->availableLocales();
    QLocale current = u.tts->locale();
    foreach (const QLocale &locale, locales) {
        QString name(QString("%1 (%2)")
                     .arg(QLocale::languageToString(locale.language()))
                     .arg(QLocale::countryToString(locale.country())));
        QLocale localeVariant(locale);
        u.ttsLocales.append(name);
        u.ttsLocalesVariants.append(localeVariant);
        if (locale.name() == current.name())
            u.ttsCurrentLocale = locale;
    }
    QObject::connect(&u, &UK::ttsSelectingEngine, [&tts2, &u](const int index){
        QString engineName = u.ttsEnginesList.at(index);
        delete tts2;
        if (engineName == "default"){
            tts2 = new QTextToSpeech();
        }else{
            tts2 = new QTextToSpeech(engineName);
        }
        u.tts = tts2;
    });

    engine.rootContext()->setContextProperty("ttsEngines", u.ttsEnginesList);
    engine.rootContext()->setContextProperty("ttsVoices", u.ttsVoicesList);
    engine.rootContext()->setContextProperty("ttsCurrentVoice", u.ttsCurrentVoice);
    engine.rootContext()->setContextProperty("ttsLocales", u.ttsLocales);
    //<-- TTS



    //QByteArray ufd=""; //Unik Folder Data
    //ufd.append(u.getPath(4));
    //ufd.append(u.getPath(8));
    //ufd.append("/zooland");
    //QDir::setCurrent(ufd);
    QDir::setCurrent(u.getPath(4));

    QByteArray host="http://zool.loca.lt";
    QByteArray fileHost="";
    fileHost.append(u.getPath(4));
    fileHost.append("/host");
    if(!u.fileExist(fileHost)){
        u.setFile(fileHost, host);
    }

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
#ifndef Q_OS_ANDROID
    engine.rootContext()->setContextProperty("curl", &curl);
#endif

    //engine.rootContext()->setContextProperty("folderIsWritable", folderIsWritable);
    //engine.rootContext()->setContextProperty("dato1FileData", dato1FileData);


    engine.rootContext()->setContextProperty("engine", &engine);
    engine.rootContext()->setContextProperty("mainZoolandPath", mainLocation);
    engine.rootContext()->setContextProperty("unik", &u);
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
        //Probando Zooland Release
        QByteArray carpetaDev="zooland-release";

        //Probando Zooland Control Release
        //carpetaDev="zooland-control-release";


        QDir::setCurrent(("/home/ns/nsp/"+carpetaDev));
        engine.addImportPath(QDir::currentPath()+"/modules");
        mainLocation="";
        mainLocation.append("/home/ns/nsp/"+carpetaDev);
        mainLocation.append("/main.qml");

        //Descomentar para probar el qrc:main.qml mientras se programa en GNU/Linux.
        mainLocation="qrc:main.qml";

        const QUrl url3(mainLocation);
        engine.load(url3);
    }else{
        const QUrl url2("qrc:main.qml");
        engine.load(url2);
    }
#endif


    return app.exec();
}
