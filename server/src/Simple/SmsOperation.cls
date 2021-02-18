/// Author: Harshitha Acha, Harshitha.acha@intersystems.com
/// This calss is created to send HTTP GET requests to Telstra API
/// The Class implements SendSMS method which takes a parameter pRequest as Ens.StringContainer and
/// send SMS to the patient's mobile number given in the Object.
/// Settings like API endpoint, credentials are configured using production item settings
/// from front end. 
Class Simple.SmsOperation Extends Ens.BusinessOperation [ Language = objectscript ]
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// The alert notification
Method SendSMS(pRequest As Ens.StringContainer, Output pResponse As Ens.Response) As %Status
{
	set pResponse = ##class(Ens.StringContainer).%New()
	// Shows data in the Management portal under message viewer -> trace tab -> Full trace
	$$$TRACE(pRequest)
	$$$TRACE(pRequest.StringValue)

	//Convert JSON String to Dynamic object.
	Set Object = ##class(%DynamicObject).%FromJSON(pRequest.StringValue)
 set tSC = $$$OK
 try 
 {
  set txtmessage = "Hello "_Object.Name_", You have an appointment at "_Object.Hospital_" on "_Object.Date_ ". Click here for google wallet pass "_$GET(^PassLink)
  set destination = Object.Phone  
  set tSC = ..Adapter.Get(.pResponse,"destination,text",destination,txtmessage)
 }
 catch ex
 {
 set tSC = ex.AsStatus()
 }

 return tSC
}

XData MessageMap
{
<MapItems>
 <MapItem MessageType="Ens.StringContainer">
 <Method>SendSMS</Method>
 </MapItem>
 </MapItems>
}

}
