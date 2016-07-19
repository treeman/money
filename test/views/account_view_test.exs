defmodule Money.AccountViewTest do
  use Money.ConnCase, async: true
  import Phoenix.View

  test "renders index.html", %{conn: conn} do
    accounts = [%Money.Account{id: "1", title: "Bank"},
                %Money.Account{id: "2", title: "Madrass"}]
    content = render_to_string(Money.AccountView, "index.html", conn: conn, accounts: accounts)

    assert String.contains?(content, "Listing accounts")
    for account <- accounts do
      assert String.contains?(content, account.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Money.Account.changeset(%Money.Account{})
    content = render_to_string(Money.AccountView, "new.html", conn: conn, changeset: changeset)

    assert String.contains?(content, "New account")
  end
end

