defmodule Money.ApiTransactionController do
  use Money.Web, :controller
  alias Money.Transaction

  plug :load_categories when action in [:create]
  #plug :load_categories when action in [:create, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def create(conn, %{"transaction" => transaction_params}, _user) do
    IO.inspect("api json!")
    IO.inspect(transaction_params)
    changeset = Transaction.changeset(%Transaction{}, transaction_params)

    case Repo.insert(changeset) do
      {:ok, transaction} ->
        IO.puts("ok")
        IO.inspect(transaction)
        IO.inspect(changeset)
        # TODO handle redirects in a cleaner way.
        #account_id = Map.get(transaction_params, "account_id")
        #render(conn, "create.json", changeset: changeset)
        render(conn, "create.json", transaction)
      {:error, changeset} ->
        IO.puts("bad changeset")
        IO.inspect(changeset)
        render(conn, "create.json", changeset: changeset)
    end
  end
end

