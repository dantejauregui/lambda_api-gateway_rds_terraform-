#This script will connect to api_gateway service but also will post data to AWS RDS database:
import json
import requests
import boto3
import os

# Initialize DynamoDB
# dynamodb = boto3.resource("dynamodb")
# table_name = os.getenv("DYNAMODB_TABLE", "SearchResultsTable")
# table = dynamodb.Table(table_name)

def get_movie_info(event):
    """ Handles GET requests to fetch movie data from OMDb API """
    query_params = event.get("queryStringParameters", {}) or {}
    api_key = query_params.get("apikey", None)
    movie_title = query_params.get("t", None)

    if not api_key:
        return {"statusCode": 400, "body": json.dumps({"Response": "False", "Error": "Missing apikey parameter"})}
    if not movie_title:
        return {"statusCode": 400, "body": json.dumps({"Response": "False", "Error": "Missing t parameter (movie title)"})}

    url = f"http://www.omdbapi.com/?t={movie_title}&apikey={api_key}"
    response = requests.get(url)

    return {"statusCode": response.status_code, "body": json.dumps(response.json())}

# def save_user_info(event):
#     """ Handles POST requests to save user data in DynamoDB """
#     try:
#         body = json.loads(event["body"])  # Parse incoming JSON payload
#         name = body.get("name")
#         favorite_movie = body.get("favorite_movie")
#         age = body.get("age")

#         if not name or not favorite_movie or not age:
#             return {"statusCode": 400, "body": json.dumps({"error": "Missing required fields (name, favorite_movie, age)"})}

#         # Insert into DynamoDB
#         table.put_item(Item={"name": name, "favorite_movie": favorite_movie, "age": int(age)})

#         return {"statusCode": 200, "body": json.dumps({"message": "User info saved successfully"})}
    
#     except Exception as e:
#         return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

def lambda_handler(event, context):
    """ Main Lambda handler that routes GET and POST requests """
    http_method = event["httpMethod"]

    if http_method == "GET":
        return get_movie_info(event)
    elif http_method == "POST":
        return save_user_info(event)
    else:
        return {"statusCode": 405, "body": json.dumps({"error": "Method not allowed"})}

#TESTING API CALL with URL: https://<URL>?apikey=<APIKEY>&t=titanic