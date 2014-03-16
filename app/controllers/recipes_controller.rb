class RecipesController < ApplicationController
    before_action :require_login, :except => [:search, :index, :show]
    before_action :identify_user
    before_action :require_recipe, :except => [:search, :index, :create, :new, :usearch]
    
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

    def require_recipe
      if params[:id].blank?
        redirect_to recipe_path, notice: "Sorry, couldn't find that recipe for you."
      end
    end

    def index
      @random_recipes = Recipe.find(Recipe.pluck(:id).shuffle[0..5])
      @cats = Course.select(:name).uniq
    end

    def show
      @recipe = Recipe.find(params[:id])
      if params[:shopping]
        @shopping = Recipe.find(params[:shopping])
      else
        @shopping = @recipe.ingredients
      end

      uid = session[:user_id]
      @user = User.find(uid)
      if not uid.blank?
        ingrs = @user.ingredients
        @shopping = @shopping - ingrs
      end


    end

    def update()
        if params[:del_ingredients_checkbox]
          tokeep = params[:del_ingredients_checkbox]
        else
          tokeep = []
        end
        toadd = params[:ingredients_checkbox]
        r = Recipe.find(params[:id])

        ingrs = Usedin.where("recipe_id = ?",r.id).pluck("ingredient_id")
        ingr_destroy = 
        ingrs.each do |x|
          if not tokeep.include? x.to_s
            u = Usedin.select(:id).where(:recipe_id => r.id, :ingredient_id => x)
            Usedin.destroy(u[0].id)
          end
        end

        if toadd #ruby hates looping over nil?
            toadd.each do |t|
                Usedin.create(:recipe_id => r.id, :ingredient_id => t)
            end
        end

        r.name = params[:name]
        r.cook_time = params[:cook_time]*60
        if params[:directions]
          r.directions = params[:directions]
        else
          r.directions = nil
        end
        if params[:ext_url]
          r.ext_url = params[:ext_url]
        else
          r.ext_url = nil
        end

        r.image_url = params[:image_url]
        r.save

        redirect_to recipe_path, notice: "Updated!"
    end

    def edit
      @recipe = Recipe.find(params[:id])
      puts "\n\n\n\n\n\n\n" + @recipe.id.to_s
      @ingredient_ids = Usedin.where("recipe_id = ?",1).pluck("ingredient_id")
      @ingredients = @recipe.ingredients
      puts "\n\n\n\n\n\n\n" + @ingredient_ids.to_s

      @cats = Ingredient.uniq.pluck('category')
      @grouped_ingredients = Hash.new
      @cats.each do |cat|
        @grouped_ingredients[cat] = Ingredient.where(["category='"+cat+"'"]).order("name asc")
      end
    end

    def new
      @cats = Ingredient.uniq.pluck('category')
      @grouped_ingredients = Hash.new
      @cats.each do |cat|
        @grouped_ingredients[cat] = Ingredient.where(["category='"+cat+"'"]).order("name asc")
      end
    end

    def findRecipeMatches(ingrs)

      recipe_fuzzy_ingredients = Hash.new
      recipe_missing_ingredients = Hash.new

      ingrs.each do |i|
      # puts "\n\n\n\n\n Checking out ingredient "+i.id.to_s + i.name+"\n\n\n\n\n\n"
        found_in = Usedin.where(:ingredient_id => i.id)
        found_in.each do |f|
          # puts "\n\n\n\n\n Checking out recipe "+f.recipe_id.to_s + Recipe.find(f.recipe_id).name+"\n\n\n\n\n\n"
          if recipe_fuzzy_ingredients.has_key? f.recipe_id
            # puts "\n\n\n\n\n Checking out ingredient "+i.id.to_s + i.name+"\n\n\n\n\n\n"
            recipe_fuzzy_ingredients[f.recipe_id] += [i]
            recipe_missing_ingredients[f.recipe_id] -= [i]
          else
            recipe_fuzzy_ingredients[f.recipe_id] = [i]
            recipe_missing_ingredients[f.recipe_id] = Recipe.find(f.recipe_id).ingredients - [i]
          end

          # puts "\n\n444444444   \n"
          # puts (recipe_fuzzy_ingredients[f.recipe_id].count + recipe_missing_ingredients[f.recipe_id].count).to_s + " =? " + Recipe.find(f.recipe_id).ingredients.count.to_s  + '\n\n'
        end
      end

      puts "\n\n\n\n\n !!!! we have "+recipe_fuzzy_ingredients.to_s + "\n\n\n\n\n\n"
      puts "\n\n\n\n\n !!!! missing "+recipe_missing_ingredients.to_s + "\n\n\n\n\n\n"

      return recipe_fuzzy_ingredients.sort_by {|_k, v| -v.count}, recipe_missing_ingredients.sort_by {|_k, v| -v.count}
    end

    def findIngredeintMatches(terms)
      ingredients_matches = []
      ingredients_not_found = []
      ingredients_like = Hash.new
      terms.each do |t| #check each search term for an exact match in ingredients list
        i = Ingredient.find_by(:name => t.strip)
        if i
            ingredients_matches << i
        else #add term to 'not found' list and find all potential matches via LIKE query
          ingredients_not_found << t.strip
          i = Ingredient.where("name LIKE ?", "%"+t.strip+"%")
          ingredients_like[t.strip] = i
        end
      end

      return ingredients_matches.uniq, ingredients_like, ingredients_not_found.uniq
    end

    def usearch
      params[:query] = "onion"
      redirect_to "/recipes/search"
    end

    def search
      if params[:query].blank? and params[:ingredgients_checkbox].blank?
        redirect_to recipes_path, notice: "No search terms were entered"
      end


      @user = session[:user_id]
      if @user
        @ingredient_ids =  Fridge.where("user_id = ?",@user).pluck("ingredient_id")
      end
      if params[:query].blank?
        search_terms = params[:ingredgients_checkbox]
      else
        @query = params[:query]
        search_terms = (@query+",").split(",")
        @recipe_matches = Recipe.where("name LIKE ?", "%"+@query+"%")
      end
      
      #compile list of ingredients that match the search terms and similar items for non-matches
      @ingredients_matches, @ingredients_like, @ingredients_not_found = findIngredeintMatches(search_terms)

      #Find recipes that match the query exactly by name and by
      #number of valid ingredients that were submitted in the query
      @recipe_fuzzy_ingredients,@recipe_missing_ingredients = findRecipeMatches(@ingredients_matches)

      #fuzzy matches by most ingredients to least
      @recipe_fuzzy_ingredients.sort_by {|k,v| v.count}

    end

    def create

      if params[:ingredgients_checkbox].blank?
        redirect_to :back, notice: "There was an error creating the recipe."
      end

      ingredient_ids = params[:ingredgients_checkbox]

      r = Recipe.new
      r.name = params[:name]
      r.cook_time = params[:cook_time]*60
      if params[:directions]
        r.directions = params[:directions]
      else
        r.directions = nil
      end
      if params[:ext_url]
        r.ext_url = params[:ext_url]
      else
        r.ext_url = nil
      end

      r.image_url = params[:image_url]
      r.save
  
      ingredient_ids.each do |x|
        Usedin.create(:recipe_id => r.id, :ingredient_id => x)
      end


      redirect_to recipe_path(r.id)
    end

end
