class AccountController < ApplicationController

  layout "menu"

  def index

    id = session[:user_id]
    thisUser = User.find(id)

    @username = thisUser.username
    @first_name = thisUser.name
    @email = thisUser.email
    @message = params[:message]

    if (session[:admin]) then render :layout => 'admin' end

  end


  def edit

    users = User.all
    @usernames = []
    users.each do |user| @usernames << user.username end

    @id = session[:user_id]
    thisUser = User.find(@id)

    @username = thisUser.username
    @first_name = thisUser.name
    @email = thisUser.email
    @message = params[:message]

    if (session[:admin]) then render :layout => 'admin' end

  end

  def make_edit

    id = session[:user_id]
    user = User.find(id)
    newUsername = params[:username]
    newFirstName = params[:first_name]
    newEmail = params[:email]
    authenticated_user = user.authenticate(params[:password])
      #returns user or false

    if(!(newUsername.present? && newFirstName.present? && newEmail.present? && params[:password].present?)) then

      @message = "Please fill in all fields"
      redirect_to(:action => "edit", :message => @message) and return

    elsif !authenticated_user

      @message = "Password Incorrect"
      redirect_to(:action => "edit", :message => @message) and return

    else

      toEdit = User.find(id)
      toEdit.username = newUsername
      toEdit.name = newFirstName
      toEdit.email = newEmail
      toEdit.save
      @message = "Account details edited"
      redirect_to(:action => "index", :message => @message) and return

    end

  end


  def change_password

    @message = params[:message]
    authenticated_user = params[:authenticated_user]

    if (session[:admin]) then render :layout => 'admin' end

  end

  def make_password_change

    current_password = params[:current_password]
    new_password = params[:new_password]
    confirm_password = params[:confirm_password]
    puts current_password
    puts new_password
    puts confirm_password
    id = session[:user_id]
    user = User.find(id)
    authenticated_user = user.authenticate(params[:current_password])

    #redirect_to(:action => "change_password", :message => @message, :authenticated_user => @authenticated_user) and return
    if !(new_password.present? && confirm_password.present? && current_password.present?) then

      @message = "Please fill in all required fields."
      redirect_to(controller: "account", :action => "change_password", message: @message)

    elsif !authenticated_user

      @message = "Your current password is incorrect"
      redirect_to(controller: "account", action: "change_password", message: @message)

    elsif new_password != confirm_password

      @message = "Your new password and password confirmation do not match"
      redirect_to(controller: "account", action: "change_password", message: @message)

    else

      user.password = new_password
      user.save
      @message = "Password successfully changed"
      redirect_to(controller: "account", action: "index", message: @message) and return

    end

  end

end
