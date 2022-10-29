import os
import requests


def handle(event, context):
    message = "Hey {}, you're Secret Santa for {} this year!".format(
        event["participant"]["name"], event["recipient"]["name"]
    )

    requests.post(
        "https://api.eu.mailgun.net/v3/" + os.environ["MAILGUN_DOMAIN"] + "/messages",
        auth=("api", os.environ["MAILGUN_API_KEY"]),
        data={
            "from": os.environ["EMAIL_FROM"],
            "to": event["participant"]["email"],
            "subject": "Who are you Secret Santa for?",
            "text": message,
        },
    )
