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
<table class="table">
  <thead>
    <tr> <th>Category</th> <th>Budgeted</th> <th>Activity</th> <th>Balance</th> </tr>
  </thead>
  <tbody>
    <tr class="budgeted-group">
      <td>Essentials</td> <td>1337</td> <td>122</td> <td>1459</td>
    </tr>
      <tr class="budgeted-category">
        <td>Food</td> <td>500</td> <td>100</td> <td>400</td>
      </tr>
      <tr class="budgeted-category">
        <td>Rent</td> <td>0</td> <td>0</td> <td>0</td>
      </tr>
    <tr class="budgeted-group">
      <td>Fun</td> <td>10</td> <td>3</td> <td>7</td>
    </tr>
  </tbody>
</table>
</main>
"""
    table = parse_table(html, ".table")
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
<table class="table">
  <thead>
    <tr> <th></th> <th>Category</th> <th>Budgeted</th> <th>Activity</th> <th>Balance</th> <th></th> </tr>
  </thead>
  <tbody>
    <tr class="budgeted-group">
      <td>1</td><td>Essentials</td> <td>1337</td> <td>122</td> <td>1459</td><td>1</td>
    </tr>
      <tr class="budgeted-category">
        <td>1</td><td>Food</td> <td>500</td> <td>100</td> <td>400</td><td>1</td>
      </tr>
      <tr class="budgeted-category">
        <td>1</td><td>Rent</td> <td>0</td> <td>0</td> <td>0</td><td>1</td>
      </tr>
    <tr class="budgeted-group">
      <td>1</td><td>Fun</td> <td>10</td> <td>3</td> <td>7</td><td>1</td>
    </tr>
  </tbody>
</table>
</main>
"""
    table = parse_table(html, ".table")
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

