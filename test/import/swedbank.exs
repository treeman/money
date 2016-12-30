defmodule Money.Import.SwedbankTest do
  use ExUnit.Case, async: true
  import Money.Import.Swedbank

  test "to_date" do
    assert {:ok, _} = to_date("06-12-13")
    assert {:ok, _} = to_date("2006-12-13")

    assert {:ok, dt} = to_date("06-12-13")
    assert dt.year == 2006;
    assert {:ok, dt} = to_date("96-12-13")
    assert dt.year == 1996;
    assert {:ok, dt} = to_date("1906-12-13")
    assert dt.year == 1906;

    assert {:error, _} = to_date("06-02-31")
    assert {:error, _} = to_date("x")
  end

  test "guess_year" do
    assert guess_year("2006") == "2006"
    assert guess_year("06") == "2006"
    assert guess_year("1996") == "1996"
    assert guess_year("96") == "1996"
  end

  test "to_num" do
    assert {:error, _} = to_num("x123xyz")
    assert {:ok, res} = to_num("123 456,789")
    assert res == Decimal.new(123456.789)
  end

  test "parse_transactions" do
    data = """
 Bokf.datum Klicka på pilen för att sortera listan i datumordning. 	Trans.datum Klicka på pilen för att sortera listan i datumordning. 	Kontohändelse Klicka på pilen för att sortera listan efter kontohändelse i bokstavsordning. 	  	Belopp Klicka på pilen för att sortera listan i beloppsordning. 	Saldo

16-12-24 	16-12-28  	Expensive Stuff  	  	99 129,00 	9 999,99
16-12-23 	16-12-23  	FOOD EXPRESS  	  	-83,20 	2 222,22
    """
    transactions = parse_transactions(data)

    assert length(transactions) == 2
    t1 = Enum.at(transactions, 0).changes
    assert t1.when == Ecto.DateTime.cast!("2016-12-23T00:00:00")
    assert t1.description == "FOOD EXPRESS"
    assert t1.amount == Decimal.new(-83.20)

    t2 = Enum.at(transactions, 1).changes
    assert t2.when == Ecto.DateTime.cast!("2016-12-28T00:00:00")
    assert t2.description == "Expensive Stuff"
    assert t2.amount == Decimal.new(99129.0)
  end
end

