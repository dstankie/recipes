class CreateFridges < ActiveRecord::Migration
  def change
    create_table :fridges do |t|
    	t.belongs_to :user
      	t.belongs_to :ingredient
      	t.timestamps
    end
  end
end

