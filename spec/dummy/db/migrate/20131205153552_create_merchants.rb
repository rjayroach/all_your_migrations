class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      # Legacy
      t.references :legacy, index: true, unique: true
      # End Legacy

      t.string :name, null: false
      t.string :slug
      t.integer :state, limit: 1, null: false, default: 1
      t.string :logo
      t.string :stamp
      t.string :background_image
      t.string :background_image_small
      t.string :short_name
      t.boolean :uses_amex, default: false
      t.string :amex_issuer_code
      t.references :primary_resource_tag
      t.references :primary_contact

      t.timestamps
    end
  end
end
