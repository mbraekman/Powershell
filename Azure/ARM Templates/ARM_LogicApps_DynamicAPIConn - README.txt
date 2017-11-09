This ARM template can be used to create a Logic App, which is capable of dynamically defining the API Connection that is be used.

Logic App-trigger:
	HTTP POST

Actions:
	Use Integration Account Lookup to get Partner-details
	Extract metadata from partner to define:
		- the name of the API Connection that is to be used.
		- the folder on the FTP (in this case) where the file needs to be stored.
	Send the message-body towards the FTP, using the dynamically defined API Connection.
