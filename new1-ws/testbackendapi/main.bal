import ballerina/http;
import ballerina/log;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /endpoint1 on httpDefaultListener {
    resource function post test1(@http:Payload json payload) returns json|error {
        log:printInfo("Received request, invoking backend...");
        
        // Invoke the backend webhook
        json response = check httpClient->post("/", payload);
        
        log:printInfo("Backend invoked successfully");
        return response;
    }

    resource function get test2() returns json|error {
        log:printInfo("Received GET request, invoking backend...");
        
        // Invoke the backend webhook with GET
        json response = check httpClient->get("/");
        
        log:printInfo("Backend invoked successfully");
        return response;
    }
}
