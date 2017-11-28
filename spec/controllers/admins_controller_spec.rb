require 'rails_helper'
require 'spec_helper'

RSpec.describe AdminController, type: :controller do

  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_session) { {} }

  before(:each) do
    @user = create(:user)
    @user.name.should eq('User')
    @user.admin.should eq(false)
    @admin = create(:admin)
    login(@admin)
    login_admin
    @admin.name.should eq('Admin')
    session[:admin].should be_truthy
    @admin.admin.should eq(true)

  end

  describe "get index" do
    it "returns a success response" do
      get :index
      response.should be_success
    end
  end

  describe "get new_user" do
    it "returns a success response" do
      get 'new_user'
      response.should be_success
    end
  end

  describe "get index" do
    it "normal user can't get index" do
      logout
      login(@user)
      get 'index'
      response.should_not be_success
    end
  end

  describe "get new_user" do
    it "normal user can't get new_index" do
      logout
      session[:admin].should eq(nil)
      session[:user_id].should eq(nil)
      login(@user)
      get 'new_user'
      response.should_not be_success
    end
  end

end
