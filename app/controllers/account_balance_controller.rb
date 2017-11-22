class AccountBalanceController < ApplicationController

  before_action :confirm_user_logged_in

  layout 'menu'

  def index
  end

  def update
    @currentUser = User.find(session[:user_id])
    @message = nil
    if(@currentUser.account_balance == nil)
      @new_balance = AccountBalance.new()
      @new_balance.user_id = session[:user_id]
      @new_balance.account_balance = 0.00
      @new_balance.save

      if(@currentUser.account_balance != nil)
        @message = "Successfully created new account_balance record"
      else
        @message = "Failed to create new account_balance record"
      end
    end


    if(@currentUser.account_balance != nil)
      spent = params['amount']
      #puts spent
      #spent.to_i
      #puts spent
      #spent = spent.to_i + 1
      @currentUser.account_balance.account_balance-=spent.to_f
      #@currentUser.account_balance.account_balance-=@spent
      @currentUser.account_balance.save
      @message = "Transaction saved, successfully updated account balance"
    else
      @message = "Transaction not saved, failed to update account balance"
    end

    if((params["next_controller"] != nil) && (params["next_action"] != nil))
      redirect_to({controller: params["next_controller"], action: params["next_action"], message: @message}) and return
    else
      redirect_to({controller: "home", action: "index", message: @message}) and return
    end
  end

  def make_update
  end

  def clear
  end
end
