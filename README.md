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
## Creating the first route (video 1)
* in the __lib/bank_api_web/router.ex__
  - add the post
    ```elixir
    scope "/api", BankApiWeb do
      pipe_through :api

      post "/auth/signup", UserController, :signup
    end
    ```
* create __lib/bank_api_web/controllers/user_controller.ex__
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
* create __lib/bank_api_web/views/user_view.ex__
  - add the code
    ```elixir
    defmodule BankApiWeb.UserView do
      use BankApiWeb, :view

      def render("user.json", %{user: user}) do
        user
      end
    end
    ```
## Creating our migration and schema (video 2)
* in the __mix.exs__
  - add the dependencies
    ```elixir
    {:comeonin, "~> 4.1"},
    {:argon2_elixir, "~> 1.3"},
    {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ```
* create __.credo.exs__ file
  - https://raw.githubusercontent.com/rrrene/credo/master/.credo.exs
  - command to run the credo
    ```bash
    $ mix credo
    ```
* migration
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
* create __lib/bank_api/accounts/user.ex__
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
* add in the database
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
