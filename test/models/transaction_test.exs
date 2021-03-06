defmodule Money.TransactionTest do
  use Money.ModelCase

  alias Money.Transaction

  @valid_attrs %{
    amount: 42,
    account_id: 1,
    category: "some content",
    description: "some content",
    when: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010},
    payee: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end

