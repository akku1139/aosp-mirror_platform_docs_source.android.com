Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
  Copyright 2019 The Android Open Source Project

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

# Automatic Test Retry

A test might fail for any reason, and sometimes simply re-running the test is
enough to make it pass again (due to flakiness, such as from issues in the
underlying infrastructure). You can configure Tradefed to conduct the retry
automatically.

The core of auto-retry is to avoid re-running **all** of the tests; it re-runs
only the failed tests, resulting in large savings in execution time.

Tradefed also supports running tests multiple times in order to detect
flakiness via the **iterations** feature. In this case, all tests will be
re-run, and the test will fail if any of the iterations fail.

## Enabling the feature

The automatic retry is controlled via the
[RetryDecision object](https://android.googlesource.com/platform/tools/tradefederation/+/master/src/com/android/tradefed/retry/BaseRetryDecision.java)
which provides two options to enable the feature: `max-testcase-run-count`
and `retry-strategy`.

`max-testcase-run-count` drives the number of retries or iterations that will
be attempted. It sets an upper bound to avoid retrying forever.
`retry-strategy` drives the decision of how to retry; see the following sections
for more details.

## Retrying failures

To retry test failures, use the following options:

```shell
--retry-strategy RETRY_ANY_FAILURE --max-testcase-run-count X
```

This will retry the failure until it passes or until the max number of retries
is reached, whichever comes first.

## Iterations

To re-run tests for a number of time, the following options can be used:

```shell
--retry-strategy ITERATIONS --max-testcase-run-count X
```

## What do the results look like?

Result reporters by default will receive aggregated results of all attempts.

For example: a `Fail` and a `Pass` for `RETRY_ANY_FAILURE` will result in an
aggregated `Pass` since the retry managed to clear the failure.

It is possible for reporters to receive the non-aggregated results. To do so,
they need to extend the
[ISupportGranularResults interface](https://android.googlesource.com/platform/tools/tradefederation/+/master/src/com/android/tradefed/result/retry/ISupportGranularResults.java)
that declares support for the granular (non-aggregated) results.
