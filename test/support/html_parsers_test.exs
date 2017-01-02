ExUnit.start

defmodule Money.HtmlParsersTest do
  use ExUnit.Case, async: true
  import Money.HtmlParsers

  test "Parsing grid" do
    html = """
<div id="transactions" class="grid">
  <div class="grid-header">
    <div class="grid-header-cell grid-transaction-cb"><input type="checkbox"></div>
    <div class="grid-header-cell grid-transaction-date">Date</div>
    <div class="grid-header-cell grid-transaction-payee">Payee</div>
    <div class="grid-header-cell grid-transaction-category">Category</div>
    <div class="grid-header-cell grid-transaction-description">Comment</div>
    <div class="grid-header-cell grid-transaction-amount">Amount</div>
    <div class="grid-header-cell grid-transaction-balance">Balance</div>
    <div class="grid-header-cell grid-transaction-cleared">
<a class="btn btn-default btn-xs" href="#">C</a>    </div>
    <div class="grid-header-cell grid-transaction-buttons"></div>
  </div>

  <div class="grid-body">
    <div class="grid-row transaction">
      <div class="grid-cell grid-transaction-cb"><input type="checkbox"></div>
      <div class="grid-account-id">1</div>
      <div class="grid-transaction-id">15</div>
      <div class="grid-cell grid-transaction-date">2017-01-02</div>
      <div class="grid-cell grid-transaction-payee">xyz</div>
      <div class="grid-cell grid-transaction-category">Giving</div>
      <div class="grid-cell grid-transaction-description"></div>
      <div class="grid-cell grid-transaction-amount">99</div>
      <div class="grid-cell grid-transaction-balance">13177</div>
      <div class="grid-cell grid-transaction-cleared"><a class="btn btn-default btn-xs" href="#">C</a></div>
    </div>

    <div class="grid-row transaction">
      <div class="grid-cell grid-transaction-cb"><input type="checkbox"></div>
      <div class="grid-account-id">2</div>
      <div class="grid-transaction-id">16</div>
      <div class="grid-cell grid-transaction-date">2017-01-03</div>
      <div class="grid-cell grid-transaction-payee">John Doe .X</div>
      <div class="grid-cell grid-transaction-category">Rent</div>
      <div class="grid-cell grid-transaction-description">No descr</div>
      <div class="grid-cell grid-transaction-amount">13.37</div>
      <div class="grid-cell grid-transaction-balance">-2003</div>
      <div class="grid-cell grid-transaction-cleared"><a class="btn btn-default btn-xs" href="#">C</a></div>
    </div>
  </div>
</div>
"""
    grid = parse_grid(html, ".grid")
    assert grid == [%{"Date" => "2017-01-02",
                      "Payee" => "xyz",
                      "Category" => "Giving",
                      "Amount" => 99.0,
                      "Balance" => 13177.0},
                    %{"Date" => "2017-01-03",
                      "Payee" => "John Doe .X",
                      "Category" => "Rent",
                      "Comment" => "No descr",
                      "Amount" => 13.37,
                      "Balance" => -2003.0}]

  end
end

