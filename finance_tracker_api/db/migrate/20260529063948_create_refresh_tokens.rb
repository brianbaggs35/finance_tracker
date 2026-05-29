class CreateRefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest
      t.datetime :expires_at
      t.datetime :revoked_at
      t.string :device_info

      t.timestamps
    end
  end
end
