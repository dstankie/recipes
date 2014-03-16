class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|

      t.string :name
  		t.integer :cook_time
  		t.string :course
  		t.text :directions
      t.string :ext_url
      t.string :image_url
      t.integer :average_rating
      t.integer :number_of_ratings
      t.timestamps
    end
  end
end
