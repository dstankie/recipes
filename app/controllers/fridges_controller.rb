class FridgesController < ApplicationController
    before_action :require_login
    before_action :identify_user

    def identify_user
      user = User.find_by(id: session[:user_id])
      if user
        @username = user.name
      end
    end

    def require_login
      if session[:user_id].blank?
        redirect_to new_session_path, notice: "Please login to create and edit your inventory"
      end
    end

    def index
        @user = User.find(session[:user_id])
    	@frs = User.find(@user.id).ingredients
    end

    def new
    	cats = Ingredient.uniq.pluck('category')
    	@gr = Hash.new
    	cats.each do |cat|
    		@gr[cat] = Ingredient.where(["category='"+cat+"'"])
    	end
    end

    def show
    	@fridge = User.find(session[:user_id]).ingredients
    end

    def edit
        #cats = Ingredient.uniq.pluck('category')
        @fridge = User.find(session[:user_id]).ingredients
        @everythingelse = Ingredient.all.order('name asc') - @fridge
    end

    def create
    	x = params[:ingredgients_checkbox]
    	x.each do |ingredient_id|
		    m = Fridge.new
		    m.user_id = session["user_id"]
		    m.ingredient_id = ingredient_id
		    m.save
		end
	    redirect_to user_path(session["user_id"])
    end

    def update(toadd={},todelete={})
        todelete = params[:delete_checkbox] if not params[:delete_checkbox].nil?
        toadd = params[:add_checkbox] if not params[:add_checkbox].nil?
        u = User.find(session["user_id"])
        
        if todelete
            todelete.each do |t|
                u.ingredients.destroy(t)
            end
        end

        if toadd #ruby hates looping over nil?
            toadd.each do |t|
                Fridge.create(:user_id => u.id, :ingredient_id => t)
            end
        end

        redirect_to user_path(session["user_id"]), notice: "deleted #{todelete.count} & added #{toadd.count} ingredients to your inventory"
    end


end
