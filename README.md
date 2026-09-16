# Azure Terraform Lab - Architecture Multi-Environnement

Ce projet déploie une infrastructure réseau et applicative sécurisée sur Microsoft Azure en utilisant **Terraform**. 
L'architecture suit une approche modulaire permettant de séparer de manière étanche les environnements de **Développement (Dev)** et de **Production (Prod)** tout en mutualisant le code source.

## 🏗️ Architecture Réseau & Sécurité

L'infrastructure implémente un modèle d'application à deux niveaux (*Two-Tier Architecture*) :

1. **Subnet Frontend (`subnet-frontend`)** :
   - Héberge la machine virtuelle Web publique (`WEB01`).
   - Accessible depuis Internet via les flux HTTP/HTTPS autorisés.

2. **Subnet Backend (`subnet-backend`)** :
   - Héberge la machine virtuelle applicative privée (`APP01`).
   - **Sécurité stricte** : Aucune IP publique. Les flux entrants (NSG) sont restreints exclusivement aux adresses IP provenant du sous-réseau Frontend sur le port `80`.
   - **Flux sortants sécurisés** : Intégration d'une **Azure NAT Gateway** avec IP publique dédiée pour permettre à la VM `APP01` d'initier des connexions sortantes (mises à jour, requêtes API) sans l'exposer aux attaques extérieures.

---

## 📁 Structure du Projet

```text
azure-terraform-lab/
├── .gitignore               # Fichiers exclus (State local, secrets .tfvars)
├── README.md                # Documentation du projet
├── modules/
│   └── app/                 # Code source de l'infrastructure mutualisée
│       ├── main.tf          # Déclaration des locals
│       ├── providers.tf     # Déclaration du provider azure
│       ├── versions.tf      # Déclaration de la version terraform
│       ├── vm_app01.tf      # Déclaration des ressources VM de app01
│       ├── vm_web01.tf      # Déclaration des ressources VM de web01
│       ├── vnet.tf          # Déclaration des vnet et subnet
│       ├── variables.tf     # Déclaration unique des variables du module
│       └── outputs.tf       # Exportation des données techniques (IPs, IDs)
│
├── dev/                  # Racine d'exécution pour l'environnement DEV
│   ├── main.tf           # Instanciation du module 'app' en mode dev
│   ├── terraform.tfstate # State stocké pour dev
│   └── terraform.tfvars  # Valeurs spécifiques (Secrets, Clé SSH, Sub ID)
|
└── prod/                 # Racine d'exécution pour l'environnement PROD
    ├── main.tf
│   ├── terraform.tfstate # State stocké pour prod 
    └── terraform.tfvars 
```

---

## ⚙️ Configuration & Bonnes Pratiques

### 1. Variables Globales et Constantes (`locals`)
Pour éviter le principe de duplication de code (DRY), la région Azure (`francecentral`), le Groupe de Ressources racine, ainsi que l'ID de l'apprenant sont centralisés dans le bloc `locals` à l'intérieur du fichier `modules/app/main.tf`.

### 2. Gestion des Balises (Tags)
Toutes les ressources cloud héritent automatiquement d'un bloc de balises communes (`common_tags`) défini de manière centralisée :
- `user` : ID de l'apprenant dynamique.
- `Project` : Nom du projet de formation.
- `Environment` : Évalué dynamiquement selon l'environnement (`dev` ou `prod`).
- `ManagedBy` : Toujours positionné sur `terraform`.

### 3. Sécurité du Fichier State
Le fichier `terraform.tfstate` contient des informations sensibles en texte brut (IP privées, configurations). **Il est strictement banni de Git** via le fichier `.gitignore`.

---

## 🚀 Guide de Déploiement

Pour déployer l'environnement de votre choix (exemple ici avec le dossier `dev`) :

1. Ouvrez votre terminal et positionnez-vous dans le dossier de l'environnement :
   ```powershell
   cd environments/dev
   ```

2. Initialisez les modules Terraform et les providers Azure :
   ```powershell
   terraform init
   ```

3. Validez la syntaxe et la cohérence de vos fichiers de configuration :
   ```powershell
   terraform validate
   ```

4. Générez et vérifiez le plan d'exécution pour inspecter les ressources qui vont être créées :
   ```powershell
   terraform plan
   ```

5. Appliquez les modifications pour provisionner l'infrastructure sur votre abonnement Azure :
   ```powershell
   terraform apply
   ```
