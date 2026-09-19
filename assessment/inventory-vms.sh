#!/bin/bash
# inventory-vms.sh
# Connects to vCenter via govc and exports a VM inventory CSV
# Usage: ./assessment/inventory-vms.sh --vcenter <host> --output <file.csv>

set -euo pipefail

VCENTER=""
OUTPUT="vm-inventory.csv"

while [[ $# -gt 0 ]]; do
  case $1 in
    --vcenter) VCENTER="$2"; shift 2 ;;
    --output)  OUTPUT="$2";  shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$VCENTER" ]]; then
  echo "❌ --vcenter is required"
  exit 1
fi

export GOVC_URL="https://${VCENTER}"
export GOVC_INSECURE=1
export GOVC_USERNAME="${VSPHERE_USER:-administrator@vsphere.local}"
export GOVC_PASSWORD="${VSPHERE_PASSWORD}"

echo "🔍 Connecting to vCenter: $VCENTER"
echo "Name,PowerState,NumCPU,MemoryMB,GuestOS,IPAddress,Datastore,Notes" > "$OUTPUT"

govc find / -type m | while read -r vm; do
  info=$(govc vm.info -json "$vm" 2>/dev/null)
  name=$(echo "$info"        | jq -r '.VirtualMachines[0].Name // ""')
  power=$(echo "$info"       | jq -r '.VirtualMachines[0].Runtime.PowerState // ""')
  cpu=$(echo "$info"         | jq -r '.VirtualMachines[0].Config.Hardware.NumCPU // ""')
  mem=$(echo "$info"         | jq -r '.VirtualMachines[0].Config.Hardware.MemoryMB // ""')
  os=$(echo "$info"          | jq -r '.VirtualMachines[0].Config.GuestFullName // ""')
  ip=$(echo "$info"          | jq -r '.VirtualMachines[0].Guest.IpAddress // ""')
  ds=$(echo "$info"          | jq -r '.VirtualMachines[0].Config.DatastoreUrl[0].Name // ""')

  echo "$name,$power,$cpu,$mem,$os,$ip,$ds," >> "$OUTPUT"
done

echo "✅ Inventory saved to: $OUTPUT"
echo "📊 Total VMs: $(tail -n +2 $OUTPUT | wc -l)"