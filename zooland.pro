#Entorno
#GNU/Linux Ubuntu 20.04
#Qt5.14.2
#Android Sdk 26.1.1
#Android Ndk 21.3.xx

QT += qml quick sql websockets webchannel svg serialport
QT += texttospeech
android:{
    QT += androidextras
}
#PKGCONFIG += openssl
#QT += webview


CONFIG += c++11

android:{
    include(openssl.pri)
    DESTDIR=$$PWD/..
}else{
    DESTDIR=/home/ns/nsp/build_zooland_linux_5.14.2
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
    android/AndroidManifest.xml \
    android/build.gradle \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew \
    android/gradlew.bat \
    android/gradlew.bat \
    android/res/values/strings.xml \
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

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
