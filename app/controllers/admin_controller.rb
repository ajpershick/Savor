class AdminController < ApplicationController

  before_action :confirm_admin_logged_in

  layout "admin";

  def index # list of all users, where admin can select users to perform operations
    @allUsers = User.all;
  end

  def show # lists the details of the user in a more viewable fashion
  end

  def delete #the page to delete user, the user's information is listed, and their name needs to be repeated to delete user
    #@user = params[:form_name]
  end

  def destroy #destroys a user and posts changes to the database
  end

  def new_admin #the new admin page
  end

  def create_admin #creates a new admin and posts to databse
  end

  def edit #the edit page
    #@user = params[:form_name]
  end

  def make_edit #posts the edits to the database
  end
end
