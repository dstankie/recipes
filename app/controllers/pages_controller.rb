  class PagesController < ApplicationController

    before_action :require_login, :except => [:home, :login]
    before_action :identify_user

    def identify_user
      user = User.find_by(id: session[:user_id])
      if user
        @username = user.name
      end
    end

    def require_login
      if session[:user_id].blank?
        redirect_to root_url, notice: "Please login to see this page"
      end
    end

    def logout
      #session[:username] = nil
      reset_session
      redirect_to root_url
    end

    def login
      session[:id] = params[:name]
      redirect_to root_url
    end

  end








