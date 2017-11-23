class HomeController < ApplicationController

  before_action :confirm_user_logged_in

  layout "menu"

  def index
    @message = params[:message]
    @currentUser = User.find(session[:user_id])

    #@name = User.where(id: session[:user_id]).first.name
    @name = @currentUser.name

    #account balance block -- start
    #if the current user has not created an account_balance, create one
    if(@currentUser.account_balance == nil)
      @new_balance = AccountBalance.new()
      @new_balance.user_id = session[:user_id]
      @new_balance.cash_balance = 0.00
      @new_balance.bank_balance = 0.00
      @new_balance.total_balance = 0.00
      @new_balance.save

      if(@currentUser.account_balance != nil)
        @message = "Successfully created new account_balance record"
      else
        @message = "Failed to create new account_balance record"
      end
    else
      @account_balance = @currentUser.account_balance.total_balance
    end
    #account balance block -- end

  end
end
