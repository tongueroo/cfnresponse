include Cfnresponse

def lambda_handler(event:, context:)
  print("Received event: " + json_pretty(event))
  event
end
