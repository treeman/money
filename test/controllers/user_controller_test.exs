defmodule Money.UserControllerTest do
  use Money.ConnCase
  alias Money.User
  import Money.UserHelpers

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, account_path(conn, :index)),
      get(conn, account_path(conn, :show, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200)
  end

  test "create a new user", %{conn: conn} do
    attrs = %{name: "Mr. x",
              username: "john_doe",
              password: "password1"}

    conn = post conn, user_path(conn, :create), user: attrs
    assert redirected_to(conn) == account_path(conn, :index)
    user = Repo.get_by(User, %{username: attrs.username})
    assert user
    # Make sure to test seeding for a new user
    assert length(Repo.all(user_categories(user))) > 0
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    attrs = %{name: "alice",
              username: "john_doe",
              password: ""}

    conn = post conn, user_path(conn, :create), user: attrs
    assert html_response(conn, 200)
    refute Repo.get_by(User, username: attrs.username)
  end
end

