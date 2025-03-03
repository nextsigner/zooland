#ifndef MICURL_H
#define MICURL_H

#include <QObject>
#include <QString>
#include <curl/curl.h>

class MICURL : public QObject
{
    Q_OBJECT

public:
    explicit MICURL(QObject *parent = nullptr);

public slots:
    void getFinalDownloadUrl(const QString &sourceforgeUrl);

signals:
    void finalDownloadUrlReady(const QString &finalUrl);
    void downloadError(const QString &errorMessage);

private:
    static size_t writeCallback(char* contents, size_t size, size_t nmemb, std::string* output);
    QString getFinalUrlUsingCurl(const QString &url);
};

#endif // MICURL_H
