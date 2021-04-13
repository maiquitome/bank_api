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
### Creating the first route (video 1)
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
