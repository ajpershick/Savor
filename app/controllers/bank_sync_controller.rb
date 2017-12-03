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
  def get_access_token
    exchange_token_response = $client.item.public_token.exchange(params['public_token'])
    access_token = exchange_token_response['access_token']
    item_id = exchange_token_response['item_id']
    puts "access token: #{access_token}"
    puts "item id: #{item_id}"
    exchange_token_response.to_json

    item_response = $client.item.get(access_token)

    institution = $client.institutions.get_by_id(item_response["item"]["institution_id"])
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
        #redirect_to(:action => "index", :access_token => access_token, :item_id => item_id, :message => "Success, item created") and return
        redirect_to(:action => "create_bank_account", :access_token => access_token, :item_id => item_id) and return
      else
        redirect_to(:action => "index", :message => "Error, failed to create item") and return
      end
    end
  end

  def delete_access_token
    #delete item, given access_token
    $client.item.delete(params['access_token']);
  end

  def create_bank_account #working
    #parameters:
      #access_token, item_id
    #precondition:
      #item_id and access_token is not nil
    #postcondition:
      #created a bank_account record for each account contained within the item, from plaid
    #description:
      #sends an http request to Plaid to get all the accounts associated with the item

    #"access-sandbox-4abdcc4a-d38a-4298-9da9-354fd51009cc"

      #response from plaid servers, in the form of a hash {"accounts", "item", "request_id"}
    accounts_response = $client.accounts.get(params[:access_token])

      #the accounts array, extracted from the accounts_response
    accounts_array = accounts_response["accounts"]

      #create an empty message for messages to be appended to it in the loop
    @message = ''

    currentUser = User.find(session[:user_id])

    currentItem = currentUser.items.find_by item_id: params[:item_id]

    total_balance = 0
    grand_total_balance = 0
    accounts_array.each do |acc|
      newAccount = BankAccount.new()
      newAccount.user_id = session[:user_id]
      newAccount.item_id = params[:item_id]
      newAccount.account_id = acc['account_id']
      newAccount.available_balance = acc['balances']['available']
      newAccount.current_balance = acc['balances']['current']
      newAccount.name = acc['name']
      newAccount.mask = acc['mask']
      newAccount.official_name = acc['official_name']
      newAccount.account_type = acc['type']
      newAccount.account_subtype = acc['subtype']

      total_balance+=newAccount.current_balance
      if(newAccount.save)
        @message += "'#{newAccount.official_name}' successfully saved. "
        puts "#{newAccount.official_name}, successfully saved. "
        #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
      else
        @message += "'#{newAccount.official_name}' failed to be saved. "
        puts "#{newAccount.official_name}, failed to be saved. "
        #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
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
    elsif(isCurrentAccountBalanceSaved == false)
      @message += "Failed to update account balance. "
      puts "Failed to update account balance. "
      #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
    elsif(isTotalAccountBalanceSaved == false)
      @message += "Failed to update TOTAL account balance. "
      puts "Failed to update TOTAL account balance. "
    end

  redirect_to(controller: "bank_sync", action: "index", message: @message) and return

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
      redirect_to(controller: "bank_sync", action: "index", message: @message)
    end


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
    @account_id = this_acc.account_id
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

  def get_all_transactions
    #gets transactions from the plaid servers and update savor database
      #copies the bank_transactions table to the transactions table.
      #executed after the item is created, to fetch all available transaction data into savor database
    #params: access_token, account_ids, bank_account_id
    @access_token = params[:access_token]
    @account_ids = params[:account_ids] #the account id's associated with plaid

    #check precondition
    accessTokenIsValid = checkAccessToken(@access_token)
    if(accessTokenIsValid == false)
      puts "Error in get_all_transactions, access_token invalid"
      return false
    end

    this_item = Item.find_by access_token: @access_token
    this_item_id = this_item.id
    this_user_id = this_item.user_id

    #currentUser = User.find(session[:user_id])
    #start_date = latest date
    end_date = Date.today.to_date.to_formatted_s #formats the date to YYYY-MM-DD

    start_date = Date.today - 728
    start_date = start_date.to_date.to_formatted_s #formats the date to YYYY-MM-DD


    if(@account_ids == nil)
      #populate @account_ids array with account_ids
      a_pos = 0
      this_item.bank_accounts.each do |i|
        @account_ids[a_pos] = i["account_id"]
        pos+=1
      end
    end

    @account_ids.each do |acc_id|
      #check if transactions are available from 24 months since the item creation date.
      #find the start date
      # start with (current date - 24 months)

      #check precondition that the accound_id is valid
      this_account = this_item.bank_accounts.find_by account_id: acc_id
      if(this_account == nil)
        puts "Error, no bank_account found with account_id: #{acc_id}"
        return false
      end

      this_account_id = this_account.id
      transactions_new = get_transactions(account_id, @access_token, start_date, end_date)
      transactions_all = transactions_new
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

      #save transactions_all into database
      transactions_all.each do |transaction|

        #save transaction in bank_transactions table
        isSavedBankTransaction = save_bank_transaction(transaction, bank_account_id, this_item_id, this_user_id)

        if(isSavedBankTransaction == false)
          puts "failed to save to bank_transactions table"
        end

        #save transaction into transactions table
        isSavedTransaction = save_transaction(transaction, this_user_id)

        if(isSavedTransaction == false)
          puts "failed to save to Transaction"
        end

      end #end of transactions_all loop

    end #end of @accounts_id loop

  end # end of get_all_transactions

  def get_new_transactions
  end

  def show_transactions
  end

  #CONTROLLER FUNCTIONS

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
    end_date_copy = end_date.to_datebank_account_id
    dateIsValid = start_date_copy < end_date_copy

    if(dateIsValid == false)
      puts "Error in get_transactions function, start_date must be older than end_date"
      return false
    end



    if(account_id != nil)

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

    # continue fetching for new transactions, until start_date = end_date
    # AND, the previous transactions fetched are the same as the current transactions fetched.

    return retreived_transactions

  end

  def remove_dupilicates(transactions_new, transactions_all)
    #params:
      #transactions_new: array of transactions, majority of which are new
      #transactions_old: saved transactions
    #description: fetches all the transaction for the given account_id
      #and returns an array of transactions fetched.

      pos = transactions_new.length - 1

      for i in 0..(transactions_new.length - 1)
        dupe = false
        #loop through og trans to find the last transaction_id
        transactions_all.each do |og_trans|
          if(transactions_new[pos]["transaction_id"] == og_trans["transaction_id"])
            dupe = true
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

      transactions_new_filtered = transactions_new[0..(new_pos+1)]
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

  def save_bank_transaction(transaction, bank_account_id, item_id, user_id)
      bank_transaction = BankTransaction.new()
      bank_transaction.user_id = user_id
      bank_transaction.item_id = item_id
      bank_transaction.account_id = transaction["account_id"]
      bank_transaction.bank_account_id = bank_account_id
      bank_transaction.transaction_id = transaction["transaction_id"]
      bank_transaction.category = transaction["category"]
      bank_transaction.category_id = transaction["category_id"]
      bank_transaction.transaction_type = transaction["special"]
      bank_transaction.amount = transaction["amount"]
      bank_transaction.date = transaction["date"].to_date
      if(transaction["location"]["address"] == nil && transaction["location"]["lat"] == nil)
        bank_transaction.location_bool == false
        bank_transaction.location[0] = transaction["location"]["address"]
        bank_transaction.location[1] = transaction["location"]["city"]
        bank_transaction.location[2] = transaction["location"]["lat"]
        bank_transaction.location[3] = transaction["location"]["lon"]
        bank_transaction.location[4] = transaction["location"]["state"]
        bank_transaction.location[5] = transaction["location"]["store_number"]
        bank_transaction.location[6] = transaction["location"]["zip"]
      elsif(transaction["location"]["lat"] != nil && transaction["location"]["lon"] != nil)
        bank_transaction.location_bool = true
        bank_transaction.location[0] = transaction["location"]["address"]
        bank_transaction.location[1] = transaction["location"]["city"]
        bank_transaction.location[2] = transaction["location"]["lat"]
        bank_transaction.location[3] = transaction["location"]["lon"]
        bank_transaction.location[4] = transaction["location"]["state"]
        bank_transaction.location[5] = transaction["location"]["store_number"]
        bank_transaction.location[6] = transaction["location"]["zip"]
      elsif(transaction["location"]["address"] != nil)
        bank_transaction.location_bool = true
        bank_transaction.location[0] = transaction["location"]["address"]
        bank_transaction.location[1] = transaction["location"]["city"]
        bank_transaction.location[2] = transaction["location"]["lat"]
        bank_transaction.location[3] = transaction["location"]["lon"]
        bank_transaction.location[4] = transaction["location"]["state"]
        bank_transaction.location[5] = transaction["location"]["store_number"]
        bank_transaction.location[6] = transaction["location"]["zip"]
      else
        bank_transaction.location_bool == false
        bank_transaction.location[0] = transaction["location"]["address"]
        bank_transaction.location[1] = transaction["location"]["city"]
        bank_transaction.location[2] = transaction["location"]["lat"]
        bank_transaction.location[3] = transaction["location"]["lon"]
        bank_transaction.location[4] = transaction["location"]["state"]
        bank_transaction.location[5] = transaction["location"]["store_number"]
        bank_transaction.location[6] = transaction["location"]["zip"]
      end
      bank_transaction.pending = transaction["pending"]
      bank_transaction.pending_transaction_id = transaction["pending_transaction_id"]
      if(bank_transaction.save)
        puts "tx_id: #{transaction_id} saved successfully in bank_transactions table"
        return true
      else
        puts "tx_id: #{transaction_id} failed to save in bank_transactions table"
        return false
      end
  end

  def save_transaction(transaction, user_id)
    bank_transaction = Transaction.new()
    bank_transaction.user_id = user_id
    bank_transaction.amount = transaction["amount"]
    bank_transaction.date = transaction["date"].to_date
    bank_transaction.category = transaction["category"][0]
    bank_transaction.transaction_type = transaction["transaction_type"]
    bank_transaction.unique_id = transaction["transaction_id"]

    if(transaction["location"]["address"] == nil && transaction["location"]["lat"] == nil)
      bank_transaction.location == false
      bank_transaction.address = nil
      bank_transaction.city = nil
      bank_transaction.state = nil
      bank_transaction.zip = nil
      bank_transaction.latitude = nil
      bank_transaction.longitude = nil
    elsif(transaction["location"]["lat"] != nil && transaction["location"]["lon"] != nil)
      bank_transaction.location_bool = true
      bank_transaction.address = transaction["location"]["address"]
      bank_transaction.city = transaction["location"]["city"]
      bank_transaction.latitude = transaction["location"]["lat"]
      bank_transaction.longitude = transaction["location"]["lon"]
      bank_transaction.state = transaction["location"]["state"]
      bank_transaction.zip = transaction["location"]["zip"]
    elsif(transaction["location"]["address"] != nil)
      bank_transaction.location_bool = true
      bank_transaction.address = transaction["location"]["address"]
      bank_transaction.city = transaction["location"]["city"]
      bank_transaction.latitude = transaction["location"]["lat"]
      bank_transaction.longitude = transaction["location"]["lon"]
      bank_transaction.state = transaction["location"]["state"]
      bank_transaction.zip = transaction["location"]["zip"]
    else
      bank_transaction.location == false
      bank_transaction.address = nil
      bank_transaction.city = nil
      bank_transaction.state = nil
      bank_transaction.zip = nil
      bank_transaction.latitude = nil
      bank_transaction.longitude = nil
    end
    bank_transaction.location_name = transaction["payment_meta"]["payee"]
    if(bank_transaction.save)
      puts "tx_id: #{transaction_id} saved successfully in transactions table"
      return true
    else
      puts "tx_id: #{transaction_id} failed to save in transactions table"
      return false
    end
  end

end
