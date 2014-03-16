require 'open-uri'
require 'json'


recipe_files = ["entrees.json"]
ingredients_hash = []

recipe_files.each do |rf|
	recipe_hashes = JSON.parse(open(rf).read)['matches']


	recipe_hashes.each do |recipe_hash|
		recipe_hash['ingredients'].each do |x|
			ingredients_hash << x
		end
	end
end

ingredients_hash.uniq.each do |y|
	puts '{"name":"'+y+'","category":[""],"vegetarian":""},'

end
