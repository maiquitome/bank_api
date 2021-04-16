<div align="center">
  <h1> BankApi </h1>
  <a href="https://www.youtube.com/watch?v=ZVRuWxVJErU&list=PLEs0qgZpGeOXmhOzmTIl89xSvpvEpuofT&index=4">
    This project is a tutorial from the youtube channel ELX PRO BR
  </a>
</div>

### To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

<div align="center">
  <h1> Creating the project from scratch </h1>
</div>

### Generating the project
```bash
  $ mix phx.new bank_api --no-webpack --no-html
```
### Generating the database
```bash
  $ mix ecto.create
```
## Video 1 - Creating the first route
### in the __lib/bank_api_web/router.ex__
- add the post
  ```elixir
  scope "/api", BankApiWeb do
    pipe_through :api

    post "/auth/signup", UserController, :signup
  end
  ```
### create __lib/bank_api_web/controllers/user_controller.ex__
- add
  ```elixir
  defmodule BankApiWeb.UserController do
    use BankApiWeb, :controller

    # An action is a regular function that receives
    # the connection and the request parameters as arguments.
    # The connection is a Plug.Conn struct, as specified by the Plug library.

    # IO.inspect request_params
    # %{
    #   "user" => %{
    #     "email" => "maiquitome@gmail.com",
    #     "first_name" => "Maiqui",
    #     "last_name" => "Tomé",
    #     "password" => "123456",
    #     "password_confirmation" => "123456"
    #   }
    # }
    def signup(conn, %{"user" => user}) do
      # render(conn, "user.json", %{user: user})
      conn
      |> put_status(:created)
      |> render("user.json", %{user: user})

      # IO.inspect conn
      # IO.puts "+++++++++"
      # IO.inspect user
    end
  end
  ```
### create __lib/bank_api_web/views/user_view.ex__
- add the code
  ```elixir
  defmodule BankApiWeb.UserView do
    use BankApiWeb, :view

    def render("user.json", %{user: user}) do
      user
    end
  end
  ```
## Video 2 - create_user
### in the __mix.exs__
- add the dependencies
  ```elixir
  {:comeonin, "~> 4.1"},
  {:argon2_elixir, "~> 1.3"},
  {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
  ```
### create __.credo.exs__ file
- https://raw.githubusercontent.com/rrrene/credo/master/.credo.exs
- command to run the credo
  ```bash
  $ mix credo
  ```
### create_user migration
- run this command to create our migration
  ```bash
  $ mix ecto.gen.migration create_user
  Compiling 14 files (.ex)
  Generated bank_api app
  * creating priv/repo/migrations/20210413102117_create_user.exs
  ```
- in the __priv/repo/migrations/20210413102117_create_user.exs__
  - add this code
    ```elixir
    defmodule BankApi.Repo.Migrations.CreateUser do
      use Ecto.Migration

      def change do
        create table(:users, primary_key: false) do
          add :id,            :uuid,  primary_key: true
          add :email,         :string
          add :first_name,    :string
          add :last_name,     :string
          add :password_hash  :string
          add :role,          :string
          timestamps()
        end

        create( unique_index(:users, [:email]) )
      end
    end
    ```
- run this command to create our table in the database
  ```bash
  $ mix ecto.migrate
  ```
### create __lib/bank_api/accounts/user.ex__
- add the code
  ```elixir
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
  ```
- testing the validations
  ```bash
  iex> BankApi.Accounts.User.changeset %{email: "MAIQUITOME@GMAIL.COM"}
  #Ecto.Changeset<
    action: nil,
    changes: %{email: "maiquitome@gmail.com"},
    errors: [
      first_name: {"can't be blank", [validation: :required]},
      last_name: {"can't be blank", [validation: :required]},
      password: {"can't be blank", [validation: :required]},
      password_confirmation: {"can't be blank", [validation: :required]}
    ],
    data: #BankApi.Accounts.User<>,
    valid?: false
  >
  ```
### add in the database
- storing the changes in the _user_ variable
  ```bash
    iex> user = BankApi.Accounts.User.changeset %{email: "MAIQUITOME@GMAIL.COM", first_name: "Maiqui", last_name: "Tomé", password: "123456", password_confirmation: "123456"}
    #Ecto.Changeset<
      action: nil,
      changes: %{
        email: "maiquitome@gmail.com",
        first_name: "Maiqui",
        last_name: "Tomé",
        password_confirmation: "123456",
        password_hash: "$argon2i$v=19$m=65536,t=6,p=1$IarUYlHZh3Y/sUfBk8LSzg$GC2qz6YucE2dAbQtzPDfmJqW0sxC3iB4dQLF1MMeNVs"
      },
      errors: [],
      data: #BankApi.Accounts.User<>,
      valid?: true
    >
  ```
- insert command
  - insert(struct_or_changeset, opts)
    - Inserts a struct defined via Ecto.Schema or a changeset.

  - insert!(struct_or_changeset, opts)
    - __Same as insert/2__ but returns the struct or raises if the changeset is invalid.

  - using now _insert!_
    ```bash
    iex> BankApi.Repo.insert! user
    [debug] QUERY OK db=7.9ms decode=4.3ms queue=1.4ms idle=1139.4ms
    INSERT INTO "users" ("email","first_name","last_name","password_hash","role","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8) ["maiquitome@gmail.com", "Maiqui", "Tomé", "$argon2i$v=19$m=65536,t=6,p=1$IarUYlHZh3Y/sUfBk8LSzg$GC2qz6YucE2dAbQtzPDfmJqW0sxC3iB4dQLF1MMeNVs", "user", ~N[2021-04-13 19:12:18], ~N[2021-04-13 19:12:18], <<108, 163, 44, 230, 185, 216, 77, 80, 131, 248, 202, 56, 124, 174, 49, 10>>]
    %BankApi.Accounts.User{
      __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
      email: "maiquitome@gmail.com",
      first_name: "Maiqui",
      id: "6ca32ce6-b9d8-4d50-83f8-ca387cae310a",
      inserted_at: ~N[2021-04-13 19:12:18],
      last_name: "Tomé",
      password: nil,
      password_confirmation: "123456",
      password_hash: "$argon2i$v=19$m=65536,t=6,p=1$IarUYlHZh3Y/sUfBk8LSzg$GC2qz6YucE2dAbQtzPDfmJqW0sxC3iB4dQLF1MMeNVs",
      role: "user",
      updated_at: ~N[2021-04-13 19:12:18]
    }
    ```
  - fetching in the database (User => Module Name)
    ```bash
    iex> BankApi.Repo.all User
    [debug] QUERY OK source="users" db=5.5ms queue=0.9ms idle=1730.3ms
    SELECT u0."id", u0."email", u0."first_name", u0."last_name", u0."password_hash", u0."role", u0."inserted_at", u0."updated_at" FROM "users" AS u0 []
    [
      %BankApi.Accounts.User{
        __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
        email: "maiquitome@gmail.com",
        first_name: "Maiqui",
        id: "6ca32ce6-b9d8-4d50-83f8-ca387cae310a",
        inserted_at: ~N[2021-04-13 19:12:18],
        last_name: "Tomé",
        password: nil,
        password_confirmation: nil,
        password_hash: "$argon2i$v=19$m=65536,t=6,p=1$IarUYlHZh3Y/sUfBk8LSzg$GC2qz6YucE2dAbQtzPDfmJqW0sxC3iB4dQLF1MMeNVs",
        role: "user",
        updated_at: ~N[2021-04-13 19:12:18]
      }
    ]
    ```
### in the __priv/repo/seeds.exs__
```elixir
BankApi.Repo.insert! BankApi.Accounts.User.changeset %{email: "MAIQUITOME@GMAIL.COM", first_name: "Maiqui", last_name: "Tomé", password: "123456", password_confirmation: "123456"}
```

## Video 3 - create_account_user
### create_account_user migration
- generate
  ```bash
  ❯ mix ecto.gen.migration create_account_user
  * creating priv/repo/migrations/20210415143435_create_account_user.exs
  ```
- in the file __priv/repo/migrations/20210415143435_create_account_user.exs__
  ```elixir
  defmodule BankApi.Repo.Migrations.CreateAccountUser do
    use Ecto.Migration

    def change do
      create table(:accounts, primary_key: false) do
        add :id,      :uuid,    primary_key: true
        add :balance, :decimal, precision: 10, scale: 2
        add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
        timestamps()
      end
    end
  end
  ```
- run __mix ecto.migrate__
  ```bash
  $ mix ecto.migrate

  12:04:05.926 [info]  == Running 20210415143435 BankApi.Repo.Migrations.CreateAccountUser.change/0 forward

  12:04:05.930 [info]  create table accounts

  12:04:05.944 [info]  == Migrated 20210415143435 in 0.0s
  ```
### account schema...
- create __lib/bank_api/accounts/account.ex__
  ```elixir
  defmodule BankApi.Accounts.Account do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :binary_id, autogenerate: true}
    @derive {Phoenix.Param, key: :id}
    @foreign_key_type Ecto.UUID
    schema "accounts" do
      field :balance, :decimal, precision: 10, scale: 2, default: 1000
      belongs_to :user, BankApi.Accounts.User
      timestamps()
    end

    @doc false
    def changeset(account, attrs \\ %{}) do
      account
      |> cast(attrs, [:balance])
      |> validate_required([:balance])
    end
  end
  ```
- testing in iex
  ```bash
  iex> %BankApi.Accounts.Account{} |> BankApi.Accounts.Account.changeset()
  #Ecto.Changeset<action: nil, changes: %{}, errors: [],
  data: #BankApi.Accounts.Account<>, valid?: true>
  ```
- in the __lib/bank_api/accounts/user.ex__
  - add in schema
    ```elixir
      has_one :accounts, BankApi.Accounts.Account # add on top of timestamps()
    ```
- searching for _users_ in the _database_ and adding them to a _list_
  ```bash
  iex> [user] = BankApi.Repo.all BankApi.Accounts.User
  [debug] QUERY OK source="users" db=2.2ms queue=0.1ms idle=1284.9ms
  SELECT u0."id", u0."email", u0."first_name", u0."last_name", u0."password_hash", u0."role", u0."inserted_at", u0."updated_at" FROM "users" AS u0 []
  [
    %BankApi.Accounts.User{
      __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
      accounts: #Ecto.Association.NotLoaded<association :accounts is not loaded>,
      email: "maiquitome@gmail.com",
      first_name: "Maiqui",
      id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b",
      inserted_at: ~N[2021-04-15 14:12:09],
      last_name: "Tomé",
      password: nil,
      password_confirmation: nil,
      password_hash: "$argon2i$v=19$m=65536,t=6,p=1$ba43Web9Wgq3CMSALRilcg$CAATitl7uoO7v4wca3O4LYOOP7AnI2Iw5ZelwAYoHGE",
      role: "user",
      updated_at: ~N[2021-04-15 14:12:09]
    }
  ]
  ```
  ```bash
  iex> user
  %BankApi.Accounts.User{
    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
    accounts: #Ecto.Association.NotLoaded<association :accounts is not loaded>,
    email: "maiquitome@gmail.com",
    first_name: "Maiqui",
    id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b",
    inserted_at: ~N[2021-04-15 14:12:09],
    last_name: "Tomé",
    password: nil,
    password_confirmation: nil,
    password_hash: "$argon2i$v=19$m=65536,t=6,p=1$ba43Web9Wgq3CMSALRilcg$CAATitl7uoO7v4wca3O4LYOOP7AnI2Iw5ZelwAYoHGE",
    role: "user",
    updated_at: ~N[2021-04-15 14:12:09]
  }
  ```
- making the association
  ```elixir
  iex> Ecto.build_assoc(user, :accounts)
  %BankApi.Accounts.Account{
    __meta__: #Ecto.Schema.Metadata<:built, "accounts">,
    balance: 1000,
    id: nil,
    inserted_at: nil,
    updated_at: nil,
    user: #Ecto.Association.NotLoaded<association :user is not loaded>,
    user_id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b"
  }
  ```
  ```elixir
  iex> account = user |> Ecto.build_assoc(:accounts)
  %BankApi.Accounts.Account{
    __meta__: #Ecto.Schema.Metadata<:built, "accounts">,
    balance: 1000,
    id: nil,
    inserted_at: nil,
    updated_at: nil,
    user: #Ecto.Association.NotLoaded<association :user is not loaded>,
    user_id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b"
  }
  ```
  ```bash
  iex> account |> BankApi.Accounts.Account.changeset()
  #Ecto.Changeset<action: nil, changes: %{}, errors: [],
  data: #BankApi.Accounts.Account<>, valid?: true>
  ```
  ```bash
  iex> account = account |> BankApi.Accounts.Account.changeset()
  #Ecto.Changeset<action: nil, changes: %{}, errors: [],
  data: #BankApi.Accounts.Account<>, valid?: true>
  ```
  - inserting into the database
    ```bash
    iex> BankApi.Repo.insert! account
    [debug] QUERY OK db=10.8ms queue=2.7ms idle=677.8ms
    INSERT INTO "accounts" ("balance","user_id","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5) [#Decimal<1000>, <<251, 64, 6, 105, 203, 208, 78, 10, 155, 159, 141, 38, 124, 9, 100, 155>>, ~N[2021-04-15 17:49:51], ~N[2021-04-15 17:49:51], <<255, 250, 83, 48, 207, 40, 64, 71, 132, 122, 229, 83, 40, 64, 151, 25>>]
    %BankApi.Accounts.Account{
      __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
      balance: 1000,
      id: "fffa5330-cf28-4047-847a-e55328409719",
      inserted_at: ~N[2021-04-15 17:49:51],
      updated_at: ~N[2021-04-15 17:49:51],
      user: #Ecto.Association.NotLoaded<association :user is not loaded>,
      user_id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b"
    }
    ```
  - inserting again
    ```bash
    iex> {:ok, account} = BankApi.Repo.insert account
    [debug] QUERY OK db=4.7ms queue=2.6ms idle=1266.2ms
    INSERT INTO "accounts" ("balance","user_id","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5) [#Decimal<1000>, <<251, 64, 6, 105, 203, 208, 78, 10, 155, 159, 141, 38, 124, 9, 100, 155>>, ~N[2021-04-15 18:13:19], ~N[2021-04-15 18:13:19], <<209, 242, 65, 70, 10, 155, 77, 226, 138, 152, 223, 157, 207, 125, 37, 65>>]
    {:ok,
    %BankApi.Accounts.Account{
      __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
      balance: 1000,
      id: "d1f24146-0a9b-4de2-8a98-df9dcf7d2541",
      inserted_at: ~N[2021-04-15 18:13:19],
      updated_at: ~N[2021-04-15 18:13:19],
      user: #Ecto.Association.NotLoaded<association :user is not loaded>,
      user_id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b"
    }}
    ```
  - searching the database for the account and his user
    ```bash
    iex> BankApi.Repo.preload(account, :user)
    [debug] QUERY OK source="users" db=4.5ms queue=2.1ms idle=1151.2ms
    SELECT u0."id", u0."email", u0."first_name", u0."last_name", u0."password_hash", u0."role", u0."inserted_at", u0."updated_at", u0."id" FROM "users" AS u0 WHERE (u0."id" = $1) [<<251, 64, 6, 105, 203, 208, 78, 10, 155, 159, 141, 38, 124, 9, 100, 155>>]
    %BankApi.Accounts.Account{
      __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
      balance: 1000,
      id: "d1f24146-0a9b-4de2-8a98-df9dcf7d2541",
      inserted_at: ~N[2021-04-15 18:13:19],
      updated_at: ~N[2021-04-15 18:13:19],
      user: %BankApi.Accounts.User{
        __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
        accounts: #Ecto.Association.NotLoaded<association :accounts is not loaded>,
        email: "maiquitome@gmail.com",
        first_name: "Maiqui",
        id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b",
        inserted_at: ~N[2021-04-15 14:12:09],
        last_name: "Tomé",
        password: nil,
        password_confirmation: nil,
        password_hash: "$argon2i$v=19$m=65536,t=6,p=1$ba43Web9Wgq3CMSALRilcg$CAATitl7uoO7v4wca3O4LYOOP7AnI2Iw5ZelwAYoHGE",
        role: "user",
        updated_at: ~N[2021-04-15 14:12:09]
      },
      user_id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b"
    }
    ```
  - searching the database for the user and his account
    ```bash
    iex> BankApi.Repo.preload(user, :accounts)
    [debug] QUERY OK source="accounts" db=2.2ms queue=2.3ms idle=1714.7ms
    SELECT a0."id", a0."balance", a0."user_id", a0."inserted_at", a0."updated_at", a0."user_id" FROM "accounts" AS a0 WHERE (a0."user_id" = $1) [<<251, 64, 6, 105, 203, 208, 78, 10, 155, 159, 141, 38, 124, 9, 100, 155>>]
    %BankApi.Accounts.User{
      __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
      accounts: %BankApi.Accounts.Account{
        __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
        balance: #Decimal<1000.00>,
        id: "fffa5330-cf28-4047-847a-e55328409719",
        inserted_at: ~N[2021-04-15 17:49:51],
        updated_at: ~N[2021-04-15 17:49:51],
        user: #Ecto.Association.NotLoaded<association :user is not loaded>,
        user_id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b"
      },
      email: "maiquitome@gmail.com",
      first_name: "Maiqui",
      id: "fb400669-cbd0-4e0a-9b9f-8d267c09649b",
      inserted_at: ~N[2021-04-15 14:12:09],
      last_name: "Tomé",
      password: nil,
      password_confirmation: nil,
      password_hash: "$argon2i$v=19$m=65536,t=6,p=1$ba43Web9Wgq3CMSALRilcg$CAATitl7uoO7v4wca3O4LYOOP7AnI2Iw5ZelwAYoHGE",
      role: "user",
      updated_at: ~N[2021-04-15 14:12:09]
    }
    ```
### create __lib/bank_api/accounts.ex__
* add the code
  ```elixir
  defmodule BankApi.Accounts do
    alias BankApi.Repo
    alias BankApi.Accounts.{User, Account}

    def create_user(map_with_changes \\ %{}) do
      case insert_user(map_with_changes) do
        {:ok, user} ->
          {:ok, account} = user
          |> Ecto.build_assoc(:accounts)
          |> Account.changeset()
          |> Repo.insert()
          {:ok, account |> Repo.preload(:user)}
          {:error, changeset} -> {:error, changeset}
      end
    end

    defp insert_user(map_with_changes) do
      User.changeset(map_with_changes)
      |> Repo.insert()
    end
  end
  ```
* inserting into the database
  ```bash
  iex> BankApi.Accounts.create_user %{email: "MAIQUITOME@GMAIL.COM", first_name: "Maiqui", last_name: "Tomé", password: "123456", password_confirmation: "123456"}
  [debug] QUERY OK db=7.1ms decode=1.9ms queue=2.2ms idle=1959.0ms
  INSERT INTO "users" ("email","first_name","last_name","password_hash","role","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8) ["maiquitome@gmail.com", "Maiqui", "Tomé", "$argon2i$v=19$m=65536,t=6,p=1$4gx+RjL79erkkEUQwrq3Pw$IAxSkIls4jCzswYW7iFqlr9VbPfdbdJpY83FDU93q2g", "user", ~N[2021-04-15 21:33:21], ~N[2021-04-15 21:33:21], <<103, 222, 145, 236, 211, 125, 72, 13, 163, 52, 184, 250, 92, 182, 206, 97>>]
  [debug] QUERY OK db=5.9ms queue=1.8ms idle=36.7ms
  INSERT INTO "accounts" ("balance","user_id","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5) [#Decimal<1000>, <<103, 222, 145, 236, 211, 125, 72, 13, 163, 52, 184, 250, 92, 182, 206, 97>>, ~N[2021-04-15 21:33:21], ~N[2021-04-15 21:33:21], <<76, 18, 164, 145, 119, 20, 79, 98, 138, 255, 43, 102, 164, 106, 64, 23>>]
  {:ok,
  %BankApi.Accounts.Account{
    __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
    balance: 1000,
    id: "4c12a491-7714-4f62-8aff-2b66a46a4017",
    inserted_at: ~N[2021-04-15 21:33:21],
    updated_at: ~N[2021-04-15 21:33:21],
    user: #Ecto.Association.NotLoaded<association :user is not loaded>,
    user_id: "67de91ec-d37d-480d-a334-b8fa5cb6ce61"
  }}
  ```

### in the lib/bank_api_web/controllers/user_controller.ex
* add alias
  ```elixir
  alias BankApi.Accounts
  ```
* in the __def signup__
  ```elixir
  {:ok, account} = Accounts.create_user(user)
  conn
  |> put_status(:created)
  |> render("account.json", %{account: account})
  ```

### in the lib/bank_api_web/views/user_view.ex
* add
  ```elixir
  def render("account.json", %{account: account}) do
    %{balance: account.balance}
  end
  ```
