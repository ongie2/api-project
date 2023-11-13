
import boto3
import json
import uuid

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('TRANSACTION')

    payload = json.loads(event['body'])

    # Generate a unique transaction_id
    transaction_id = str(uuid.uuid4())

    # Store the transaction with the generated ID
    table.put_item(
        Item={
            'transaction_id': transaction_id,
            'merchant_id': str(payload['merchant-id']),
            'amount': str(payload['amount']),
            'datetime': payload['datetime'],
            'user': payload['user'],
            'card': payload['card']
        }
    )

    # Check for additional headers and log events if necessary
    if 'card-detail-viewed' in event['headers']:
        log_critical_event(table, transaction_id, 'Card Detail Viewed')

    if 'user-detail-viewed' in event['headers']:
        log_critical_event(table, transaction_id, 'User Detail Viewed')

    return {
        'statusCode': 200,
        'body': json.dumps(f'Transaction {transaction_id} stored successfully')
    }

def log_critical_event(table, transaction_id, event_type):
    table.put_item(
        Item={
            'transaction_id': transaction_id,
            'event_type': event_type
        }
    )


# import boto3
# import json


# def lambda_handler(event, context):
#     dynamodb = boto3.resource('dynamodb')
#     table = dynamodb.Table('TRANSACTION')

#     payload = json.loads(event['body'])

#     table.put_item(
#         Item={
#             'transaction_id': str(payload['transaction-id']),
#             'merchant_id': str(payload['merchant-id']),
#             'amount': str(payload['amount']),
#             'datetime': payload['datetime'],
#             'user': payload['user'],
#             'card': payload['card']
#         }
#     )

#     if 'card-detail-viewed' in event['headers']:
#         log_critical_event(table, payload['transaction-id'], 'Card Detail Viewed')

#     if 'user-detail-viewed' in event['headers']:
#         log_critical_event(table, payload['transaction-id'], 'User Detail Viewed')

#     return {
#         'statusCode': 200,
#         'body': json.dumps('Transaction stored successfully')
#     }


# def log_critical_event(table, transaction_id, event_type):
#     table.put_item(
#         Item={
#             'transaction_id': str(transaction_id),
#             'event_type': event_type
#         }
#     )
