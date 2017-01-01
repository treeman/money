defmodule Money.CategoryControllerTest do
  use Money.ConnCase

  alias Money.Category
  @valid_attrs %{name: "Rent"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
    else
      {:ok, conn: put_req_header(conn, "accept", "application/json")}
    end
  end

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      put(conn, category_path(conn, :update, "123", %{})),
      post(conn, category_path(conn, :create, %{})),
      delete(conn, category_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "creates and renders resource when data is valid", %{conn: conn, user: user} do
    category_group = insert_category_group(user)
    attrs = Dict.merge(%{category_group_id: category_group.id}, @valid_attrs)
    conn = post conn, category_path(conn, :create), category: attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Category, attrs)
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user} do
    category_group = insert_category_group(user)
    attrs = Dict.merge(%{category_group_id: category_group.id}, @invalid_attrs)
    conn = post conn, category_path(conn, :create), category: attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "does not create and render error when not unique", %{conn: conn, user: user} do
    # Shouldn't key unique across users
    other_user = insert_user(username: "alice")
    og = insert_category_group(other_user)
    insert_category(og, name: "Existing")

    g = insert_category_group(user)
    insert_category(g, name: "Existing")
    conn = post conn, category_path(conn, :create), category: %{category_group_id: g.id, name: "Existing"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    category_group = insert_category_group(user)
    category = insert_category(category_group)
    conn = put conn, category_path(conn, :update, category), category: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Category, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    category_group = insert_category_group(user)
    category = insert_category(category_group)
    conn = put conn, category_path(conn, :update, category), category: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "does not update and renders error when not unique", %{conn: conn, user: user} do
    g = insert_category_group(user)
    insert_category(g, name: "Existing")
    category = insert_category(g, name: "New")
    conn = put conn, category_path(conn, :update, category), category: %{name: "Existing"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    category_group = insert_category_group(user)
    category = insert_category(category_group)
    conn = delete conn, category_path(conn, :delete, category)
    assert response(conn, 204)
    refute Repo.get(Category, category.id)
  end
end
