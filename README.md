# MoneyTracker9000

I want to track my budget including investments and expenses. Instead of using any of the many already existing ones I figured I'd build my own, go figure. It's also an excuse for me to learn web dev with Elixir and Phoenix.

# Vim

C-]     Jump to definition
C-t     Jump back

# TODO
1. Ajax transactions add/edit/remove
    1. Need to update balance of all transactions after the one just added
    1. Edit transactions inline in account view
    1. Deletion still reloads the page
1. Add/remove/edit categories

1. Prettier add transaction form
1. Better datetime selector
1. Ability to add a category via category dropdown
    1. Need to be able to add/select category group as well
1. Should be able to close flash with js
1. Table header should always be visible
1. Need autocomplete on payee as well

## Categories
1. Need to be able to create a category
1. Need to be able to delete/rename a category

## User
1. When new user is created need to seed categories
1. Need to associate categories/budgets with a single user

## Transactions
1. JS enabled transaction view
    1. Edit transactions needs to rebuild with forms and then conform with server
    1. Delete transaction directly from account view
1. Add/edit/new transaction support for the all account view

1. No good error message if category isn't select (also it should be possible to create)
1. Importer/Generator
1. Store payees and info about them. Last Category and amount and others?
1. Recurring transactions
1. Transactions between accounts (with transaction fee support)

## Accounts
1. Split amount -> inflow/outflow
1. Edit accounts
1. Add transaction must be tied to an account (form generation/default account)

Should be split up in budgeted/non-budgeted accounts. Or possibly generate several budgets? Hm.
This is where we can track our investments.
Allow us to track some things automatically. (cryptos)

## Budget view
1. Support create/update
1. Customized sort?
1. Need to specify currency
1. Need to support split budgets with another person/non-tracked account
1. JS enabled budget view
    1. Everything should already be editable, just click and change.
1. The budget shouldn't automatically operate on all accounts but should be configurable

## Investments Graphs/Repots
1. Possibly just use a non-budget account as a base
1. Need to manually create a planned split given percentages
1. Need to create reports of shared expenses.
    Possibly ability to create customized filters for a report, which could track all tagged/split transactions.

## Misc
1. Use a factory to generate test data. Find some library?
1. Add behavior/tests for cascading deletion
1. Graphs and shit
1. Need to support fraction (use integers) calculations
1. Login directly on homepage
1. Better register/landing page
1. Need a way to register debt/borrowing

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

