import { navigationItems } from '../../navigation/navigationConfig';

export function Navigation({ className, activeTab, onSelect }) {
    return (
        <nav className={className} aria-label="Primary navigation">
            {navigationItems.map(({ id, label, icon: Icon }) => (
                <button
                    className={`navigation-item ${activeTab === id ? 'active' : ''}`}
                    type="button"
                    key={id}
                    aria-current={activeTab === id ? 'page' : undefined}
                    onClick={() => onSelect(id)}
                >
                    <Icon size={21} strokeWidth={2} />
                    <span>{label}</span>
                </button>
            ))}
        </nav>
    );
}

export function MobileNavigation(props) {
    return <Navigation className="mobile-navigation" {...props} />;
}
