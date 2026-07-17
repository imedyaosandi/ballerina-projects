import ballerina/http;
import ballerina/io;
import ballerina/lang.regexp;
import ballerina/log;

final http:Client webhookClient = check new ("https://webhook.site");
final http:Client domainClient = check new ("https://test123.domain.com");

type ProcessedData record {
    string fileName;
    int wordCount;
    string webhookResponse;
};

public function main() returns error? {
    string webhookRequestId = "N/A";
    string webhookCorrelationId = "N/A";
    string domainRequestId = "N/A";
    string domainCorrelationId = "N/A";

    do {
        io:println("Starting file processing...");

        //string filePath = "sample.txt";
        string fileContent = "test new file content"; // Placeholder for actual file reading logic
        string[] words = regexp:split(re `\s+`, fileContent);
        int wordCount = words.length();

        io:println("File processed successfully. Word count: ", wordCount);

        // Invoke webhook.site backend
        io:println("Invoking webhook.site...");
        http:Response webhookHttpResponse = check webhookClient->get("/19250b4e-2881-47ea-8f0d-584b1012f02c");
        
        // Log request/correlation ID from webhook response
        webhookRequestId = webhookHttpResponse.hasHeader("x-request-id") ? 
            check webhookHttpResponse.getHeader("x-request-id") : "N/A";
        webhookCorrelationId = webhookHttpResponse.hasHeader("x-correlation-id") ? 
            check webhookHttpResponse.getHeader("x-correlation-id") : "N/A";
        io:println("Webhook Request ID: ", webhookRequestId);
        io:println("Webhook Correlation ID: ", webhookCorrelationId);
        
        string webhookResponse = check webhookHttpResponse.getTextPayload();
        io:println("Webhook response received: ", webhookResponse);


        // Invoke test123.domain.com backend
        io:println("Invoking test123.domain.com...");
        http:Response domainResponse = check domainClient->post("/", webhookResponse);
        
        // Log request/correlation ID from domain response
        domainRequestId = domainResponse.hasHeader("x-request-id") ? 
            check domainResponse.getHeader("x-request-id") : "N/A";
        domainCorrelationId = domainResponse.hasHeader("x-correlation-id") ? 
            check domainResponse.getHeader("x-correlation-id") : "N/A";
        io:println("Domain Request ID: ", domainRequestId);
        io:println("Domain Correlation ID: ", domainCorrelationId);
        io:println("Domain backend response status: ", domainResponse.statusCode);
        
        string domainResponseBody = check domainResponse.getTextPayload();
        io:println("Domain backend response: ", domainResponseBody);

        io:println("All operations completed successfully.");
    } on fail error e {
        log:printError("File processing failed: " + e.message() + 
            " | Webhook Request ID: " + webhookRequestId + 
            " | Webhook Correlation ID: " + webhookCorrelationId + 
            " | Domain Request ID: " + domainRequestId + 
            " | Domain Correlation ID: " + domainCorrelationId);
        return e;
    }
}
