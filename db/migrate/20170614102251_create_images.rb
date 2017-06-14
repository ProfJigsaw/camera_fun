class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :filename
      t.string :content_type
      t.binary :content

      t.timestamps
    end
  end
end
