# 🔒 GUÍA DE CONFIGURACIÓN SEGURA - GEMINI API PROXY

## 📋 Paso 1: Generar Nueva API Key en Google Cloud

### Revocar la clave comprometida PRIMERO:
1. Ve a https://console.cloud.google.com/apis/credentials
2. Busca la API key `AIzaSyDBRklyr0qP-ILxzziXNiFvUmG4f8zFBPc`
3. Haz clic en los 3 puntos (⋮) y selecciona "Eliminar"
4. Confirma la eliminación

### Crear nueva API key:
1. En Google Cloud Console, haz clic en "+ CREATE CREDENTIALS"
2. Selecciona "API Key"
3. Copia la nueva key (ej: `AIzaSy...`)

### Restringir la key (IMPORTANTE para seguridad):
1. Haz clic en la clave recién creada
2. En "Application restrictions", selecciona "HTTP referrers (websites)"
3. Añade tus dominios:
   ```
   https://staffeliteperu.com/*
   https://www.staffeliteperu.com/*
   ```
4. En "API restrictions", selecciona "Generative Language API"
5. Haz clic en "Save"

## 📝 Paso 2: Configurar Variables de Entorno

### Opción A: En cPanel (RECOMENDADO)
1. Login a cPanel de tu hosting
2. Ve a "Software > Environment Variables" o busca "Env"
3. Crea nueva variable:
   - **Name:** `GEMINI_API_KEY`
   - **Value:** Tu nueva API key (ej: `AIzaSy...`)
4. Guarda

### Opción B: Editar archivo .env
1. Copia `.env.example` a `.env` en la raíz del proyecto
2. Edita `.env` y añade tu API key:
   ```
   GEMINI_API_KEY=AIzaSy...
   ```
3. **IMPORTANTE:** Asegúrate de que `.env` NO se suba a Git
4. Verifica que tu `.gitignore` incluya `.env`:
   ```
   .env
   .env.local
   ```

### Opción C: Plesk/DirectAdmin
1. Login a tu panel de control
2. Ve a "Domains > Tu Dominio > Environment Variables"
3. Crea:
   - **Key:** GEMINI_API_KEY
   - **Value:** Tu nueva API key
4. Aplica cambios

## 🔑 Paso 3: Verificar Configuración

### Testear que el proxy funciona:
1. Abre la consola del navegador (F12)
2. Ve a la página con la herramienta de IA
3. Describe un evento simple (5-10 palabras)
4. Haz clic en "Analizar"
5. Verifica en la consola:
   - **Si funciona:** verás respuesta JSON con el análisis
   - **Si falla:** verás error en la consola (ej: "API key no configurada")

### Si ves error "500 - API key de Gemini no configurada":
- Verifica que la variable de entorno está correctamente configurada
- En cPanel, recarga el dominio
- Intenta limpiar cache del navegador (Ctrl+Shift+Del)
- Espera 5 minutos (el servidor necesita reiniciar)

## 📊 Paso 4: Monitoreo

### Ver uso de tu API en Google Cloud:
1. Ve a https://console.cloud.google.com/apis/dashboard
2. Busca "Generative Language API"
3. Verifica "Quotas" para ver uso por día/minuto
4. Establece alertas si lo deseas

### Ver logs de requests en tu servidor:
- Los logs se guardan en: `/logs/gemini-api-YYYY-MM-DD.log`
- Contiene: timestamp, IP del cliente, estado, detalles
- Úsalos para detectar abuso o problemas

## 🛡️ Seguridad: Rate Limiting

El proxy limita a **20 requests por hora por IP**.

**Si recibes error "429 - Rate limit exceeded":**
- El usuario ha excedido el límite de 20 requests/hora
- El límite se resetea cada hora automáticamente
- Para aumentar el límite, edita `api/gemini-proxy.php` línea 10:
  ```php
  define('MAX_REQUESTS_PER_HOUR', 20); // Cambiar a 50, etc.
  ```

## ✅ Verificación Final

### Checklist antes de producción:
- [ ] API key vieja (`AIzaSyDBRklyr0qP...`) fue eliminada de Google Cloud
- [ ] Nueva API key creada y restringida a tu dominio
- [ ] Variable de entorno `GEMINI_API_KEY` configurada en el servidor
- [ ] Archivo `.env` NO está en Git (verificar `.gitignore`)
- [ ] Tested que el proxy funciona correctamente
- [ ] Logs en `/logs/` muestran requests exitosos
- [ ] CSP en `.htaccess` permite `/api/gemini-proxy.php`
- [ ] `.env` protegido en servidor (no públicamente accesible)

## 🆘 Troubleshooting

### Error: "CORS error" en la consola
→ Verifica que `.htaccess` en raíz incluya headers CORS para PHP
→ Reinicia Apache/servidor web

### Error: "429 Too Many Requests"
→ Cliente ha excedido 20 requests/hora
→ Aumenta `MAX_REQUESTS_PER_HOUR` en `api/gemini-proxy.php`

### Error: "API key no configurada"
→ Variable de entorno no está seteada correctamente
→ Verifica en cPanel o .env
→ Reinicia el dominio/servidor

### Error: "Invalid JSON response"
→ Gemini API cambió formato de respuesta
→ Verifica en Google Cloud Console si hay cambios
→ Contáctame para actualizar el parser

## 📚 Archivos Clave

```
/api/
├── gemini-proxy.php          ← Proxy seguro (con validaciones)
├── .htaccess                 ← Protecciones de seguridad
└── logs/                     ← Logs de requests (auto-creado)

/.env.example                 ← Plantilla de variables
/index.html                   ← Actualizado para usar proxy
/.htaccess                    ← Actualizado con CORS
```

## 🔄 Actualización Futura

Si Google cambio su API:
1. Actualiza el URL en `api/gemini-proxy.php` línea 130
2. Actualiza el request/response format si es necesario
3. Test antes de subir a producción

---

**Autor:** Security Audit  
**Fecha:** 2025-12-26  
**Status:** ✅ Implementado y Probado Localmente
