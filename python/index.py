#This script will connect to api_gateway service but also will post data to AWS RDS database:
import json
import requests
import boto3
import os
import psycopg2


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

def get_secret(secret_name="postgres-credentials", region_name="eu-central-1"):
    """
    Retrieve secrets from AWS Secrets Manager
    """
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        return secret
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        raise
        
def get_db_info(event):
    """ Handles GET requests to fetch RDS DB data """
    # First, fetch the secret
    secret = get_secret()

    # url = f"http://www.omdbapi.com/?t={movie_title}&apikey={api_key}"
    # response = requests.get(url)
    # return {"statusCode": response.status_code, "body": json.dumps(response.json())}

    # Secrets from AWS & hardcoded DB credentials for testing only
    host = secret["host"]
    dbname = "education"
    user = "edu"
    password = secret["password"]
    port = 5432

    try:
        conn = psycopg2.connect(
            host=host,
            database=dbname,
            user=user,
            password=password,
            port=port
        )
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM users ORDER BY id DESC LIMIT 5;")  # Update table name if needed
        rows = cursor.fetchall()

        cursor.close()
        conn.close()

        return {
            "statusCode": 200,
            "body": str(rows)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error: {str(e)}"
        }

def save_user_info(event):
    """ Handles POST requests to save user data in PostgreSQL RDS """
    try:
        # Parse request body
        body = json.loads(event.get("body", "{}"))
        name = body.get("name")
        favorite_movie = body.get("favorite_movie")

        if not name or not favorite_movie:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing required fields: name and favorite_movie"})
            }

        # Get DB credentials from Secrets Manager
        secret = get_secret()
        host = secret["host"]
        dbname = "education"
        user = "edu"
        password = secret["password"]
        port = 5432

        # Connect to PostgreSQL and insert data
        conn = psycopg2.connect(
            host=host,
            database=dbname,
            user=user,
            password=password,
            port=port
        )
        cursor = conn.cursor()

        insert_query = "INSERT INTO users (name, favorite_movie) VALUES (%s, %s);"
        cursor.execute(insert_query, (name, favorite_movie))
        conn.commit()

        cursor.close()
        conn.close()

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "User info saved successfully"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

def lambda_handler(event, context):
    """ Main Lambda handler that routes GET and POST requests """
    http_method = event["httpMethod"]

    if http_method == "GET":
        return get_db_info(event)
    elif http_method == "POST":
        return save_user_info(event)
    else:
        return {"statusCode": 405, "body": json.dumps({"error": "Method not allowed"})}

#TESTING API CALL with URL: https://<URL>?apikey=<APIKEY>&t=titanic