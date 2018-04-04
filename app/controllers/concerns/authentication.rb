# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  def current_user
    @current_user ||= session[:current_user]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_auth!
    unless user_signed_in?
      client = get_oidc_client

      session[:state] = SecureRandom.uuid # You can specify or pass in your own state here
      session[:nonce] = SecureRandom.hex(16) # You should store this and validate it on return.
      session[:return_url] = request.original_url
      redirect_to client.authorization_uri(
          :state => session[:state],
          :nonce => session[:nonce],
          :scope => [:profile, :email, :address, :phone]
      )
    end
  end

  def auth_callback
    raise "State missmatch error" if params[:state] != session[:state]

    client = get_oidc_client
    client.authorization_code = params[:code]
    access_token = client.access_token!
    userinfo = access_token.userinfo!
    session[:id_token] = access_token.id_token # store this for logout flows.
    session[:current_user] = userinfo
    redirect_to session[:return_url]
  end


  private

  def get_oidc_client
    OpenIDConnect::Client.new(
        :identifier => Rails.configuration.x.oidc_client_id,
        :secret => Rails.configuration.x.oidc_client_secret,
        :redirect_uri => "#{Rails.configuration.x.base_url}/oidc/cb",
        :host => Rails.configuration.x.oidc_host,
        :authorization_endpoint => '/auth',
        :token_endpoint => '/token',
        :userinfo_endpoint => '/me'
    )
  end
end
