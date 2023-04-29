# Quality Assurance

## Features to test before each release

### General
1. Review wording and look for typos.
2. Crash recovery.

### HealthKit
1. Test energy units and test that they update correctly.
2. Test without giving HealthKit permissions.

### Preferences
1. Test that MHR is correctly taken into account.
2. Test that the number of rounds is correctly taken into account.
3. Test that round duration impacts last stretch duration.
4. Test that duration validation is working…
	* … for the last stretch, which depends on the round duration.
	* … for the round duration.


### Workout
1. Test audio feedback:
	* with AirPods connected…
		* … and music playing.
		* … and no music playing.
		* … and silent mode switched on.
	* without AirPods connected…
		* … and silent mode switched off.
		* … and silent mode switched on.

2. Test haptic feedback:
	* with AirPods connected…
		* … and music playing.
		* … and no music playing.
		* … and silent mode switched on.
	* without AirPods connected…
		* … and silent mode switched off.
		* … and silent mode switched on.

3. Test both feedbacks:
	* with AirPods connected…
		* … and music playing.
		* … and no music playing.
		* … and silent mode switched on.
	* without AirPods connected…
		* … and silent mode switched off.
		* … and silent mode switched on.

4. Test pause/resume.
5. Test stop.
6. Test that the workout appears in Fitness.