Class Simple.RestEndPoint Extends %CSP.REST [ Language = objectscript ]
{

/// Author: Harshitha Acha - (harshitha.acha@intersystems.com)
///         (Michael) Yuanhao Zheng - (Yuanhao.Zheng@InterSystems.com / likeping13@gmail.com)
/// 		Sachin Malik - (Sachin.Malik@InterSystems.com)
///         (Quentin) Jianjie Yu - (Jianjie.Yu@InterSystems.com)
/// 
/// This is a REST API class which creates a REST end point to recieve requests from TrakCare.
/// The class method SendEMail() converts the recieved JSON object into a StringContainer and forwards to 
/// a business operation.
/// The URLMap defines the endpoint of the API. 
/// Further Settings to create REST endpoint are configured in Management portal under WebApplications.
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

}
