Class Simple.NewRestService Extends Ens.BusinessService
{

Method OnProcessInput(pInput As Ens.StringContainer, Output pOutput As %RegisteredObject) As %Status
{

	Set tSc = ..SendRequestSync("RestPassEmailOperation",pInput,.Response)

	$$$TRACE(Response.StringValue)

	$$$TRACE(tSc)

	Set pOutput = Response.StringValue

	Quit $$$OK
}

}
