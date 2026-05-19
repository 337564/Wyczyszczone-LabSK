Odpowiedź z ChatGPT (do weryfikacji ;-) :

Q: My question will be about CLI installation of az package (Azure support) on Ubuntu totally without graphic (X-window) interface

A: To install the Azure CLI package on Ubuntu without a graphical interface, you can follow these steps:

1. Open a terminal on your Ubuntu system. You can do this by pressing Ctrl+Alt+T or searching for "Terminal" in the applications.

2. Update the package lists and upgrade any existing packages:
   ```bash
   sudo apt update
   sudo apt upgrade
   ```

3. Install the prerequisites for the Azure CLI:
   ```bash
   sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
   ```

4. Import the Microsoft repository GPG key:
   ```bash
   curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
   ```

5. Set up the Azure CLI repository:
   ```bash
   AZ_REPO=$(lsb_release -cs)
   echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
   ```

6. Update the package lists again:
   ```bash
   sudo apt update
   ```

7. Install the Azure CLI package:
   ```bash
   sudo apt install azure-cli
   ```

8. Verify the installation by checking the version of the Azure CLI:
   ```bash
   az --version
   ```

After following these steps, you should have the Azure CLI installed on your Ubuntu system without requiring a graphical interface. You can then use the `az` command to interact with Azure services from the command line.
