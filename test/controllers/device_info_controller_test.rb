require "test_helper"

class DeviceInfoControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get device_info_create_url
    assert_response :success
  end
end
