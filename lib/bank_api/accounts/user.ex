defmodule BankApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key - configures the schema primary key.
  # It expects a tuple {field_name, type, options} with the primary key field name,
  # type (typically :id or :binary_id, but can be any type) and options.
  # It also accepts false to disable the generation of a primary key field.
  # Defaults to {:id, :id, autogenerate: true}.
  @primary_key {:id, :binary_id, autogenerate: true}

  # Phoenix.Param - A protocol that converts data structures into URL parameters.
  # This protocol is used by URL helpers and other parts of the Phoenix stack.
  # https://elixircasts.io/uuid-primary-key-with-ecto
  @derive {Phoenix.Param, key: :id}

  schema "users" do
    field :email,                 :string
    field :first_name,            :string
    field :last_name,             :string
    field :password,              :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash,         :string
    field :role,                  :string, default: "user"

    timestamps()
  end

  @allowed_for_changes [
    :email,
    :first_name,
    :last_name,
    :password,
    :password_confirmation,
    :password_hash,
    :role,
  ]
  @required_keys [
    :email,
    :first_name,
    :last_name,
    :password,
    :password_confirmation,
    :role,
  ]
  def changeset(map_with_changes) do
    %__MODULE__{} # => first cast parameter is an empty struct
    |> cast(map_with_changes, @allowed_for_changes)
    |> validate_required(@required_keys)
    |> validate_format(:email, ~r/@/, message: "formato inválido para email!")
    |> update_change(:email, &String.downcase(&1))
    |> validate_length(:password, min: 6, max: 100, message: "password deve ter entre 6 a 100 caracteres!")
    |> validate_confirmation(:password, message: "password não é igual!")
    |> unique_constraint(:email, message: "já existe usuário com este email")
    |> put_pass_hash()
  end

  defp put_pass_hash(
    %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset)
  do
    change(changeset, Comeonin.Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
