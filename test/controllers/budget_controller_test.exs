defmodule Money.BudgetControllerTest do
  use Money.ConnCase
  import Money.HtmlParsers
  alias Ecto.DateTime

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, account_path(conn, :new)),
      get(conn, account_path(conn, :index)),
      get(conn, account_path(conn, :show, "123")),
      get(conn, account_path(conn, :edit, "123")),
      put(conn, account_path(conn, :update, "123", %{})),
      post(conn, account_path(conn, :create, %{})),
      delete(conn, account_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "index redirects to current month", %{conn: conn} do
    {{year, month, _}, _} = :calendar.local_time()

    conn = get conn, budget_path(conn, :index)
    assert redirected_to(conn) == budget_path(conn, :show, year, month)
  end

  @tag login_as: "max"
  test "show renders ok", %{conn: conn} do
    conn = get conn, budget_path(conn, :show, 2016, 7)
    assert html_response(conn, 200)
  end

  @tag login_as: "max"
  test "test budget calculations", %{conn: conn, user: user} do
    account = insert(:account, user: user)

    essentials = insert(:category_group, user: user, name: "Essentials")
    rent = insert(:category, category_group: essentials, name: "Rent")
    food = insert(:category, category_group: essentials, name: "Food")

    fun = insert(:category_group, user: user, name: "Fun")
    clothes = insert(:category, category_group: fun, name: "Clothes")
    games = insert(:category, category_group: fun, name: "Games")
    vacation = insert(:category, category_group: fun, name: "Vacation")

    insert(:budgeted_category, category: rent, year: 2015, month: 7, budgeted: 9999)

    insert(:budgeted_category, category: rent, year: 2016, month: 6, budgeted: 5201)
    insert(:budgeted_category, category: food, year: 2016, month: 6, budgeted: 317)
    insert(:budgeted_category, category: clothes, year: 2016, month: 6, budgeted: 999999)
    insert(:budgeted_category, category: games, year: 2016, month: 6, budgeted: 1)

    insert(:budgeted_category, category: rent, year: 2016, month: 7, budgeted: 5202)
    insert(:budgeted_category, category: food, year: 2016, month: 7, budgeted: 99)
    insert(:budgeted_category, category: clothes, year: 2016, month: 7, budgeted: 43)
    insert(:budgeted_category, category: games, year: 2016, month: 7, budgeted: 17)

    insert(:budgeted_category, category: rent, year: 2016, month: 8, budgeted: 5203)
    insert(:budgeted_category, category: food, year: 2016, month: 8, budgeted: 1)
    insert(:budgeted_category, category: clothes, year: 2016, month: 8, budgeted: 999999)
    insert(:budgeted_category, category: games, year: 2016, month: 8, budgeted: 5)

    insert(:budgeted_category, category: rent, year: 2015, month: 9, budgeted: 9999)

    {:ok, dt} = DateTime.cast("2016-06-30 00:01:00")
    insert(:transaction, account: account, category: rent, amount: -3570, payee: "Mr.T", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-31 00:01:00")
    insert(:transaction, account: account, category: rent, amount: -3573, payee: "Mr.T", when: dt)
    {:ok, dt} = DateTime.cast("2016-08-31 00:01:00")
    insert(:transaction, account: account, category: rent, amount: -3579, payee: "Mr.T", when: dt)

    {:ok, dt} = DateTime.cast("2016-06-01 12:00:00")
    insert(:transaction, account: account, category: food, amount: -10, payee: "Sushi", when: dt)
    insert(:transaction, account: account, category: food, amount: -10, payee: "Sushi", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-01 10:00:00")
    insert(:transaction, account: account, category: food, amount: -3, payee: "f1", when: dt)
    insert(:transaction, account: account, category: food, amount: -19, payee: "f2", when: dt)
    insert(:transaction, account: account, category: food, amount: -100, payee: "f3", when: dt)
    {:ok, dt} = DateTime.cast("2016-08-01 00:00:00")
    insert(:transaction, account: account, category: food, amount: -999, payee: "9", when: dt)

    {:ok, dt} = DateTime.cast("2016-07-03 00:00:01")
    insert(:transaction, account: account, category: games, amount: -1, payee: "Casino Royale 1", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-03 00:00:02")
    insert(:transaction, account: account, category: games, amount: -1, payee: "Casino Royale 2", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-03 00:00:03")
    insert(:transaction, account: account, category: games, amount: -1, payee: "Casino Royale 3", when: dt)

    {:ok, dt} = DateTime.cast("2016-07-17 12:00:03")
    insert(:transaction, account: account, category: vacation, amount: -10000, payee: "Abisko", when: dt)

    conn = get conn, budget_path(conn, :show, 2016, 7)
    html = html_response(conn, 200)

    table = parse_grid(html, ".grid")

    essentials_budget = find_category(table, "Essentials")
    assert essentials_budget["Activity"] == -3695
    assert essentials_budget["Budgeted"] == 5301
    assert essentials_budget["Balance"] == 1606

    rent_budget = find_category(table, "Rent")
    assert rent_budget["Activity"] == -3573
    assert rent_budget["Budgeted"] == 5202
    assert rent_budget["Balance"] == 1629

    food_budget = find_category(table, "Food")
    assert food_budget["Activity"] == -122
    assert food_budget["Budgeted"] == 99
    assert food_budget["Balance"] == -23

    fun_budget = find_category(table, "Fun")
    assert fun_budget["Activity"] == -10003
    assert fun_budget["Budgeted"] == 60
    assert fun_budget["Balance"] == -9943

    clothes_budget = find_category(table, "Clothes")
    assert clothes_budget["Activity"] == 0
    assert clothes_budget["Budgeted"] == 43
    assert clothes_budget["Balance"] == 43

    games_budget = find_category(table, "Games")
    assert games_budget["Activity"] == -3
    assert games_budget["Budgeted"] == 17
    assert games_budget["Balance"] == 14

    vacation_budget = find_category(table, "Vacation")
    assert vacation_budget["Activity"] == -10000
    assert vacation_budget["Budgeted"] == 0
    assert vacation_budget["Balance"] == -10000
  end

  defp find_category(table, category) do
    Enum.find(table, fn %{"Category" => c} -> c == category end)
  end

  @tag login_as: "max"
  test "filter activity against other users", %{conn: conn, user: owner} do
    account = insert(:account, user: owner)

    essentials = insert(:category_group, user: owner, name: "Essentials")
    rent = insert(:category, category_group: essentials, name: "Rent")
    _food = insert(:category, category_group: essentials, name: "Food")

    insert(:budgeted_category, category: rent, year: 2016, month: 7, budgeted: 9999)

    {:ok, dt} = DateTime.cast("2016-07-02 00:01:00")
    insert(:transaction, account: account, category: rent, amount: -3570, payee: "Mr.T", when: dt)

    # Some random seeding for other user which may interfere
    alice = insert(:user, username: "alice")
    alice_account = insert(:account, user: alice)

    alice_essentials = insert(:category_group, user: alice, name: "Essentials")
    alice_rent = insert(:category, category_group: alice_essentials, name: "Rent")
    alice_food = insert(:category, category_group: alice_essentials, name: "Food")

    insert(:budgeted_category, category: alice_rent, year: 2016, month: 7, budgeted: 1337)

    {:ok, dt} = DateTime.cast("2016-07-01 00:01:00")
    insert(:transaction, account: alice_account, category: alice_rent, amount: -100, payee: "John Doe", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-08 00:01:00")
    insert(:transaction, account: alice_account, category: alice_food, amount: -20000, payee: "John's Pizza", when: dt)


    conn = get conn, budget_path(conn, :show, 2016, 7)
    html = html_response(conn, 200)

    table = parse_grid(html, ".grid")
    assert length(table) == 3

    essentials_budget = find_category(table, "Essentials")
    assert essentials_budget["Activity"] == -3570
    assert essentials_budget["Budgeted"] == 9999
    assert essentials_budget["Balance"] == 6429

    rent_budget = find_category(table, "Rent")
    assert rent_budget["Activity"] == -3570
    assert rent_budget["Budgeted"] == 9999
    assert rent_budget["Balance"] == 6429

    food_budget = find_category(table, "Food")
    assert food_budget["Activity"] == 0
    assert food_budget["Budgeted"] == 0
    assert food_budget["Balance"] == 0
  end
end

