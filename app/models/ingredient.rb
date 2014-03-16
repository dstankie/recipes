class Ingredient < ActiveRecord::Base
	has_many :users, :through => :fridges
	has_many :fridges
end
