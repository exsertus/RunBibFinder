import json
import boto3
import logging
import os

# Requires S3 bucket with inbox, matched and folders

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')

def oncreate_event(event, context):
    try:

        bucket=event['Records'][0]['s3']['bucket']['name']
        key=event['Records'][0]['s3']['object']['key']

        # Find numeric values for bibs at store them in matches array

        response = rekognition.detect_text(
            Image={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': key
                }
            }
        )

        matches = []
        for match in response['TextDetections']:
            logger.info('Found text: %s, confidence: %s' % (match['DetectedText'],match['Confidence']))
            if match['Type'] == "WORD" and match['Confidence'] > 85 and match['DetectedText'].isdigit():
                matches.append(match['DetectedText'])

        logger.info("Bib matches: %s" % (matches))

        # Move original image to:
        # /unmatched (if no matches)
        # /matched and rename image to bib number for matches (may result in multiple files for many bibs found in each image)

        if len(matches) > 0:
            for match in matches:
                dest_key = "matched/" + str(match) + ".jpg"

                s3.copy_object(
                    CopySource={
                        'Bucket': bucket,
                        'Key': key
                    },
                    Bucket=bucket,
                    Key=dest_key
                )
                logger.info("Moving match: %s to %s" % (key,dest_key))

        else:
            dest_key = key.replace('inbox/','unmatched/')
            s3.copy_object(
                CopySource={
                    'Bucket': bucket,
                    'Key': key
                },
                Bucket=bucket,
                Key=dest_key
            )
            logger.info("Moving unmatched: %s " % (key))

        s3.delete_object(Bucket=bucket, Key=key)


        return {
            "status":True,
            "data":matches
        }

    except Exception as e:
        return {
            "status":False,
            "error":e
        }
