# TODO: using CA to trust the certificate

import os
import traceback
import logging
import json
import http.client
import socket, ssl
from codepipeline_client import CodePipeline_Client

# Samples
data_model = {
    "host": "webhook.site",
    "method": "POST",
    "endpoint": "https://webhook.site/397c3712-28a6-4ea4-8049-571199e8cef5",
    "headers": {
        "Content-Type": "application/json"
    },
    "body": {
        "secret": "data_model",
        "parameters": {
            "artifact_id": "sample-application",
            "artifact_version": "v123"
        }
    }
}

codepipeline_model = {
   "CodePipeline.job":{
      "id":"664865c8-45ba-45d9-8952-f8593de4510c",
      "accountId":"253032955724",
      "data":{
         "actionConfiguration":{
            "configuration":{
               "FunctionName":"http-request",
               "UserParameters":"{\"host\":\"webhook.site\",\"method\":\"POST\",\"endpoint\":\"https://webhook.site/397c3712-28a6-4ea4-8049-571199e8cef5\",\"headers\":{\"Content-Type\":\"application/json\"},\"body\":{\"secret\":\"codepipeline_model\",\"parameters\":{\"artifact_id\":\"sample-application\",\"artifact_version\":\"v123\"}}}"
            }
         }
      }
   }
}

# Initialize
logger = logging.getLogger()
logger.setLevel(logging.os.environ['LOGGING_LEVEL'])

# Global vars
cp_client = None
run_in_cp = False

#
def process(request):
    logger.debug('request: {}'.format(request))
    logger.info('Begin sending request.')

    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    ssl_context.verify_mode = ssl.CERT_NONE
    client = http.client.HTTPSConnection(request["host"], context=ssl_context)
    client.request(request["method"], request["endpoint"], body=json.dumps(request["body"]), headers=request["headers"])

    # TODO: handle exceptions
    response = client.getresponse()
    response_raw_body = response.read()
    response_body = json.loads(response_raw_body)
    logger.debug('body: {}'.format(response_body))
    logger.debug('status code: {}'.format(response.status))

    logger.info('End sending request.')

#
def finalize(event, msg=None, err=None):
    if run_in_cp:
        if not err:
            cp_client.put_job_success(event["CodePipeline.job"]["id"], msg)
        else:
            cp_client.put_job_failure(event["CodePipeline.job"]["id"], msg)

#
def lambda_handler(event, context):
    global cp_client
    global run_in_cp

    logger.debug('event: {}'.format(event))
    logger.debug('context: {}'.format(context))

    if not event:
        request = data_model
    elif "CodePipeline.job" in event:
        request = json.loads(event["CodePipeline.job"]["data"]["actionConfiguration"]["configuration"]["UserParameters"])
        cp_client = CodePipeline_Client()
        run_in_cp = True
    else:
        request = event

    try:
        process(request)
        finalize(event, "Success.")
    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        logger.info('Function failed due to exception!')
        logger.error(e)
        traceback.print_exc()
        finalize(event, msg='Function exception: ' + str(e), err=e)

#
if __name__ == '__main__':
    event = codepipeline_model
    context = None
    lambda_handler(event, context)
