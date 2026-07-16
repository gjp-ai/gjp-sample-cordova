import { ArrowLeftRight, Home, Menu, WalletCards } from 'lucide-react';

export const TAB_IDS = Object.freeze({
    home: 'home',
    accounts: 'accounts',
    pay: 'pay',
    more: 'more'
});

export const DEFAULT_TAB_ID = TAB_IDS.home;

export const navigationItems = Object.freeze([
    { id: TAB_IDS.home, label: 'Home', icon: Home },
    { id: TAB_IDS.accounts, label: 'Accounts', icon: WalletCards },
    { id: TAB_IDS.pay, label: 'Pay & Transfer', icon: ArrowLeftRight },
    { id: TAB_IDS.more, label: 'More', icon: Menu }
]);

export function getTabLabel(tabId) {
    return navigationItems.find((item) => item.id === tabId)?.label ?? 'Home';
}
