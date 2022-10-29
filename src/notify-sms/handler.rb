require 'twilio-ruby'

def handle(event:, context:)
  @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  message = "Hey #{event["participant"]["name"]}, you're Secret Santa for #{event["recipient"]["name"]} this year!"

  @client.messages.create(
    from: ENV["SMS_FROM"],
    to: event["participant"]["number"],
    body: message
  )
end
