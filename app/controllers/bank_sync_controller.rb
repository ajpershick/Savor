class BankSyncController < ApplicationController
  skip_before_action :verify_authenticity_token

  layout "menu"

  $client = Plaid::Client.new(env: :sandbox,
                             client_id: Rails.application.secrets.plaid_client_id,
                             secret: Rails.application.secrets.plaid_secret,
                             public_key: Rails.application.secrets.plaid_public_key)

  access_token = nil

  def index
    @access_token = params[:access_token]
    @item_id = params[:item_id]
    @message = params[:message]
  end

  def create_item
  end

  def add_account
  end

  def get_access_token
    exchange_token_response = $client.item.public_token.exchange(params['public_token'])
    access_token = exchange_token_response['access_token']
    item_id = exchange_token_response['item_id']
    puts "access token: #{access_token}"
    puts "item id: #{item_id}"
    exchange_token_response.to_json
    if(access_token != nil)
      new_item = Item.new()
      new_item.user_id = session[:user_id]
      new_item.access_token = access_token
      new_item.item_id = item_id
      new_item.save
      if(new_item != nil)
        redirect_to(:action => "index", :access_token => access_token, :item_id => item_id, :message => "Success, item created") and return
      else
        redirect_to(:action => "index", :message => "Error, failed to create item") and return
      end
    end
  end

  def delete_access_token
    #delete item, given access_token
    client.item.delete(params['access_token']);

  end

end
