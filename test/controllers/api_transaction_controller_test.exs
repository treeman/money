defmodule ApiTransactionControllerTest do
  use Money.ConnCase

  alias Money.Transaction
  @valid_attrs %{amount: 42,
                 description: "some description",
                 when: Ecto.DateTime.utc,
                 payee: "somewhere"}
  @invalid_attrs %{amount: nil}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
    else
      :ok
    end
  end

  test "requries user authentication on all actions", %{conn: conn} do
    Enum.each([
      post(conn, api_transaction_path(conn, :create, %{})),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  #test "lists all entries on index", %{conn: conn} do
    #conn = get conn, api_transaction_path(conn, :index)
    #assert json_response(conn, 200)["data"] == []
  #end

  #test "shows chosen resource", %{conn: conn} do
    #api_transaction = Repo.insert! %<%= alias %>{}
    #conn = get conn, api_transaction_path(conn, :show, api_transaction)
    #assert json_response(conn, 200)["data"] == %{"id" => api_transaction.id<%= for {k, _} <- attrs do %>,
      #"<%= k %>" => api_transaction.<%= k %><% end %>}
  #end

  #@tag login_as: "max"
  #test "renders page not found when id is nonexistent", %{conn: conn} do
    #assert_error_sent 404, fn ->
      #get conn, api_transaction_path(conn, :show, -1)
    #end
  #end

  @tag login_as: "max"
  test "creates and renders resource when data is valid", %{conn: conn, user: user} do
    account = insert_account(user)
    transaction = Map.put(@valid_attrs, :account_id, account.id)
    conn = post conn, api_transaction_path(conn, :create), transaction: transaction
    json = json_response(conn, 201)
    assert json["data"]["id"]
    assert json["data"]["html_row"]
    assert Repo.get_by(Transaction, transaction)
  end

  @tag login_as: "max"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, api_transaction_path(conn, :create), transaction: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  #test "updates and renders chosen resource when data is valid", %{conn: conn} do
    #api_transaction = Repo.insert! %<%= alias %>{}
    #conn = put conn, api_transaction_path(conn, :update, api_transaction), api_transaction: @valid_attrs
    #assert json_response(conn, 200)["data"]["id"]
    #assert Repo.get_by(<%= alias %>, @valid_attrs)
  #end

  #test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    #api_transaction = Repo.insert! %<%= alias %>{}
    #conn = put conn, api_transaction_path(conn, :update, api_transaction), api_transaction: @invalid_attrs
    #assert json_response(conn, 422)["errors"] != %{}
  #end

  #test "deletes chosen resource", %{conn: conn} do
    #api_transaction = Repo.insert! %<%= alias %>{}
    #conn = delete conn, api_transaction_path(conn, :delete, api_transaction)
    #assert response(conn, 204)
    #refute Repo.get(<%= alias %>, api_transaction.id)
  #end
end
