defmodule Money.CategoryGroupControllerTest do
  use Money.ConnCase
  alias Money.CategoryGroup
  alias Money.Category
  import Money.UserHelpers

  @valid_attrs %{name: "Fun"}
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
    other_user = insert_user(username: "alice")
    insert_category_group(other_user, name: "Group")

    attrs = %{user_id: user.id, name: "Group"}
    insert_category_group(user, attrs)
    conn = post conn, category_group_path(conn, :create), category_group: attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    # Shouldn't key unique across users
    other_user = insert_user(username: "alice")
    insert_category_group(other_user, @valid_attrs)

    category_group = insert_category_group(user)
    conn = put conn, category_group_path(conn, :update, category_group), category_group: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(user_category_groups(user), @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    category_group = insert_category_group(user)
    conn = put conn, category_group_path(conn, :update, category_group), category_group: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "does not update and render error when not unique", %{conn: conn, user: user} do
    insert_category_group(user, %{user_id: user.id, name: "New"})
    category_group = insert_category_group(user, %{user_id: user.id, name: "Original"})
    conn = post conn, category_group_path(conn, :create), category_group: %{user_id: user.id, name: "New"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login_as: "max"
  test "deletes chosen resource", %{conn: conn, user: user} do
    category_group = insert_category_group(user)
    insert_category(category_group, name: "c1")
    insert_category(category_group, name: "c2")
    conn = delete conn, category_group_path(conn, :delete, category_group)
    assert response(conn, 204)
    refute Repo.get(CategoryGroup, category_group.id)
    assert length(Repo.all(Category)) == 0
  end
end

