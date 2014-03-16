# require 'open-uri'
# require 'json'


User.destroy_all
Fridge.destroy_all
Ingredient.destroy_all

ingredients_file = Rails.root.join('db', 'ingredients.json').to_s
ingredients_hashes = JSON.parse(open(ingredients_file).read)

#populate Ingredients table.  These are all taken from the json files I obtained elsewhere
#I ended up formatting this json file semi-manually because there was no easy way to get
#richer data specific to the ingredients in the recipes.
ingredients_hashes.each do |ingredients_hash|
	i = Ingredient.new
	i.name = ingredients_hash["name"]
	i.category = ingredients_hash["category"][0]
	i.vegetarian = ingredients_hash["vegetarian"]
	i.save
end

Recipe.destroy_all
Usedin.destroy_all
Course.destroy_all

#This data was obtained through the api for yummly.com
#Unfortunately there was not an easy way to find recipes in bulk
#in a usable format that also included the recipe directions as well.
#I've plucked the links yummply provides to external sites
recipe_files = ["breakfast.json","appetizers.json","entrees.json"]

recipe_files.each do |rf|
	recipe_file = Rails.root.join('db', rf).to_s
	recipe_hashes = JSON.parse(open(recipe_file).read)['matches']

	recipe_hashes.each do |recipe_hash|
		if recipe_hash
			b = Recipe.new
			b.name = recipe_hash['recipeName']
			b.ext_url = "http://www.yummly.com/recipe/external/"+recipe_hash['id']
			if recipe_hash['totalTimeInSeconds']
				b.cook_time = recipe_hash['totalTimeInSeconds']
			else
				b.cook_time = 999
			end
			b.directions = recipe_hash['directions']

			image = recipe_hash['imageUrlsBySize']['90'].split('=')[0]+"=s1200-c"
			b.image_url = image

			b.save

			recipe_hash['ingredients'].each do |x|
				p = Ingredient.find_by(:name => x)
				Usedin.create(:recipe_id => b.id, :ingredient_id => p.id)
			end
			rcourses = recipe_hash['attributes']['course']
			if rcourses
				rcourses.each do |x|
					Course.create(:recipe_id => b.id, :name => x)
				end
			else
				Course.create(:recipe_id => b.id, :name => "Other")
			end

		end
	end
end
