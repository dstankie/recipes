class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
    	t.string :name
		t.string :description
		t.boolean :vegetarian
		t.string :category
    	t.timestamps
    end
  end
end
