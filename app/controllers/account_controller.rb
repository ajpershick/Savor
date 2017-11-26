class AccountController < ApplicationController

  layout "menu"

  def edit
    @id = session[:user_id]
    thisUser = User.find(@id)

    @username = thisUser.username
    @first_name = thisUser.name
    @email = thisUser.email
    @message = params[:message]

    if (session[:admin])
      render :layout => 'admin'
    else
      render :layout => "menu"
    end

  end

  def make_edit
    id = params[:userID]
    user = User.find(id)
    newUsername = params[:username]
    newFirstName = params[:first_name]
    newEmail = params[:email]
    authenticated_user = user.authenticate(params[:password])
      #returns user or false

    if((newUsername.present? && newFirstName.present? && newEmail.present? && params[:password].present?) == false)
      @message = "Please fill in all fields"
      redirect_to(:action => "edit", :message => @message) and return
    elsif(authenticated_user == false)
      @message = "Password Incorrect"
      redirect_to(:action => "edit", :message => @message) and return
    else
      toEdit = User.find(id)
      toEdit.username = newUsername
      toEdit.name = newFirstName
      toEdit.email = newEmail
      toEdit.save
      @message = "Account details editted"
      redirect_to(:action => "index", :message => @message) and return
    end

  end

  def index

    id = session[:user_id]

    thisUser = User.find(id)
    @username = thisUser.username
    @first_name = thisUser.name
    @email = thisUser.email
    @message = params[:message]

    if (session[:admin])
      render :layout => 'admin'
    else
      render :layout => "menu"
    end

  end

  def change_password
    @message = params[:message]
    authenticated_user = params[:authenticated_user]

    if (session[:admin])
      render :layout => 'admin'
    else
      render :layout => "menu"
    end

  end

  def make_password_change
    current = params[:current]
    new = params[:new]
    confirm = params[:confirm]
    id = session[:user_id]
    user = User.find(id)
    authenticated_user = user.authenticate(params[:current])

    #redirect_to(:action => "change_password", :message => @message, :authenticated_user => @authenticated_user) and return
    if ((new.present? && confirm.present? && current.present? ) == false)
      @message = "Please fill in all required fields."
      redirect_to(:action => "change_password", :message => @message, :authenticated_user => authenticated_user) and return
    elsif(authenticated_user == false)
      @message = "Please reenter your current password"
      redirect_to(:action => "change_password", :message => @message, :authenticated_user => authenticated_user) and return
    elsif (new != confirm)
      @message = "Please make sure your new passwords are matching"
      redirect_to(:action => "change_password", :message => @message, :authenticated_user => authenticated_user) and return
    else
      user.password = new
      user.save
      @message = "Password successfully changed"
      redirect_to(:action => "index", :message => @message, :authenticated_user => authenticated_user) and return
    end

  end

end
