defmodule Multimedia.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @type t :: %__MODULE__{
          id: integer,
          password: String.t(),
          password_hash: String.t()
        }

  defp put_password_hash(changeset) do
    if changeset.valid? do
      password = get_change(changeset, :password)
      change(changeset, Bcrypt.add_hash(password))
    else
      changeset
    end
  end

  def changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 4)
    |> put_password_hash()
    |> unique_constraint(:email)
  end

  @spec login_changeset(any) :: Ecto.Changeset.t()
  def login_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 4)
  end

  def register_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_length(:password, min: 4)
    |> validate_confirmation(:password)
  end
end
