import pymysql

# Database connection parameters
host = "fds-db.cleo42wwet5x.us-east-1.rds.amazonaws.com"
username = "fdsadmin123"
password = "cddd0004"
database_name = "fds"

def lambda_handler(event, context):
    connection = None
    try:
        connection = pymysql.connect(host=host, user=username,
                                     password=password, database=database_name)

        with connection.cursor() as cursor:
            orders_items_data = event.get('orders_items_data', [])

            insert_query = """
            INSERT INTO order_items (order_id, food_item_id, quantity, price)
            VALUES (%s, %s, %s, %s)
            """

            for order_item in orders_items_data:
                cursor.execute(insert_query, order_item)

            connection.commit()

            print(f"{len(orders_items_data)} order items data inserted successfully.")

    except pymysql.MySQLError as e:
        print(f"Error: {e}")
    finally:
        if connection:
            connection.close()
