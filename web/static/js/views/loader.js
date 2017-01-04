import MainView    from './main';
import AccountShowView from './account/show';

// Collection of specific view modules
const views = {
  AccountShowView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}

