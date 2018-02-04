import sys
from Registry import Registry

reg = Registry.Registry(sys.argv[1])

interfaces = reg.open("ControlSet001\\Control\\Class\\{4D36E972-E325-11CE-BFC1-08002bE10318}")

physicalInterfaces=[]

for interface in interfaces.subkeys():
	for property in interface.values():
		if property.name()=="BusType": physicalInterfaces.append(interface)

if ( len(physicalInterfaces) != 2):
	print("\nPlease select one of the network interfaces found:\n")
	for index, physicalInterface in enumerate(physicalInterfaces):
		print("%d - %s" % (index,physicalInterface.value("DriverDesc").value()))
	
	print("\nEnter the number numer of the interface and press enter: ")
	chosen = int(sys.stdin.read(1))
else:
	chosen = 0

setupInfoKey = reg.open("ControlSet001\\Services\\Tcpip\\Parameters\\Interfaces\\"+physicalInterfaces[chosen].value("NetCfgInstanceId").value())

setupInfo = {
	"IPAddress":setupInfoKey.value("IPAddress").value()[0],
        "domain":setupInfoKey.value("Domain").value(),
        "defaultGateway":setupInfoKey.value("DefaultGateway").value()[0],
	"subnetMask":setupInfoKey.value("SubnetMask").value()[0],
	"dns":setupInfoKey.value("NameServer").value()
}

interfacesFile = open('/etc/network/interfaces','w')
interfacesFile.write("iface "+sys.argv[2]+" inet static\n")
interfacesFile.write("\taddress "+setupInfo['IPAddress'])
interfacesFile.write("\tnetmask "+setupInfo['subnetMask'])
interfacesFile.write("\tgateway "+setupInfo['defaultGateway'])

