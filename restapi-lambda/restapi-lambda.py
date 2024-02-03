import boto3
import json

# Create a DynamoDB client
dynamo = boto3.client("dynamodb", region_name="us-east-1")

# Define the table name
table_name = "items"

# Define the handler function that the Lambda service will use as an entry point
def lambda_handler(event, context):
    # Print the received event
    print("Received event: " + json.dumps(event, indent=2))

    # Get the HTTP method from the event
    method = event["requestContext"]["http"]["method"]

    # Get the resource path from the event
    path = event["requestContext"]["http"]["path"]

    # Initialize the response
    response = {}

    # Perform CRUD operations based on the method and path
    try:
        if method == "GET" and path == "/items/{id}":
            # Get an item from the table
            body = dynamo.get_item(
                TableName=table_name,
                Key={
                    "id": {"S": event["pathParameters"]["id"]}
                }
            )
            body = body["Item"]
        elif method == "GET" and path == "/items":
            # Scan the table and return all items
            body = dynamo.scan(TableName=table_name)
            body = body["Items"]
        elif method == "POST" and path == "/items":
            # Put an item to the table
            body = json.loads(event["body"])
            dynamo.put_item(
                TableName=table_name,
                Item={
                    "id": {"S": body["id"]},
                    "name": {"S": body["name"]},
                    "description": {"S": body["description"]}
                }
            )
            body = {"message": "Item created successfully"}
        elif method == "PUT" and path == "/items/{id}":
            # Update an item in the table
            body = json.loads(event["body"])
            dynamo.update_item(
                TableName=table_name,
                Key={
                    "id": {"S": event["pathParameters"]["id"]}
                },
                UpdateExpression="SET name = :n, description = :d",
                ExpressionAttributeValues={
                    ":n": {"S": body["name"]},
                    ":d": {"S": body["description"]}
                }
            )
            body = {"message": "Item updated successfully"}
        elif method == "DELETE" and path == "/items/{id}":
            # Delete an item from the table
            dynamo.delete_item(
                TableName=table_name,
                Key={
                    "id": {"S": event["pathParameters"]["id"]}
                }
            )
            body = {"message": "Item deleted successfully"}
        else:
            # Return an error for unsupported operations
            response["statusCode"] = 400
            body = {"error": "Unsupported method or path"}
    except Exception as e:
        # Return an error if something goes wrong
        print(e)
        response["statusCode"] = 500
        body = {"error": "Internal server error"}

    # Format the response
    response["headers"] = {"Content-Type": "application/json"}
    response["body"] = json.dumps(body)
    return response