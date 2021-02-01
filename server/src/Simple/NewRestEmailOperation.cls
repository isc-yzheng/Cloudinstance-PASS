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

	//Set global to blank everytime
	Set ^PassLink = " "
	Set ^name = Object.Name
	Set ^email = Object.Email
	Set ^mrn = Object.RegistrationNo
	Set ^date = Object.Date
	Set ^doctor = Object.Doctor
	Set ^hospital = Object.Hospital
	Set ^hospitalphone = Object.HospitalPhone
	Set ^hospitaladdress = Object.HospitalAddress
	Set ^location = Object.Location
	Set ^service = Object.Service
	
	set args($i(args)) = "/irisdev/app/python/main.py" 

	//Call python script to create wallet link
	
	Set ret = ##class(Simple.ZFwrapper).RunCmd("python3.9",.args,.output)

	//SET ret = $ZF(-100,"/SHELL /LOGCMD /STDERR=error.txt ", "cmd /C C:/Python39/python.exe C:/Users/hacha/Downloads/passes-rest-samples-master/passes-rest-samples-master/python/main.py")
	
	If ( $$$ISERR(ret) || $GET(^PassLink) = " " )
	{
	$$$TRACE("Global Value:"_$GET(^PassLink))
	$$$TRACE("Error Message: "_output)
	Quit $$$ERROR($$$GeneralError, "Failed to generate google pass link, Email sent failed.")
	}

	$$$TRACE("Global Value:"_$GET(^PassLink))
	$$$TRACE("Status: "_ret)
    
	set args2($i(args2)) = "/irisdev/app/apple/main.py" 
    Set ret2 = ##class(Simple.ZFwrapper).RunCmd("python3.9",.args2,.output2)
	$$$TRACE("Status: "_ret2)

	//Get info from object and create message
	Set Message = "Hello <b>"_Object.Name_"</b>"

	//Create new %Net.MailMessage object which will have all the email data
	Set email=##class(%Net.MailMessage).%New()

    Do email.TextData.Write(Message)
    Do email.TextData.Write(",<br>Our Records show that you have an appointment on <b>"_Object.Date_"</b>")
    Do email.TextData.Write(" with <b>"_Object.Doctor_"</b>")
    Do email.TextData.Write(" at <b>"_Object.Hospital_", "_Object.Location_"</b>")
    Do email.TextData.Write(" in regards to <b>"_Object.Service_"</b>")
    Do email.TextData.Write(".<br>Please ensure that you bring all the required documents to your appointment.")
    Do email.TextData.Write("<br>To add your appointment to your <b>Google wallet</b>, Please click the following button.")
    Do email.TextData.Write("<table border=""0"" cellpadding=""0"" cellspacing=""0"" class=""btn btn-primary"" style=""border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%; box-sizing: border-box; min-width: 100% !important;"" width=""100%""> ")
    Do email.TextData.Write("<tr><td align=""center"" style=""font-family: sans-serif; font-size: 14px; vertical-align: top; padding-bottom: 15px;"" valign=""top"">")
    Do email.TextData.Write("<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: auto;""><tr>")
    Do email.TextData.Write("<td style=""font-family: sans-serif; font-size: 14px; vertical-align: top; background-color: #3498db; border-radius: 5px; text-align: center;"" valign=""top"" bgcolor=""#3498db"" align=""center""> ")
    Do email.TextData.Write("<a href="" "_$Get(^PassLink)_" ""target=""Blank"" style=""display: inline-block; color: #ffffff; background-color: #3498db; border: solid 1px #3498db; border-radius: 5px; box-sizing: border-box; cursor: pointer; text-decoration: none; font-size: 14px; font-weight: bold; margin: 0; padding: 12px 25px; text-transform: capitalize; border-color: #3498db;"">Add To Google Wallet</a> ")
    Do email.TextData.Write("</td></tr></table></td></tr></table>")
   	Do email.TextData.Write("To add your appointment to your <b>Apple wallet</b>, Please download the attached <b>apple.pkpass</b> file.")
   
    //Add attachment
	Do email.AttachFile("/irisdev/app/dur/mgr/PASS/","apple.pkpass")

    Set email.IsHTML = 1
    Set email.Subject= "Appointment Confirmation - "_Object.Date_" at "_Object.Hospital 

    // Add recipient from the JSON Object
    Set tSc = ..Adapter.AddRecipients(email,Object.Email)
    //simple case--do not check for failed recipients
    Set tSc=..Adapter.SendMail(email)
	//Check if email is sent successfully
    If $$$ISOK(tSc) { 
     Set pResponse.StringValue = "Success.. Email sent!"
    }
    else {
	Set pResponse.StringValue = "Email send failed."
   }
	Quit tSc
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
