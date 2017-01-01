defmodule Money.CategoryTest do
  use Money.ModelCase

  alias Money.Category

  @valid_attrs %{name: "some content", category_group_id: 3}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end
end
