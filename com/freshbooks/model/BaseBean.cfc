<cfcomponent output="false">
	
	<cffunction name="init" access="public" returntype="BaseBean" output="false">
		<cfset var item = "" />
		<cfif structCount(arguments) GT 0>
			<cfloop collection="#arguments#" item="item">
				<cfif (!structKeyExists(variables.instance, item) && arguments.createIfNotExists) || (structKeyExists(variables.instance, item))>
					<cfset variables.instance[item] = arguments[item] />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="onMissingMethod" output="false">
		<cfargument name="missingMethodName" type="string" />
		<cfargument name="missingMethodArguments" type="struct" />
		
		<cfset var property = "" />
		<cfset var value = "" />
		
		<cfif left(arguments.missingMethodName, 3) EQ "get">			
			<cfset property = replaceNoCase(arguments.missingMethodName, "get", "") />
			<cfif structKeyExists(variables.instance, property)>
				<cfreturn variables.instance[property] />
			<cfelse>
				<cfreturn "" />
			</cfif>

		<cfelseif left(arguments.missingMethodName, 3) EQ "set">			
			<cfset property = replaceNoCase(arguments.missingMethodName, "set", "") />
			
			<!--- assume only arg is value --->			
			<cfif NOT ListLen(structKeyList(arguments.missingMethodArguments))>
				<cfthrow type="baseModel.onMissingMethod" message="You must supply one and only one argument to this setter.  You have supplied #ListLen(structKeyList(arguments.missingMethodArguments))# arguments.">
			</cfif>
			
			<cfset value = arguments.missingMethodArguments[listFirst(structKeyList(arguments.missingMethodArguments))] />
			<cfset variables.instance[property] = value />

		<cfelse>			
			<cfthrow type="com.freshbooks.model.BaseBean" message="Method '#arguments.missingMethodName#' cannot be found." />		
		</cfif>	
	</cffunction>
	
	<cffunction name="getMemento" access="public" returntype="struct" output="false">
		<cfreturn duplicate(variables.instance) />
	</cffunction>
	
</cfcomponent>