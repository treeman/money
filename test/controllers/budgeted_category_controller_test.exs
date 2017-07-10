defmodule Money.BudgetedCategoryControllerTest do
  use Money.ConnCase

  #alias Money.BudgetedCategory
  @valid_attrs %{budgeted: Decimal.new(2),
                 year: 2017,
                 month: 4}
  @invalid_attrs %{budgeted: Decimal.new(-3)}

  setup %{conn: conn} = config do
    %{config | conn: put_req_header(conn, "accept", "application/json")}
  end

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      put(conn, budgeted_category_path(conn, :save, "2017", "12", %{})),
      post(conn, budgeted_category_path(conn, :create, %{})),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, budgeted_category_path(conn, :create), budgeted_category: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  #@tag login_as: "max"
  #test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    #category_group = insert(:category_group, user: user)
    #category = insert(:category, category_group: category_group)
    #budgeted_category = insert(:budgeted_category, category: category)

    #conn = put conn, budgeted_category_path(conn, :update, budgeted_category), budgeted_category: @valid_attrs
    #assert json_response(conn, 200)["data"]["id"]
    #assert Repo.get_by(BudgetedCategory, @valid_attrs)
  #end

  #@tag login_as: "max"
  #test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    #budgeted_category = insert(:budgeted_category)
    #conn = put conn, budgeted_category_path(conn, :update, budgeted_category), budgeted_category: @invalid_attrs
    #assert json_response(conn, 422)["errors"] != %{}
  #end
end
