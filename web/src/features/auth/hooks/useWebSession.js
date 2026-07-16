import { useCallback, useEffect, useState } from 'react';
import { authenticateWithMock } from '../services/mockAuthService';

const SESSION_KEY = 'sample-finance.web-authenticated';

function readStoredSession() {
    try {
        return window.sessionStorage.getItem(SESSION_KEY) === 'true';
    } catch {
        return false;
    }
}

function writeStoredSession(authenticated) {
    try {
        if (authenticated) {
            window.sessionStorage.setItem(SESSION_KEY, 'true');
        } else {
            window.sessionStorage.removeItem(SESSION_KEY);
        }
    } catch {
        // The in-memory session still works when storage is unavailable.
    }
}

export function useWebSession() {
    const [nativeHost, setNativeHost] = useState(Boolean(window.cordova));
    const [authenticated, setAuthenticated] = useState(() => Boolean(window.cordova) || readStoredSession());

    useEffect(() => {
        const handleDeviceReady = () => {
            setNativeHost(true);
            setAuthenticated(true);
        };

        document.addEventListener('deviceready', handleDeviceReady, false);
        return () => document.removeEventListener('deviceready', handleDeviceReady, false);
    }, []);

    const login = useCallback(async (credentials) => {
        await authenticateWithMock(credentials);
        writeStoredSession(true);
        setAuthenticated(true);
    }, []);

    const logout = useCallback(() => {
        writeStoredSession(false);
        setAuthenticated(false);
    }, []);

    return { authenticated, login, logout, nativeHost };
}
