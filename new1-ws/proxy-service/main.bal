import ballerina/http;
import ballerina/log;

// Backend URLs (overridable via Config.toml or env vars)
configurable string endpoint1Backend = "https://webhook.site/19250b4e-2881-47ea-8f0d-584b1012f02c";
configurable string endpoint2Backend = "https://webhook.site/fcda4a0b-4176-4f4e-9070-f1af24d8a4df";

// Listener port for this service
configurable int servicePort = 8080;

final http:Client endpoint1Client = check new (endpoint1Backend);
final http:Client endpoint2Client = check new (endpoint2Backend);

service / on new http:Listener(servicePort) {

    // Proxies any request under /endpoint1 to endpoint1Backend
    resource function default endpoint1(http:Request req) returns http:Response|error {
        log:printInfo("Forwarding request to endpoint1 backend", backend = endpoint1Backend);
        http:Response|error resp = endpoint1Client->forward("/", req);
        if resp is error {
            log:printError("Error forwarding to endpoint1 backend", 'error = resp);
            return resp;
        }
        return resp;
    }

    // Proxies any request under /endpoint2 to endpoint2Backend
    resource function default endpoint2(http:Request req) returns http:Response|error {
        log:printInfo("Forwarding request to endpoint2 backend", backend = endpoint2Backend);
        http:Response|error resp = endpoint2Client->forward("/", req);
        if resp is error {
            log:printError("Error forwarding to endpoint2 backend", 'error = resp);
            return resp;
        }
        return resp;
    }
}
