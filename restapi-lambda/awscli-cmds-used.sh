# Create a DynamoDB Table
aws dynamodb create-table \
    --table-name items \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Create a Lambda Function
aws lambda create-function \
    --function-name items-api \
    --runtime python3.8 \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::123456789012:role/lambda-dynamodb-role \
    --zip-file fileb://function.zip

# Create an HTTP API
aws apigatewayv2 create-api \
    --name items-api \
    --protocol-type HTTP \
    --target arn:aws:lambda:us-east-1:123456789012:function:items-api

# Create a route for the /items path with ANY method
aws apigatewayv2 create-route \
    --api-id <api-id> \
    --route-key "ANY /items"

# Create a route for the /items/{id} path with ANY method
aws apigatewayv2 create-route \
    --api-id <api-id> \
    --route-key "ANY /items/{id}"

# Test API
# Get the API endpoint
aws apigatewayv2 get-api --api-id <api-id>

# Send requests to API
aws apigatewayv2 invoke \
    --api-id <api-id> \
    --path /items \
    --http-method GET

# Create a new item
aws apigatewayv2 invoke \
    --api-id <api-id> \
    --path /items \
    --http-method POST \
    --body '{"id": "1", "name": "Book", "description": "A good read"}'

# Get a specific item by ID
aws apigatewayv2 invoke \
    --api-id <api-id> \
    --path /items/1 \
    --http-method GET

# Update an existing item
aws apigatewayv2 invoke \
    --api-id <api-id> \
    --path /items/1 \
    --http-method PUT \
    --body '{"name": "Novel", "description": "A thrilling story"}'

# Delete an existing item
aws apigatewayv2 invoke \
    --api-id <api-id> \
    --path /items/1 \
    --http-method DELETE