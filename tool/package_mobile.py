"""Package portable Android/iOS Flutter source, excluding machine-local files."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parents[1]
output = root / 'dist' / 'NextGenYield-Flutter-Mobile.zip'
output.parent.mkdir(exist_ok=True)
root_files = ['README.md', 'pubspec.yaml', 'pubspec.lock',
              'analysis_options.yaml', '.gitignore', '.vscode/launch.json',
              'docs/mobile-preview.png']
folders = ['lib', 'assets', 'android', 'ios', 'test', 'tool']
excluded_parts = {'.gradle', 'build', '.dart_tool', '.symlinks', 'Pods',
                  'ephemeral', 'xcuserdata', '__pycache__'}
excluded_names = {'local.properties', 'Generated.xcconfig',
                  'flutter_export_environment.sh', 'GeneratedPluginRegistrant.java',
                  'GeneratedPluginRegistrant.h', 'GeneratedPluginRegistrant.m'}
paths = [root / p for p in root_files]
for folder in folders:
    paths.extend(p for p in (root / folder).rglob('*') if p.is_file()
                 and not excluded_parts.intersection(p.relative_to(root).parts)
                 and p.name not in excluded_names
                 and p.suffix not in {'.iml', '.jks', '.keystore', '.pyc'})
with ZipFile(output, 'w', ZIP_DEFLATED) as archive:
    for path in sorted(set(paths)):
        archive.write(path, 'nextgenyield/' + path.relative_to(root).as_posix())
with ZipFile(output) as archive:
    names = archive.namelist()
    assert archive.testzip() is None
    assert 'nextgenyield/lib/main.dart' in names
    assert 'nextgenyield/android/gradle/wrapper/gradle-wrapper.jar' in names
    assert 'nextgenyield/ios/Runner.xcodeproj/project.pbxproj' in names
    assert not any('/web/' in name or name.endswith('local.properties') for name in names)
print(f'{output}\n{len(names)} files; {output.stat().st_size:,} bytes; archive verified')
