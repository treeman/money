defmodule Money.CategoryGroupTest do
  use Money.ModelCase

  alias Money.CategoryGroup

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CategoryGroup.changeset(%CategoryGroup{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CategoryGroup.changeset(%CategoryGroup{}, @invalid_attrs)
    refute changeset.valid?
  end
end
