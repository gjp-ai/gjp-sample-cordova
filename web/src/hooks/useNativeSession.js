import { useCallback, useEffect, useState } from 'react';

export function useNativeSession() {
    const [available, setAvailable] = useState(Boolean(window.NativeSession));
    const [logoutError, setLogoutError] = useState('');

    useEffect(() => {
        const updateAvailability = () => setAvailable(Boolean(window.NativeSession));
        document.addEventListener('deviceready', updateAvailability, false);
        updateAvailability();
        return () => document.removeEventListener('deviceready', updateAvailability, false);
    }, []);

    const logout = useCallback(() => {
        setLogoutError('');
        window.NativeSession?.logout(null, (error) => {
            console.error('Native logout failed:', error);
            setLogoutError('Unable to log out. Please try again.');
        });
    }, []);

    return { available, logout, logoutError };
}
