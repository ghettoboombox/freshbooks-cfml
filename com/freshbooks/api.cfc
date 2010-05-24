<cfcomponent output="false">
	
	<cffunction name="init" access="public" returntype="api" output="false">
		<cfargument name="serviceURL" type="string" required="true" />
		<cfargument name="authToken" type="string" required="true" />
		
		<cfset variables.serviceURL = arguments.serviceURL />
		<cfset variables.authToken = arguments.authToken />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="send" returntype="struct" access="private" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfargument name="request" type="string" required="true" />
		<cfargument name="debug" type="boolean" required="false" default="false" />
		
		<cfset var local = StructNew() />
		<cfset local.response = StructNew() />
		
		<cfxml variable="local.request" casesensitive="false">
		<cfoutput><request method="#arguments.method#">#trim(arguments.request)#</request></cfoutput>
		</cfxml>
		
		<cftry>
			<cfhttp url="#variables.serviceURL#" method="post" username="#variables.authToken#" password="x">
				<cfhttpparam name="request" value="#local.request#" type="body" />
			</cfhttp>
			
			<cfcatch>
				<cfthrow type="com.freshbooks.api" message="There was a problem communicating with Freshbooks." />
			</cfcatch>
		</cftry>
				
		<cfset local.response['xml'] = xmlParse(cfhttp.fileContent) />
		
		<cfif cfhttp.ResponseHeader.Status_Code NEQ 200>
			<cfthrow type="com.freshbooks.api" message="API Call Failed - Message: #local.response.xml.response.error.xmlText#" />
		</cfif>
		
		<cfif arguments.debug>
			<cfdump var="#cfhttp#"><cfabort>
		</cfif>
		
		<cfreturn local.response />
	</cffunction>
	
	<cffunction name="listProjects" access="public" returntype="struct" output="false">
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="perPage" type="numeric" required="false" default="15" />
		
		<cfset var local = StructNew() />
		
		<cfsavecontent variable="local.request">
		<cfoutput>
		<page>#arguments.page#</page>
		<per_page>#arguments.perPage#</per_page>
		</cfoutput>
		</cfsavecontent>
		
		<cfset local.response = send('project.list',local.request) />
		<cfset local.response['currentPage'] = local.response.xml.response.projects.xmlAttributes.page />
		<cfset local.response['totalPages'] = local.response.xml.response.projects.xmlAttributes.pages />
		<cfset local.response['total'] = local.response.xml.response.projects.xmlAttributes.total />
		<cfset local.response['perPage'] = local.response.xml.response.projects.xmlAttributes.per_page />
		<cfset local.response['collection'] = ArrayNew(1) />
		
		<cfloop from="1" to="#ArrayLen(local.response.xml.response.projects.project)#" index="local.i">
			<cfset local.project = local.response.xml.response.projects.project[local.i] />
			<cfset local.projectBean = CreateObject('component','com.freshbooks.model.ProjectBean').init() />
			<cfset local.projectBean.setID(local.project.project_id.xmlText) />
			<cfset local.projectBean.setName(local.project.name.xmlText) />
			<cfset local.projectBean.setDescription(local.project.description.xmlText) />
			<cfset local.projectBean.setRate(local.project.rate.xmlText) />
			<cfset local.projectBean.setBillMethod(local.project.bill_method.xmlText) />
			<cfset local.projectBean.setClientID(local.project.client_id.xmlText) />
			<cfset local.staff = ArrayNew(1) />
			<cfif ArrayLen(local.project.staff)>
				<cfloop from="1" to="#ArrayLen(local.project.staff)#" index="local.n">
					<cfset ArrayAppend(local.staff,local.project.staff[local.n].staff_id.xmlText) />
				</cfloop>
			</cfif>
			<cfset local.projectBean.setStaff(local.staff) />
			<cfset arrayAppend(local.response.collection,local.projectBean) />
		</cfloop>
		
		<cfreturn local.response />
	</cffunction>

	<cffunction name="listClients" access="public" returntype="struct" output="false">
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="perPage" type="numeric" required="false" default="15" />
		
		<cfset var local = StructNew() />
		
		<cfsavecontent variable="local.request">
		<cfoutput>
		<page>#arguments.page#</page>
		<per_page>#arguments.perPage#</per_page>
		</cfoutput>
		</cfsavecontent>
		
		<cfset local.response = send('client.list',local.request) />
		<cfset local.response['currentPage'] = local.response.xml.response.clients.xmlAttributes.page />
		<cfset local.response['totalPages'] = local.response.xml.response.clients.xmlAttributes.pages />
		<cfset local.response['total'] = local.response.xml.response.clients.xmlAttributes.total />
		<cfset local.response['perPage'] = local.response.xml.response.clients.xmlAttributes.per_page />
		<cfset local.response['collection'] = ArrayNew(1) />
		
		<cfloop from="1" to="#ArrayLen(local.response.xml.response.clients.client)#" index="local.i">
			<cfset local.client = local.response.xml.response.clients.client[local.i] />
			<cfset local.clientBean = CreateObject('component','com.freshbooks.model.ClientBean').init() />
			<cfset local.clientBean.setID(local.client.client_id.xmlText) />
			<cfset local.clientBean.setFirstName(local.client.first_name.xmlText) />
			<cfset local.clientBean.setLastName(local.client.last_name.xmlText) />
			<cfset local.clientBean.setOrganization(local.client.organization.xmlText) />
			<cfset local.clientBean.setEmail(local.client.email.xmlText) />
			<cfset local.clientBean.setWorkPhone(local.client.work_phone.xmlText) />
			<cfset local.clientBean.setHomePhone(local.client.home_phone.xmlText) />
			<cfset local.clientBean.setMobilePhone(local.client.mobile.xmlText) />
			<cfset local.clientBean.setFax(local.client.fax.xmlText) />
			<cfset local.clientBean.setVATName(local.client.vat_name.xmlText) />
			<cfset local.clientBean.setVATNumber(local.client.vat_number.xmlText) />
			<cfset local.clientBean.setStreet1(local.client.p_street1.xmlText) />
			<cfset local.clientBean.setStreet2(local.client.p_street2.xmlText) />
			<cfset local.clientBean.setCity(local.client.p_city.xmlText) />
			<cfset local.clientBean.setState(local.client.p_state.xmlText) />
			<cfset local.clientBean.setCode(local.client.p_code.xmlText) />
			<cfset local.clientBean.setCountry(local.client.p_country.xmlText) />
			<cfset local.credits = arrayNew(1) />
			<cfif ArrayLen(local.client.credits.credit)>
				<cfloop from="1" to="#ArrayLen(local.client.credits.credit)#" index="local.n">
					<cfset local.credit = StructNew() />
					<cfset local.credit['credit'] = local.client.credits.credit[local.n].xmlText />
					<cfset local.credit['currency'] = local.client.credits.credit[local.n].xmlAttributes.currency />
					<cfset ArrayAppend(local.credits,local.credit) />
				</cfloop>
			</cfif>
			<cfset local.clientBean.setCredits(local.credits) />
			<cfset local.clientBean.setUpdated(local.client.updated.xmlText) />
			<cfset ArrayAppend(local.response.collection,local.clientBean) />
		</cfloop>
		
		<cfreturn local.response />
	</cffunction>
	
	<cffunction name="createTimeEntry" access="public" returntype="numeric" output="false">
		<cfargument name="projectID" type="numeric" required="true" />
		<cfargument name="taskID" type="numeric" required="true" />
		<cfargument name="hours" type="numeric" required="true" />
		<cfargument name="date" type="date" required="true" />
		<cfargument name="notes" type="string" required="false" />
		
		<cfset var local = StructNew() />
		
		<cfsavecontent variable="local.request">
		<cfoutput>
		<time_entry>
			<project_id>#arguments.projectID#</project_id>
			<task_id>#arguments.taskID#</task_id>
			<hours>#arguments.hours#</hours>
			<cfif len(arguments.notes)>
				<notes>#XmlFormat(arguments.notes)#</notes>
			</cfif>
			<date>#dateFormat(arguments.date,'yyyy-mm-dd')#</date>
		</time_entry>
		</cfoutput>
		</cfsavecontent>
		
		<cfset local.response = send('time_entry.create',local.request) />
		
		<cfreturn local.response.xml.response.time_entry_id.xmlText />
	</cffunction>
	
	<cffunction name="listTasks" access="public" returntype="struct" output="false">
		<cfargument name="projectID" type="numeric" required="false" default="0" />
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="perPage" type="numeric" required="false" default="15" />
		
		<cfset var local = StructNew() />
		
		<cfsavecontent variable="local.request">
		<cfoutput>
		<cfif arguments.projectID>
			<project_id>#arguments.projectID#</project_id>
		</cfif>
		<cfif arguments.page AND arguments.perPage>
			<page>#arguments.page#</page>
			<per_page>#arguments.perPage#</per_page>
		</cfif>
		</cfoutput>
		</cfsavecontent>
		
		<cfset local.response = send('task.list',local.request) />
		
		<cfset local.response['currentPage'] = local.response.xml.response.tasks.xmlAttributes.page />
		<cfset local.response['totalPages'] = local.response.xml.response.tasks.xmlAttributes.pages />
		<cfset local.response['total'] = local.response.xml.response.tasks.xmlAttributes.total />
		<cfset local.response['perPage'] = local.response.xml.response.tasks.xmlAttributes.per_page />
		<cfset local.response['collection'] = ArrayNew(1) />
		
		<cfloop from="1" to="#ArrayLen(local.response.xml.response.tasks.task)#" index="local.i">
			<cfset local.task = local.response.xml.response.tasks.task[local.i] />
			<cfset local.taskBean = CreateObject('component','com.freshbooks.model.TaskBean').init() />
			<cfset local.taskBean.setID(local.task.task_id.xmlText) />
			<cfset local.taskBean.setName(local.task.name.xmlText) />
			<cfset local.taskBean.setDescription(local.task.description.xmlText) />
			<cfset local.taskBean.setIsBillable(local.task.billable.xmlText) />
			<cfset local.taskBean.setRate(local.task.rate.xmlText) />
			<cfset ArrayAppend(local.response.collection,local.taskBean) />
		</cfloop>
		
		<cfreturn local.response />
	</cffunction>
	
</cfcomponent>