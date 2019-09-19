defmodule Multimedia.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      timestamps()
    end

    create unique_index(:users, :email)

    create table(:user_sessions) do
      add :user_id, references(:users), null: false
      add :browser, :string, null: false
      timestamps()
    end
  end
end
