#!/usr/bin/env python

from passbook.models import Pass, Barcode, EventTicket, BarcodeFormat, Location
import irisnative

ip = "trak.australiasoutheast.cloudapp.azure.com"
port = 1972
namespace = "PASS"
username = "_system"
password = "trakcare"

# create database connection and IRIS instance
connection = irisnative.createConnection(ip,port,namespace,username,password)
dbnative = irisnative.createIris(connection)

# getting global values from IRIS]
Globalname = dbnative.get("name")
Globalmrn = dbnative.get("mrn")
Globalemail = dbnative.get("email")
Globaldate = dbnative.get("date")
Globaldoctor = dbnative.get("doctor")
Globalhospital = dbnative.get("hospital")
Globalhospitalphone = dbnative.get("hospitalphone")
Globalhospitaladdress = dbnative.get("hospitaladdress")
Globallocation = dbnative.get("location")
Globalservice = dbnative.get("service")

# Setting the fields
cardInfo = EventTicket()
cardInfo.addHeaderField('title', 'Appointment','')
cardInfo.addPrimaryField('name', Globalname, 'Patient Name')
cardInfo.addSecondaryField('date', Globaldate, 'Date')
cardInfo.addSecondaryField('hospital', Globalhospital, 'Hospital')
cardInfo.addAuxiliaryField('note', 'Add this card to your wallet and flip it for more details', 'Note')
cardInfo.addBackField('doctor', Globaldoctor, 'Doctor')
cardInfo.addBackField('service', Globalservice, 'Service')
cardInfo.addBackField('phone', Globalhospitalphone, 'Hospital Phone')
cardInfo.addBackField('address', Globalhospitaladdress, 'Hospital Address')
cardInfo.addBackField('location', Globallocation, 'Location')
cardInfo.addBackField('instruction', 'Bring your photo Id and other required documents with you.', 'Instruction')


organizationName = 'InterSystems'
passTypeIdentifier = 'pass.com.intersystems.trakcare.apptPassDemo'
teamIdentifier = '5HLUDG9M34'

passfile = Pass(cardInfo, \
    passTypeIdentifier=passTypeIdentifier, \
    organizationName=organizationName, \
    teamIdentifier=teamIdentifier)
passfile.description = "This is the appointment pass powered by InterSystems"
passfile.backgroundColor='#87CEFA'
passfile.foregroundColor='#000000'
passfile.labelColor='#000000'
#passfile.stripColor='#000000'
passfile.logoText= 'InterSystems'
passfile.serialNumber = '1234567'
passfile.barcode = Barcode(message = Globalmrn ,format=BarcodeFormat.PDF417)
passfile.locations = []
location = Location(-12.3559002,130.8807508)
passfile.locations.append(location)

# Including the icon and logo is necessary for the passbook to be valid.
passfile.addFile('icon.png', open('/irisdev/app/apple/test.pass/icon.png', 'rb'))
passfile.addFile('logo.png', open('/irisdev/app/apple/test.pass/logo.png', 'rb'))
#passfile.addFile('background.png', open('/irisdev/app/apple/test.pass/background.png', 'rb'))

# Create and output the Passbook file (.pkpass)
password = '123456'
passfile.create('/irisdev/app/apple/certs/certificate.pem', '/irisdev/app/apple/certs/private.key', '/irisdev/app/apple/certs/wwdr.pem', password , 'apple.pkpass')
