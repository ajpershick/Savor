require 'test_helper'

class SpendingHistoryControllerTest < ActionDispatch::IntegrationTest
  test "should get charts" do
    get spending_history_charts_url
    assert_response :success
  end

  test "should get index" do
    get spending_history_index_url
    assert_response :success
  end

end
