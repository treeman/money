defmodule Money.BudgetControllerTest do
  use Money.ConnCase
  import Money.HtmlParsers
  alias Ecto.DateTime

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

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
  test "index redirects to current month", %{conn: conn, user: _user} do
    {{year, month, _}, _} = :calendar.local_time()

    conn = get conn, budget_path(conn, :index)
    assert redirected_to(conn) == budget_path(conn, :show, year, month)
  end

  @tag login_as: "max"
  test "show renders ok", %{conn: conn, user: _user} do
    conn = get conn, budget_path(conn, :show, 2016, 7)
    assert html_response(conn, 200)
  end

  @tag login_as: "max"
  test "test budget calculations", %{conn: conn, user: user} do
    account = insert_account(user)

    essentials = insert_category_group(name: "Essentials")
    rent = insert_category(essentials, name: "Rent")
    food = insert_category(essentials, name: "Food")

    fun = insert_category_group(name: "Fun")
    clothes = insert_category(fun, name: "Clothes")
    games = insert_category(fun, name: "Games")

    insert_budgeted_category(rent, year: 2016, month: 6, amount: 5201)
    insert_budgeted_category(food, year: 2016, month: 6, amount: 317)
    insert_budgeted_category(clothes, year: 2016, month: 6, amount: 999999)
    insert_budgeted_category(games, year: 2016, month: 6, amount: 1)

    insert_budgeted_category(rent, year: 2016, month: 7, amount: 5202)
    insert_budgeted_category(food, year: 2016, month: 7, amount: 99)
    insert_budgeted_category(clothes, year: 2016, month: 7, amount: 43)
    insert_budgeted_category(games, year: 2016, month: 7, amount: 17)

    insert_budgeted_category(rent, year: 2016, month: 8, amount: 5203)
    insert_budgeted_category(food, year: 2016, month: 8, amount: 1)
    insert_budgeted_category(clothes, year: 2016, month: 8, amount: 999999)
    insert_budgeted_category(games, year: 2016, month: 8, amount: 5)

    {:ok, dt} = DateTime.cast("2016-06-30 00:01:00")
    insert_transaction(account, category: rent, amount: 3570, payee: "Mr.T", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-31 00:01:00")
    insert_transaction(account, category: rent, amount: 3573, payee: "Mr.T", when: dt)
    {:ok, dt} = DateTime.cast("2016-08-31 00:01:00")
    insert_transaction(account, category: rent, amount: 3579, payee: "Mr.T", when: dt)

    {:ok, dt} = DateTime.cast("2016-06-01 12:00:00")
    insert_transaction(account, category: food, amount: 10, payee: "Sushi", when: dt)
    insert_transaction(account, category: food, amount: 10, payee: "Sushi", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-01 10:00:00")
    insert_transaction(account, category: food, amount: 3, payee: "f1", when: dt)
    insert_transaction(account, category: food, amount: 19, payee: "f2", when: dt)
    insert_transaction(account, category: food, amount: 100, payee: "f3", when: dt)
    {:ok, dt} = DateTime.cast("2016-08-01 00:00:00")
    insert_transaction(account, category: food, amount: 999, payee: "9", when: dt)

    {:ok, dt} = DateTime.cast("2016-07-03 00:00:01")
    insert_transaction(account, category: games, amount: 1, payee: "Casino Royale 1", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-03 00:00:02")
    insert_transaction(account, category: games, amount: 1, payee: "Casino Royale 2", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-03 00:00:03")
    insert_transaction(account, category: games, amount: 1, payee: "Casino Royale 3", when: dt)

    # TODO use https://github.com/philss/floki to parse category/budgeted/activity
    # FIXME shows nothing in rent
    # FIXME shows nothing budgeted for clothes
    # FIXME +- calculation is off
    conn = get conn, budget_path(conn, :show, 2016, 7)
    html = html_response(conn, 200)

    table = parse_table(html, ".table")

    essentials_budget = find_category(table, "Essentials")
    assert essentials_budget["Activity"] == 3692
    assert essentials_budget["Budgeted"] == 5301
    assert essentials_budget["Balance"] == 169

    rent_budget = find_category(table, "Rent")
    assert rent_budget["Activity"] == 3570
    assert rent_budget["Budgeted"] == 5202
    assert rent_budget["Balance"] == 1632

    food_budget = find_category(table, "Food")
    assert food_budget["Activity"] == 122
    assert food_budget["Budgeted"] == 99
    assert food_budget["Balance"] == -23


    fun_budget = find_category(table, "Fun")
    assert fun_budget["Activity"] == 3
    assert fun_budget["Budgeted"] == 60
    assert fun_budget["Balance"] == 57

    clothes_budget = find_category(table, "Clothes")
    assert clothes_budget["Activity"] == 0
    assert clothes_budget["Budgeted"] == 43
    assert clothes_budget["Balance"] == 43

    games_budget = find_category(table, "Games")
    assert games_budget["Activity"] == 3
    assert games_budget["Budgeted"] == 17
    assert games_budget["Balance"] == 14
  end

  defp find_category(table, category) do
    Enum.find(table, fn %{"Category" => c} -> c == category end)
  end
end

