defmodule Money.AccountControllerTest do
  use Money.ConnCase
  alias Money.Account
  import Money.HtmlParsers
  alias Ecto.DateTime
  import Kernel

  @valid_attrs %{title: "some content"}
  @invalid_attrs %{}

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
  test "lists all transactions on index", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    insert(:transaction, account: account, amount: 1337, payee: "John", description: "Johns payment")
    insert(:transaction, account: account, amount: -99, payee: "Mr.X", description: "secret transaction")

    other_account = insert(:account, user: user)
    insert(:transaction, account: other_account, amount: 123456, payee: "Alice")

    conn = get conn, account_path(conn, :index)
    html = html_response(conn, 200)

    assert String.contains?(html, "1337")
    assert String.contains?(html, "John")
    assert String.contains?(html, "Johns payment")

    assert String.contains?(html, "-99")
    assert String.contains?(html, "Mr.X")
    assert String.contains?(html, "secret transaction")

    assert String.contains?(html, "123456")
    assert String.contains?(html, "Alice")
  end

  @tag login_as: "max"
  test "renders form for new resources", %{conn: conn, user: _user} do
    conn = get conn, account_path(conn, :new)
    assert html_response(conn, 200) =~ "New account"
  end

  @tag login_as: "max"
  test "creates resource and redirects when data is valid", %{conn: conn, user: _user} do
    conn = post conn, account_path(conn, :create), account: @valid_attrs
    assert redirected_to(conn) == account_path(conn, :index)
    assert Repo.get_by(Account, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: _user} do
    conn = post conn, account_path(conn, :create), account: @invalid_attrs
    assert html_response(conn, 200) =~ "New account"
  end

  @tag login_as: "max"
  test "shows chosen resource", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    insert(:transaction, account: account, amount: 1337, payee: "John", description: "Johns payment")
    insert(:transaction, account: account, amount: -99, payee: "Mr.X", description: "secret transaction")

    other_account = insert(:account, user: user)
    insert(:transaction, account: other_account, amount: 123456, payee: "Alice")

    conn = get conn, account_path(conn, :show, account)
    html = html_response(conn, 200)

    assert String.contains?(html, "1337")
    assert String.contains?(html, "John")
    assert String.contains?(html, "Johns payment")

    assert String.contains?(html, "-99")
    assert String.contains?(html, "Mr.X")
    assert String.contains?(html, "secret transaction")

    refute String.contains?(html, "123456")
    refute String.contains?(html, "Alice")
  end

  @tag login_as: "max"
  test "renders page not found when id is nonexistent", %{conn: conn, user: _user} do
    assert_error_sent 404, fn ->
      get conn, account_path(conn, :show, -1)
    end
  end

  @tag login_as: "max"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    conn = get conn, account_path(conn, :edit, account)
    assert html_response(conn, 200) =~ "Edit account"
  end

  @tag login_as: "max"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    conn = put conn, account_path(conn, :update, account), account: @valid_attrs
    assert redirected_to(conn) == account_path(conn, :show, account)
    assert Repo.get_by(Account, @valid_attrs)
  end

  # Currently no invalid attributes, so we're still getting redirected
  #@tag login_as: "max"
  #test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    #account = insert(:account, user: user)
    #conn = put conn, account_path(conn, :update, account), account: @invalid_attrs
    #assert html_response(conn, 200) =~ "Edit account"
  #end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    conn = delete conn, account_path(conn, :delete, account)
    assert redirected_to(conn) == account_path(conn, :index)
    refute Repo.get(Account, account.id)
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    account = insert(:account, Map.merge(%{user: owner}, @valid_attrs))
    non_owner = insert(:user, username: "alice")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, account_path(conn, :show, account))
    end
    assert_error_sent :not_found, fn ->
      get(conn, account_path(conn, :edit, account))
    end
    assert_error_sent :not_found, fn ->
      put(conn, account_path(conn, :update, account), account: @valid_attrs)
    end
    assert_error_sent :not_found, fn ->
      delete(conn, account_path(conn, :delete, account))
    end
  end

  @tag login_as: "max"
  test "list all accounts", %{conn: conn, user: user} do
    acc1 = insert(:account, user: user, title: "Alice account")
    acc2 = insert(:account, user: user, title: "Bob account")

    other_user = insert(:user, username: "Eve")
    acc3 = insert(:account, user: other_user, title: "Eve account")

    conn = get conn, account_path(conn, :index)
    html = html_response(conn, 200)

    assert String.contains?(html, account_path(conn, :index))
    assert String.contains?(html, account_path(conn, :show, acc1))
    assert String.contains?(html, account_path(conn, :show, acc2))
    refute String.contains?(html, account_path(conn, :show, acc3))
  end

  @tag login_as: "max"
  test "rolling balance of transactions", %{conn: conn, user: user} do
    # Should never show up.
    other_user = insert(:user, username: "Alice")
    other_account = insert(:account, user: other_user)
    {:ok, dt} = DateTime.cast("2016-07-01 23:59:59")
    insert(:transaction, account: other_account, amount: -99999, payee: "Bob", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-03 11:11:11")
    insert(:transaction, account: other_account, amount: -99999, payee: "Alice", when: dt)

    acc1 = insert(:account, user: user, title: "Account 1")
    {:ok, dt} = DateTime.cast("2016-06-30 00:01:00")
    insert(:transaction, account: acc1, amount: 1000, payee: "Income", when: dt)
    {:ok, dt} = DateTime.cast("2016-06-30 00:01:01")
    insert(:transaction, account: acc1, amount: -23, payee: "Gum1", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-01 23:59:59")
    insert(:transaction, account: acc1, amount: -13, payee: "Gum2", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-03 00:11:11")
    insert(:transaction, account: acc1, amount: -102, payee: "Gum3", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-03 00:11:11")
    insert(:transaction, account: acc1, amount: -1017, payee: "Gum4", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-31 01:00:00")
    insert(:transaction, account: acc1, amount: 1000, payee: "Income", when: dt)
    {:ok, dt} = DateTime.cast("2016-08-01 00:10:00")
    insert(:transaction, account: acc1, amount: -3, payee: "Gum5", when: dt)

    acc2 = insert(:account, user: user, title: "Account 2")
    {:ok, dt} = DateTime.cast("2016-06-30 00:02:00")
    insert(:transaction, account: acc2, amount: 37, payee: "Food Income", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-02 23:59:59")
    insert(:transaction, account: acc2, amount: -3.3, payee: "Food1", when: dt)
    {:ok, dt} = DateTime.cast("2016-07-10 01:00:00")
    insert(:transaction, account: acc2, amount: -7, payee: "Food2", when: dt)
    {:ok, dt} = DateTime.cast("2016-08-01 00:00:00")
    insert(:transaction, account: acc2, amount: -31, payee: "Food3", when: dt)

    conn = get conn, account_path(conn, :index)
    html = html_response(conn, 200)

    # List is rendered latest at the top, test bottom up
    table = parse_table(html, ".ctable") |> Enum.reverse

    expected = [
      %{"Account" => "Account 1", "Amount" => 1000, "Balance" => 1000, "Payee" => "Income", "Date" => "2016-06-30"},
      %{"Account" => "Account 1", "Amount" => -23, "Balance" => 977, "Payee" => "Gum1", "Date" => "2016-06-30"},
      %{"Account" => "Account 2", "Amount" => 37, "Balance" => 37, "Payee" => "Food Income", "Date" => "2016-06-30"},
      %{"Account" => "Account 1", "Amount" => -13, "Balance" => 964, "Payee" => "Gum2", "Date" => "2016-07-01"},
      %{"Account" => "Account 2", "Amount" => -3.3, "Balance" => 33.7, "Payee" => "Food1", "Date" => "2016-07-02"},
      %{"Account" => "Account 1", "Amount" => -102, "Balance" => 862, "Payee" => "Gum3", "Date" => "2016-07-03"},
      %{"Account" => "Account 1", "Amount" => -1017, "Balance" => -155, "Payee" => "Gum4", "Date" => "2016-07-03"},
      %{"Account" => "Account 2", "Amount" => -7, "Balance" => 26.7, "Payee" => "Food2", "Date" => "2016-07-10"},
      %{"Account" => "Account 1", "Amount" => 1000, "Balance" => 845, "Payee" => "Income", "Date" => "2016-07-31"},
      %{"Account" => "Account 2", "Amount" => -31, "Balance" => -4.3, "Payee" => "Food3", "Date" => "2016-08-01"},
      %{"Account" => "Account 1", "Amount" => -3, "Balance" => 842, "Payee" => "Gum5", "Date" => "2016-08-01"}
    ]
    for {want, have} <- Enum.zip(expected, table) do
      assert want == have
    end
    assert length(table) == length(expected)
  end
end

