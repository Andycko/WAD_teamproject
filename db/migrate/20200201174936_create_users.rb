class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
        t.string :username
        t.string :password
        t.boolean :edit
        t.timestamps null: false
    end
    User.create(username: "Admin", password: "admin", edit: true)
  end
end