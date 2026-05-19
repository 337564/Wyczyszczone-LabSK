
Get_MAC () { # dev
  dev=$1
  ip -br link sho $dev | awk '{print $3}'		# e8:40:f2:ec:54:88
}

Set_MAC () { # dev mac
  dev=$1  mac=$2
  $E ip link set $dev down
  $E ip link set $dev address $mac
  $E ip link set $dev up
}

Change_MAC () { # dev
  Get
  dev=$1  mac=$2
  Get_MAC | sed 
} 
  #Save_MAC $dev e8:40:f2:ec:54:99
