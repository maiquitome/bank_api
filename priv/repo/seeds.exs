# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BankApi.Repo.insert!(%BankApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
BankApi.Accounts.create_user %{email: "MAIQUITOME@GMAIL.COM", first_name: "Maiqui", last_name: "Tomé", password: "123456", password_confirmation: "123456"}
