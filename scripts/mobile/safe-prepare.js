const { spawnSync } = require('node:child_process');
const path = require('node:path');

const projectRoot = path.resolve(__dirname, '../..');
const platform = process.argv[2];
const supportedPlatforms = new Set(['android', 'ios']);

if (!supportedPlatforms.has(platform)) {
    fail('Usage: node scripts/mobile/safe-prepare.js <android|ios>');
}

const initialStatus = git(['status', '--porcelain', '--untracked-files=all']);
if (initialStatus.trim()) {
    fail('Cordova preparation requires a clean working tree. Commit or stash all changes first.');
}

const branch = git(['branch', '--show-current']).trim();
if ((branch === 'main' || branch === 'master') && process.env.CORDOVA_PREPARE_ALLOW_MAIN !== '1') {
    fail(
        `Refusing to prepare ${platform} on ${branch}. Use a migration branch or set ` +
        'CORDOVA_PREPARE_ALLOW_MAIN=1 for an intentional exception.'
    );
}

const cordova = path.join(projectRoot, 'node_modules/.bin/cordova');
const preparation = spawnSync(cordova, ['prepare', platform], {
    cwd: projectRoot,
    encoding: 'utf8',
    stdio: 'inherit'
});
if (preparation.error) {
    throw preparation.error;
}
if (preparation.status !== 0) {
    fail(`Cordova prepare ${platform} failed with exit code ${preparation.status}.`);
}

const finalStatus = git(['status', '--porcelain', '--untracked-files=all']);
if (!finalStatus.trim()) {
    process.stdout.write(`Cordova prepare ${platform} completed without tracked changes.\n`);
    process.exit(0);
}

process.stdout.write('\nCordova preparation changed these files:\n');
process.stdout.write(finalStatus);

const protectedPrefixes = platform === 'android'
    ? [
        'platforms/android/app/src/main/java/com/ganjianping/sample/app/',
        'platforms/android/app/src/main/AndroidManifest.xml',
        'platforms/android/app/src/main/assets/app-settings.json',
        'platforms/android/app/src/main/assets/mock-responses/',
        'platforms/android/app/src/main/res/drawable/',
        'platforms/android/app/src/main/res/mipmap-',
        'platforms/android/app/src/main/res/values/cdv_colors.xml',
        'platforms/android/app/src/main/res/values/cdv_strings.xml',
        'platforms/android/app/src/main/res/values/cdv_themes.xml'
    ]
    : [
        'platforms/ios/App/App-Info.plist',
        'platforms/ios/App/AppDelegate.swift',
        'platforms/ios/App/Assets.xcassets/',
        'platforms/ios/App/Base.lproj/',
        'platforms/ios/App/Configuration/',
        'platforms/ios/App/Flow/',
        'platforms/ios/App/Login/',
        'platforms/ios/App/MainViewController.h',
        'platforms/ios/App/Network/',
        'platforms/ios/App/Resources/AppSettings.json',
        'platforms/ios/App/Resources/MockResponses/',
        'platforms/ios/App/Resources/SplashIcon.png',
        'platforms/ios/App/SceneDelegate.swift',
        'platforms/ios/App/Session/',
        'platforms/ios/App/Splash/',
        'platforms/ios/App/Web/'
    ];

const changedPaths = finalStatus
    .trim()
    .split('\n')
    .map(line => line.slice(3).split(' -> ').pop());
const protectedChanges = changedPaths.filter(changedPath =>
    protectedPrefixes.some(prefix => changedPath.startsWith(prefix))
);

if (protectedChanges.length > 0) {
    process.stderr.write('\nProtected native source changed unexpectedly:\n');
    protectedChanges.forEach(changedPath => process.stderr.write(`- ${changedPath}\n`));
    fail('Review and restore protected native changes before continuing.');
}

process.stdout.write(
    '\nPreparation completed. Review and commit the generated changes on this migration branch.\n'
);

function git(args) {
    const result = spawnSync('git', args, { cwd: projectRoot, encoding: 'utf8' });
    if (result.error) {
        throw result.error;
    }
    if (result.status !== 0) {
        fail(`git ${args.join(' ')} failed: ${result.stderr.trim()}`);
    }
    return result.stdout;
}

function fail(message) {
    process.stderr.write(`Error: ${message}\n`);
    process.exit(1);
}
