import ballerina/data.xmldata;
import ballerina/http;
import ballerina/io;
import ballerina/log;

configurable string username = ?;
configurable string password = ?;

listener http:Listener httpDefaultListener = http:getDefaultListener();

final http:Client backendClient = check new ("https://webhook.site");

final http:Client backendClientWithTimeout = check new ("https://webhook.site", timeout = 5);

service / on httpDefaultListener {

    resource function post convert(@http:Payload json payload) returns xml|http:BadRequest|http:InternalServerError {
        do {
            // Log the received JSON request
            io:println("Received JSON request: ", payload.toJsonString());

            // Validate payload is not empty
            if payload.toString().trim() == "" {
                log:printError("Empty payload received");
                return http:BAD_REQUEST;
            }

            // Convert JSON to XML.
            xml convertedXml = check xmldata:fromJson(payload);

            // Log the converted XML.
            io:println("Converted to XML: ", convertedXml.toString());
            return convertedXml;

        } on fail error err {
            log:printError("Failed to convert JSON to XML", 'error = err);
            
            // Check if it's a data conversion error
            if err.message().includes("conversion") || err.message().includes("parse") {
                return http:BAD_REQUEST;
            }
            
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get invoke(http:Request req) returns json|http:InternalServerError|http:ServiceUnavailable {
        // Extract correlation ID from request headers
        string|error correlationIdResult = req.getHeader("x-correlation-id");
        string correlationId = correlationIdResult is string ? correlationIdResult : "N/A";
        
        do {
            log:printInfo("Processing request with correlation ID: " + correlationId);

            // Invoke the backend with GET request
            json response = check backendClient->/["19250b4e-2881-47ea-8f0d-584b1012f02c"]();

            // Log the response with correlation ID
            io:println("Backend response for correlation ID " + correlationId + ": ", response.toJsonString());
            return response;

        } on fail error err {
            log:printError("Failed to invoke backend for correlation ID " + correlationId, 'error = err);
            
            // Check for specific error types
            string errorMsg = err.message().toLowerAscii();
            if errorMsg.includes("timeout") || errorMsg.includes("connection") {
                log:printError("Backend service unavailable for correlation ID " + correlationId);
                return http:SERVICE_UNAVAILABLE;
            }
            
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get invokeWithTimeout(http:Request req) returns json|http:InternalServerError|http:RequestTimeout|http:ServiceUnavailable {
        // Extract correlation ID from request headers
        string|error correlationIdResult = req.getHeader("x-correlation-id");
        string correlationId = correlationIdResult is string ? correlationIdResult : "N/A";
        
        do {
            log:printInfo("Processing request with correlation ID: " + correlationId);

            // Invoke the backend with GET request and 5 seconds timeout
            log:printWarn("Invoking backend endpoint with 5 seconds timeout for correlation ID: " + correlationId);
            json response = check backendClientWithTimeout->/["19250b4e-2881-47ea-8f0d-584b1012f02c"]();

            // Log the response with correlation ID
            io:println("Backend response with timeout for correlation ID " + correlationId + ": ", response.toJsonString());
            return response;

        } on fail error err {
            log:printError("Failed to invoke backend with timeout for correlation ID " + correlationId, 'error = err);
            
            // Check for specific error types
            string errorMsg = err.message().toLowerAscii();
            if errorMsg.includes("timeout") {
                log:printError("Request timeout for correlation ID " + correlationId);
                return http:REQUEST_TIMEOUT;
            }
            
            if errorMsg.includes("connection") || errorMsg.includes("unavailable") {
                log:printError("Backend service unavailable for correlation ID " + correlationId);
                return http:SERVICE_UNAVAILABLE;
            }
            
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get invokeAlternate(http:Request req) returns json|http:InternalServerError|http:ServiceUnavailable {
        // Extract correlation ID from request headers
        string|error correlationIdResult = req.getHeader("x-correlation-id");
        string correlationId = correlationIdResult is string ? correlationIdResult : "N/A";
        
        do {
            log:printInfo("Processing alternate request with correlation ID: " + correlationId);

            // Invoke the alternate backend endpoint
            json response = check backendClient->/["c07f2fed-0554-402e-8728-beeb73d68e04"]();

            // Log the response with correlation ID
            io:println("Alternate backend response for correlation ID " + correlationId + ": ", response.toJsonString());
            return response;

        } on fail error err {
            log:printError("Failed to invoke alternate backend for correlation ID " + correlationId, 'error = err);
            
            // Check for specific error types
            string errorMsg = err.message().toLowerAscii();
            if errorMsg.includes("timeout") || errorMsg.includes("connection") {
                log:printError("Alternate backend service unavailable for correlation ID " + correlationId);
                return http:SERVICE_UNAVAILABLE;
            }
            
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get redirect() returns http:Found {
        http:Found redirectResponse = {
            body: "Redirecting to new location",
            headers: {
                "Location": "https://webhook.site/c07f2fed-0554-402e-8728-beeb73d68e04"
            }
        };
        log:printInfo("Redirecting client with 302 status");
        return redirectResponse;
    }

    resource function get credentials() returns json|http:InternalServerError {
        do {
            log:printInfo("Accessing credentials");
            
            // Validate credentials are configured
            if username.trim() == "" {
                log:printError("Username not configured");
                return http:INTERNAL_SERVER_ERROR;
            }
            
            return {
                username: username,
                message: "Credentials accessed successfully"
            };
            
        } on fail error err {
            log:printError("Failed to access credentials", 'error = err);
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}
