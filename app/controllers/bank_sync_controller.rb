class BankSyncController < ApplicationController
  skip_before_action :verify_authenticity_token
  #before_action :confirm_user_logged_in

  require 'date'

  layout "menu"

  $client = Plaid::Client.new(env: :sandbox,
                             client_id: Rails.application.secrets.plaid_client_id,
                             secret: Rails.application.secrets.plaid_secret,
                             public_key: Rails.application.secrets.plaid_public_key)
                             #webhook: 'https://requestb.in'
  access_token = nil

  #$current_user = User.find(session[:user_id])


  def index
    #the home page of the bank_sync
    #params:  access_token
    #         message
    #         user_balance

    currentUser = User.find(session[:user_id])
    @items = currentUser.items #an array of the user's items



    @access_token = params[:access_token]
    @item_id = []

    pos = 0
    @items.each do |i|
      @item_id[pos] = i["item_id"]
      pos+=1
    end

    @item_id_array = @item_id #converts string to array of item ID's
    @message = params[:message]
    @balance = params[:user_balance]


  end

  def create_item
  end

  def add_account
    @user_id = session[:user_id]
  end

  #creates a new item in the database with fields: user_id, item_id, access_token
  def get_access_token  # (basically does all initial setup stuff for bank-sync)
                        # get_access_token
                        # creates item and saves in database
                        # creates the bank_accounts and saves in database
                        # loads the transactions on the accounts from Plaid into the database

    @message = ''
    exchange_token_response = $client.item.public_token.exchange(params['public_token'])
    access_token = exchange_token_response['access_token']
    item_id = exchange_token_response['item_id']
    puts "access token: #{access_token}"
    puts "item id: #{item_id}"
    exchange_token_response.to_json

    item_response = $client.item.get(access_token)

    institution = $client.institutions.get_by_id(item_response["item"]["institution_id"])

    #checks whether the institution has already been saved
    currentUser = User.find(session[:user_id])
    items = currentUser.items.all
    items.all.each do |i|
      if(institution["institution"]["name"] == i["institution_name"])
        @message = "Error, you have already added this institution to your Savor account. "
        redirect_to({controller: "bank_sync", action: "index", message: @message}) and return
        break
      end
    end

    #if save the access_token in database (create a new item)
    if(access_token != nil)
      new_item = Item.new()
      new_item.user_id = session[:user_id]
      new_item.access_token = access_token
      new_item.item_id = item_id
      new_item.institution_id = item_response["item"]["institution_id"]
      new_item.institution_name = institution["institution"]["name"]
      new_item.available_products = item_response["item"]["available_products"]
      new_item.billed_products = item_response["item"]["billed_products"]

      new_item.save
      if(new_item != nil)
        puts "Successfully created item. "
        @message += "Successfully created item. "
        #redirect_to(:action => "index", :access_token => access_token, :item_id => item_id, :message => "Success, item created") and return
        #redirect_to(:action => "create_bank_account", :access_token => access_token, :item_id => item_id) and return


        message = @message
        createdBankAccounts = create_bank_accounts(access_token, message)
        @message = message
        if(createdBankAccounts == false)
          puts "Error, failed to create bank_accounts for item. "
          @message += "Error, failed to create bank_accounts for item. "
          redirect_to(:action => "index", :message => @message) and return
        else
          puts "Successfully created bank_accounts for item."
          @message += "Successfully created bank_accounts for item."

          #pull transactions from Plaid
          #redirect_to a loading page while transactions are being loaded
          redirect_to(:action => "load_transactions", :access_token => access_token, :message => @message) and return

          #redirect_to(:action => "index", :message => @message) and return
        end

      else
        puts "Error, failed to create item. "
        @message += "Error, failed to create item. "
        redirect_to(:action => "index", :message => @message) and return
      end
    end
  end

  def delete_access_token
    #params: access_token
    #delete item, given access_token
    $client.item.delete(params['access_token']);
  end

  def unsync_bank_accounts
    # Parameters
    #   Access_token from database. item_id, institution_name
    # Precondition
    #   Access token must be valid
    # Post condition:
    #   Delete item from database and deactivate access token in plaid
    # Description
    #   Makes an http request to Plaid for the given access key to delete the item.
    #   Calls $client.item.delete(access_token)

    @message = ''
    to_delete_access_token = params[:access_token]
    to_delete_item_id = params[:item_id]
    to_delete_institution = params[:institution_name]

    #delete item off of database.
    itemToDelete = Item.find_by item_id: to_delete_item_id
    isDeletedFromDB = itemToDelete.destroy
    if isDeletedFromDB
      response = $client.item.delete(to_delete_access_token)
      @message+= "'#{to_delete_institution}' successfully deleted from database. "
    else
      @message+= "'#{to_delete_institution}' failed to be deleted from database. "
    end

    if response["deleted"] && isDeletedFromDB
      @message+= "'#{to_delete_institution}' successfully unsynced with plaid"
      redirect_to(controller: "bank_sync", action: "index", message: @message) and return
    else
      @message+= "'#{to_delete_institution}' failed to unsynced with plaid"
      redirect_to(controller: "bank_sync", action: "index", message: @message) and return
    end
  end

  def load_transactions
    #params:  access_token, message
    #description: loading page for when the transactions are being loaded into
    # the savor database, from plaid
    # Executes the get_all_transactions function to...get all transactions

    @message = params[:message]

    @access_token = params["access_token"]
    @account_ids = nil
    failedCounters = get_all_transactions(@access_token, @account_ids)
    #returns an array with two values: [bankTransFailedCounter, transFailedCounter]
    @message += " '#{failedCounters[0]}' failed bank_transactions table submission(s), '#{failedCounters[1]}' failed transactions table submission(s), '#{failedCounters[2]}' failed incomes table submission(s), '#{failedCounters[3]}' transactions received from Plaid, '#{failedCounters[4]}' transactions saved successfully. "

    redirect_to(controller: "bank_sync", action: "index", message: @message) and return
  end

  def load_new_transactions
    @access_token = params["access_token"]
    @account_ids = params[:account_ids]
    failedCounters = get_new_transactions(@access_token, @account_ids)
    puts "failedCounters = #{failedCounters}"
    if(failedCounters[5] == true)
      @message = failedCounters[4]
    else
      @message += " '#{failedCounters[0]}' failed bank_transactions table submission(s), '#{failedCounters[1]}' failed transactions table submission(s), '#{failedCounters[2]}' failed incomes table submission(s), '#{failedCounters[3]}' transactions received from Plaid, '#{failedCounters[4]}' transactions saved successfully. "
    end
    redirect_to(controller: "bank_sync", action: "index", message: @message) and return
  end

  def get_bank_account_info
    # Parameters
    #   Access_token from database
    # Precondition
    #   Access token must be valid
    # Post condition:
    #   Updated accounts table for current user with new account information
    # Description
    #   Makes an http request to Plaid for the given access key to retreive the user’s account info. The account info is received in JSON, but is parsed into Ruby hash.
    #   Calls $client.accounts.get(@access_token)

    #get access token from database

    currentUser = User.find(session[:user_id])
    currentItem = currentUser.items.find_by item_id: newAccount.item_id


  end

  def get_account_balance
    #@access_token = params[:access_token]

#    @item_id = params[:item_id]
#    @message = params[:message]
    # returns the current user's item
#    user_item = Item.find_by user_id: session[:user_id]
#    @access_token = user_item.access_token
    #returns the total balance in the bank accounts registered by the user, using their access token
#    @userBalance = $client.accounts.balance.get(@access_token);
    #pass @userBalance to a view to display balance

#    @balanceSum = 0
#    @balanceSum.to_i
#    #@balanceArray = @userBalance[]
#    @userBalance["accounts"].each do |i|
#      @sum = @userBalance['accounts'][i][1][0].to_i
#      @balanceSum+=@sum

#    end


#    redirect_to(:action => "index", :access_token => @access_token, :item_id => @item_id, :message => @message, :user_balance => @balanceSum) and return
    #redirect_to(:action => "index", :user_balance => @userBalance) and return
  end

  def show_bank_account
    #params: user_id, item_id, account_id
    currentUser = User.find(session[:user_id])
    item = currentUser.items.find_by item_id: params[:item_id]
    bank_account = item.bank_account
  end

  def show_item
    #params: item_id
    #show show the item information and its corresponding bank accounts
    currentUser = User.find(session[:user_id])
    item = currentUser.items.find_by item_id: params[:item_id]

    @institution_name = item.institution_name
    @total_account_balance = item.total_account_balance
    @created_at = item.created_at
    @bank_accounts = item.bank_accounts

    @account_ids = []
    pos = 0
    @bank_accounts.each do |acc|
      @account_ids[pos] = acc["account_id"]
    end

    @access_token = item["access_token"]

    puts "@account_ids = #{@account_ids}"
    # @bank_accounts_ids = []
    #
    # pos = 0
    # @bank_accounts.each do |acc|
    #   @bank_accounts_ids[pos] = acc.id
    #   pos+=1
    # end
    #
    # pos = 0
    # @bank_accounts_array = []
    # @bank_accounts_ids.each do |bank_account_id|
    #   @bank_accounts_array[pos] = item.bank_accounts.find_by id: bank_account_id
    #   pos+=1
    # end
  end

  def show_account_details #done
    #params: bank_account id, institution_name
    @institution_name = params[:institution_name]
    this_acc = BankAccount.find(params[:bank_id])
    #@account_id = this_acc.account_id
    @available_balance = this_acc.available_balance
    @current_balance = this_acc.current_balance
    @name = this_acc.name
    @mask = this_acc.mask
    @official_name = this_acc.official_name
    @account_type = this_acc.account_type
    @account_subtype = this_acc.account_subtype
    @created_at = this_acc.created_at
    @updated_at = this_acc.updated_at

    if @available_balance == nil
      @available_balance = "n/a"
    end
  end


  def get_new_transactions(access_token, account_ids)

    #params:  access_token, account_ids (array of account_ids)
    #description: loading page for when the transactions are being loaded into
    # the savor database, from plaid
    # Executes the get_all_transactions function to...get all transactions

    isValidAccessToken = checkAccessToken(access_token)
    @message = ''


    #check preconditions
    if(isValidAccessToken == false)
      puts "Error, in 'load_new_transactions', invalid access_token"
      @message+="Invalid acess token. "
      return [nil, nil, nil, nil, nil, nil]
    end

    this_item = Item.find_by access_token: access_token
    this_item_id = this_item.id
    this_user_id = this_item.user_id

    if(account_ids[0] == nil)
      puts "No account id's detected in parameters, fetching all transactions for all items."
      @message+="No account id's detected in parameters, fetching all transactions for all items. "

      #populate @account_ids array with account_ids
      a_pos = 0
      account_ids = []
      this_item.bank_accounts.each do |i|
        account_ids[a_pos] = i["account_id"]
        a_pos+=1
      end

    else
      puts "Fetching transactions from account_ids provided."
      @message+="Fetching transactions from account_ids provided."
    end


    pos = 0
    account_ids.each do |acc_id|
      isValidAccountID = checkAccountID(acc_id, access_token)
      if(isValidAccountID == false)
        puts "@account_ids[#{pos}] is invalid, exiting. "
        @message+="@account_ids[#{pos}] is invalid, exiting. "
        return [nil, nil, nil, nil, nil, nil]
      end

      #find the account using the account_id
      this_account =  BankAccount.all.find_by account_id: acc_id
      if(this_account == nil)
        puts "Error, no bank_account found with account_id: #{acc_id}"
        return [nil, nil, nil, nil, nil, nil]
      end
      saved_transactions = this_account.bank_transactions.all

      #find start_date
      if(saved_transactions == nil)
        start_date = (Date.today - 728).to_formatted_s
      else
        start_date = saved_transactions.order(date: :desc).first["date"].to_date.to_formatted_s
      end

      #set end_date
      end_date = Date.today.to_formatted_s

      dateIsValid = start_date <= end_date

      if(dateIsValid == false)
        puts "Error in get_transactions function, start_date must be older than end_date"
        return [nil, nil, nil, nil, nil, nil]
      end

      @numberFetched = 0 #the number of transactions received from Plaid.

      #fetch transactions from plaid
      new_transactions_all = get_transactions(acc_id, access_token, start_date, end_date)

      puts "new_transactions_all = #{new_transactions_all}"
      @numberFetched = new_transactions_all[1]
      puts "@numberFetched = #{@numberFetched}"

      new_transactions = new_transactions_all[0]

      puts "In get_new_transactions"
      puts "saved_transactions = #{saved_transactions}"
      #remove duplicates
      filtered_transactions = remove_dupilicates(new_transactions, saved_transactions)

      if(new_transactions != nil && filtered_transactions.length == 0)
        puts "No new transactions, transactions are up to date."
        @message = "No new transactions, transactions are up to date. "
        failedTrans = [ nil, nil,nil , 0, @message, true]
        return failedTrans
      end

      #append filtered_transactions to end of saved_transactions
      saved_transactions = (saved_transactions << filtered_transactions).flatten!


      #if max number of transactions fetched, then we need to loop again.
      while(new_transactions.length == 500) do
        #fetch for more transactions and append to end
        start_date = new_transactions.order(date: :desc).first["date"].to_date.to_formatted_s
        new_transactions = get_transactions(acc_id, access_token, start_date, end_date)

        filtered_transactions = remove_dupilicates(new_transactions, saved_transactions)

        saved_transactions = (saved_transactions << filtered_transactions).flatten!

      end

      @bankTransFailedCounter = 0
      @transFailedCounter = 0
      @incomeFailedCounter = 0

      #save transactions_all into database

      @numberSaved = @numberFetched
      saved_transactions.each do |transaction|
        #save transaction in bank_transactions table
        isSavedBankTransaction = save_bank_transaction(transaction, bank_account_id, this_item_id, this_user_id)

        if(isSavedBankTransaction == false)
          puts "failed to save to bank_transactions table"
          @bankTransFailedCounter+=1
          @numberSaved-=1
        end

        #save transaction into transactions table
        if(transaction["amount"] < 0)
          isSavedIncome = save_income(transaction, this_user_id)
          if(isSavedIncome == false)
            puts "failed to save to incomes table"
            @incomeFailedCounter+= 1
          end
        else
          isSavedTransaction = save_transaction(transaction this_user_id)
          if(isSavedTransaction == false)
            puts "failed to save to transactions table"
            @transFailedCounter+= 1
          end
        end #end of if/else statement
      end #end of saved_transactions loop
      pos+=1
    end #end of account_id loop

    failedTrans = []

    failedTrans = [@bankTransFailedCounter, @transFailedCounter, @incomeFailedCounter, @numberFetched, @numberSaved]

    puts "failedTrans = #{failedTrans}"
    return failedTrans


  end

  def show_transactions
  end

  #---------------------CONTROLLER FUNCTIONS-----------------------------------------------------------

  def create_bank_accounts(access_token, message) #working
    #parameters:
      #access_token
    #precondition:
      #item_id and access_token is not nil
    #postcondition:
      #created a bank_account record for each account contained within the item, from plaid
    #description:
      #sends an http request to Plaid to get all the accounts associated with the item

    #"access-sandbox-4abdcc4a-d38a-4298-9da9-354fd51009cc"


      #response from plaid servers, in the form of a hash {"accounts", "item", "request_id"}
    accounts_response = $client.accounts.get(access_token)

      #the accounts array, extracted from the accounts_response
    accounts_array = accounts_response["accounts"]

      #create an empty message for messages to be appended to it in the loop
    #@message = ''

    this_item = Item.find_by access_token: access_token
    this_item_id = this_item.id
    this_user_id = this_item.user_id

    currentUser = User.find(this_user_id)

    currentItem = this_item

    newAccountsSaved = nil

    @message = ''
    total_balance = 0
    grand_total_balance = 0
    accounts_array.each do |acc|
      newAccount = BankAccount.new()
      newAccount.user_id = this_user_id
      newAccount.item_id = this_item_id
      newAccount.account_id = acc['account_id']
      if(acc['balances']['available'] != nil)
        newAccount.available_balance = acc['balances']['available']
      end
      newAccount.current_balance = acc['balances']['current']
      newAccount.name = acc['name']
      newAccount.mask = acc['mask']
      newAccount.official_name = acc['official_name']
      newAccount.account_type = acc['type']
      newAccount.account_subtype = acc['subtype']
      if(newAccount.save)
        total_balance+=newAccount.current_balance
        @message += "'#{newAccount.official_name}' successfully saved. "
        puts "#{newAccount.official_name}, successfully saved. "
        #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
        newAccountsSaved = true
      else
        @message += "'#{newAccount.official_name}' failed to be saved. "
        puts "#{newAccount.official_name}, failed to be saved. "
        #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
        newAccountsSaved = false
      end
    end

    #update bank balance in database

    #sum up all the bank_balances of this user.
    currentItem.total_account_balance = total_balance
    isCurrentItemSaved = currentItem.save

    #sum up the total balance in all the banks at this user's item.
    currentUser.items.each do |i|
      grand_total_balance += i.total_account_balance
    end

    #update the bank_balance of the current user with the newly calculated grand_total_balance
    currentUser.account_balance.bank_balance = grand_total_balance
    isCurrentAccountBalanceSaved = currentUser.account_balance.save

    #update the total balance
    currentUser.account_balance.total_balance = currentUser.account_balance.bank_balance + currentUser.account_balance.cash_balance
    isTotalAccountBalanceSaved = currentUser.account_balance.save


    #check preconditions
    if(isCurrentItemSaved == false)
      @message += "Failed to update item: #{currentUser.institution_id}. "
      puts "Failed to update item: #{currentUser.institution_id}. "
      #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
      return false
    elsif(isCurrentAccountBalanceSaved == false)
      @message += "Failed to update account balance. "
      puts "Failed to update account balance. "
      #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
      return false
    elsif(isTotalAccountBalanceSaved == false)
      @message += "Failed to update TOTAL account balance. "
      puts "Failed to update TOTAL account balance. "
      return false
    else
      return newAccountsSaved
    end

  #redirect_to(controller: "bank_sync", action: "index", message: @message) and return

  end

  def get_all_transactions(access_token, account_ids)
    #gets transactions from the plaid servers and update savor database
      #copies the bank_transactions table to the transactions table.
      #executed after the item is created, to fetch all available transaction data into savor database
      #returns an array with two values: [bankTransFailedCounter, transFailedCounter]
    #params: access_token, account_ids
      #account_ids: the plaid account_ids associated with all the accounts in the item.

    #check precondition
    accessTokenIsValid = checkAccessToken(access_token)
    if(accessTokenIsValid == false)
      puts "Error in get_all_transactions, access_token invalid"
      return false
    end

    this_item = Item.find_by access_token: access_token
    this_item_id = this_item.id
    this_user_id = this_item.user_id

    #currentUser = User.find(session[:user_id])
    #start_date = latest date
    end_date = Date.today.to_date.to_formatted_s #formats the date to YYYY-MM-DD


    if(account_ids == nil)
      #populate @account_ids array with account_ids
      a_pos = 0
      account_ids = []
      this_item.bank_accounts.each do |i|
        account_ids[a_pos] = i["account_id"]
        a_pos+=1
      end
    end

    @numberFetched = 0 #the number of transactions received from Plaid

    account_ids.each do |acc_id|
      #check if transactions are available from 24 months since the item creation date.
      #find the start date
      # start with (current date - 24 months)

      #check precondition that the accound_id is valid
      this_account = this_item.bank_accounts.find_by account_id: acc_id
      if(this_account == nil)
        puts "Error, no bank_account found with account_id: #{acc_id}"
        return false
      end

      start_date = Date.today - 728
      start_date = start_date.to_date.to_formatted_s #formats the date to YYYY-MM-DD


      this_account_id = this_account.id
      transactions_new = get_transactions(acc_id, access_token, start_date, end_date)
      @numberFetched+=transactions_new[1]
      transactions_all = transactions_new[0]
      bank_accounts = this_item.bank_accounts

      current_bank_account = bank_accounts.find_by account_id: acc_id
      bank_account_id = current_bank_account.id


      # continue fetching for new transactions, until start_date = end_date
      # AND, the previous transactions fetched are the same as the current transactions fetched.

      # if 500 transactions were fetched (max), then fetch for more transactions
        # but, make sure to not include duplicate transactions
      while(transactions_new.length == 500) do

        start_date = transactions_new[0]["date"]
        transactions_new = get_transactions(acc_id, access_token, start_date, end_date)

        #remove duplicates from the newly fetched transactions_new
        trans_new_no_dupe = remove_dupilicates(transactions_new, transactions_all)

        #appends new filtered transactions to transactions_all array
        transactions_all = (transactions_all << trans_new_no_dupe).flatten!

      end

      @bankTransFailedCounter = 0
      @transFailedCounter = 0
      @incomeFailedCounter = 0

      #save transactions_all into database

      @numberSaved = @numberFetched
      transactions_all.each do |transaction|
        transaction_1 = transaction

        #save transaction in bank_transactions table
        isSavedBankTransaction = save_bank_transaction(transaction, bank_account_id, this_item_id, this_user_id)

        if(isSavedBankTransaction == false)
          puts "failed to save to bank_transactions table"
          @bankTransFailedCounter+=1
          @numberSaved-=1
        end

        #save transaction into transactions table
        if(transaction["amount"] < 0)
          isSavedIncome = save_income(transaction_1, this_user_id)
          if(isSavedIncome == false)
            puts "failed to save to incomes table"
            @incomeFailedCounter+= 1
          end
        else
          isSavedTransaction = save_transaction(transaction_1, this_user_id)
          if(isSavedTransaction == false)
            puts "failed to save to transactions table"
            @transFailedCounter+= 1
          end
        end #end of if/else statement

      end #end of transactions_all loop

    end #end of @accounts_id loop

    failedTrans = []

    failedTrans = [@bankTransFailedCounter, @transFailedCounter, @incomeFailedCounter, @numberFetched, @numberSaved]

    puts "failedTrans = #{failedTrans}"
    return failedTrans

  end # end of get_all_transactions

  def get_transactions(account_id, access_token, start_date, end_date)
    #params: account_id, access_token, start_date, end_date
    #description: fetches all the transaction for the given account_id
      #and returns an array of transactions fetched.
    #precondition: access_token is a valid access_token in items table.
    #postcondition: fetch transactions from plaid and return

    # @account_id = params[:account_id] #the account_id to pull transactions from
    # @access_token = params[:access_token] #the access_token if the item the transactions belong to (required)
    # @start_date = params[:start_date] #the oldest date to pull transactions from
    # @end_date = params[:end_date] #the most recent date to pull transactions from

    #check precondition
    if(checkAccessToken(access_token) == false)
      puts "Error in get_transactions function, access_token invalid" and return
    end

    start_date = start_date.to_date.to_formatted_s #changes format to (YYYY-MM-DD)
    end_date = end_date.to_date.to_formatted_s

    #check precondition
    start_date_copy = start_date.to_date
    end_date_copy = end_date.to_date
    dateIsValid = start_date_copy <= end_date_copy

    if(dateIsValid == false)
      puts "Error in get_transactions function, start_date must be older than end_date"
      return false
    end

    @numberFetched = 0 #the number of transactions received from Plaid.


    if(account_id != nil)
      puts "account_id = #{account_id}"

      response = $client.transactions.get(access_token,
                                              start_date,
                                              end_date,
                                              account_ids: [account_id], #@account_ids,
                                              count: 500,
                                              offset: 0)
    else
      response = $client.transactions.get(access_token,
                                              start_date,
                                              end_date,
                                              count: 500,
                                              offset: 0)
    end



    retreived_transactions = []

    retreived_transactions = response["transactions"] #an array with many transactions
    @numberFetched = retreived_transactions.length

    # continue fetching for new transactions, until start_date = end_date
    # AND, the previous transactions fetched are the same as the current transactions fetched.

    return [retreived_transactions, @numberFetched]

  end

  def remove_dupilicates(transactions_new, transactions_all)
    #params:
      #transactions_new: array of transactions, majority of which are new
      #transactions_old: saved transactions
    #description: fetches all the transaction for the given account_id
      #and returns an array of transactions fetched.

      puts "In remove_dupilicates"
      puts "transactions_new = #{transactions_new}"
      puts " "
      puts "transactions_all = #{transactions_all}"

      pos = transactions_new.length - 1
      puts "transactions_new.length = #{transactions_new.length}"
      for i in 0..(transactions_new.length-1)
        puts "WHATS UP DUDE"
        dupe = false
        puts "dupe = #{dupe}"
        #loop through og trans to find the last transaction_id
        transactions_all.each do |og_trans|
          if(transactions_new[pos]["transaction_id"] == og_trans["transaction_id"])
            puts "WHATS UP DUDE2"
            dupe = true
            puts "dupe = #{dupe}"
            break #exit the loop if a duplicate has been found
          end
        end

        if(dupe == false)
          #if this transaction is not a duplicate, save the position of this transaction
          new_pos = pos
          #all transactions after this position will be saved.
          break #break out of the for loop once new unduped transaction found
        end
        pos-=1
      end

      #truncates the duplicate values in transactions_2 and stores in transasctions_3
      # i = 0
      # transactions_3 = []
      # pos = 0
      # for i in 0...new_pos
      #     transactions_3[pos] = transaction_2[pos]
      #     pos+=1
      # end

      # truncate all the duplication values in transactions_2
      # take all values from and including new_pos + 1 to the end of array
      puts "new_pos = #{new_pos}"
      #new_pos: the position of the first new element that is a not duplicate.
      if(new_pos == nil)
        transactions_new_filtered = []
      else
        transactions_new_filtered = transactions_new[0..(new_pos+1)]
      end
      return transactions_new_filtered

  end

  def checkAccessToken(access_token)
    #params: access_token
    #description: takes in a string as a paramter and checks whether the string
      #is a valid access token, returns a boolean
    item = Item.all.find_by access_token: access_token
    if(item == nil)
      return false
    else
      return true
    end
  end

  def checkAccountID(acc_id, access_token)
    #params: access_token, item_id
    #description: takes in two strings, acc_id, and access_token, and checks whether the account_id
      #belongs to the item.
      #assumes that the access_token is valid
    item = Item.all.find_by access_token: access_token
    bank_account = item.bank_accounts.find_by account_id: acc_id
    if(bank_account == nil)
      return false
    else
      return true
    end
  end

  def save_bank_transaction(transaction, bank_account_id, item_id, user_id)
    bank_transaction = BankTransaction.new()
    bank_transaction.user_id = user_id.to_i
    bank_transaction.item_id = item_id.to_s

    if(transaction["account_id"] != nil)
      bank_transaction.account_id = transaction["account_id"]
    else
      bank_transaction.account_id = "n/a"
    end

    bank_transaction.bank_account_id = bank_account_id.to_i

    if(transaction["transaction_id"] != nil)
      bank_transaction.transaction_id = transaction["transaction_id"]
    else
      bank_transaction.transaction_id = "n/a"
    end

    if(transaction["category"] != nil)
      bank_transaction.category = transaction["category"]
    else
      bank_transaction.category = []
      bank_transaction.category[0] = "n/a"
    end

    if(transaction["category_id"] != nil)
      bank_transaction.category_id = transaction["category_id"]
    else
      bank_transaction.category_id = "n/a"
    end

    if(transaction["transaction_type"] != nil)
      bank_transaction.transaction_type = transaction["transaction_type"]
    else
      bank_transaction.transaction_type = "n/a"
    end

    if(transaction["amount"] != nil)
      bank_transaction.amount = transaction["amount"].to_f
    else
      bank_transaction.amount = 0
    end

    if(transaction["date"].to_date != nil)
      bank_transaction.date = transaction["date"].to_date
    else
      bank_transaction.date = Date.today
    end

    if(transaction["name"] != nil)
      bank_transaction.name = transaction["name"]
    else
      bank_transaction.name = "n/a"
    end

    if(transaction["location"]["address"] == nil && transaction["location"]["lat"] == nil)
      bank_transaction.location_bool = false
      bank_transaction.location = []
      bank_transaction.location[0] = "n/a"
      bank_transaction.location[1] = "n/a"
      bank_transaction.location[2] = "n/a"
      bank_transaction.location[3] = "n/a"
      bank_transaction.location[4] = "n/a"
      bank_transaction.location[5] = "n/a"
      bank_transaction.location[6] = "n/a"
    elsif(transaction["location"]["lat"] != nil && transaction["location"]["lon"] != nil)
      bank_transaction.location_bool = true
      bank_transaction.location = []
      if(transaction["location"]["address"] != nil)
        bank_transaction.location[0] = transaction["location"]["address"]
      else
        bank_transaction.location[0] = "n/a"
      end
      if(transaction["location"]["city"] != nil)
        bank_transaction.location[1] = transaction["location"]["city"]
      else
        bank_transaction.location[1] = "n/a"
      end
      if(transaction["location"]["lat"] != nil)
        bank_transaction.location[2] = transaction["location"]["lat"]
      else
        bank_transaction.location[2] = "n/a"
      end
      if(transaction["location"]["lon"] != nil)
        bank_transaction.location[3] = transaction["location"]["lon"]
      else
        bank_transaction.location[3] = "n/a"
      end
      if(transaction["location"]["state"] != nil)
        bank_transaction.location[4] = transaction["location"]["state"]
      else
        bank_transaction.location[4] = "n/a"
      end
      if(transaction["location"]["store_number"] != nil)
        bank_transaction.location[5] = transaction["location"]["store_number"]
      else
        bank_transaction.location[5] = "n/a"
      end
      if(transaction["location"]["zip"] != nil)
        bank_transaction.location[6] = transaction["location"]["zip"]
      else
        bank_transaction.location[6] = "n/a"
      end
    elsif(transaction["location"]["address"] != nil)
      bank_transaction.location_bool = true
      bank_transaction.location = []
      if(transaction["location"]["address"] != nil)
        bank_transaction.location[0] = transaction["location"]["address"]
      else
        bank_transaction.location[0] = "n/a"
      end
      if(transaction["location"]["city"] != nil)
        bank_transaction.location[1] = transaction["location"]["city"]
      else
        bank_transaction.location[1] = "n/a"
      end
      if(transaction["location"]["lat"] != nil)
        bank_transaction.location[2] = transaction["location"]["lat"]
      else
        bank_transaction.location[2] = "n/a"
      end
      if(transaction["location"]["lon"] != nil)
        bank_transaction.location[3] = transaction["location"]["lon"]
      else
        bank_transaction.location[3] = "n/a"
      end
      if(transaction["location"]["state"] != nil)
        bank_transaction.location[4] = transaction["location"]["state"]
      else
        bank_transaction.location[4] = "n/a"
      end
      if(transaction["location"]["store_number"] != nil)
        bank_transaction.location[5] = transaction["location"]["store_number"]
      else
        bank_transaction.location[5] = "n/a"
      end
      if(transaction["location"]["zip"] != nil)
        bank_transaction.location[6] = transaction["location"]["zip"]
      else
        bank_transaction.location[6] = "n/a"
      end
    else
      bank_transaction.location_bool = false
      bank_transaction.location = []
      bank_transaction.location[0] = "n/a"
      bank_transaction.location[1] = "n/a"
      bank_transaction.location[2] = "n/a"
      bank_transaction.location[3] = "n/a"
      bank_transaction.location[4] = "n/a"
      bank_transaction.location[5] = "n/a"
      bank_transaction.location[6] = "n/a"
    end

    if(transaction["pending"] != nil)
      bank_transaction.pending = transaction["pending"]

      if(transaction["pending_transaction_id"] != nil)
        bank_transaction.pending_transaction_id = transaction["pending_transaction_id"]
      else
        bank_transaction.pending_transaction_id = "n/a"
      end
    else
      bank_transaction.pending = false
      if(transaction["pending_transaction_id"] != nil)
        bank_transaction.pending_transaction_id = transaction["pending_transaction_id"]
      else
        bank_transaction.pending_transaction_id = "n/a"
      end
    end
    if(bank_transaction.save)
      puts "tx_id: #{transaction["transaction_id"]} saved successfully in bank_transactions table"
      return true
    else
      puts "tx_id: #{transaction["transaction_id"]} failed to save in bank_transactions table"
      puts "bank_transaction = #{bank_transaction}"
      puts "bank_transaction.user_id: #{bank_transaction.user_id}"
      puts "bank_transaction.item_id: #{bank_transaction.item_id}"
      puts "bank_transaction.bank_account_id: #{bank_transaction.bank_account_id}"
      puts "bank_transaction.transaction_id: #{bank_transaction.transaction_id}"
      puts "bank_transaction.category: #{bank_transaction.category}"
      puts "bank_transaction.category_id: #{bank_transaction.category_id}"
      puts "bank_transaction.transaction_type: #{bank_transaction.transaction_type}"
      puts "bank_transaction.amount: #{bank_transaction.amount}"
      puts "bank_transaction.date: #{bank_transaction.date}"
      puts "bank_transaction.location_bool: #{bank_transaction.location_bool}"
      puts "bank_transaction.location: #{bank_transaction.location}"
      puts "bank_transaction.name: #{bank_transaction.name}"
      puts "bank_transaction.pending: #{bank_transaction.pending}"
      puts "bank_transaction.pending_transaction_id: #{bank_transaction.pending_transaction_id}"


      puts "bank_transaction.errors = #{bank_transaction.errors}"
      #puts "@messages: #{bank_transaction.errors[@messages]}"
      #puts "@details:  #{bank_transaction.errors[@details]}"
      puts "transaction = #{transaction}"
      return false
    end
  end

  def save_transaction(transaction, user_id)
    new_transaction = Transaction.new()
    new_transaction.user_id = user_id
    puts "user_id = #{user_id}"

    if(transaction["amount"] != nil)
      new_transaction.amount = transaction["amount"]
    else
      new_transaction.amount = 0
    end
    puts "transaction['amount'] = #{transaction["amount"]}"

    if(transaction["date"] != nil)
      new_transaction.date = transaction["date"].to_date
      puts "transaction['date'].to_date = #{transaction["date"].to_date}"
    else
      new_transaction.date = Date.today
      puts "transaction['date'] = nil, new_transaction.date saved as Date.today"
    end


    if(transaction["category"] != nil)
      puts "transactions['category'] = #{transaction["category"]}"
      new_transaction.category = changeCategory(transaction["category"])
      #new_transaction.category = transaction["category"][0]
    else
      new_transaction.category = "miscellaneous"
    end

    if(transaction["transaction_type"] != nil)
      new_transaction.transaction_type = transaction["transaction_type"]
    else
      new_transaction.transaction_type = "n/a"
    end

    if(transaction["transaction_id"] != nil)
      new_transaction.unique_id = transaction["transaction_id"]
    else
      new_transaction.unique_id = "n/a"
    end

    if(transaction["location"]["address"] == nil && transaction["location"]["lat"] == nil)
      new_transaction.location == false
      new_transaction.address = nil
      new_transaction.city = nil
      new_transaction.state = nil
      new_transaction.zip = nil
      new_transaction.latitude = nil
      new_transaction.longitude = nil
    elsif(transaction["location"]["lat"] != nil && transaction["location"]["lon"] != nil)
      new_transaction.location_bool = true
      new_transaction.address = transaction["location"]["address"]
      new_transaction.city = transaction["location"]["city"]
      new_transaction.latitude = transaction["location"]["lat"]
      new_transaction.longitude = transaction["location"]["lon"]
      new_transaction.state = transaction["location"]["state"]
      new_transaction.zip = transaction["location"]["zip"]
    elsif(transaction["location"]["address"] != nil)
      new_transaction.location_bool = true
      new_transaction.address = transaction["location"]["address"]
      new_transaction.city = transaction["location"]["city"]
      new_transaction.latitude = transaction["location"]["lat"]
      new_transaction.longitude = transaction["location"]["lon"]
      new_transaction.state = transaction["location"]["state"]
      new_transaction.zip = transaction["location"]["zip"]
    else
      new_transaction.location == false
      new_transaction.address = nil
      new_transaction.city = nil
      new_transaction.state = nil
      new_transaction.zip = nil
      new_transaction.latitude = nil
      new_transaction.longitude = nil
    end

    if(transaction["name"] != nil)
      new_transaction.location_name = transaction["name"]
    elsif(transaction["payment_meta"]["payee"] != nil)
      new_transaction.location_name = transaction["payment_meta"]["payee"]
    else
      new_transaction.location_name = "n/a"
    end

    if(new_transaction.save)
      puts "tx_id: #{transaction["transaction_id"]} saved successfully in transactions table"
      return true
    else
      puts "tx_id: #{transaction["transaction_id"]} failed to save in transactions table"
      return false
    end
  end

  def save_income(income_entry, user_id)
    new_income = Income.new()
    new_income.user_id = user_id
    puts "user_id = #{user_id}"
    if(income_entry["amount"].abs != nil)
      new_income.income_amount = income_entry["amount"].abs
    end
    puts "income_entry['amount'].abs = #{income_entry["amount"].abs}"
    if(income_entry["date"].to_date != nil)
      new_income.date = income_entry["date"].to_date
    end
    puts "income_entry['date'].to_date = #{income_entry["date"].to_date}"
    if(income_entry["payment_meta"]["payee"] != nil)
      new_income.source = income_entry["payment_meta"]["payee"]
      puts "income_entry['payment_meta']['payee'] = #{income_entry["payment_meta"]["payee"]}"
    end

    if(new_income.save)
      puts "tx_id: #{income_entry["transaction_id"]} saved successfully in incomes table"
      return true
    else
      puts "tx_id: #{income_entry["transaction_id"]} failed to save in incomes table"
      return false
    end
  end

  def changeCategory(hierarchy)
    #params: an array of categories
    #description: takes in an array of categories that were given from plaid
      #the last value in the hierarchy array is taken and used to find a key-value plaid_secret
      #in the classification hash. If a corresponding value is found, return that value,
      #else, return "miscellaneous".

    puts "#{hierarchy} passed into changeCategory"


    classification = {
    "Bank Fees" => "banking",
    "Overdraft" => "banking",
    "ATM" => "banking",
    "Late Payment" => "banking",
    "Fraud Dispute" => "banking",
    "Foreign Transaction" => "banking",
    "Wire Transfer" => "banking",
    "Insufficient Funds" => "banking",
    "Cash Advance" => "banking",
    "Excess Activity" => "banking",
    "Community" => "services",
    "Animal Shelter" => "pets",
    "Assisted Living Services" => "services",
    "Facilities and Nursing Homes" => "services",
    "Caretakers" => "services",
    "Cemetery" => "services",
    "Courts" => "services",
    "Day Care and Preschools" => "education",
    "Disabled Persons Services" => "services",
    "Drug and Alcohol Services" => "services",
    "Education" => "education",
    "Vocational Schools" => "education",
    "Tutoring and Educational Services" => "education",
    "Primary and Secondary Schools" => "education",
    "Fraternities and Sororities" => "education",
    "Driving Schools" => "education",
    "Dance Schools" => "education",
    "Culinary Lessons and Schools" => "education",
    "Computer Training" => "education",
    "Colleges and Universities" => "education",
    "Art School" => "education",
    "Adult Education" => "education",
    "Government Departments and Agencies" => "services",
    "Government Lobbyists" => "services",
    "Housing Assistance and Shelters" => "charity",
    "Law Enforcement" => "services",
    "Police Stations" => "services",
    "Fire Stations" => "services",
    "Correctional Institutions" => "services",
    "Libraries" => "education",
    "Military" => "services",
    "Organizations and Associations" => "services",
    "Youth Organizations" => "charity",
    "Environmental" => "charity",
    "Charities and Non-Profits" => "charity",
    "Post Offices" => "services",
    "Public and Social Services" => "services",
    "Religious" => "charity",
    "Temple" => "charity",
    "Synagogues" => "charity",
    "Mosques" => "charity",
    "Churches" => "charity",
    "Senior Citizen Services" => "services",
    "Retirement" => "services",
    "Food and Drink" => "dining",
    "Bar" => "dining",
    "Wine Bar" => "dining",
    "Sports Bar" => "dining",
    "Hotel Lounge" => "dining",
    "Breweries" => "dining",
    "Internet Cafes" => "dining",
    "Nightlife" => "entertainment",
    "Strip Club" => "entertainment",
    "Night Clubs" => "entertainment",
    "Karaoke" => "entertainment",
    "Jazz and Blues Cafe" => "entertainment",
    "Hookah Lounges" => "entertainment",
    "Adult Entertainment" => "entertainment",
    "Restaurants" => "dining",
    "Winery" => "dining",
    "Vegan and Vegetarian" => "dining",
    "Turkish" => "dining",
    "Thai" => "dining",
    "Swiss" => "dining",
    "Sushi" => "dining",
    "Steakhouses" => "dining",
    "Spanish" => "dining",
    "Seafood" => "dining",
    "Scandinavian" => "dining",
    "Portuguese" => "dining",
    "Pizza" => "dining",
    "Moroccan" => "dining",
    "Middle Eastern" => "dining",
    "Mexican" => "dining",
    "Mediterranean" => "dining",
    "Latin American" => "dining",
    "Korean" => "dining",
    "Juice Bar" => "dining",
    "Japanese" => "dining",
    "Italian" => "dining",
    "Indonesian" => "dining",
    "Indian" => "dining",
    "Ice Cream" => "dining",
    "Greek" => "dining",
    "German" => "dining",
    "Gastropub" => "dining",
    "French" => "dining",
    "Food Truck" => "dining",
    "Fish and Chips" => "dining",
    "Filipino" => "dining",
    "Fast Food" => "dining",
    "Falafel" => "dining",
    "Ethiopian" => "dining",
    "Eastern European" => "dining",
    "Donuts" => "dining",
    "Distillery" => "dining",
    "Diners" => "dining",
    "Dessert" => "dining",
    "Delis" => "dining",
    "Cupcake Shop" => "dining",
    "Cuban" => "dining",
    "Coffee Shop" => "dining",
    "Chinese" => "dining",
    "Caribbean" => "dining",
    "Cajun" => "dining",
    "Cafe" => "dining",
    "Burrito" => "dining",
    "Burgers" => "dining",
    "Breakfast Spot" => "dining",
    "Brazilian" => "dining",
    "Barbecue" => "dining",
    "Bakery" => "dining",
    "Bagel Shop" => "dining",
    "Australian" => "dining",
    "Asian" => "dining",
    "American" => "dining",
    "African" => "dining",
    "Afghan" => "dining",
    "Healthcare" => "medical",
    "Healthcare Services" => "medical",
    "Psychologists" => "medical",
    "Pregnancy and Sexual Health" => "medical",
    "Podiatrists" => "medical",
    "Physical Therapy" => "medical",
    "Optometrists" => "medical",
    "Nutritionists" => "medical",
    "Nurses" => "medical",
    "Mental Health" => "medical",
    "Medical Supplies and Labs" => "medical",
    "Hospitals, Clinics and Medical Centers" => "medical",
    "Emergency Services" => "medical",
    "Dentists" => "medical",
    "Counseling and Therapy" => "medical",
    "Chiropractors" => "medical",
    "Blood Banks and Centers" => "medical",
    "Alternative Medicine" => "medical",
    "Acupuncture" => "medical",
    "Physicians" => "medical",
    "Urologists" => "medical",
    "Respiratory" => "medical",
    "Radiologists" => "medical",
    "Psychiatrists" => "medical",
    "Plastic Surgeons" => "medical",
    "Pediatricians" => "medical",
    "Pathologists" => "medical",
    "Orthopedic Surgeons" => "medical",
    "Ophthalmologists" => "medical",
    "Oncologists" => "medical",
    "Obstetricians and Gynecologists" => "medical",
    "Neurologists" => "medical",
    "Internal Medicine" => "medical",
    "General Surgery" => "medical",
    "Gastroenterologists" => "medical",
    "Family Medicine" => "medical",
    "Ear, Nose and Throat" => "medical",
    "Dermatologists" => "medical",
    "Cardiologists" => "medical",
    "Anesthesiologists" => "medical",
    "Interest" => "banking",
    "Interest Earned" => "banking",
    "Interest Charged" => "banking",
    "Payment" => "debt",
    "Credit Card" => "debt",
    "Loan" => "debt",
    "Recreation" => "entertainment",
    "Arts and Entertainment" => "entertainment",
    "Theatrical Productions" => "entertainment",
    "Symphony and Opera" => "entertainment",
    "Sports Venues" => "entertainment",
    "Social Clubs" => "entertainment",
    "Psychics and Astrologers" => "entertainment",
    "Party Centers" => "entertainment",
    "Music and Show Venues" => "entertainment",
    "Museums" => "entertainment",
    "Movie Theatres" => "entertainment",
    "Fairgrounds and Rodeos" => "entertainment",
    "Entertainment" => "entertainment",
    "Dance Halls and Saloons" => "entertainment",
    "Circuses and Carnivals" => "entertainment",
    "Casinos and Gaming" => "entertainment",
    "Bowling" => "entertainment",
    "Billiards and Pool" => "entertainment",
    "Art Dealers and Galleries" => "entertainment",
    "Arcades and Amusement Parks" => "entertainment",
    "Aquarium" => "entertainment",
    "Athletic Fields" => "recreation",
    "Baseball" => "recreation",
    "Basketball" => "recreation",
    "Batting Cages" => "recreation",
    "Boating" => "recreation",
    "Campgrounds and RV Parks" => "recreation",
    "Canoes and Kayaks" => "recreation",
    "Combat Sports" => "recreation",
    "Cycling" => "recreation",
    "Dance" => "recreation",
    "Equestrian" => "recreation",
    "Football" => "recreation",
    "Go Carts" => "recreation",
    "Golf" => "recreation",
    "Gun Ranges" => "recreation",
    "Gymnastics" => "recreation",
    "Gyms and Fitness Centers" => "recreation",
    "Hiking" => "recreation",
    "Hockey" => "recreation",
    "Hot Air Balloons" => "recreation",
    "Hunting and Fishing" => "recreation",
    "Landmarks" => "recreation",
    "Monuments and Memorials" => "recreation",
    "Historic Sites" => "recreation",
    "Gardens" => "recreation",
    "Buildings and Structures" => "recreation",
    "Miniature Golf" => "recreation",
    "Outdoors" => "recreation",
    "Rivers" => "recreation",
    "Mountains" => "recreation",
    "Lakes" => "recreation",
    "Forests" => "recreation",
    "Beaches" => "recreation",
    "Paintball" => "recreation",
    "Parks" => "recreation",
    "Playgrounds" => "recreation",
    "Picnic Areas" => "recreation",
    "Natural Parks" => "recreation",
    "Personal Trainers" => "recreation",
    "Race Tracks" => "recreation",
    "Racquet Sports" => "recreation",
    "Racquetball" => "recreation",
    "Rafting" => "recreation",
    "Recreation Centers" => "recreation",
    "Rock Climbing" => "recreation",
    "Running" => "recreation",
    "Scuba Diving" => "recreation",
    "Skating" => "recreation",
    "Skydiving" => "recreation",
    "Snow Sports" => "recreation",
    "Soccer" => "recreation",
    "Sports and Recreation Camps" => "recreation",
    "Sports Clubs" => "recreation",
    "Stadiums and Arenas" => "recreation",
    "Swimming" => "recreation",
    "Tennis" => "recreation",
    "Water Sports" => "recreation",
    "Yoga and Pilates" => "recreation",
    "Zoo" => "recreation",
    "Service" => "services",
    "Advertising and Marketing" => "services",
    "Writing, Copywriting and Technical Writing" => "services",
    "Search Engine Marketing and Optimization" => "services",
    "Public Relations" => "services",
    "Promotional Items" => "services",
    "Print, TV, Radio and Outdoor Advertising" => "services",
    "Online Advertising" => "services",
    "Market Research and Consulting" => "services",
    "Direct Mail and Email Marketing Services" => "services",
    "Creative Services" => "services",
    "Advertising Agencies and Media Buyers" => "services",
    "Art Restoration" => "services",
    "Audiovisual" => "services",
    "Automation and Control Systems" => "services",
    "Automotive" => "automotive",
    "Towing" => "automotive",
    "Motorcycle, Moped and Scooter Repair" => "automotive",
    "Maintenance and Repair" => "automotive",
    "Car Wash and Detail" => "automotive",
    "Car Appraisers" => "automotive",
    "Auto Transmission" => "automotive",
    "Auto Tires" => "automotive",
    "Auto Smog Check" => "automotive",
    "Auto Oil and Lube" => "automotive",
    "Business and Strategy Consulting" => "services",
    "Business Services" => "services",
    "Printing and Publishing" => "services",
    "Cable" => "utilities",
    "Chemicals and Gasses" => "services",
    "Cleaning" => "housing",
    "Computers" => "electronics",
    "Construction" => "housing",
    "Specialty" => "housing",
    "Roofers" => "housing",
    "Painting" => "housing",
    "Masonry" => "housing",
    "Infrastructure" => "housing",
    "Heating, Ventilating and Air Conditioning" => "housing",
    "Electricians" => "housing",
    "Contractors" => "housing",
    "Carpet and Flooring" => "housing",
    "Carpenters" => "housing",
    "Credit Counseling and Bankruptcy Services" => "banking",
    "Dating and Escort" => "personal care",
    "Employment Agencies" => "services",
    "Engineering" => "services",
    "Media" => "entertainment",
    "Events and Event Planning" => "services",
    "Financial" => "banking",
    "Taxes" => "insurance and taxes",
    "Student Aid and Grants" => "education",
    "Stock Brokers" => "banking",
    "Loans and Mortgages" => "debt",
    "Holding and Investment Offices" => "banking",
    "Fund Raising" => "charity",
    "Financial Planning and Investments" => "banking",
    "Credit Reporting" => "banking",
    "Collections" => "banking",
    "Check Cashing" => "banking",
    "Business Brokers and Franchises" => "banking",
    "Banking and Finance" => "banking",
    "ATMs" => "banking",
    "Accounting and Bookkeeping" => "banking",
    "Food and Beverage" => "dining",
    "Distribution" => "dining",
    "Catering" => "dining",
    "Funeral Services" => "services",
    "Geological" => "services",
    "Home Improvement" => "housing",
    "Upholstery" => "housing",
    "Tree Service" => "housing",
    "Swimming Pool Maintenance and Services" => "housing",
    "Pools and Spas" => "housing",
    "Plumbing" => "housing",
    "Pest Control" => "housing",
    "Movers" => "housing",
    "Mobile Homes" => "housing",
    "Lighting Fixtures" => "housing",
    "Landscaping and Gardeners" => "housing",
    "Kitchens" => "housing",
    "Interior Design" => "housing",
    "Housewares" => "housing",
    "Home Inspection Services" => "housing",
    "Home Appliances" => "housing",
    "Heating, Ventilation and Air Conditioning" => "housing",
    "Hardware and Services" => "housing",
    "Fences, Fireplaces and Garage Doors" => "housing",
    "Doors and Windows" => "housing",
    "Architects" => "housing",
    "Household" => "housing",
    "Human Resources" => "services",
    "Immigration" => "services",
    "Import and Export" => "services",
    "Industrial Machinery and Vehicles" => "services",
    "Insurance" => "insurance and taxes",
    "Internet Services" => "services",
    "Leather" => "services",
    "Legal" => "services",
    "Logging and Sawmills" => "services",
    "Machine Shops" => "services",
    "Management" => "services",
    "Manufacturing" => "services",
    "Apparel and Fabric Products" => "services",
    "Computers and Office Machines" => "services",
    "Electrical Equipment and Components" => "services",
    "Furniture and Fixtures" => "services",
    "Glass Products" => "services",
    "Industrial Machinery and Equipment" => "services",
    "Leather Goods" => "services",
    "Metal Products" => "services",
    "Nonmetallic Mineral Products" => "services",
    "Paper Products" => "services",
    "Petroleum" => "services",
    "Plastic Products" => "services",
    "Rubber Products" => "services",
    "Service Instruments" => "services",
    "Textiles" => "services",
    "Transportation Equipment" => "services",
    "Wood Products" => "services",
    "Media Production" => "services",
    "Metals" => "services",
    "Mining" => "services",
    "Coal" => "services",
    "Metal" => "services",
    "Non-Metallic Minerals" => "services",
    "News Reporting" => "services",
    "Oil and Gas" => "services",
    "Packaging" => "services",
    "Paper" => "services",
    "Personal Care" => "personal care",
    "Tattooing" => "personal care",
    "Tanning Salons" => "personal care",
    "Spas" => "personal care",
    "Skin Care" => "personal care",
    "Piercing" => "personal care",
    "Massage Clinics and Therapists" => "personal care",
    "Manicures and Pedicures" => "personal care",
    "Laundry and Garment Services" => "personal care",
    "Hair Salons and Barbers" => "personal care",
    "Hair Removal" => "personal care",
    "Photography" => "services",
    "Plastics" => "services",
    "Rail" => "services",
    "Real Estate" => "housing",
    "Real Estate Development and Title Companies" => "housing",
    "Real Estate Appraiser" => "housing",
    "Real Estate Agents" => "housing",
    "Property Management" => "housing",
    "Corporate Housing" => "housing",
    "Commercial Real Estate" => "housing",
    "Building and Land Surveyors" => "housing",
    "Boarding Houses" => "housing",
    "Apartments, Condos and Houses" => "housing",
    "Rent" => "housing",
    "Refrigeration and Ice" => "services",
    "Renewable Energy" => "services",
    "Repair Services" => "services",
    "Research" => "services",
    "Rubber" => "services",
    "Scientific" => "services",
    "Security and Safety" => "insurance and taxes",
    "Shipping and Freight" => "services",
    "Software Development" => "services",
    "Storage" => "services",
    "Subscription" => "services",
    "Tailors" => "services",
    "Telecommunication Services" => "utilities",
    "Tourist Information and Services" => "travel",
    "Transportation" => "transit",
    "Travel Agents and Tour Operators" => "travel",
    "Utilities" => "utilities",
    "Water" => "utilities",
    "Sanitary and Waste Management" => "utilities",
    "Heating, Ventilating, and Air Conditioning" => "utilities",
    "Gas" => "utilities",
    "Electric" => "utilities",
    "Veterinarians" => "pets",
    "Water and Waste Management" => "utilities",
    "Web Design and Development" => "services",
    "Welding" => "services",
    "Agriculture and Forestry" => "services",
    "Crop Production" => "services",
    "Forestry" => "services",
    "Livestock and Animals" => "services",
    "Services" => "services",
    "Art and Graphic Design" => "services",
    "Shops" => "supplies",
    "Adult" => "entertainment",
    "Antiques" => "luxury",
    "Arts and Crafts" => "supplies",
    "Auctions" => "luxury",
    "Used Car Dealers" => "automotive",
    "Salvage Yards" => "automotive",
    "RVs and Motor Homes" => "automotive",
    "Motorcycles, Mopeds and Scooters" => "automotive",
    "Classic and Antique Car" => "automotive",
    "Car Parts and Accessories" => "automotive",
    "Car Dealers and Leasing" => "automotive",
    "Beauty Products" => "personal care",
    "Bicycles" => "recreation",
    "Boat Dealers" => "recreation",
    "Bookstores" => "education",
    "Cards and Stationery" => "supplies",
    "Children" => "gifts",
    "Clothing and Accessories" => "clothing",
    "Women's Store" => "clothing",
    "Swimwear" => "clothing",
    "Shoe Store" => "clothing",
    "Men's Store" => "clothing",
    "Lingerie Store" => "clothing",
    "Kids' Store" => "clothing",
    "Boutique" => "clothing",
    "Accessories Store" => "clothing",
    "Computers and Electronics" => "electronics",
    "Video Games" => "electronics",
    "Mobile Phones" => "electronics",
    "Cameras" => "electronics",
    "Construction Supplies" => "supplies",
    "Convenience Stores" => "gifts",
    "Costumes" => "clothing",
    "Dance and Music" => "recreation",
    "Department Stores" => "clothing",
    "Digital Purchase" => "electronics",
    "Discount Stores" => "supplies",
    "Electrical Equipment" => "electronics",
    "Equipment Rental" => "services",
    "Flea Markets" => "supplies",
    "Florists" => "gifts",
    "Food and Beverage Store" => "groceries",
    "Health Food" => "groceries",
    "Farmers Markets" => "groceries",
    "Beer, Wine and Spirits" => "groceries",
    "Fuel Dealer" => "automotive",
    "Furniture and Home Decor" => "housing",
    "Gift and Novelty" => "gifts",
    "Glasses and Optometrist" => "medical",
    "Hardware Store" => "supplies",
    "Hobby and Collectibles" => "luxury",
    "Industrial Supplies" => "supplies",
    "Jewelry and Watches" => "luxury",
    "Luggage" => "travel",
    "Marine Supplies" => "supplies",
    "Music, Video and DVD" => "entertainment",
    "Musical Instruments" => "entertainment",
    "Newsstands" => "entertainment",
    "Office Supplies" => "supplies",
    "Outlet" => "clothing",
    "Pawn Shops" => "supplies",
    "Pets" => "pets",
    "Pharmacies" => "medical",
    "Photos and Frames" => "supplies",
    "Shopping Centers and Malls" => "clothing",
    "Sporting Goods" => "recreation",
    "Supermarkets and Groceries" => "groceries",
    "Tobacco" => "luxury",
    "Toys" => "gifts",
    "Vintage and Thrift" => "supplies",
    "Warehouses and Wholesale Stores" => "supplies",
    "Wedding and Bridal" => "luxury",
    "Wholesale" => "supplies",
    "Lawn and Garden" => "housing",
    "Tax" => "insurance and taxes",
    "Refund" => "insurance and taxes",
    "Transfer" => "banking",
    "Internal Account Transfer" => "banking",
    "ACH" => "banking",
    "Billpay" => "banking",
    "Check" => "banking",
    "Credit" => "banking",
    "Debit" => "banking",
    "Deposit" => "banking",
    "Keep the Change Savings Program" => "banking",
    "Payroll" => "banking",
    "Benefits" => "banking",
    "Third Party" => "banking",
    "Venmo" => "banking",
    "Square Cash" => "banking",
    "Square" => "banking",
    "PayPal" => "banking",
    "Dwolla" => "banking",
    "Coinbase" => "banking",
    "Chase QuickPay" => "banking",
    "Acorns" => "banking",
    "Digit" => "banking",
    "Betterment" => "banking",
    "Plaid" => "banking",
    "Wire" => "banking",
    "Withdrawal" => "banking",
    "Save As You Go" => "banking",
    "Travel" => "travel",
    "Airlines and Aviation Services" => "travel",
    "Airports" => "travel",
    "Boat" => "travel",
    "Bus Stations" => "transit",
    "Car and Truck Rentals" => "travel",
    "Car Service" => "travel",
    "Ride Share" => "travel",
    "Charter Buses" => "travel",
    "Cruises" => "travel",
    "Gas Stations" => "automotive",
    "Heliports" => "travel",
    "Limos and Chauffeurs" => "travel",
    "Lodging" => "travel",
    "Resorts" => "travel",
    "Lodges and Vacation Rentals" => "travel",
    "Hotels and Motels" => "travel",
    "Hostels" => "travel",
    "Cottages and Cabins" => "travel",
    "Bed and Breakfasts" => "travel",
    "Parking" => "transit",
    "Public Transportation Services" => "transit",
    "Rail" => "transit",
    "Taxi" => "transit",
    "Tolls and Fees" => "transit",
    "Transportation Centers" => "travel",
    }

    # Item is whatever variable plaid returns a transaction as
    #categories = item["category"]
    # Get the category_id, which is a column for transactions
    #category_id = categories["category_id"]
    # Get the category_type, which is a column for transactions
    #transaction_type = categories["group"]
    # Gets the array of categories provided by plaid
    #hierarchy = categories["hierarchy"]

    # Length of array
    length = hierarchy.length
    # Get the last category in the hierarchy array given by plaid, which will be the most specific category
    group = hierarchy[length - 1]
    if classification[group] then
      # Set the category (for the transactions model, which is 1 of 24 categories) by finding the plaid category in the hash
      category = classification[group]
      puts "Category found in hash. '#{group}' changed to '#{category}'"
    else
      # Default to miscellaneous category
      category = "miscellaneous"
      puts "Category not found, '#{group}' changed to '#{category}'"
    end

    return category
  end

end
