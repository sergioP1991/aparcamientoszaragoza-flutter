Stripe MCP (Model Context Protocol) - Instalación y ejecución

Este repositorio añade una entrada en `mcp.json` para ejecutar el MCP oficial de Stripe vía npx.

Requisitos
- Node.js/npm o npx disponible
- Cuenta y claves de Stripe (Secret Key)

Ejecutar localmente
1. Exportar la clave secreta de Stripe en el entorno (REEMPLAZA con tu clave):

```bash
export STRIPE_SECRET_KEY=sk_test_XXXXXXXXXXXXXXXXXXXXXXXX
```

2. Ejecutar el servidor MCP de Stripe usando npx:

```bash
npx @stripe/mcp@latest
```

Esto descargará y ejecutará el paquete `@stripe/mcp` temporalmente. Consulta la documentación oficial de Stripe MCP para opciones adicionales (puerto, logs, configuración de cuentas conectadas).

Notas
- Nunca comprometas tu `STRIPE_SECRET_KEY` en el repositorio.
- Para integración en CI, configura el secreto en los secretos del repositorio (GitHub Actions Secrets) y ajusta los pasos del workflow para ejecutar `npx @stripe/mcp@latest` si es necesario.

Referencia
- Documentación oficial: https://docs.stripe.com/mcp
