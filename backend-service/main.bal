import ballerina/data.xmldata;
import ballerina/http;
import ballerina/io;
import ballerina/log;

listener http:Listener httpDefaultListener = http:getDefaultListener();

final http:Client backendClient = check new ("https://webhook.site");

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

    resource function get invoke() returns json|http:InternalServerError {
        do {
            // Invoke the backend with GET request
            json response = check backendClient->/["19250b4e-2881-47ea-8f0d-584b1012f02c"]();

            // Log the response
            io:println("Backend response: ", response.toJsonString());
            return response;

        } on fail error err {
            log:printError("Failed to invoke backend: " + err.message());
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}
