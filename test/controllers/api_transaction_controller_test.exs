defmodule ApiTransactionControllerTest do
  use Money.ConnCase

  alias Money.Transaction
  @valid_attrs %{amount: 42,
                 description: "some description",
                 when: Ecto.DateTime.utc,
                 payee: "somewhere"}
  @invalid_attrs %{amount: nil}

  setup %{conn: conn} = config do
    %{config | conn: put_req_header(conn, "accept", "application/json")}
  end

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      put(conn, api_transaction_path(conn, :update, "123", %{})),
      post(conn, api_transaction_path(conn, :create, %{})),
      delete(conn, api_transaction_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "creates and renders resource when data is valid", %{conn: conn, user: user} do
    account = insert(:account, user: user)

    params = Map.merge(@valid_attrs, %{account_id: account.id})

    conn = post conn, api_transaction_path(conn, :create), transaction: params
    json = json_response(conn, 201)
    assert json["data"]["id"]
    assert json["data"]["html_row"]

    transaction = Repo.get_by(Transaction, @valid_attrs)
    assert transaction
    assert transaction.account_id == account.id
  end

  @tag login_as: "max"
  test "parses category name", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    category_group = insert(:category_group, user: user)
    category = insert(:category, category_group: category_group)

    params = Map.merge(@valid_attrs, %{account_id: account.id, category: category.name})

    conn = post conn, api_transaction_path(conn, :create), transaction: params
    json = json_response(conn, 201)
    assert json["data"]["category"] == category.name

    transaction = Repo.get_by(Transaction, @valid_attrs)
    assert transaction.category_id == category.id
  end

  @tag login_as: "max"
  test "parses a date string", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    params = Map.merge(@valid_attrs, %{account_id: account.id, when: "2016-02-03"})

    conn = post conn, api_transaction_path(conn, :create), transaction: params
    json = json_response(conn, 201)
    assert json["data"]["when"] == "2016-02-03T00:00:00";
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, api_transaction_path(conn, :create), transaction: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "returns all transaction balances on creation", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    category_group = insert(:category_group, user: user)
    category = insert(:category, category_group: category_group)
    t1 = insert(:transaction, account: account,
                            amount: 12.34,
                            when: Ecto.DateTime.from_erl({{2010, 10, 10}, {0, 0, 0}}))

    # Add in some other random data
    early = Ecto.DateTime.from_erl({{1900, 10, 10}, {0, 0, 0}})
    account2 = insert(:account, user: user)
    insert(:transaction, account: account2, amount: 99999.99, when: early)
    user2 = insert(:user, username: "alice")
    user2account = insert(:account, user: user2)
    insert(:transaction, account: user2account, amount: 99999.99, when: early)

    params = Map.merge(@valid_attrs, %{account_id: account.id, category_id: category.id, amount: 13.37})
    conn = post conn, api_transaction_path(conn, :create), transaction: params
    json = json_response(conn, 201)
    t_balance = json["data"]["transaction_balance"]
    assert length(Map.keys(t_balance)) == 2
    assert Map.fetch!(t_balance, Integer.to_string(t1.id)) == "12.34"

    transaction = Repo.get_by(Transaction, params)
    assert transaction
    assert Map.fetch!(t_balance, Integer.to_string(transaction.id)) == "25.71"
  end

  @tag login_as: "max"
  test "updates and renders resource when data is valid", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    t1 = insert(:transaction, Map.merge(%{account: account}, @valid_attrs))
    params = %{amount: 1337,
               description: t1.description,
               when: t1.when,
               payee: "nowhere"}

    conn = put conn, api_transaction_path(conn, :update, t1.id), transaction: params
    assert json_response(conn, 200)

    transaction = Repo.get(Transaction, t1.id)
    assert transaction
    assert transaction.description == t1.description
    assert transaction.amount == Decimal.new(1337)
    assert transaction.payee == "nowhere"
  end

  @tag login_as: "max"
  test "returns all transaction balances on update", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    t1 = insert(:transaction, account: account, amount: 12.34, when: Ecto.DateTime.from_erl({{2010, 10, 10}, {0, 0, 0}}))

    t2 = insert(:transaction, Map.merge(%{account: account}, @valid_attrs))
    params = %{amount: 1337,
               description: t2.description,
               when: t2.when,
               payee: "nowhere"}

    # Add in some other random data
    early = Ecto.DateTime.from_erl({{1900, 10, 10}, {0, 0, 0}})
    account2 = insert(:account, user: user)
    insert(:transaction, account: account2, amount: 99999.99, when: early)
    user2 = insert(:user, username: "alice")
    user2account = insert(:account, user: user2)
    insert(:transaction, account: user2account, amount: 99999.99, when: early)

    conn = put conn, api_transaction_path(conn, :update, t2.id), transaction: params
    json = json_response(conn, 200)
    t_balance = json["data"]["transaction_balance"]
    assert length(Map.keys(t_balance)) == 2
    assert Map.fetch!(t_balance, Integer.to_string(t1.id)) == "12.34"
    assert Map.fetch!(t_balance, Integer.to_string(t2.id)) == "1349.34"
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    t1 = insert(:transaction, account: account)
    conn = put conn, api_transaction_path(conn, :update, t1.id), transaction: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    account = insert(:account, user: user)
    transaction = insert(:transaction, account: account)

    conn = delete conn, api_transaction_path(conn, :delete, transaction)
    json = json_response(conn, 200)
    assert json["data"]["id"] == transaction.id
    assert json["data"]["transaction_balance"]
    refute Repo.get(Transaction, transaction.id)
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    account = insert(:account, user: owner)
    transaction = insert(:transaction, account: account)

    non_owner = insert(:user, username: "alice")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      attrs = Dict.merge(%{account_id: account.id}, @valid_attrs)
      put(conn, api_transaction_path(conn, :update, transaction), transaction: attrs)
    end
    assert_error_sent :not_found, fn ->
      delete(conn, api_transaction_path(conn, :delete, transaction))
    end
  end
end

