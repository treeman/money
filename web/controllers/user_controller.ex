defmodule Money.UserController do
  use Money.Web, :controller
  alias Money.User
  alias Money.CategoryGroup

  plug :authenticate_user when action in [:index, :show]

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        seed_categories(user)

        conn
        |> Money.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: account_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def seed_categories(user) do
    groups = [
      %{name: "Savings",
        categories: ["Buffer", "Investment"]},
      %{name: "Debt",
        categories: ["Student Loan", "Mortgage"]},
      %{name: "Housing",
        categories: ["Electricity", "Rent", "Internet", "Maintenance", "Home Insurance"]},
      %{name: "Food",
        categories: ["Groceries", "Restaurants"]},
      %{name: "Transportation",
        categories: ["Gas", "Maintenance", "Car Insurance"]},
      %{name: "Health",
        categories: ["Life Insurance", "Medical", "Fitness"]},
      %{name: "Other Passive Expenses",
        categories: ["Software Subscriptions", "Phone"]},
      %{name: "Other Active Expenses",
        categories: ["Clothing", "Education", "Fun Money", "Gaming", "Giving",
                     "Music", "Unbudgeted", "Vacation"]}
    ]

    for %{name: name, categories: categories} <- groups do
      group = Repo.get_by(CategoryGroup, user_id: user.id, name: name) ||
                build_assoc(user, :category_groups, %{name: name})
                |> Repo.insert!()

      for c <- categories do
        category = build_assoc(group, :categories, %{name: c})
        Repo.insert!(category)
      end
    end
  end
end

