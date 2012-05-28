class CreateSms < ActiveRecord::Migration
  def change
    create_table :sms do |t|
      t.string :phone
      t.string :subject
      t.text :content
      t.boolean :isflash, :default => false
      t.boolean :pl, :default => true
      t.integer :globalid
      t.integer :localid
      t.integer :status_id
      t.boolean :ok
      t.boolean :sent, :default => false

      t.timestamps
    end
  end
end
