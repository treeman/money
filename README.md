# MoneyTracker9000

I want to track my budget including investments and expenses. Instead of using any of the many already existing ones I figured I'd build my own, go figure. It's also an excuse for me to learn web dev with Elixir and Phoenix.

# TODO

1. Need to associate categories/budgets with a single user

## Transactions
1. Importer/Generator
1. JS enabled transaction view
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
1. Modify end-date to fix bug

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

coincap API <https://github.com/CoinCapDev/CoinCap.io>
