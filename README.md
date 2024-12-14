# Log8100-project

## Quelques points à savoir

Il s'agit d'une application OWASP dont la version originale se trouve ici:  https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application

l'installation et la configuration de l'image docker y sont expliqués.

## Requis

- Un compte Azure (dans notre cas)
- Un compte Docker
- `SonarQube Cloud`
- `Snyk`
- `Docker Scout`
- `Trivy`
- `minikube`
- `ansible`
- `terraform`
- `kubectl`

## Étapes du Pipeline CI/CD
# Pipeline d'intégration continue:
1. Analyse du code avec SonarCloud
2. Analyse des dépendances avec Snyk
3. Construire et push l'image de l'application
4. Analyse de l'image avec Docker Scout
5. Analyse de l'IaC avec Trivy
# Pipeline de déploiement continue:

## Installation de terraform

En utilisant la compilation à la source: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli 
```sh
git clone https://github.com/hashicorp/terraform
cd terraform
go install

##Pour vérrifier l'installation
terraform -help
```


## Installation ansible

```sh
##Installer  Windows Subsystem for Linux (WSL)
wsl --install
```
Après l'installation de wsl, un terminal ubuntu va se lancer. 

Il faut entrer les commandes suivante: 
```sh
## Update packages 
sudo apt update

## installation des préréquis: 
sudo apt install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt update

## installation de Ansible 

sudo apt install ansible -y
```

## Installation de Kubectl 

La documentation complète se trouve ici: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-kubectl-binary-on-windows-via-direct-download-or-curl 

1. téléchargement de Kubectl

```
curl.exe -LO "https://dl.k8s.io/release/v1.32.0/bin/windows/amd64/kubectl.exe"
curl.exe -LO "https://dl.k8s.io/v1.32.0/bin/windows/amd64/kubectl.exe.sha256"

```
2. Ensuite ajouter le fichier binaire dans votre  path

## Installation de minukube 

La documentation complète se trouve ici: https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download 

1. Installer minikube via le lien de la documentation 
2. Lancer la commande suivante pour s'assurer que l'installation a été complétée: 

`minikube start`

Cela va démarrer un cluster avec un seul noeud. 
## L'utilisation de Kubectl 

Il faudrait déjà avoir un cluster k8s et le configurer dans un fichier KUBECONFIG. nous avons utilisé un cluster dans Azure.

1. Se connecter à Azure 

`az login` 

2. configuer automatiquement kubeconfig 

`az aks get-credentials --resource-group <nom-du-groupe-de-ressources> --name <nom-du-cluster>`

3. Lancer ces commandes pour apercevoir vos noeuds en local. 

```sh
kubectl get nodes -o wide
kubectl get pods -A -o wide

```
