require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(username: 'savortest', name: 'savor',
                      email: 'savor@savor.com', password_digest: 'test')
  end

  test 'valid user' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '     '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
  end

  test 'user has the correct info' do
    assert @user.name = 'savor'
    assert @user.username = 'savortest'
    assert @user.email = 'savor@savor.com'
    assert @user.password_digest = 'test'
  end

  test 'name isnt a number' do
    @user.name = 1
    assert_not @user.valid?
  end

end
