ssh-keygen -t ed25519 ; ssh-copy-id vol ; ssh vol grep $env:COMPUTERNAME .ssh/.authorized_keys
