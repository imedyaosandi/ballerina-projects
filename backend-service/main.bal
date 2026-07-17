import ballerina/data.xmldata;
import ballerina/http;
import ballerina/io;
import ballerina/log;

listener http:Listener httpDefaultListener = http:getDefaultListener();

final http:Client backendClient = check new ("https://webhook.site");

final http:Client backendClientWithTimeout = check new ("https://webhook.site", timeout = 5);

service / on httpDefaultListener {

    resource function post convert(@http:Payload json payload) returns xml|http:BadRequest {
        do {
            // Log the received JSON request
            io:println("Received JSON request: ", payload.toJsonString());

            // Convert JSON to XML.
            xml convertedXml = check xmldata:fromJson(payload);

            // Log the converted XML.
            io:println("Converted to XML: ", convertedXml.toString());
            return convertedXml;

        } on fail error err {
            log:printError("Failed to convert JSON to XML: " + err.message());
            return http:BAD_REQUEST;
        }
    }

    resource function get invoke(http:Request req) returns json|http:InternalServerError {
        do {
            // Extract correlation ID from request headers
            string correlationId = req.hasHeader("x-correlation-id") ? check req.getHeader("x-correlation-id") : "N/A";
            log:printInfo("Processing request with correlation ID: " + correlationId);

            // Invoke the backend with GET request
            json response = check backendClient->/["19250b4e-2881-47ea-8f0d-584b1012f02c"]();

            // Log the response with correlation ID
            io:println("Backend response for correlation ID " + correlationId + ": ", response.toJsonString());
            return response;

        } on fail error err {
            log:printError("Failed to invoke backend: " + err.message());
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get invokeWithTimeout(http:Request req) returns json|http:InternalServerError {
        do {
            // Extract correlation ID from request headers
            string correlationId = req.hasHeader("x-correlation-id") ? check req.getHeader("x-correlation-id") : "N/A";
            log:printInfo("Processing request with correlation ID: " + correlationId);

            // Invoke the backend with GET request and 5 seconds timeout
            log:printWarn("Invoking backend endpoint with 5 seconds timeout for correlation ID: " + correlationId);
            json response = check backendClientWithTimeout->/["19250b4e-2881-47ea-8f0d-584b1012f02c"]();

            // Log the response with correlation ID
            io:println("Backend response with timeout for correlation ID " + correlationId + ": ", response.toJsonString());
            return response;

        } on fail error err {
            log:printError("Failed to invoke backend with timeout: " + err.message());
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}
