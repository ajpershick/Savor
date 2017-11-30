require 'test_helper'

class AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.new(username: 'savortest', name: 'savor',
                      email: 'savor@savor.com', password_digest: 'test', admin: true)
  end

  test 'index redirected to login' do
    get admin_index_url
    assert_redirected_to access_login_url
  end

  test 'new admin redirected to login' do
    get admin_new_user_url
    assert_redirected_to access_login_url
  end

  # test 'should get index' do
  #   login(@admin)
  #   get admin_index_url
  #   assert_response :success
  # end

  # test 'should create admin' do
  #   assert_difference('Admin.count') do
  #     post admins_url, params: { admin: {  } }
  #   end

  #   assert_redirected_to admin_url(Admin.last)
  # end
  #
  # test "should show admin" do
  #   get admin_url(@admin)
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get edit_admin_url(@admin)
  #   assert_response :success
  # end
  #
  # test "should update admin" do
  #   patch admin_url(@admin), params: { admin: {  } }
  #   assert_redirected_to admin_url(@admin)
  # end
  #
  # test "should destroy admin" do
  #   assert_difference('Admin.count', -1) do
  #     delete admin_url(@admin)
  #   end
  #
  #   assert_redirected_to admins_url
  # end

end
