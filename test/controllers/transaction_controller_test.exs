defmodule Money.TransactionControllerTest do
  use Money.ConnCase

  alias Money.Transaction
  @valid_attrs %{amount: 42,
                 description: "some description",
                 when: Ecto.DateTime.utc,
                 payee: "somewhere"}
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
    conn = get conn, transaction_path(conn, :new, %{"account_id" => 3})
    assert html_response(conn, 200) =~ "New transaction"
  end

  @tag login_as: "max"
  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    account = insert_account(user)
    category = insert_category()
    attrs = Dict.merge(%{account_id: account.id, category_id: category.id}, @valid_attrs)

    conn = post conn, transaction_path(conn, :create), transaction: attrs
    assert redirected_to(conn) == account_path(conn, :show, account.id)
    assert Repo.get_by(Transaction, @valid_attrs)
  end

  @tag login_as: "max"
  test "correctly associates with categories and accounts", %{conn: conn, user: user} do
    account = insert_account(user)
    category = insert_category()
    attrs = Dict.merge(%{account_id: account.id, category_id: category.id}, @valid_attrs)

    post conn, transaction_path(conn, :create), transaction: attrs
    t = Repo.get_by(Transaction, @valid_attrs)

    assert category.id == t.category_id
    assert account.id == t.account_id
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user} do
    account = insert_account(user)
    attrs = Dict.merge(%{account_id: account.id}, @invalid_attrs)

    conn = post conn, transaction_path(conn, :create), transaction: attrs
    assert html_response(conn, 200) =~ "New transaction"
  end

  @tag login_as: "max"
  test "shows chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    transaction = insert_transaction(account)

    conn = get conn, transaction_path(conn, :show, transaction)
    assert html_response(conn, 200) =~ "Show transaction"
  end

  @tag login_as: "max"
  test "renders page not found when id is nonexistent", %{conn: conn, user: _user} do
    assert_error_sent 404, fn ->
      get conn, transaction_path(conn, :show, -1)
    end
  end

  @tag login_as: "max"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    transaction = insert_transaction(account)

    conn = get conn, transaction_path(conn, :edit, transaction)
    assert html_response(conn, 200) =~ "Edit transaction"
  end

  @tag login_as: "max"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    account = insert_account(user)
    transaction = insert_transaction(account)

    conn = put conn, transaction_path(conn, :update, transaction), transaction: @valid_attrs
    assert redirected_to(conn) == transaction_path(conn, :show, transaction)
    assert Repo.get_by(Transaction, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    account = insert_account(user)
    transaction = insert_transaction(account)

    conn = put conn, transaction_path(conn, :update, transaction), transaction: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit transaction"
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    transaction = insert_transaction(account)

    conn = delete conn, transaction_path(conn, :delete, transaction)
    assert redirected_to(conn) == account_path(conn, :show, account.id)
    refute Repo.get(Transaction, transaction.id)
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    account = insert_account(owner)
    transaction = insert_transaction(account)

    non_owner = insert_user(username: "alice")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, transaction_path(conn, :show, transaction))
    end
    assert_error_sent :not_found, fn ->
      get(conn, transaction_path(conn, :edit, transaction))
    end
    assert_error_sent :not_found, fn ->
      attrs = Dict.merge(%{account_id: account.id}, @valid_attrs)
      put(conn, transaction_path(conn, :update, transaction), transaction: attrs)
    end
    assert_error_sent :not_found, fn ->
      delete(conn, transaction_path(conn, :delete, transaction))
    end
  end
end

