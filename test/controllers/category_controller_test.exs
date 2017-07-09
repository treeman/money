defmodule Money.CategoryControllerTest do
  use Money.ConnCase

  alias Money.Category
  alias Money.CategoryGroup
  alias Money.BudgetedCategory
  @valid_attrs %{name: "Rent"}
  @invalid_attrs %{name: nil}

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      put(conn, category_path(conn, :update, "123", %{})),
      post(conn, category_path(conn, :create, %{})),
      delete(conn, category_path(conn, :delete, "123")),
      delete(conn, category_path(conn, :delete_categories)),
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
  test "deletes several categories", %{conn: conn, user: user} do
    g1 = insert(:category_group, user: user)

    g2 = insert(:category_group, user: user)
    c21 = insert(:category, category_group: g2)

    g3 = insert(:category_group, user: user)
    c31 = insert(:category, category_group: g3)

    g4 = insert(:category_group, user: user)
    c41 = insert(:category, category_group: g4)
    bc41 = insert(:budgeted_category, category: c41, year: 2017, month: 1)
    bc42 = insert(:budgeted_category, category: c41, year: 2017, month: 2)

    # Ok, we don't allow deleting a category when transactions are there.
    # But we need to handle errors gracefully (changelist?)
    #account = insert(:account, user: user)
    #g4 = insert(:category_group, user: user)
    #c41 = insert(:category, category_group: g4)
    #t41 = insert(:transaction, account: account, category: c41)

    conn = delete conn, category_path(conn, :delete_categories),
                  data: %{groups: Poison.encode!([g1.name, g2.name, g4.name]),
                          categories: Poison.encode!([c31.name])}
    json = json_response(conn, 200)
    assert json["data"]["groups"] == [g1.name, g2.name, g4.name]
    assert json["data"]["categories"] == [c31.name]

    # Delete a group without categories
    refute Repo.get(CategoryGroup, g1.id)
    # Delete a group with categories but without transactions
    refute Repo.get(CategoryGroup, g2.id)
    refute Repo.get(Category, c21.id)
    # Delete categories keeps the group
    assert Repo.get(CategoryGroup, g3.id)
    refute Repo.get(CategoryGroup, c31.id)
    # Delete category should delete all budgeted_categories as well
    refute Repo.get(CategoryGroup, g4.id)
    refute Repo.get(Category, c41.id)
    refute Repo.get(BudgetedCategory, bc41.id)
    refute Repo.get(BudgetedCategory, bc42.id)
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

    delete(conn, category_path(conn, :delete_categories),
           data: %{groups: Poison.encode!([group.name]),
                   categories: Poison.encode!([category.name])})
    assert Repo.get(CategoryGroup, group.id)
    assert Repo.get(Category, category.id)
  end
end
