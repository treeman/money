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
1. Need tests for rolling balance! Need to check for sort order as well!
1. Edit accounts
1. Add transaction must be tied to an account (form generation/default account)

Should be split up in budgeted/non-budgeted accounts.
This is where we can track our investments.
Allow us to track some things automatically. (cryptos)

## Budget view
1. Need test for summations!
1. Support create/update
1. Customized sort?

## Misc
1. Add behavior/tests for cascading deletion
1. Graphs and shit
1. Need to support fraction (use integers) calculations

