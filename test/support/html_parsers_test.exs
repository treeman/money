ExUnit.start

defmodule Money.HtmlParsersTest do
  use ExUnit.Case, async: true
  import Money.HtmlParsers

  test "Parsing table" do
    html = """
<main role="main" class="right-main">
<p class="alert alert-info" role="alert"></p>
<p class="alert alert-danger" role="alert"></p>

year: 2016 month: 7
<div class="ctable">
  <div class="thead">
    <div class="tr">
      <div class="th">Category</div> <div class="th">Budgeted</div> <div class="th">Activity</div> <div class="th">Balance</div>
    </div>
  </div>
  <div class="tbody">
    <div class="tr budgeted-group">
      <div class="tc">Essentials</div> <div class="tc">1337</div> <div class="tc">122</div> <div class="tc">1459</div>
    </div>
    <div class="tr budgeted-category">
      <div class="tc">Food</div> <div class="tc">500</div> <div class="tc">100</div> <div class="tc">400</div>
    </div>
    <div class="tr budgeted-category">
      <div class="tc">Rent</div> <div class="tc">0</div> <div class="tc">0</div> <div class="tc">0</div>
    </div>
    <div class="tr budgeted-group">
      <div class="tc">Fun</div> <div class="tc">10</div> <div class="tc">3</div> <div class="tc">7</div>
    </div>
  </div>
</div>
</main>
"""
    table = parse_table(html, ".ctable")
    assert table == [%{"Category" => "Essentials", "Budgeted" => 1337,
                       "Activity" => 122, "Balance" => 1459},
                     %{"Category" => "Food", "Budgeted" => 500,
                       "Activity" => 100, "Balance" => 400},
                     %{"Category" => "Rent", "Budgeted" => 0,
                       "Activity" => 0, "Balance" => 0},
                     %{"Category" => "Fun", "Budgeted" => 10,
                       "Activity" => 3, "Balance" => 7}]
  end

  test "Parsing table skip empty headers" do
    html = """
<main role="main" class="right-main">
<p class="alert alert-info" role="alert"></p>
<p class="alert alert-danger" role="alert"></p>

year: 2016 month: 7
<div class="ctable">
  <div class="thead">
    <div class="tr">
      <div class="th"></div> <div class="th">Category</div> <div class="th">Budgeted</div> <div class="th">Activity</div> <div class="th">Balance</div> <div class="th"></div>
    </div>
  </div>
  <div class="tbody">
    <div class="tr budgeted-group">
      <div class="tc">1</div><div class="tc">Essentials</div> <div class="tc">1337</div> <div class="tc">122</div> <div class="tc">1459</div><div class="tc">1</div>
    </div>
    <div class="tr budgeted-category">
      <div class="tc">1</div><div class="tc">Food</div> <div class="tc">500</div> <div class="tc">100</div> <div class="tc">400</div><div class="tc">1</div>
    </div>
    <div class="tr budgeted-category">
      <div class="tc">1</div><div class="tc">Rent</div> <div class="tc">0</div> <div class="tc">0</div> <div class="tc">0</div><div class="tc">1</div>
    </div>
    <div class="tr budgeted-group">
      <div class="tc">1</div><div class="tc">Fun</div> <div class="tc">10</div> <div class="tc">3</div> <div class="tc">7</div><div class="tc">1</div>
    </div>
  </div>
</div>
</main>
"""
    table = parse_table(html, ".ctable")
    assert table == [%{"Category" => "Essentials", "Budgeted" => 1337,
                       "Activity" => 122, "Balance" => 1459},
                     %{"Category" => "Food", "Budgeted" => 500,
                       "Activity" => 100, "Balance" => 400},
                     %{"Category" => "Rent", "Budgeted" => 0,
                       "Activity" => 0, "Balance" => 0},
                     %{"Category" => "Fun", "Budgeted" => 10,
                       "Activity" => 3, "Balance" => 7}]
  end
end

