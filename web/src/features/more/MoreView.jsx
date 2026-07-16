import { ChevronRight, LogOut } from 'lucide-react';
import { moreMenuItems } from '../../data/mockData';

export function MoreView({ nativeSession, nativeHost, onWebLogout }) {
    const logoutAvailable = !nativeHost || nativeSession.available;
    const logout = nativeHost ? nativeSession.logout : onWebLogout;

    return (
        <div className="more-layout">
            <section className="profile-summary">
                <span className="profile-avatar">JD</span>
                <div><strong>Jamie Doe</strong><p>Personal banking</p></div>
                <button className="icon-button bordered" type="button" aria-label="Open profile"><ChevronRight size={20} /></button>
            </section>
            <section className="content-section menu-section" aria-labelledby="more-menu-title">
                <h2 id="more-menu-title" className="sr-only">More options</h2>
                {moreMenuItems.map(({ label, icon: Icon }) => (
                    <button className="menu-row" type="button" key={label}>
                        <Icon size={21} /><span>{label}</span><ChevronRight size={19} />
                    </button>
                ))}
            </section>
            <button
                className="logout-button"
                type="button"
                disabled={!logoutAvailable}
                onClick={logout}
            >
                <LogOut size={20} />
                <span>{logoutAvailable ? 'Log out' : 'Log out unavailable'}</span>
            </button>
            {nativeSession.logoutError && <p className="error-message" role="alert">{nativeSession.logoutError}</p>}
            <p className="version-label">Sample Finance - Version 1.0.0</p>
        </div>
    );
}
