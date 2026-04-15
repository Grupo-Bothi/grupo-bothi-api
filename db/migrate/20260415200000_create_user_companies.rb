class CreateUserCompanies < ActiveRecord::Migration[8.0]
  def up
    create_table :user_companies do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_companies, %i[user_id company_id], unique: true

    # Migrate existing company_id data to the join table
    execute <<-SQL
      INSERT INTO user_companies (user_id, company_id, created_at, updated_at)
      SELECT id, company_id, NOW(), NOW()
      FROM users
      WHERE company_id IS NOT NULL
    SQL

    remove_index  :users, :company_id
    remove_column :users, :company_id, :bigint
  end

  def down
    add_column :users, :company_id, :bigint
    add_index  :users, :company_id

    execute <<-SQL
      UPDATE users
      SET company_id = (
        SELECT company_id
        FROM user_companies
        WHERE user_companies.user_id = users.id
        LIMIT 1
      )
    SQL

    drop_table :user_companies
  end
end
