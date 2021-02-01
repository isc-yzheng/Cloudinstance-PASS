import config # contains constants
import services # methods that returns JWTs to be used to rend "save to phone" button
import uuid # std library for unique identifier generation
import irisnative

SAVE_LINK = "https://pay.google.com/gp/v/save/" # Save link that uses JWT. See https://developers.google.com/pay/passes/guides/get-started/implementing-the-api/save-to-google-pay#add-link-to-email

def demoSkinnyJwt(verticalType, classId, objectId):
  # Modify connection info based on your environment
 
  ip = "trak.australiasoutheast.cloudapp.azure.com"
  port = 1972
  namespace = "PASS"
  username = "_system"
  password = "trakcare"

  # create database connection and IRIS instance
  connection = irisnative.createConnection(ip,port,namespace,username,password)
  dbnative = irisnative.createIris(connection)

  print("Generates a signed skinny JWT.")
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


  skinnyJwt = services.makeSkinnyJwt(verticalType, classId, objectId, Globalname, Globalmrn, Globaldate, Globaldoctor, Globalhospital, Globalhospitalphone, Globalhospitaladdress, Globallocation, Globalservice)

  if skinnyJwt is not None:
    print('This is an "skinny" jwt:\n%s\n' % (skinnyJwt.decode('UTF-8')) )
    print('you can decode it with a tool to see the unsigned JWT representation:\n%s\n' % ('https://jwt.io') )
   
    print("[1. Setting and getting a global]")

    dbnative.set(SAVE_LINK+skinnyJwt.decode('UTF-8'), "PassLink")
    Globallink = dbnative.get("PassLink")

    print("The value of testglobal is ", Globallink)

  return

#############################
# RUNNER
# This script demonstrates using your services which make JWTs
# The JWTs are used to generate save links or JS Web buttons to save Pass(es)
#
# 1) Get credentials and check prerequisistes in: https://developers.google.com/pay/passes/samples/quickstart-python.
# 2) Modify config.py so the credentials are correct.
# 3) Try running it: python main.py . Check terminal output for server response, JWT, and save links.
#############################

verticalType = services.VerticalType.EVENTTICKET

# your classUid should be a hash based off of pass metadata, for the demo we will use pass-type_class_uniqueid
classUid = str(verticalType).split('.')[1] + '_CLASS_'+ str(uuid.uuid4()) # CHANGEME
# check Reference API for format of "id" (https://developers.google.com/pay/passes/reference/v1/o).
# must be alphanumeric characters, '.', '_', or '-'.
classId = '%s.%s' % (config.ISSUER_ID,classUid)

# your objectUid should be a hash based off of pass metadata, for the demo we will use pass-type_object_uniqueid
objectUid = str(verticalType).split('.')[1] + '_OBJECT_'+ str(uuid.uuid4()) # CHANGEME
# check Reference API for format of "id" (https://developers.google.com/pay/passes/reference/v1/).
# Must be alphanumeric characters, '.', '_', or '-'.
objectId = '%s.%s' % (config.ISSUER_ID,objectUid)

# demonstrate the different "services" that make links/values for frontend to render a functional "save to phone" button
#demoFatJwt(verticalType, classId, objectId)
#demoObjectJwt(verticalType, classId, objectId)
demoSkinnyJwt(verticalType, classId, objectId)
