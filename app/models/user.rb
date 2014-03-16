class User < ActiveRecord::Base
	has_secure_password
	has_many :ingredients, :through => :fridges
	has_many :fridges
end

