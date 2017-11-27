class BankSyncController < ApplicationController
  skip_before_action :verify_authenticity_token
  #before_action :confirm_user_logged_in

  layout "menu"

  $client = Plaid::Client.new(env: :sandbox,
                             client_id: Rails.application.secrets.plaid_client_id,
                             secret: Rails.application.secrets.plaid_secret,
                             public_key: Rails.application.secrets.plaid_public_key)

  access_token = nil

  #$current_user = User.find(session[:user_id])

  def index
    @access_token = params[:access_token]
    @item_id = params[:item_id]
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
        redirect_to(:action => "create_bank_account", :access_token => access_token, :item_id => item_id)
      else
        redirect_to(:action => "index", :message => "Error, failed to create item") and return
      end
    end
  end

  def delete_access_token
    #delete item, given access_token
    $client.item.delete(params['access_token']);
  end

  def create_bank_account
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

        #update bank balance in database
        currentUser = User.find(session[:user_id])

        #sum up all the bank_balances of this user.
          currentItem = currentUser.items.find_by item_id: newAccount.item_id
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

        @message += "'#{newAccount.official_name}' successfully saved. "
        puts "#{newAccount.official_name}, successfully saved. "
        #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
      else
        @message += "'#{newAccount.official_name}' failed to be saved. "
        puts "#{newAccount.official_name}, failed to be saved. "
        #redirect_to(controller: "bank_sync", action: "index", message: @message) and return
      end

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

    response = $client.accounts.get()




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

  def get_transaction
    #confirm that user has
  end

  def show_depository_accounts
    #params: user_id, item_id, account_id
    currentUser = User.find(session[:user_id])
    item = currentUser.items.find_by item_id: params[:item_id]
    bank_account = item.bank_account
  end

end
