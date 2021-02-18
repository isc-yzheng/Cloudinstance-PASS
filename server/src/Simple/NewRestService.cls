/// Author: Harshitha Acha - (harshitha.acha@intersystems.com)
///         (Michael) Yuanhao Zheng - (Yuanhao.Zheng@InterSystems.com / likeping13@gmail.com)
/// 		Sachin Malik - (Sachin.Malik@InterSystems.com)
///         (Quentin) Jianjie Yu - (Jianjie.Yu@InterSystems.com)
/// 
/// This business service forwards the recieved JSON object to Email Operation and SMS operation
/// Both the requests are made Asynchronosly to make sure the operations don't hold TrakCare in waiting state for long.
Class Simple.NewRestService Extends Ens.BusinessService
{

Method OnProcessInput(pInput As Ens.StringContainer, Output pOutput As %RegisteredObject) As %Status
{
	//Send Async 
	Set tSc = ..SendRequestAsync("RestPassEmailOperation",pInput)
	$$$TRACE(tSc)
	Set pOutput = "Request Sent" //Response.StringValue

	Quit $$$OK
}

}
