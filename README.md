# HyperVTools

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207+-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20Hyper--V-lightgrey)
![License](https://img.shields.io/badge/License-GPLv3-green)
![Status](https://img.shields.io/badge/Status-Active-success)

**HyperVTools** est un module PowerShell avancé permettant d’automatiser la création, la gestion et la configuration de machines virtuelles Hyper‑V.  
Il fournit une interface simple, cohérente et modulaire pour créer des VM, des vSwitch, des réseaux NAT, et bien plus.

---

## ✨ Fonctionnalités principales

- Création automatisée de VM Hyper‑V  
- Gestion multi‑disques (OS + data)  
- Création automatique de vSwitch (Internal / NAT)  
- Création de réseaux NAT Windows  
- Détection des vSwitch existants  
- Architecture modulaire (Public / Private)  
- Logging standardisé  
- Compatible PowerShell 5.1 et PowerShell 7+

---

## 📦 Installation

### 1. Cloner le dépôt

```powershell
git clone https://github.com/iFrenchies/HyperVTools.git

### 2. Importer le module
  Import-Module "HyperVTools\HyperVTools.psd1"

### 3. Vérifier les commandes disponibles
  Get-Command -Module HyperVTools

## 🚀 Exemple d’utilisation

Créer une VM avec vSwitch NAT automatique
  New-CustomVM `
      -Name "LAB-DC01" `
      -CPU 4 `
      -RAM 8192 `
      -Disks @(
          @{ Name="OS"; SizeGB=40 }
      ) `
      -AutoVSwitchType NAT `
      -AutoVSwitchSubnet "192.168.200.0/24" `
      -ISOPath "D:\ISO\WindowsServer.iso"

Créer un vSwitch interne
  New-CustomVSwitch -Name "vSwitch-LAB" -Type Internal

Lister les vSwitch disponibles
  Get-AvailableVSwitches

## 🧱 Architecture du module

HyperVTools\
│
├── HyperVTools.psd1          # Manifest du module
├── HyperVTools.psm1          # Assemblage des fonctions
│
├── Public\                   # Fonctions exportées
│   ├── New-CustomVM.ps1
│   ├── New-CustomVSwitch.ps1
│   ├── New-CustomNAT.ps1
│   ├── Get-AvailableVSwitches.ps1
│
└── Private\                  # Fonctions internes
    ├── Test-VMName.ps1
    ├── Test-VSwitchName.ps1
    └── Write-Log.ps1

## 🛠️ Dépendances
Windows 10/11 ou Windows Server avec Hyper‑V activé
PowerShell 5.1 ou PowerShell 7+
Module Hyper‑V installé
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

## 📬 Contact
Projet maintenu par Stéphane (iFrenchies)  
GitHub : https://github.com/iFrenchies/HyperVTools (github.com in Bing)
