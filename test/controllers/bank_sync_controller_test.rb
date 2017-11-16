require 'test_helper'

class BankSyncControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get bank_sync_index_url
    assert_response :success
  end

  test "should get create_item" do
    get bank_sync_create_item_url
    assert_response :success
  end

  test "should get add_account" do
    get bank_sync_add_account_url
    assert_response :success
  end

end
