require 'test_helper'

class InputControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get input_new_url
    assert_response :success
  end

end
