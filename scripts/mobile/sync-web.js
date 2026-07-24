const { cpSync, existsSync, mkdirSync, readdirSync, rmSync } = require('node:fs');
const { spawnSync } = require('node:child_process');
const path = require('node:path');

const projectRoot = path.resolve(__dirname, '../..');
const webOutput = path.join(projectRoot, 'www');
const vite = path.join(projectRoot, 'node_modules/vite/bin/vite.js');
const destinations = [
    path.join(projectRoot, 'platforms/android/app/src/main/assets/www'),
    path.join(projectRoot, 'platforms/ios/www')
];
const protectedEntries = new Set(['cordova.js', 'cordova_plugins.js', 'plugins']);

const build = spawnSync(
    process.execPath,
    [vite, 'build', '--config', path.join(projectRoot, 'vite.config.js')],
    { cwd: projectRoot, stdio: 'inherit' }
);

if (build.error) {
    throw build.error;
}
if (build.status !== 0) {
    throw new Error(`React web build failed with exit code ${build.status}.`);
}

const webEntries = readdirSync(webOutput).filter(entry =>
    !protectedEntries.has(entry) && !entry.startsWith('.')
);
for (const destination of destinations) {
    mkdirSync(destination, { recursive: true });

    for (const entry of readdirSync(destination)) {
        if (!protectedEntries.has(entry)) {
            rmSync(path.join(destination, entry), { recursive: true, force: true });
        }
    }

    for (const entry of webEntries) {
        cpSync(
            path.join(webOutput, entry),
            path.join(destination, entry),
            { recursive: true }
        );
    }

    verifyCordovaRuntime(destination);
    process.stdout.write(`Synced web application to ${path.relative(projectRoot, destination)}\n`);
}

function verifyCordovaRuntime(destination) {
    const requiredFiles = [
        'cordova.js',
        'cordova_plugins.js',
        'plugins/com.ganjianping.native-session/www/nativeSession.js'
    ];
    for (const relativePath of requiredFiles) {
        if (!existsSync(path.join(destination, relativePath))) {
            throw new Error(
                `Required Cordova runtime file is missing from ${destination}: ${relativePath}`
            );
        }
    }
}
