<cfsetting showdebugoutput="false">
<!---
QuickTrack uses a CSV file for bug tracking. It is 100% not intended for production use, but rather, a quick 
way to generate some quick feedback that ends up in a CSV file that could be used later. Imagine, for example, 
a code base/site that has no proper JIRA setup and you are planning on spending the day recording notes and stuff.

This mini web app will let you do so and give you a nice CSV file at the end of the day.
--->

<!---
CONFIG:

* csvPath - name of csv file generated. 
* resolutionArr - array of resolution values
* statusArr - array of issue status values
* priorityArr - array of issue priority values
--->

<!---
The core page template. 
--->
<cfsavecontent variable="template">
<html>
<head>
<title>Quick Bug Tracker</title>
<link
  rel="stylesheet"
  media="(prefers-color-scheme:light)"
  href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.1/cdn/themes/light.css"
/>
<link
  rel="stylesheet"
  media="(prefers-color-scheme:dark)"
  href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.1/cdn/themes/dark.css"
  onload="document.documentElement.classList.add('sl-theme-dark');"
/>
<script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.1/cdn/shoelace-autoloader.js"></script>
<style>
body {
  font-family: Arial;  
  margin: 40px;
}

form {
	max-width: 700px;
}

sl-input, sl-textarea, sl-select {
	margin-bottom: 20px;
}

table {
	border-collapse: collapse;
	border: 1px solid white;
	width: 100%;
}

th, td {
	border: 1px solid white;
	padding: 5px; 
}

td.centered {
	text-align:center;
}

td.titleCell {
	width: 500px;
}

td.small {
	width: 25px;
}

td.medium {
	width: 100px;
}

</style>
</head>

<body>

	<h2><sl-icon-button name="house" label="Home" href="?"></sl-icon-button> Quick Bug Tracker</h2>

<!--CONTENT-->
</body>
</html>
</cfsavecontent>

<cfscript>
// config variables
csvPath = expandPath('./bugs.csv');
resolutionArr = ["FIXED", "WONTFIX"];
statusArr = ["OPEN", "CLOSED"];
priorityArr = ["LOW", "MEDIUM", "HIGH"];

headers = ["ID","Title","Description","Status","Priority","Resolution","Created","Updated"];

/* init the csv to help with header stuff */
if(!fileExists(csvPath)) {
	fileWrite(csvPath, headers.toList());
}

function header() {
	return template.listToArray('<!--CONTENT-->',true,true)[1];
}

function footer() {
	return template.listToArray('<!--CONTENT-->',true,true)[2];
}

function getIssue(required numeric id) {
	local.data = csvRead(filePath=csvPath,outputFormat="arrayOfStruct", csvFormatConfiguration={skipHeaderRecord:true, header:headers, ignoreHeaderCase:false});
	return local.data[local.data.find(i => i.ID == id)];
}

function getIssues() {
	return csvRead(filePath=csvPath,outputFormat="arrayOfStruct", csvFormatConfiguration={skipHeaderRecord:true, header:headers, ignoreHeaderCase:false});
}

function saveIssue(i) {
	local.data = getIssues();
	if(i.ID == "") {
		i.Created = dateTimeFormat(now());
		i.Updated = i.Created;
		i.ID = int(local.data.reduce((curr, i) => {
			if(i.ID > curr) return i.ID;
			return curr;
		},0) + 1);
		local.data.append(i);
	} else {
		oldIssue = local.data.find(issue => issue.ID == i.ID);
		i.Created = local.data[oldIssue].Created;
		i.Updated = dateTimeFormat(now());
		local.data[oldIssue] = i;
	}
	csvWrite(data, "arrayofStruct", csvPath, { header: headers });
}

param name="url.route" default="home";

data = getIssues();
</cfscript>


<cfoutput>#header()#</cfoutput>

<cfswitch expression="#url.route#">

	<cfcase value="home">
		<cfoutput>

		<cfif data.len() gt 0>
			<table>
			<thead>
			<tr>
				<th>ID</th></T><th>Title</th><th>Status</th><th>Priority</th><th>Resolution</th><th>Updated</th>
			</tr>
			</thead>
			<tbody>
			<cfloop item="i" array="#data#">
			<tr>
				<td class="centered small">#i.ID#</td>
				<td class="titleCell"><a href="?route=issue&id=#i.ID#">#i.Title#</a></td>
				<td class="centered medium">#i.Status#</td>
				<td class="centered medium">#i.Priority#</td>
				<td class="centered medium">#i.Resolution#</td>
				<td class="centered medium">#i.Updated#</td>
			</tr>
			</cfloop>
			</tbody>
			</table>
		<cfelse>
			<p>
			Congratulations! There are no issues! Everything is right and perfect the world... or is it?
			</p>
		</cfif>

		<p>
		<sl-button variant="primary" href="?route=issue"><sl-icon name="bug"></sl-icon> New Issue</sl-button>
		<sl-button variant="primary" href="?route=export"><sl-icon name="file-earmark-arrow-down"></sl-icon> Export CSV</sl-button>
		<sl-button variant="primary" href="?route=reports"><sl-icon name="file-bar-graph"></sl-icon> Reports</sl-button>
		</p>
		</cfoutput>
	</cfcase>

	<cfcase value="issue">

		<cfscript>

		if(url.keyExists("id") && url.id !== "") {
			issue = getIssue(url.id);
			param name="form.id" default=issue.ID;
			param name="form.title" default=issue.Title;
			param name="form.description" default=issue.Description;
			param name="form.status" default=issue.Status;
			param name="form.priority" default=issue.Priority;
			param name="form.resolution" default=issue.Resolution;
			form
		} else {
			param name="url.id" default="";
			param name="form.title" default="";
			param name="form.description" default="";
			param name="form.status" default="";
			param name="form.priority" default="";
			param name="form.resolution" default="";
		}

		// todo, validation, yolo
		if(form.keyExists("save")) {
			newIssue = ["ID":url.id, "Title":form.title, "Description":form.description, status:form.status, priority:form.priority, resolution:form.resolution ];
			saveIssue(newIssue);
			location(url="?");
		}

		if(url.keyExists("print")) {

			cfdocument(format="pdf") {
				writeOutput("<h2>Issue #url.id#: #form.title#</h2>");
				writeOutput("<p><strong>Status: </strong> #form.status#<br>");
				writeOutput("<strong>Priority: </strong> #form.priority#<br>");
				writeOutput("<strong>Resolution: </strong> #form.resolution#<br>");
				// I'm removing the ability to print new issues RAY TOMORROW keep this and edit button
				if(variables.keyExists("issue") && issue.keyExists("Created")) writeOutput("<strong>Created: </strong> #issue.Created#<br>");
				if(variables.keyExists("issue") && issue.keyExists("Updated")) writeOutput("<strong>Updated: </strong> #issue.Updated#</p>");

				writeOutput("<p>#form.description#</p>");
			}
		}
		</cfscript>

		<cfoutput>
		<form action="?route=issue&id=#url.id#" method="post" class="input-validation-required">

			<sl-input name="title" label="Title" value="#form.title#" required></sl-input>
			<sl-textarea name="description" label="Description" value="#form.description#" required resize="auto"></sl-textarea>

			<sl-select label="Status" name="status" value="#form.status#" required>
			<cfloop item="s" array="#statusArr#" >
				<sl-option value="#s#">#s#</sl-option>
			</cfloop>
			</sl-select>

			<sl-select label="Priority" name="priority" value="#form.priority#" required>
			<cfloop item="p" array="#priorityArr#">
				<sl-option value="#p#">#p#</sl-option>
			</cfloop>
			</sl-select>

			<sl-select label="Resolution" name="resolution" value="#form.resolution#" clearable>
			<cfloop item="r" array="#resolutionArr#">
				<sl-option value="#r#">#r#</sl-option>
			</cfloop>
			</sl-select>

			<cfif url.id != "">
				<p>
				This issue was created #issue.Created#.
				</p>
			</cfif>

			<sl-button href="?" variant="neutral">Cancel</sl-button>
			<sl-button variant="primary" name="print" href="?route=issue&id=#url.id#&print=true" target="_blank"><sl-icon name="file-pdf"></sl-icon> Print</sl-button>
			<sl-button type="submit" variant="primary" name="save"><sl-icon name="floppy"></sl-icon> Save</sl-button>
		</form>
		</cfoutput>	

	</cfcase>

	<cfcase value="export">
		<cfcontent file="#expandPath('./bugs.csv')#">
	</cfcase>

	<cfcase value="reports">

		<cfscript>
		// do some data magic voodoo
		statusValues = [:];
		for(s in statusArr) {
			statusValues[s] = data.reduce((curr,i) => {
				if(i.Status == s) curr++;
				return curr;
			},0);
		}

		priorityValues = [:];
		for(p in priorityArr) {
			priorityValues[p] = data.reduce((curr,i) => {
				if(i.Priority == p) curr++;
				return curr;
			},0);
		}

		resolutionValues = [:];
		for(r in resolutionArr) {
			resolutionValues[r] = data.reduce((curr,i) => {
				if(i.Resolution == r) curr++;
				return curr;
			},0);
		}

		</cfscript>

		<cfchartset format="html" layout="2x2" height="1000" width="1000" theme="vernal_dark">

			<cfchart type="ring">
				<cfchartseries seriesLabel="Issues By Status" >
					<cfloop item="s" collection="#statusValues#">
						<cfchartdata item="#s#" value="#statusValues[s]#">
					</cfloop>
				</cfchartseries>
			</cfchart>

			<cfchart type="ring">
				<cfchartseries seriesLabel="Issues By Priority">
					<cfloop item="p" collection="#priorityValues#">
						<cfchartdata item="#p#" value="#priorityValues[p]#">
					</cfloop>
				</cfchartseries>
			</cfchart>

			<cfchart type="ring">
				<cfchartseries seriesLabel="Issues By Resolution">
					<cfloop item="r" collection="#resolutionValues#">
						<cfchartdata item="#r#" value="#resolutionValues[r]#">
					</cfloop>
				</cfchartseries>
			</cfchart>

		</cfchartset>

	</cfcase>

</cfswitch>

<cfoutput>#footer()#</cfoutput>
