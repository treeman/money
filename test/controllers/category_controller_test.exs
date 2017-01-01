defmodule Money.CategoryControllerTest do
  use Money.ConnCase

  alias Money.Category
  @valid_attrs %{name: "Rent"}
  @invalid_attrs %{name: nil}

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
    category_group = insert(:category_group, user: user)
    attrs = Dict.merge(%{category_group_id: category_group.id}, @valid_attrs)
    conn = post conn, category_path(conn, :create), category: attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Category, attrs)
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user} do
    category_group = insert(:category_group, user: user)
    attrs = Dict.merge(%{category_group_id: category_group.id}, @invalid_attrs)
    conn = post conn, category_path(conn, :create), category: attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "does not create and render error when not unique", %{conn: conn, user: user} do
    # Shouldn't key unique across users
    other_user = insert(:user, username: "alice")
    og = insert(:category_group, user: other_user)
    insert(:category, category_group: og, name: "Existing")

    g = insert(:category_group, user: user)
    insert(:category, category_group: g, name: "Existing")
    conn = post conn, category_path(conn, :create), category: %{category_group_id: g.id, name: "Existing"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    category_group = insert(:category_group, user: user)
    category = insert(:category, category_group: category_group)
    conn = put conn, category_path(conn, :update, category), category: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Category, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    category_group = insert(:category_group, user: user)
    category = insert(:category, category_group: category_group)
    conn = put conn, category_path(conn, :update, category), category: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "does not update and renders error when not unique", %{conn: conn, user: user} do
    g = insert(:category_group, user: user)
    insert(:category, category_group: g, name: "Existing")
    category = insert(:category, category_group: g, name: "New")
    conn = put conn, category_path(conn, :update, category), category: %{name: "Existing"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    category_group = insert(:category_group, user: user)
    category = insert(:category, category_group: category_group)
    conn = delete conn, category_path(conn, :delete, category)
    assert response(conn, 204)
    refute Repo.get(Category, category.id)
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    group = insert(:category_group, user: owner)
    category = insert(:category, category_group: group)

    non_owner = insert(:user, username: "alice")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      attrs = Dict.merge(%{category_id: category.id}, @valid_attrs)
      put(conn, category_path(conn, :update, category), category: attrs)
    end
    assert_error_sent :not_found, fn ->
      delete(conn, category_path(conn, :delete, category))
    end
  end
end
