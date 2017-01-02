# MoneyTracker9000

I want to track my budget including investments and expenses. Instead of using any of the many already existing ones I figured I'd build my own, go figure. It's also an excuse for me to learn web dev with Elixir and Phoenix.

# Vim

C-]     Jump to definition
C-t     Jump back

# TODO
1. Categories
1. Finish swedbank transaction importer
1. Minor stuff for account view
1. Cleanup budget view

## Categories
1. UI for:
    1. Need to be able to create a category and groups
    1. Need to be able to delete/rename a category and groups

## Import text
* In the future import using the api of banks, now just make a simple parser...

## Account view
1. Add new fields for a transaction:
    (account)
    checked
    account
    outflow/inflow instead of amount
    'cleared'
1. Table header should always be visible
1. Use explicit width for table display, flex is useful
1. Clicking on new account should insert a row into the table at the top instead
1. Search/filter/sort
1. Edit a transaction should reveal:
    clear/unclear
    categorize as
    move to account
    delete
1. Make the all account view add/edit transactions work as intended
1. Editing a transaction shouldn't change the width of the table columns. Annoying.

## Transactions
1. No good error message if category isn't select (also it should be possible to create)
1. Store payees and info about them. Last Category and amount and others?
1. Recurring transactions
1. Transactions between accounts (with transaction fee support)
1. Remove transaction controller, move over methods from api transaction controller.

## Budget view
1. Should support adding/removing categories/groups
1. Support create/update
1. JS enabled budget view
    1. Everything should already be editable, just click and change.
1. The budget shouldn't automatically operate on all accounts but should be configurable
    Should be able to choose which categories/groups/accounts it's specific to
    Should be able to split the amount between budgets

## Accounts
1. Edit accounts
1. Should be in a specific currency

Should be able to automatically sync with external api's. (cryptos, banks)

## Investments Graphs/Repots
1. Generated for budgets?
1. Need to manually create a planned split given percentages
1. Need to create reports of shared expenses.
    Possibly ability to create customized filters for a report, which could track all tagged/split transactions.

## Misc
1. Add behavior/tests for cascading deletion
1. Graphs and shit
1. Login directly on homepage
1. Better register/landing page
1. Need a way to register debt/borrowing
1. Should be able to close flash with js
1. mix test for some reason isn't running import tests?!

coincap API <https://github.com/CoinCapDev/CoinCap.io>

# Phoenix

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

Test: tradet 123456

