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
            # Extract order items data from the event
            orders_items_data = event.get('orders_items_data', [])

            # SQL query for inserting data into the order_items table
            insert_query = """
            INSERT INTO order_items (order_id, food_item_id, quantity, price)
            VALUES (%s, %s, %s, %s)
            """

            # Execute the insert query for each row of data
            for order_item in orders_items_data:
                cursor.execute(insert_query, order_item)

            # Commit the changes
            connection.commit()

            print(f"{len(orders_items_data)} order items data inserted successfully.")

    except pymysql.MySQLError as e:
        print(f"Error: {e}")
    finally:
        if connection:
            connection.close()

# Note: No need to call the handler function directly, AWS Lambda will invoke lambda_handler