class ApplicationController < ActionController::Base
  require 'date'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    if !logged_in?
      flash[:error] = "ログインして下さい。"
      redirect_to root_path
    end
  end

  def update_recent_customer(id)
    rc = RecentCustomer.find_by(customer_id: id)
    if rc 
      rc.access_date = DateTime.now
      rc.save
    else
      rc = RecentCustomer.new
      rc.customer_id = id
      rc.access_date = DateTime.now
      rc.save
    end
  end
  
end
