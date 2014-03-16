class SessionsController < ApplicationController

  def destroy
    reset_session
    redirect_to root_url, notice: "You are logged out"
  end

  def create
    email_address = params[:email]

    user = User.find_by(email: email_address)
    if user
      if user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to :root, notice: "You are logged in"
      else
        redirect_to :back, notice: "The password was incorrect"
      end
    else
       redirect_to :back, notice: "Unknown Email Address"
    end
  end

end
