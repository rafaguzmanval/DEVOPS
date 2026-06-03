#!/bin/bash

# ============================================================================
# generate-full-tsl.sh
# Genera un truststore con TODOS los certificados del TSL oficial.
# Uso: ./generate-full-tsl.sh [PASSWORD] [OUTPUT_FILE]
# ============================================================================

set -euo pipefail

# Parámetros y configuración
STORE_PASS="${1:-changeit}"
OUTPUT_FILE="${2:-truststore-full.p12}"
TSL_URL="https://sedediatid.digital.gob.es/Prestadores/TSL/TSL.xml"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Directorio temporal para procesamiento
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "🚀 Iniciando generación de truststore completo..."
echo "📥 Descargando TSL desde la fuente oficial..."

curl -s -L -k -f -A "$UA" "$TSL_URL" -o "$TEMP_DIR/TSL.xml" || {
    echo "❌ Error al descargar el TSL"; exit 1
}

echo "🔍 Extrayendo certificados..."
# Extraer contenido de las etiquetas X509Certificate (limpiando espacios)
perl -ne '
    while (/<X509Certificate>([^<]+)<\/X509Certificate>/g) {
        my $c = $1; $c =~ s/\s+//g;
        print "$c\n" if length($c) > 100;
    }
' "$TEMP_DIR/TSL.xml" > "$TEMP_DIR/certs.txt"

COUNT=$(wc -l < "$TEMP_DIR/certs.txt")
[ "$COUNT" -eq 0 ] && { echo "⚠️ No se encontraron certificados"; exit 1; }

echo "📜 $COUNT certificados encontrados. Importando..."

# Eliminar archivo de salida si existe para evitar conflictos de alias
rm -f "$OUTPUT_FILE"

IMPORTED=0
while IFS= read -r cert_b64; do
    [ -z "$cert_b64" ] && continue
    
    # Crear archivo PEM temporal
    {
        echo "-----BEGIN CERTIFICATE-----"
        echo "$cert_b64" | fold -w 64
        echo "-----END CERTIFICATE-----"
    } > "$TEMP_DIR/cert.pem"

    # Intentar obtener el Common Name para el alias
    CN=$(openssl x509 -noout -subject -in "$TEMP_DIR/cert.pem" 2>/dev/null | sed -n '/^subject/s/^.*CN\s*=\s*\([^,]*\).*$/\1/p' | head -n 1 | tr -cd '[:alnum:]_' | cut -c1-50)
    ALIAS="${CN:-cert}_${IMPORTED}"

    # Importar al keystore
    if keytool -import -alias "$ALIAS" -file "$TEMP_DIR/cert.pem" \
        -keystore "$OUTPUT_FILE" -storepass "$STORE_PASS" \
        -storetype PKCS12 -noprompt 2>/dev/null; then
        let IMPORTED=IMPORTED+1
        # Mostrar progreso simple cada 50 certs
        if (( IMPORTED % 50 == 0 )); then echo "  ... $IMPORTED procesados"; fi
    fi
done < "$TEMP_DIR/certs.txt"

echo "----------------------------------------------------------"
echo "✅ Proceso finalizado"
echo "📦 Archivo: $OUTPUT_FILE"
echo "🔑 Password: $STORE_PASS"
echo "📜 Total importados: $IMPORTED"
echo "----------------------------------------------------------"
