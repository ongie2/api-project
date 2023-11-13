import boto3
import json

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('TRANSACTION')

    payload = json.loads(event['body'])
    transaction_id = str(payload['transaction-id'])

    # UpdateExpression is constructed based on the fields provided in the payload
    # For simplicity, this example assumes all fields are provided for the update
    response = table.update_item(
        Key={
            'transaction_id': transaction_id
        },
        UpdateExpression="set merchant_id=:m, amount=:a, datetime=:d, user=:u, card=:c",
        ExpressionAttributeValues={
            ':m': str(payload['merchant-id']),
            ':a': str(payload['amount']),
            ':d': payload['datetime'],
            ':u': payload['user'],
            ':c': payload['card']
        },
        ReturnValues="UPDATED_NEW"
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f'Transaction {transaction_id} updated successfully')
    }
