/// This is an integration feature to send patient notifications when appointment is booked or changed
Class Region.TRAKREGION.FeatureHandler.PatientNotification Extends websys.UDFExt.Abstract
{

/// Send patient notification
ClassMethod PatientNotification() As %String
{
	set PatientID=$get(%request.Data("PatientID",1))
	if PatientID="" quit 1
	set apptId=%UDF.Id
	if apptId="" quit 1

	set apptData=$get(^RBAS(+apptId,+$piece(apptId,"||",2),"APPT",$piece(apptId,"||",3)))
	set patientName=##class(web.PAPerson).GetNameForDisplay(PatientID)
	set patientUrn=##class(web.PAPatMas).GetRegistration(PatientID)
	set patientEmail=$piece($get(^PAPER(PatientID,"PER",4)),"^",19) // PAPER_Email
	set patientPhone=$piece($get(^PAPER(PatientID,"PER",4)),"^",21) // PAPER_MobPhone
	set apptDate=##class(websys.Conversions).DateLogicalToHtml($piece($get(^RBAS(+apptId,+$piece(apptId,"||",2))),"^")) //AS_Date
	set apptTime=##class(websys.Conversions).TimeLogicalToHtml($piece($get(^RBAS(+apptId,+$piece(apptId,"||",2))),"^",4)) //AS_SessStartTime
	set Resource=##class(User.RBResource).%OpenId(+apptId)
	if Resource.RESCTPCPDR set doctor=Resource.RESCTPCPDR.CTPCPDesc
	if Resource.RESCTLOCDR,Resource.RESCTLOCDR.CTLOCHospitalDR {
		#dim Hospital as User.CTHospital = Resource.RESCTLOCDR.CTLOCHospitalDR
		set hospital=Hospital.HOSPDesc
		set hospitalPhone=Hospital.HOSPPhone
		set hospitalAddress=Hospital.HOSPAddress
		if Hospital.HOSPCity set hospitalAddress=hospitalAddress_" "_Hospital.HOSPCity.CTCITDesc
		if Hospital.HOSPState set hospitalAddress=hospitalAddress_" "_Hospital.HOSPState.CTSTTCode
		if Hospital.HOSPZipDR set hospitalAddress=hospitalAddress_" "_Hospital.HOSPZipDR.CTZIPCode
	}
	if Resource.RESCTLOCDR set location=Resource.RESCTLOCDR.CTLOCDesc
	set serviceId=$piece(apptData,"^",15) //APPT_RBCServ_DR
	set service=$piece($get(^RBC("SER", serviceId)),"^",6)

	set json={
		"Name":(patientName),
			"RegistrationNo":(patientUrn),
			"Email":(patientEmail),
			"Phone":(patientPhone),
			"Date":(apptDate_" "_apptTime),
			"Doctor": ($get(doctor)),
			"Hospital": ($get(hospital)),
			"HospitalPhone": ($get(hospitalPhone)),
			"HospitalAddress": ($get(hospitalAddress)),
			"Location": ($get(location)),
			"Service": (service)
	}
	
	set url=%UDF.FeatureParameters("zSSHPatientNotification","REST URL")
	set username=%UDF.FeatureParameters("zSSHPatientNotification","REST Username")
	set password=%UDF.FeatureParameters("zSSHPatientNotification","REST Password")
	set httpRequest=##class(%Net.HttpRequest).%New()
	set httpRequest.Username=username
	set httpRequest.Password=password
	do httpRequest.EntityBody.Write(json.%ToJSON())
	set server=$piece(url,"http://",2)
	set server=$piece(server,"/",1)
	if server[":" {
		set port=$piece(server,":",2)
		set server=$piece(server,":",1)
	} else {
		set port=80
	}
	set path="/"_$piece(url,"/",4,*)
	set httpRequest.Server=server
	set httpRequest.Port=port
	do httpRequest.Post(path)
	quit 1
}

/// Feature parameters
ClassMethod GetParams() As %List
{
	quit $listbuild("zSSHPatientNotification"
		,"Sends a patient notfifcation using external REST service"
		,$listbuild(
			$listbuild("REST URL","","%String"),
			$listbuild("REST Username","","%String"),
			$listbuild("REST Password","","%String")
		)
		,"Sends a patient notfifcation using external REST service"
		,"CDUI-199"
	)
}

/// Abstract method to register subscribers within the class<br/>
/// Classes that inherit from this class must override this method and implement calls to the Registerxxx functions<br/>
ClassMethod RegisterEntryPoints() As %Status
{
	#dim sc, status as %Status = $$$OK
	set sc = ..RegisterWithFeature("User.RBAppointment","OnSQLTrigger","##class("_$classname()_").PatientNotification()",..GetParams())
	set status = $$$ADDSC(status,sc)
	quit status
}

/// This Parameter is updated by Perforce
Parameter SrcVer = "$Id$";

}
