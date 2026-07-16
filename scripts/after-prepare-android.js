const fs = require('node:fs');
const path = require('node:path');
const elementTree = require('elementtree');

const ANDROID_NAME = 'android:name';
const CONFIG_CHANGES = 'orientation|keyboardHidden|keyboard|screenSize|locale|smallestScreenSize|screenLayout|uiMode|navigation';
const SPLASH_ACTIVITY = 'com.ganjianping.sample.app.splash.SplashActivity';
const LOGIN_ACTIVITY = 'com.ganjianping.sample.app.login.LoginActivity';
const WEB_ACTIVITY = 'com.ganjianping.sample.app.web.WebViewActivity';

module.exports = function configureAndroidActivities(context) {
    if (!context.opts.platforms.includes('android')) {
        return;
    }

    const projectRoot = context.opts.projectRoot;
    restoreWebActivityPackage(projectRoot);

    const manifestPath = path.join(
        projectRoot,
        'platforms/android/app/src/main/AndroidManifest.xml'
    );
    const document = elementTree.parse(fs.readFileSync(manifestPath, 'utf8'));
    const application = document.find('./application');

    if (!application) {
        throw new Error(`Android application node not found in ${manifestPath}`);
    }

    const managedActivityNames = new Set([
        'MainActivity',
        '.MainActivity',
        'com.ganjianping.sample.MainActivity',
        SPLASH_ACTIVITY,
        LOGIN_ACTIVITY,
        WEB_ACTIVITY
    ]);

    application.findall('activity')
        .filter(activity => managedActivityNames.has(activity.get(ANDROID_NAME)))
        .forEach(activity => application.remove(activity));

    application.append(createSplashActivity());
    application.append(createLoginActivity());
    application.append(createWebActivity());

    fs.writeFileSync(manifestPath, document.write({ indent: 4 }), 'utf8');
};

function restoreWebActivityPackage(projectRoot) {
    const javaRoot = path.join(
        projectRoot,
        'platforms/android/app/src/main/java/com/ganjianping/sample'
    );
    const relocatedPath = path.join(javaRoot, 'WebViewActivity.java');

    if (!fs.existsSync(relocatedPath)) {
        return;
    }

    const featureDirectory = path.join(javaRoot, 'app/web');
    const featurePath = path.join(featureDirectory, 'WebViewActivity.java');
    const source = fs.readFileSync(relocatedPath, 'utf8').replace(
        /^package com\.ganjianping\.sample;$/m,
        'package com.ganjianping.sample.app.web;'
    );

    fs.mkdirSync(featureDirectory, { recursive: true });
    fs.writeFileSync(featurePath, source, 'utf8');
    fs.unlinkSync(relocatedPath);
}

function createActivity(name, theme) {
    const activity = new elementTree.Element('activity');
    activity.set('android:configChanges', CONFIG_CHANGES);
    activity.set('android:exported', 'false');
    activity.set(ANDROID_NAME, name);
    activity.set('android:theme', theme);
    return activity;
}

function createSplashActivity() {
    const activity = createActivity(SPLASH_ACTIVITY, '@style/Theme.App.SplashScreen');
    activity.set('android:exported', 'true');
    activity.set('android:label', '@string/activity_name');
    activity.set('android:launchMode', 'singleTop');

    const intentFilter = new elementTree.Element('intent-filter');
    intentFilter.set('android:label', '@string/launcher_name');

    const action = new elementTree.Element('action');
    action.set(ANDROID_NAME, 'android.intent.action.MAIN');
    intentFilter.append(action);

    const category = new elementTree.Element('category');
    category.set(ANDROID_NAME, 'android.intent.category.LAUNCHER');
    intentFilter.append(category);

    activity.append(intentFilter);
    return activity;
}

function createLoginActivity() {
    const activity = createActivity(LOGIN_ACTIVITY, '@style/Theme.Cordova.App.DayNight');
    activity.set('android:windowSoftInputMode', 'adjustResize');
    return activity;
}

function createWebActivity() {
    const activity = createActivity(WEB_ACTIVITY, '@style/Theme.Cordova.App.DayNight');
    activity.set('android:launchMode', 'singleTop');
    activity.set('android:windowSoftInputMode', 'adjustResize');
    return activity;
}
