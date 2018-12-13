[![](https://travis-ci.org/grigorye/GELeaks.svg?branch=master)](https://travis-ci.org/grigorye/GELeaks)
[![](https://codecov.io/gh/grigorye/GELeaks/branch/master/graph/badge.svg)](https://codecov.io/gh/grigorye/GELeaks)

# GELeaks

Seamless leak detection for unit tests.

# Why

Laziness. Excersizing for memory leaks is boring. There're some naive ways to excersize any black box for memory leaks. Unit tests are already there.

If we can treat a test case as a black box, we can apply the naive ways to excersize it for memory leaks. Automate it.

# Usage

Add pod to test target (Podfile) or to test_spec subspec (podspec). Run the tests. Get leaks reported.

# Third Parties Used

- [FBAllocationTracker](https://github.com/facebook/FBAllocationTracker)
