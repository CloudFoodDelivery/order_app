import pymysql
import json
import os

host = "fds-db.cleo42wwet5x.us-east-1.rds.amazonaws.com"
username = "fdsadmin123"
password = "cddd0004"
database_name = "fds"

def lambda_handler(event, context):
    connection = None
    try:
        connection = pymysql.connect(host=host, user=username,
                                     password=password, database=database_name)

        if 'body' not in event:
            raise ValueError("No body found in the event")

        body = json.loads(event['body'])
        if not all(key in body for key in ['customer_id', 'restaurant_id', 'order_status', 'total_price']):
            raise ValueError("Missing required fields in the order data")

        order_data = (
            body['customer_id'],
            body['restaurant_id'],
            body['order_status'],
            body['total_price']
        )

        with connection.cursor() as cursor:
            insert_query = """
            INSERT INTO orders (customer_id, restaurant_id, order_status, total_price)
            VALUES (%s, %s, %s, %s)
            """

            cursor.execute(insert_query, order_data)

            connection.commit()

        message = "Order data inserted successfully."
        print(message)
        return {
            'statusCode': 200,
            'body': json.dumps({'message': message})
        }

    except ValueError as ve:
        error_message = f"Validation Error: {str(ve)}"
        print(error_message)
        return {
            'statusCode': 400,
            'body': json.dumps({'error': error_message})
        }
    except pymysql.MySQLError as e:
        error_message = f"Database Error: {str(e)}"
        print(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_message})
        }
    except Exception as e:
        error_message = f"Unexpected Error: {str(e)}"
        print(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_message})
        }
    finally:
        if connection:
            connection.close()