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
		<cfargument name="xml" type="xml" required="true" />
		<cfargument name="debug" type="boolean" required="false" default="false" />
		
		<cfset var local = StructNew() />
		<cfset local.response = StructNew() />
		
		<cfxml variable="local.request" casesensitive="false">
		<request method="#arguments.method#">#trim(arguments.xml,false)#</request>
		</cfxml>
		
		<cfreturn local.response />
	</cffunction>
	
</cfcomponent>