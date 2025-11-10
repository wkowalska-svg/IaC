# Wdrażanie zmian Cloud Build

Krótki przewodnik dotyczący kroków wymaganych przed zastosowaniem konfiguracji Terraform dla Cloud Build.

## Wymagane kroki przed zastosowaniem Terraform

### 1. Utworzenie GitHub Token

Utworzyć GitHub Personal Access Token z następującymi uprawnieniami:

- `admin:public_key`
- `admin:repo_hook`
- `repo`
- `user`
- `workflow`

**Utworzenie tokenu:** https://github.com/settings/tokens

⚠️ **Zapisać wartość tokenu** - będzie potrzebna w kolejnym kroku.

### 2. Konfiguracja Google Cloud Build w GitHub Apps

1. Przejść do strony instalacji **Google Cloud Build GitHub App**: https://github.com/apps/google-cloud-build
2. Kliknąć **"Configure"** lub **"Install"**
3. Wybrać konto/organizację GitHub
4. Wybrać repozytorium do połączenia
5. Po instalacji, **zapisać Application ID** z URL:
   - Format URL: `https://github.com/settings/installations/XXXXXXXX`
   - Liczba na końcu to **Application ID** (Installation ID)

### 3. Uruchomienie skryptu bootstrap

Uruchomić skrypt bootstrap i przekazać GitHub token, gdy zostanie o niego zapytany:

```bash
scripts/bootstrap_all.sh <PROJECT_ID> [state-bucket-name] [region]
```

**Uwaga:** Przy każdym kolejnym uruchomieniu skryptu można zatwierdzić bez wpisywania tokenu (naciśnąć Enter).

### 4. Terraform Plan i Apply

Wykonać `terraform plan` i `terraform apply` z wymaganymi zmiennymi:

```bash
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Alternatywnie, utworzyć plik `terraform.tfvars` zgodnie ze wzorem `terraform.tfvars.example` i użyć go zamiast przekazywania zmiennych ręcznie.

**Wymagane zmienne:**

- `project_id`
- `vm_user_email`
- `github_repo_url`
- `state_bucket`
- `github_app_installation_id` (Application ID z kroku 2)
- `cloud_build_sa`

### 5. Utworzenie Pull Request

Po pomyślnym zastosowaniu konfiguracji Terraform:

1. Dodać jakiekolwiek zmiany do repozytorium
2. Utworzyć Pull Request do gałęzi `main` lub `master`
3. Cloud Build automatycznie uruchomi `terraform plan` dla PR

Po scaleniu PR, Cloud Build automatycznie wykona `terraform apply`.
