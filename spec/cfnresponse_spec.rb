require "ostruct"

class Main
  include Cfnresponse

  def lambda_handler(event:, context:)
    print("Received event: " + json_pretty(event))

    case event['RequestType']
    when "Create"
      # create logic
      send_response(event, context, "SUCCESS")
    end
  end
end

RSpec.describe Cfnresponse do
  let(:event) do
    {
      "RequestType" => "Create",
      "ServiceToken" => "arn:aws:lambda:us-west-2:112233445566:function:alert-delivered-lambda_function",
      "ResponseURL" => "https://cloudformation-custom-resource-response-uswest2.s3-us-west-2.amazonaws.com/arn-blah-blah",
      "StackId" => "arn:aws:cloudformation:us-west-2:112233445566:stack/Bucket-5HWSC7WEFBT0/1671c9d0-2ccb-11e9-a131-06737af08cb6",
      "RequestId" => "61318e12-6c1a-44c4-bd8f-ce0b34f32026",
      "LogicalResourceId" => "MyLogicalId",
      "ResourceType" => "Custom::MyCustomResource",
      "ResourceProperties" => {
        "ServiceToken" => "arn:aws:lambda:us-west-2:112233445566:function:alert-delivered-lambda_function",
        "Property1" => "Value1",
        "Property2" => {
          "Value2" => [
            {
              "More" => [ "Data"],
              "SomeArn" => "arn:blah",
            },
          ],
        }
      }
    }
  end
  let(:context) do
    OpenStruct.new(log_stream_name: "fake-stream-name")
  end

  it "has a version number" do
    expect(Cfnresponse::VERSION).not_to be nil
  end

  it "does something useful" do
    main = Main.new
    body_data = main.lambda_handler(event: event, context: context) # due to CFNRESPONSE_TEST=1
    pp body_data # uncomment to debug
    expect(body_data).to eq(
      {"Status"=>"SUCCESS",
       "Reason"=>"See the details in CloudWatch Log Stream: \"fake-stream-name\"",
       "PhysicalResourceId"=>"PhysicalId",
       "StackId"=>
        "arn:aws:cloudformation:us-west-2:112233445566:stack/Bucket-5HWSC7WEFBT0/1671c9d0-2ccb-11e9-a131-06737af08cb6",
       "RequestId"=>"61318e12-6c1a-44c4-bd8f-ce0b34f32026",
       "LogicalResourceId"=>"MyLogicalId",
       "Data"=>{}}
    )
  end
end
