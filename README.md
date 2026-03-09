# NixOS Configuration

Este repositório contém a **configuração declarativa completa do sistema NixOS**.
A configuração foi estruturada para ser **modular, versionada e reproduzível**, utilizando **Nix Flakes**, **Home-Manager** e organização baseada em **profiles / roles / modules / hosts**.

O objetivo dessa estrutura é permitir:

* reconstruir o sistema inteiro a partir do repositório
* manter todas as configurações versionadas no Git
* reutilizar módulos em múltiplas máquinas
* facilitar manutenção e evolução do sistema

---

# Arquitetura do repositório

A estrutura do projeto segue o modelo modular comum em ambientes NixOS avançados.

```
nixos-config
├─ flake.nix
├─ flake.lock
├─ hosts
│  └─ pcdohu
│     ├─ configuration.nix
│     └─ hardware-configuration.nix
├─ profiles
│  ├─ base.nix
│  ├─ desktop.nix
│  └─ development.nix
├─ roles
│  ├─ workstation.nix
│  ├─ docker-host.nix
│  └─ virtualization.nix
├─ modules
│  ├─ desktop
│  │  └─ kde.nix
│  ├─ networking
│  │  └─ ssh.nix
│  └─ hardware
│     └─ optimizations.nix
├─ home
│  └─ huanderson.nix
└─ secrets
   └─ secrets.nix
```

---

# Conceitos da arquitetura

## Hosts

Representam **máquinas específicas**.

Exemplo:

```
hosts/pcdohu
```

Contém:

* hostname
* hardware
* configuração específica da máquina

---

## Profiles

Profiles definem **características gerais do sistema**.

Exemplos:

```
profiles/base.nix
profiles/desktop.nix
profiles/development.nix
```

Eles configuram coisas como:

* timezone
* rede
* pacotes base
* ambiente desktop

---

## Roles

Roles representam **funções da máquina**.

Exemplo:

```
roles/workstation.nix
roles/docker-host.nix
roles/virtualization.nix
```

Uma máquina pode combinar múltiplas roles.

---

## Modules

Modules são **componentes reutilizáveis de configuração**.

Exemplo:

```
modules/desktop/kde.nix
modules/networking/ssh.nix
modules/hardware/optimizations.nix
```

Eles encapsulam configurações específicas.

---

## Home Manager

Configura o **ambiente do usuário**.

Arquivo:

```
home/huanderson.nix
```

Controla:

* shell
* git
* ferramentas CLI
* dotfiles

---

# Arquivos importantes

## flake.nix

Define:

* dependências do sistema
* hosts disponíveis
* módulos utilizados

Ele é o **ponto de entrada do sistema**.

---

## flake.lock

Arquivo gerado automaticamente que fixa:

* versões de nixpkgs
* home-manager
* agenix

Este arquivo **deve ser versionado no Git**.

Ele garante que o sistema seja reconstruído exatamente igual no futuro.

---

## hardware-configuration.nix

Gerado automaticamente durante a instalação do NixOS.

Contém:

* módulos de kernel necessários
* configuração de discos
* partições
* UUIDs

**Não deve ser modificado manualmente**, exceto em mudanças de hardware.

---

# Fluxo de trabalho diário

## 1. Editar configurações

Exemplo:

```
nano modules/devtools.nix
```

ou

```
nano profiles/development.nix
```

---

## 2. Verificar build (sem aplicar)

Sempre teste antes de ativar:

```
sudo nixos-rebuild build --flake ~/nixos-config#pcdohu
```

Isso compila o sistema sem aplicá-lo.

---

## 3. Aplicar a nova configuração

Se o build funcionar:

```
sudo nixos-rebuild switch --flake ~/nixos-config#pcdohu
```

Isso:

* ativa nova geração
* atualiza serviços
* atualiza bootloader

---

## 4. Versionar mudanças

Depois de alterar configurações:

```
git add .
git commit -m "update system configuration"
git push
```

---

# Atualizar dependências

Para atualizar as versões do sistema:

```
nix flake update
```

Depois commit:

```
git add flake.lock
git commit -m "update flake dependencies"
```

---

# Recuperar sistema em outra máquina

Caso seja necessário reconstruir o sistema:

1. instalar NixOS
2. clonar o repositório

```
git clone <repo>
cd nixos-config
```

3. aplicar configuração

```
sudo nixos-rebuild switch --flake .#pcdohu
```

O sistema será reconstruído automaticamente.

---

# Arquivos que NÃO vão para o Git

Alguns arquivos são gerados localmente e não devem ser versionados.

Adicionar ao `.gitignore`:

```
result
```

A pasta `result` é apenas um link simbólico para builds do Nix.

---

# Boas práticas

* sempre testar com `nixos-rebuild build` antes de `switch`
* manter commits pequenos e descritivos
* versionar `flake.lock`
* nunca editar diretamente `/nix/store`
* manter módulos pequenos e reutilizáveis

---

# Comandos úteis

## Ver gerações do sistema

```
nixos-rebuild list-generations
```

---

## Voltar para geração anterior

Selecionar no menu de boot do NixOS.

---

## Limpar builds antigos

```
sudo nix-collect-garbage -d
```

---

# Objetivo da arquitetura

Essa estrutura permite transformar o sistema em **infraestrutura declarativa**.

Benefícios:

* sistema reproduzível
* configuração versionada
* fácil manutenção
* escalável para múltiplas máquinas

---

# Próximas evoluções possíveis

* integração com Kubernetes local
* gerenciamento de secrets com agenix
* ambientes dev com nix-shell
* monitoramento com Prometheus/Grafana
* storage avançado com BTRFS ou ZFS

---

# Autor

Configuração mantida por **Huanderson**.
