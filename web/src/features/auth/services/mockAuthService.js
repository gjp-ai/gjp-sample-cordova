const MOCK_USERNAME = 'demo';
const MOCK_PASSWORD = 'demo';
const MOCK_DELAY_MS = 500;

export async function authenticateWithMock({ username, password }) {
    await new Promise((resolve) => window.setTimeout(resolve, MOCK_DELAY_MS));

    if (username.trim() !== MOCK_USERNAME || password !== MOCK_PASSWORD) {
        throw new Error('The username or password is incorrect.');
    }
}
