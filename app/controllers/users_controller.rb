class UsersController < ApplicationController
  
  before_action :require_login, :except => [:new, :create]
  before_action :identify_user

  def identify_user
    user = User.find_by(id: session[:user_id])
    if user
      @username = user.name
    end
  end

  def require_login
    if session[:user_id].blank?
      redirect_to root_url, notice: "Please login to access that page"
    end
  end
  
  def show
    @user = User.find(session[:user_id])
    @fr = Fridge.find_by(:user_id => @user.id)
    @ingredients = @user.ingredients
  end

  def create
    user = User.new
    user.name = params[:name]
    user.email = params[:email]
    user.password = params[:password]
    user.password_confirmation = params[:password]

    if User.find_by(email: user.email)
      redirect_to :back, notice: "Account already exists for this email"
    else
      user.save!
      session[:user_id] = user.id
      redirect_to root_url
    end
  end

end
