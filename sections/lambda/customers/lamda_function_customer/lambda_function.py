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
        
        # Extract customer data from the event
        customer_data = event.get('customers', [])
        
        if not customer_data:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No customer data provided'})
            }
        
        with connection.cursor() as cursor:
            # SQL query for inserting data into the customers table
            insert_query = """
            INSERT INTO customers (customer_id, first_name, last_name, email, phone_number, address, city, state, postal_code)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            # Execute the insert query for each customer in the data
            for customer in customer_data:
                cursor.execute(insert_query, (
                    customer.get('customer_id'),
                    customer.get('first_name'),
                    customer.get('last_name'),
                    customer.get('email'),
                    customer.get('phone_number'),
                    customer.get('address'),
                    customer.get('city'),
                    customer.get('state'),
                    customer.get('postal_code')
                ))
            
            # Commit the changes
            connection.commit()
            
            message = f"{len(customer_data)} customers inserted successfully."
            print(message)
            
            return {
                'statusCode': 200,
                'body': json.dumps({'message': message})
            }
    
    except pymysql.MySQLError as e:
        error_message = f"Error: {str(e)}"
        print(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_message})
        }
    
    finally:
        if connection:
            connection.close()