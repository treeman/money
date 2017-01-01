defmodule Money.CategoryGroupControllerTest do
  use Money.ConnCase
  alias Money.CategoryGroup
  alias Money.Category
  import Money.UserHelpers

  @valid_attrs %{name: "Fun"}
  @invalid_attrs %{name: nil}

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      put(conn, category_group_path(conn, :update, "123", %{})),
      post(conn, category_group_path(conn, :create, %{})),
      delete(conn, category_group_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "creates and renders resource when data is valid", %{conn: conn, user: user} do
    attrs = Dict.merge(%{user_id: user.id}, @valid_attrs)
    conn = post conn, category_group_path(conn, :create), category_group: attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(CategoryGroup, attrs)
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user} do
    attrs = Dict.merge(%{user_id: user.id}, @invalid_attrs)
    conn = post conn, category_group_path(conn, :create), category_group: attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "does not create and render error when not unique", %{conn: conn, user: user} do
    # Shouldn't key unique across users
    other_user = insert(:user, username: "alice")
    insert(:category_group, user: other_user, name: "Group")

    attrs = %{user_id: user.id, name: "Group"}
    insert(:category_group, Map.merge(%{user: user}, attrs))
    conn = post conn, category_group_path(conn, :create), category_group: attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    # Shouldn't key unique across users
    other_user = insert(:user, username: "alice")
    insert(:category_group, Map.merge(%{user: other_user}, @valid_attrs))

    category_group = insert(:category_group, user: user)
    conn = put conn, category_group_path(conn, :update, category_group), category_group: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(user_category_groups(user), @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    category_group = insert(:category_group, user: user)
    conn = put conn, category_group_path(conn, :update, category_group), category_group: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "does not update and render error when not unique", %{conn: conn, user: user} do
    insert(:category_group, user: user, user_id: user.id, name: "New")
    insert(:category_group, user: user, user_id: user.id, name: "Original")
    conn = post conn, category_group_path(conn, :create), category_group: %{user_id: user.id, name: "New"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    category_group = insert(:category_group, user: user)
    insert(:category, category_group: category_group, name: "c1")
    insert(:category, category_group: category_group, name: "c2")
    conn = delete conn, category_group_path(conn, :delete, category_group)
    assert response(conn, 204)
    refute Repo.get(CategoryGroup, category_group.id)
    assert length(Repo.all(Category)) == 0
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn, user: owner} do
    group = insert(:category_group, user: owner)

    non_owner = insert(:user, username: "alice")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      attrs = Dict.merge(%{category_group_id: group.id}, @valid_attrs)
      put(conn, category_group_path(conn, :update, group), category_group: attrs)
    end
    assert_error_sent :not_found, fn ->
      delete(conn, category_group_path(conn, :delete, group))
    end
  end
end

