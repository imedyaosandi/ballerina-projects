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
    do {
        io:println("Starting file processing...");

        string filePath = "sample.txt";
        string fileContent = "test new file content"; // Placeholder for actual file reading logic
        string[] words = regexp:split(re `\s+`, fileContent);
        int wordCount = words.length();

        io:println("File processed successfully. Word count: ", wordCount);

        // Invoke webhook.site backend
        io:println("Invoking webhook.site...");
        string webhookResponse = check webhookClient->get("/fcda4a0b-4176-4f4e-9070-f1af24d8a4df");
        io:println("Webhook response received: ", webhookResponse);

        // Prepare data to send to second backend
        ProcessedData processedData = {
            fileName: filePath,
            wordCount: wordCount,
            webhookResponse: webhookResponse
        };

        // Invoke test123.domain.com backend
        io:println("Invoking test123.domain.com...");
        http:Response domainResponse = check domainClient->post("/", processedData);
        io:println("Domain backend response status: ", domainResponse.statusCode);
        
        string domainResponseBody = check domainResponse.getTextPayload();
        io:println("Domain backend response: ", domainResponseBody);

        io:println("All operations completed successfully.");
    } on fail error e {
        log:printError("File processing failed: " + e.message());
        return e;
    }
}
