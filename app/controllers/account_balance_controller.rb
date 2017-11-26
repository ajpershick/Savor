class AccountBalanceController < ApplicationController

  before_action :confirm_user_logged_in

  layout 'menu'

  def index

    currentUser = User.find(session[:user_id])
    @message = nil
    if(currentUser.account_balance == nil)
      new_balance = AccountBalance.new()
      new_balance.user_id = session[:user_id]
      new_balance.cash_balance = 0.00
      new_balance.bank_balance = 0.00
      new_balance.total_balance = 0.00
      new_balance.save

      if(currentUser.account_balance != nil)
        @message = "Successfully created new account_balance record"
      else
        @message = "Failed to create new account_balance record"
      end
    end

    if(currentUser.account_balance != nil)
      @total_balance = @currentUser.account_balance.total_balance
      @cash_balance = @currentUser.account_balance.cash_balance
      @bank_balance = @currentUser.account_balance.bank_balance
    else
      @message = "An error occurred, the you have no account balance associated with your account"
    end



  end

  def update
    currentUser = User.find(session[:user_id])
    @transaction_type = params["trans_type"] # "bank", "cash", "income-cash", "income-bank"
    @message = nil
    if(currentUser.account_balance == nil)
      new_balance = AccountBalance.new()
      new_balance.user_id = session[:user_id]
      new_balance.cash_balance = 0.00
      new_balance.bank_balance = 0.00
      new_balance.total_balance = 0.00
      new_balance.save

      if(currentUser.account_balance != nil)
        @message = "Successfully created new account_balance record"
      else
        @message = "Failed to create new account_balance record"
      end
    end


    if(currentUser.account_balance != nil && @transaction_type == "cash")
      puts "Detected cash transaction"
        #save cash_amount parameter into spent
      spent = params['amount']
        #subtract the spent amount from cash balance
      currentUser.account_balance.cash_balance-=spent.to_f
        #update total_balance
      currentUser.account_balance.total_balance = currentUser.account_balance.cash_balance + currentUser.account_balance.bank_balance
        #save changes to database
      currentUser.account_balance.save
      @message = "Transaction saved, successfully updated account balance"

    elsif (currentUser.account_balance != nil && @transaction_type == "bank")
      puts "Detected bank transaction"
        #save bank_amount parameter into spent
      spent = params['amount']
        #subtract the spent amount from bank balance
      currentUser.account_balance.bank_balance-=spent.to_f
        #update total_balance
      currentUser.account_balance.total_balance = currentUser.account_balance.cash_balance + currentUser.account_balance.bank_balance
        #save changes to database
      currentUser.account_balance.save
      @message = "Transaction saved, successfully updated account balance"

    elsif (currentUser.account_balance != nil && @transaction_type == "income-cash")
      puts "Detected income-cash transaction"
        #save bank_amount parameter into spent
      income = params['amount']
        #add the income-cash amount to the cash balance
      currentUser.account_balance.cash_balance+=income.to_f
        #update total_balance
      currentUser.account_balance.total_balance = currentUser.account_balance.cash_balance + currentUser.account_balance.bank_balance
        #save changes to database
      currentUser.account_balance.save
      @message = "Transaction saved, successfully updated account balance"

    elsif (currentUser.account_balance != nil && @transaction_type == "income-bank")
      puts "Detected income-bank transaction"
        #save bank_amount parameter into spent
      income = params['amount']
        #add the income-cash amount to the bank balance
      currentUser.account_balance.bank_balance+=income.to_f
        #update total_balance
      currentUser.account_balance.total_balance = currentUser.account_balance.cash_balance + currentUser.account_balance.bank_balance
        #save changes to database
      currentUser.account_balance.save
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

end
