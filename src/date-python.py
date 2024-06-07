from datetime import datetime
from json import dumps, loads
def lambda_handler(event, context):
    now = datetime.now()
    currentTime = {
        'currentTime': now
    }
    output = loads(dumps(currentTime, default=str))
    
    # For local testing
    # print(output)
    
    return output
 
# For local testing    
# if __name__ == '__main__':
#     lambda_handler({}, {})