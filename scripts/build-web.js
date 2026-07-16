const { spawnSync } = require('node:child_process');
const path = require('node:path');

module.exports = function buildWeb(context) {
    const projectRoot = context.opts.projectRoot;
    const vite = path.join(projectRoot, 'node_modules/vite/bin/vite.js');
    const result = spawnSync(
        process.execPath,
        [vite, 'build', '--config', path.join(projectRoot, 'vite.config.js')],
        { cwd: projectRoot, stdio: 'inherit' }
    );

    if (result.error) {
        throw result.error;
    }

    if (result.status !== 0) {
        throw new Error(`React web build failed with exit code ${result.status}.`);
    }
};
