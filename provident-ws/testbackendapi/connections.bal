import ballerina/http;

final http:Client httpClient = check new ("https://webhook.site/19250b4e-2881-47ea-8f0d-584b1012f02c", httpVersion = "1.1", timeout = 5, compression = "AUTO", validation = false, laxDataBinding = false);
