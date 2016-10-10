class Payments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :user, index: true, null: false
      t.string :session_id, unique: true, index: true
      t.integer :amount, null: false
      t.string :currency
      t.string :country
      t.text :description
      t.integer :status
      t.string :token
      t.integer :order_id
      t.integer :payment_method
      t.string :payment_statement

      t.timestamps
    end
  end
end
