defmodule Money.UserHelpersTest do
  use ExUnit.Case, async: true
  use Money.ConnCase
  import Money.UserHelpers
  import Money.Factory

  @tag login_as: "max"
  test "user accounts", %{user: user} do
    insert(:account, user: user)
    insert(:account, user: user)

    other_user = insert(:user, username: "alice")
    insert(:account, user: other_user)

    assert Kernel.length(Repo.all(user_accounts(user))) == 2
  end

  @tag login_as: "max"
  test "user transactions", %{user: user} do
    a1 = insert(:account, user: user)
    insert(:transaction, account: a1)
    insert(:transaction, account: a1)
    a2 = insert(:account, user: user)
    insert(:transaction, account: a2)
    insert(:transaction, account: a2)

    other_user = insert(:user, username: "alice")
    other_a1 = insert(:account, user: other_user)
    insert(:transaction, account: other_a1)

    assert Kernel.length(Repo.all(user_transactions(user))) == 4
  end

  @tag login_as: "max"
  test "user categories", %{user: user} do
    g1 = insert(:category_group, user: user, name: "g1")
    insert(:category, category_group: g1, name: "c1")
    insert(:category, category_group: g1, name: "c2")
    g2 = insert(:category_group, user: user, name: "g2")
    insert(:category, category_group: g2, name: "c3")

    other_user = insert(:user, username: "alice")
    other_g = insert(:category_group, user: other_user, name: "g1")
    insert(:category, category_group: other_g)

    assert Kernel.length(Repo.all(user_categories(user))) == 3
  end

  @tag login_as: "max"
  test "user budgeted categories", %{user: user} do
    g1 = insert(:category_group, user: user, name: "g1")
    c1 = insert(:category, category_group: g1, name: "c1")
    insert(:budgeted_category, category: c1)

    other_user = insert(:user, username: "alice")
    other_g = insert(:category_group, user: other_user, name: "g1")
    other_c = insert(:category, category_group: other_g, name: "c1")
    insert(:budgeted_category, category: other_c)

    assert Kernel.length(Repo.all(user_budgeted_categories(user))) == 1
  end
end

