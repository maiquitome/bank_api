defmodule BankApiWeb.UserController do
  use BankApiWeb, :controller
  alias BankApi.Accounts

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

    {:ok, account} = Accounts.create_user(user)
    conn
    |> put_status(:created)
    |> render("account.json", %{account: account})

    # IO.inspect conn
    # IO.puts "+++++++++"
    # IO.inspect user
  end
end
