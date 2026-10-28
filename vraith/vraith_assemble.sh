#!/bin/bash
# ============================================================
# VRAITH — Script d'assemblage SPWN
# Concatène toutes les sections en un seul fichier SPWN
# Usage : ./vraith_assemble.sh [--check]
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="$SCRIPT_DIR/vraith_full.spwn"

SECTIONS=(
    "vraith_section1.spwn"
    "vraith_section2.spwn"
    "vraith_section3.spwn"
    "vraith_section4.spwn"
    "vraith_section5.spwn"
    "vraith_section6.spwn"
    "vraith_section7.spwn"
    "vraith_section8.spwn"
    "vraith_section9.spwn"
)

# ── CHECK mode : vérifie que les fichiers existent ──
if [ "$1" = "--check" ]; then
    echo "=== VRAITH CHECK ==="
    ALL_OK=true
    for s in "${SECTIONS[@]}"; do
        f="$SCRIPT_DIR/$s"
        if [ -f "$f" ]; then
            LINES=$(wc -l < "$f")
            echo "  ✓ $s ($LINES lignes)"
        else
            echo "  ✗ $s MANQUANT"
            ALL_OK=false
        fi
    done
    if $ALL_OK; then
        echo ""
        echo "Tous les fichiers OK — prêt pour assemblage."
    else
        echo ""
        echo "Fichiers manquants — assemblage impossible."
        exit 1
    fi
    exit 0
fi

# ── ASSEMBLAGE ──
echo "=== VRAITH ASSEMBLE ==="
echo "// ============================================================" > "$OUTPUT"
echo "// VRAITH — Niveau complet (assemblé automatiquement)"          >> "$OUTPUT"
echo "// BPM: 200 | Newgrounds ID: 1633728 | Extreme Demon"          >> "$OUTPUT"
echo "// Généré le : $(date '+%Y-%m-%d %H:%M')"                      >> "$OUTPUT"
echo "// ============================================================" >> "$OUTPUT"
echo ""                                                                 >> "$OUTPUT"

for s in "${SECTIONS[@]}"; do
    f="$SCRIPT_DIR/$s"
    if [ ! -f "$f" ]; then
        echo "  ✗ $s introuvable — abandon"
        exit 1
    fi
    echo "" >> "$OUTPUT"
    echo "// ── ${s} ──────────────────────────────────────────────" >> "$OUTPUT"
    # Skip les lignes de déclaration de variables dupliquées (let BEAT, OX, GY, G)
    # Ne garde que la première occurrence (section 1)
    if [ "$s" = "vraith_section1.spwn" ]; then
        cat "$f" >> "$OUTPUT"
    else
        # Supprimer les re-déclarations de constantes déjà dans S1
        grep -v "^let BEAT" "$f" | grep -v "^let OX" | grep -v "^let GY " | grep -v "^let G " >> "$OUTPUT"
    fi
    echo "  ✓ $s ajouté"
done

echo ""
echo "=== ASSEMBLAGE TERMINÉ ==="
echo "Fichier : $OUTPUT"
TOTAL=$(wc -l < "$OUTPUT")
echo "Total lignes : $TOTAL"
echo ""
echo "Pour compiler avec SPWN :"
echo "  spwn build $OUTPUT"
