defmodule Multimedia.UserSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_sessions" do
    field :browser, :string
    belongs_to :user, Multimedia.User

    timestamps()
  end

  @type t :: %__MODULE__{
          id: integer,
          browser: String.t()
        }

  def changeset(%__MODULE__{} = session, params) do
    session
    |> cast(params, [:user_id, :browser])
    |> validate_required([:user_id, :browser])
    |> foreign_key_constraint(:user_id)
  end
end
