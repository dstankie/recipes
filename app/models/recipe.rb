class Recipe < ActiveRecord::Base
	has_many :ingredients, :through => :usedins
	has_many :usedins
	has_many :courses
end
