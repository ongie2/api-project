import boto3
import json

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('TRANSACTION')

    payload = json.loads(event['body'])
    transaction_id = str(payload['transaction-id'])

    response = table.delete_item(
        Key={
            'transaction_id': transaction_id
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f'Transaction {transaction_id} deleted successfully')
    }
