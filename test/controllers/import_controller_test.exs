defmodule Money.ImportControllerTest do
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
      get(conn, import_path(conn, :new, 6)),
      get(conn, import_path(conn, :parse, 6)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "parse", %{conn: conn, user: user} do
    data = """
 Bokf.datum Klicka på pilen för att sortera listan i datumordning. 	Trans.datum Klicka på pilen för att sortera listan i datumordning. 	Kontohändelse Klicka på pilen för att sortera listan efter kontohändelse i bokstavsordning. 	  	Belopp Klicka på pilen för att sortera listan i beloppsordning. 	Saldo

16-12-28 	16-12-28  	Expensive Stuff  	  	-99 129,00 	9 999,99
    """
    account = insert_account(user)
    conn = post conn, import_path(conn, :parse, account.id), data: data
    assert html_response(conn, 302)
  end
end

