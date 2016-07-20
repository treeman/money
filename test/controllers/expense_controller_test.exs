defmodule Money.ExpenseControllerTest do
  use Money.ConnCase

  alias Money.Expense
  @valid_attrs %{amount: 42,
                 category: "some category",
                 description: "some description",
                 when: Ecto.DateTime.utc,
                 where: "somewhere"}
  @invalid_attrs %{amount: nil}

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
  test "renders form for new resources", %{conn: conn, user: _user} do
    conn = get conn, expense_path(conn, :new, %{"account_id" => 3})
    assert html_response(conn, 200) =~ "New expense"
  end

  @tag login_as: "max"
  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    account = insert_account(user)
    attrs = Dict.merge(%{ account_id: account.id}, @valid_attrs)

    conn = post conn, expense_path(conn, :create), expense: attrs
    assert redirected_to(conn) == account_path(conn, :show, account.id)
    assert Repo.get_by(Expense, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user} do
    account = insert_account(user)
    attrs = Dict.merge(%{account_id: account.id}, @invalid_attrs)

    conn = post conn, expense_path(conn, :create), expense: attrs
    assert html_response(conn, 200) =~ "New expense"
  end

  @tag login_as: "max"
  test "shows chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    expense = insert_expense(account)

    conn = get conn, expense_path(conn, :show, expense)
    assert html_response(conn, 200) =~ "Show expense"
  end

  @tag login_as: "max"
  test "renders page not found when id is nonexistent", %{conn: conn, user: _user} do
    assert_error_sent 404, fn ->
      get conn, expense_path(conn, :show, -1)
    end
  end

  @tag login_as: "max"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    expense = insert_expense(account)

    conn = get conn, expense_path(conn, :edit, expense)
    assert html_response(conn, 200) =~ "Edit expense"
  end

  @tag login_as: "max"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    account = insert_account(user)
    expense = insert_expense(account)

    conn = put conn, expense_path(conn, :update, expense), expense: @valid_attrs
    assert redirected_to(conn) == expense_path(conn, :show, expense)
    assert Repo.get_by(Expense, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    account = insert_account(user)
    expense = insert_expense(account)

    conn = put conn, expense_path(conn, :update, expense), expense: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit expense"
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    expense = insert_expense(account)

    conn = delete conn, expense_path(conn, :delete, expense)
    assert redirected_to(conn) == account_path(conn, :show, account.id)
    refute Repo.get(Expense, expense.id)
  end
end

