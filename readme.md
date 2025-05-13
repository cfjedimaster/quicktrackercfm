# QuickTracker.cfm

QuickTracker.cfm is simple 'drop and go' bug tracker system that is tied to a CSV file. It is absolutely, positively, 100% definitely not something that should be used in production, but rather, something to quickly generate a set of issue reports until a proper system (I'm looking at you, big ugly Jira) can be used instead. As the output of this system is a CSV file, it can be imported into another system at any time. 

By default, the file stored is named `bugs.csv`, but that can tweaked in the code to another name. Issues have the following properties:

* title (a simple name for the issue)
* description (a detailed note of the issue)
* status (either OPEN or CLOSED, and can be changed)
* priority (either LOW, MEDIUM, or HIGH, and can also be changed)
* resolution (either FIXED or WONTFIX, and ditto)

You can edit the three values (status, priority, and resolution) in the file itself:

```js
resolutionArr = ["FIXED", "WONTFIX"];
statusArr = ["OPEN", "CLOSED"];
priorityArr = ["LOW", "MEDIUM", "HIGH"];
```

## Installation

Copy `quicktracker.cfm` to your web root and open it in your browser. That's it.

The template makes use of multiple ColdFusion 2025 features so be sure you are running in that version.

## Release History

| Date | Description |
| ---- | ----------  |
| May 13, 2025 | Initial Release |
