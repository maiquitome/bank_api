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
