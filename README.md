# MoneyTracker9000

I want to track my budget including investments and expenses. Instead of using any of the many already existing ones I figured I'd build my own, go figure. It's also an excuse for me to learn web dev with Elixir and Phoenix.

# Vim

C-]     Jump to definition
C-t     Jump back

# TODO
1. Give budget view a little love
    1. Should be able to add/remove categories and groups
1. Minor stuff for account view

## Categories
1. UI for:
    1. Need to be able to create a category and groups
    1. Need to be able to delete/rename a category and groups
1. Should be able to create categories (and groups?) from the account view when adding transactions

## Import text
* In the future import using the api of banks, now just make a simple parser...

## Budget view
1. Should support adding/removing categories/groups
1. Support create/update
1. Alter budgeted amount
1. JS enabled budget view
    + Everything should already be editable, just click and change.
    + Checkbox support
1. Show info on the right side
1. The budget shouldn't automatically operate on all accounts but should be configurable
    Should be able to choose which categories/groups/accounts it's specific to
    Should be able to split the amount between budgets
1. Ability to hide certain categories
    Hidden setting should be remembered for new months
    How to view all categories?

## Account view
1. Add new fields for a transaction:
    (account)                           DONE
    outflow/inflow instead of amount
    'cleared'                           DONE
1. Show explicit cancel button during insert
    * Option to insert and continue to insert another transaction
1. Search/filter/sort
1. Checkbox handling
    + ability to change category for all selected
    + ability to clear/unclear all selected
1. Edit a transaction should reveal:
    + clear/unclear
    + categorize as
    + move to account
    + delete
1. Arrows on category/payees
1. Client side validation for inputs
    + Account matches existing accounts, not null
    + Date matches YYYY-MM-DD
    + Payee not null
    + Category matches existing categories, not null
    + Amount not null

## Transactions
1. Store payees and info about them. Last Category and amount and others?
1. Recurring transactions
1. Transactions between accounts (with transaction fee support)

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

