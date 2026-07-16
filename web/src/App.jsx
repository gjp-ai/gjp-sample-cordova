import { useState } from 'react';
import { AppHeader } from './components/layout/AppHeader';
import { MobileNavigation } from './components/layout/Navigation';
import { AccountsView } from './features/accounts/AccountsView';
import { LoginPage } from './features/auth/LoginPage';
import { useWebSession } from './features/auth/hooks/useWebSession';
import { HomeView } from './features/home/HomeView';
import { MoreView } from './features/more/MoreView';
import { PayView } from './features/pay/PayView';
import { useNativeSession } from './hooks/useNativeSession';
import { DEFAULT_TAB_ID, getTabLabel, TAB_IDS } from './navigation/navigationConfig';

function App() {
    const [activeTab, setActiveTab] = useState(DEFAULT_TAB_ID);
    const nativeSession = useNativeSession();
    const webSession = useWebSession();

    const selectTab = (tabId) => {
        setActiveTab(tabId);
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    if (!webSession.authenticated) {
        return <LoginPage onLogin={webSession.login} />;
    }

    return (
        <div className="app-shell">
            <AppHeader activeTab={activeTab} onSelect={selectTab} />
            <main className="main-content" id="main-content">
                <div className="page-heading">
                    <p className="eyebrow">Sample Finance</p>
                    <h1>{getTabLabel(activeTab)}</h1>
                </div>
                {activeTab === TAB_IDS.home && <HomeView onNavigate={selectTab} />}
                {activeTab === TAB_IDS.accounts && <AccountsView />}
                {activeTab === TAB_IDS.pay && <PayView />}
                {activeTab === TAB_IDS.more && (
                    <MoreView
                        nativeSession={nativeSession}
                        nativeHost={webSession.nativeHost}
                        onWebLogout={webSession.logout}
                    />
                )}
            </main>
            <MobileNavigation activeTab={activeTab} onSelect={selectTab} />
        </div>
    );
}

export default App;
