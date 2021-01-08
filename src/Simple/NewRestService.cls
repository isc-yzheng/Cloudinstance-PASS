Class Simple.NewRestService Extends (%CSP.REST, Ens.BusinessService)
{

XData UrlMap
{
<Routes>
<Route Url="/SendEmail" Method="POST" Call="SendEmail"/>
</Routes>
}

ClassMethod SendEmail() As %Status
{
	//Read JSON string into variable.
	Set Data = %request.Content.Read()

	//Create a persistent object of Ens.StringContainer
	Set Object = ##class(Ens.StringContainer).%New()

	//Assign JSON string data to Object.Stringvalue property
	Set Object.StringValue= Data

	//Create an object of business service
	set tSc = ##class(Ens.Director).CreateBusinessService("RestPassService",.tService)

	//Send Object data to OnProcessInput method of the business service
	set tSc = tService.OnProcessInput(Object,.Output)
	If ($$$ISERR(tSc)) Quit tSC

	Write Output

	Quit $$$OK
}

Method OnProcessInput(pInput As Ens.StringContainer, Output pOutput As %RegisteredObject) As %Status
{

	Set tSc = ..SendRequestSync("RestPassEmailOperation",pInput,.Response)
	
	If $$$ISERR(tSc)
	{
		Set pOutput = "Email Send Failed with error. Check trace for more information."
	} else {
	
	$$$TRACE(Response.StringValue)

	$$$TRACE(tSc)

	Set pOutput = Response.StringValue
		
	}
	
	Quit $$$OK
}

}
