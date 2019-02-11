require "ostruct"

class Main
  include Cfnresponse

  def lambda_handler(event:, context:)
    puts("Received event: " + json_pretty(event))

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
    OpenStruct.new(
      log_group_name: "fake-log-group",
      log_stream_name: "fake-log-stream",
    )
  end

  it "has a version number" do
    expect(Cfnresponse::VERSION).not_to be nil
  end

  it "lambda_handler" do
    main = Main.new
    body_data = main.lambda_handler(event: event, context: context) # due to CFNRESPONSE_TEST=1
    pp body_data # uncomment to debug
    expect(body_data).to eq(
      {"Status"=>"SUCCESS",
       "Reason"=>%Q|See the details in CloudWatch Log Group: fake-log-group Log Stream: fake-log-stream|,
       "PhysicalResourceId"=>"PhysicalId",
       "StackId"=>
        "arn:aws:cloudformation:us-west-2:112233445566:stack/Bucket-5HWSC7WEFBT0/1671c9d0-2ccb-11e9-a131-06737af08cb6",
       "RequestId"=>"61318e12-6c1a-44c4-bd8f-ce0b34f32026",
       "LogicalResourceId"=>"MyLogicalId",
       "Data"=>{}}
    )
  end

  it "lambda_function" do
    code = IO.read("./spec/fixtures/lambda_function.rb")
    # Seems to be the only way to mimic access the methods by include Cfnresponse like json_pretty
    eval %Q{
      class MainScope
        #{code}
      end
    }
    scope = MainScope.new

    data = scope.json_pretty(a: 1)
    expect(data).to eq JSON.pretty_generate(a: 1)
  end
end
