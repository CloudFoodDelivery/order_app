import json
import pymysql

# Database connection parameters
host = "fds-db.cleo42wwet5x.us-east-1.rds.amazonaws.com"
username = "fdsadmin123"
password = "cddd0004"
database_name = "fds"

def lambda_handler(event, context):
    connection = None
    try:
        # Establish connection to the database
        connection = pymysql.connect(host=host, user=username,
                                     password=password, database=database_name)

        with connection.cursor() as cursor:
            # Parse the incoming event data
            body = json.loads(event['body'])
            fooditems_data = body['fooditems']

            # SQL query for inserting data into the food_items table
            insert_query = """
            INSERT INTO food_items (restaurant_id, name, description, price, available)
            VALUES (%s, %s, %s, %s, %s)
            """

            # Execute the insert query for each food item
            for item in fooditems_data:
                cursor.execute(insert_query, (
                    item['restaurant_id'],
                    item['name'],
                    item['description'],
                    item['price'],
                    item['available']
                ))

            # Commit the changes
            connection.commit()

            return {
                'statusCode': 200,
                'body': json.dumps(f"{len(fooditems_data)} food items inserted successfully.")
            }

    except pymysql.MySQLError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Database error: {str(e)}")
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: {str(e)}")
        }
    finally:
        if connection:
            connection.close()