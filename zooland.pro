#Linux Deploy
#Deploy Command Line Example


#1) Situarse en la carpeta principal. cd ~

#2) Edit default.desktop

#3)  ~/linuxdeployqt-continuous-x86_64.AppImage /home/ns/nsp/zooland/build_zooland_linux/zooland -qmldir=/home/ns/unik -qmake=/home/ns/Qt/5.15.2/gcc_64/bin/qmake -verbose=3


#4 optional) Copy full plugins and qml folder for full qtquick support.
#Copy <QT-INSTALL>/gcc_64/qml and <QT-INSTALL>/gcc_64/plugins folders manualy to the executable folder location.
#cp -r ~/Qt5.12.3/5.12.3/gcc_64/qml ~/nsp/build_zooland_linux/
#cp -r ~/Qt5.12.3/5.12.3/gcc_64/plugins ~/nsp/build_zooland_linux/

#Make Unik AppImage (The AppImage version is maked automatically from ./build_linux/default.desktop file)
#5) ~/linuxdeployqt-continuous-x86_64.AppImage /home/ns/nsp/build_zooland_linux/zooland -qmldir=/home/ns/nsp/zooland -qmake=/home/ns/Qt5.12.3/5.12.3/gcc_64/bin/qmake -verbose=3 -bundle-non-qt-libs -no-plugins -appimage

#Si hay fallas con los drivesr Sqlite o MySql
#hay que renombrar los archivos
#cd ~/Qt5.12.3/5.12.3/gcc_64/plugins/sqldrivers
#mv libqsqlmysql.so libqsqlmysql.so_ignore
#mv libqsqlpsql.so libqsqlpsql.so_ignore


QT += quick
QT += qml quick sql websockets webchannel svg serialport
QT += texttospeech
#PKGCONFIG += openssl
#QT += webview
#QT += androidextras

CONFIG += c++11

include(openssl.pri)
#android: include(/home/ns/Android/Sdk/android_openssl/openssl.pri)

android:{
    DESTDIR=$$PWD/..
}else{
    DESTDIR=/home/ns/nsp/build_zooland_linux
}


# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        chatserver.cpp \
        main.cpp \
        row.cpp \
        uk.cpp \
        websocketclientwrapper.cpp \
        websockettransport.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

INCLUDEPATH += $$PWD/quazip
LIBS += -lz

INCLUDEPATH+=/usr/local/zlib/include
HEADERS += $$PWD/quazip/*.h \
    chatserver.h \
    websocketclientwrapper.h \
    websockettransport.h
SOURCES += $$PWD/quazip/*.cpp
SOURCES += $$PWD/quazip/*.c

linux:{
    #LIBS+=-lcrypto
}
DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

contains(ANDROID_TARGET_ARCH,arm64-v8a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}

HEADERS += \
    row.h \
    uk.h

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
    $$PWD/android_openssl-5.12.4_5.13.0/arm/libcrypto.so \
    $$PWD/android_openssl-5.12.4_5.13.0/arm/libssl.so
}
