Class Simple.NewRestEmailOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

Property Adapter As EnsLib.EMail.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method SendSimpleEmail(pRequest As Ens.StringContainer, Output pResponse As Ens.StringContainer) As %Status
{
	set pResponse = ##class(Ens.StringContainer).%New()
	// Shows data in the Management portal under message viewer -> trace tab -> Full trace
	$$$TRACE(pRequest)

	$$$TRACE(pRequest.StringValue)

	//Convert JSON String to Dynamic object.
	Set Object = ##class(%DynamicObject).%FromJSON(pRequest.StringValue)

	$$$TRACE(Object)

	$$$TRACE(Object.Name)

	$$$TRACE(Object.Email)

	//Create and set wallet pass link here
	//Set walletLink = ""

	//Get info from object and create message
	Set Message = "Hello "_Object.Name_", your appointment is confirmed on "_Object.Date_". Please Click the following link to add pass to your google wallet."_Object.wallet

	//Create new %Net.MailMessage object which will have all the email data
	Set email=##class(%Net.MailMessage).%New()

    Do email.TextData.Write(Message)
    
    Set email.Subject= "Appointment Confirmation"

    // Add recipient from the JSON Object
    Set tSc = ..Adapter.AddRecipients(email,Object.Email)
    //simple case--do not check for failed recipients
    Set tSc=..Adapter.SendMail(email)
	//Check if email is sent successfully
    If $$$ISOK(tSc) { 
    	Set pResponse.StringValue = "Success.. Email sent!"
    }
    else {
		Set pResponse.StringValue = "Email send failed. Check trace for more information."
		
		Quit tSc //$$$ERROR($$$GeneralError,"General error occured."_tSc)
  	 }
	
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="Ens.StringContainer">
    <Method>SendSimpleEmail</Method>
  </MapItem>
</MapItems>
}

}
