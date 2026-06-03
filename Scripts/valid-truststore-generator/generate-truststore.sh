#!/bin/bash

# ============================================================================
# generate-truststore.sh
# Genera archivos truststore.p12 a partir del TSL (Trust Service List)
# ============================================================================

set -euo pipefail

# Configuración por defecto
TSL_URL="https://sedediatid.digital.gob.es/Prestadores/TSL/TSL.xml"
SHA_URL="https://sedediatid.digital.gob.es/Prestadores/TSL/TSL.sha2"

TSL_FILE="TSL.xml"
SHA_FILE="TSL.sha2"
STORE_PASS="changeit"
OUTPUT_FILE="./truststore.p12"
PROVIDER="FNMT-RCM"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ============================================================================
# Funciones auxiliares
# ============================================================================

usage() {
    cat <<EOF
Uso: $0 [OPCIONES]

Opciones:
  --all                Genera un truststore con TODOS los certificados del TSL
  --provider NOMBRE    Proveedor a extraer (por defecto: FNMT-RCM)
  --output FILE        Archivo de salida (por defecto: ./truststore.p12)
  --store-pass PASS    Password del truststore (por defecto: changeit)
  --list               Lista todos los proveedores disponibles
  -h, --help           Muestra esta ayuda

Ejemplos:
  $0                                                    # Genera truststore.p12 con FNMT-RCM
  $0 --all                                              # Genera truststore con TODOS los certificados
  $0 --provider "Banco Santander"                       # Truststore de Santander
  $0 --output certs.p12 --store-pass mypass             # Archivo personalizado
  $0 --list                                             # Lista proveedores
EOF
    exit 0
}

# ============================================================================
# Gestión del TSL
# ============================================================================

download_and_verify_tsl() {
    echo "ℹ️  Comprobando TSL..."

    curl -s -L -k -f -A "$UA" "$SHA_URL" -o "${SHA_FILE}.remote" 2>/dev/null || {
        echo "❌ No se pudo descargar el hash SHA256"; exit 1
    }
    REMOTE_SHA=$(awk '{print $1}' "${SHA_FILE}.remote")

    if [ -f "$TSL_FILE" ] && [ -f "$SHA_FILE" ]; then
        LOCAL_SHA=$(cat "$SHA_FILE")
        if [ "$REMOTE_SHA" == "$LOCAL_SHA" ]; then
            echo "✅ TSL actualizado (caché local)"
            rm -f "${SHA_FILE}.remote"
            return 0
        fi
    fi

    echo "📥 Descargando TSL..."
    curl -s -L -k -f -A "$UA" "$TSL_URL" -o "$TSL_FILE" 2>/dev/null || {
        echo "❌ No se pudo descargar el TSL"; exit 1
    }

    CALCULATED_SHA=$(sha256sum "$TSL_FILE" | awk '{print $1}')
    if [ "$CALCULATED_SHA" != "$REMOTE_SHA" ]; then
        echo "❌ El hash no coincide. Archivo corrupto."
        exit 1
    fi

    echo "$CALCULATED_SHA" > "$SHA_FILE"
    rm -f "${SHA_FILE}.remote"
    echo "✅ TSL descargado y verificado"
}

# ============================================================================
# Listar proveedores
# ============================================================================

list_providers() {
    if [ ! -f "$TSL_FILE" ]; then
        download_and_verify_tsl
    fi

    echo "ℹ️  Proveedores disponibles en el TSL:"
    echo "----------------------------------------------------------"
    awk '/<TSPName>/,/<\/TSPName>/' "$TSL_FILE" | \
    while IFS= read -r line; do
        if echo "$line" | grep -q '<Name xml:lang="es">'; then
            echo "$line" | grep -oP '(?<=<Name xml:lang="es">)[^<]*'
        elif echo "$line" | grep -q '<Name xml:lang="en">'; then
            echo "$line" | grep -oP '(?<=<Name xml:lang="en">)[^<]*'
        fi
    done | sort -u | nl -w 3 -s '. '
    echo "----------------------------------------------------------"
    echo "ℹ️  Total: $(grep -c '<TSPName>' "$TSL_FILE") proveedores"
}

# ============================================================================
# Generar truststore
# ============================================================================

generate_truststore() {
    local pattern="$1"
    local output_file="$2"
    local TEMP_DIR=$(mktemp -d)

    if [ "$pattern" == "ALL" ]; then
        echo "🔍 Buscando TODOS los certificados en el TSL..."
        cp "$TSL_FILE" "$TEMP_DIR/block.xml"
    else
        echo "🔍 Buscando certificados de: '$pattern'"

        # Encontrar línea del proveedor
        LINE_START=$(grep -n -i "$pattern" "$TSL_FILE" | head -n 1 | cut -d: -f1)
        if [ -z "$LINE_START" ]; then
            echo "❌ No se encontró el proveedor '$pattern'"
            echo "ℹ️  Usa --list para ver los disponibles"
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        # Extraer bloque del proveedor con perl para evitar pipes problemáticos
        perl -ne '
            BEGIN { $start = $ARGV[0]; $line = 0; $found = 0 }
            $line++;
            if ($line >= $start) {
                if (/<\/TrustServiceProvider>/ && !$found) { $found = 1; next }
                if ($found) { exit }
                print;
            }
        ' "$LINE_START" "$TSL_FILE" > "$TEMP_DIR/block.xml" 2>/dev/null || true
    fi

    # Extraer certificados con perl (uno por línea)
    perl -ne '
        while (/<X509Certificate>([^<]+)<\/X509Certificate>/g) {
            my $c = $1; $c =~ s/\s+//g;
            print "$c\n" if length($c) > 100;
        }
    ' "$TEMP_DIR/block.xml" > "$TEMP_DIR/certs.txt"

    COUNT=$(wc -l < "$TEMP_DIR/certs.txt")
    [ "$COUNT" -eq 0 ] && { echo "⚠️  No se encontraron certificados"; rm -rf "$TEMP_DIR"; exit 1; }

    echo "📜 $COUNT certificados encontrados"

    # Importar al truststore
    IMPORTED=0
    while IFS= read -r cert_b64; do
        [ -z "$cert_b64" ] && continue
        
        # Crear PEM
        {
            echo "-----BEGIN CERTIFICATE-----"
            echo "$cert_b64" | fold -w 64
            echo "-----END CERTIFICATE-----"
        } > "$TEMP_DIR/cert.pem"

        # Intentar obtener un alias descriptivo del CN
        CN=$(openssl x509 -noout -subject -in "$TEMP_DIR/cert.pem" 2>/dev/null | sed -n '/^subject/s/^.*CN\s*=\s*\([^,]*\).*$/\1/p' | head -n 1 | tr -cd '[:alnum:]_' | cut -c1-50)
        
        if [ -z "$CN" ]; then
            ALIAS="cert_${IMPORTED}"
        else
            ALIAS="${CN}_${IMPORTED}"
        fi

        # Importar
        keytool -delete -alias "$ALIAS" \
            -keystore "$output_file" -storepass "$STORE_PASS" -storetype PKCS12 2>/dev/null || true

        if keytool -import -alias "$ALIAS" -file "$TEMP_DIR/cert.pem" \
            -keystore "$output_file" -storepass "$STORE_PASS" \
            -storetype PKCS12 -noprompt 2>/dev/null; then
            let IMPORTED=IMPORTED+1
        fi
    done < "$TEMP_DIR/certs.txt"

    rm -rf "$TEMP_DIR"

    echo "----------------------------------------------------------"
    echo "✅ $IMPORTED certificados importados → $output_file ($(ls -lh "$output_file" | awk '{print $5}'))"
    echo "🔑 Password: $STORE_PASS"
    echo "----------------------------------------------------------"
}

# ============================================================================
# Parseo de argumentos
# ============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            PROVIDER="ALL"; shift 1 ;;
        --provider)
            PROVIDER="$2"; shift 2 ;;
        --output)
            OUTPUT_FILE="$2"; shift 2 ;;
        --store-pass)
            STORE_PASS="$2"; shift 2 ;;
        --list)
            download_and_verify_tsl
            list_providers; exit 0 ;;
        -h|--help)
            usage ;;
        *)
            echo "❌ Opción desconocida: $1"; usage ;;
    esac
done

# ============================================================================
# Main
# ============================================================================

echo "=========================================================="
echo "  Generador de Truststores desde TSL"
echo "=========================================================="
echo ""

download_and_verify_tsl
generate_truststore "$PROVIDER" "$OUTPUT_FILE"