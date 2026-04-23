class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :plan, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :billing_cycle, null: false, default: 0
      t.integer :amount_cents, null: false, default: 0
      t.datetime :trial_ends_at
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.string :stripe_subscription_id
      t.datetime :cancelled_at
      t.timestamps
    end

    add_index :subscriptions, :stripe_subscription_id, unique: true,
              where: "stripe_subscription_id IS NOT NULL"
    add_index :subscriptions, :status
    add_index :subscriptions, :trial_ends_at
  end
end
