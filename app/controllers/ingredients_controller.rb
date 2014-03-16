class IngredientsController < ApplicationController
    before_action :require_login, :except => [:index, :show]
    before_action :identify_user

    def identify_user
      user = User.find_by(id: session[:user_id])
      if user
        @username = user.name
      end
    end

    def require_login
      if session[:user_id].blank?
        redirect_to new_session_path, notice: "Please login to create and edit ingredients"
      end
    end



    def index
    	#@ingrs = Ingredient.all.order("name asc")
    	
    	cats = Ingredient.uniq.pluck('category')
    	@gr = Hash.new
    	cats.each do |cat|
    		@gr[cat] = Ingredient.where(["category='"+cat+"'"]).order("name asc")
    	end
    end

  	def show
    	@ingredient = Ingredient.find(params[:id])
	end

    def edit
        @ingredient = Ingredient.find(params[:id])        
    end

    def update
        i = Ingredient.find(params[:id])
        ingr.name = params[:name]
        ingr.category = params[:category]
        ingr.save!
        redirect_to ingredient_path(ingr.id)
    end


	def create
	    ingr = Ingredient.new
	    ingr.name = params[:name]
	    ingr.category = params[:category]
	    ingr.save!
	    redirect_to ingredient_path(ingr.id)
  	end

end
