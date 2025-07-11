def lambda_handler(event, context):
    # Hardcoded DB credentials for testing only
    host = "<HOST>"
    dbname = "education"
    user = "edu"
    password = "<PASSWORD>"
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
