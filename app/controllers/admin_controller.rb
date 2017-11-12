class AdminController < ApplicationController

  before_action :confirm_admin_logged_in

  layout "admin";

  def index # list of all users, where admin can select users to perform operations
    @users = User.all
    @message = params[:message]
  end

  def show # lists the details of the user in a more viewable fashion
  end

  def delete #the page to delete user, the user's information is listed, and their name needs to be repeated to delete user
    @user_id = params[:user_id]
    @username = params[:username]
    @first_name = params[:first_name]
    # add last_name
    #@password = params:[:password]
    @email = params[:email]
    @admin = params[:admin]
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
    @message = params[:message]
    @confirm = params[:confirm]
  end

  def destroy
    #destroys a user and posts changes to the database
    @confirm = params[:confirm]

    toBeDeleted = User.find(params[:user_id]) #finds the user object to be deleted
    @username = toBeDeleted.username
    @first_name = toBeDeleted.name
    # add last_name
    @email = toBeDeleted.email
    @admin = toBeDeleted.admin
    @created_at = toBeDeleted.created_at
    @updated_at = toBeDeleted.updated_at
    @user_id = toBeDeleted.id

    if(toBeDeleted.id == session[:user_id])
      @message = "Error: You can not delete yourself."
      redirect_to(:action => "index", :message => @message) and return
    end

    #check if the user is trying to delete themselves, dont let them
    if (@confirm == @username)
      @message = "[User ID:#{@user_id}] deleted."
      toBeDeleted.destroy #destroy the user
      redirect_to :action => "index", :message => @message
    else
      @message = "[User ID:#{@user_id}] not deleted, please enter the username to delete the user"
      redirect_to :action => "delete", :message => @message, :user_id => @user_id, :username => @username, :first_name => @first_name, :email => @email, :admin => @admin, :created_at => @created_at, :updated_at => @updated_at, :confirm => @confirm
    end
  end

  def new_user #the new admin page
    @message = params[:message]
  end

  def create_user #creates a new admin and posts to databse
    @username = params[:username]
    @name = params[:first_name]
    @password = params[:password]
    @confirm_password = params[:confirm_password]
    @email = params[:email]
    @admin = params[:admin]

    if(@password != @confirm_password)
      @message = "Error! Passwords do not match."
      redirect_to :action => "new_user", :message => @message and return
    end

    newUser = User.new()
    newUser.username = @username
    newUser.name = @name
    newUser.password = @password
    newUser.email = @email
    if (@admin == "true")
      newUser.admin = true
    else
      newUser.admin = false
    end
    if(newUser.save == true)
      redirect_to({action: "index"}) and return
    else
      @message = "Please revise user fields"
      redirect_to :action => "new_user", :message => @message and return
    end
  end

  def edit #the edit page
    @user_id = params[:user_id]
    @username = params[:username]
    @first_name = params[:first_name]
    # add last_name
    #@password = params:[:password]
    @email = params[:email]
    @admin = params[:admin]
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
  end

  def confirm_edit #posts the edits to the database
    @user_id = params[:user_id]

    @username_old = params[:username_old]
    @first_name_old = params[:first_name_old]
    @email_old = params[:email_old]
    @admin_old = params[:admin_old]

    @username = params[:username]
    @first_name = params[:first_name]
    # add last_name
    #@password = params:[:password]
    @email = params[:email]
    @admin = params[:admin]
  end

  def make_edit
    @user_id = params[:user_id]

    @username_old = params[:username_old]
    @first_name_old = params[:first_name_old]
    @email_old = params[:email_old]
    @admin_old = params[:admin_old]

    @username = params[:username]
    @first_name = params[:first_name]
    # add last_name
    #@password = params:[:password]
    @email = params[:email]
    @admin = params[:admin]

    toEdit = User.find(@user_id)
    toEdit.username = @username
    toEdit.name = @first_name
    toEdit.email = @email
    if (@admin = "true")
      toEdit.admin = true
    else
      toEdit.admin = false
    end
    toEdit.save

    @message = "[User ID:#{@user_id}] editted"
    redirect_to :action => index, :message => @message
  end
end
