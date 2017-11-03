require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_show_url
    assert_response :success
  end

  test "should get delete" do
    get admin_delete_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_destroy_url
    assert_response :success
  end

  test "should get new_admin" do
    get admin_new_admin_url
    assert_response :success
  end

  test "should get create_admin" do
    get admin_create_admin_url
    assert_response :success
  end

end
