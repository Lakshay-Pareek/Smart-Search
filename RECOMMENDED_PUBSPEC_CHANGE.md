Add the following dependency to pubspec.yaml to enable sqflite ffi on desktop:

```yaml
dependencies:
  sqflite_common_ffi: ^2.0.0
```

Then run `flutter pub get`. You may prefer to add this under dev_dependencies if you only use it in desktop/testing environments, but adding to dependencies is the simplest for runtime support.
