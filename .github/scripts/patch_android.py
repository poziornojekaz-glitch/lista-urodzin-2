#!/usr/bin/env python3
"""Patch Android config for awesome_notifications."""
import re
from pathlib import Path

manifest_path = Path('android/app/src/main/AndroidManifest.xml')
content = manifest_path.read_text()

permissions = '''    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.INTERNET" />
'''

if 'SCHEDULE_EXACT_ALARM' not in content:
    content = content.replace('<application', permissions + '\n    <application', 1)

receivers = '''
        <receiver android:name="me.carda.awesome_notifications.core.receivers.NotificationActionReceiver" android:exported="false" />
        <receiver android:name="me.carda.awesome_notifications.core.receivers.ScheduledNotificationReceiver" android:exported="false" />
        <receiver android:name="me.carda.awesome_notifications.core.receivers.NotificationBootReceiver" android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
'''

if 'NotificationActionReceiver' not in content:
    content = content.replace('</application>', receivers + '\n    </application>', 1)

manifest_path.write_text(content)
print('AndroidManifest.xml patched.')

gradle_path = Path('android/app/build.gradle')
if gradle_path.exists():
    g = gradle_path.read_text()
    g = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 23', g)
    g = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 23', g)
    if 'coreLibraryDesugaringEnabled' not in g:
        if 'compileOptions {' in g:
            g = g.replace(
                'compileOptions {',
                'compileOptions {\n        coreLibraryDesugaringEnabled true\n        sourceCompatibility JavaVersion.VERSION_1_8\n        targetCompatibility JavaVersion.VERSION_1_8',
                1,
            )
        g = g.rstrip() + "\n\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'\n}\n"
        gradle_path.write_text(g)
        print('build.gradle patched.')

kts_path = Path('android/app/build.gradle.kts')
if kts_path.exists():
    k = kts_path.read_text()
    k = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 23', k)
    if 'coreLibraryDesugaringEnabled' not in k:
        k = k.replace(
            'compileOptions {',
            'compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n        sourceCompatibility = JavaVersion.VERSION_1_8\n        targetCompatibility = JavaVersion.VERSION_1_8',
            1,
        )
        k = k.rstrip() + '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")\n}\n'
        kts_path.write_text(k)
        print('build.gradle.kts patched.')

print('Done.')
