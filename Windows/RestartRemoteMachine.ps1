# Restart a machine remotely
Restart-Computer -ComputerName "server01" -credential "domain\user"
# in case of multiple machines
# Restart-Computer -ComputerName "server01", "server02", "server03"

# Shutdown a machine remotely
Stop-Computer -ComputerName "server01"