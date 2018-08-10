Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
  Copyright 2018 The Android Open Source Project

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

# Compatibility WAL (Write-Ahead Logging) for Apps

Android {{ androidPVersionNumber }} introduces a special mode of
[SQLiteDatabase](https://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html){: .external}
called Compatibility WAL (write-ahead logging) that allows a database to use
`journal_mode=WAL` while preserving the behavior of keeping a maximum of one
connection per database.

Compatibility WAL is enabled for an application's database by default unless the
application has either:

1.  Opted-in or out of write-ahead logging by calling
    [`SQLiteDatabase.enableWriteAheadLogging`](https://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#enableWriteAheadLogging\(\)){: .external}
    or
    [`disableWriteAheadLogging`](https://developer.android.com/reference/android/database/sqlite/SQLiteDatabase.html#disableWriteAheadLogging\(\)){: .external}
1.  Explicitly requested journal mode by calling
    `SQLiteDatabase.OpenParams.setJournalMode(String mode)`

Enabling the WAL journal mode can lead to a significant improvement in
performance and reduction in the amount of writes. For example, on an ext4
filesystem, WAL can lead to a 4x improvement in write speed.

Compatibility WAL is enabled by default and doesn't require any additional
implementation.

Note: For applications using
[Room](https://developer.android.com/topic/libraries/architecture/room),
full write-ahead logging mode (not Compatibility WAL) is enabled by
default. This applies to devices running API 16 and higher and are not
categorized as a
[low memory device](https://developer.android.com/reference/android/app/ActivityManager.html#isLowRamDevice()). For more information, see
[`RoomDatabase.JournalMode AUTOMATIC`](https://developer.android.com/reference/androidx/room/RoomDatabase.JournalMode#AUTOMATIC).

## Disabling Compatibility WAL

To disable the Compatibility WAL mode, overlay the
[`db_compatibility_wal_supported`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml#1844){: .external}
config resource.

For example:

```
<bool name="db_compatibility_wal_supported">false</bool>
```

You may want to disable Compatibility WAL for configurations where the WAL
journal mode does not provide a performance advantage over traditional rollback
journal modes. For example, on a F2FS filesystem, although SQLite supports
atomic writes and the DELETE journal performance is similar to WAL, WAL can
increase the amount of writes by 10% to 15%.

## Validation

To validate the Compatibility WAL mode, run
[CTS tests](https://android.googlesource.com/platform/cts/+/master/tests/tests/database){: .external}
from the CtsDatabaseTestCases module. CTS tests will verify the expected
behavior when Compatibility WAL is enabled.

Note: CTS tests pass when the Compatibility WAL mode is disabled.
