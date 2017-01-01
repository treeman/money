defmodule Money.UserHelpersTest do
  use ExUnit.Case, async: true
  use Money.ConnCase
  import Money.UserHelpers

  setup config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      {:ok, user: user}
    else
      :ok
    end
  end

  @tag login_as: "max"
  test "user accounts", %{user: user} do
    insert_account(user)
    insert_account(user)

    other_user = insert_user(username: "alice")
    insert_account(other_user)

    assert Kernel.length(Repo.all(user_accounts(user))) == 2
  end

  @tag login_as: "max"
  test "user transactions", %{user: user} do
    a1 = insert_account(user)
    insert_transaction(a1)
    insert_transaction(a1)
    a2 = insert_account(user)
    insert_transaction(a2)
    insert_transaction(a2)

    other_user = insert_user(username: "alice")
    other_a1 = insert_account(other_user)
    insert_transaction(other_a1)

    assert Kernel.length(Repo.all(user_transactions(user))) == 4
  end

  @tag login_as: "max"
  test "user categories", %{user: user} do
    g1 = insert_category_group(user, name: "g1")
    insert_category(g1, name: "c1")
    insert_category(g1, name: "c2")
    g2 = insert_category_group(user, name: "g2")
    insert_category(g2, name: "c3")

    other_user = insert_user(username: "alice")
    other_g = insert_category_group(other_user, name: "g1")
    insert_category(other_g)

    assert Kernel.length(Repo.all(user_categories(user))) == 3
  end
end

