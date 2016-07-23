defmodule Money.BudgetControllerTest do
  use Money.ConnCase

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
end

