# TailAdmin Vue.js Dashboard

#### Preview
 - [Demo](https://themewagon.github.io/tailadmin-vuejs/)

#### Download
 - [Download from ThemeWagon](https://themewagon.com/themes/tailadmin-vuejs/)


### Getting Started

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Docker (VPS/Produção)

Este repositório contém:

- `Dockerfile.web`: build do frontend (Vite) + Nginx servindo o `dist`
- `Dockerfile.api`: API Node/Express (`backend/server.js`)
- `docker-compose.yml`: modo "build no servidor" (ideal para Portainer Stack via Git)
- `docker-compose.prod.yml`: modo "pull de imagens" (ideal com GitHub Actions + GHCR)

### Opção A — Portainer / Stack via Git (recomendado se você quer "via link do GitHub")

1. No VPS, abra o Portainer → **Stacks** → **Add stack** → **Repository**.
2. Cole a URL do seu repositório e informe o caminho do compose: `docker-compose.yml`.
3. Configure as variáveis do stack (ou use um arquivo `.env` equivalente).
4. Deploy the stack.

### Opção B — Build e Push no GitHub Actions + Pull na VPS

1. O workflow [Build & Push Docker Images](.github/workflows/docker.yml) faz build e publica as imagens no **GHCR**:
	- `ghcr.io/<owner>/<repo>-web:main`
	- `ghcr.io/<owner>/<repo>-api:main`
2. No VPS, crie uma pasta (ex: `/opt/barberhub`) e copie para lá:
	- `docker-compose.prod.yml`
	- um `.env` baseado em `.env.example`
3. Suba com:

```bash
docker compose -f docker-compose.prod.yml up -d
```

Opcionalmente, você pode usar o workflow [Deploy to VPS](.github/workflows/deploy-vps.yml) (manual) com secrets:

- `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`
- `GHCR_PAT` (apenas se as imagens no GHCR estiverem privadas)

### Variáveis de ambiente

Use `.env.example` como base. Para produção, é importante definir pelo menos:

- `JWT_SECRET`
- `DB_*` (host/usuário/senha/nome)
- `GOOGLE_CLIENT_*`, `GOOGLE_REDIRECT_URI`, `GOOGLE_TOKEN_ENCRYPTION_KEY` (se usar Google Calendar)


## Author 
```
Design and code is completely written by TailAdmin and development team. 
```

## License

 - Design and Code is Copyright &copy; [TailAdmin](https://tailadmin.com/)
 - Licensed cover under [MIT]
 - Distributed by [ThemeWagon](https://themewagon.com)