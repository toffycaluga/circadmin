class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.references :circus,                    null: false, foreign_key: true
      t.string     :stripe_payment_method_id,  null: false
      t.string     :card_brand,                null: false
      t.string     :last4,                     null: false
      t.integer    :exp_month,                 null: false
      t.integer    :exp_year,                  null: false
      t.boolean    :default,     default: false
      t.timestamps
    end
  end
end
