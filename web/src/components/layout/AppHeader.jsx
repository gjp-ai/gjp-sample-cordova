import { Bell } from 'lucide-react';
import { Navigation } from './Navigation';

export function AppHeader({ activeTab, onSelect }) {
    return (
        <header className="app-header">
            <div className="header-inner">
                <div className="brand" aria-label="Sample Finance">
                    <img src={`${import.meta.env.BASE_URL}img/app-icon.png`} alt="" />
                    <span>Sample Finance</span>
                </div>
                <Navigation className="desktop-navigation" activeTab={activeTab} onSelect={onSelect} />
                <button className="icon-button header-action" type="button" aria-label="Notifications">
                    <Bell size={20} strokeWidth={2} />
                    <span className="notification-dot" />
                </button>
            </div>
        </header>
    );
}
