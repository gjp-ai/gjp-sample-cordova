import { useState } from 'react';
import { ArrowRight, Eye, EyeOff, LoaderCircle, LockKeyhole, UserRound } from 'lucide-react';
import './login.css';

export function LoginPage({ onLogin }) {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [passwordVisible, setPasswordVisible] = useState(false);
    const [error, setError] = useState('');
    const [submitting, setSubmitting] = useState(false);

    const submit = async (event) => {
        event.preventDefault();
        setError('');

        if (!username.trim() || !password) {
            setError('Enter your username and password.');
            return;
        }

        setSubmitting(true);
        try {
            await onLogin({ username, password });
        } catch (loginError) {
            setError(loginError.message || 'Unable to sign in. Please try again.');
            setSubmitting(false);
        }
    };

    return (
        <div className="login-page">
            <aside className="login-brand-panel" aria-label="Sample Finance">
                <img src={`${import.meta.env.BASE_URL}img/app-icon.png`} alt="" />
                <div>
                    <strong>Sample Finance</strong>
                    <p>Everyday banking, clearly organized.</p>
                </div>
            </aside>

            <main className="login-main">
                <section className="login-form-shell" aria-labelledby="login-title">
                    <div className="login-mobile-brand" aria-hidden="true">
                        <img src={`${import.meta.env.BASE_URL}img/app-icon.png`} alt="" />
                        <strong>Sample Finance</strong>
                    </div>
                    <p className="login-eyebrow">Welcome back</p>
                    <h1 id="login-title">Sign in</h1>
                    <p className="login-intro">Access your sample accounts and payments.</p>

                    <form className="login-form" onSubmit={submit} noValidate>
                        <label htmlFor="username">Username</label>
                        <div className="login-input-wrap">
                            <UserRound size={20} aria-hidden="true" />
                            <input
                                id="username"
                                name="username"
                                type="text"
                                value={username}
                                autoComplete="username"
                                autoCapitalize="none"
                                spellCheck="false"
                                disabled={submitting}
                                onChange={(event) => setUsername(event.target.value)}
                            />
                        </div>

                        <label htmlFor="password">Password</label>
                        <div className="login-input-wrap">
                            <LockKeyhole size={20} aria-hidden="true" />
                            <input
                                id="password"
                                name="password"
                                type={passwordVisible ? 'text' : 'password'}
                                value={password}
                                autoComplete="current-password"
                                disabled={submitting}
                                onChange={(event) => setPassword(event.target.value)}
                            />
                            <button
                                className="password-toggle"
                                type="button"
                                aria-label={passwordVisible ? 'Hide password' : 'Show password'}
                                disabled={submitting}
                                onClick={() => setPasswordVisible((visible) => !visible)}
                            >
                                {passwordVisible ? <EyeOff size={20} /> : <Eye size={20} />}
                            </button>
                        </div>

                        <div className="login-form-meta">
                            <span>Demo credentials: demo / demo</span>
                        </div>

                        {error && <p className="login-error" role="alert">{error}</p>}

                        <button className="login-submit" type="submit" disabled={submitting}>
                            {submitting ? <LoaderCircle className="login-spinner" size={20} /> : <ArrowRight size={20} />}
                            <span>{submitting ? 'Signing in...' : 'Sign in'}</span>
                        </button>
                    </form>
                    <p className="login-footer">Sample application - Version 1.0.0</p>
                </section>
            </main>
        </div>
    );
}
