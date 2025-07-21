#This script will connect to api_gateway service but also will post data to AWS RDS database:
import json
import requests
import boto3
import os
import psycopg2

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

def lambda_handler(event, context):
    # First, fetch the secret
    secret = get_secret()

    # Hardcoded DB credentials for testing only
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

        cursor.execute("SELECT * FROM users LIMIT 5;")  # Update table name if needed
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

