defmodule Money.AccountControllerTest do
  use Money.ConnCase

  alias Money.Account
  @valid_attrs %{title: "some content"}
  @invalid_attrs %{}

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
  test "lists all entries on index", %{conn: conn, user: _user} do
    conn = get conn, account_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing accounts"
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
    account = insert_account(user)
    conn = get conn, account_path(conn, :show, account)
    assert html_response(conn, 200) =~ "Show account"
  end

  @tag login_as: "max"
  test "renders page not found when id is nonexistent", %{conn: conn, user: _user} do
    assert_error_sent 404, fn ->
      get conn, account_path(conn, :show, -1)
    end
  end

  @tag login_as: "max"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    conn = get conn, account_path(conn, :edit, account)
    assert html_response(conn, 200) =~ "Edit account"
  end

  @tag login_as: "max"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    account = insert_account(user)
    conn = put conn, account_path(conn, :update, account), account: @valid_attrs
    assert redirected_to(conn) == account_path(conn, :show, account)
    assert Repo.get_by(Account, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    account = insert_account(user)
    conn = put conn, account_path(conn, :update, account), account: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit account"
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    account = insert_account(user)
    conn = delete conn, account_path(conn, :delete, account)
    assert redirected_to(conn) == account_path(conn, :index)
    refute Repo.get(Account, account.id)
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    account = insert_account(owner, @valid_attrs)
    non_owner = insert_user(username: "alice")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, account_path(conn, :show, account))
    end
    assert_error_sent :not_found, fn ->
      get(conn, account_path(conn, :edit, account))
    end
    assert_error_sent :not_found, fn ->
      put(conn, account_path(conn, :update, account, account: @valid_attrs))
    end
    assert_error_sent :not_found, fn ->
      delete(conn, account_path(conn, :delete, account))
    end
  end
end

