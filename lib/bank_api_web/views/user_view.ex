defmodule BankApiWeb.UserView do
  use BankApiWeb, :view

  # Phoenix.View.render(YourApp.UserView, "index.html", name: "John<br/>Doe")
  def render("user.json", %{user: user}) do
    user
  end
end
