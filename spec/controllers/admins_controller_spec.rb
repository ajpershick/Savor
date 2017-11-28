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
    @user = create(:admin)
    login(@user)
  end

  describe "get index" do
    it "returns a success response" do
      @user.name.should eq('Admin')
      session[:admin].should be_truthy
      @user.admin.should eq(true)
      get :index
      response.should be_success
    end
  end


  describe "get new_user" do
    it "returns a success response" do
      @user.name.should eq('Admin')
      session[:admin].should be_truthy
      @user.admin.should eq(true)
      get new_user_path
      response.should be_success
    end
  end

end
