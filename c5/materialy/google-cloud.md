● Odpowiednikiem az (Azure CLI) dla Google Cloud jest gcloud — część pakietu Google Cloud CLI (dawniej Google Cloud SDK).

  Na Arch Linux instalujesz z oficjalnych repozytoriów:

  pacman -S google-cloud-cli

  Pakiet jest w repozytorium extra. Po instalacji autoryzujesz się przez:

  gcloud auth login
  gcloud config set project TWOJ_PROJECT_ID

  Kilka przydatnych analogii az → gcloud:

  ┌──────────────────────┬───────────────────────────────┐
  │      Azure CLI       │       Google Cloud CLI        │
  ├──────────────────────┼───────────────────────────────┤
  │ az login             │ gcloud auth login             │
  ├──────────────────────┼───────────────────────────────┤
  │ az account list      │ gcloud projects list          │
  ├──────────────────────┼───────────────────────────────┤
  │ az vm list           │ gcloud compute instances list │
  ├──────────────────────┼───────────────────────────────┤
  │ az group list        │ gcloud projects list          │
  ├──────────────────────┼───────────────────────────────┤
  │ az storage blob list │ gcloud storage ls             │
  └──────────────────────┴───────────────────────────────┘
