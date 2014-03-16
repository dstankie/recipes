class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
		t.belongs_to :recipe
		t.string :name
      	t.timestamps
    end
  end
end
