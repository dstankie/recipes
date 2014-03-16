class CreateUsedins < ActiveRecord::Migration
  def change
    create_table :usedins do |t|
    	t.belongs_to :recipe
      	t.belongs_to :ingredient
      	t.timestamps
    end
  end
end
