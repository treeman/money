import MainView    from './main';
import AccountShowView from './account/show';
import BudgetShowView from './budget/show';

// Collection of specific view modules
const views = {
  AccountShowView,
  BudgetShowView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}

